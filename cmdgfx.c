/****************************************
 * Cmdgfx (c) Mikael Sollenborn 2016-19 *
 ****************************************/

//#define GDI_OUTPUT

// needed for mingw to recognize GDI functions
#ifdef GDI_OUTPUT
#define _WIN32_WINNT 0x0500
#endif

#include <stdio.h>
#include <math.h>
#include <string.h>
#include <conio.h>
#include <windows.h>
#include "gfxlib.h"
#include "tinyexpr.h"

#ifdef GDI_OUTPUT
#include "cmdfonts.h"
#endif

// Issues/ideas:
// 1. Code optimization: Re-use images used several times, same way as for 3d objects (or possibly, use binary alternative to gxy to remove parsing, might be almost as fast)
// 2. Force col for tpoly/3d? Free rotation for block?
// 3. GDI: Actually showing text with text operation in pixel mode. Add last optional param to text op for cmdgfx_gdi. For text modes, will draw big letters of char/fgcol/bgcol!
// 4. Major: Port to Linux
// 5. RGB: long double for colexpr?

int XRES, YRES, FRAMESIZE;
uchar *video;
float *ZBufVideo = NULL;
int bAllowRepeated3dTextures = 0;
float texture_offset_x = 0, texture_offset_y = 0;
int bPrintFullErrorString = 0;

#define MAX_ERRS 64
typedef enum {ERR_NOF_ARGS, ERR_IMAGE_LOAD, ERR_OBJECT_LOAD, ERR_PARSE, ERR_MEMORY, ERR_OPTYPE, ERR_EXPRESSION } ErrorType;
typedef enum {OP_POLY=0, OP_IPOLY=1, OP_GPOLY=2, OP_TPOLY=3, OP_IMAGE=4, OP_BOX=5, OP_FBOX=6, OP_LINE=7, OP_PIXEL=8, OP_CIRCLE=9, OP_FCIRCLE=10, OP_ELLIPSE=11, OP_FELLIPSE=12, OP_TEXT=13, OP_3D=14, OP_BLOCK=15, OP_INSERT=16, OP_PLAY=17, OP_UNKNOWN=18 } OperationType;
typedef struct {
	ErrorType errType[MAX_ERRS];
	OperationType opType[MAX_ERRS];
	int index[MAX_ERRS];
	char *extras[MAX_ERRS];
	char *op[MAX_ERRS];
	int argNof[MAX_ERRS];
	int errCnt;
} ErrorHandler;

unsigned char hexLookup[256];
unsigned char colLookup[256];

#define GetHex(v) (hexLookup[(int)v])
#define GetCol(v, old) (colLookup[(int)v] == TRANSPVAL? old : hexLookup[(int)v])

#define MAX_STR_SIZE 300000
#define MAX_OP_SIZE 128000

HANDLE g_conin, g_conout;

HANDLE GetInputHandle() {
	return CreateFile("CONIN$", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
}

HANDLE GetOutputHandle() {
	return CreateFile("CONOUT$", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
}

int MouseClicked(MOUSE_EVENT_RECORD mer) {
	static int bReportNext = 0;
	int res = 0;

	switch(mer.dwEventFlags) {
		case DOUBLE_CLICK: case MOUSE_WHEELED:	bReportNext = 1; res = 1; break;
		
		case 0: case MOUSE_MOVED:
			if(mer.dwButtonState & FROM_LEFT_1ST_BUTTON_PRESSED || mer.dwButtonState & RIGHTMOST_BUTTON_PRESSED) {
				bReportNext = 1;
				res = 1;
			} else if (bReportNext) {
				bReportNext = 0;
				res = 1;
			} else {
				bReportNext = 0;
				res = 0;
			}
			break;
		default:
			break;
	}
		
	return res;
}

int MouseEventProc(MOUSE_EVENT_RECORD mer) {
	static int bReportNext = 0;
	
	int res;
	res = (mer.dwMousePosition.X << 5) | (mer.dwMousePosition.Y << 14);

	switch(mer.dwEventFlags) {
		case 0: case DOUBLE_CLICK: case MOUSE_MOVED:
			//printf("GOT: %d %d\n",mer.dwButtonState, mer.dwEventFlags);
			if(mer.dwButtonState & FROM_LEFT_1ST_BUTTON_PRESSED) {
				res |= 2;
			}
			if(mer.dwButtonState & RIGHTMOST_BUTTON_PRESSED) {
				res |= 4;
			}
			break;
		case MOUSE_WHEELED:
			if ((int)mer.dwButtonState < 0)
				res |= 8;
			else
				res |= 16;
			break;
		default:
			break;
	}
	
	res |= 1;
	
	return res;
}


int consoleFgCol=-1, consoleBgCol=-1;

void GetConsoleColor(){
	CONSOLE_SCREEN_BUFFER_INFO info;
	int col = 0x7;
	GetConsoleScreenBufferInfo(g_conout, &info);
	
	consoleFgCol = info.wAttributes & 0xf;
	consoleBgCol = (info.wAttributes>>4) & 0xf;
}

int GXY_MAX_X = 256, GXY_MAX_Y = 256;
unsigned int *g_rgbFgPalette, *g_rgbBgPalette;

int readGxy(char *fname, Bitmap *b_cols, Bitmap *b_chars, int *w1, int *h1, uchar color, int transpchar,int bIsFile,int bIgnoreFgColor, int bIgnoreBgColor, int bIgnoreAllCodes) {
	unsigned char *text, ch;
	uchar *pbcol, *pbchar;
	int fr, i, j, 	inlen;
	int x = 0, y = 0, yp=0;
	int v, v16;
	unsigned int fgCol, bgCol;
	uchar oldColor;
	uchar *cchars, *ccols;
	int w = GXY_MAX_X, h = GXY_MAX_Y;
	FILE *ifp;

	*w1 = -1;
	
	bgCol = (color>>BITSHL) & AND_MASK;
	fgCol = color & AND_MASK;
	oldColor = color;
	
	b_cols->data = (uchar *)malloc(w*h*sizeof(uchar));
	b_chars->data = (uchar *)malloc(w*h*sizeof(uchar));
	text = (char *)malloc(GXY_MAX_X * GXY_MAX_Y * 6);
	if (!text || !b_cols->data || !b_chars->data) { if (text) free(text); if (b_cols->data) free(b_cols->data); if(b_chars->data) free(b_chars->data); b_cols->data = b_chars->data = NULL; return 0; }
	MYMEMSET(b_cols->data, 0, w*h);
	MYMEMSET(b_chars->data, TRANSPVAL, w*h);

	pbchar = b_chars->data;
	pbcol = b_cols->data;

	if (bIsFile) {
		ifp=fopen(fname, "r");
		if (ifp == NULL) {
			free(text); free(b_cols->data); free(b_chars->data); b_cols->data = b_chars->data = NULL;
			return 0;
		} else {
			fr = fread(text, 1, GXY_MAX_X * GXY_MAX_Y * 6, ifp);
			fclose(ifp);
		}
		text[fr] = 0;
	} else
		strcpy(text, fname);
	inlen =strlen(text);

	for(i = 0; i < inlen; i++) {
		ch = text[i];
		if (ch == '\\' && !bIgnoreAllCodes) {
			i++;
			ch = text[i];

			switch(ch) {
				case '-': {
					x++;
					break;
				}
				case 'g': {
					i++; v16 = GetHex(text[i]);
					i++; v = 0;
					if (i < inlen) {
						v = GetHex(text[i]);
					}
					v16 = (v16*16) + v;
					if (x < w) { pbchar[yp+x] = v16; pbcol[yp+x] = color; }
					x++;
					break;
				}
				case '\\': {
					if (x < w) { pbchar[yp+x] = ch; pbcol[yp+x] = color; }
					x++;
					break;
				}
				case 'r': {
					uchar tempC = color;
					color = oldColor;
					oldColor = tempC;
					break;
				}
				case 'n': {
					if (x > *w1) *w1 = x;
					x = 0; y++; yp+=w;
					break;
				}
				default: {
					oldColor = color;
					if (!bIgnoreFgColor) {
						if (ch == 'u' || ch == 'U') {
							if (consoleBgCol==-1)
								GetConsoleColor();
							fgCol = ch == 'u'? consoleFgCol : consoleBgCol;
						} else
							fgCol = GetCol(ch, fgCol);
					}
					i++;
					if (!bIgnoreBgColor) {
						ch = text[i];
						if (ch == 'u' || ch == 'U') {
							if (consoleBgCol==-1)
								GetConsoleColor();
							bgCol = ch == 'u'? consoleFgCol : consoleBgCol;
						} else
							bgCol = GetCol(ch, bgCol);
					}
					#ifndef _RGB32
					color = fgCol | (bgCol<<4);
					#else
					if (bIgnoreFgColor) color = fgCol; else color = g_rgbFgPalette[fgCol];
					if (bIgnoreBgColor) color |= (PREPCOL)bgCol<<BITSHL; else color |= ((PREPCOL)g_rgbBgPalette[bgCol]<<BITSHL);
					#endif
				}
			}
		} else {
			if (y >= h) break;
			
			if (ch == 10) {
				if (x > *w1) *w1 = x;
				x = 0; y++; yp+=w;
			} else {
				if (ch == 9) ch=32;
				if (x < w) { pbchar[yp+x] = ch; pbcol[yp+x] = color; }
				x++;
			}
		}
	}		
	y++;
	*h1 = y;
	if (x > *w1) *w1 = x;
	
	ccols = (uchar *)malloc((*w1)*y*sizeof(uchar));
	cchars = (uchar *)malloc((*w1)*y*sizeof(uchar));
	if (!ccols || !cchars) { free(b_cols->data); free(b_chars->data); free(text); if (ccols) free(ccols); if (cchars) free(cchars); return 0; }
	
	for (i = 0; i < *h1; i++)
		for (j = 0; j < *w1; j++) {
			ccols[i*(*w1)+j] = b_cols->data[i*w+j];
			cchars[i*(*w1)+j] = b_chars->data[i*w+j];
		}

	b_chars->xSize = *w1; b_chars->ySize = *h1;
	b_cols->xSize = *w1; b_cols->ySize = *h1;
	b_cols->transpVal = b_chars->transpVal = -1;

	free(b_cols->data);
	free(b_chars->data);
	b_chars->data = cchars;
	b_cols->data = ccols;
	
	free(text);
	return 1;
}



int parseInput(char *s_fgcol, char *s_bgcol, char *s_dchar, int *fgcol, int *bgcol, int *dchar, int *bWriteChars, int *bWriteCols) {
	int writeCols = 1, writeChars = 1, writeFgBg = 3, sLen;
	
	sLen = strlen(s_fgcol);
	if (sLen==1) {
		*fgcol = strtol(s_fgcol, NULL, 16);
		if (s_fgcol[0] == 'U') {
			if (consoleBgCol==-1)
				GetConsoleColor();
			*fgcol = consoleBgCol;
		}
		else if (s_fgcol[0] == 'u') {
			if (consoleFgCol==-1)
				GetConsoleColor();
			*fgcol = consoleFgCol;
		}
		else if (s_fgcol[0] == '?')
			writeCols = 0, writeFgBg -= 1;
#ifndef _RGB32		
	} else
		*fgcol = strtol(s_fgcol, NULL, 10);
#else
		*fgcol = g_rgbFgPalette[*fgcol] & 0x00ffffff;
	} else {
		if (sLen==2) {
			*fgcol = strtol(s_fgcol, NULL, 10);
			if (*fgcol < 0 || *fgcol > 15) *fgcol = 0;
			*fgcol = g_rgbFgPalette[*fgcol] & 0x00ffffff;
		} else {
			*fgcol = strtoll(s_fgcol, NULL, 16);
		}
	}
#endif	

	sLen = strlen(s_bgcol);
	if (sLen==1) {
		*bgcol = strtol(s_bgcol, NULL, 16);
		if (s_bgcol[0] == 'U') {
			if (consoleBgCol==-1)
				GetConsoleColor();
			*bgcol = consoleBgCol;
		}
		else if (s_bgcol[0] == 'u') {
			if (consoleFgCol==-1)
				GetConsoleColor();
			*bgcol = consoleFgCol;
		}
		else if (s_bgcol[0] == '?')
			writeCols = 0, writeFgBg -= 2;
#ifndef _RGB32		
	} else
		*bgcol = strtol(s_bgcol, NULL, 10);
#else
		*bgcol = g_rgbBgPalette[*bgcol] & 0x00ffffff;
	} else {
		if (sLen==2) {
			*bgcol = strtol(s_bgcol, NULL, 10);
			if (*bgcol < 0 || *bgcol > 15) *bgcol = 0;
			*bgcol = g_rgbBgPalette[*bgcol] & 0x00ffffff;
		} else
			*bgcol = strtoll(s_bgcol, NULL, 16);
	}
#endif	

	if (strlen(s_dchar)==1) {
		if (s_dchar[0] == '?')
			writeChars = 0;
		*dchar = s_dchar[0];
	} else
		*dchar = strtol(s_dchar, NULL, 16);
	
	if (bWriteChars) *bWriteChars = writeChars;
	if (bWriteCols) *bWriteCols = writeCols;
	
	return writeFgBg;
}


ErrorHandler *g_errH;
int g_opCount;
void reportFileError(ErrorHandler *errHandler, OperationType opType, ErrorType errType, int index, char *extras, char *op);
uchar *g_videoCol, *g_videoChar;
int g_bSleepingWait = 0;
int g_bFlushAfterELwrite = 0;

int readCmdGfxTexture(Bitmap *bmap, char *fname) {
	char *orgFnameP = fname;
	int res = 0;
	if (!bmap || !fname) return res;
	bmap->transpVal = -1;
	
	if (strstr(fname, ".pcx")) {
		char transp[16], inpname[256];
		int nofargs, dum1, dum2, transpVal = -1;
		
		nofargs = sscanf(fname, "%250s %13s", inpname, transp);
		if (nofargs > 1) parseInput(transp, transp, transp, &transpVal, &dum1, &dum2, NULL, NULL);
		res = PCXload(bmap, inpname);

#ifdef _RGB32		
		for(int i = 0; i < bmap->xSize*bmap->ySize; i++)
			bmap->data[i] = g_rgbFgPalette[bmap->data[i]] & 0xffffff;
#endif
		
		bmap->transpVal = transpVal;
		bmap->bCmdBlock = 0;
		bmap->extras = NULL;
		bmap->extrasType = EXTRAS_NONE;


#ifdef _RGB32

	} else if (strstr(fname, ".bmp")) {
		char transp[16], inpname[256];
		int nofargs, dum1, dum2, transpVal = -1;
		
		nofargs = sscanf(fname, "%250s %13s", inpname, transp);
		if (nofargs > 1) parseInput(transp, transp, transp, &transpVal, &dum1, &dum2, NULL, NULL);
		res = BMPload(bmap, inpname);

		bmap->transpVal = transpVal;
		bmap->bCmdBlock = 0;
		bmap->extras = NULL;
		bmap->extrasType = EXTRAS_NONE;

	} else if (strstr(fname, ".bxy")) {
		int w, h;
		char transp[16], inpname[256];
		int nofargs, dum1, dum2, transpVal = -1;
		
		nofargs = sscanf(fname, "%250s %13s", inpname, transp);
		if (nofargs > 1) parseInput(transp, transp, transp, &dum1, &dum2, &transpVal, NULL, NULL);
		
		bmap->extras = (Bitmap *) calloc(sizeof(Bitmap), 1);
		if (!bmap->extras) return res;
		bmap->extrasType = EXTRAS_BITMAP;
		res = BXYload(bmap, (Bitmap *)bmap->extras, inpname);
		bmap->transpVal = transpVal;
		bmap->bCmdBlock = 0;
		
#endif

	} else if (strstr(fname, "cmdblock")) {
		int x, y, w, h, i, j, ii, vi, nofargs, transpVal = -1, blockRefresh = 0;
		Bitmap *bmap2;
	
		fname = strstr(fname, "cmdblock ") + strlen("cmdblock ");
		while (*fname==32) fname++;

		nofargs = sscanf(fname, "%d %d %d %d %x %d", &x, &y, &w, &h, &transpVal, &blockRefresh);
		if (nofargs < 4)
			return 0;
		
		if (x < 0 || y < 0 || x >= XRES || y >= YRES)
			return 0;

		if (x+w >= XRES) w -= (x+w)-(XRES+0);
		if (y+h >= YRES) h -= (y+h)-(YRES+0);

		bmap2 = (Bitmap *) calloc(sizeof(Bitmap), 1);
		bmap2->data = (uchar *) malloc( w * h * sizeof(uchar));
		bmap->data = (uchar *) malloc( w * h * sizeof(uchar));
		if (!bmap2 || ! bmap->data || ! bmap2->data) { if(bmap2->data) free(bmap2->data); if(bmap->data) free(bmap->data); if (bmap2) free(bmap2); return res; }
		bmap->extras = bmap2;
		bmap->xSize = bmap2->xSize = w;
		bmap->ySize = bmap2->ySize = h;
		bmap->extrasType = EXTRAS_BITMAP;
		bmap->transpVal = -1;
		bmap2->transpVal = transpVal;
		bmap->bCmdBlock = 1;
		strncpy(bmap->pathOrBlockString, orgFnameP, 64);
		bmap->pathOrBlockString[64] = 0;
		bmap->blockRefresh = blockRefresh == 2? 2 : 0;
		
		for (i = 0; i < h; i++) {
			ii = w*i; vi = x + y * XRES + i * XRES;
			for (j = 0; j < w; j++) {
				bmap->data[ii + j] = g_videoCol[vi + j];
				bmap2->data[ii + j] = g_videoChar[vi + j];
			}
		}
		res = 1;
		
	} else if (strstr(fname, "cmdcolblock")) {
		int x, y, w, h, i, j, ii, vi, nofargs, transpVal = -1, blockRefresh = 0;
	
		fname = strstr(fname, "cmdcolblock ") + strlen("cmdcolblock ");
		while (*fname==32) fname++;

		nofargs = sscanf(fname, "%d %d %d %d %x %d", &x, &y, &w, &h, &transpVal, &blockRefresh);
		if (nofargs < 4)
			return 0;
		
		if (x < 0 || y < 0 || x >= XRES || y >= YRES)
			return 0;

		if (x+w >= XRES) w -= (x+w)-(XRES+0);
		if (y+h >= YRES) h -= (y+h)-(YRES+0);

		bmap->data = (uchar *) malloc( w * h * sizeof(uchar));
		if (!bmap->data) { if(bmap->data) free(bmap->data); return res; }
		bmap->extras = NULL;
		bmap->xSize = w;
		bmap->ySize = h;
		bmap->extrasType = EXTRAS_NONE;
		bmap->transpVal = transpVal;
		bmap->bCmdBlock = 1;
		strncpy(bmap->pathOrBlockString, orgFnameP, 64);
		bmap->pathOrBlockString[64] = 0;
		bmap->blockRefresh = blockRefresh == 2? 2 : 0;
		
		for (i = 0; i < h; i++) {
			ii = w*i; vi = x + y * XRES + i * XRES;
			for (j = 0; j < w; j++) {
				bmap->data[ii + j] = g_videoCol[vi + j];
			}
		}
		res = 1;
		
	} else if (strstr(fname, "cmdpalette ")) {
		char s_fgcols[34][64], s_bgcols[34][10], s_dchars[34][4];
		int pchar[64], pbWriteChars[64], pbWriteCols[64];
		uchar pfgbg[64], *cols;
		int nofcols, i, j;
		int fgcol, bgcol;

		fname = strstr(fname, "cmdpalette ") + strlen("cmdpalette ");
		while (*fname==32) fname++;

		nofcols = sscanf(fname, "%62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s", 
																			s_fgcols[0], s_bgcols[0], s_dchars[0],	s_fgcols[1], s_bgcols[1], s_dchars[1], s_fgcols[2], s_bgcols[2], s_dchars[2],
																			s_fgcols[3], s_bgcols[3], s_dchars[3], s_fgcols[4], s_bgcols[4], s_dchars[4], s_fgcols[5], s_bgcols[5], s_dchars[5],
																			s_fgcols[6], s_bgcols[6], s_dchars[6], s_fgcols[7], s_bgcols[7], s_dchars[7],	s_fgcols[8], s_bgcols[8], s_dchars[8],
																			s_fgcols[9], s_bgcols[9], s_dchars[9],	s_fgcols[10], s_bgcols[10], s_dchars[10],	s_fgcols[11], s_bgcols[11], s_dchars[11],
																			s_fgcols[12], s_bgcols[12], s_dchars[12],	s_fgcols[13], s_bgcols[13], s_dchars[13],	s_fgcols[14], s_bgcols[14], s_dchars[14],
																			s_fgcols[15], s_bgcols[15], s_dchars[15], s_fgcols[16], s_bgcols[16], s_dchars[16], s_fgcols[17], s_bgcols[17], s_dchars[17],
																			s_fgcols[18], s_bgcols[18], s_dchars[18],	s_fgcols[19], s_bgcols[19], s_dchars[19], s_fgcols[20], s_bgcols[20], s_dchars[20],
																			s_fgcols[21], s_bgcols[21], s_dchars[21], s_fgcols[22], s_bgcols[22], s_dchars[22], s_fgcols[23], s_bgcols[23], s_dchars[23],
																			s_fgcols[24], s_bgcols[24], s_dchars[24], s_fgcols[25], s_bgcols[25], s_dchars[25], s_fgcols[26], s_bgcols[26], s_dchars[26],
																			s_fgcols[27], s_bgcols[27], s_dchars[27], s_fgcols[28], s_bgcols[28], s_dchars[28], s_fgcols[29], s_bgcols[29], s_dchars[29],
																			s_fgcols[30], s_bgcols[30], s_dchars[30], s_fgcols[31], s_bgcols[31], s_dchars[31] );
		if (nofcols < 3)
			return res;
		nofcols /= 3;

		bmap->extras = (uchar *) malloc(sizeof(uchar) * (34 * 4 + 1));
		if (!bmap->extras) return res;
		bmap->data = NULL;
 		bmap->extrasType = EXTRAS_ARRAY;
		bmap->bCmdBlock = 0;
			
		for (i = 0; i < nofcols; i++) {
			parseInput(s_fgcols[i%nofcols], s_bgcols[i%nofcols], s_dchars[i%nofcols], &fgcol, &bgcol, &pchar[i], &pbWriteChars[i], &pbWriteCols[i]);
			pfgbg[i] = (bgcol << 4) | fgcol;
		}
		cols = (uchar *)bmap->extras;
		j = 0; cols[j++] = nofcols;
		for (i = 0; i < nofcols; i++) {
			cols[j++] = pfgbg[i];
			cols[j++] = pchar[i];
			cols[j++] = pbWriteChars[i];
			cols[j++] = pbWriteCols[i];
		}
		res = 1;
	} else {
		int w, h;
		char transp[16], inpname[256];
		int nofargs, dum1, dum2, transpVal = -1;
		
		nofargs = sscanf(fname, "%250s %13s", inpname, transp);
		if (nofargs > 1) parseInput(transp, transp, transp, &dum1, &dum2, &transpVal, NULL, NULL);
		
		bmap->extras = (Bitmap *) calloc(sizeof(Bitmap), 1);
		if (!bmap->extras) return res;
		bmap->extrasType = EXTRAS_BITMAP;
		res = readGxy(inpname, bmap, (Bitmap *)bmap->extras, &w, &h, 0, -1, 1, 0, 0, 0);
		bmap->transpVal = transpVal;
		bmap->bCmdBlock = 0;
	}
	
	if (!res) reportFileError(g_errH, OP_3D, ERR_IMAGE_LOAD, g_opCount, fname, NULL);
	return res;
}


CHAR_INFO * readScreenBlock() {
	COORD a = { 1, 1 };
	COORD b = { 0, 0 };
	SMALL_RECT r;
	CHAR_INFO *str;
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	int x,y, w, h;
	HANDLE conout = GetOutputHandle();
	
	GetConsoleScreenBufferInfo(conout, &screenBufferInfo);

	x = y = 0;
	w = screenBufferInfo.dwSize.X;
	h = screenBufferInfo.dwSize.Y;

	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * w*h);
	if (!str) {
		CloseHandle(conout);
		return NULL;
	}

	// Stupid bug in ReadConsoleOutput doesn't seem to read more than ~15680 chars, then it's all garbled characters!! Have to read in smaller blocks
	{
		int i, j, k, l;
		l = 15000 / w;
		i = h / l;
		for (j = 0; j <= i; j++) {
			r.Left = 0;
			r.Top = j*l;
			r.Right = w;
			if (i == j) k = h % l; else k = l;
			r.Bottom = j*l+k;
			a.X = r.Right;
			a.Y = k;
			ReadConsoleOutput(conout, str+j*l*w, a, b, &r);
		}
	}

	CloseHandle(conout);
	return str;
}

#ifndef GDI_OUTPUT

#ifndef _RGB32
void convertToText(int XRES, int YRES, uchar *videoCol, uchar *videoChar, uchar *fgPalette, uchar *bgPalette, int x,int y, int outw, int outh) {
	CHAR_INFO *str;
	COORD a, b;
	SMALL_RECT r;
	HANDLE hCurrHandle;
	int i,j,k,l;

	a.X = outw; a.Y = outh;

	hCurrHandle = g_conout;
	str = (CHAR_INFO *) calloc (sizeof(CHAR_INFO) * (a.X * a.Y), 1);
	if (!str) return;

	if (fgPalette == NULL) {
		
		for (i = 0; i < outh; i++) {
			k = i * XRES; l = i * outw;
			for (j = 0; j < outw; j++) {
				str[l+j].Attributes = videoCol[k+j];
				str[l+j].Char.AsciiChar = videoChar[k+j];
			}
		}
	} else {
		for (i = 0; i < outh; i++) {
			k = i * XRES; l = i * outw;
			for (j = 0; j < outw; j++) {
				str[l+j].Attributes = fgPalette[videoCol[k+j] & 0xf] | (bgPalette[videoCol[k+j] >> 4] << 4);
				str[l+j].Char.AsciiChar = videoChar[k+j];
			}
		}
	}
	
	b.X = b.Y = r.Left = r.Top = 0;
	r.Right = a.X + x;
	r.Bottom = a.Y + y;
	r.Left = x;
	r.Top = y;
	WriteConsoleOutput(hCurrHandle, str, a, b, &r);

	free(str);
}

#else

void convertToVT100(int XRES, int YRES, uchar *videoCol, uchar *videoChar, int x, int y, int outw, int outh) {
	unsigned int i,j,fcol,bcol,cchar, oldfcol = -1, oldbcol = -1, k=0;
	unsigned char *outS = malloc(40 * XRES + 10);

	for (i = 0; i < outh-1; i++) {
		*outS=0; k=0;
		k += sprintf(outS, "%c[%d;%dH",27,y+i+1,x);
		for (j = 0; j < outw; j++) {
			cchar = videoChar[j+i*XRES] SAFE_AND; if (cchar==0) cchar=255;
			fcol = videoCol[j+i*XRES] & 0xffffff;
			bcol = videoCol[j+i*XRES] >> BITSHL;
			if (fcol != oldfcol) {
				k += sprintf(&outS[k], "%c[38;2;%d;%d;%dm",27,(fcol>>16)&0xff,(fcol>>8)&0xff,fcol&0xff);
				oldfcol = fcol;
			}
			if (bcol != oldbcol) {
				k += sprintf(&outS[k], "%c[48;2;%d;%d;%dm",27,(bcol>>16)&0xff,(bcol>>8)&0xff,bcol&0xff);
				oldbcol = bcol;
			}
			outS[k] = cchar; k++; outS[k] = 0; 
		}
		puts(outS);
	}
	
	free(outS);
}


#endif

#endif

#ifdef GDI_OUTPUT

HWND g_hWnd = NULL;
HDC g_hDc = NULL, g_hDcBmp = NULL;

unsigned char* g_lpBitmapBits;
HBITMAP g_bitmap;

void convertToGdiBitmap(int XRES, int YRES, uchar *videoCol, uchar *videoChar, int fontIndex, unsigned int *cmdPaletteFg, unsigned int *cmdPaletteBg, int x, int y, int outw, int outh, int bAbsBitmapPos, int bWindowedMode) {
	HBITMAP hBmp1 = NULL;
	HGDIOBJ hGdiObj = NULL;
	BITMAP bmp = {0};
	LONG w = 0, h = 0;
	int iRet = EXIT_FAILURE;
	unsigned int *outdata = NULL, *pcol, *outt, *fgcol, *bgcol, rgbfgcol, rgbbgcol;
	int i,j,ccol,cchar,l,m, index;
	static unsigned int cmdPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	static int *fontData[16] = { &cmd_font0_data[0][0], &cmd_font1_data[0][0], &cmd_font2_data[0][0], &cmd_font3_data[0][0], &cmd_font4_data[0][0], &cmd_font5_data[0][0], &cmd_font6_data[0][0], &cmd_font7_data[0][0], &cmd_font8_data[0][0], &cmd_font9_data[0][0], NULL, NULL, NULL };
	int fontWidth[16] = { cmd_font0_w, cmd_font1_w, cmd_font2_w, cmd_font3_w, cmd_font4_w, cmd_font5_w, cmd_font6_w, cmd_font7_w, cmd_font8_w, cmd_font9_w, 1,2,3 };
	int fontHeight[16] = { cmd_font0_h, cmd_font1_h, cmd_font3_h, cmd_font3_h, cmd_font4_h, cmd_font5_h, cmd_font6_h, cmd_font7_h, cmd_font8_h, cmd_font9_h, 1,2,3 };
	int fw, fh, *data, val, bpp = 4;
	unsigned int *palFg, *palBg;
	static int oldw=-1, oldh=-1, oldFontIndex = -1, oldbWindowedMode = -1;
	unsigned long long rgbcoltemp;
	
	if (cmdPaletteFg == NULL) palFg = &cmdPalette[0]; else palFg = cmdPaletteFg;
	if (cmdPaletteBg == NULL) palBg = &cmdPalette[0]; else palBg = cmdPaletteBg;

	if (fontIndex < 0 || fontIndex > 12)
		return;

	fw = fontWidth[fontIndex];
	fh = fontHeight[fontIndex];
	data = fontData[fontIndex];

	if (!bAbsBitmapPos) {
		x *= fw; y *= fh;
	}

	w = outw * fw;
	h = outh * fh;

	if (g_hDc == NULL || w != oldw || h != oldh || fontIndex != oldFontIndex || bWindowedMode != oldbWindowedMode) {
		if (g_hDc != NULL) {
			if (g_hDc) ReleaseDC(g_hWnd, g_hDc);
			if (g_hDcBmp) DeleteDC(g_hDcBmp);
			if (g_bitmap) DeleteObject(g_bitmap);
		}
		
		oldw = w; oldh = h; oldFontIndex = fontIndex; oldbWindowedMode = bWindowedMode;
		
		if ((g_hWnd = GetConsoleWindow())) {
			if ((g_hDc = GetDC(bWindowedMode? g_hWnd : NULL))) {
				BITMAPINFO bi; 

				g_hDcBmp = CreateCompatibleDC(g_hDc);
				
				ZeroMemory(&bi, sizeof(BITMAPINFO));
				bi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
				bi.bmiHeader.biWidth = w;
				bi.bmiHeader.biHeight = -h;  //negative so (0,0) is at top left
				bi.bmiHeader.biPlanes = 1;
				bi.bmiHeader.biBitCount = 32;
				
				g_bitmap = CreateDIBSection(g_hDcBmp, &bi, DIB_RGB_COLORS,  (VOID**)&g_lpBitmapBits, NULL, 0);
				SelectObject(g_hDcBmp, g_bitmap); 
			}
		}
	}

	if (g_hDcBmp)
	{
		outdata = (unsigned int *)g_lpBitmapBits;
		
		if (fontIndex < 10) {
			for (i = 0; i < outh; i++) {
				for (j = 0; j < outw; j++) {
					cchar = videoChar[j+i*XRES] SAFE_AND;
#ifndef _RGB32
					ccol = videoCol[j+i*XRES];
					fgcol = &palFg[(ccol&0xf)];
					bgcol = &palBg[(ccol>>4)];
#else
					rgbcoltemp = videoCol[j+i*XRES];
					rgbfgcol = rgbcoltemp&0xffffffff;
					rgbbgcol = rgbcoltemp>>BITSHL;
#endif
					for (l = 0; l < fh; l++) {
						index = (j*fw + (i*fh+l)*outw*fw);
						val = data[cchar*fh+l];
						outt = &outdata[index];
						for (m = 0; m < fw; m++) {
#ifndef _RGB32
							*outt++ = (val & 1) ? *fgcol : *bgcol;
#else
							*outt++ = (val & 1) ? rgbfgcol : rgbbgcol;
#endif
							val >>= 1;
						}
					}
				}
			}
		} else { // pixelfont
			if (fw == 1) {
				for (i = 0; i < outh; i++) {
					for (j = 0; j < outw; j++) {
						cchar = videoChar[j+i*XRES] SAFE_AND;
#ifndef _RGB32
						ccol = videoCol[j+i*XRES];
						fgcol = &palFg[(ccol&0xf)];
						bgcol = &palBg[(ccol>>4)];

						pcol = fgcol; if (cchar == 0 || cchar == 32 || cchar == 255) pcol = bgcol; 
						outdata[j + i*outw] = *pcol;
#else
						rgbcoltemp = videoCol[j+i*XRES];
						if (cchar == 0 || cchar == 32 || cchar == 255) rgbfgcol = rgbcoltemp>>BITSHL; else rgbfgcol = rgbcoltemp&0xffffffff;
						outdata[j + i*outw] = rgbfgcol;
#endif
						
					}
				}
			} else {
				for (i = 0; i < outh; i++) {
					for (j = 0; j < outw; j++) {
						cchar = videoChar[j+i*XRES] SAFE_AND;
#ifndef _RGB32
						ccol = videoCol[j+i*XRES];
						fgcol = &palFg[(ccol&0xf)];
						bgcol = &palBg[(ccol>>4)];
						pcol = fgcol; if (cchar == 0 || cchar == 32 || cchar == 255) pcol = bgcol; 
#else
						rgbcoltemp = videoCol[j+i*XRES];
						if (cchar == 0 || cchar == 32 || cchar == 255) rgbfgcol = rgbcoltemp>>BITSHL; else rgbfgcol = rgbcoltemp&0xffffffff;
#endif

						for (l = 0; l < fh; l++) {
							index = (j*fw + (i*fh+l)*outw*fw);
							outt = &outdata[index];
							for (m = 0; m < fw; m++) {
#ifndef _RGB32
								*outt++ = *pcol;
#else
								*outt++ = rgbfgcol;
#endif
							}
						}
					}
				}
			}
		}

		if (BitBlt(g_hDc, (int)x, (int)y, (int)w, (int)h, g_hDcBmp, 0, 0, SRCCOPY)) {
			iRet = EXIT_SUCCESS;
		}
	}

	GdiFlush();
	
	if (iRet == EXIT_FAILURE) printf("#ERR: Failure processing output bitmap\n");
}

#endif



#ifdef _RGB32

void readOutChars(char *pch, unsigned char *outCh) {
	int i, j = 0, v16, v, inlen = strlen(pch);
	
	for (i = 0; i < inlen; i++) {
		if (pch[i] == '\\' && pch[i+1] == 'g') {
			i+=2;
			
			if (i < inlen) {
				v16 = GetHex(pch[i]);
				i++; v = 0;
				if (i < inlen)
					v = GetHex(pch[i]);
				
				outCh[j] = (v16*16) + v;
				j++;
			}
		} else {
			outCh[j] = pch[i];
			j++;
		}
	}
	
	outCh[j] = 0;
}

void parseConv16Flag(char *inVal, unsigned char *outCh, int *div, int *mode) {
	int tempMode, tempDiv, chIndex, nof, bCustomSet=0;
	char tempOutCh[64];
	*mode = 0;
	*div = 1000;
	outCh[0]=0x20; outCh[1]=0x2b; outCh[2]=0x04; outCh[3]=0x05; outCh[4]=0; // 0x08 på index 3 (visar MER av färg1 än färg0 (som det eg ej ska vara), så får man lite "kromigt" utseende
	tempOutCh[0]=0;
	
	if (inVal[0]== 0) return;
	nof = sscanf(inVal, "%d %62s %d", &tempMode, tempOutCh, &tempDiv);
	
	if (nof > 1) {
		if (strlen(tempOutCh) > 1) {
			readOutChars(tempOutCh, outCh);
			bCustomSet=1;
		} else
			sscanf(tempOutCh, "%d", &chIndex);
	}
	
	if (nof < 1) tempMode=0;
	if (nof < 2) { chIndex = 0; }
	if (tempMode < 0 || tempMode > 1) tempMode = 0;
	if (nof < 3) { if (tempMode==0) tempDiv = 1000; else tempDiv = 3000; }
	
	if (tempDiv < 1) tempDiv = 1000;
	if (chIndex < 0 || chIndex > 3) chIndex = 0;
	
	*mode = tempMode;
	*div = tempDiv;
	
	if (bCustomSet)
		return;
	
	switch(chIndex) {
		case 0: outCh[0]=0x20; outCh[1]=0x2b; outCh[2]=0x04; outCh[3]=0x05; outCh[4]=0; break;
		case 1: outCh[0]=0x20; outCh[1]=0xb0; outCh[2]=0xb1; outCh[3]=0; break;
		case 2: strcpy(outCh, " .-:ogM"); break;
		case 3: outCh[0]=0x20; outCh[1]=0xfa; outCh[2]=0xf9; outCh[3]=0xfe; outCh[4]=0xdf; outCh[5]=0;  break;
	}
}

void convertFgRgbTo16Col(int XRES, int YRES, uchar *videoCol, uchar *videoChar, uchar *videoColOut, uchar *videoCharOut, unsigned int *cmdPaletteFg, unsigned char *outCh, int div, int mode, int outw, int outh) {
	int i,j, k, l, m,n;
	unsigned long inCol;
	unsigned int r,g,b,rd,gd,bd, rp,gp,bp, ri,gi,bi, palcol;

	unsigned int closestI[4], closest[4], cc, cci = 0, len;
	unsigned int dist[32];
	
	int chLen = strlen(outCh) - 1;
		
	for (j = 0; j < outh; j++) {
		k = j * XRES;
		for (i = 0; i < outw; i++) {
			inCol = videoCol[k + i] & 0xffffff;

			ri = inCol >> 16;
			gi = (inCol >> 8) & 0xff;
			bi = inCol & 0xff;

			for (l = 0; l <16; l++) {
				palcol = cmdPaletteFg[l] & 0xffffff;
				rp = palcol >> 16;
				gp = (palcol >> 8) & 0xff;
				bp = palcol & 0xff;
			
				rd = abs(ri - rp);
				gd = abs(gi - gp);
				bd = abs(bi - bp);

				dist[l] = rd*rd+gd*gd+bd*bd;
			}
			
			for (m = 0; m <2; m++) {
				cc = 100000000;
				for (n = 0; n <16; n++) {
					if (dist[n] < cc) {
						cc = dist[n];
						cci = n;
					}
				}
				closestI[m] = cci;
				closest[m] = cc;
				dist[cci] = 10000000;
		//		printf("%d %d\n", cci, cc);
			}
			
			videoColOut[k + i] = (cmdPaletteFg[closestI[1]] & 0xffffff) | ((PREPCOL)(cmdPaletteFg[closestI[0]] & 0xffffff) << BITSHL);

			if (mode == 0) {
				m = abs(closest[0]-closest[1])/div; // 1000
				if (m > chLen) m=chLen;
				m = chLen - m;
			} else {
				m = closest[0]/div; // 3000
				//m = closest[0]>>11;
				if (m > chLen) m=chLen;
			}
			
			videoCharOut[k + i] = outCh[m];
		}
	}
	
}
#endif


int getConsoleDim(int bH) {
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	HANDLE conout = GetOutputHandle();
	GetConsoleScreenBufferInfo(conout, &screenBufferInfo);
	CloseHandle(conout);
	return bH? screenBufferInfo.dwSize.Y : screenBufferInfo.dwSize.X;
}

void setResolution(int resX, int resY) {
	XRES=resX;
	YRES=resY;
	FRAMESIZE=XRES*YRES;
}

char *insertCgx(char *inp) {
	char *nb = NULL, *nf = NULL, *fnd, *fnd2, fname[256], *currI, *currO, nofile[64] = " [FILE NOT FOUND] ";
	FILE *ifp;
	int fr;

	fnd = strstr(inp, "insert ");
 	if (!fnd) return NULL;

	nb = (char *)malloc(MAX_OP_SIZE);
	if (!nb) return NULL;
	nf = (char *)malloc(MAX_OP_SIZE);
	if (!nf) { free(nb); return NULL; }
	currI = inp;
	currO = nb;
	
	do {
		int fstart = 7;
		
		while (fnd[fstart] == ' ')
			fstart++;
		fnd2 = strstr((char *)(fnd + fstart), "&");
		if (!fnd2)
			fnd2 = &inp[strlen(inp)];

		memcpy(currO, currI, fnd - currI);
		currO = currO + (fnd - currI);
		
		memcpy(fname, (char *)(fnd + fstart), (int)fnd2 - (int)fnd - (fstart - 1));
		fname[(int)fnd2 - (int)fnd - fstart] = 0;
		ifp=fopen(fname, "r");
		if (ifp == NULL) {
			memcpy(currO, nofile, strlen(nofile));
			currO = currO + strlen(nofile);
		} else {
			fr = fread(nf, 1, MAX_OP_SIZE, ifp);
			memcpy(currO, nf, fr);
			currO = currO + fr;
			fclose(ifp);
		}
		
		currI = fnd2;
		fnd = strstr(currI, "insert ");
	} while(fnd);

	memcpy(currO, currI, strlen(currI));
	currO[strlen(currI)] = 0;

	free(nf);
	return nb;
}


void processFromTranspBuffer(uchar *videoTransp, uchar *videoCol, uchar *videoChar, int transpcol, int dchar, int bWriteChars, int bWriteCols, int x,int y, int w, int h) {
	int i,j,k,l;

	if (x+w < XRES) w++;
	if (y+h < YRES) h++;
	
	l = y*XRES + x;
	
	for (i = 0; i < h; i++) {
		k = l;
		for (j = 0; j < w; j++) {
			if ((videoTransp[k] & AND_MASK) != transpcol) {
				if (bWriteCols) videoCol[k] = videoTransp[k];
				if (bWriteChars) videoChar[k] = dchar;
			}
			k++;
		}
		l += XRES;
	}
}

void getBounds(intVector vv[], int points, int *_minx, int *_maxx, int *_miny, int *_maxy) {
	int i, minx=vv[0].x, maxx=vv[0].x, miny=vv[0].y, maxy=vv[0].y;
	
	for (i = 1; i < points; i++) {
		if (vv[i].x < minx) minx=vv[i].x;
		if (vv[i].x > maxx) maxx=vv[i].x;
		if (vv[i].y < miny) miny=vv[i].y;
		if (vv[i].y > maxy) maxy=vv[i].y;
	}
	if (minx < 0) minx=0;
	if (maxx < 0) maxx=0;
	if (miny < 0) miny=0;
	if (maxy < 0) maxy=0;
	if (minx >= XRES) minx=XRES-1;
	if (maxx >= XRES) maxx=XRES-1;
	if (miny >= YRES) miny=YRES-1;
	if (maxy >= YRES) maxy=YRES-1;
	
	*_minx = minx; *_maxx = maxx; *_miny = miny; *_maxy = maxy;
}

void drawTranspTPoly(uchar *videoTransp, uchar *videoCol, uchar *videoChar, int transpval, int dchar, int bWriteChars, int bWriteCols,intVector vv[], int points, Bitmap *bild, PREPCOL plusVal, int bPerspectiveCorrected) {
	int minx, maxx, miny, maxy, i, ok;
	video = videoTransp;
	
	getBounds(vv, points, &minx, &maxx, &miny, &maxy);
	transpval &= AND_MASK;
	//printf("%llx\n",plusVal);getch();
	fbox(minx, miny, maxx-minx, maxy-miny, transpval);
	ok = scanConvex_tmap(vv, points, NULL, bild, plusVal, bPerspectiveCorrected);
	if (ok) processFromTranspBuffer(videoTransp, videoCol, videoChar, transpval, dchar, bWriteChars, bWriteCols, minx, miny, maxx-minx, maxy-miny);
}


void processFromDoubleTranspBuffer(uchar *videoColTransp, uchar *videoCharTransp, uchar *videoCol, uchar *videoChar, int transpchar, int bWriteChars, int bWriteCols, int x,int y, int w, int h) {
	int i,j,k,l;

	if (x+w < XRES) w++;
	if (y+h < YRES) h++;
	l = y*XRES + x;
	
	for (i = 0; i < h; i++) {
		k = l;
		for (j = 0; j < w; j++) {
			if (videoCharTransp[k] != transpchar && videoCharTransp[k] != TRANSPVAL) {
				if (bWriteCols) videoCol[k] = videoColTransp[k];
				if (bWriteChars) videoChar[k] = videoCharTransp[k];
			}
			k++;
		}
		l += XRES;
	}
}

void drawTranspTDoublePoly(uchar *videoTransp, uchar *videoTranspChar, uchar *videoCol, uchar *videoChar, int transpval, int bWriteChars, int bWriteCols,intVector vv[], int points, Bitmap *bild, int plusVal, int bPerspectiveCorrected, Bitmap *bild2) {
	int minx, maxx, miny, maxy, i, ok;
	
	video = videoTransp;
	ok = scanConvex_tmap(vv, points, NULL, bild, plusVal, bPerspectiveCorrected);
	if (!ok)
		return;
	
	getBounds(vv, points, &minx, &maxx, &miny, &maxy);
	
	video = videoTranspChar;
	fbox(minx, miny, maxx-minx, maxy-miny, transpval);
	ok = scanConvex_tmap(vv, points, NULL, bild2, 0, bPerspectiveCorrected);
	if (ok)
		processFromDoubleTranspBuffer(videoTransp, videoTranspChar, videoCol, videoChar, transpval, bWriteChars, bWriteCols, minx, miny, maxx-minx, maxy-miny);
}


void displayMessage(char *text, int x, int y, int fgcol, int bgcol, uchar *videoCol, uchar *videoChar) {
	int i;
	video = videoCol;
	line(x, y, x+strlen(text)-1, y, ((PREPCOL)bgcol << BITSHL) | fgcol, 1);
	video = videoChar;
	if (y < YRES && y >= 0) {
		for (i=0; i < strlen(text); i++) {
			if (x + i < XRES && x + i >= 0) video[y*XRES + x + i] = text[i] == '_' ? ' ' : text[i];
		}
	}
}

void displayErrors(ErrorHandler *errH, uchar *videoCol, uchar *videoChar) {
	char opNames[20][16] = { "poly", "ipoly", "gpoly", "tpoly", "image", "box", "fbox", "line", "pixel", "circle", "fcircle", "ellipse", "fellipse", "text", "3d", "block", "insert", "play" };
	char tstring[1028], *partstring;
	int i, y = 1;

	for (i = 0; i < errH->errCnt; i++) {
		switch(errH->errType[i]) {
			case ERR_NOF_ARGS: sprintf(tstring, "#ERR %d: (op %d) '%s' missing and/or malformed parameters (param %d?)", i+1, errH->index[i]+1, opNames[errH->opType[i]], errH->argNof[i] + 1); break;
			case ERR_OBJECT_LOAD: case ERR_IMAGE_LOAD: sprintf(tstring, "#ERR %d: (op %d) '%s' failed to load '%s'", i+1, errH->index[i]+1, opNames[errH->opType[i]], errH->extras[i]); break;
			case ERR_PARSE: sprintf(tstring, "#ERR %d: (op %d) '%s' failed to parse/process '%s'", i+1, errH->index[i]+1, opNames[errH->opType[i]], errH->extras[i]); break;
			case ERR_MEMORY: sprintf(tstring, "#ERR %d: (op %d) '%s' memory allocation error", i+1, errH->index[i]+1, opNames[errH->opType[i]]); break;
			case ERR_OPTYPE: sprintf(tstring, "#ERR %d: (op %d) '%s' unknown operation", i+1, errH->index[i]+1, errH->extras[i]); break;
			case ERR_EXPRESSION: sprintf(tstring, "#ERR %d: (op %d) '%s' parse error in %s", i+1, errH->index[i]+1, opNames[errH->opType[i]], errH->extras[i]); break;
			default: sprintf(tstring, "#ERR %d: (op %d) '%s' unknown error", i+1, errH->index[i]+1, opNames[errH->opType[i]]);
		}
#ifdef _RGB32
		displayMessage(tstring, 0, y, 0x00ff00, 0x008000, videoCol, videoChar);
#else
		displayMessage(tstring, 0, y, 0xa, 0x2, videoCol, videoChar);
#endif	
		y++;
		if (bPrintFullErrorString && errH->op[i]) {
			sprintf(tstring, "%s %*.*s", opNames[errH->opType[i]], 0, 1000, errH->op[i]);
			partstring = tstring;

			do {
#ifdef _RGB32
				displayMessage(partstring, 0, y, 0x0, 0x00ff00, videoCol, videoChar);
#else
				displayMessage(partstring, 0, y, 0x0, 0xa, videoCol, videoChar);
#endif	
				y++;
				if (strlen(partstring) < XRES) break;
				partstring += XRES;
			} while (1);
		}
	}
}

int gTempArgNof = 0;
void reportError(ErrorHandler *errHandler, OperationType opType, ErrorType errType, int index, char *extras, char *op) {
	int i = errHandler->errCnt;
	errHandler->errType[i] = errType;
	errHandler->opType[i] = opType;
	errHandler->index[i] = index;
	errHandler->extras[i] = NULL;
	errHandler->op[i] = NULL;
	errHandler->argNof[i] = gTempArgNof;
	if (extras) { errHandler->extras[i]=(char *)malloc((strlen(extras)+1) * sizeof(char)); if (errHandler->extras[i]) strcpy(errHandler->extras[i], extras); }
	if (op) { errHandler->op[i]=(char *)malloc((strlen(op)+1) * sizeof(char)); if (errHandler->op[i]) strcpy(errHandler->op[i], op); }
	errHandler->errCnt++;
	if (errHandler->errCnt >= MAX_ERRS) errHandler->errCnt = MAX_ERRS-1;
}

void reportFileError(ErrorHandler *errHandler, OperationType opType, ErrorType errType, int index, char *extras, char *op) {
	FILE *ifp;
	if (extras) {
		ifp = fopen(extras, "r");
		if (ifp) { errType = ERR_PARSE; fclose(ifp); }
	}
	reportError(errHandler, opType, errType, index, extras, op);
}
	
void reportArgError(ErrorHandler *errHandler, OperationType opType, int index, char *op, int argNof) {
	gTempArgNof = argNof;
	reportError(errHandler, opType, ERR_NOF_ARGS, index, NULL, op);
}

double my_random(void) {
	static int setSeed = 1;
	if (setSeed) { setSeed = 0; srand(GetTickCount()); }
	return (double)(rand() % 32768) / 32768.0;
}

double my_eq(double n, double comp) {
	return (double)(n == comp);
}

double my_neq(double n, double comp) {
	return (double)(n != comp);
}

double my_gtr(double n, double comp) {
	return (double)(n > comp);
}

double my_lss(double n, double comp) {
	return (double)(n < comp);
}

static uchar *activeChars;
static uchar *activeCols;
static int sw, sh;
static double store[5];

double my_char(double x, double y) {
	if (x < 0 || y < 0 || x >= sw || y >= sh)
		return 0;
	return activeChars[(int)y * sw + (int)x];
}

double my_col(double x, double y) {
	if (x < 0 || y < 0 || x >= sw || y >= sh)
		return 0;
	return activeCols[(int)y * sw + (int)x];
}

double my_fgcol(double x, double y) {
	if (x < 0 || y < 0 || x >= sw || y >= sh)
		return 0;
	return (activeCols[(int)y * sw + (int)x]) & AND_MASK;
}

double my_bgcol(double x, double y) {
	if (x < 0 || y < 0 || x >= sw || y >= sh)
		return 0;
	return (activeCols[(int)y * sw + (int)x]) >> BITSHL;
}

double my_store(double val, double index) {
	int i = (int)index;
	if (i >= 0 && i < 5)
		store[i] = val;
	return 0;
}

double my_or(double v1, double v2) {
	return ((int)v1) | ((int)v2);
}
double my_and(double v1, double v2) {
	return ((int)v1) & ((int)v2);
}
double my_xor(double v1, double v2) {
	return ((int)v1) ^ ((int)v2);
}
double my_neg(double v1) {
	return ~((int)v1);
}
double my_shl(double v1, double v2) {
	return ((int)v1) << ((int)v2);
}
double my_shr(double v1, double v2) {
	return ((int)v1) >> ((int)v2);
}

double my_min(double in1, double in2) {
	return in1 < in2? in1 : in2;
}
double my_max(double in1, double in2) {
	return in1 > in2? in1 : in2;
}

#ifdef _RGB32
double my_shade(double inColor, double or, double og, double ob) {
	long long inCol=inColor, rp=or, gp=og, bp=ob, r,g,b;
	inCol &= 0xffffff;
	
	b = (inCol & 0xff) + bp;
	g = ((inCol>>8) & 0xff) + gp;
	r = ((inCol>>16) & 0xff) + rp;
	if (b>255) b=255; if (b<0) b=0;
	if (g>255) g=255; if (g<0) g=0;
	if (r>255) r=255;  if (r<0) r=0;
	return b | (g<<8) | (r<<16); // | (col & 0xffffff00000000);
}

double my_blend(double inColor, double a, double or, double og, double ob) {
	long long inCol=inColor, av=a, rv=or, gv=og, bv=ob, r,g,b;
	int blNew, blOrg;
	inCol &= 0xffffff;
	
	 blNew=av & 0xff; blOrg=255-blNew;
	 b=((((inCol & 0xff) * blOrg / 256) + ((bv & 0xff) * blNew / 256)));
	 g=(((((inCol>>8) & 0xff) * blOrg / 256) + ((gv & 0xff) * blNew / 256)));
	 r=(((((inCol>>16) & 0xff) * blOrg / 256) + ((rv & 0xff) * blNew / 256)));
	 return b | (g<<8) | (r<<16); // | (col & 0xffffff00000000);
}

double my_fgr(double inColor) {
	long long inCol=inColor;
	return (inCol>>16) & 0xff;
}
double my_fgg(double inColor) {
	long long inCol=inColor;
	return (inCol>>8) & 0xff;
}
double my_fgb(double inColor) {
	long long inCol=inColor;
	return inCol & 0xff;
}

double my_makecol(double or, double og, double ob) {
	long long r=or, g=og, b=ob;
	return (b&0xff) | ((g&0xff)<<8) | ((r&0xff)<<16); // | (col & 0xffffff00000000);
}

#endif


int transformBlock(char *s_mode, int x, int y, int w, int h, int nx, int ny, int nw, int nh, int rz, char *transf, char *colorExpr, char *xExpr, char *yExpr, int XRES, int YRES, uchar *videoCol, uchar *videoChar, int transpchar, int bFlipX, int bFlipY, int bTo, int mvx,int mvy, int mvw, int mvh) {
	uchar *blockCol, *blockChar;
	int i,j,k,k2,i2,j2, mode = 0, moveChar = 32, nofT = 0, n;
	uchar moveFg = 7, moveBg = 0, moveCol=7;
	int inFg, inBg, inChar, compVal;
	int outFg, outBg, outChar;
	int *m_inFg = NULL, *m_inBg = NULL, *m_inChar = NULL;
	int *m_outFg = NULL, *m_outBg = NULL, *m_outChar = NULL;
#ifdef _RGB32
	uchar vc, bc;
	int bBlend=0, blendVal = -1, blendValBg = -1;
	int blNew, blOrg, bl2New, bl2Org;
	int _r,_g,_b;
	long long _r2,_g2,_b2;
#endif
	
	for (i=0; i < 5; i++) store[i] = 0;
	
	if (s_mode) {
		char *smp;
		i = 0;
		if (s_mode[i]=='1' || s_mode[i]=='3') {
			mode = s_mode[i]=='1'? 1 : 3; i+=2;

			if (s_mode[i-1] != 0 && s_mode[i] != 0) {
				moveFg = GetHex(s_mode[i]); i++;
				if (s_mode[i] != 0) {
					moveBg = GetHex(s_mode[i]); i++;
					if (s_mode[i] != 0 && s_mode[i+1] != 0) {
						sscanf(&s_mode[i], "%x", &moveChar);
					}
#ifndef _RGB32
					moveCol = (moveBg << 4) | moveFg;
#else
					moveCol = (((PREPCOL)g_rgbBgPalette[moveBg]) << BITSHL) | g_rgbFgPalette[moveFg];
#endif	
				}
			}
		} else if (s_mode[i]=='2')
			mode = 2;
		
#ifdef _RGB32
		smp = strchr(s_mode, ',');
		if (smp && smp[1] != 0) {
			int nf = sscanf(&smp[1], "%d", &blendVal);
			if (nf > 0) {
				if (blendVal < 0) blendVal = -1;
				if (blendVal > 255) blendVal = 255;
				bBlend=1;
				//printf("%d\n", blendVal); getch();
			}
			blendValBg = blendVal;
			if (blendVal != -1) {
				smp++;
				smp = strchr(smp, ',');
				if (smp && smp[1] != 0) {
					int nf = sscanf(&smp[1], "%d", &blendValBg);
					if (nf > 0) {
						if (blendValBg < 0) blendValBg = -1;
						if (blendValBg > 255) blendValBg = 255;
						bBlend=2;
						//printf("%d\n", blendValBg); getch();
					} else
						blendValBg = blendVal;
				}
			}
		}
#endif
	}

	sw = w, sh = h;
		
	if (x >= XRES || nx >= XRES) return 0;
	if (y >= YRES || ny >= YRES) return 0;

	if (rz != 90 && rz != 270 && (nw <= 0 || nh <= 0)) {
		if (x+w < 0 || nx+w < 0) return 0;
		if (y+h < 0 || ny+h < 0) return 0;
		if (x < 0) { w+=x; x=0; }
		if (y < 0) { h+=y; y=0; }
		if (h < 0 || w < 0) return 0;
		if (x+w >= XRES) { w-=(x+w)-XRES; }
		if (y+h >= YRES) { h-=(y+h)-YRES; }
		if (h < 0 || w < 0) return 0;
	}
	
	blockCol = (uchar *)malloc(w*h*sizeof(uchar));
	blockChar = (uchar *)malloc(w*h*sizeof(uchar));
	if (!blockCol || !blockChar) { if (blockCol) free(blockCol); if (blockChar) free(blockChar); return 0; }

	if (strlen(transf) >= 9) {
		nofT = (strlen(transf)+1)/10;
		if (nofT > 0) {
			m_inFg = (int *)malloc(nofT*sizeof(int));
			m_inBg = (int *)malloc(nofT*sizeof(int));
			m_inChar = (int *)malloc(nofT*sizeof(int));
			m_outFg = (int *)malloc(nofT*sizeof(int));
			m_outBg = (int *)malloc(nofT*sizeof(int));
			m_outChar = (int *)malloc(nofT*sizeof(int));
			if (!m_inFg || !m_inBg || !m_inChar || !m_outFg || !m_outBg || !m_outChar) {
				if (m_inFg) free(m_inFg); if (m_inBg) free(m_inBg); if (m_inChar) free(m_inChar);
				if (m_outFg) free(m_outFg); if (m_outBg) free(m_outBg); if (m_outChar) free(m_outChar);
				nofT = 0;
			} else {
				for (i = 0; i < nofT; i++) {
					m_inFg[i] = GetHex(transf[i*10]); if (transf[i*10] == '?') m_inFg[i] = -1;
					m_inBg[i] = GetHex(transf[i*10+1]); if (transf[i*10+1] == '?') m_inBg[i] = -1;
					m_inChar[i] = (GetHex(transf[i*10+2]) << 4) | GetHex(transf[i*10+3]); if (transf[i*10+2] == '?' || transf[i*10+3] == '?') m_inChar[i] = -1;
					m_outFg[i] = GetHex(transf[i*10+5]); if (transf[i*10+5] == '?') m_outFg[i] = -1; if (transf[i*10+5] == '-') m_outFg[i]= -2; if (transf[i*10+5] == '+') m_outFg[i]= -3;
					m_outBg[i] = GetHex(transf[i*10+6]); if (transf[i*10+6] == '?') m_outBg[i] = -1; if (transf[i*10+6] == '-') m_outBg[i]= -2; if (transf[i*10+6] == '+') m_outBg[i]= -3;
					m_outChar[i] = (GetHex(transf[i*10+7]) << 4) | GetHex(transf[i*10+8]); if (transf[i*10+7] == '?' || transf[i*10+8] == '?') m_outChar[i] = -1; if (transf[i*10+7] == '-' || transf[i*10+8] == '-') m_outChar[i] = -2; if (transf[i*10+7] == '+' || transf[i*10+8] == '+') m_outChar[i] = -3;
				}
			}
		}
	}
		
	for (i = 0; i < h; i++) {
		k = i*w; k2=y*XRES+i*XRES+x;
		for (j = 0; j < w; j++) {
			blockCol[k+j] = videoCol[k2+j];
			blockChar[k+j] = videoChar[k2+j];
		}
	}

	if (mode == 1 || mode == 3) {
		video = videoCol;
		fbox(x, y, w-1, h-1, moveCol);
		video = videoChar;
		fbox(x, y, w-1, h-1, moveChar);
	}

	if (mvx < 0 || mvy < 0 || mvw < 0 || mvh < 0) { mvx=mvy=0; mvw=w; mvh=h; }
	mvw += mvx;
	mvh += mvy;
	if (mvh > h) mvh=h;
	if (mvw > w) mvw=w;
			
	
	if (strlen(colorExpr) > 1) {
		int err, r;
		double ex, ey;
		uchar *blockCol2, *blockChar2;
	 
		activeChars = blockChar;
		activeCols = blockCol;
			
		te_variable vars[] = {{"x", &ex}, {"y", &ey}, {"random", my_random, TE_FUNCTION0}
		, {"eq", my_eq, TE_FUNCTION2},  {"neq", my_neq, TE_FUNCTION2}, {"gtr", my_gtr, TE_FUNCTION2}, {"lss", my_lss, TE_FUNCTION2}
		, {"char", my_char, TE_FUNCTION2},  {"col", my_col, TE_FUNCTION2}, {"fgcol", my_fgcol, TE_FUNCTION2}, {"bgcol", my_bgcol, TE_FUNCTION2}
		, {"store", my_store, TE_FUNCTION2}, {"s0", &store[0]}, {"s1", &store[1]}, {"s2", &store[2]}, {"s3", &store[3]}, {"s4", &store[4]}
		, {"or", my_or, TE_FUNCTION2},  {"and", my_and, TE_FUNCTION2}, {"xor", my_xor, TE_FUNCTION2}, {"neg", my_neq, TE_FUNCTION1}
#ifndef _RGB32
		, {"shl", my_shl, TE_FUNCTION2},  {"shr", my_shr, TE_FUNCTION2}, {"max", my_max, TE_FUNCTION2},  {"min", my_min, TE_FUNCTION2}
		};
		te_expr *n = te_compile(colorExpr, vars, 25, &err);
#else
		, {"shl", my_shl, TE_FUNCTION2},  {"shr", my_shr, TE_FUNCTION2},  {"shade", my_shade, TE_FUNCTION4},  {"blend", my_blend, TE_FUNCTION5}
		, {"makecol", my_makecol, TE_FUNCTION3},  {"fgr", my_fgr, TE_FUNCTION1},  {"fgg", my_fgg, TE_FUNCTION1},  {"fgb", my_fgb, TE_FUNCTION1}
		, {"max", my_max, TE_FUNCTION2},  {"min", my_min, TE_FUNCTION2}
		};
		te_expr *n = te_compile(colorExpr, vars, 31, &err);
#endif
		
		if (n) {
			blockCol2 = (uchar *)malloc(w*h*sizeof(uchar));
			blockChar2 = (uchar *)malloc(w*h*sizeof(uchar));
			activeChars = blockChar2;
			activeCols = blockCol2;

			if (!blockCol2 || !blockChar2) { if (blockCol2) free(blockCol2); if (blockChar2) free(blockChar2); free(blockChar); free(blockCol); te_free(n); return 0; }
			MYMEMCPY(blockCol2, blockCol, w*h);
			MYMEMCPY(blockChar2, blockChar, w*h);
			
			for (i = mvy; i < mvh; i++) {
				k = i*w;
				for (j = mvx; j < mvw; j++) {
					ex = j; ey = i;
					r = (int) te_eval(n);
					// printf("Result:\n\t%f\n", r);
					blockCol[k+j] = r;
				}
			}
			te_free(n);
			free(blockChar2); free(blockCol2);
		} else {
			char errS[64];
			sprintf(errS, "colorExpr near character %d", err);
			reportError(g_errH, OP_BLOCK, ERR_EXPRESSION, g_opCount, errS, NULL);
		}
	}

	if (strlen(xExpr) > 1 || strlen(yExpr) > 1) {
		int err, errX, nx, ny;
		double ex, ey;
		uchar *blockCol2, *blockChar2;
		
		te_variable vars[] = {{"x", &ex}, {"y", &ey}, {"random", my_random, TE_FUNCTION0}
		, {"eq", my_eq, TE_FUNCTION2},  {"neq", my_neq, TE_FUNCTION2}, {"gtr", my_gtr, TE_FUNCTION2}, {"lss", my_lss, TE_FUNCTION2}
		, {"char", my_char, TE_FUNCTION2},  {"col", my_col, TE_FUNCTION2}, {"fgcol", my_fgcol, TE_FUNCTION2}, {"bgcol", my_bgcol, TE_FUNCTION2}
		, {"store", my_store, TE_FUNCTION2}, {"s0", &store[0]}, {"s1", &store[1]}, {"s2", &store[2]}, {"s3", &store[3]}, {"s4", &store[4]}
		, {"or", my_or, TE_FUNCTION2},  {"and", my_and, TE_FUNCTION2}, {"xor", my_xor, TE_FUNCTION2}, {"neg", my_neq, TE_FUNCTION1}
		, {"shl", my_shl, TE_FUNCTION2},  {"shr", my_shr, TE_FUNCTION2}, {"max", my_max, TE_FUNCTION2},  {"min", my_min, TE_FUNCTION2}
		};
		te_expr *n, *n2;
		n = te_compile(xExpr, vars, 25, &err); errX = err;
		n2 = te_compile(yExpr, vars, 25, &err);
		
		if (n && n2) {
			blockCol2 = (uchar *)malloc(w*h*sizeof(uchar));
			blockChar2 = (uchar *)malloc(w*h*sizeof(uchar));
			activeChars = blockChar2;
			activeCols = blockCol2;

			if (!blockCol2 || !blockChar2) { if (blockCol2) free(blockCol2); if (blockChar2) free(blockChar2); free(blockChar); free(blockCol); te_free(n); te_free(n2); return 0; }
			MYMEMCPY(blockCol2, blockCol, w*h);
			MYMEMCPY(blockChar2, blockChar, w*h);
			if (mode == 1 || mode == 3) {
				MYMEMSET(blockCol, moveCol, w*h);
				MYMEMSET(blockChar, moveChar, w*h);
			}
			
			for (i = mvy; i < mvh; i++) {
				k = i*w;
				for (j = mvx; j < mvw; j++) {
					ex = j; ey = i;
					nx = (int) te_eval(n);
					ny = (int) te_eval(n2);
					// printf("Result:\n\t%f\n", r);
//					if (nx >= 0 && nx < w && ny >=0 && ny < h && blockChar2[k+j] != 0) {
					if (nx >= 0 && nx < w && ny >=0 && ny < h) {
						if (bTo) {
							blockCol[ny*w+nx] = blockCol2[k+j];
							blockChar[ny*w+nx] = blockChar2[k+j];
						} else {
							blockCol[k+j] = blockCol2[ny*w+nx];
							blockChar[k+j] = blockChar2[ny*w+nx]; 
						}
					}
				}
			}
			free(blockChar2); free(blockCol2);

		} else {
			char errS[64];
			if (!n) {
				sprintf(errS, "xExpr near character %d", errX);
				reportError(g_errH, OP_BLOCK, ERR_EXPRESSION, g_opCount, errS, NULL);
			}
			if (!n2) {
				sprintf(errS, "yExpr near character %d", err);
				reportError(g_errH, OP_BLOCK, ERR_EXPRESSION, g_opCount, errS, NULL);
			}
		}

		if (n) te_free(n);
		if (n2) te_free(n2);
	}

	//if ((nw > 0 && nh > 0 && (nw != w || nh != h)) || (nw > 0 && nw != w)) {
	if (nw > 0 && nh > 0 && (nw != w || nh != h)) {
		uchar *blockCol2, *blockChar2;
		float dx, dy, ax=0, ay=0;
		int ry, dry;
		
		/*
		if (nh <= 0) {
			float change = (float)nw / (float)w;
			nh = (int)((float)h * change);
		}*/
		
		blockCol2 = (uchar *)malloc(nw*nh*sizeof(uchar));
		blockChar2 = (uchar *)malloc(nw*nh*sizeof(uchar));

		dx = (float)w / (float)nw;
		dy = (float)h / (float)nh;
		
		for (i=0; i < nh; i++) {
			ry = i*nw;
			dry = ((int)ay) * w;
			ax = 0;
			for (j=0; j < nw; j++) {
				blockChar2[ry+j] = blockChar[dry + (int)ax];
				blockCol2[ry+j] = blockCol[dry + (int)ax];
				ax = ax + dx;
			}
			ay = ay + dy;
		}
		
		w=nw, h=nh;
		free(blockChar); free(blockCol);
		blockChar = blockChar2;
		blockCol = blockCol2;
	}
	
	if (rz == 90 || rz == 180 || rz == 270) {
		uchar *blockCol2, *blockChar2;
		int rw = w, rh=h, oy;
		int rsy, rdy, rsx, rdx;
		int rx, ry;
		
		if (rz != 180) rw = h, rh = w;
		
		blockCol2 = (uchar *)malloc(rw*rh*sizeof(uchar));
		blockChar2 = (uchar *)malloc(rw*rh*sizeof(uchar));

		if(rz==180) { rsy=w*(h-1), rdy=-w, rsx=w-1, rdx=-1; }
		else if(rz==90) { rsy=h-1, rdy=-1, rsx=0, rdx=h; }
		else if(rz==270) { rsy=0, rdy=1, rsx=h*(w-1), rdx=-h; }
		
		ry = rsy;
		for (i=0; i<h; i++) {
			oy = w*i;
			rx = rsx;
			for (j=0; j<w; j++) {
				blockChar2[ry+rx] = blockChar[oy + j];
				blockCol2[ry+rx] = blockCol[oy + j];
				rx += rdx;
			}
			ry += rdy;
		}
	
		w=rw, h=rh;
		free(blockChar); free(blockCol);
		blockChar = blockChar2;
		blockCol = blockCol2;
	}
	
	if (nofT < 1) {
		for (i = 0; i < h; i++) {
			i2 = i; if (bFlipY) i2 = h-1-i;
			k = i2*w; k2=ny*XRES+i*XRES+nx;
			if (ny+i >= 0 && ny+i < YRES) {
				if (mode < 2) {
					for (j = 0; j < w; j++) {
						j2 = j; if (bFlipX) j2 = w-1-j;
						if (nx+j >= 0 && nx+j < XRES && blockChar[k+j2] != transpchar) {
#ifndef _RGB32 
							videoCol[k2+j] = blockCol[k+j2];
#else
							if (!bBlend)
								videoCol[k2+j] = blockCol[k+j2];
							else {
								vc = videoCol[k2+j]; bc = blockCol[k+j2];
								blNew=blendVal; blOrg=255-blNew;
								_b=((((vc & 0xff) * blOrg / 256) + ((bc & 0xff) * blNew / 256))); _g=(((((vc>>8) & 0xff) * blOrg / 256) + (((bc>>8) & 0xff) * blNew / 256))); _r=(((((vc>>16) & 0xff) * blOrg / 256) + (((bc>>16) & 0xff) * blNew / 256)));
								if (bBlend ==2) {
									bl2New=blendValBg; bl2Org=255-bl2New;
									_b2=(((((vc>>32) & 0xff) * bl2Org / 256) + (((bc>>32) & 0xff) * bl2New / 256))); _g2=(((((vc>>40) & 0xff) * bl2Org / 256) + (((bc>>40) & 0xff) * bl2New / 256))); _r2=(((((vc>>48) & 0xff) * bl2Org / 256) + (((bc>>48) & 0xff) * bl2New / 256)));
									videoCol[k2+j] = _b | (_g<<8) | (_r<<16) | (_b2<<32)  | (_g2<<40)  | (_r2<<48);
								} else
									videoCol[k2+j] = _b | (_g<<8) | (_r<<16) | (vc & 0xffffff00000000);
							}
#endif
							videoChar[k2+j] = blockChar[k+j2];
						}
					}
				} else {
					for (j = 0; j < w; j++) {
						j2 = j; if (bFlipX) j2 = w-1-j;
						if (nx+j >= 0 && nx+j < XRES && (blockCol[k+j2] & AND_MASK) != transpchar) {
#ifndef _RGB32 
							videoCol[k2+j] = blockCol[k+j2];
#else
							if (!bBlend)
								videoCol[k2+j] = blockCol[k+j2];
							else {
								vc = videoCol[k2+j]; bc = blockCol[k+j2];
								blNew=blendVal; blOrg=255-blNew;
								_b=((((vc & 0xff) * blOrg / 256) + ((bc & 0xff) * blNew / 256))); _g=(((((vc>>8) & 0xff) * blOrg / 256) + (((bc>>8) & 0xff) * blNew / 256))); _r=(((((vc>>16) & 0xff) * blOrg / 256) + (((bc>>16) & 0xff) * blNew / 256)));
								if (bBlend ==2) {
									bl2New=blendValBg; bl2Org=255-bl2New;
									_b2=(((((vc>>32) & 0xff) * bl2Org / 256) + (((bc>>32) & 0xff) * bl2New / 256))); _g2=(((((vc>>40) & 0xff) * bl2Org / 256) + (((bc>>40) & 0xff) * bl2New / 256))); _r2=(((((vc>>48) & 0xff) * bl2Org / 256) + (((bc>>48) & 0xff) * bl2New / 256)));
									videoCol[k2+j] = _b | (_g<<8) | (_r<<16) | (_b2<<32)  | (_g2<<40)  | (_r2<<48);
								} else
									videoCol[k2+j] = _b | (_g<<8) | (_r<<16) | (vc & 0xffffff00000000);
							}
#endif
							videoChar[k2+j] = blockChar[k+j2];
						}
					}
				}
			}
		}
	} else {

		for (i = 0; i < h; i++) {
			i2 = i; if (bFlipY) i2 = h-1-i;
			k = i2*w; k2=ny*XRES+i*XRES+nx;
			if (ny+i >= 0 && ny+i < YRES) {
				for (j = 0; j < w; j++) {
					j2 = j; if (bFlipX) j2 = w-1-j;
					if (nx+j >= 0 && nx+j < XRES) {
						inFg = blockCol[k+j2]; inBg = outBg = inFg>>4; inFg &= AND_MASK; outFg = inFg;
						inChar = outChar = blockChar[k+j2];

						for (n = 0; n < nofT; n++) {
							if ((inFg == m_inFg[n] || m_inFg[n] == -1) && (inBg == m_inBg[n] || m_inBg[n] == -1) && (inChar == m_inChar[n] || m_inChar[n] == -1)) {
								if (m_outFg[n] != -1) outFg = m_outFg[n]; if (m_outFg[n] == -2) { outFg = inFg-1; if (outFg < 0) outFg = 0; } if (m_outFg[n] == -3) { outFg = inFg+1; if (outFg > 15) outFg = 15; }
								if (m_outBg[n] != -1) outBg = m_outBg[n]; if (m_outBg[n] == -2) { outBg = inBg-1; if (outBg < 0) outBg = 0; } if (m_outBg[n] == -3) { outBg = inBg+1; if (outBg > 15) outBg = 15; }
								if (m_outChar[n] != -1) outChar = m_outChar[n]; if (m_outChar[n] == -2) { outChar = inChar-1; if (outChar < 0) outChar = 0; } if (m_outChar[n] == -3) { outChar = inChar+1; if (outChar > 255) outChar = 255; }
								break;
							}
						}

						compVal = inChar; if (mode > 1) compVal = inFg;
						if (compVal != transpchar) {

#ifndef _RGB32 
							videoCol[k2+j] = (outBg << 4) | outFg;
#else
							if (!bBlend)
								videoCol[k2+j] = (outBg << 4) | outFg;
							else {
								vc = videoCol[k2+j]; bc = blockCol[k+j2];
								blNew=blendVal; blOrg=255-blNew;
								_b=((((vc & 0xff) * blOrg / 256) + ((bc & 0xff) * blNew / 256))); _g=(((((vc>>8) & 0xff) * blOrg / 256) + (((bc>>8) & 0xff) * blNew / 256))); _r=(((((vc>>16) & 0xff) * blOrg / 256) + (((bc>>16) & 0xff) * blNew / 256)));
								if (bBlend ==2) {
									bl2New=blendValBg; bl2Org=255-bl2New;
									_b2=(((((vc>>32) & 0xff) * bl2Org / 256) + (((bc>>32) & 0xff) * bl2New / 256))); _g2=(((((vc>>40) & 0xff) * bl2Org / 256) + (((bc>>40) & 0xff) * bl2New / 256))); _r2=(((((vc>>48) & 0xff) * bl2Org / 256) + (((bc>>48) & 0xff) * bl2New / 256)));
									videoCol[k2+j] = _b | (_g<<8) | (_r<<16) | (_b2<<32)  | (_g2<<40)  | (_r2<<48);
								} else
									videoCol[k2+j] = _b | (_g<<8) | (_r<<16) | (vc & 0xffffff00000000);
							}
#endif
							
							videoChar[k2+j] = outChar;
						}
					}
				}
			}
		}
	}
	
	free(blockCol); free(blockChar);
	if (m_inFg) free(m_inFg); if (m_inBg) free(m_inBg); if (m_inChar) free(m_inChar);
	if (m_outFg) free(m_outFg); if (m_outBg) free(m_outBg); if (m_outChar) free(m_outChar);
	
	return 1;
}

void writeErrorLevelToFile(int bWriteReturnToFile, int value, int bMouse) {
	FILE *ofp;
	
	if (!bWriteReturnToFile)
		return;
	
	if (bWriteReturnToFile == 2) {
		if (!bMouse && value == 0)
			return;
		if (bMouse && value < 0)
			return;

		if (g_bFlushAfterELwrite)
			fflush(stdin);
	}
	
	ofp = fopen("EL.dat", "w"); // "a+" ?
	if (ofp != NULL) {
		fprintf(ofp, "%d\n", value);
		fclose(ofp);
	}	
}


/* Windows ns high-precision sleep */
BOOLEAN nanosleep(LONGLONG ns){
    HANDLE timer;
    LARGE_INTEGER li;

    if(!(timer = CreateWaitableTimer(NULL, TRUE, NULL)))
        return FALSE;
    li.QuadPart = -ns;
    if(!SetWaitableTimer(timer, &li, 0, NULL, NULL, FALSE)){
        CloseHandle(timer);
        return FALSE;
    }
    WaitForSingleObject(timer, INFINITE);
    CloseHandle(timer);
    return TRUE;
}

BOOLEAN millisleep(LONGLONG ms){
	return nanosleep(ms * 10000);
}

long long milliseconds_now(void) {
	static LARGE_INTEGER s_frequency;
	static BOOL s_use_qpc;

	s_use_qpc = QueryPerformanceFrequency(&s_frequency);
	if (s_use_qpc) {
		LARGE_INTEGER now;
		QueryPerformanceCounter(&now);
		return (1000LL * now.QuadPart) / s_frequency.QuadPart;
	} else {
		return GetTickCount();
	}
}

void process_waiting(int bWait, int waitTime, int bServer) { 
	static long long lastTime = -1;

	if (bWait==1 && waitTime > 0) {
		long long sT = milliseconds_now();
		if (g_bSleepingWait)
			millisleep(waitTime);
		else
			while (milliseconds_now() < sT + waitTime) ;
	}
	
	if (bWait==2 && waitTime > 0) {
		long long sT;
		
		if (!bServer) {
			FILE *fp = fopen("CGXMS.dat", "r");

			if (fp != NULL) {
				fscanf(fp, "%lld", &sT);
				fclose(fp);
				if (milliseconds_now() >= sT) {
					if (g_bSleepingWait) {
						int sleepTime = sT + waitTime - milliseconds_now();
						if (sleepTime > 0)
							millisleep(sleepTime);
					} else
						while (milliseconds_now() < sT + waitTime) ;
				}
			}
			
			fp = fopen("CGXMS.dat", "w");
			if (fp != NULL) {
				fprintf(fp, "%lld", milliseconds_now());
				fclose(fp);
			}
		} else {
				if (lastTime >= 0) {
					if (milliseconds_now() >= lastTime) {
					if (g_bSleepingWait) {
						int sleepTime = lastTime + waitTime - milliseconds_now();
						if (sleepTime > 0)
							millisleep(sleepTime);
					} else
						while (milliseconds_now() < lastTime + waitTime) ;
					}
				}
				lastTime = milliseconds_now();
		}
	}
}
	

char DecToHex(int i) {
	switch(i) {
	case 0:case 1:case 2:case 3:case 4:case 5:case 6:case 7:case 8:case 9: i=i+'0'; break;
	case 10:case 11:case 12:case 13:case 14:case 15: i = 'A'+(i-10); break;
	default: i = '0';
	}
	return i;
}


char *GetAttribs(WORD attributes, char *utp) {
	int i;
	utp[0] = '\\';
	utp[1] = DecToHex(attributes & 0xf);
	utp[2] = DecToHex((attributes >> 4) & 0xf);
	utp[3] = 0;
	return utp;
}

#ifndef _RGB32

int SaveBlock(int indexNr, int x, int y, int w, int h, int bEncode) {
	WORD oldAttrib = 6666;
	FILE *ofp = NULL;
	uchar ch;
	char fName[128];
	int i, j;
	char *output, attribS[16], charS[8];

	output = (char*) malloc(10 * w*h);
	if (!output) return 3;
	output[0] = 0;
	
	if (bEncode == 0)
		sprintf(fName, "capture-%d.txt", indexNr);
	else
		sprintf(fName, "capture-%d.gxy", indexNr);
	ofp = fopen(fName, "w");
	if (!ofp) return 1;
	
	for (j=0; j < h; j++) {
		output[0]=0;
		for (i=0; i < w; i++) {
			ch = g_videoChar[x + i + j*XRES + y*XRES];
			if (bEncode == 0) {
				charS[0] = ch == 0? 32 : ch; charS[1]=0;
			}
			else if (!(ch ==32 || (ch >='0' && ch <='9') || (ch >='A' && ch <='Z') || (ch >='a' && ch <='z'))) {
				int v;
				charS[0] = '\\'; charS[1] = 'g';
				v = ch / 16; charS[2]=DecToHex(v);
				v = ch % 16; charS[3]=DecToHex(v);
				charS[4]=0;
			} else {
				charS[0] = ch; charS[1]=0;
			}
			if (oldAttrib == g_videoCol[x + i + j*XRES + y*XRES] || bEncode == 0)
				sprintf(output, "%s%s", output, charS);
			else
				sprintf(output, "%s%s%s", output, GetAttribs(g_videoCol[x + i + j*XRES + y*XRES], attribS), charS);
			oldAttrib = g_videoCol[x + i + j*XRES + y*XRES];
		}
		if (bEncode == 0) fprintf(ofp, "%s\n", output); else fprintf(ofp, "%s\\n", output);
	}

	free(output);

	fclose(ofp);
	return 0;
}
#else

int SaveBlock(int indexNr, int x, int y, int w, int h, int bEncode) {
	char fName[128];
	FILE *ofp = NULL;
	unsigned char ch;
	char *output, charS[8];
	int i, j;

	output = (char*) malloc(2 * w*h);
	if (!output) return 3;
	output[0] = 0;
	
	if (bEncode == 0)
		sprintf(fName, "capture-%d.txt", indexNr);
	else if (bEncode == 2)
		sprintf(fName, "capture-%d.bmp", indexNr);
	else if (bEncode == 3)
		sprintf(fName, "capture-%d.gxy", indexNr);
	else
		sprintf(fName, "capture-%d.bxy", indexNr);
	
	if (bEncode == 0) {
		ofp = fopen(fName, "w");
		if (!ofp) return 1;

		for (j=0; j < h; j++) {
			output[0]=0;
			for (i=0; i < w; i++) {
				ch = g_videoChar[x + i + j*XRES + y*XRES];
				charS[0] = ch == 0? 32 : ch; charS[1]=0;
				sprintf(output, "%s%s", output, charS);
			}
			fprintf(ofp, "%s\n", output);
		}
		fclose(ofp);
	} else if (bEncode == 2) {
		uchar *cBlock = (uchar *)malloc(w*h*sizeof(uchar));
		
		for (j=0; j < h; j++) {
			for (i=0; i < w; i++) {
				cBlock[i + j*w] = g_videoCol[x + i + j*XRES + y*XRES];
			}
		}
		BMPsave(cBlock, fName, w, h);
		free(cBlock);
	} else if (bEncode == 3) {
		char *output, attribS[16], charS[8];
		WORD oldAttrib = 6666;

		output = (char*) malloc(10 * w*h);
		if (!output) return 3;
		output[0] = 0;
		
		ofp = fopen(fName, "w");
		if (!ofp) return 1;
		
		for (j=0; j < h; j++) {
			output[0]=0;
			for (i=0; i < w; i++) {
				ch = g_videoChar[x + i + j*XRES + y*XRES];
				if (!(ch ==32 || (ch >='0' && ch <='9') || (ch >='A' && ch <='Z') || (ch >='a' && ch <='z'))) {
					int v;
					charS[0] = '\\'; charS[1] = 'g';
					v = ch / 16; charS[2]=DecToHex(v);
					v = ch % 16; charS[3]=DecToHex(v);
					charS[4]=0;
				} else {
					charS[0] = ch; charS[1]=0;
				}
				if (oldAttrib == g_videoCol[x + i + j*XRES + y*XRES])
					sprintf(output, "%s%s", output, charS);
				else
					sprintf(output, "%s%s%s", output, GetAttribs(g_videoCol[x + i + j*XRES + y*XRES], attribS), charS);
				oldAttrib = g_videoCol[x + i + j*XRES + y*XRES];
			}
			fprintf(ofp, "%s\\n", output);
		}

		free(output);
		fclose(ofp);		
		
	}  else {
		unsigned char *chBlock = (unsigned char *)malloc(w*h*sizeof(unsigned char));
		uchar *cBlock = (uchar *)malloc(w*h*sizeof(uchar));
		for (j=0; j < h; j++) {
			for (i=0; i < w; i++) {
				cBlock[i + j*w] = g_videoCol[x + i + j*XRES + y*XRES];
				chBlock[i + j*w] = g_videoChar[x + i + j*XRES + y*XRES];
			}
		}
		BXYsave(chBlock, cBlock, fName, w, h);
		free(chBlock);
		free(cBlock);
	}


	free(output);
	return 0;
}
	
	
#endif
	
	
#ifdef GDI_OUTPUT
void readPalette(char *argv3, char *argv4, unsigned int *fgPalette, unsigned int *bgPalette, int *bPaletteSet) {	
	if (argv3) {
		int nofc, gr,gg,gb,i;
		nofc = (strlen(argv3)+1) / 7;
		if (nofc > 16) nofc = 16;
		for (i = 0; i < nofc; i++) {
			gr = (GetHex(argv3[i*7]) << 4) | GetHex(argv3[i*7+1]);
			gg = (GetHex(argv3[i*7+2]) << 4) | GetHex(argv3[i*7+3]);
			gb = (GetHex(argv3[i*7+4]) << 4) | GetHex(argv3[i*7+5]);
			fgPalette[i] = (0xff << 24) | (gr << 16) | (gg << 8) | (gb);
			if (!argv4) bgPalette[i] = fgPalette[i];
		}
	}

	if (argv4) {
		int nofc, gr,gg,gb,i;
		nofc = (strlen(argv4)+1) / 7;
		if (nofc > 16) nofc = 16;
		for (i = 0; i < nofc; i++) {
			gr = (GetHex(argv4[i*7]) << 4) | GetHex(argv4[i*7+1]);
			gg = (GetHex(argv4[i*7+2]) << 4) | GetHex(argv4[i*7+3]);
			gb = (GetHex(argv4[i*7+4]) << 4) | GetHex(argv4[i*7+5]);
			bgPalette[i] = (0xff << 24) | (gr << 16) | (gg << 8) | (gb); 
		}
	}
}
#else

#ifndef _RGB32
	
void readPalette(char *argv3, char *argv4, uchar *fgPalette, uchar *bgPalette, int *bPaletteSet) {	
	if (argv3) {
		int i, nofc = strlen(argv3);
		if (nofc > 16) nofc = 16;
		for (i = 0; i < nofc; i++)
			fgPalette[i] = GetHex(argv3[i]); bgPalette[i] = fgPalette[i];
		*bPaletteSet = 1;
	}

	if (argv4) {
		int i, nofc = strlen(argv4);
		if (nofc > 16) nofc = 16;
		for (i = 0; i < nofc; i++)
			bgPalette[i] = GetHex(argv4[i]);
	}
}
#else
void readPalette(char *argv3, char *argv4, unsigned int *fgPalette, unsigned int *bgPalette, int *bPaletteSet) {	
	if (argv3) {
		int nofc, gr,gg,gb,i;
		nofc = (strlen(argv3)+1) / 7;
		if (nofc > 16) nofc = 16;
		for (i = 0; i < nofc; i++) {
			gr = (GetHex(argv3[i*7]) << 4) | GetHex(argv3[i*7+1]);
			gg = (GetHex(argv3[i*7+2]) << 4) | GetHex(argv3[i*7+3]);
			gb = (GetHex(argv3[i*7+4]) << 4) | GetHex(argv3[i*7+5]);
			fgPalette[i] = (0xff << 24) | (gr << 16) | (gg << 8) | (gb);
			if (!argv4) bgPalette[i] = fgPalette[i];
		}
	}

	if (argv4) {
		int nofc, gr,gg,gb,i;
		nofc = (strlen(argv4)+1) / 7;
		if (nofc > 16) nofc = 16;
		for (i = 0; i < nofc; i++) {
			gr = (GetHex(argv4[i*7]) << 4) | GetHex(argv4[i*7+1]);
			gg = (GetHex(argv4[i*7+2]) << 4) | GetHex(argv4[i*7+3]);
			gb = (GetHex(argv4[i*7+4]) << 4) | GetHex(argv4[i*7+5]);
			bgPalette[i] = (0xff << 24) | (gr << 16) | (gg << 8) | (gb); 
		}
	}
}
#endif

#endif	

void transformFilenameSpaces(char *inout) {
	while (*inout) {
		if (*inout == '~') *inout=' ';
		inout++;
	}
}

void makeOrigoPoly(intVector vv[], int *nofp, int bUseTextures) {
	int i, xo, yo;
	
	xo = vv[0].x; yo = vv[0].y; 
	for (int i=0; i<*nofp-1; i++) {
		vv[i].x = vv[i+1].x + xo;
		vv[i].y = vv[i+1].y + yo;
		if (bUseTextures) {
			vv[i].z = vv[i+1].z;
			vv[i].tex_coord = vv[i+1].tex_coord;
		}
	}
	(*nofp)--;
}

void RemoveGxyCodes(char *tstring, int bRemoveNewLineCode) {
	int i = 0, o = 0, len = strlen(tstring);

	for (i = 0; i < len; i++) {
		if (tstring[i] == '\\') {
			i++;
			if (tstring[i] == '\\' || tstring[i] == '-' || tstring[i] == 'r' || tstring[i] == 'n')
				;
			else if (tstring[i] == 'g')
				i+=2;
			else
				i+=1;
		} else {
			tstring[o] = tstring[i];
			o++;
		}
	}
	tstring[o] = 0;
}

	
#define MAX_OBJECTS_IN_MEM 64

int main(int argc, char *argv[]) {
	uchar *videoCol, *videoChar, *videoTransp, *videoTranspChar;
	int txres, tyres, nof, opCount = 0, fgcol, bgcol, dchar, transpval;
	intVector vv[64];
	CHAR_INFO *old = NULL;
	char s_fgcol[20], s_bgcol[20], s_dchar[4], s_transpval[20], fname[128];
	int bReadKey = 0, bWaitKey = 0, bMouse = 0, mouseWait = -1, bWriteReturnToFile = 0;
	Bitmap b_pcx;
	intVector v[64];
	float us[4] = {0, 1, 1, 0}, vs[4] = {0, 0, 1, 1};
	float *averageZ, lowZ, highZ, addZ, currZ;
	char *argv1;
	obj3d *objs[MAX_OBJECTS_IN_MEM];
	char *objNames[MAX_OBJECTS_IN_MEM];
	int objCnt = 0;
	char *pch, *insertedArgs = NULL;
	ErrorHandler errH;
	int bSuppressErrors = 0, bWaitAfterErrors = 0;
	int bWait = 0, waitTime = 0;
	int bWriteChars, bWriteCols, projectionDepth = 500;
	int orgW, orgH, rem = 0;
	int bPaletteSet = 0;
	int captX = 0, captY=0, captW, captH, captFormat=1, captureCount = 0, bCapture = 0;
	char sFlags[130];
	int bIgnoreServerCmdFile = 0, bIgnoreTitleComm = 1;
	char sTitleBuffer[1024] = "";
	int bUseOrigoPoly = 0, bUseOrigoBox = 0;
	
	int gx = 0, gy = 0;
	int outw = 0, outh = 0;
	
#ifdef GDI_OUTPUT
	int fontIndex = 6;
	unsigned int fgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	unsigned int bgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	int bWriteGdiToFile = 0;
	unsigned int orgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 	0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	int bAbsBitmapPos = 0;
	int bWindowedMode = 1;
	
#else
	
#ifndef _RGB32
	uchar fgPalette[20] = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 };
	uchar bgPalette[20] = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 };
	uchar orgPalette[20] = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 };
#else
	unsigned int fgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	unsigned int bgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	unsigned int orgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 	0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
		
#endif	
		
#endif


	int i, j, k, retVal = 0, ii, bSendKeyUp = 0;
	int bServer = 0, bDoNothing = 0, bInserted = 0, frameCounter = 0;
	DWORD oldfdwMode, oldOutMode, outMode;
	unsigned char *cp;
	long long startT = milliseconds_now();

#ifdef _RGB32
	int MAXBITOP=BIT_OP_BLEND_RGB;
	
	unsigned char outCh[64] = "";
	outCh[0]=0x20; outCh[1]=0x2b; outCh[2]=0x04; outCh[3]=0x05; outCh[4]=0;
	int conv16mode = 0;
	int conv16div = 1000;
	
	int	bWasConvertedTo16 = 0;
	uchar *conv16Col=NULL, *conv16Char=NULL, *oldVidCol=NULL, *oldVidChar=NULL;
	int conv16W=-1, conv16H=-1;
	
#else
	int MAXBITOP=BIT_NORMAL_IPOLY;
#endif


#ifdef GDI_OUTPUT
	g_rgbFgPalette = fgPalette;
	g_rgbBgPalette = bgPalette;
#endif
#ifdef _RGB32
	g_rgbFgPalette = fgPalette;
	g_rgbBgPalette = bgPalette;
#endif

	int rotationGranularity = 4;
	int bAutoCenter3d = 0;
	float autoScale3dScale = -1;

	int lightSource0Div = 25, lightSource0Plus = 16;
	
	int bZBuffer = 0;
	int bUsePerspectiveSingleCol = 0;

	uchar singleColData[16] = { 0 };
	Bitmap singleColBitmap = { 0 };
	
	int showHelp=0;
	
	singleColBitmap.xSize = 1;
	singleColBitmap.ySize = 1;
	singleColBitmap.transpVal = -1;
	singleColBitmap.data = singleColData;
	
	
	cp = hexLookup; k = 0;
	for (j = 0; j < 2; j++) {
		memset(cp, k, 256);
		for (i=0; i < 10; i++) cp[i + '0'] = i;
		cp['a'] = 10; cp['A'] = 10; cp['b'] = 11; cp['B'] = 11; cp['c'] = 12; cp['C'] = 12; cp['d'] = 13; cp['D'] = 13; cp['e'] = 14; cp['E'] = 14; cp['f'] = 15; cp['F'] = 15;
		cp = colLookup; k = 255;
	}

	for (i = 0; i < MAX_OBJECTS_IN_MEM; i++) {
		objs[i] = NULL;
		objNames[i] = NULL;
	}

	orgW = txres = getConsoleDim(0);
	orgH = tyres = getConsoleDim(1);

	outw = txres; outh = tyres;

	errH.errCnt = 0;

	if (argc > 1 && strlen(argv[1]) == 2 && argv[1][0] == '/' && argv[1][1] == '?')
		showHelp = 1;

	if (argc > 2 && showHelp == 0) {
		char *fnd, fin[64];
		int nof;
		for (i=0; i < strlen(argv[2]); i++) {
			switch(argv[2][i]) {
				case 'f': 
#ifdef GDI_OUTPUT
				i++; fontIndex = GetHex(argv[2][i]);
				if (fontIndex < 0 || fontIndex > 12) fontIndex = 6; 
#endif
				if (argv[2][i+1] == ':' && argv[2][i+2]) {
					fnd = strchr(&argv[2][i+2], ';');
					if (!fnd) strcpy(fin, &argv[2][i+2]); else { nof = fnd-&argv[2][i+2]; strncpy(fin, &argv[2][i+2], nof); fin[nof]=0; }
					nof = sscanf(fin, "%d,%d,%d,%d,%d,%d", &gx, &gy, &txres, &tyres, &outw, &outh);
					if (nof >= 3 && nof < 5) outw = txres;
					if (nof >= 4 && nof < 6) outh = tyres;
					if (outw > txres || outw < 0) outw = txres;
					if (outh > tyres || outh < 0) outh = tyres;
				}
				break;
				case 'o': bWriteReturnToFile = 1; break;
				case 'O': bWriteReturnToFile = 2; break;
			}
		}
	}

	// { double d1=0xff008800ffffff; long double d2=0xff008800ffffff; uchar v1=d1, v2=d2; printf("%d %d %lx %llx\n", sizeof(double), sizeof(long double), v1, v2);	}
	
	setResolution(txres, tyres);

	b_pcx.data = NULL;

//	if (argc < 2 || (argc > 1 && strcmp(argv[1], "/?") == 0)) { // WTF? This slows down performance of entire program (320 bounce balls=62 fps instead of 500 balls=62)... why??
//	if (argc < 2 || showHelp) { // It's messed up... this line causes same problem... but not below line, for now... could it be aligment related?
	if (argc < 2 || (argc > 1 && strlen(argv[1]) == 2 && argv[1][0] == '/' && argv[1][1] == '?')) {
		char boxhelp[] = "X and y are column and row coordinates with 0,0 as top left. A width and height of 0 still draws one single character.";
		char coordhelp[] = "X and y are column and row coordinates with 0,0 as top left.";
		char circlehelp[] = "Note that unless the font used has the same pixel width and height (such as bitmap font 2), the circle will not look perfectly round. Therefore it is often preferable to use an ellipse instead.";
		char polyhelp[] = "A minimum of 3 coordinates (max 24) must be specified to draw a polygon.";
#ifndef _RGB32
		char blockMode[]="mode[:1233]";
		char fileFormat[]="";
		char filePlus[]="";
		char bxyPlus[]="";
		char filePl[]="";
		char charFF[]="gxy/txt";
#else
		char blockMode[]="mode[[:1233],fgblend[,bgblend]]";
		char fileFormat[]="a 24 bit uncompressed bmp file, a bxy file saved with the c flag, ";
		char filePlus[]=" or bmp";
		char bxyPlus[]=" or bxy";
		char filePl[]="bmp,bxy,";
		char charFF[]="gxy/bxy/txt";
#endif	

		char ver[] = "v1.3";
		
#ifdef GDI_OUTPUT
#ifndef _RGB32
		char colspec[] = "Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.\n\nChar can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255 (code page 437 is always used). Use '?' to keep the character in the buffer at each position.";
		char name[16] = "_gdi";
#else		
		char colspec[] = "Cmdgfx_RGB can take colors as 24 bit hexadecimal RRGGBB values, e.g. ff00ff for violet. Fgcol and bgcol values can ALSO use palette index range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.\n\nChar can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255 (code page 437 is always used). Use '?' to keep the character in the buffer at each position.";
		char name[16] = "_RGB";
#endif
	
#else
#ifndef _RGB32
		char colspec[] = "Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.\n\nChar can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.";
		char name[2] = "";
#else		
		char colspec[] = "Cmdgfx_VT can take colors as 24 bit hexadecimal RRGGBB values, e.g. ff00ff for violet. Fgcol and bgcol values can ALSO use palette index range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.\n\nChar can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255 (code page 437 is always used). Use '?' to keep the character in the buffer at each position.";
		char name[16] = "_VT";
#endif
#endif
		if (argc > 2) {
			if (strcmp(argv[2], "fbox") == 0) {
				printf("\nFbox - draw a rectangle filled with characters\n\nSyntax: fbox fgcol bgcol char [x,y,w,h]\n\nIf the last four arguments are omitted, fbox fills the entire buffer.\n\n%s\n\n%s A negative width or height will make the box invisible.\n", colspec, boxhelp);
			}
			else if (strcmp(argv[2], "box") == 0) {
				printf("\nBox - draw an outline rectangle of characters\n\nSyntax: box fgcol bgcol char x,y,w,h\n\n%s\n\n%s Negative width and/or height is also accepted.\n", colspec, boxhelp);
			}
			else if (strcmp(argv[2], "pixel") == 0) {
				printf("\nPixel - draw a single character\n\nSyntax: pixel fgcol bgcol char x,y\n\n%s\n\n%s\n", colspec, coordhelp);
			}
			else if (strcmp(argv[2], "circle") == 0) {
				printf("\nCircle - draw an outlined circle of characters\n\nSyntax: circle fgcol bgcol char x,y,radius\n\n%s\n\n%s The given position is used as the center of the circle. A radius of 0 still draws one single character. A negative radius gives the same result as a positive radius.\n\n%s\n", colspec, coordhelp, circlehelp);
			}
			else if (strcmp(argv[2], "ellipse") == 0) {
				printf("\nEllipse - draw an outlined ellipse of characters\n\nSyntax: ellipse fgcol bgcol char x,y,rx,ry\n\n%s\n\n%s The given position is used as the center of the ellipse. Rx and ry are the x and y radius. Rx and ry of 0 still draws one single character. Negative radius values give the same result as positive ones.\n", colspec, coordhelp);
			}
			else if (strcmp(argv[2], "fcircle") == 0) {
				printf("\nFcircle - draw an filled circle of characters\n\nSyntax: fcircle fgcol bgcol char x,y,radius\n\n%s\n\n%s The given position is used as the center of the circle. A negative radius gives the same result as a positive radius.\n\n%s\n", colspec, coordhelp, circlehelp);
			}
			else if (strcmp(argv[2], "fellipse") == 0) {
				printf("\nFellipse - draw a filled ellipse of characters\n\nSyntax: fellipse fgcol bgcol char x,y,rx,ry\n\n%s\n\n%s The given position is used as the center of the ellipse. Rx and ry are the x and y radius. Negative radius values give the same result as positive ones.\n", colspec, coordhelp);
			}
			else if (strcmp(argv[2], "insert") == 0) {
				printf("\nInsert - use the content of a file as operation input for cmdgfx\n\nSyntax: insert filename\n\nThe file content replaces the insert operation, but not remaining operations after that.\n");
			}
			else if (strcmp(argv[2], "skip") == 0) {
				printf("\nSkip - ignore the following operation\n\nSyntax: skip anyoperation\n\nUse skip to ignore the operation following skip.\n");
			}
			else if (strcmp(argv[2], "rem") == 0) {
				printf("\nRem - ignore all following operations given\n\nSyntax: rem anyoperations\n\nUse rem to ignore all operations on the line following rem.\n");
			}
			else if (strcmp(argv[2], "line") == 0) {
				printf("\nLine - draw a line (or bezier line) of characters\n\nSyntax: line fgcol bgcol char x,y,x2,y2 [bezierPx1,bPy1[,...,bPx6,bPy6]]\n\n%s\n\nX and y are column and row coordinates with 0,0 as top left. The line is drawn from x1,y1 to x2,y2.\n\nTo draw a bezier (curved) line instead of a straight line, specify atleast 1 and up to 6 control points.\n", colspec);
			}
			else if (strcmp(argv[2], "poly") == 0) {
				printf("\nPoly - draw a filled polygon of characters\n\nSyntax: poly fgcol bgcol char x1,y1,x2,y2,x3,y3[,x4,y4...,y24]\n\n%s\n\n%s\n\nThe poly operation cannot properly draw self-intersecting polygons. For that, use the ipoly operation.\n", colspec, polyhelp);
			}
			else if (strcmp(argv[2], "ipoly") == 0) {
				#ifndef _RGB32
					char ipolyExtra[] = "";
				#else
					char ipolyExtra[] = "\n\n*RGB* : Ipoly is the only operation (except for block) that allows drawing with alpha blending. Keep in mind that the 3d operation allows setting a bitop for flat shading, which means it can also do blending.\n\nThere are 6 extra bitops, dealing with various forms of color blending:\n\n16=Add_RGB_Fg, 17=Add_RGB, 18=Sub_RGB_Fg, 19=Sub_RGB, 20=Blend_RGB_Fg, 21=Blend_RGB\n\nThe Fg versions deal only with changing the Fg color but does not blend the Bg color. This can be faster.\n\nMode 16 and 17 adds the given 24 bit RGB color of the form RRGGBB to the current color in the buffer. Mode 18 and 19 subtracts in the same manner.\n\nFor mode 20 and 21, the colors given must be 32 bit. This means that they follow the form AARRGGBB, where AA specifies the opacity of the drawn color, 0-255.\n";
				#endif
				
				printf("\nIpoly - draw a filled polygon of characters (supporting self-intersection)\n\nSyntax: ipoly fgcol bgcol char bitop x1,y1,x2,y2,x3,y3[,x4,y4...,y24]\n\n%s\n\nExcept for the 3d operation, ipoly is the only operation that supports bit operations (bitop is only used for color, not char).\n\nPossible bitop values: 0=Normal, 1=Or, 2=And, 3=Xor, 4=Add, 5=Sub, 6=Sub-n, 7=regular\n\n%s\n\nNote that ipoly can be used to simulate other operations such as fbox if bitop is needed. Fcircle, fellipse, line, and pixel can also be simulated with ipoly, though it is slightly cumbersome.\n%s", colspec, polyhelp, ipolyExtra);
			}
			else if (strcmp(argv[2], "image") == 0) {
				printf("\nImage - draw an image or text file of characters\n\nSyntax: image filename fgcol bgcol char transpchar/transpcol x,y [xflip] [yflip] [w,h]\n\n'filename' should point to %sa gxy file, a 16 color pcx file, or any other (preferably text) file.\n\nFgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' for fgcol to keep the foreground color in the buffer at each position, and use '?' for bgcol to keep the background color in the buffer at each position. Precede fgcol and/or bgcol with '-' to force the color used. Precede fgcol with '\\' to ignore/type out all gxy control codes inside the file.\n\nNote that fgcol will only have effect for a txt file, and bgcol will have no effect for a gxy%s file (unless forcing fgcol and/or bgcol with '-', or if using '?').\n\nChar can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position. For a %s file, the char argument has no effect unless '?' is used.\n\n'transpchar' or 'transpcol' can be used to make part of the image transparent. For a gxy file and text file, set 'transpchar' to either a char or a two-digit hexadecimal character to make that character transparent. For a pcx%s file, set 'transpcol' to make that color transparent.\n\nX and y are column and row coordinates with 0,0 as top left.\n\nBoth 'xflip' and 'yflip' are normally 0. Set 'xflip' to 1 to flip the image horizontally, and set 'yflip' to 1 to flip the image vertically.\n\nSpecify 'w' and 'h' (width and height) to scale the image to the given width and height. Negative values are not allowed.\n", fileFormat,bxyPlus,charFF,filePlus);
			}
			else if (strcmp(argv[2], "text") == 0) {
				printf("\nText - write a formatted text string\n\nSyntax: text fgcol bgcol char string x,y\n\nFgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' for fgcol to keep the foreground color in the buffer at each position, and use '?' for bgcol to keep the background color in the buffer at each position. Precede fgcol and/or bgcol with '-' to force the color used. Precede fgcol with '\\' to ignore/type out all gxy control codes inside the text.\n\nChar has no meaning for the text operation, unless '?' is used to keep the character in the buffer at each position.\n\nThe 'string' allows formatting text output using the same control codes used in gxy files. Note that it is *not* possible to write blank spaces in the string. Instead, spaces must be written as underscores (_), or as \\g20, or as \\- to skip writing the character. To actually write an underscore in a string, use the Ascii code formatting \\g5f\n\nThe following gxy control codes are supported in the string:\n\n   \\r: restore previous fgcol and bgcol\n \\gxx: ascii character in hex (xx)\n   \\n: newline (new line starts from initial x position)\n   \\-: skip character (transparent)\n   \\\\: print \\\n  \\xx: fgcol and bgcol in hex, e.g. \\A0 for green text on black background. Use 'k' to keep the current fgcol and/or bgcol, and 'u' and 'U' to use current foreground/background color of the cmd window\n\nApart from blank space, a few other characters must be written using control codes, including & (\\g26), \" (\\g22), and possibly ! (\\g21) and %% (\\g25)\n\nX and y are column and row coordinates with 0,0 as top left.\n");
			}
			else if (strcmp(argv[2], "tpoly") == 0) {
				printf("\nTpoly - draw an affine texture-mapped polygon of characters\n\nSyntax: tpoly image fgcol bgcol char transpchar/transpcol x1,y1,tx1,ty1,x2,y2,tx2,ty2,x3,y3,tx3,ty3[...,ty24]\n\n'filename' should point to %sa gxy file, a 16 color pcx file, or any other (preferably text) file.\n\nFgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Unlike the image operation, fgcol and bgcol are not ignored but instead *added* to the texture's foreground and background colors. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position. Precede fgcol or bgcol with '-' to force using that color instead of the colors in the image.\n\nChar can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Note that char is ignored unless the image is a pcx%s file. Use '?' to keep the character in the buffer at each position.\n\n%s For each coordinate you must also specify x and y floating point texture coordinates. 0,0 is the top left coordinate and 1,1 is the bottom right. It is also possible to repeat the texture in x and/or y by specifying a value larger than 1, i.e. 2.5 to repeat the texture 2.5 times. Unlike the 3d operation, the 'T' flag does not have to be set for this to work properly.\n\nThe tpoly operation cannot draw self-intersecting polygons.\n", fileFormat,filePlus, polyhelp);
			}
			else if (strcmp(argv[2], "gpoly") == 0) {
				printf("\nGpoly - draw a goraud-shaded polygon of characters\n\nSyntax: gpoly palette x1,y1,c1,x2,y2,c2,x3,y3,c3[,x4,y4,c4...,c24]\n\nThe 'palette' should be a number of fcol+bgcol+char combinations (all in hexadecimal notation), typically gradually going from one color to the next, separated by '.' An example of a 5 step palette fading from black to light blue would be 10b0.10b1.10db.19b1.1920\n\n%s The third argument per coordinate (cn), is an index number into the palette used, where 0 denotes the first index, and n+1 denotes the last. Thus, a full use of the above palette for a triangle polygon could look like: gpoly 10b0.10b1.10db.19b1.1920 2,2,0, 60,2,2, 2,30,5\n\nThe gpoly operation cannot draw self-intersecting polygons.\n", polyhelp);
			}
			
			else if (strcmp(argv[2], "3d") == 0) {
				printf("\n3d - draw a 3d object file\n\nSyntax: 3d objectfile drawmode,drawoption[,tex_offset,tey_offset,tex_scale,tey_scale] rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]\n\n[objectfile] These file formats are supported: ply, plg, and obj. Only the obj file format supports texture mapping, and all normals are discarded. The obj format has a number of non-default extensions added for cmdgfx (while ignoring all other info than v, vt, and f). The extensions are all for 'usemtl': 1. Usemtl does not support mtl files, instead it supports %spcx,gxy and txt files. It is possible to follow the file name with a (hex value) color (for pcx%s files) or character (for other formats) that is used for transparency. 2. cmdblock extension, to use a rectangular block of the current buffer as texture. Syntax usemtl cmdblock x y w h [transpchar]. There is also cmdcolblock, which copies only colors, not characters, with syntax: cmdcolblock x y w h [transpcol] 3. cmdpalette extension, use this to change the palette used to draw the object from this point on. The syntax is: usemtl cmdpalette followed by a palette of the same format as used at the end of the 3d operation (see below)\n\ndrawmode: 0=affine texture mapping if texture available, else flat shading, 1=flat shaded with z-sourced lighting, 3=goraud shaded z-sourced lighting, 3=wireframe lines, 4=forced flat shading, 5=perspective correct texture mapping if texture available, else flat shading, 6=affine char/perspective color texture\n\ndrawoption: In hexadecimal! For mode 0,5,6 with texture, drawoption is transpchar(for %s) and transpcol(for pcx%s); set to -1 if no transparency wanted. For mode 0,5,6 without texture and mode 4, drawoption is bitwise operator (see ipoly for values). For mode 1 and 2, set to 0 for static and 1 for even light distribution (L flag to set light range). For mode 1, a bitwise operator can also be set in the high nibble (bitop*16) of drawoption.\n\n[,tex_offset,tey_offset,tex_scale,tey_scale]: optional parameters used to set/scroll texture offset. Since calculating floating point in Batch is hard, the values are integers, where 0 is 0 and 100000 is 1. The scale is used to determine how much of the texture is seen at once, e.g a value of 33000 would show 1/3 of the texture in the given dimension, and 200000 would show it double.\n\nrx[:rx2],ry[:ry2],rz[:rz2]: rotation of 3d object in 3 axis, specified as Euler angles. If specifying a second rotation (for all axis), it is performed *after* the first translation. Keep in mind that angles are integers, and by default multiplied by 4 (can be changed with R flag), so a full circle is 1440 degrees.\n\ntx[:tx2],ty[:ty2],tz[:tz2]: floating point translation (move) of 3d object in 3 dimensions. The translation is done after the rotation. If specifying a second translation (for all dimensions), it is performed after the second rotation.\n\nscalex,scaley,scalez,xmod,ymod,zmod: Floating point initial moving (mod) and scaling of the object done before any translations or rotations. Note that mod is done before scaling, and thus uses the initial object size.\n\ncull,z_near_cull,z_far_cull,z_levels: Set cull to 1 to use backface culling, otherwise 0. Z_near_cull sets the close-to-camera cutoff z distance where the object is no longer visible (set 0 for no cutoff). Z_far_cull sets the far-away camera cutoff z distance where the object is no longer visible (set 0 for no cutoff). Z_levels is used to sort faces within a single object, where a higher value gives better precision (a default of 10  will be used if 0 is set)\n\nxpos,ypos,distance,aspect: Xpos,ypos is the screen center point (column and row) around which the object is drawn. Distance is the distance of the object from the camera. Negative values produce an 'inverted' object. Aspect (floating point value) is used for correction when fonts are not the same width as height, and thus make objects appear distorted (not true for pixel fonts, where aspect is 1). To get the correct aspect for a font, divide its width in pixels by its height, e.g. raster font 1 is 6/8=0.75.\n\nfgcol1 bgcol1 char1...: Faces are drawn using at mimimum 1 set of fgcol/bgcol/char, and at most 32. If only 1 is provided, the same set is used for all faces. If 2 are provided, set 1 is used for face 1, set 2 for face 2, set 1 for face 3, etc. Use '?' for fgcol or bgcol to keep the current foreground AND background colors in the buffer. Use '?' for char to keep the current characters in the buffer. If drawing with a texture, fgcol and bgcol are not ignored but instead *added* to the texture's foreground and background colors. Char is ignored for textures unless it is a pcx%s file. Cols are 0-15 in hex or decimal (u and U for current console fg/bg colors), and chars are 0-255 in hex or written as an actual character.\n\nNote that faces with less than 3 vertices are treated differently when drawing, since they cannot form a polygon. For single vertex faces, a single character (dot) is drawn (except in drawmode 2). However, for mode 0,1,5 and 6, if a texture has been set, the texture is drawn (as unscaled image) instead of a dot, with the vertex as center point. For faces with 2 vertices, a line is drawn between the points (except in drawmode 2).\n\nAlso note that the Z-buffer (if enabled) only works for textured graphics in drawmode 5 by default. Set the s flag too to support Z-buffer for flat shade in 3d modes 0,1,4 as well.\n",filePl,filePlus,charFF,filePlus,filePlus);
			}
			else if (strcmp(argv[2], "block") == 0) {
				#ifndef _RGB32
					char blockExtra[] = "";
					char blockExtraFuncs[] = "";
				#else
					char blockExtra[] = "*RGB* : ,fgblend[,bgblend]: For cmdgfx_RGB, the block operation can set an opacity for the final block output between 0-255. This is always added to the end of the mode setting, preceded with a ',' character. If only fgblend is set, only the foreground color is blended. If bgblend is set, both fgcol and bgcol are blended separately. E.g. to copy with alpha blend 128 for fgcol only: block 0,128 5,5,40,40 20,20. To move (and set specific move char) and use separate blend for fgcol and bgcol: block 1:a021,128,64 5,5,40,40 20,20\n\n";
					char blockExtraFuncs[] = "\n\n*RGB* : There are several new helper functions for colExpr to deal with 24 bit color values. Please note that currently, due to lack of precision, ONLY fgcol values can be changed and even *preserved* in colExpr! The bgcol for values set in colExpr will ALWAYS be (re)set to 0.  New functions: 1. shade(col,r,g,b) to add (or decrease if negative) the values r,g,b to the color col (typically col would be replaced by e.g. fgcol(x,y)).  2. blend(col, a,r,g,b) to alpha blend col with color r,g,b using opacity a (all values in range 0-255).  3. makecol(r,g,b) to construct a color from r,g,b values in range 0-255.  4. fgr(col),fgg(col),fgb(col) to get a color's red,green or blue value (0-255).";
				#endif
				
				printf("\nBlock - copy, move, and transform a block of characters\n\nSyntax: block %s x,y,w,h x2,y2[,w2,h2[,rz]] [transpchar/transpcol] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from] [mvx,mvy,mvw,mvh]\n\nIn its most simple form, the block operation is used to copy or move a rectangular block of characters from one place to another. For example, to copy a block of character from position 10,10 with width and height of 5,5 to position 0,0, use: block 0 10,10,5,5 0,0\n\nmode[:1233]  Essentially, there are two modes: 0=copy and 1=move, but also 2=copy and 3=move (see transparency below). If using move (mode 1 or 3), we can optionally specify the character to fill the empty area after the move (default is blank space with color 7 and background color 0). In order to make a block move and fill in with exclamation points (ASCII hex value 21), with color 15(f) and background color 4, use: block 1:f421 10,10,5,5 0,0\n\n%sx,y,w,h x2,y2[,w2,h2[,rz]]: X and y are column and row coordinates with 0,0 as top left. X2,y2 is destination. Negative coordinates are ok, but not negative width/height. Optionally, the block can be scaled by setting w2 and h2, as well as rotated with rz (only 90,180,270 degrees supported). Scaling is done before rotation.\n\n[transpchar/transpcol]: when making the copy or move, either a character (mode 0 and 1) or a foreground color (mode 2 and 3) can be transparent, i.e. not copied. If no transparency is needed, specify -1.\n\n[xflip] [yflip]: the copied block can be reversed(flipped) in x and/or y. Specify 1 instead of 0 for each to do so.\n\n[transform]: The block operation allows per-character search and replace functionality. A transform string follows the format 1233=1233,... and the characters used are 0-f, ?=any, +=add 1, -=minus 1. To take all blank spaces (hex 20) with color 5 and bgcolor 1, and replace with A(hex 41) with color 9 and 0, the transform string would look like: 2051=4190. To also change all B's(42) to C's(43), regardless of color, ? would be used to disregard color(s), and get the string: 2051=4190,42??=43??. Finally, to take all characters from 40-4f(@ and A-O) and keep it, BUT increase the color and decrease the bgcolor, the string would be: 2051=4190,42??=43??,4???=??+-. Note that characters that do not fit any rules are left as-is, and that rules are checked from left to right only until the FIRST match is made. To do a catch-all at the end and transform all remaining characters to black spaces(20), use: 2051=4190,42??=43??,4???=??+-,????=2000. Note that + and - can also be used for characters (++ or --), and that ? can be used for color AND/OR bgcolor.\n\n[colExpr]: The block operation allows using mathematical expressions on a per-character basis to change color/bgcolor. One would typically want to produce output in the range 0-15 (for color 0-15 and bgcolor 0), or 0-255 (color 0-15 in low byte, bgcolor 0-15 in high byte). A colExpr can also be combined with a transform, which is applied after the expression. Apart from regular math operations, expressions can also use standard math functions such as: sin, cos, abs, asin, pow, pi, tan, atan, log, floor, etc, plus added functions random() to make random number 0..1, eq(n,n2) return 1 if n=n2 otherwise 0, neq(n,n2) return 1 if NOT n=n2 otherwise 0, gtr(n,n2) return 1 if n>n2, lss(n,n1) return 1 if n<n2, char(xp,yp) return character value at xp,yp, col(xp,yp) return color value at xp,yp, fgcol(xp,yp) return fgcol 0-15, bgcol(xp,yp) return bgcol 0-15, store(expr, [0-4]) returns 0 and stores the math expression expr in one of 5 variables called s0-s4 for later reuse, and finally bitwise logic functions or(n,n2), and(n,n2), xor(n,n2), neg(n), shl(n,n2), shr(n,n2). In addition, the variables x and y are available inside the expression and represent the position of the character currently being processed (note that the top-left position of the block is always 0,0). A simple example of a colExpr where each row has a different color (starting with 1) would be just y+1. An example to create a plasma-like color variation could be: sin(y/13)*15*cos(x/16*y/34)*15+15.%s\n\n[xExpr yExpr]: Must be provided as a pair. The first determines the x position, the second the y position. By default, it determines the position this character is going *to*, but can be changed to mean where the character should be taken *from* (see next parameter). Variables and functions for xExpr and yExpr are the same as colExpr above. Note that colExpr evaluates before xExpr and yExpr, so it can be used to provide data to move. A simple example to first fill with blue and then move the lines vertically: fbox 9 0 A 0,0,80,50 & block 1 0,0,81,51 0,0 -1 0 0 - - x y*y/4\n\n[from|to]: As mentioned above, to is default for xExpr and yExpr.\n\n[mvx,mvy,mvw,mvh]: Optimization setting for xExpr and yExpr, which can be used to limit the rectangular area (inside the entire block) for which the expressions are evaluated.\n", blockMode, blockExtra, blockExtraFuncs);
			}
			
			else if (strcmp(argv[2], "flags") == 0) {
#ifdef GDI_OUTPUT
				char gdiflag1[] = "\n- a  Absolute (pixel) output positioning (used by f flag)";
				char gdiflag2[] = "\n- U  Draw straight on top of Windows desktop instead of current window";
				char gdiflag3[] = "\n  P  Save buffer to 'GDIbuf.dat' at end of run, read back when start again";
				char fFlag[] = "  fFont:x,y,w,h,outW,outH  Set buffer font(0-9,a-c), position, and size. 1-7 params. Force outW and outH to screen width/height for better performance\n";
#else
				char gdiflag1[] = "", gdiflag2[] = "", gdiflag3[] = "";
				char fFlag[] = "  f:x,y,w,h,outW,outH  Set output buffer position and size. 0-6 params. Force outW and outH to screen width/height for better performance\n";
#endif

#ifndef _RGB32
				char cFlag[] = "Capture buffer to file, as capture-i.gxy (i starts at 0 and increases). 0-6 params. Format=0 for txt format. Last param can force i\n";
#else
				char cFlag[] = "Capture buffer to file, as capture-i.bxy (i starts at 0 and increases). 0-6 params. Format=0 for txt, 1 for bxy(default), 2 for bmp format, 3 for gxy(legacy). Last param can force i\n";
#endif

				printf("\nFlags marked with - can be turned OFF in server by preceding it with -\n\nSet flags in 4 ways:\n1. If not using server, flags are the third argument after string of operations\n2. If running as server, flags are also put after the operations\n3. To force flag changes in server (skip queue), create file 'servercmd.dat' in start folder. Start file with operations within \"\", then blank space and flags\n4. If 'I' flag has been set, window title can be set to send operations/flags. Title must be prefixed with 'output:'. Example: title output: \"\" e\n\nDebug:\n- d  Print entire line causing the error if error happens\n- e  Ignore/hide all error messages\n- E  Wait for key press after error\n\nInput/timing (cmdgfx_input prefered):\n- k  Return keys (in ERRORLEVEL, and in EL.dat if server on and o/O flag set)\n  K  As above, but not persistent, and will *wait* for key press\n- m[i]  Return input (mouse/key) info (in ERRORLEVEL, and in EL.dat if server on and o/O flags set). Set i to wait max i ms. Format of bit pattern: kkkkkkkkuyyyyyyyyxxxxxxxxxWwrlM where M=1 if mouse event, l=left click, r=right click, w/W=mouse wheel up/down, x/y=mouse coordinates, u=key up, k is keycode (0=no key)\n- M[i]  As above, but reports mouse move even if no mouse key pressed\n- u  Also send keyboard UP events for m and M flags\n- wi  Wait i ms after each frame\n- Wi  Wait up to i ms after each frame (use for smooth frame rate)\n- z  Enable sleeping wait (for w and W flag). Uses less CPU but less smooth\n\nOutput:%s\n  c:x,y,w,h,format,i  %s%s  n  Produce no output. Used to create a frame in several steps%s\n\n3d:\n  b  Clear Z-buffer (only makes sense if n flag was just used)\n- B  Create Z-buffer (only 3d mode 5 supported if s flag not set)\n  D  Clear all 3d objects in memory\n  Li,j  Set z-light range to i,j. Used for 3d in mode 1. Default: 25,16\n- N[i]  Auto center 3d objects. If i is set, enable auto scaling by i\n  Ri  Rotation granularity for 3d. Default is 4, i.e. full circle is 360*4\n- s  Z-buffer support for flat shade in 3d modes 0,1,4. Handles edge bug for pcx textures\n- T  Support repeated texture coordinates (above 1.0)\n  Zi  Set projection depth i for all 3d operations. Default: 500\n\nOther:\n  C  Clear frame counter (print using [FRAMECOUNT] in string for text op)\n  Gi,j  Set maximum allowed width and height of gxy files. Default: 256,256\n  p  Preserve the content of the cmd window text buffer when starting cmdgfx%s\n  v  Enable origo mode for all poly operations (first coordinate is origo, rest are deltas)\n  V  Enable origo mode for all box operations\n\nServer:\n  F  Flush the pipe input buffer between script and server\n- i  If set, ignore the file 'servercmd.dat' even if present\n- I  If set, support setting title to supply commands to cmdgfx\n- J  When an input event happens, flush buffer between script and server\n- o  Each frame, write return value (input events) to EL.dat\n- O  Same as o, but only write to El.dat if an event happened (usually better)\n  S  Enable server mode\n", gdiflag1, cFlag, fFlag, gdiflag2, gdiflag3);
			}
			else if (strcmp(argv[2], "palette") == 0) {
#ifdef GDI_OUTPUT
				printf("\nPalette - set new RGB values for the 16 color palette\n\nThe foreground palette is set as parameter 3, always following flags (use - to set no flags). The background palette can be set as parameter 4, but if omitted, background palette is the same as foreground.\n\nAll 16 colors can potentially be set, but does not have to be.\n\nThe palette follows the format RRGGBB,RRGGBB,... up to 16 colors, where RR is the red component 0-255 in hexadecimal, GG is the green component, and BB is the blue component. As an example, to keep index 0 black but set color 1 to orange and color 2 to lime green, use 000000,ff9900,99ff00 as palette.\n\nIf runninng as server, default palette can be restored by using - as palette.\n");
#else
				printf("\nPalette - rearrange order of the 16 cmd colors\n\nUnlike cmdgfx_gdi, setting the palette for cmdgfx does not set new RGB colors. Instead, it rearranges the existing palette indices. To actually set RGB colors for cmdgfx, use the program 'cmdwiz' with the 'setpalette' operation.\n\nThe foreground palette for cmdgfx is set as parameter 3, always following flags (use - to set no flags). The background palette can also be set as parameter 4 (it is NOT copied from parameter 3 if omitted).\n\nAll 16 color indices can potentially be rearranged, but does not have to be.\n\nThe default palette looks like 0123456789abcdef, which means index 0 is color 0, index 10 is color 10(a) etc. As an example, to keep index 0 and 1 as black and dark blue, but set index 2 to light blue, index 3 to cyan, and index 4 to white, use 019bf as palette.\n\nIf running as server, default palette can be restored by using - as palette.\n");
#endif
			}
			else if (strcmp(argv[2], "server") == 0) {
				printf("\nRunning as server has several advantages, mostly regarding speed. The overhead of running an executable each frame disappears, and 3d objects are kept in memory and don't have to be re-read with each use. Server functionality also presents some problems, such as dealing with asynchronicity and input lag.\n\nIn order to run as server, the S flag must be set, and the program needs to be last in a pipe chain, such as: call program.bat | cmdgfx.exe "" S . For practical purposes, it is a better idea to have the script call itself this way than to have to type it manually each time. There are many example batch scripts included with this program that show how do to this.\n\nTo send operations from the script to the program, use the echo command with a prefix of 'cmdgfx:' within quotes (optionally followed by flags and palette(s)), e.g: echo \"cmdgfx: fbox 9 0 A\". If the string sent does not have the prefix, the server simply prints it to stdout and otherwise ignores it. It is also possible to send operations either by writing (without 'cmdgfx' prefix) to the file 'servercmd.dat', or (if I flag set) by setting the title of the window, prefixed with 'output:'. These two methods have the advantage that they bypass the frame queue over the pipe and are processed immediately.\n\nSetting flags: see the separate help section for flags. Note that flags can be disabled by preceding with -.\n\nDealing with input lag: because the batch script may execute faster than cmdgfx, a queue of frames to render may build up over the pipe, which can result in input lag. Actually, the best way to deal with this is to use the separate 'cmdgfx_input' program to handle input, because when put at the beginning of the pipe chain (like: cmdgfx_input.exe m0nW10 | call program.bat | cmdgfx "" S) it can control the speed of the batch script, preventing it from running faster than the server. Most of the example scripts included with the program use this approach. Without cmdgfx_input, the best approach is to set the O flag (see flag section), and send in extra data (~2000 characters) prefixed by 'skip' with each call to the server to fill up the pipe buffer to prevent the server from lagging behind.\n\nQuitting the server: To exit the server, use echo as usual but follow 'cmdgfx:' with 'quit'. Using servercmd.dat or setting the title is also supported.\n");
			}
			else if (strcmp(argv[2], "compare") == 0) {
				printf("\nThe main difference between cmdgfx and cmdgfx_gdi is that while the former outputs actual text into the cmd window buffer, the output of cmdgfx_gdi is not text but a bitmap, simulating text output.\n\nProducing a bitmap instead of text may seem nonsensical, but there is a simple explanation: it is (usually) much faster! That is because the Windows API to output text to a console is very slow, as soon as there is more than one color in the output.\n\nThe cmdgfx_gdi executable is larger than cmdgfx, because bitmap font data is embedded inside the program. This means that while cmdgfx will use any current font set in the console window, cmdgfx_gdi only supports a small subset of embedded fonts: raster fonts 0-9, plus the specialized fonts a-c which are so called pixel fonts (1 character is 1 'pixel', font a is 1x1 size, font b 2x2 and font c 3x3). Apart from being faster and supporting pixel fonts, there are also a few other things cmdgfx_gdi can do that cmdgfx cannot (see list below).\n\nUse cmdgfx:\n  1. For single output, not animating in a loop (speed is not crucial)\n  2. When the resulting characters actually need to be put into the text buffer\n  3. When needing to use another font than the 9 raster fonts or pixel fonts\n  4. If output is monochrome/single color (speed will be same or better)\n\nUse cmdgfx_gdi:\n  1. When speed is of the essence (when making animations)\n  2. When needing to write pixels instead of characters\n  3. When needing to write to desktop instead of current window (set flag U)\n  4. When needing to place the output with pixel precision instead of character precision (set a flag, then use f flag)\n  5. For advanced users, it is possible to get more than 16 color output by splitting the output into blocks and setting an individual palette for each\n  6. For adcanced users, it is possible to use more than one font on a single screen, by splitting the output into blocks and using a different font for each\n\n\n*RGB* : The main difference between cmdgfx_RGB and cmdgfx_gdi is that the former can read/write 24 bit RGB colors. It can also use 24 bit BMP files as input for images, textures etc. Colors are stored as 24-bit RRGGBB values, which is something that e.g. the block colExpr has to take into account to produce meaningful values.\n\nOnly use cmdgfx_RGB if RGB output is actually needed. The program reads/writes about 8 times as much data as cmdgfx/cmdgfx_gdi, and is therefore significantly slower. \n\n\n*VT*: This is the RGB equivalent of standard cmdgfx, which means it can output actual text and use the current font of the console window. It only works on Windows 10 machines, as only Windows 10 supports VT-100 escape codes to set colors. It has significantly slower output than cmdgfx_RGB.\n");
			}
#ifdef _RGB32			
			else if (strcmp(argv[2], "color16") == 0) {

				printf("\nColor16 - convert RGB buffer to 16 colors using a mix of characters\n\nSyntax: color16 [mode] [set] [range]\n\nNote that color16 can only be called *once* per frame, further calls will be ignored. Also note that after calling color16, any drawing operations during the same frame will not be preserved in the buffer.\n\nThe current 16 color palette will be used in the conversion (console window default colors unless previously specified)\n\n[mode]: Either 0 or 1 (default 0). Affects how conversion is done, experiment for best results.\n\n[set]: The character set index used in the conversion, *or* a custom character set. Standard set indices are 0-3 (default 0). In order to set a custom set, specify a string of characters starting with the least solid character and ending with the most solid character. Gxy format of \\g is supported for special characters. Example: \\g20-+jW\n\n[range]: Represents the numerical color distance range used for each character in the set. Default value is 1000. Experiment for best results (for a set with a long string of characters, the range should typically be smaller).\n");
			}
#endif
			else {
				printf("\nError: Unknown help section\n");
			}

		
		} else {
#ifdef _RGB32
			char color16op[] = "color16  [mode] [set] [range]\n";
#else
			char color16op[] = "";
#endif
			printf("\nCmdGfx%s %s : Mikael Sollenborn 2016-2019\n\nUsage: cmdgfx%s [\"operations\"] [flags] [fgpalette] [bgpalette]\n\nOperations (separated by &):\npoly     fgcol bgcol char x1,y1,x2,y2,x3,y3[,x4,y4...,y24]\nipoly    fgcol bgcol char bitop x1,y1,x2,y2,x3,y3[,x4,y4...,y24]\ngpoly    palette x1,y1,c1,x2,y2,c2,x3,y3,c3[,x4,y4,c4...,c24]\ntpoly    image fgcol bgcol char transpchar/transpcol x1,y1,tx1,ty1,x2,y2,tx2,ty2,x3,y3,tx3,ty3[...,ty24]\nimage    image fgcol bgcol char transpchar/transpcol x,y [xflip] [yflip] [w,h]\nbox      fgcol bgcol char x,y,w,h\nfbox     fgcol bgcol char [x,y,w,h]\nline     fgcol bgcol char x1,y1,x2,y2 [bezierPx1,bPy1[,...,bPx6,bPy6]]\npixel    fgcol bgcol char x,y\ncircle   fgcol bgcol char x,y,r\nfcircle  fgcol bgcol char x,y,r\nellipse  fgcol bgcol char x,y,rx,ry\nfellipse fgcol bgcol char x,y,rx,ry\ntext     fgcol bgcol char string x,y\nblock    %s x,y,w,h x2,y2[,w2,h2[,rz]] [transpchar/transpcol] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from] [mvx,mvy,mvw,mvh]\n3d       objectfile drawmode,drawoption[,tex_offset,tey_offset,tex_scale,tey_scale] rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]\n%sinsert   file\nskip\nrem\n\nArguments within brackets are optional, but if used they must be written in the given order from left to right. For example, to set [xflip] for the block operation, [transpchar] must be specified first.\n\n'cmdgfx%s /? operation' to see operation info, e.g. 'cmdgfx%s /? fbox'\n\n'cmdgfx%s /? flags' for information about flags.\n\n'cmdgfx%s /? server' for info on running as server.\n\n'cmdgfx%s /? palette' for info on setting the color palette.\n\n'cmdgfx%s /? compare' for a comparison of cmdgfx, cmdgfx_gdi, cmdgfx_RGB, and cmdgfx_VT.\n", name, ver, name, blockMode, color16op, name, name, name, name, name, name);
		}
		
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	videoCol = (uchar *)calloc(XRES*YRES,sizeof(uchar));
	if (videoCol == NULL) {
		printf("Error: Couldn't allocate memory for framebuffer!\n");
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	videoChar = (uchar *)calloc(XRES*YRES,sizeof(uchar));
	if (videoChar == NULL) {
		printf("Error: Couldn't allocate memory for framebuffer(2)!\n");
		free(videoCol);
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	videoTransp = (uchar *)malloc(XRES*YRES*sizeof(uchar));
	if (videoTransp == NULL) {
		printf("Error: Couldn't allocate memory for transpbuffer!\n");
		free(videoCol);
		free(videoChar);
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	videoTranspChar = (uchar *)malloc(XRES*YRES*sizeof(uchar));
	if (videoTranspChar == NULL) {
		printf("Error: Couldn't allocate memory for transpbuffer(2)!\n");
		free(videoCol);
		free(videoChar);
		free(videoTransp);
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	averageZ = (float *) malloc(32000*sizeof(float));
	if (!averageZ) { printf("Err: Couldn't allocate memory for averages\n"); free(videoCol); free(videoChar); writeErrorLevelToFile(bWriteReturnToFile, 0, 0); return 0; }

	argv1 = (char *) malloc(MAX_OP_SIZE*sizeof(char));
	if (!argv1) { printf("Err: Couldn't allocate memory for string\n"); free(averageZ); free(videoCol); free(videoChar); writeErrorLevelToFile(bWriteReturnToFile, 0, 0); return 0; }

	bInserted = 1;
	insertedArgs = insertCgx(argv[1]);
	//printf(insertedArgs); getch();
	if (!insertedArgs) { insertedArgs = argv[1]; bInserted = 0; }

	if (argc > 2) {
		for (i=0; i < strlen(argv[2]); i++) {
			switch(argv[2][i]) {
				case 'p': {
					if (!old) old = readScreenBlock();
					if (old) {
						int j2, gstart = 0;
#ifdef GDI_OUTPUT
						gstart = gx + gy*orgW;
#endif
						for (j2 = 0; j2 < YRES; j2++) {
							for (j = 0; j < XRES; j++) {
								int fromPos = j+j2*orgW + gstart;
								if (j < orgW && j2 < orgH && fromPos < orgW * orgH) {
#ifndef _RGB32
									videoCol[j+j2*XRES] = old[fromPos].Attributes;
#else
									uchar bgc = g_rgbBgPalette[(old[fromPos].Attributes >> 4) & 0xf];
									bgc = bgc << BITSHL;
									videoCol[j+j2*XRES] = g_rgbFgPalette[old[fromPos].Attributes & 0xf] | bgc;
#endif								

									videoChar[j+j2*XRES] = old[fromPos].Char.AsciiChar;
								}
							}
						}

						free(old);
					}
				}
				break;
				
				case 'P': {
						FILE *fp; 
						int rep = 0, nofread;
						do {
							fp = fopen("GDIbuf.dat", "rb");
							nofread = 0;
							if (fp != NULL) {
								int width, height, blockSize;
								nofread = 0;
								nofread += fread(&width, sizeof(int), 1, fp);
								nofread += fread(&height, sizeof(int), 1, fp);
								blockSize = width * height;
								if (blockSize > XRES * YRES)
									blockSize = XRES * YRES;
								nofread += fread(videoCol, sizeof(uchar)*blockSize, 1, fp);
								nofread += fread(videoChar, sizeof(uchar)*blockSize, 1, fp);
								fclose(fp);
							}
						} while (rep++ < 100 && nofread != 4 && fp != NULL);
#ifdef GDI_OUTPUT
						if (nofread == 4 || fp == NULL)
							bWriteGdiToFile = 1;
						else {
							free(averageZ); free(videoCol); free(videoChar); writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
							return 0;
						}
#endif
				}
				break;
				case 'n': bDoNothing = 1; break;
#ifdef GDI_OUTPUT
				case 'a': bAbsBitmapPos = 1; break;
				case 'U': bWindowedMode = 0; break;
#endif
				case 'f': i++; break;
				case 'B': bZBuffer = 1; break;
				case 'k': bReadKey = 1; break;
				case 'K': bWaitKey = 1; break;
				case 'u': bSendKeyUp = 1; break;
				case 'v': bUseOrigoPoly = 1; break;
				case 'V': bUseOrigoBox = 1; break;
				case 'd': bPrintFullErrorString = 1; break;

				case 'L': 
				{
					nof = sscanf(&argv[2][i+1], "%d,%d", &lightSource0Div, &lightSource0Plus);
					break;
				}

				case 'N': 
				{
					bAutoCenter3d = 1; autoScale3dScale = -1;
					if (argv[2][i+1] >= '0' && argv[2][i+1] <= '9')
						nof = sscanf(&argv[2][i+1], "%f", &autoScale3dScale);
					break;
				}
				
				case 'G': 
				{
					int GXM=256, GYM=256;
					i++;
					nof = sscanf(&argv[2][i], "%d,%d", &GXM, &GYM);
					if (nof == 2 && GXM >= 16 && GYM >= 16) { GXY_MAX_X = GXM; GXY_MAX_Y = GYM; }
					break;
				}
				case 'Z': {
					char pDepth[64];
					j = 0; i++;
					while (argv[2][i] >= '0' && argv[2][i] <= '9') pDepth[j++] = argv[2][i++];
					i--; pDepth[j] = 0;
					if (j) projectionDepth = atoi(pDepth);
					break;
				}
				case 'M': case 'm': {
					char wTime[64];
					bMouse = argv[2][i] == 'M'? 2 : 1; j = 0; i++;
					while (argv[2][i] >= '0' && argv[2][i] <= '9') wTime[j++] = argv[2][i++];
					i--; wTime[j] = 0;
					if (j) mouseWait = atoi(wTime);
					break;
				}
				case 'W': case 'w': {
					char wTime[64];
					bWait = 1; if (argv[2][i] == 'W') bWait = 2; j = 0; i++;
					while (argv[2][i] >= '0' && argv[2][i] <= '9') wTime[j++] = argv[2][i++];
					i--; wTime[j] = 0;
					if (j) waitTime = atoi(wTime);
					break;
				}
				case 'R': {
					char rotGran[64];
					j = 0; i++;
					while (argv[2][i] >= '0' && argv[2][i] <= '9') rotGran[j++] = argv[2][i++];
					i--; rotGran[j] = 0;
					if (j) rotationGranularity = atoi(rotGran);
					if (rotationGranularity < 1)rotationGranularity = 4;
					break;
				}
				case 'e': bSuppressErrors = 1; break;
				case 'E': bWaitAfterErrors = 1; break;
				case 's': bUsePerspectiveSingleCol = 1; break;
				case 'S': bServer = 1; 	remove("EL.dat"); remove("servercmd.dat"); break;
				case 'T': bAllowRepeated3dTextures = 1; break;
				case 'z': g_bSleepingWait = 1; break;
				case 'J': g_bFlushAfterELwrite = 1; break;
				case 'I': bIgnoreTitleComm = 0; break;
				case 'i': bIgnoreServerCmdFile = 1; break;
				
				case 'c': 
				{
					char *fnd, fin[64];
					int nof = 0;
					captX = 0, captY=0, captW=txres, captH=tyres, captFormat=1, bCapture = 1;
					if (argv[2][i+1] == ':' && argv[2][i+2]) {
						fnd = strchr(&argv[2][i+2], ';');
						if (!fnd) strcpy(fin, &argv[2][i+2]); else { nof = fnd-&argv[2][i+2]; strncpy(fin, &argv[2][i+2], nof); fin[nof]=0; }
						nof = sscanf(fin, "%d,%d,%d,%d,%d,%d", &captX, &captY, &captW, &captH, &captFormat, &captureCount);
					} else
						bCapture=0;
					if (nof < 3) captW = txres - captX;
					if (nof < 4) captH = tyres - captY;
					break;
				}
			}
		}
	}

	if (argc > 3)
		readPalette(argv[3], argc > 4? argv[4] : NULL, fgPalette, bgPalette, &bPaletteSet);

#ifdef _RGB32
	if (argc > 5) readOutChars(argv[5], outCh);
#endif
	
	g_videoCol = videoCol;
	g_videoChar = videoChar;

	if (bServer)
		setvbuf ( stdin , NULL , _IOLBF , 128000 );
	
	g_conin = GetInputHandle();
	g_conout = GetOutputHandle();
			
	GetConsoleMode(g_conin, &oldfdwMode);
	
#ifdef _RGB32
#ifndef GDI_OUTPUT
	GetConsoleMode(g_conout, &oldOutMode);
	outMode = oldOutMode | 0x0004; // 0x0004 = ENABLE_VIRTUAL_TERMINAL_PROCESSING
    if (!SetConsoleMode(g_conout, outMode))
        return 0;
	GetConsoleColor();
#endif
#endif
	
	
	if (bZBuffer)
		ZBufVideo = (float *) malloc(XRES * YRES * sizeof(float));
	
	/* START MAIN LOOP */ 
	strcpy(argv1, insertedArgs);
	
	if (ZBufVideo)
		memset(ZBufVideo, -99999999, sizeof(float) * XRES*YRES);
	
	do {
		rem = 0;
		retVal = 0;
		pch = strtok(argv1, "&");

		while (pch != NULL) {
			//printf ("%s\n",pch);

			while(*pch == ' ')
				pch++;

			if (strstr(pch,"rem ") == pch || rem) {
				rem = 1;
				// do nothing, skip rest
			} else if (strstr(pch,"poly ") == pch) {
				pch = pch + 5;
				nof = sscanf(pch, "%12s %12s %2s %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", 																			s_fgcol, s_bgcol, s_dchar, &vv[0].x, &vv[0].y, &vv[1].x, &vv[1].y, &vv[2].x, &vv[2].y,
																																	&vv[3].x, &vv[3].y, &vv[4].x, &vv[4].y, &vv[5].x, &vv[5].y,
																																	&vv[6].x, &vv[6].y, &vv[7].x, &vv[7].y, &vv[8].x, &vv[8].y,
																																	&vv[9].x, &vv[9].y, &vv[10].x, &vv[10].y, &vv[11].x, &vv[11].y,
																																	&vv[12].x, &vv[12].y, &vv[13].x, &vv[13].y, &vv[14].x, &vv[14].y,
																																	&vv[15].x, &vv[15].y, &vv[16].x, &vv[16].y, &vv[17].x, &vv[17].y,
																																	&vv[18].x, &vv[18].y, &vv[19].x, &vv[19].y, &vv[20].x, &vv[20].y,
																																	&vv[21].x, &vv[21].y, &vv[22].x, &vv[22].y, &vv[23].x, &vv[23].y);
				if (nof >= 9) {
					int nofp = 3 + (nof-9) / 2;
					parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
					video = videoCol;
					if (bUseOrigoPoly) makeOrigoPoly(vv, &nofp, 0);
					if (bWriteCols) scanConvex(vv, nofp, NULL, ((PREPCOL)bgcol << BITSHL) | fgcol);
					video = videoChar;
					if (bWriteChars) scanConvex(vv, nofp, NULL, dchar);
				} else
					reportArgError(&errH, OP_POLY, opCount, pch, nof);
			}
			else if (strstr(pch,"ipoly ") == pch) {
				unsigned int lfgcol, lbgcol;
				int bitOp;
				uchar inCol;
				pch = pch + 6;
				nof = sscanf(pch, "%18s %18s %2s %d %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",																				s_fgcol, s_bgcol, s_dchar, &bitOp, &vv[0].x, &vv[0].y, &vv[1].x, &vv[1].y, &vv[2].x, &vv[2].y,
																																		&vv[3].x, &vv[3].y, &vv[4].x, &vv[4].y, &vv[5].x, &vv[5].y,
																																		&vv[6].x, &vv[6].y, &vv[7].x, &vv[7].y, &vv[8].x, &vv[8].y,
																																		&vv[9].x, &vv[9].y, &vv[10].x, &vv[10].y, &vv[11].x, &vv[11].y,
																																		&vv[12].x, &vv[12].y, &vv[13].x, &vv[13].y, &vv[14].x, &vv[14].y,
																																		&vv[15].x, &vv[15].y, &vv[16].x, &vv[16].y, &vv[17].x, &vv[17].y,
																																		&vv[18].x, &vv[18].y, &vv[19].x, &vv[19].y, &vv[20].x, &vv[20].y,
																																		&vv[21].x, &vv[21].y, &vv[22].x, &vv[22].y, &vv[23].x, &vv[23].y);
				if (nof >= 10) {
					int nofp = 3 + (nof-10) / 2;
					parseInput(s_fgcol, s_bgcol, s_dchar, &lfgcol, &lbgcol, &dchar, &bWriteChars, &bWriteCols);
					video = videoCol;
					inCol = ((PREPCOL)lbgcol << BITSHL) | lfgcol;
					if (bUseOrigoPoly) makeOrigoPoly(vv, &nofp, 0);
					if (bWriteCols) scanPoly(vv, nofp, inCol, bitOp);
					video = videoChar;
					if (bWriteChars) scanPoly(vv, nofp, dchar, BIT_OP_NORMAL);
				} else
					reportArgError(&errH, OP_IPOLY, opCount, pch, nof);
			 }
		 else if (strstr(pch,"gpoly ") == pch) {
			char goraudPalette[512], gfgbg[256];
			int gValue[32], gchar[256];
			int m;

			MYMEMSET(videoTransp, TRANSPVAL, XRES*YRES);
			
			pch = pch + 6;
			nof = sscanf(pch, "%500s %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", goraudPalette,
																											&vv[0].x, &vv[0].y, &gValue[0], &vv[1].x, &vv[1].y, &gValue[1],&vv[2].x, &vv[2].y, &gValue[2],
																											&vv[3].x, &vv[3].y, &gValue[3], &vv[4].x, &vv[4].y, &gValue[4],&vv[5].x, &vv[5].y, &gValue[5], 
																											&vv[6].x, &vv[6].y, &gValue[6], &vv[7].x, &vv[7].y, &gValue[7],&vv[8].x, &vv[8].y, &gValue[8],
																											&vv[9].x, &vv[9].y, &gValue[9], &vv[10].x, &vv[10].y, &gValue[10],&vv[11].x, &vv[11].y, &gValue[11],
																											&vv[12].x, &vv[12].y, &gValue[12], &vv[13].x, &vv[13].y, &gValue[13],&vv[14].x, &vv[14].y, &gValue[14],
																											&vv[15].x, &vv[15].y, &gValue[15], &vv[16].x, &vv[16].y, &gValue[16],&vv[17].x, &vv[17].y, &gValue[17],
																											&vv[18].x, &vv[18].y, &gValue[18], &vv[19].x, &vv[19].y, &gValue[19],&vv[20].x, &vv[20].y, &gValue[20],
																											&vv[21].x, &vv[21].y, &gValue[21], &vv[22].x, &vv[22].y, &gValue[22],&vv[23].x, &vv[23].y, &gValue[23]);
			if (nof >= 10) {
				int nofp, nofc;
				nofp = 3 + (nof-10) / 3;
				
				if (bUseOrigoPoly) makeOrigoPoly(vv, &nofp, 0);
				
				nofc = (strlen(goraudPalette)+1) / 5;
				for (i = 0; i < nofc; i++) {
					if (goraudPalette[i*5+2] == '?' && goraudPalette[i*5+3] == '?')
						gchar[i] = -1;
					else
						gchar[i] = (GetHex(goraudPalette[i*5+2]) << 4) | GetHex(goraudPalette[i*5+3]);
					gfgbg[i] = (GetHex(goraudPalette[i*5+1]) << 4) | GetHex(goraudPalette[i*5]);
				}
				
				video = videoTransp;
				scanConvex_goraud(vv, nofp, NULL, &(gValue[bUseOrigoPoly]), GORAUD_TYPE_STATIC, 0, 0,0,0);
				for (i = 0; i < YRES; i++) {
					k = i*XRES;
					for (j = 0; j < XRES; j++) {
						if (videoTransp[k] != TRANSPVAL) {
							m = videoTransp[k] % nofc;
#ifndef _RGB32
							videoCol[k] = gfgbg[m];
#else
							videoCol[k] = (((PREPCOL)g_rgbBgPalette[(gfgbg[m]>>4)]) << BITSHL) | g_rgbFgPalette[(gfgbg[m] & 0xf)];
#endif
							if (gchar[m] != -1) videoChar[k] = gchar[m];
						}
						k++;
					}
				}
			} else
				reportArgError(&errH, OP_GPOLY, opCount, pch, nof);
		 }
		 else if (strstr(pch,"tpoly ") == pch) {
			int bIgnoreFgCol=0, bIgnoreBgCol=0, bIgnoreAllCodes=0;
			int nofp, w,h;
			Bitmap b_cols, b_chars;
			
			pch = pch + 6;
			nof = sscanf(pch, "%128s %13s %13s %2s %13s %d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f", fname, s_fgcol, s_bgcol, s_dchar, s_transpval, 
																			&vv[0].x, &vv[0].y, &vv[0].tex_coord.x, &vv[0].tex_coord.y, &vv[1].x, &vv[1].y, &vv[1].tex_coord.x, &vv[1].tex_coord.y,
																			&vv[2].x, &vv[2].y, &vv[2].tex_coord.x, &vv[2].tex_coord.y, &vv[3].x, &vv[3].y, &vv[3].tex_coord.x, &vv[3].tex_coord.y,
																			&vv[4].x, &vv[4].y, &vv[4].tex_coord.x, &vv[4].tex_coord.y, &vv[5].x, &vv[5].y, &vv[5].tex_coord.x, &vv[5].tex_coord.y,
																			&vv[6].x, &vv[6].y, &vv[6].tex_coord.x, &vv[6].tex_coord.y, &vv[7].x, &vv[7].y, &vv[7].tex_coord.x, &vv[7].tex_coord.y,
																			&vv[8].x, &vv[8].y, &vv[8].tex_coord.x, &vv[8].tex_coord.y, &vv[9].x, &vv[8].y, &vv[9].tex_coord.x, &vv[9].tex_coord.y,
																			&vv[10].x, &vv[10].y, &vv[10].tex_coord.x, &vv[10].tex_coord.y, &vv[11].x, &vv[11].y, &vv[11].tex_coord.x, &vv[11].tex_coord.y,
																			&vv[12].x, &vv[12].y, &vv[12].tex_coord.x, &vv[12].tex_coord.y, &vv[13].x, &vv[13].y, &vv[13].tex_coord.x, &vv[13].tex_coord.y,
																			&vv[14].x, &vv[14].y, &vv[14].tex_coord.x, &vv[14].tex_coord.y, &vv[15].x, &vv[15].y, &vv[15].tex_coord.x, &vv[15].tex_coord.y,
																			&vv[16].x, &vv[16].y, &vv[16].tex_coord.x, &vv[16].tex_coord.y, &vv[17].x, &vv[17].y, &vv[17].tex_coord.x, &vv[17].tex_coord.y,
																			&vv[18].x, &vv[18].y, &vv[18].tex_coord.x, &vv[18].tex_coord.y, &vv[19].x, &vv[19].y, &vv[19].tex_coord.x, &vv[19].tex_coord.y,
																			&vv[20].x, &vv[20].y, &vv[10].tex_coord.x, &vv[20].tex_coord.y, &vv[21].x, &vv[21].y, &vv[11].tex_coord.x, &vv[21].tex_coord.y,
																			&vv[22].x, &vv[22].y, &vv[12].tex_coord.x, &vv[22].tex_coord.y, &vv[23].x, &vv[23].y, &vv[13].tex_coord.x, &vv[23].tex_coord.y);
			if (nof >= 17) {
				nofp = 3 + (nof-17) / 4;
				
				if (s_fgcol[0] == '\\') { bIgnoreAllCodes=1; s_fgcol[0]=s_fgcol[1]; s_fgcol[1]=s_fgcol[2]; s_fgcol[2]=0; }
				else if (s_fgcol[0] == '-') { bIgnoreFgCol=1; s_fgcol[0]=s_fgcol[1]; s_fgcol[1]=s_fgcol[2]; s_fgcol[2]=0; }
				if (s_bgcol[0] == '-') { bIgnoreBgCol=1; s_bgcol[0]=s_bgcol[1]; s_bgcol[1]=s_bgcol[2]; s_bgcol[2]=0; }
				
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);

				transformFilenameSpaces(fname);
				
				if (bUseOrigoPoly) makeOrigoPoly(vv, &nofp, 1);

				if (strstr(fname,".pcx")) {
					if (b_pcx.data) { free(b_pcx.data); b_pcx.data = NULL; }
					if (PCXload (&b_pcx,fname)) {
						parseInput(s_transpval, s_bgcol, s_dchar, &transpval, &bgcol, &dchar, NULL, NULL);
#ifdef _RGB32
						if(s_fgcol[0] == '0' && s_fgcol[1] == 0) fgcol = 0;
						if(s_bgcol[0] == '0' && s_bgcol[1] == 0) bgcol = 0;

						if(atoi(s_transpval) == -1)
							transpval = -1;
						
						for(int tpi = 0; tpi < b_pcx.xSize*b_pcx.ySize; tpi++)
							b_pcx.data[tpi] = g_rgbFgPalette[b_pcx.data[tpi]] & 0xffffff;
#endif						
						if (transpval < 0) {
							video = videoCol;
							if (bWriteCols) scanConvex_tmap(vv, nofp, NULL, &b_pcx, ((PREPCOL)bgcol<<BITSHL) | fgcol, 0);
							video = videoChar;
							if (bWriteChars) scanConvex(vv, nofp, NULL, dchar);
						} else {
							drawTranspTPoly(videoTransp, videoCol, videoChar, transpval, dchar, bWriteChars, bWriteCols, vv, nofp, &b_pcx, ((PREPCOL)bgcol<<BITSHL) | fgcol, 0);
						}
					} else
						reportFileError(&errH, OP_TPOLY, ERR_IMAGE_LOAD, opCount, fname, NULL);
#ifdef _RGB32

				} else if (strstr(fname,".bmp")) {
					
					if (b_pcx.data) { free(b_pcx.data); b_pcx.data = NULL; }
					if (BMPload (&b_pcx,fname)) {
						parseInput(s_transpval, s_bgcol, s_dchar, &transpval, &bgcol, &dchar, NULL, NULL);

						if(s_fgcol[0] == '0' && s_fgcol[1] == 0) fgcol = 0;
						if(s_bgcol[0] == '0' && s_bgcol[1] == 0) bgcol = 0;

						if(atoi(s_transpval) == -1)
							transpval = -1;
						
						if (transpval < 0) {
							video = videoCol;
							if (bWriteCols) scanConvex_tmap(vv, nofp, NULL, &b_pcx, ((PREPCOL)bgcol<<BITSHL) | fgcol, 0);
							video = videoChar;
							if (bWriteChars) scanConvex(vv, nofp, NULL, dchar);
						} else {
							drawTranspTPoly(videoTransp, videoCol, videoChar, transpval, dchar, bWriteChars, bWriteCols, vv, nofp, &b_pcx, ((PREPCOL)bgcol<<BITSHL) | fgcol, 0);
						}
					} else
						reportFileError(&errH, OP_TPOLY, ERR_IMAGE_LOAD, opCount, fname, NULL);
					
				} else if (strstr(fname,".bxy")) {
					
					if (b_pcx.data) { free(b_pcx.data); b_pcx.data = NULL; }
					if (BXYload (&b_cols, &b_chars, fname)) {
						parseInput(s_fgcol, s_bgcol, s_transpval, &fgcol, &bgcol, &transpval, NULL, NULL);

						if(s_fgcol[0] == '0' && s_fgcol[1] == 0) fgcol = 0;
						if(s_bgcol[0] == '0' && s_bgcol[1] == 0) bgcol = 0;

						if(atoi(s_transpval) == -1)
							transpval = -1;
						
						if (transpval < 0) {
							video = videoCol;
							if (bWriteCols) scanConvex_tmap(vv, nofp, NULL, &b_cols, ((PREPCOL)bgcol<<BITSHL) | fgcol, 0);
							video = videoChar;
							if (bWriteChars) scanConvex_tmap(vv, nofp, NULL, &b_chars, 0, 0);
						} else {
							drawTranspTDoublePoly(videoTransp, videoTranspChar, videoCol, videoChar, transpval, bWriteChars, bWriteCols, vv, nofp, &b_cols, ((PREPCOL)bgcol<<BITSHL) | fgcol, 0, &b_chars);
						}
					} else
						reportFileError(&errH, OP_TPOLY, ERR_IMAGE_LOAD, opCount, fname, NULL);
					
#endif						
				} else {
					if (readGxy(fname, &b_cols, &b_chars, &w, &h, 0, dchar, 1, bIgnoreFgCol, bIgnoreBgCol, bIgnoreAllCodes)) {
						parseInput(s_fgcol, s_bgcol, s_transpval, &fgcol, &bgcol, &transpval, NULL, NULL);
#ifdef _RGB32
						if(s_fgcol[0] == '0' && s_fgcol[1] == 0) fgcol = 0;
						if(s_bgcol[0] == '0' && s_bgcol[1] == 0) bgcol = 0;
#endif						
						if (transpval < 0) {
							video = videoCol;
							if (bWriteCols) scanConvex_tmap(vv, nofp, NULL, &b_cols, ((PREPCOL)bgcol<<BITSHL) | fgcol, 0);
							video = videoChar;
							if (bWriteChars) scanConvex_tmap(vv, nofp, NULL, &b_chars, 0, 0);
						} else {
							drawTranspTDoublePoly(videoTransp, videoTranspChar, videoCol, videoChar, transpval, bWriteChars, bWriteCols, vv, nofp, &b_cols, ((PREPCOL)bgcol<<BITSHL) | fgcol, 0, &b_chars);
							
						}
						free(b_chars.data);
						free(b_cols.data);
					} else
						reportFileError(&errH, OP_TPOLY, ERR_IMAGE_LOAD, opCount, fname, NULL);
				}
			} else
				reportArgError(&errH, OP_TPOLY, opCount, pch, nof);
		 }
		 else if (strstr(pch,"fcircle ") == pch) {
			int rc,xc,yc;
			pch = pch + 8;
			nof = sscanf(pch, "%12s %12s %2s %d,%d,%d", s_fgcol, s_bgcol, s_dchar, &xc, &yc, &rc);

			if (nof == 6) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) filled_circle(xc, yc, rc, ((PREPCOL)bgcol << BITSHL) | fgcol);
				video = videoChar;
				if (bWriteChars) filled_circle(xc, yc, rc, dchar);
			} else
				reportArgError(&errH, OP_FCIRCLE, opCount, pch, nof);
		}
		else if (strstr(pch,"circle ") == pch) {
			int rc,xc,yc;
			pch = pch + 7;
			nof = sscanf(pch, "%12s %12s %2s %d,%d,%d", s_fgcol, s_bgcol, s_dchar, &xc, &yc, &rc);

			if (nof == 6) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) circle(xc, yc, rc, ((PREPCOL)bgcol << BITSHL) | fgcol);
				video = videoChar;
				if (bWriteChars) circle(xc, yc, rc, dchar);
			} else
				reportArgError(&errH, OP_CIRCLE, opCount, pch, nof);
		}
		else if (strstr(pch,"fellipse ") == pch) {
			int rcx,rcy,xc,yc;
			pch = pch + 9;
			nof = sscanf(pch, "%12s %12s %2s %d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &xc, &yc, &rcx, &rcy);

			if (nof == 7) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) filled_ellipse(xc, yc, rcx, rcy, ((PREPCOL)bgcol << BITSHL) | fgcol);
				video = videoChar;
				if (bWriteChars) filled_ellipse(xc, yc, rcx, rcy, dchar);
			} else
				reportArgError(&errH, OP_FELLIPSE, opCount, pch, nof);
		}
		else if (strstr(pch,"ellipse ") == pch) {
			int rcx,rcy,xc,yc;
			pch = pch + 8;
			nof = sscanf(pch, "%12s %12s %2s %d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &xc, &yc, &rcx, &rcy);

			if (nof == 7) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) ellipse(xc, yc, rcx, rcy, ((PREPCOL)bgcol << BITSHL) | fgcol);
				video = videoChar;
				if (bWriteChars) ellipse(xc, yc, rcx, rcy, dchar);
			} else
				reportArgError(&errH, OP_ELLIPSE, opCount, pch, nof);
		 }
		 else if (strstr(pch,"line ") == pch) {
			int x1,y1,x2,y2;
			int xPoints[9], yPoints[9];
			pch = pch + 5;
			nof = sscanf(pch, "%12s %12s %2s %d,%d,%d,%d %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &x1, &y1, &x2, &y2,
																													&xPoints[1], &yPoints[1], &xPoints[2], &yPoints[2], &xPoints[3], &yPoints[3],
																													&xPoints[4], &yPoints[4], &xPoints[5], &yPoints[5], &xPoints[6], &yPoints[6]);
			if (nof == 7) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) line(x1, y1, x2, y2, ((PREPCOL)bgcol << BITSHL) | fgcol, 1);
				video = videoChar;
				if (bWriteChars) line(x1, y1, x2, y2, dchar, 1);
			} else
				if (nof >= 9) {
					int nofP = 2 + (nof-7)/2;
					xPoints[0] = x1; yPoints[0] = y1;
					xPoints[nofP-1] = x2; yPoints[nofP-1] = y2;
		
					parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
					video = videoCol;
					if (bWriteCols) bezier(nofP-1, xPoints, yPoints, ((PREPCOL)bgcol << BITSHL) | fgcol);
					video = videoChar;
					if (bWriteChars) bezier(nofP-1, xPoints, yPoints, dchar);
				} else 
					reportArgError(&errH, OP_LINE, opCount, pch, nof);
		 }
		 else if (strstr(pch,"pixel ") == pch) {
			int x1,y1;
			pch = pch + 6;
			nof = sscanf(pch, "%12s %12s %2s %d,%d", s_fgcol, s_bgcol, s_dchar, &x1, &y1);

			if (nof == 5) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) setpixel(x1, y1, ((PREPCOL)bgcol << BITSHL) | fgcol);
				video = videoChar;
				if (bWriteChars) setpixel(x1, y1, dchar);
			} else
				reportArgError(&errH, OP_PIXEL, opCount, pch, nof);
		 }
		 else if (strstr(pch,"text ") == pch) {
			Bitmap b_cols, b_chars;
			char tstring[12096], *tsfgc=s_fgcol, *tsbgc=s_bgcol;
			int x1,y1,w1,h1,xb,xdb,res;
			int writeCols;
			int bIgnoreFgCol=0, bIgnoreBgCol=0, bIgnoreAllCodes=0, bRemoveAllCodes = 0;
			pch = pch + 5;
			nof = sscanf(pch, "%13s %13s %2s %12090s %d,%d", s_fgcol, s_bgcol, s_dchar, tstring, &x1, &y1);

			if (nof == 6) {
				if (s_fgcol[0] == '\\') { bIgnoreAllCodes=1; tsfgc++; }
				else if (s_fgcol[0] == '/') { bRemoveAllCodes=1; tsfgc++; }
				else if (s_fgcol[0] == '-') { bIgnoreFgCol=1; tsfgc++; }
				if (s_bgcol[0] == '-') { bIgnoreBgCol=1; tsbgc++; }
				writeCols = parseInput(tsfgc, tsbgc, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);

				b_cols.data = b_chars.data = NULL;
				for (i = 0; i < strlen(tstring); i++)
					if (tstring[i] == '_') tstring[i] = ' ';
				
				if (bServer) {
					char *fndFrame = strstr(tstring, "[FRAMECOUNT]");
					if (fndFrame) {
						char FCT[64];
						int FPS = 0;
						float elapsedS = (float)(milliseconds_now() - startT) / (float)1000;
						if (elapsedS > 0)
							FPS = (float)frameCounter / elapsedS;
						
						sprintf(FCT, "%d (%d)", frameCounter, FPS);
						for (j = 0; j < 12; j++) {
							if (j < strlen(FCT))
								fndFrame[j] = FCT[j];
							else
								fndFrame[j] = ' ';
						}
						
					}
				}
				
				if (bRemoveAllCodes) RemoveGxyCodes(tstring, 1);
				
				res = readGxy(tstring, &b_cols, &b_chars, &w1, &h1, (((PREPCOL)bgcol << BITSHL) | fgcol), -1, 0, bIgnoreFgCol, bIgnoreBgCol, bIgnoreAllCodes);

				if (res) {
					for (j=0; j < h1; j++) {
						if (y1+j < YRES && y1+j >= 0) {
							xb = y1*XRES + x1 + j*XRES;
							xdb = j*w1;
							for (i=0; i < w1; i++) {
								if (x1 + i < XRES && x1 + i >= 0 && b_chars.data[xdb] != TRANSPVAL) { 
									if (writeCols == 3) videoCol[xb + i] = b_cols.data[xdb];
									else if (writeCols == 1) videoCol[xb + i] = (videoCol[xb + i] & BG_AND_MASK) | (b_cols.data[xdb] & AND_MASK);
									else if (writeCols == 2) videoCol[xb + i] = (videoCol[xb + i] & AND_MASK) | (b_cols.data[xdb] & BG_AND_MASK);
									if (bWriteChars) videoChar[xb + i] = b_chars.data[xdb];
								}
								xdb+=1;
							}
						}
					}

					if (b_cols.data) free(b_cols.data); 
					if (b_chars.data) free(b_chars.data); 
				}
			} else
				reportArgError(&errH, OP_TEXT, opCount, pch, nof);
		 }
		 else if (strstr(pch,"image ") == pch) {
			int bIgnoreFgCol=0, bIgnoreBgCol=0, bIgnoreAllCodes=0, bRemoveAllCodes=0;
			int x1,y1,w1,h1, res, xflip=0, yflip=0, xb, xdb, xdir=1, w2=-1, h2=-1, writeCols;
			Bitmap b_cols, b_chars;
			char *tsfgc=s_fgcol, *tsbgc=s_bgcol;
			b_cols.data = b_chars.data = NULL;

			pch = pch + 6;
			nof = sscanf(pch, "%127s %13s %13s %2s %13s %d,%d %d %d %d,%d", fname, s_fgcol, s_bgcol, s_dchar, s_transpval, &x1, &y1, &xflip, &yflip, &w2, &h2);
			if (xflip) xdir = -1;
			if (nof >= 7) {
				transformFilenameSpaces(fname);
				if (s_fgcol[0] == '\\') { bIgnoreAllCodes=1; tsfgc++; }
				else if (s_fgcol[0] == '-') { bIgnoreFgCol=1; tsfgc++; }
				if (s_bgcol[0] == '-') { bIgnoreBgCol=1; tsbgc++; }
				writeCols = parseInput(tsfgc, tsbgc, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				if (strstr(fname, ".pcx")){
					parseInput(s_transpval, tsbgc, s_dchar, &transpval, &bgcol, &dchar, NULL, NULL);
#ifdef _RGB32							
					if(atoi(s_transpval) == -1)
						transpval = -1;
#endif							
					res = PCXload (&b_cols,fname);
					if (res) {
						b_chars.data = (uchar *) malloc(b_cols.xSize*b_cols.ySize*sizeof(uchar));
						if (!b_chars.data) {
							free(b_cols.data);
							res = 0;
						} else {
							for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
								b_chars.data[i] = b_cols.data[i] == transpval? TRANSPVAL : dchar;
							}
							if (bIgnoreFgCol) {
								for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
									b_cols.data[i] = fgcol;
								}
							}
#ifdef _RGB32							
							else 
								for(i = 0; i < b_cols.xSize*b_cols.ySize; i++)
									b_cols.data[i] = g_rgbFgPalette[b_cols.data[i]] & 0xffffff;
							for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
								b_chars.data[i] = b_cols.data[i] == transpval? TRANSPVAL : dchar;
							}
#endif							
							
							if (bgcol > 0) {
								uchar bgc = (PREPCOL)bgcol << BITSHL;
								for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
									b_cols.data[i] |= bgc;
								}
							}
							w1 = b_cols.xSize; h1 = b_cols.ySize;
							dchar = TRANSPVAL;
						}
					} else
						reportFileError(&errH, OP_IMAGE, ERR_IMAGE_LOAD, opCount, fname, NULL);
#ifdef _RGB32					
				} else if (strstr(fname, ".bmp")) {

					parseInput(s_transpval, s_bgcol, s_dchar, &transpval, &bgcol, &dchar, NULL, NULL);
					if(atoi(s_transpval) == -1)
						transpval = -1;

					res = BMPload (&b_cols,fname);
					if (res) {
						b_chars.data = (uchar *) malloc(b_cols.xSize*b_cols.ySize*sizeof(uchar));
						if (!b_chars.data) {
							free(b_cols.data);
							res = 0;
						} else {
							for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
								b_chars.data[i] = b_cols.data[i] == transpval? TRANSPVAL : dchar;
							}
							if (bIgnoreFgCol) {
								for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
									b_cols.data[i] = fgcol;
								}
							}
							
							if (bgcol > 0) {
								uchar bgc = (PREPCOL)bgcol << BITSHL;
								for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
									b_cols.data[i] |= bgc;
								}
							}
							w1 = b_cols.xSize; h1 = b_cols.ySize;
							dchar = TRANSPVAL;
						}
					} else
						reportFileError(&errH, OP_IMAGE, ERR_IMAGE_LOAD, opCount, fname, NULL);
				
				} else if (strstr(fname, ".bxy")) {

					parseInput(tsfgc, tsbgc, s_transpval, &fgcol, &bgcol, &transpval, NULL, NULL);
					if(atoi(s_transpval) == -1)
						transpval = -1;

					res = BXYload (&b_cols, &b_chars, fname);
					if (res) {
						
						if (bIgnoreFgCol) {
							for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
								b_cols.data[i] = (b_cols.data[i] & BG_AND_MASK) | fgcol;
							}
						}
						if (bIgnoreBgCol) {
							for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
								b_cols.data[i] = (b_cols.data[i] & AND_MASK) | ((PREPCOL)bgcol << BITSHL);
							}
						}
						
						w1 = b_cols.xSize; h1 = b_cols.ySize;
						dchar = TRANSPVAL;
					} else
						reportFileError(&errH, OP_IMAGE, ERR_IMAGE_LOAD, opCount, fname, NULL);
#endif					
				} else {
					parseInput(tsfgc, tsbgc, s_transpval, &fgcol, &bgcol, &transpval, NULL, NULL);
					res = readGxy(fname, &b_cols, &b_chars, &w1, &h1, (((PREPCOL)bgcol << BITSHL) | fgcol), dchar, 1, bIgnoreFgCol, bIgnoreBgCol, bIgnoreAllCodes);
					if (!res) reportFileError(&errH, OP_IMAGE, ERR_IMAGE_LOAD, opCount, fname, NULL);
				}
				
				if (res) {
					if (w2 == -1 && h2 == -1) {
						for (j=0; j < h1; j++) {
							if (y1+j < YRES && y1+j >= 0) {
								xb = y1*XRES + x1 + j*XRES;
								xdb = (yflip? (h1-1-j)*w1 : j*w1); 
								xdb += (xflip? w1-1 : 0);
								for (i=0; i < w1; i++) {
									if (x1 + i < XRES && x1 + i >= 0 && b_chars.data[xdb] != TRANSPVAL && b_chars.data[xdb] != transpval) {
										if (writeCols == 3) videoCol[xb + i] = b_cols.data[xdb];
										else if (writeCols == 1) videoCol[xb + i] = (videoCol[xb + i] & BG_AND_MASK) | (b_cols.data[xdb] & AND_MASK);
										else if (writeCols == 2) videoCol[xb + i] = (videoCol[xb + i] & AND_MASK) | (b_cols.data[xdb] & BG_AND_MASK);
										if (bWriteChars) videoChar[xb + i] = b_chars.data[xdb];
									}
									xdb+=xdir;
								}
							}
						}
					} else { // stretched
						if (w2 <= 0 || h2 <= 0)
							reportArgError(&errH, OP_IMAGE, opCount, pch, w2<=0? 9 : 10);
						else {
							float xdbf, xdirf, ydbf = 0, ydirf;
							xdirf = (float)w1 / (float)w2;
							if (xflip) xdirf = -xdirf;
							ydirf = (float)h1 / (float)h2;
							if (yflip) { ydirf = -ydirf; ydbf = h1-1; }
							
							for (j=0; j < h2; j++) {
								if (y1+j < YRES && y1+j >= 0) {
									xb = y1*XRES + x1 + j*XRES;
									xdbf = ((int)ydbf) * w1; 
									xdbf += (xflip? w1-0.01 : 0);
									for (i=0; i < w2; i++) {
										xdb = xdbf;
										if (x1 + i < XRES && x1 + i >= 0 && b_chars.data[xdb] != TRANSPVAL && b_chars.data[xdb] != transpval) {
											if (writeCols == 3) videoCol[xb + i] = b_cols.data[xdb];
											else if (writeCols == 1) videoCol[xb + i] = (videoCol[xb + i] & BG_AND_MASK) | (b_cols.data[xdb] & AND_MASK);
											else if (writeCols == 2) videoCol[xb + i] = (videoCol[xb + i] & AND_MASK) | (b_cols.data[xdb] & BG_AND_MASK);
											if (bWriteChars) videoChar[xb + i] = b_chars.data[xdb];
										}
										xdbf+=xdirf;
									}
								}
								ydbf+=ydirf;
							}
						}
					}
				}
				
				if (b_cols.data) free(b_cols.data); 
				if (b_chars.data) free(b_chars.data);

			} else
				reportArgError(&errH, OP_IMAGE, opCount, pch, nof);
		 }
		 else if (strstr(pch,"box ") == pch) {
			int x1,y1,w,h;
			pch = pch + 4;
			nof = sscanf(pch, "%12s %12s %2s %d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &x1, &y1, &w, &h);

			if (nof == 7) {
				
				if (bUseOrigoBox){ x1-=w/2; y1-=h/2; }
				
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) box(x1, y1, w, h, ((PREPCOL)bgcol << BITSHL) | fgcol);
				video = videoChar;
				if (bWriteChars) box(x1, y1, w, h, dchar);
			} else
				reportArgError(&errH, OP_BOX, opCount, pch, nof);
		 }
		 else if (strstr(pch,"fbox ") == pch) {
			int x1,y1,w,h;
			pch = pch + 5;
			nof = sscanf(pch, "%12s %12s %2s %d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &x1, &y1, &w, &h);

			if (nof == 7 || nof == 3) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				
				if (nof == 3) { x1=y1=0; w=txres; h=tyres; } else { if (bUseOrigoBox){ x1-=w/2; y1-=h/2; } }
				
				if (bWriteCols) fbox(x1, y1, w, h, ((PREPCOL)bgcol << BITSHL) | fgcol);
				video = videoChar;
				if (bWriteChars) fbox(x1, y1, w, h, dchar);
			} else
				reportArgError(&errH, OP_FBOX, opCount, pch, nof);
		 }
		 else if (strstr(pch,"block ") == pch) {	
			int x1,y1,w,h, nx,ny,nw=-1,nh=-1, rz=0, xFlip = 0, yFlip = 0;
			int mvx=-1, mvy=-1, mvw=-1, mvh=-1;
			char transf[2510]= {0}, mode[16], colorExpr[8024] = {0}, xExpr[8024] = {0}, yExpr[8024] = {0}, xyExprToCh[16] = {0}, nys[64] = {0};

			pch = pch + 6;
			nof = sscanf(pch, "%14s %d,%d,%d,%d %d,%60s %13s %d %d %2500s %8022s %8022s %8022s %10s %d,%d,%d,%d", mode, &x1, &y1, &w, &h, &nx, &nys, s_transpval, &xFlip, &yFlip, transf, colorExpr, xExpr, yExpr, xyExprToCh, &mvx, &mvy, &mvw, &mvh);
			
			transpval = -1;
			if (nof >= 7) {
				g_errH = &errH; g_opCount = opCount;
				nof=sscanf(nys, "%d,%d,%d,%d", &ny, &nw, &nh, &rz);
				if (nof > 0) {
					if (mode[0] == '2' || mode[0] == '3')
						parseInput(s_transpval, "0", "0", &transpval, &fgcol, &bgcol, NULL, NULL);
					else
						parseInput("0", "0", s_transpval, &fgcol, &bgcol, &transpval, NULL, NULL);
					transformBlock(mode, x1, y1, w, h, nx, ny, nw, nh, rz, transf, colorExpr, xExpr, yExpr, XRES, YRES, videoCol, videoChar, transpval, xFlip, yFlip, xyExprToCh[0] != 'f', mvx, mvy, mvw, mvh);
				} else
					reportArgError(&errH, OP_BLOCK, opCount, pch, 7);
			} else
				reportArgError(&errH, OP_BLOCK, opCount, pch, nof);
		 }
		 else if (strstr(pch,"3d ") == pch) {
			obj3d *obj3 = NULL;
			int culling = 1, z_culling_near = 0, z_culling_far = 0;
			float scalex, scaley, scalez, modx, mody, modz, postmodx, postmody, postmodz, postmodx2 = 0, postmody2 = 0, postmodz2 = 0;
			int drawmode, drawoption;
			char s_fgcols[34][64], s_bgcols[34][10], s_dchars[34][4], drawOpS[128];
			int nofcols, nof_ext;
			int l,colIndex=0, nofFacePoints, bDrawPerspective;
			int divZ, plusZ, z_levels;;
			uchar pfgbg[64], fgbg;
			int m, pchar[64], pbWriteChars[64], pbWriteCols[64];
			Bitmap *paletteBmap = NULL, *bmap = NULL;
			int rx,ry,rz;
			float rrx,rry,rrz;
			int rx2=0,ry2=0,rz2=0;
			float rrx2=0,rry2=0,rrz2=0;
			int xg, yg, dist = 5500;
			float aspect;
			int tex_offset_x = 0, tex_offset_y = 0;
			int tex_mod_x = 100000, tex_mod_y = 100000, tex_add_x = 0, tex_add_y = 0;
			int bSkipZsort = 0, oldZL, negZAdd = 0;

			pch = pch + 3;

			nof = sscanf(pch, "%128s %d,%120s %d:%d,%d:%d,%d:%d %f:%f,%f:%f,%f:%f %f,%f,%f,%f,%f,%f %d,%d,%d,%d %d,%d,%d,%f %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s", fname, &drawmode,drawOpS,&rx,&rx2,&ry,&ry2,&rz,&rz2,&postmodx,&postmodx2,&postmody,&postmody2,&postmodz,&postmodz2,&scalex,&scaley,&scalez,&modx,&mody,&modz,&culling,&z_culling_near,&z_culling_far,&z_levels,&xg,&yg,&dist,&aspect,
																				s_fgcols[0], s_bgcols[0], s_dchars[0],	s_fgcols[1], s_bgcols[1], s_dchars[1], s_fgcols[2], s_bgcols[2], s_dchars[2],
																				s_fgcols[3], s_bgcols[3], s_dchars[3], s_fgcols[4], s_bgcols[4], s_dchars[4], s_fgcols[5], s_bgcols[5], s_dchars[5],
																				s_fgcols[6], s_bgcols[6], s_dchars[6], s_fgcols[7], s_bgcols[7], s_dchars[7],	s_fgcols[8], s_bgcols[8], s_dchars[8],
																				s_fgcols[9], s_bgcols[9], s_dchars[9],	s_fgcols[10], s_bgcols[10], s_dchars[10],	s_fgcols[11], s_bgcols[11], s_dchars[11],
																				s_fgcols[12], s_bgcols[12], s_dchars[12],	s_fgcols[13], s_bgcols[13], s_dchars[13],	s_fgcols[14], s_bgcols[14], s_dchars[14],
																				s_fgcols[15], s_bgcols[15], s_dchars[15], s_fgcols[16], s_bgcols[16], s_dchars[16], s_fgcols[17], s_bgcols[17], s_dchars[17],
																				s_fgcols[18], s_bgcols[18], s_dchars[18],	s_fgcols[19], s_bgcols[19], s_dchars[19], s_fgcols[20], s_bgcols[20], s_dchars[20],
																				s_fgcols[21], s_bgcols[21], s_dchars[21], s_fgcols[22], s_bgcols[22], s_dchars[22], s_fgcols[23], s_bgcols[23], s_dchars[23],
																				s_fgcols[24], s_bgcols[24], s_dchars[24], s_fgcols[25], s_bgcols[25], s_dchars[25], s_fgcols[26], s_bgcols[26], s_dchars[26],
																				s_fgcols[27], s_bgcols[27], s_dchars[27], s_fgcols[28], s_bgcols[28], s_dchars[28], s_fgcols[29], s_bgcols[29], s_dchars[29],
																				s_fgcols[30], s_bgcols[30], s_dchars[30], s_fgcols[31], s_bgcols[31], s_dchars[31] );
			if (nof >= 32) {
				nof -= 6;
			} else {
				
				postmodx2 = postmody2 = postmodz2 = 0;
				
				// name drawmode,option rx:rx2,ry:ry2,rz:rz2 postmodx,pmody,pmodz scalex,scaley,scalez,modx,mody,modz,backface_cull,z_cull_near_z_cull_far,z_levels xg,yg,dist,aspect colors...
				nof = sscanf(pch, "%128s %d,%60s %d:%d,%d:%d,%d:%d %f,%f,%f %f,%f,%f,%f,%f,%f %d,%d,%d,%d %d,%d,%d,%f %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s", fname, &drawmode,drawOpS,&rx,&rx2,&ry,&ry2,&rz,&rz2,&postmodx,&postmody,&postmodz,&scalex,&scaley,&scalez,&modx,&mody,&modz,&culling,&z_culling_near,&z_culling_far,&z_levels,&xg,&yg,&dist,&aspect,
																					s_fgcols[0], s_bgcols[0], s_dchars[0],	s_fgcols[1], s_bgcols[1], s_dchars[1], s_fgcols[2], s_bgcols[2], s_dchars[2],
																					s_fgcols[3], s_bgcols[3], s_dchars[3], s_fgcols[4], s_bgcols[4], s_dchars[4], s_fgcols[5], s_bgcols[5], s_dchars[5],
																					s_fgcols[6], s_bgcols[6], s_dchars[6], s_fgcols[7], s_bgcols[7], s_dchars[7],	s_fgcols[8], s_bgcols[8], s_dchars[8],
																					s_fgcols[9], s_bgcols[9], s_dchars[9],	s_fgcols[10], s_bgcols[10], s_dchars[10],	s_fgcols[11], s_bgcols[11], s_dchars[11],
																					s_fgcols[12], s_bgcols[12], s_dchars[12],	s_fgcols[13], s_bgcols[13], s_dchars[13],	s_fgcols[14], s_bgcols[14], s_dchars[14],
																					s_fgcols[15], s_bgcols[15], s_dchars[15], s_fgcols[16], s_bgcols[16], s_dchars[16], s_fgcols[17], s_bgcols[17], s_dchars[17],
																					s_fgcols[18], s_bgcols[18], s_dchars[18],	s_fgcols[19], s_bgcols[19], s_dchars[19], s_fgcols[20], s_bgcols[20], s_dchars[20],
																					s_fgcols[21], s_bgcols[21], s_dchars[21], s_fgcols[22], s_bgcols[22], s_dchars[22], s_fgcols[23], s_bgcols[23], s_dchars[23],
																					s_fgcols[24], s_bgcols[24], s_dchars[24], s_fgcols[25], s_bgcols[25], s_dchars[25], s_fgcols[26], s_bgcols[26], s_dchars[26],
																					s_fgcols[27], s_bgcols[27], s_dchars[27], s_fgcols[28], s_bgcols[28], s_dchars[28], s_fgcols[29], s_bgcols[29], s_dchars[29],
																					s_fgcols[30], s_bgcols[30], s_dchars[30], s_fgcols[31], s_bgcols[31], s_dchars[31] );
				if (nof >= 29) {
					nof -= 3;
				} else {
					// name drawmode,option rx,ry,rz postmodx,postmody,postmodz scalex,scaley,scalez,modx,mody,modz,backface_cull,z_cull_near_z_cull_far,z_levels xg,yg,dist,aspect colors...
					nof = sscanf(pch, "%128s %d,%60s %d,%d,%d %f,%f,%f %f,%f,%f,%f,%f,%f %d,%d,%d,%d %d,%d,%d,%f %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s %62s %8s %2s", fname, &drawmode,drawOpS,&rx,&ry,&rz,&postmodx,&postmody,&postmodz,&scalex,&scaley,&scalez,&modx,&mody,&modz,&culling,&z_culling_near,&z_culling_far,&z_levels,&xg,&yg,&dist,&aspect,
																				s_fgcols[0], s_bgcols[0], s_dchars[0],	s_fgcols[1], s_bgcols[1], s_dchars[1], s_fgcols[2], s_bgcols[2], s_dchars[2],
																				s_fgcols[3], s_bgcols[3], s_dchars[3], s_fgcols[4], s_bgcols[4], s_dchars[4], s_fgcols[5], s_bgcols[5], s_dchars[5],
																				s_fgcols[6], s_bgcols[6], s_dchars[6], s_fgcols[7], s_bgcols[7], s_dchars[7],	s_fgcols[8], s_bgcols[8], s_dchars[8],
																				s_fgcols[9], s_bgcols[9], s_dchars[9],	s_fgcols[10], s_bgcols[10], s_dchars[10],	s_fgcols[11], s_bgcols[11], s_dchars[11],
																				s_fgcols[12], s_bgcols[12], s_dchars[12],	s_fgcols[13], s_bgcols[13], s_dchars[13],	s_fgcols[14], s_bgcols[14], s_dchars[14],
																				s_fgcols[15], s_bgcols[15], s_dchars[15], s_fgcols[16], s_bgcols[16], s_dchars[16], s_fgcols[17], s_bgcols[17], s_dchars[17],
																				s_fgcols[18], s_bgcols[18], s_dchars[18],	s_fgcols[19], s_bgcols[19], s_dchars[19], s_fgcols[20], s_bgcols[20], s_dchars[20],
																				s_fgcols[21], s_bgcols[21], s_dchars[21], s_fgcols[22], s_bgcols[22], s_dchars[22], s_fgcols[23], s_bgcols[23], s_dchars[23],
																				s_fgcols[24], s_bgcols[24], s_dchars[24], s_fgcols[25], s_bgcols[25], s_dchars[25], s_fgcols[26], s_bgcols[26], s_dchars[26],
																				s_fgcols[27], s_bgcols[27], s_dchars[27], s_fgcols[28], s_bgcols[28], s_dchars[28], s_fgcols[29], s_bgcols[29], s_dchars[29],
																				s_fgcols[30], s_bgcols[30], s_dchars[30], s_fgcols[31], s_bgcols[31], s_dchars[31] );
				}
			}
					
			if (nof >= 26) {

				sscanf(drawOpS, "%x,%d,%d,%d,%d,%d,%d", &drawoption, &tex_offset_x, &tex_offset_y, &tex_mod_x, &tex_mod_y, &tex_add_x, &tex_add_y);

				nofcols = 1+(nof-26)/3;
				for (i = 0; i < MAX_OBJECTS_IN_MEM; i++) {
					if (objNames[i] && strstr(fname, objNames[i])) {
						obj3 = objs[i]; break;
					}
				}

				g_errH = &errH; g_opCount = opCount;

				transformFilenameSpaces(fname);

				if (!obj3) {
					if (strstr(fname,".obj"))
						obj3 = readObj(fname, 1, 0,0,0, 0, readCmdGfxTexture, bAllowRepeated3dTextures, (float)(tex_mod_x) / 100000.0, (float)(tex_mod_y) / 100000.0, (float)(tex_add_x) / 100000.0, (float)(tex_add_y) / 100000.0);
					else if (strstr(fname,".plg"))
						obj3 = readPlg(fname, 1, 0,0,0);
					else
						obj3 = readPly(fname, 1, 0,0,0);

					if (obj3) {
						if (objs[objCnt])
							freeObj3d(objs[objCnt]);
						objs[objCnt] = obj3;
						objNames[objCnt] = (char *) malloc(132);
						strcpy(objNames[objCnt], fname);
						
						if (bAutoCenter3d)
							centerObj3d(obj3, autoScale3dScale);
						
						objCnt++;
						if (objCnt >= MAX_OBJECTS_IN_MEM) objCnt = 0;				
					}
				}

				if (obj3) {
					unsigned int lfgcol, lbgcol;
				
					if (drawmode == 2)
						MYMEMSET(videoTransp, TRANSPVAL, XRES*YRES);

					for (i = 0; i < nofcols; i++) {
						int modi = i%nofcols;
						parseInput(s_fgcols[modi], s_bgcols[modi], s_dchars[modi], &lfgcol, &lbgcol, &pchar[i], &pbWriteChars[i], &pbWriteCols[i]);
#ifdef _RGB32
						if(s_fgcols[modi][0] == '0' && s_fgcols[modi][1] == 0) lfgcol = 0;
						if(s_bgcols[modi][0] == '0' && s_bgcols[modi][1] == 0) lbgcol = 0;
#endif						
						pfgbg[i] = ((PREPCOL)lbgcol << BITSHL) | lfgcol;
					}

					for (j = 0; j < obj3->nofPoints; j++) {
						obj3->objData[j].x = (obj3->objData[j].ox + modx) * scalex;
						obj3->objData[j].y = (obj3->objData[j].oy + mody) * scaley;
						obj3->objData[j].z = (obj3->objData[j].oz + modz) * scalez;
					}

					rrx = (float)(rx/rotationGranularity) * 3.14159265359 / 180.0;
					rry = (float)(ry/rotationGranularity) * 3.14159265359 / 180.0;
					rrz = (float)(rz/rotationGranularity) * 3.14159265359 / 180.0;

					if (rx2 == 0 && ry2 == 0 && rz2 == 0 && postmodx2 == 0 && postmody2 == 0 && postmodz2 == 0) {
						rot3dPoints(obj3->objData, obj3->nofPoints, xg, yg, dist, rrx, rry, rrz, aspect, postmodx, postmody, postmodz, z_culling_near != 0, projectionDepth);
					} else {
						rrx2 = (float)(rx2/rotationGranularity) * 3.14159265359 / 180.0;
						rry2 = (float)(ry2/rotationGranularity) * 3.14159265359 / 180.0;
						rrz2 = (float)(rz2/rotationGranularity) * 3.14159265359 / 180.0;

						rot3dPoints_doubleRotation(obj3->objData, obj3->nofPoints, xg, yg, dist, rrx, rry, rrz, aspect, postmodx, postmody, postmodz, z_culling_near != 0, projectionDepth, rrx2, rry2, rrz2, postmodx2, postmody2, postmodz2);
					}
					 
					 lowZ = 99999999; highZ = -99999999;
					 for(j=0; j<obj3->nofFaces; j++) {
						addZ = 0;
						for(i=0; i<obj3->faceData[j*R3D_MAX_V_PER_FACE]; i++) {
							addZ += obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vz;
						}
						addZ /= (float)i;
						if (addZ > highZ) highZ = addZ;
						if (addZ < lowZ) lowZ = addZ;
						averageZ[j] = addZ;
					 }
					 
					 
					 oldZL = z_levels;
					 if (z_levels < 10) z_levels = 10;
					 addZ = (highZ - lowZ) / z_levels;
					 currZ = highZ;
					 
					 divZ = (highZ - lowZ) / nofcols;
					 plusZ = -(lowZ / divZ);
					 
					 if ((drawmode == 5 || drawmode == 6) && ZBufVideo) {
						if (oldZL < 0) oldZL = 0;
						if (oldZL == 0) {
							bSkipZsort = 1; z_levels = 0;
						} else {
							currZ = lowZ; // + addZ / 2.0;
							negZAdd = 1;
							z_levels = oldZL;
						}
					 }
					 
					 if (addZ < 0) { addZ = 0.000001; } // some sort of rounding error, should not happen (but does :) )
					 
					 for (k = 0; k <= z_levels+1; k++) {
						 for(j=0, colIndex=0; j<obj3->nofFaces; j++, colIndex++) {
							
							if (obj3->nofBmaps > 0) {
								bmap=obj3->bmaps[obj3->faceBitmapIndex[j]];
								if (bmap && !bmap->data && bmap != paletteBmap && bmap->extras && bmap->extrasType == EXTRAS_ARRAY) {
									uchar *cols, nof;
									cols = (uchar *)bmap->extras;
									nof = *cols++;

									if (nof > 0 && nof <= 32) {
										
										if (drawmode == 2 ) {
											int j, k;
											for (i = 0; i < YRES; i++) {
												k = i*XRES;
												for (j = 0; j < XRES; j++) {
													if (videoTransp[k] != TRANSPVAL) {
														m = videoTransp[k] - 8;
														if (m < 0 ) m = 0;
														if (m >= nofcols) m = nofcols - 1;
														
														if (pbWriteCols[m]) videoCol[k] = pfgbg[m];
														if (pbWriteChars[m]) videoChar[k] = pchar[m];
													}
													k++;
												}
											}
											MYMEMSET(videoTransp, TRANSPVAL, XRES*YRES);
										}									

										nofcols = nof;
										paletteBmap = bmap;
										colIndex=0;
										for (i = 0; i < nofcols; i++) {
											pfgbg[i] = *cols++;
											pchar[i] = *cols++;
											pbWriteChars[i] = *cols++;
											pbWriteCols[i] = *cols++;
										}
										divZ = (highZ - lowZ) / nofcols;
										plusZ = -(lowZ / divZ);
									}
								}
							}

							nofFacePoints = obj3->faceData[j*R3D_MAX_V_PER_FACE];
							
							if (bmap && bmap->bCmdBlock && bmap->blockRefresh > 0 && obj3->nofBmaps > 0) {
								int ok;
								if (bmap->data)
									freeBitmap(bmap, 0);	
								ok = readCmdGfxTexture(bmap, bmap->pathOrBlockString);
								if (bmap->blockRefresh != 2) bmap->blockRefresh = 0;
								if (!ok) { bmap->data=NULL; bmap = NULL; }
							}
										
							if (averageZ[j] != 99999999 && ((averageZ[j] >= currZ && averageZ[j] <= currZ + addZ) || bSkipZsort)) {
								for(i=0; i<nofFacePoints; i++) {
									v[i].x=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vx; v[i].y=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vy;
									v[i].z=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vz;
									
									if (obj3->texCoords) {
										v[i].tex_coord.x=obj3->texCoords[obj3->texData[i+1+j*R3D_MAX_V_PER_FACE] * 2];
										v[i].tex_coord.y=obj3->texCoords[obj3->texData[i+1+j*R3D_MAX_V_PER_FACE] * 2+1];
									} else {
										v[i].tex_coord.x=us[i%3]; v[i].tex_coord.y=vs[i%3];
									}
									v[i].tex_coord.z=1.0;
								}

								if (!z_culling_near || averageZ[j] > z_culling_near)
								if (!z_culling_far || averageZ[j] < z_culling_far)
								if (!culling || (((v[1].x - v[0].x) * (v[2].y - v[1].y)) - ((v[2].x - v[1].x) * (v[1].y - v[0].y)) < 0)) {

									if (drawmode == 0 || drawmode == 4 || drawmode == 5 || drawmode == 6 || (nofFacePoints == 1 && obj3->nofBmaps > 0 && bmap && bmap->data && drawmode == 1)) {
										fgbg = pfgbg[colIndex%nofcols]; dchar = pchar[colIndex%nofcols];
										bWriteChars = pbWriteChars[colIndex%nofcols]; bWriteCols = pbWriteCols[colIndex%nofcols];

										video = videoCol;
										
										if (obj3->nofBmaps > 0 && bmap && bmap->data && (drawmode == 0 || drawmode == 5 || drawmode == 6 || (nofFacePoints == 1 && drawmode == 1)) && nofFacePoints != 2) {
											transpval = drawoption;
											
											if (bmap->transpVal != -1) transpval = bmap->transpVal;
											
											bmap->projectionDistance = dist;
											if (bmap->extras && bmap->extrasType == EXTRAS_BITMAP && drawmode != 6)
												((Bitmap *)(bmap->extras))->projectionDistance = dist;
											
											bDrawPerspective = (drawmode == 5 || drawmode == 6);
											
											if (nofFacePoints == 1) {
												int ox = v[0].x, oy = v[0].y;
												int bw = bmap->xSize - 1, bh = bmap->ySize - 1;
												v[0].tex_coord.z = v[1].tex_coord.z = v[2].tex_coord.z = v[3].tex_coord.z = 1; v[1].z = v[2].z = v[3].z = v[0].z;
												v[0].x = ox - bw / 2; v[0].y = oy - bh / 2; v[0].tex_coord.x = 0; v[0].tex_coord.y = 0;
												v[1].x = ox + bw / 2 + bw % 2; v[1].y = oy - bh / 2; v[1].tex_coord.x = 1.01; v[1].tex_coord.y = 0;
												v[2].x = ox + bw / 2 + bw % 2; v[2].y = oy + bh / 2 + bh % 2; v[2].tex_coord.x = 1.01; v[2].tex_coord.y = 1;
												v[3].x = ox - bw / 2; v[3].y = oy + bh / 2 + bh % 2; v[3].tex_coord.x = 0; v[3].tex_coord.y = 1.01;
												nofFacePoints = 4; bDrawPerspective = 0;
											}
											
											texture_offset_x = (float)(tex_offset_x) / 100000.0;
											texture_offset_y = (float)(tex_offset_y) / 100000.0;
											
											if (transpval >= 0) {
												
												if (bmap->extras && bmap->extrasType == EXTRAS_BITMAP) {
													drawTranspTDoublePoly(videoTransp, videoTranspChar, videoCol, videoChar, transpval, bWriteChars, bWriteCols, v, nofFacePoints, bmap, fgbg, bDrawPerspective, (Bitmap *)bmap->extras);
												} else {
#ifdef _RGB32
													if (transpval <= 15) transpval = g_rgbFgPalette[transpval];
													//printf("%lx\n",transpval); getch();
#endif
													drawTranspTPoly(videoTransp, videoCol, videoChar, transpval, dchar, bWriteChars, bWriteCols, v, nofFacePoints, bmap, fgbg, bDrawPerspective);
												}
											} else { 
												if (bWriteCols) scanConvex_tmap(v, nofFacePoints, NULL, bmap, fgbg, bDrawPerspective);
												video = videoChar;
												if (bWriteChars) {
													if (bmap->extras && bmap->extrasType == EXTRAS_BITMAP) {
														scanConvex_tmap(v, nofFacePoints, NULL, (Bitmap *)bmap->extras, 0, bDrawPerspective);
													} else {
														if (!bUsePerspectiveSingleCol)
															scanConvex(v, nofFacePoints, NULL, dchar);
														else {
															singleColData[0] = dchar;
															singleColBitmap.projectionDistance = bmap->projectionDistance;
															scanConvex_tmap(v, nofFacePoints, NULL, &singleColBitmap, 0, bDrawPerspective);
														}
													}
												}
											}
											
											texture_offset_x = texture_offset_y = 0;

										} else {
											if (nofFacePoints > 2) {
												if (drawoption > 0 && drawoption <= MAXBITOP) {
													int option = drawoption; if (option == BIT_NORMAL_IPOLY) option=0;
													if (bWriteCols) scanPoly(v, nofFacePoints, fgbg, option);
													video = videoChar;
													if (bWriteChars) scanPoly(v, nofFacePoints, dchar, BIT_OP_NORMAL);
												} else {
													if (!bUsePerspectiveSingleCol || ZBufVideo == NULL) {
														if (bWriteCols) scanConvex(v, nofFacePoints, NULL, fgbg);
														video = videoChar;
														if (bWriteChars) scanConvex(v, nofFacePoints, NULL, dchar);
													} else {
														if (bWriteCols) {
															singleColData[0] = fgbg;
															singleColBitmap.projectionDistance = dist;
															scanConvex_tmap(v, nofFacePoints, NULL, &singleColBitmap, 0, 1);
														}
														if (bWriteChars) {
															video = videoChar;
															singleColData[0] = dchar;
															singleColBitmap.projectionDistance = dist;
															scanConvex_tmap(v, nofFacePoints, NULL, &singleColBitmap, 0, 1);
														}
													}
												}
											} else if (nofFacePoints > 1) {
												if (bWriteCols) line(v[0].x, v[0].y, v[1].x, v[1].y, fgbg, 1);
												video = videoChar;
												if (bWriteChars) line(v[0].x, v[0].y, v[1].x, v[1].y, dchar, 1);
											} else {
												if (bWriteCols) setpixel(v[0].x, v[0].y, fgbg);
												video = videoChar;
												if (bWriteChars) setpixel(v[0].x, v[0].y, dchar);
											}
										}
										
									} else if (drawmode == 1) {
										int zcol = 0;
										for (l=0; l < nofFacePoints; l++) {
											if ((drawoption & 1) == 0)
												zcol += v[l].z/lightSource0Div+lightSource0Plus;
											else
												zcol += v[l].z/divZ+plusZ;
										}
										zcol /= nofFacePoints;
										if (zcol < 0) zcol=0;
										if (zcol >= nofcols) zcol=nofcols-1;

										fgbg = pfgbg[zcol]; dchar = pchar[zcol];
										bWriteChars = pbWriteChars[zcol]; bWriteCols = pbWriteCols[zcol];

										video = videoCol;
										if (nofFacePoints > 2) {
											if ((drawoption>>4) > 0 && (drawoption>>4) <= MAXBITOP) {
												int option = drawoption>>4; if (option == BIT_NORMAL_IPOLY) option=0;
												if (bWriteCols) scanPoly(v, nofFacePoints, fgbg, option);
												video = videoChar;
												if (bWriteChars) scanPoly(v, nofFacePoints, dchar, BIT_OP_NORMAL);
											} else {
												if (!bUsePerspectiveSingleCol || ZBufVideo == NULL) {
													if (bWriteCols) scanConvex(v, nofFacePoints, NULL, fgbg);
													video = videoChar;
													if (bWriteChars) scanConvex(v, nofFacePoints, NULL, dchar);
												} else {
													if (bWriteCols) {
														singleColData[0] = fgbg;
														singleColBitmap.projectionDistance = dist;
														scanConvex_tmap(v, nofFacePoints, NULL, &singleColBitmap, 0, 1);
													}
													if (bWriteChars) {
														video = videoChar;
														singleColData[0] = dchar;
														singleColBitmap.projectionDistance = dist;
														scanConvex_tmap(v, nofFacePoints, NULL, &singleColBitmap, 0, 1);
													}
												}												
											}
										} else if (nofFacePoints > 1) {
											if (bWriteCols) line(v[0].x, v[0].y, v[1].x, v[1].y, fgbg, 1);
											video = videoChar;
											if (bWriteChars) line(v[0].x, v[0].y, v[1].x, v[1].y, dchar, 1);
										} else {
											if (bWriteCols) setpixel(v[0].x, v[0].y, fgbg);
											video = videoChar;
											if (bWriteChars) setpixel(v[0].x, v[0].y, dchar);
										}
									} else if (drawmode == 2) {
										int gValue[16];
										video = videoTransp;
										if (drawoption == 0)
											scanConvex_goraud(v, nofFacePoints, NULL, gValue, GORAUD_TYPE_Z, 0, 25, 16, nofcols);
										else
											scanConvex_goraud(v, nofFacePoints, NULL, gValue, GORAUD_TYPE_Z, 0, divZ, plusZ, nofcols);

									} else {
										fgbg = pfgbg[colIndex%nofcols]; dchar = pchar[colIndex%nofcols];
										bWriteChars = pbWriteChars[colIndex%nofcols]; bWriteCols = pbWriteCols[colIndex%nofcols];

										video = videoCol;
										if (nofFacePoints > 2) {
											if (bWriteCols) polyLine(v, nofFacePoints, fgbg, 1, 1);
											video = videoChar;
											if (bWriteChars) polyLine(v, nofFacePoints, dchar, 1, 1);
										} else if (nofFacePoints > 1) {
											if (bWriteCols) line(v[0].x, v[0].y, v[1].x, v[1].y, fgbg, 1);
											video = videoChar;
											if (bWriteChars) line(v[0].x, v[0].y, v[1].x, v[1].y, dchar, 1);
										} else {
											if (bWriteCols) setpixel(v[0].x, v[0].y, fgbg);
											video = videoChar;
											if (bWriteChars) setpixel(v[0].x, v[0].y, dchar);
										}
									}
								}
								averageZ[j] = 99999999; 
							}
						}
						if (negZAdd)
							currZ = currZ + addZ;
						else
							currZ = currZ - addZ;
					}

					if (drawmode == 2 ) {
						for (i = 0; i < YRES; i++) {
							k = i*XRES;
							for (j = 0; j < XRES; j++) {
								if (videoTransp[k] != TRANSPVAL) {
									m = videoTransp[k] - 8;
									if (m < 0 ) m = 0;
									if (m >= nofcols) m = nofcols - 1;
									
									if (pbWriteCols[m]) videoCol[k] = pfgbg[m];
									if (pbWriteChars[m]) videoChar[k] = pchar[m];
								}
								k++;
							}
						}
					}
				} else
					reportFileError(&errH, OP_3D, ERR_OBJECT_LOAD, opCount, fname, NULL);

				// stupid strtok, I use it in the load functions for plg and obj files, thus screwing up the existing strtok. Rereading, ugly fix...
				strcpy(argv1, insertedArgs);
				pch = strtok(argv1, "&");
				for (i = 0; i < opCount; i++) { pch = strtok (NULL, "&"); }

			}
			else
				reportArgError(&errH, OP_3D, opCount, pch, nof);
		}	else if (strstr(pch,"skip ") == pch) {
			// do nothing
#ifdef _RGB32			
		}	else if (strstr(pch,"color16 ") == pch) {
			int x1,y1,w,h;
			pch = pch + 8;

			if (!bWasConvertedTo16) {
				bWasConvertedTo16 = 1;
				
				parseConv16Flag(pch, outCh, &conv16div, &conv16mode); 

				if (conv16W != txres || conv16H != tyres) {
					if (conv16Col) free (conv16Col);
					if (conv16Char) free (conv16Char);
					
					conv16Col = (uchar *)malloc(XRES*YRES*sizeof(uchar));
					conv16Char = (uchar *)malloc(XRES*YRES*sizeof(uchar));
					conv16W=txres; conv16H=tyres;
				}
				
				convertFgRgbTo16Col(XRES, YRES, videoCol, videoChar, conv16Col, conv16Char, &fgPalette[0], outCh, conv16div, conv16mode, outw, outh);
				
				oldVidCol = videoCol; oldVidChar = videoChar;
				videoCol = conv16Col; videoChar = conv16Char;
				
			}
#endif
		} else {
			char faultyOp[42], *fnd;
			strncpy(faultyOp, pch, 40);
			faultyOp[40] = 0;
			fnd = strchr(faultyOp, ' ');
			if (fnd) *fnd = 0;
			if (faultyOp[0])
				reportError(&errH, OP_UNKNOWN, ERR_OPTYPE, opCount, faultyOp, NULL);
		}

		pch = strtok (NULL, "&");
		opCount++;
		}	
		
		if (!bSuppressErrors) {
			displayErrors(&errH, videoCol, videoChar);
			if (bWaitAfterErrors && errH.errCnt > 0)
				bWaitKey = 1;
		}
		
		
		if (!bDoNothing) {
				
	#ifdef GDI_OUTPUT
			convertToGdiBitmap(XRES, YRES, videoCol, videoChar, fontIndex, &fgPalette[0], &bgPalette[0], gx, gy, outw, outh, bAbsBitmapPos, bWindowedMode);
	
			if (bWriteGdiToFile) {
					FILE *fp = fopen("GDIbuf.dat", "wb");
					if (fp != NULL) {
						int blockSize;
						fwrite(&XRES, sizeof(int), 1, fp);
						fwrite(&YRES, sizeof(int), 1, fp);
						blockSize = XRES * YRES;
						fwrite(videoCol, sizeof(uchar), blockSize, fp);
						fwrite(videoChar, sizeof(uchar), blockSize, fp);
					}
			}
	#else
		
	#ifdef _RGB32
			convertToVT100(XRES, YRES, videoCol, videoChar, gx, gy, outw, outh);
	#else
			if (bPaletteSet)
				convertToText(XRES, YRES, videoCol, videoChar, fgPalette, bgPalette, gx, gy, outw, outh);
			else
				convertToText(XRES, YRES, videoCol, videoChar, NULL, NULL, gx, gy, outw, outh);
	#endif		
			
	#endif
	
	#ifdef _RGB32			
			if (bWasConvertedTo16) {
				bWasConvertedTo16 = 0;
				videoCol = oldVidCol;
				videoChar = oldVidChar;
			}
	#endif
	
			frameCounter++;
			
			if (ZBufVideo)
				memset(ZBufVideo, -99999999, sizeof(float) * XRES*YRES);

		}
		bDoNothing = 0;
		
		for (i = 0; i < errH.errCnt; i++) if (errH.extras[i]) free(errH.extras[i]);
		errH.errCnt = 0;

		if (!bMouse && ((bReadKey && kbhit()) || bWaitKey)) {
			int k = getch();
			if (k == 224 || k == 0) k = 256 + getch();
			retVal = k;
			bWaitKey = 0;
		}

		if (bMouse) {
			DWORD fdwMode, cNumRead = 0, iOut; 
			INPUT_RECORD irInBuf[128];
			int res, res2, key = -1, bKeyDown = 0, bWroteKey = 0, bTimeout = 0, bOk;
			
			//GetConsoleMode(g_conin, &oldfdwMode);
			fdwMode = oldfdwMode | ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT;
			fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
			SetConsoleMode(g_conin, fdwMode);
			
			bOk = 1;
			if (mouseWait > -1) {
				res = WaitForSingleObject(g_conin, mouseWait);
				// bug is reason it works. Don't reset old fdwMode in non-server mode
				if (res & WAIT_TIMEOUT) { 
					if (!bServer) {
						process_waiting(bWait, waitTime, bServer); 
						writeErrorLevelToFile(bWriteReturnToFile, -1, bMouse); /* SetConsoleMode(g_conin, oldfdwMode); */
						CloseHandle(g_conin);
						CloseHandle(g_conout);
						return -1; 
					} else bOk = 0; 
				}
			}

			res = -1;
			if (bOk)
				ReadConsoleInput(g_conin, irInBuf, 128, &cNumRead);
			for (i = 0; i < cNumRead; i++) {
				switch(irInBuf[i].EventType) { 
				case MOUSE_EVENT:
					bOk = 1;
					if (bMouse == 1) bOk = MouseClicked(irInBuf[i].Event.MouseEvent);
					if (bOk)
						res = MouseEventProc(irInBuf[i].Event.MouseEvent);
					break;
				case KEY_EVENT:
					bKeyDown = irInBuf[i].Event.KeyEvent.bKeyDown;
					if (irInBuf[i].Event.KeyEvent.uChar.AsciiChar > 0)
						key = irInBuf[i].Event.KeyEvent.uChar.AsciiChar;
					else
						key = 256 + irInBuf[i].Event.KeyEvent.wVirtualScanCode;
					irInBuf[i].Event.KeyEvent.bKeyDown = 1; WriteConsoleInput(g_conin, &irInBuf[i], 1, &iOut);
					irInBuf[i].Event.KeyEvent.bKeyDown = 0; WriteConsoleInput(g_conin, &irInBuf[i], 1, &iOut);
					bWroteKey = 1;

	//				printf("DWN:%d REP:%d %d %d %d %d key:%d CK:%ld\n", irInBuf[i].Event.KeyEvent.bKeyDown, irInBuf[i].Event.KeyEvent.wRepeatCount, irInBuf[i].Event.KeyEvent.wVirtualKeyCode, irInBuf[i].Event.KeyEvent.wVirtualScanCode, irInBuf[i].Event.KeyEvent.uChar.UnicodeChar, irInBuf[i].Event.KeyEvent.uChar.AsciiChar, key, irInBuf[i].Event.KeyEvent.dwControlKeyState);
					break;
				case WINDOW_BUFFER_SIZE_EVENT:
				case FOCUS_EVENT:
				case MENU_EVENT:
					break;
				}
			}

			if (bWroteKey) {
				if (kbhit()) {
					key=getch();
					if (key == 224 || key == 0) key = 256 + getch();
					while(kbhit()) getch();
				}
				res2 = WaitForSingleObject(g_conin, 1);
				if (!(res2 & WAIT_TIMEOUT))
					ReadConsoleInput(g_conin, irInBuf, 128, &cNumRead);			

				if (bKeyDown || bSendKeyUp) {
					res = (res > 0? res : 0) | (key<<22);
					res = res | (bKeyDown<<21);
				}
			}
			
			retVal = res;
		}

		process_waiting(bWait, waitTime, bServer);
		
		writeErrorLevelToFile(bWriteReturnToFile, retVal, bMouse);

		if (bCapture && captX >= 0 && captX < txres && captY >= 0 && captY < tyres && captW >= 0 && captX+captW <= txres && captY >= 0 && captY+captH <= tyres) {
			int saveRes = SaveBlock(captureCount, captX, captY, captW, captH, captFormat);
			if (saveRes == 0)
				captureCount++;
		}
		bCapture = 0;
		
		if (bServer) {
			char *input = NULL, *fndMe = NULL, *fndMeEcho;
			FILE	*flushFile = NULL;

			if (!bIgnoreServerCmdFile)
				flushFile = fopen("servercmd.dat", "r");
			if (flushFile) {
				char *inputTemp;
				inputTemp = fgets(argv1, MAX_OP_SIZE-1, flushFile);
				fclose(flushFile);
				if (inputTemp){
					input = inputTemp;
					remove("servercmd.dat");
					fndMe = strchr(input, '\"');
					if (fndMe) {
						memmove(argv1, (char *)fndMe, strlen(fndMe)+1);
						argv1[0] = ' ';
						fndMe = NULL;
					}
				}
			}

			if (!bIgnoreTitleComm && input == NULL) {
				HWND consoleWindow = GetConsoleWindow();
				if (consoleWindow!= NULL) {
					GetWindowText(consoleWindow, argv1, 1023);
					if (strstr(argv1, "output:") == (char *) argv1) {
						SetWindowText(consoleWindow, sTitleBuffer);

						fndMe = strchr(argv1, '\"');
						if (fndMe) {
							memmove(argv1, (char *)fndMe, strlen(fndMe)+1);
							input = argv1;
							argv1[0] = ' ';
							fndMe = NULL;
						}
						
					} else
						strcpy(sTitleBuffer, argv1);
				}
			}
			
			if (input == NULL) {
				do {
					input = fgets(argv1, MAX_OP_SIZE-1, stdin); // this call blocks if there is no input
					if (input != NULL) {
						fndMe = strstr(input, "cmdgfx:");
						if (!fndMe) {
							puts(input);
						}
					}

				} while (fndMe == NULL && input != NULL);
			}
									
			if (input != NULL) {
				if ((strstr(input, "quit") != NULL || strstr(input, "exit") != NULL) && strlen(input) < 20) {
					bServer = 0;
				} else {
					if (fndMe != NULL)
						memmove(argv1, (char *)fndMe + strlen("cmdgfx:"), strlen(input));
				}
			} else {
				if (!bSuppressErrors) {
					printf("\nCMDGFX: Client appears to have ended prematurely. Use the 'quit' command to stop the server.\n\nExit server... Press a key.\n");
					getch();
				}
				bServer = 0;
			}
			
			if (bServer){
				int ast = 1;
				for (i = 0; i < strlen(argv1); i++) {
					if (argv1[i] == ' ' && ast) argv1[i] = 1;
					if (argv1[i] == '\"') { ast = 1 - ast; argv1[i] = ' '; }
				}
				
				pch = strtok(argv1, " \n");
				strcpy(argv1, pch);
				for (i = 0; i < strlen(argv1); i++)
					if (argv1[i] == 1) argv1[i] = ' ';
				
				pch = strtok (NULL, " \n");

				if (pch) {
					int neg = 0;
					for (i = 0; i < strlen(pch); i++) {
						
						neg = 0;
						if (pch[i] == '-') { neg = 1; i++; }
						
						switch(pch[i]) {
#ifdef GDI_OUTPUT
							case 'P': bWriteGdiToFile = neg? 0 : 1; break;
#endif
							case 'n': bDoNothing = 1; break;
							case 'k': bReadKey = neg? 0 : 1; if (bReadKey) bMouse = 0; break;
							case 'K': bWaitKey = 1; break;
							case 'Z': {
								char pDepth[64];
								j = 0; i++;
								while (pch[i] >= '0' && pch[i] <= '9') pDepth[j++] = pch[i++];
								i--; pDepth[j] = 0;
								if (j) projectionDepth = atoi(pDepth);
								break;
							}
							case 'M': case 'm':{
								if (neg)
									bMouse = 0;
								else {
									char wTime[64];
									bMouse = pch[i] == 'M'? 2 : 1; j = 0; i++;
									while (pch[i] >= '0' && pch[i] <= '9') wTime[j++] = pch[i++];
									i--; wTime[j] = 0;
									if (j) mouseWait = atoi(wTime);
								}
								break;
							}
							case 'W': case 'w': {
								if (neg)
									bWait = 0;
								else {
									char wTime[64];
									bWait = 1; if (pch[i] == 'W') bWait = 2; j = 0; i++;
									while (pch[i] >= '0' && pch[i] <= '9') wTime[j++] = pch[i++];
									i--; wTime[j] = 0;
									if (j) waitTime = atoi(wTime);
								}
								break;
							}
							case 'd': bPrintFullErrorString = neg? 0 : 1; break;
							case 'u': bSendKeyUp = neg? 0 : 1; break;
							case 'e': bSuppressErrors = neg? 0 : 1; break;
							case 'E': bWaitAfterErrors = neg? 0 : 1; break;
							case 's': bUsePerspectiveSingleCol = neg? 0 : 1; break;
							case 'o': bWriteReturnToFile = neg? 0 : 1; break;
							case 'O': bWriteReturnToFile = neg? 0 : 2; break;
							case 'C': frameCounter = 0; startT = milliseconds_now(); break;
							case 'T': bAllowRepeated3dTextures = neg? 0 : 1; break;
							case 'z': g_bSleepingWait = neg? 0 : 1; break;				
							case 'J': g_bFlushAfterELwrite = neg? 0 : 1; break;
							case 'I': bIgnoreTitleComm = neg? 1 : 0; break;
							case 'i': bIgnoreServerCmdFile = neg? 0 : 1; break;
							case 'v': bUseOrigoPoly = neg? 0 : 1; break;
							case 'V': bUseOrigoBox = neg? 0 : 1; break;
#ifdef GDI_OUTPUT
							case 'a': bAbsBitmapPos =  neg? 0 : 1; break;
							case 'U': bWindowedMode = neg? 1 : 0; break;
#endif
							case 'G': {
								int GXM=256, GYM=256;
								i++;
								nof = sscanf(&pch[i], "%d,%d", &GXM, &GYM);
								if (nof == 2 && GXM >= 16 && GYM >= 16) { GXY_MAX_X = GXM; GXY_MAX_Y = GYM; }
								break;
							}
							case 'R': {
								char rotGran[64];
								j = 0; i++;
								while (pch[i] >= '0' && pch[i] <= '9') rotGran[j++] = pch[i++];
								i--; rotGran[j] = 0;
								if (j) rotationGranularity = atoi(rotGran);
								if (rotationGranularity < 1) rotationGranularity = 4;
								break;
							}
							
							case 'N': {
								bAutoCenter3d = neg? 0 : 1; autoScale3dScale = -1;
								if (bAutoCenter3d && pch[i+1] >= '0' && pch[i+1] <= '9')
									sscanf(&pch[i+1], "%f", &autoScale3dScale);
								break;
							}

							case 'B': {
								bZBuffer = neg? 0 : 1;
								if (bZBuffer) {
									if(ZBufVideo == NULL)
										ZBufVideo = (float *) malloc(XRES * YRES * sizeof(float));
										memset(ZBufVideo, -99999999, sizeof(float) * XRES*YRES);
								} else {
									if (ZBufVideo)
										free(ZBufVideo);
									ZBufVideo = NULL;
								}
								break;
							}

							case 'b': {
								if (ZBufVideo)
									memset(ZBufVideo, -99999999, sizeof(float) * XRES*YRES);
							}
							
							case 'L': 
							{
								nof = sscanf(&pch[i+1], "%d,%d", &lightSource0Div, &lightSource0Plus);
								break;
							}
							
							case 'f': 
							{
								int oldtx=txres, oldty=tyres;
								char *fnd, fin[64];
								int nof;
#ifdef GDI_OUTPUT
								i++; fontIndex = GetHex(pch[i]);
								if (fontIndex < 0 || fontIndex > 12) fontIndex = 6; 
#endif
								if (pch[i+1] == ':' && pch[i+2]) {
									fnd = strchr(&pch[i+2], ';');
									if (!fnd) strcpy(fin, &pch[i+2]); else { nof = fnd-&pch[i+2]; strncpy(fin, &pch[i+2], nof); fin[nof]=0; }
									nof = sscanf(fin, "%d,%d,%d,%d,%d,%d", &gx, &gy, &txres, &tyres, &outw, &outh);
									if (nof >= 3 && nof < 5) outw = txres;
									if (nof >= 4 && nof < 6) outh = tyres;
									if (outw > txres || outw < 0) outw = txres;
									if (outh > tyres || outh < 0) outh = tyres;
								}
							
								if (oldtx != txres || oldty != tyres) {
									setResolution(txres, tyres);
									free(videoCol); free(videoChar); free(videoTransp); free(videoTranspChar);
									videoCol = (uchar *)calloc(XRES*YRES,sizeof(uchar));
									videoChar = (uchar *)calloc(XRES*YRES,sizeof(uchar));
									videoTransp = (uchar *)malloc(XRES*YRES*sizeof(uchar));
									videoTranspChar = (uchar *)malloc(XRES*YRES*sizeof(uchar));
									g_videoCol = videoCol;
									g_videoChar = videoChar;
									
									if (ZBufVideo) {
										free(ZBufVideo);
										ZBufVideo = (float *) malloc(XRES * YRES * sizeof(float));
										memset(ZBufVideo, -99999999, sizeof(float) * XRES*YRES);
									}
									
									if (!videoCol || !videoChar || !videoTransp || !videoTranspChar) {
										printf("\nPANIC: Server could not re-allocate space for buffer!\n\nExit server...\n");
										return 0;
									}
								}
								break;
							}
							case 'c': 
							{
								char *fnd, fin[64];
								int nof = 0;
								captX = 0, captY=0, captW=txres, captH=tyres, captFormat=1, bCapture = 1;
								if (pch[i+1] == ':' && pch[i+2]) {
									fnd = strchr(&pch[i+2], ';');
									if (!fnd) strcpy(fin, &pch[i+2]); else { nof = fnd-&pch[i+2]; strncpy(fin, &pch[i+2], nof); fin[nof]=0; }
									nof = sscanf(fin, "%d,%d,%d,%d,%d,%d", &captX, &captY, &captW, &captH, &captFormat, &captureCount);
								} else
									bCapture = 0;
								if (nof < 3) captW = txres - captX;
								if (nof < 4) captH = tyres - captY;
								break;
							}
							
							case 'D':
							{
								for (j = 0; j < MAX_OBJECTS_IN_MEM; j++) {
									if (objs[j]) {
										freeObj3d(objs[j]);
										free(objNames[j]);
										objs[j] = NULL;
										objNames[j] = NULL;
									}
								}
								break;
							}
														
							case 'F': fflush(stdin); break; // should this be before the loop rather than after?
						}
					}
										
					pch = strtok (NULL, " \n");
					if (pch) {
						char fgPal[6400];
						strcpy(fgPal, pch);
						for (ii = 0; ii < 16; ii++) { fgPalette[ii] = orgPalette[ii]; }
						pch = strtok (NULL, " \n");
						if (pch) for (ii = 0; ii < 16; ii++) { bgPalette[ii] = orgPalette[ii]; }

						readPalette(fgPal, pch, fgPalette, bgPalette, &bPaletteSet);
					}
					
				}
				
			}
						
			if (bInserted)
				free(insertedArgs);
			
			bInserted = 1;
			insertedArgs = insertCgx(argv1);
			if (!insertedArgs) { insertedArgs = (char *) malloc(strlen(argv1) + 10); strcpy(insertedArgs, argv1); }
			opCount = 0;
			if (bServer) {
				for (i = 0; i < MAX_OBJECTS_IN_MEM; i++) {
					obj3d *obj = objs[i];
					if (obj && obj->bmaps) {
						for (j = 0; j < obj->nofBmaps; j++) {
							if (obj->bmaps[j] && obj->bmaps[j]->bCmdBlock && obj->bmaps[j]->blockRefresh == 0)
								obj->bmaps[j]->blockRefresh = 1;
						}
					}
				}
			}
		}

	} while (bServer);


	if(bInserted)
		free(insertedArgs);

	free(videoCol);
	free(videoChar);
	free(videoTransp);
	free(videoTranspChar);


	for (i = 0; i < MAX_OBJECTS_IN_MEM; i++) {
		if (objs[i]) {
			freeObj3d(objs[i]);
			free(objNames[i]);
		}
	}

	if (ZBufVideo)
		free(ZBufVideo);

	for (i = 0; i < errH.errCnt; i++) { if (errH.extras[i]) free(errH.extras[i]); if (errH.op[i]) free(errH.op[i]); }
	errH.errCnt = 0;

#ifdef GDI_OUTPUT
	if (g_hDc) ReleaseDC(g_hWnd, g_hDc);
	if (g_hDcBmp) DeleteDC(g_hDcBmp);
	if (g_bitmap) DeleteObject(g_bitmap);
#endif
	
	if (b_pcx.data) free(b_pcx.data);
	free(averageZ);
	free(argv1);
	
	SetConsoleMode(g_conin, oldfdwMode);
	
#ifndef GDI_OUTPUT
#ifdef _RGB32
	{
	unsigned int fcol, bcol;
	fcol = orgPalette[consoleFgCol];
	bcol = orgPalette[consoleBgCol];
	printf("%c[38;2;%d;%d;%dm",27,(fcol>>16)&0xff,(fcol>>8)&0xff,fcol&0xff);
	printf("%c[48;2;%d;%d;%dm",27,(bcol>>16)&0xff,(bcol>>8)&0xff,bcol&0xff);
	}
	SetConsoleMode(g_conout, oldOutMode);
#endif
#endif

#ifdef _RGB32
	if (conv16Col) free(conv16Col);
	if (conv16Char) free(conv16Char);
#endif

	CloseHandle(g_conin);
	CloseHandle(g_conout);
	
	return retVal;
}
