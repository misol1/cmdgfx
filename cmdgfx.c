/************************************************
 * Cmdgfx v 0.999 (c) Mikael Sollenborn 2016-17 *
 ************************************************/

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

// Issues:
// 1. Code optimization: Re-use images used several times, same way as for objects
// 2. TinyExpr: optimize recursion
// (3. Use *10 for rotations instead of *4?)

// For 3d:
// 1. Code optimization: Texture mapping: re-using textures, both for single objects and between objects
// 2. Code optimization: Optimize texture transparency for 3d/tpoly (currently fills/copies whole buffer for every polygon!)
// 3. Code fix: Persp correct tmapping edge bug (cause: for pcx, chars are drawn with std poly routine, and cols with perspmapper)
// 4. Code fix: Figure out why RX rotation not working as in Amiga/ASM 3d world (i.e. not working as expected in 3dworld.bat)
// (5. Not likely: z-buffer)

int XRES, YRES, FRAMESIZE;
uchar *video;

#define MAX_ERRS 64
typedef enum {ERR_NOF_ARGS, ERR_IMAGE_LOAD, ERR_OBJECT_LOAD, ERR_PARSE, ERR_MEMORY, ERR_OPTYPE, ERR_EXPRESSION } ErrorType;
typedef enum {OP_POLY=0, OP_IPOLY=1, OP_GPOLY=2, OP_TPOLY=3, OP_IMAGE=4, OP_BOX=5, OP_FBOX=6, OP_LINE=7, OP_PIXEL=8, OP_CIRCLE=9, OP_FCIRCLE=10, OP_ELLIPSE=11, OP_FELLIPSE=12, OP_TEXT=13, OP_3D=14, OP_BLOCK=15, OP_INSERT=16, OP_UNKNOWN=17 } OperationType;
typedef struct {
	ErrorType errType[MAX_ERRS];
	OperationType opType[MAX_ERRS];
	int index[MAX_ERRS];
	char *extras[MAX_ERRS];
	int errCnt;
} ErrorHandler;

uchar hexLookup[256];
uchar colLookup[256];

#define GetHex(v) (hexLookup[(int)v])
#define GetCol(v, old) (colLookup[(int)v] == 255? old : hexLookup[(int)v])

#define MAX_STR_SIZE 300000
#define MAX_OP_SIZE 128000


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

int readGxy(char *fname, Bitmap *b_cols, Bitmap *b_chars, int *w1, int *h1, int color, int transpchar,int bIsFile,int bIgnoreFgColor, int bIgnoreBgColor) {
	char *text, ch, *pbcol, *pbchar;
	int fr, i, j, 	inlen;
	int x = 0, y = 0, yp=0;
	int v, v16, fgCol, bgCol, oldColor;
	unsigned char *cchars, *ccols;
	int w = 256, h = 128;
	FILE *ifp;

	*w1 = -1;
	
	bgCol = (color>>4) & 0xf;
	fgCol = color & 0xf;
	oldColor = color;
	
	b_cols->data = (unsigned char *)malloc(w*h*sizeof(unsigned char));
	b_chars->data = (unsigned char *)malloc(w*h*sizeof(unsigned char));
	text = (char *)malloc(MAX_STR_SIZE);
	if (!text || !b_cols->data || !b_chars->data) { if (text) free(text); if (b_cols->data) free(b_cols->data); if(b_chars->data) free(b_chars->data); b_cols->data = b_chars->data = NULL; return 0; }
	memset(b_cols->data, 0, w*h*sizeof(unsigned char));
	memset(b_chars->data, 255, w*h*sizeof(unsigned char));

	pbchar = b_chars->data;
	pbcol = b_cols->data;

	if (bIsFile) {
		ifp=fopen(fname, "r");
		if (ifp == NULL) {
			free(text); free(b_cols->data); free(b_chars->data); b_cols->data = b_chars->data = NULL;
			return 0;
		} else {
			fr = fread(text, 1, MAX_STR_SIZE, ifp);
			fclose(ifp);
		}
		text[fr] = 0;
	} else
		strcpy(text, fname);
	inlen =strlen(text);

	for(i = 0; i < inlen; i++) {
		ch = text[i];
		if (ch == '\\') {
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
					int tempC = color;
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
					if (!bIgnoreFgColor)
						fgCol = GetCol(ch, fgCol);
					i++;
					if (!bIgnoreBgColor)
						bgCol = GetCol(text[i], bgCol);
					color = fgCol | (bgCol<<4);
				}
			}
		} else {
			if (y >= h) break;
			
			if (ch == 10) {
				if (x > *w1) *w1 = x;
				x = 0; y++; yp+=w;
			} else {
				if (x < w) { pbchar[yp+x] = ch; pbcol[yp+x] = color; }
				x++;
			}
		}
	}		
	y++;
	*h1 = y;
	if (x > *w1) *w1 = x;
	
	ccols = (unsigned char *)malloc((*w1)*y*sizeof(unsigned char));
	cchars = (unsigned char *)malloc((*w1)*y*sizeof(unsigned char));
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
	int writeCols = 1, writeChars = 1, writeFgBg = 3;

	if (strlen(s_fgcol)==1) {
		if (s_fgcol[0] == '?')
			writeCols = 0, writeFgBg -= 1;
		*fgcol = strtol(s_fgcol, NULL, 16);
	} else
		*fgcol = strtol(s_fgcol, NULL, 10);

	if (strlen(s_bgcol)==1) {
		if (s_bgcol[0] == '?')
			writeCols = 0, writeFgBg -= 2;
		*bgcol = strtol(s_bgcol, NULL, 16);
	} else
		*bgcol = strtol(s_bgcol, NULL, 10);

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
void reportFileError(ErrorHandler *errHandler, OperationType opType, ErrorType errType, int index, char *extras);
unsigned char *g_videoCol, *g_videoChar;
int g_bSleepingWait = 0;
int g_bFlushAfterELwrite = 0;

int readCmdGfxTexture(Bitmap *bmap, char *fname) {
	char *orgFnameP = fname;
	int res = 0;
	if (!bmap || !fname) return res;
	bmap->transpVal = -1;
	
	if (strstr(fname, ".pcx")) {
		char transp[4], inpname[256];
		int nofargs, dum1, dum2, transpVal = -1;
		
		nofargs = sscanf(fname, "%250s %2s", inpname, transp);
		if (nofargs > 1) parseInput(transp, transp, transp, &transpVal, &dum1, &dum2, NULL, NULL);
		res = PCXload(bmap, inpname);

		bmap->transpVal = transpVal;
		bmap->bCmdBlock = 0;
		bmap->extras = NULL;
		bmap->extrasType = EXTRAS_NONE;

	} else if (strstr(fname, "cmdblock")) {
		int x, y, w, h, transpval, i, j, ii, vi, nofargs, transpVal = -1, blockRefresh = 0;
		Bitmap *bmap2;
	
		fname = strstr(fname, "cmdblock ") + strlen("cmdblock ");
		while (*fname==32) fname++;

		nofargs = sscanf(fname, "%d %d %d %d %x %d", &x, &y, &w, &h, &transpval, &blockRefresh);
		if (nofargs < 4)
			return 0;
		
		if (x < 0 || y < 0 || x >= XRES || y >= YRES || x+w >= XRES || y+h >= YRES)
			return 0;

		bmap2 = (Bitmap *) calloc(sizeof(Bitmap), 1);
		bmap2->data = (uchar *) malloc( w * h);
		bmap->data = (uchar *) malloc( w * h);
		if (!bmap2 || ! bmap->data || ! bmap2->data) { if(bmap2->data) free(bmap2->data); if(bmap->data) free(bmap->data); if (bmap2) free(bmap2); return res; }
		bmap->extras = bmap2;
		bmap->xSize = bmap2->xSize = w;
		bmap->ySize = bmap2->ySize = h;
		bmap->extrasType = EXTRAS_BITMAP;
		bmap->transpVal = -1;
		bmap2->transpVal = transpVal;

		bmap->bCmdBlock = 1;
		strncpy(bmap->pathOrBlockString, orgFnameP, strlen(orgFnameP));
		bmap->pathOrBlockString[strlen(orgFnameP)] = 0;
		bmap->blockRefresh = blockRefresh == 2? 2 : 0;
		
		for (i = 0; i < h; i++) {
			ii = w*i; vi = x + y * XRES + i * XRES;
			for (j = 0; j < w; j++) {
				bmap->data[ii + j] = g_videoCol[vi + j];
				bmap2->data[ii + j] = g_videoChar[vi + j];
			}
		}
		res = 1;
		
	} else if (strstr(fname, "cmdpalette ")) {
		char s_fgcols[34][64], s_bgcols[34][4], s_dchars[34][4];
		int pchar[64], pbWriteChars[64], pbWriteCols[64];
		uchar pfgbg[64], *cols;
		int nofcols, i, j;
		int fgcol, bgcol;

		fname = strstr(fname, "cmdpalette ") + strlen("cmdpalette ");
		while (*fname==32) fname++;

		nofcols = sscanf(fname, "%62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s", 
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
		char transp[4], inpname[256];
		int nofargs, dum1, dum2, transpVal = -1;
		
		nofargs = sscanf(fname, "%250s %2s", inpname, transp);
		if (nofargs > 1) parseInput(transp, transp, transp, &dum1, &dum2, &transpVal, NULL, NULL);
		
		bmap->extras = (Bitmap *) calloc(sizeof(Bitmap), 1);
		if (!bmap->extras) return res;
		bmap->extrasType = EXTRAS_BITMAP;
		res = readGxy(inpname, bmap, (Bitmap *)bmap->extras, &w, &h, 0, -1, 1, 0, 0);
		bmap->transpVal = transpVal;
		bmap->bCmdBlock = 0;
	}
	
	if (!res) reportFileError(g_errH, OP_3D, ERR_IMAGE_LOAD, g_opCount, fname);
	return res;
}


CHAR_INFO * readScreenBlock() {
	COORD a = { 1, 1 };
	COORD b = { 0, 0 };
	SMALL_RECT r;
	CHAR_INFO *str;
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	int x,y, w, h;
	
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);

	x = 0; y = 0;
	w = screenBufferInfo.dwSize.X;
	h = screenBufferInfo.dwSize.Y;

	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * w*h);
	if (!str) {
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
			ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str+j*l*w, a, b, &r);
		}
	}

	return str;
}

#ifndef GDI_OUTPUT

void convertToText(int XRES, int YRES, unsigned char *videoCol, unsigned char *videoChar, uchar *fgPalette, uchar *bgPalette) {
	CHAR_INFO *str;
	COORD a, b;
	SMALL_RECT r;
	HANDLE hCurrHandle;
	int i;

	a.X = XRES; a.Y = YRES;

	hCurrHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	str = (CHAR_INFO *) calloc (sizeof(CHAR_INFO) * (a.X * a.Y), 1);
	if (!str) return;

	if (fgPalette == NULL) {
		for (i = 0; i < XRES * YRES; i++) {
			str[i].Attributes = videoCol[i];
			str[i].Char.AsciiChar = videoChar[i];
		}
	} else {
		for (i = 0; i < XRES * YRES; i++) {
			str[i].Attributes = fgPalette[videoCol[i] & 0xf] | (bgPalette[videoCol[i] >> 4] << 4);
			str[i].Char.AsciiChar = videoChar[i];
		}
	}
	
	b.X = b.Y = r.Left = r.Top = 0;
	r.Right = a.X;
	r.Bottom = a.Y;
	WriteConsoleOutput(hCurrHandle, str, a, b, &r);

	free(str);
}

#endif

#ifdef GDI_OUTPUT

HWND g_hWnd = NULL;
HDC g_hDc = NULL, g_hDcBmp = NULL;


// Writing ints instead of chars
void convertToGdiBitmap(int XRES, int YRES, unsigned char *videoCol, unsigned char *videoChar, int fontIndex, unsigned int *cmdPaletteFg, unsigned int *cmdPaletteBg, int x, int y, int outw, int outh) {
	HBITMAP hBmp1 = NULL;
	HGDIOBJ hGdiObj = NULL;
	BITMAP bmp = {0};
	LONG w = 0, h = 0;
	int iRet = EXIT_FAILURE;
	unsigned int *outdata = NULL, *pcol, *outt, *fgcol, *bgcol;
	int i,j,ccol,cchar,l,m, index;
	static unsigned int cmdPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	static int *fontData[16] = { &cmd_font0_data[0][0], &cmd_font1_data[0][0], &cmd_font2_data[0][0], &cmd_font3_data[0][0], &cmd_font4_data[0][0], &cmd_font5_data[0][0], &cmd_font6_data[0][0], &cmd_font7_data[0][0], &cmd_font8_data[0][0], &cmd_font9_data[0][0], NULL, NULL, NULL };
	int fontWidth[16] = { cmd_font0_w, cmd_font1_w, cmd_font2_w, cmd_font3_w, cmd_font4_w, cmd_font5_w, cmd_font6_w, cmd_font7_w, cmd_font8_w, cmd_font9_w, 1,2,3 };
	int fontHeight[16] = { cmd_font0_h, cmd_font1_h, cmd_font3_h, cmd_font3_h, cmd_font4_h, cmd_font5_h, cmd_font6_h, cmd_font7_h, cmd_font8_h, cmd_font9_h, 1,2,3 };
	int fw, fh, *data, val, bpp = 4;
	unsigned int *palFg, *palBg;

	if (cmdPaletteFg == NULL) palFg = &cmdPalette[0]; else palFg = cmdPaletteFg;
	if (cmdPaletteBg == NULL) palBg = &cmdPalette[0]; else palBg = cmdPaletteBg;

	if (fontIndex < 0 || fontIndex > 12)
		return;

	fw = fontWidth[fontIndex];
	fh = fontHeight[fontIndex];
	data = fontData[fontIndex];

	x *= fw; y *= fh;

	if (g_hDc == NULL) {
		if ((g_hWnd = GetConsoleWindow())) {
			if ((g_hDc = GetDC(g_hWnd))) {
				g_hDcBmp = CreateCompatibleDC(g_hDc);
			}
		}
	}
	
	if (g_hDcBmp)
	{
		w = outw * fw;
		h = outh * fh;
		outdata = (unsigned int *)malloc(w*h*sizeof(unsigned int));
		if (!outdata) { printf("#ERR: Could not allocate memory for output buffer\n"); return; }

		if (fontIndex < 10) {
			for (i = 0; i < outh; i++) {
				for (j = 0; j < outw; j++) {
					cchar = videoChar[j+i*XRES];
					ccol = videoCol[j+i*XRES];
					fgcol = &palFg[(ccol&0xf)];
					bgcol = &palBg[(ccol>>4)];
					for (l = 0; l < fh; l++) {
						index = (j*fw + (i*fh+l)*outw*fw);
						val = data[cchar*fh+l];
						outt = &outdata[index];
						for (m = 0; m < fw; m++) {
							*outt++ = (val & 1) ? *fgcol : *bgcol;
							val >>= 1;
						}
					}
				}
			}
		} else { // pixelfont
			if (fw == 1) {
				for (i = 0; i < outh; i++) {
					for (j = 0; j < outw; j++) {
						cchar = videoChar[j+i*XRES];
						ccol = videoCol[j+i*XRES];
						fgcol = &palFg[(ccol&0xf)];
						bgcol = &palBg[(ccol>>4)];
						pcol = fgcol; if (cchar == 0 || cchar == 32 || cchar == 255) pcol = bgcol; 
						outdata[j + i*outw] = *pcol;
					}
				}
			} else {
				for (i = 0; i < outh; i++) {
					for (j = 0; j < outw; j++) {
						cchar = videoChar[j+i*XRES];
						ccol = videoCol[j+i*XRES];
						fgcol = &palFg[(ccol&0xf)];
						bgcol = &palBg[(ccol>>4)];
						pcol = fgcol; if (cchar == 0 || cchar == 32 || cchar == 255) pcol = bgcol; 

						for (l = 0; l < fh; l++) {
							index = (j*fw + (i*fh+l)*outw*fw);
							outt = &outdata[index];
							for (m = 0; m < fw; m++) {
								*outt++ = *pcol;
							}
						}
					}
				}
			}
		}

		hBmp1 = (HBITMAP)CreateBitmap(w, h, 1, 8*bpp, outdata);
		if (hBmp1)
		{
			if (GetObject(hBmp1, sizeof(bmp), &bmp))
			{
				w = bmp.bmWidth; h = bmp.bmHeight;
				if ((hGdiObj = SelectObject(g_hDcBmp, hBmp1)) && hGdiObj != HGDI_ERROR)
				{
					if (BitBlt(g_hDc, (int)x, (int)y, (int)w, (int)h, g_hDcBmp, 0, 0, SRCCOPY)) {
						iRet = EXIT_SUCCESS;
					}
					DeleteObject(hGdiObj);
				} 
			}

			DeleteObject(hBmp1);
		}
	}
			
	if (iRet == EXIT_FAILURE) printf("#ERR: Failure processing output bitmap\n");
	if (outdata) free(outdata);
}

#endif

int getConsoleDim(int bH) {
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
	return bH? screenBufferInfo.dwSize.Y : screenBufferInfo.dwSize.X;
}


void wait_vblank(int maxWaitTime) {
	static long oldTime = 0;
	
	long deltaWait = oldTime+maxWaitTime - GetTickCount();
	if (deltaWait > 0)
		Sleep(deltaWait);
	oldTime = GetTickCount();
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


void processTranspBuffer(uchar *videoTransp, uchar *videoCol, uchar *videoChar, int transpcol, int dchar, int bWriteChars, int bWriteCols) {
	int i,j,k;

	transpcol &= 0xf;
	for (i = 0; i < YRES; i++) {
		k = i*XRES;
		for (j = 0; j < XRES; j++) {
			if ((videoTransp[k] & 0xf) != transpcol) {
				if (bWriteCols) videoCol[k] = videoTransp[k];
				if (bWriteChars) videoChar[k] = dchar;
			}
			k++;
		}
	}
}

void processDoubleTranspBuffer(uchar *videoColTransp, uchar *videoCharTransp, uchar *videoCol, uchar *videoChar, int transpchar, int bWriteChars, int bWriteCols) {
	int i,j,k;

	for (i = 0; i < YRES; i++) {
		k = i*XRES;
		for (j = 0; j < XRES; j++) {
			if (videoCharTransp[k] != transpchar && videoCharTransp[k] != 255) {
				if (bWriteCols) videoCol[k] = videoColTransp[k];
				if (bWriteChars) videoChar[k] = videoCharTransp[k];
			}
			k++;
		}
	}
}

void displayMessage(char *text, int x, int y, int fgcol, int bgcol, uchar *videoCol, uchar *videoChar) {
	int i;
	video = videoCol;
	line(x, y, x+strlen(text)-1, y, (bgcol << 4) | fgcol, 1);
	video = videoChar;
	if (y < YRES && y >= 0) {
		for (i=0; i < strlen(text); i++) {
			if (x + i < XRES && x + i >= 0) video[y*XRES + x + i] = text[i] == '_' ? ' ' : text[i];
		}
	}
}

void displayErrors(ErrorHandler *errH, uchar *videoCol, uchar *videoChar) {
	char opNames[20][16] = { "poly", "ipoly", "gpoly", "tpoly", "image", "box", "fbox", "line", "pixel", "circle", "fcircle", "ellipse", "fellipse", "text", "3d", "block", "insert" };
	char tstring[1028];
	int i, y = 1;

	for (i = 0; i < errH->errCnt; i++) {
		switch(errH->errType[i]) {
			case ERR_NOF_ARGS: sprintf(tstring, "#ERR %d: (op %d) '%s' missing and/or malformed parameters", i+1, errH->index[i]+1, opNames[errH->opType[i]]); break;
			case ERR_OBJECT_LOAD: case ERR_IMAGE_LOAD: sprintf(tstring, "#ERR %d: (op %d) '%s' failed to load '%s'", i+1, errH->index[i]+1, opNames[errH->opType[i]], errH->extras[i]); break;
			case ERR_PARSE: sprintf(tstring, "#ERR %d: (op %d) '%s' failed to parse/process '%s'", i+1, errH->index[i]+1, opNames[errH->opType[i]], errH->extras[i]); break;
			case ERR_MEMORY: sprintf(tstring, "#ERR %d: (op %d) '%s' memory allocation error", i+1, errH->index[i]+1, opNames[errH->opType[i]]); break;
			case ERR_OPTYPE: sprintf(tstring, "#ERR %d: (op %d) '%s' unknown operation", i+1, errH->index[i]+1, errH->extras[i]); break;
			case ERR_EXPRESSION: sprintf(tstring, "#ERR %d: (op %d) '%s' parse error in %s", i+1, errH->index[i]+1, opNames[errH->opType[i]], errH->extras[i]); break;
			default: sprintf(tstring, "#ERR %d: (op %d) '%s' unknown error", i+1, errH->index[i]+1, opNames[errH->opType[i]]);
		}
		displayMessage(tstring, 0, y, 0xa, 0x2, videoCol, videoChar);
		y++;
	}
}

void reportError(ErrorHandler *errHandler, OperationType opType, ErrorType errType, int index, char *extras) {
	int i = errHandler->errCnt;
	errHandler->errType[i] = errType;
	errHandler->opType[i] = opType;
	errHandler->index[i] = index;
	errHandler->extras[i] = NULL;
	if (extras) { errHandler->extras[i]=(char *)malloc((strlen(extras)+1) * sizeof(char)); if (errHandler->extras[i]) strcpy(errHandler->extras[i], extras); }
	errHandler->errCnt++;
	if (errHandler->errCnt >= MAX_ERRS) errHandler->errCnt = MAX_ERRS-1;
}

void reportFileError(ErrorHandler *errHandler, OperationType opType, ErrorType errType, int index, char *extras) {
	FILE *ifp;
	if (extras) {
		ifp = fopen(extras, "r");
		if (ifp) { errType = ERR_PARSE; fclose(ifp); }
	}
	reportError(errHandler, opType, errType, index, extras);
}
	
void reportArgError(ErrorHandler *errHandler, OperationType opType, int index) {
	reportError(errHandler, opType, ERR_NOF_ARGS, index, NULL);
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
	return (activeCols[(int)y * sw + (int)x]) & 0xf;
}

double my_bgcol(double x, double y) {
	if (x < 0 || y < 0 || x >= sw || y >= sh)
		return 0;
	return (activeCols[(int)y * sw + (int)x]) >> 4;
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


int transformBlock(char *s_mode, int x, int y, int w, int h, int nx, int ny, char *transf, char *colorExpr, char *xExpr, char *yExpr, int XRES, int YRES, unsigned char *videoCol, unsigned char *videoChar, int transpchar, int bFlipX, int bFlipY, int bTo, int mvx,int mvy, int mvw, int mvh) {
	uchar *blockCol, *blockChar;
	int i,j,k,k2,i2,j2, mode = 0, moveChar = 32, nofT = 0, n;
	char moveFg = 7, moveBg = 0, moveCol=7;
	int inFg, inBg, inChar;
	int outFg, outBg, outChar;
	int *m_inFg = NULL, *m_inBg = NULL, *m_inChar = NULL;
	int *m_outFg = NULL, *m_outBg = NULL, *m_outChar = NULL;

	for (i=0; i < 5; i++) store[i] = 0;
	
	if (s_mode) {
		i = 0;
		if (s_mode[i]=='1') {
			mode = 1; i+=2;
			if (s_mode[i-1] != 0 && s_mode[i] != 0) {
				moveFg = GetHex(s_mode[i]); i++;
				if (s_mode[i] != 0) {
					moveBg = GetHex(s_mode[i]); i++;
					if (s_mode[i] != 0 && s_mode[i+1] != 0) {
						sscanf(&s_mode[i], "%x", &moveChar);
					}
					moveCol = (moveBg << 4) | moveFg;
				}
			}
		}
	}
		
	sw = w, sh = h;
		
	if (x >= XRES || nx >= XRES) return 0;
	if (x+w < 0 || nx+w < 0) return 0;
	if (y >= YRES || ny >= YRES) return 0;
	if (y+h < 0 || ny+h < 0) return 0;
	if (x < 0) { w+=x; x=0; }
	if (y < 0) { h+=y; y=0; }
	if (h < 0 || w < 0) return 0;
	if (x+w >= XRES) { w-=(x+w)-XRES; }
	if (y+h >= YRES) { h-=(y+h)-YRES; }
	if (h < 0 || w < 0) return 0;
	
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

	if (mode == 1) {
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
		, {"shl", my_shl, TE_FUNCTION2},  {"shr", my_shr, TE_FUNCTION2}
		};
		te_expr *n = te_compile(colorExpr, vars, 23, &err);

		if (n) {
			blockCol2 = (uchar *)malloc(w*h*sizeof(uchar));
			blockChar2 = (uchar *)malloc(w*h*sizeof(uchar));
			activeChars = blockChar2;
			activeCols = blockCol2;

			if (!blockCol2 || !blockChar2) { if (blockCol2) free(blockCol2); if (blockChar2) free(blockChar2); free(blockChar); free(blockCol); te_free(n); return 0; }
			memcpy(blockCol2, blockCol, w*h*sizeof(uchar));
			memcpy(blockChar2, blockChar, w*h*sizeof(uchar));
			
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
			reportError(g_errH, OP_BLOCK, ERR_EXPRESSION, g_opCount, errS);
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
		, {"shl", my_shl, TE_FUNCTION2},  {"shr", my_shr, TE_FUNCTION2}
		};
		te_expr *n, *n2;
		n = te_compile(xExpr, vars, 23, &err); errX = err;
		n2 = te_compile(yExpr, vars, 23, &err);
		
		if (n && n2) {
			blockCol2 = (uchar *)malloc(w*h*sizeof(uchar));
			blockChar2 = (uchar *)malloc(w*h*sizeof(uchar));
			activeChars = blockChar2;
			activeCols = blockCol2;

			if (!blockCol2 || !blockChar2) { if (blockCol2) free(blockCol2); if (blockChar2) free(blockChar2); free(blockChar); free(blockCol); te_free(n); te_free(n2); return 0; }
			memcpy(blockCol2, blockCol, w*h*sizeof(uchar));
			memcpy(blockChar2, blockChar, w*h*sizeof(uchar));

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
				reportError(g_errH, OP_BLOCK, ERR_EXPRESSION, g_opCount, errS);
			}
			if (!n2) {
				sprintf(errS, "yExpr near character %d", err);
				reportError(g_errH, OP_BLOCK, ERR_EXPRESSION, g_opCount, errS);
			}
		}

		if (n) te_free(n);
		if (n2) te_free(n2);
	}

	if (nofT < 1) {
		for (i = 0; i < h; i++) {
			i2 = i; if (bFlipY) i2 = h-1-i;
			k = i2*w; k2=ny*XRES+i*XRES+nx;
			if (ny+i >= 0 && ny+i < YRES) {
				for (j = 0; j < w; j++) {
					j2 = j; if (bFlipX) j2 = w-1-j;
					if (nx+j >= 0 && nx+j < XRES && blockChar[k+j] != transpchar) {
						videoCol[k2+j] = blockCol[k+j2];
						videoChar[k2+j] = blockChar[k+j2];
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
						inFg = blockCol[k+j2]; inBg = outBg = inFg>>4; inFg &= 0xf; outFg = inFg;
						inChar = outChar = blockChar[k+j2];

						for (n = 0; n < nofT; n++) {
							if ((inFg == m_inFg[n] || m_inFg[n] == -1) && (inBg == m_inBg[n] || m_inBg[n] == -1) && (inChar == m_inChar[n] || m_inChar[n] == -1)) {
								if (m_outFg[n] != -1) outFg = m_outFg[n]; if (m_outFg[n] == -2) { outFg = inFg-1; if (outFg < 0) outFg = 0; } if (m_outFg[n] == -3) { outFg = inFg+1; if (outFg > 15) outFg = 15; }
								if (m_outBg[n] != -1) outBg = m_outBg[n]; if (m_outBg[n] == -2) { outBg = inBg-1; if (outBg < 0) outBg = 0; } if (m_outBg[n] == -3) { outBg = inBg+1; if (outBg > 15) outBg = 15; }
								if (m_outChar[n] != -1) outChar = m_outChar[n]; if (m_outChar[n] == -2) { outChar = inChar-1; if (outChar < 0) outChar = 0; } if (m_outChar[n] == -3) { outChar = inChar+1; if (outChar > 255) outChar = 255; }
								break;
							}
						}

						if (inChar != transpchar) {
							videoCol[k2+j] = (outBg << 4) | outFg;
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
int SaveBlock(int indexNr, int x, int y, int w, int h, int bEncode) {
	WORD oldAttrib = 6666;
	FILE *ofp = NULL;
	unsigned char ch;
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
			fgPalette[i] = bgPalette[i] = (0xff << 24) | (gr << 16) | (gg << 8) | (gb); 
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
#endif	

	
#define MAX_OBJECTS_IN_MEM 64

int main(int argc, char *argv[]) {
	uchar *videoCol, *videoChar, *videoTransp, *videoTranspChar;
	int txres, tyres, nof, opCount = 0, fgcol, bgcol, dchar, transpval;
	intVector vv[64];
	CHAR_INFO *old = NULL;
	char s_fgcol[4], s_bgcol[4], s_dchar[4], s_transpval[4], fname[128];
	int bReadKey = 0, bWaitKey = 0, bMouse = 0, mouseWait = -1, bWriteReturnToFile = 0;
	Bitmap b_pcx;
	intVector v[64];
	float us[4] = {0, 1, 1, 0}, vs[4] = {0, 0, 1, 1};
	float *averageZ, lowZ, highZ, addZ, currZ;
	unsigned char *argv1;
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
	int bAllowRepeated3dTextures = 0;
	int captX = 0, captY=0, captW, captH, captFormat=1, captureCount = 0, bCapture = 0;
	char sFlags[130];
	
#ifdef GDI_OUTPUT
	int fontIndex = 6;
	unsigned int fgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	unsigned int bgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
	int gx = 0, gy = 0;
	int bWriteGdiToFile = 0;
	int outw = 0, outh = 0;
	unsigned int orgPalette[16] = { 0xff000000, 0xff000080, 0xff008000, 0xff008080, 0xff800000, 0xff800080, 0xff808000, 0xffc0c0c0, 	0xff808080, 0xff0000ff, 0xff00ff00, 0xff00ffff, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff };
#else
	uchar fgPalette[20] = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 };
	uchar bgPalette[20] = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 };
	uchar orgPalette[20] = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 };
#endif
	int i, j, k, retVal = 0, ii, bSendKeyUp = 0;
	int bServer = 0, bDoNothing = 0, bInserted = 0, frameCounter = 0;
	HANDLE h_stdin;
	DWORD oldfdwMode;
	uchar *cp;
	long long startT = milliseconds_now();

	
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

#ifdef GDI_OUTPUT
	outw = txres; outh = tyres;
#endif

	errH.errCnt = 0;

	if (argc > 2) {
		char *fnd, fin[64];
		int nof;
		for (i=0; i < strlen(argv[2]); i++) {
			switch(argv[2][i]) {
#ifdef GDI_OUTPUT
				case 'f': 
				i++; fontIndex = GetHex(argv[2][i]);
				if (fontIndex < 0 || fontIndex > 12) fontIndex = 6; 
				if (argv[2][i+1] == ':' && argv[2][i+2]) {
					fnd = strchr(&argv[2][i+2], ';');
					if (!fnd) strcpy(fin, &argv[2][i+2]); else { nof = fnd-&argv[2][i+2]; strncpy(fin, &argv[2][i+2], nof); fin[nof]=0; }
					nof = sscanf(fin, "%d,%d,%d,%d,%d,%d", &gx, &gy, &txres, &tyres, &outw, &outh);
					if (nof >= 3 && nof < 5) outw = txres;
					if (nof >= 4 && nof < 6) outh = tyres;
				}
				break;
#endif
				case 'o': bWriteReturnToFile = 1; break;
				case 'O': bWriteReturnToFile = 2; break;
			}
		}
	}

	setResolution(txres, tyres);

	b_pcx.data = NULL;

	if (argc < 2) {
#ifdef GDI_OUTPUT
		char name[16] = "_gdi";
		char extras[128] = ", 'fn[:x,y,w,h[,outw,outh]]' use font n(0-9,default 6), 'P' read/write buffer to 'GDIbuf.dat'";
		char dspalette[256] = "Fgpalette/bgpalette follows '112233,' repeated, 1=red, 2=green, 3=blue (hex)\n\n";
#else
		char name[2] = "", extras[2] = "", dspalette[2] = "";
#endif
		printf("\nUsage: cmdgfx%s [operations] [flags] [fgpalette] [bgpalette]\n\nOperations (separated by &):\npoly     fgcol bgcol char x1,y1,x2,y2,x3,y3[,x4,y4...,y24]\nipoly    fgcol bgcol char bitop x1,y1,x2,y2,x3,y3[,x4,y4...,y24]\ngpoly    palette x1,y1,c1,x2,y2,c2,x3,y3,c3[,x4,y4,c4...,c24]\ntpoly    image fgcol bgcol char transpchar/transpcol x1,y1,tx1,ty1,x2,y2,tx2,ty2,x3,y3,tx3,ty3[...,ty24]\nimage    image fgcol bgcol char transpchar/transpcol x,y [xflip] [yflip] [w,h]\nbox      fgcol bgcol char x,y,w,h\nfbox     fgcol bgcol char x,y,w,h\nline     fgcol bgcol char x1,y1,x2,y2 [bezierPx1,bPy1[,...,bPx6,bPy6]]\npixel    fgcol bgcol char x,y\ncircle   fgcol bgcol char x,y,r\nfcircle  fgcol bgcol char x,y,r\nellipse  fgcol bgcol char x,y,rx,ry\nfellipse fgcol bgcol char x,y,rx,ry\ntext     fgcol bgcol char string x,y\nblock    mode[:1233] x,y,w,h x2,y2 [transpchar] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from] [mvx,mvy,mvw,mvh]\n3d       objectfile drawmode,drawoption rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]\ninsert   file\n\nFgcol and bgcol can be specified either as decimal or hex.\nChar is specified either as a char or a two-digit hexadecimal ASCII code.\nFor both char and fgcol+bgcol, specify ? to use existing.\nBitop: 0=Normal, 1=Or, 2=And, 3=Xor, 4=Add, 5=Sub, 6=Sub-n, 7=Normal ipoly.\n\nImage: 256 color pcx file (first 16 colors used), or gxy file, or text file.\nIf using pcx, specify transpcol, otherwise transpchar. Use -1 if not needed!\n\nGpoly palette follows '1233,' repeated, 1=fgcol, 2=bgcol, 3=char (all in hex).\nTransform follows '1233=1233,' repeated, ?+- supported. Mode 0=copy, 1=move\n\nString for text op has all _ replaced with ' '. Supports a subset of gxy codes.\n\nObjectfile should point to either a plg, ply or obj file.\nDrawmode: 0=flat/texture, 1=flat z-sourced, 2=goraud-shaded z-sourced, 3=wireframe, 4=flat, 5=persp. correct texture/flat, 6=affine char/persp col.\nDrawoption: Mode 0 textured=transpchar/transpcol(-1 if not used!). Mode 0/4 flat=bitop. Mode 1/2: 0=static col, 1=even col. Mode 1: bitop in high byte.\n\n%s[flags]: 'p' keep buffer content, 'k' return last keypress, 'K' wait for/return key, 'e/E' suppress/pause errors, 'wn/Wn' wait/await n ms, 'M/m[wait]' return key/mouse bit pattern%s, 'u' key up for M/m, 'Zn' set projection depth, 'o/O' save (/non-0) errorlevel to 'EL.dat', 'n' no output, 'z' sleep, 'S' start as server.\n", name, dspalette, extras);
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	videoCol = (uchar *)calloc(XRES*YRES,sizeof(unsigned char));
	if (videoCol == NULL) {
		printf("Error: Couldn't allocate memory for framebuffer!\n");
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	videoChar = (uchar *)calloc(XRES*YRES,sizeof(unsigned char));
	if (videoChar == NULL) {
		printf("Error: Couldn't allocate memory for framebuffer(2)!\n");
		free(videoCol);
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	videoTransp = (uchar *)malloc(XRES*YRES*sizeof(unsigned char));
	if (videoTransp == NULL) {
		printf("Error: Couldn't allocate memory for transpbuffer!\n");
		free(videoCol);
		free(videoChar);
		writeErrorLevelToFile(bWriteReturnToFile, 0, 0);
		return 0;
	}

	videoTranspChar = (uchar *)malloc(XRES*YRES*sizeof(unsigned char));
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
									videoCol[j+j2*XRES] = old[fromPos].Attributes;
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
								nofread += fread(videoCol, sizeof(unsigned char)*blockSize, 1, fp);
								nofread += fread(videoChar, sizeof(unsigned char)*blockSize, 1, fp);
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
				case 'k': bReadKey = 1; break;
				case 'K': bWaitKey = 1; break;
				case 'u': bSendKeyUp = 1; break;
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
				case 'e': bSuppressErrors = 1; break;
				case 'E': bWaitAfterErrors = 1; break;
				case 'S': bServer = 1; 	remove("EL.dat"); remove("servercmd.dat"); break;
				case 'T': bAllowRepeated3dTextures = 1; break;
				case 'z': g_bSleepingWait = 1; break;
				case 'I': g_bFlushAfterELwrite = 1; break;
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

	g_videoCol = videoCol;
	g_videoChar = videoChar;

	if (bServer)
		setvbuf ( stdin , NULL , _IOLBF , 128000 );
	
	if (bServer)
		h_stdin = CreateFile("CONIN$",GENERIC_READ|GENERIC_WRITE,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
	else
		h_stdin = GetStdHandle(STD_INPUT_HANDLE);
			
	GetConsoleMode(h_stdin, &oldfdwMode);

	/* START MAIN LOOP */ 
	strcpy(argv1, insertedArgs);
	
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
				nof = sscanf(pch, "%2s %2s %2s %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", 																			s_fgcol, s_bgcol, s_dchar, &vv[0].x, &vv[0].y, &vv[1].x, &vv[1].y, &vv[2].x, &vv[2].y,
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
					if (bWriteCols) scanConvex(vv, nofp, NULL, (bgcol << 4) | fgcol);
					video = videoChar;
					if (bWriteChars) scanConvex(vv, nofp, NULL, dchar);
				} else
					reportArgError(&errH, OP_POLY, opCount);
			}
			else if (strstr(pch,"ipoly ") == pch) {
				int bitOp;
				pch = pch + 6;
				nof = sscanf(pch, "%2s %2s %2s %d %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",																				s_fgcol, s_bgcol, s_dchar, &bitOp, &vv[0].x, &vv[0].y, &vv[1].x, &vv[1].y, &vv[2].x, &vv[2].y,
																																		&vv[3].x, &vv[3].y, &vv[4].x, &vv[4].y, &vv[5].x, &vv[5].y,
																																		&vv[6].x, &vv[6].y, &vv[7].x, &vv[7].y, &vv[8].x, &vv[8].y,
																																		&vv[9].x, &vv[9].y, &vv[10].x, &vv[10].y, &vv[11].x, &vv[11].y,
																																		&vv[12].x, &vv[12].y, &vv[13].x, &vv[13].y, &vv[14].x, &vv[14].y,
																																		&vv[15].x, &vv[15].y, &vv[16].x, &vv[16].y, &vv[17].x, &vv[17].y,
																																		&vv[18].x, &vv[18].y, &vv[19].x, &vv[19].y, &vv[20].x, &vv[20].y,
																																		&vv[21].x, &vv[21].y, &vv[22].x, &vv[22].y, &vv[23].x, &vv[23].y);
				if (nof >= 10) {
					int nofp = 3 + (nof-10) / 2;
					parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
					video = videoCol;
					if (bWriteCols) scanPoly(vv, nofp, (bgcol << 4) | fgcol, bitOp);
					video = videoChar;
					if (bWriteChars) scanPoly(vv, nofp, dchar, BIT_OP_NORMAL);
				} else
					reportArgError(&errH, OP_IPOLY, opCount);
			 }
		 else if (strstr(pch,"gpoly ") == pch) {
			char goraudPalette[512], gfgbg[256];
			int gValue[32], gchar[256];
			int m;

			memset(videoTransp, 255, XRES*YRES*sizeof(unsigned char));
			
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
				nofc = (strlen(goraudPalette)+1) / 5;
				for (i = 0; i < nofc; i++) {
					if (goraudPalette[i*5+2] == '?' && goraudPalette[i*5+3] == '?')
						gchar[i] = -1;
					else
						gchar[i] = (GetHex(goraudPalette[i*5+2]) << 4) | GetHex(goraudPalette[i*5+3]);
					gfgbg[i] = (GetHex(goraudPalette[i*5+1]) << 4) | GetHex(goraudPalette[i*5]);
				}
				video = videoTransp;
				scanConvex_goraud(vv, nofp, NULL, gValue, GORAUD_TYPE_STATIC, 0, 0,0,0);
				for (i = 0; i < YRES; i++) {
					k = i*XRES;
					for (j = 0; j < XRES; j++) {
						if (videoTransp[k] != 255) {
							m = videoTransp[k] % nofc;
							videoCol[k] = gfgbg[m];
							if (gchar[m] != -1) videoChar[k] = gchar[m];
						}
						k++;
					}
				}
			} else
				reportArgError(&errH, OP_GPOLY, opCount);
		 }
		 else if (strstr(pch,"tpoly ") == pch) {
			int bIgnoreFgCol=0, bIgnoreBgCol=0;
			int nofp, w,h;
			Bitmap b_cols, b_chars;
			
			pch = pch + 6;
			nof = sscanf(pch, "%128s %3s %3s %2s %2s %d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f,%d,%d,%f,%f", fname, s_fgcol, s_bgcol, s_dchar, s_transpval, 
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
				
				if (s_fgcol[0] == '-') { bIgnoreFgCol=1; s_fgcol[0]=s_fgcol[1]; s_fgcol[1]=s_fgcol[2]; s_fgcol[2]=0; }
				if (s_bgcol[0] == '-') { bIgnoreBgCol=1; s_bgcol[0]=s_bgcol[1]; s_bgcol[1]=s_bgcol[2]; s_bgcol[2]=0; }
				
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				
				if (strstr(fname,".pcx")) {
					if (b_pcx.data) { free(b_pcx.data); b_pcx.data = NULL; }
					if (PCXload (&b_pcx,fname)) {
						parseInput(s_transpval, s_bgcol, s_dchar, &transpval, &bgcol, &dchar, NULL, NULL);
						if (transpval < 0) {
							video = videoCol;
							if (bWriteCols) scanConvex_tmap(vv, nofp, NULL, &b_pcx, (bgcol<<4) | fgcol, 0);
							video = videoChar;
							if (bWriteChars) scanConvex(vv, nofp, NULL, dchar);
						} else {
							int ok;
							video = videoTransp;
							memset(videoTransp, transpval, XRES*YRES*sizeof(unsigned char));
							ok = scanConvex_tmap(vv, nofp, NULL, &b_pcx, (bgcol<<4) | fgcol, 0);
							if (ok) processTranspBuffer(videoTransp, videoCol, videoChar, transpval, dchar, bWriteChars, bWriteCols);
						}
					} else
						reportFileError(&errH, OP_TPOLY, ERR_IMAGE_LOAD, opCount, fname);
				} else {
					if (readGxy(fname, &b_cols, &b_chars, &w, &h, 0, dchar, 1, bIgnoreFgCol, bIgnoreBgCol)) {
						parseInput(s_fgcol, s_bgcol, s_transpval, &fgcol, &bgcol, &transpval, NULL, NULL);
						if (transpval < 0) {
							video = videoCol;
							if (bWriteCols) scanConvex_tmap(vv, nofp, NULL, &b_cols, (bgcol<<4) | fgcol, 0);
							video = videoChar;
							if (bWriteChars) scanConvex_tmap(vv, nofp, NULL, &b_chars, 0, 0);
						} else {
							int ok;
							video = videoTransp;
							memset(videoTransp, transpval, XRES*YRES*sizeof(unsigned char));
							ok = scanConvex_tmap(vv, nofp, NULL, &b_cols, bgcol<<4, 0);
							if (ok) {
								video = videoTranspChar;
								memset(videoTranspChar, transpval, XRES*YRES*sizeof(unsigned char));
								scanConvex_tmap(vv, nofp, NULL, &b_chars, 0, 0);
								processDoubleTranspBuffer(videoTransp, videoTranspChar, videoCol, videoChar, transpval, bWriteChars, bWriteCols);
							}
						}
						free(b_chars.data);
						free(b_cols.data);
					} else
						reportFileError(&errH, OP_TPOLY, ERR_IMAGE_LOAD, opCount, fname);
				}
			} else
				reportArgError(&errH, OP_TPOLY, opCount);
		 }
		 else if (strstr(pch,"fcircle ") == pch) {
			int rc,xc,yc;
			pch = pch + 8;
			nof = sscanf(pch, "%2s %2s %2s %d,%d,%d", s_fgcol, s_bgcol, s_dchar, &xc, &yc, &rc);

			if (nof == 6) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) filled_circle(xc, yc, rc, (bgcol << 4) | fgcol);
				video = videoChar;
				if (bWriteChars) filled_circle(xc, yc, rc, dchar);
			} else
				reportArgError(&errH, OP_FCIRCLE, opCount);
		}
		else if (strstr(pch,"circle ") == pch) {
			int rc,xc,yc;
			pch = pch + 7;
			nof = sscanf(pch, "%2s %2s %2s %d,%d,%d", s_fgcol, s_bgcol, s_dchar, &xc, &yc, &rc);

			if (nof == 6) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) circle(xc, yc, rc, (bgcol << 4) | fgcol);
				video = videoChar;
				if (bWriteChars) circle(xc, yc, rc, dchar);
			} else
				reportArgError(&errH, OP_CIRCLE, opCount);
		}
		else if (strstr(pch,"fellipse ") == pch) {
			int rcx,rcy,xc,yc;
			pch = pch + 9;
			nof = sscanf(pch, "%2s %2s %2s %d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &xc, &yc, &rcx, &rcy);

			if (nof == 7) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) filled_ellipse(xc, yc, rcx, rcy, (bgcol << 4) | fgcol);
				video = videoChar;
				if (bWriteChars) filled_ellipse(xc, yc, rcx, rcy, dchar);
			} else
				reportArgError(&errH, OP_FELLIPSE, opCount);
		}
		else if (strstr(pch,"ellipse ") == pch) {
			int rcx,rcy,xc,yc;
			pch = pch + 8;
			nof = sscanf(pch, "%2s %2s %2s %d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &xc, &yc, &rcx, &rcy);

			if (nof == 7) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) ellipse(xc, yc, rcx, rcy, (bgcol << 4) | fgcol);
				video = videoChar;
				if (bWriteChars) ellipse(xc, yc, rcx, rcy, dchar);
			} else
				reportArgError(&errH, OP_ELLIPSE, opCount);
		 }
		 else if (strstr(pch,"line ") == pch) {
			int x1,y1,x2,y2;
			int xPoints[9], yPoints[9];
			pch = pch + 5;
			nof = sscanf(pch, "%2s %2s %2s %d,%d,%d,%d %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &x1, &y1, &x2, &y2,
																													&xPoints[1], &yPoints[1], &xPoints[2], &yPoints[2], &xPoints[3], &yPoints[3],
																													&xPoints[4], &yPoints[4], &xPoints[5], &yPoints[5], &xPoints[6], &yPoints[6]);
			if (nof == 7) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) line(x1, y1, x2, y2, (bgcol << 4) | fgcol, 1);
				video = videoChar;
				if (bWriteChars) line(x1, y1, x2, y2, dchar, 1);
			} else
				if (nof >= 9) {
					int nofP = 2 + (nof-7)/2;
					xPoints[0] = x1; yPoints[0] = y1;
					xPoints[nofP-1] = x2; yPoints[nofP-1] = y2;
		
					parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
					video = videoCol;
					if (bWriteCols) bezier(nofP-1, xPoints, yPoints, (bgcol << 4) | fgcol);
					video = videoChar;
					if (bWriteChars) bezier(nofP-1, xPoints, yPoints, dchar);
				} else 
					reportArgError(&errH, OP_LINE, opCount);
		 }
		 else if (strstr(pch,"pixel ") == pch) {
			int x1,y1;
			pch = pch + 6;
			nof = sscanf(pch, "%2s %2s %2s %d,%d", s_fgcol, s_bgcol, s_dchar, &x1, &y1);

			if (nof == 5) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) setpixel(x1, y1, (bgcol << 4) | fgcol);
				video = videoChar;
				if (bWriteChars) setpixel(x1, y1, dchar);
			} else
				reportArgError(&errH, OP_PIXEL, opCount);
		 }
		 else if (strstr(pch,"text ") == pch) {
			Bitmap b_cols, b_chars;
			char tstring[12096];
			int x1,y1,w1,h1,xb,xdb,res;
			int writeCols;
			pch = pch + 5;
			nof = sscanf(pch, "%2s %2s %2s %12090s %d,%d", s_fgcol, s_bgcol, s_dchar, tstring, &x1, &y1);

			if (nof == 6) {
				writeCols = parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);

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
				
				res = readGxy(tstring, &b_cols, &b_chars, &w1, &h1, ((bgcol << 4) | fgcol), -1, 0, 0, 0);

				if (res) {
					for (j=0; j < h1; j++) {
						if (y1+j < YRES && y1+j >= 0) {
							xb = y1*XRES + x1 + j*XRES;
							xdb = j*w1;
							for (i=0; i < w1; i++) {
								if (x1 + i < XRES && x1 + i >= 0 && b_chars.data[xdb] != 255) { 
									if (writeCols == 3) videoCol[xb + i] = b_cols.data[xdb];
									else if (writeCols == 1) videoCol[xb + i] = (videoCol[xb + i] & 0xf0) | (b_cols.data[xdb] & 0x0f);
									else if (writeCols == 2) videoCol[xb + i] = (videoCol[xb + i] & 0x0f) | (b_cols.data[xdb] & 0xf0);
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
				reportArgError(&errH, OP_TEXT, opCount);
		 }
		 else if (strstr(pch,"image ") == pch) {
			int bIgnoreFgCol=0, bIgnoreBgCol=0;
			int x1,y1,w1,h1, res, xflip=0, yflip=0, xb, xdb, xdir=1, w2=-1, h2=-1, writeCols;
			Bitmap b_cols, b_chars;
			b_cols.data = b_chars.data = NULL;

			pch = pch + 6;
			nof = sscanf(pch, "%127s %3s %3s %2s %2s %d,%d %d %d %d,%d", fname, s_fgcol, s_bgcol, s_dchar, s_transpval, &x1, &y1, &xflip, &yflip, &w2, &h2);
			if (xflip) xdir = -1;
			if (nof >= 7) {
				if (s_fgcol[0] == '-') { bIgnoreFgCol=1; s_fgcol[0]=s_fgcol[1]; s_fgcol[1]=s_fgcol[2]; s_fgcol[2]=0; }
				if (s_bgcol[0] == '-') { bIgnoreBgCol=1; s_bgcol[0]=s_bgcol[1]; s_bgcol[1]=s_bgcol[2]; s_bgcol[2]=0; }
				writeCols = parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				if (strstr(fname, ".pcx")){
					parseInput(s_transpval, s_bgcol, s_dchar, &transpval, &bgcol, &dchar, NULL, NULL);
					res = PCXload (&b_cols,fname);
					if (res) {
						b_chars.data = (unsigned char *) malloc(b_cols.xSize*b_cols.ySize);
						if (!b_chars.data) {
							free(b_cols.data);
							res = 0;
						} else {
							for(i = 0; i < b_cols.xSize*b_cols.ySize; i++) {
								b_chars.data[i] = b_cols.data[i] == transpval? 255 : dchar;
							}
							w1 = b_cols.xSize; h1 = b_cols.ySize;
							dchar = 255;
						}
					} else
						reportFileError(&errH, OP_IMAGE, ERR_IMAGE_LOAD, opCount, fname);
				} else {
					parseInput(s_fgcol, s_bgcol, s_transpval, &fgcol, &bgcol, &transpval, NULL, NULL);
					res = readGxy(fname, &b_cols, &b_chars, &w1, &h1, ((bgcol << 4) | fgcol), dchar, 1, bIgnoreFgCol, bIgnoreBgCol);
					if (!res) reportFileError(&errH, OP_IMAGE, ERR_IMAGE_LOAD, opCount, fname);
				}

				if (res) {
					if (w2 == -1 && h2 == -1) {
						for (j=0; j < h1; j++) {
							if (y1+j < YRES && y1+j >= 0) {
								xb = y1*XRES + x1 + j*XRES;
								xdb = (yflip? (h1-1-j)*w1 : j*w1); 
								xdb += (xflip? w1-1 : 0);
								for (i=0; i < w1; i++) {
									if (x1 + i < XRES && x1 + i >= 0 && b_chars.data[xdb] != 255 && b_chars.data[xdb] != transpval) {
										if (writeCols == 3) videoCol[xb + i] = b_cols.data[xdb];
										else if (writeCols == 1) videoCol[xb + i] = (videoCol[xb + i] & 0xf0) | (b_cols.data[xdb] & 0x0f);
										else if (writeCols == 2) videoCol[xb + i] = (videoCol[xb + i] & 0x0f) | (b_cols.data[xdb] & 0xf0);
										if (bWriteChars) videoChar[xb + i] = b_chars.data[xdb];
									}
									xdb+=xdir;
								}
							}
						}
					} else { // stretched
						if (w2 <= 0 || h2 <= 0)
							reportArgError(&errH, OP_IMAGE, opCount);
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
										if (x1 + i < XRES && x1 + i >= 0 && b_chars.data[xdb] != 255 && b_chars.data[xdb] != transpval) {
											if (writeCols == 3) videoCol[xb + i] = b_cols.data[xdb];
											else if (writeCols == 1) videoCol[xb + i] = (videoCol[xb + i] & 0xf0) | (b_cols.data[xdb] & 0x0f);
											else if (writeCols == 2) videoCol[xb + i] = (videoCol[xb + i] & 0x0f) | (b_cols.data[xdb] & 0xf0);
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
				reportArgError(&errH, OP_IMAGE, opCount);
		 }
		 else if (strstr(pch,"box ") == pch) {
			int x1,y1,w,h;
			pch = pch + 4;
			nof = sscanf(pch, "%2s %2s %2s %d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &x1, &y1, &w, &h);

			if (nof == 7) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) box(x1, y1, w, h, (bgcol << 4) | fgcol);
				video = videoChar;
				if (bWriteChars) box(x1, y1, w, h, dchar);
			} else
				reportArgError(&errH, OP_BOX, opCount);
		 }
		 else if (strstr(pch,"fbox ") == pch) {
			int x1,y1,w,h;
			pch = pch + 5;
			nof = sscanf(pch, "%2s %2s %2s %d,%d,%d,%d", s_fgcol, s_bgcol, s_dchar, &x1, &y1, &w, &h);

			if (nof == 7) {
				parseInput(s_fgcol, s_bgcol, s_dchar, &fgcol, &bgcol, &dchar, &bWriteChars, &bWriteCols);
				video = videoCol;
				if (bWriteCols) fbox(x1, y1, w, h, (bgcol << 4) | fgcol);
				video = videoChar;
				if (bWriteChars) fbox(x1, y1, w, h, dchar);
			} else
				reportArgError(&errH, OP_FBOX, opCount);
		 }
		 else if (strstr(pch,"block ") == pch) {
			int x1,y1,w,h, nx,ny, xFlip = 0, yFlip = 0;
			int mvx=-1, mvy=-1, mvw=-1, mvh=-1;
			char transf[2510]= {0}, mode[8], colorExpr[1024] = {0}, xExpr[1024] = {0}, yExpr[1024] = {0}, xyExprToCh[16] = {0};

			pch = pch + 6;
			nof = sscanf(pch, "%6s %d,%d,%d,%d %d,%d %2s %d %d %2500s %1022s %1022s %1022s %10s %d,%d,%d,%d", mode, &x1, &y1, &w, &h, &nx, &ny, s_transpval, &xFlip, &yFlip, transf, colorExpr, xExpr, yExpr, xyExprToCh, &mvx, &mvy, &mvw, &mvh);
			
			transpval = -1;
			if (nof >= 7) {
				g_errH = &errH; g_opCount = opCount;
				parseInput("0", "0", s_transpval, &fgcol, &bgcol, &transpval, NULL, NULL);
				transformBlock(mode, x1, y1, w, h, nx, ny, transf, colorExpr, xExpr, yExpr, XRES, YRES, videoCol, videoChar, transpval, xFlip, yFlip, xyExprToCh[0] != 'f', mvx, mvy, mvw, mvh);
			} else
				reportArgError(&errH, OP_BLOCK, opCount);
		 }
		 else if (strstr(pch,"3d ") == pch) {
			obj3d *obj3 = NULL;
			int culling = 1, z_culling_near = 0, z_culling_far = 0;
			float scalex, scaley, scalez, modx, mody, modz, postmodx, postmody, postmodz, postmodx2 = 0, postmody2 = 0, postmodz2 = 0;
			int drawmode, drawoption;
			char s_fgcols[34][64], s_bgcols[34][4], s_dchars[34][4];
			int nofcols, nof_ext;
			int l,colIndex=0, nofFacePoints, bDrawPerspective;
			int divZ, plusZ, z_levels;;
			unsigned char pfgbg[64], fgbg;
			int m, pchar[64], pbWriteChars[64], pbWriteCols[64];
			Bitmap *paletteBmap = NULL, *bmap = NULL;
			int rx,ry,rz;
			float rrx,rry,rrz;
			int rx2=0,ry2=0,rz2=0;
			float rrx2=0,rry2=0,rrz2=0;
			int xg, yg, dist = 5500;
			float aspect;

			pch = pch + 3;

			nof = sscanf(pch, "%128s %d,%x %d:%d,%d:%d,%d:%d %f:%f,%f:%f,%f:%f %f,%f,%f,%f,%f,%f %d,%d,%d,%d %d,%d,%d,%f %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s", fname, &drawmode,&drawoption,&rx,&rx2,&ry,&ry2,&rz,&rz2,&postmodx,&postmodx2,&postmody,&postmody2,&postmodz,&postmodz2,&scalex,&scaley,&scalez,&modx,&mody,&modz,&culling,&z_culling_near,&z_culling_far,&z_levels,&xg,&yg,&dist,&aspect,
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
				nof = sscanf(pch, "%128s %d,%x %d:%d,%d:%d,%d:%d %f,%f,%f %f,%f,%f,%f,%f,%f %d,%d,%d,%d %d,%d,%d,%f %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s", fname, &drawmode,&drawoption,&rx,&rx2,&ry,&ry2,&rz,&rz2,&postmodx,&postmody,&postmodz,&scalex,&scaley,&scalez,&modx,&mody,&modz,&culling,&z_culling_near,&z_culling_far,&z_levels,&xg,&yg,&dist,&aspect,
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
					nof = sscanf(pch, "%128s %d,%x %d,%d,%d %f,%f,%f %f,%f,%f,%f,%f,%f %d,%d,%d,%d %d,%d,%d,%f %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s %62s %2s %2s", fname, &drawmode,&drawoption,&rx,&ry,&rz,&postmodx,&postmody,&postmodz,&scalex,&scaley,&scalez,&modx,&mody,&modz,&culling,&z_culling_near,&z_culling_far,&z_levels,&xg,&yg,&dist,&aspect,
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
				nofcols = 1+(nof-26)/3;
				for (i = 0; i < MAX_OBJECTS_IN_MEM; i++) {
					if (objNames[i] && strstr(fname, objNames[i])) {
						obj3 = objs[i]; break;
					}
				}

				g_errH = &errH; g_opCount = opCount;

				if (!obj3) {
					if (strstr(fname,".obj"))
						obj3 = readObj(fname, 1, 0,0,0, 0, readCmdGfxTexture, bAllowRepeated3dTextures);
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
						
						objCnt++;
						if (objCnt >= MAX_OBJECTS_IN_MEM) objCnt = 0;				
					}
				}

				if (obj3) {
					if (drawmode == 2)
						memset(videoTransp, 255, XRES*YRES*sizeof(unsigned char));

					for (i = 0; i < nofcols; i++) {
						parseInput(s_fgcols[i%nofcols], s_bgcols[i%nofcols], s_dchars[i%nofcols], &fgcol, &bgcol, &pchar[i], &pbWriteChars[i], &pbWriteCols[i]);
						pfgbg[i] = (bgcol << 4) | fgcol;
					}

					for (j = 0; j < obj3->nofPoints; j++) {
						obj3->objData[j].x = (obj3->objData[j].ox + modx) * scalex;
						obj3->objData[j].y = (obj3->objData[j].oy + mody) * scaley;
						obj3->objData[j].z = (obj3->objData[j].oz + modz) * scalez;
					}

					rrx = (float)(rx/4) * 3.14159265359 / 180.0;
					rry = (float)(ry/4) * 3.14159265359 / 180.0;
					rrz = (float)(rz/4) * 3.14159265359 / 180.0;

					if (rx2 == 0 && ry2 == 0 && rz2 == 0 && postmodx2 == 0 && postmody2 == 0 && postmodz2 == 0) {
						rot3dPoints(obj3->objData, obj3->nofPoints, xg, yg, dist, rrx, rry, rrz, aspect, postmodx, postmody, postmodz, z_culling_near != 0, projectionDepth);
					} else {
						rrx2 = (float)(rx2/4) * 3.14159265359 / 180.0;
						rry2 = (float)(ry2/4) * 3.14159265359 / 180.0;
						rrz2 = (float)(rz2/4) * 3.14159265359 / 180.0;

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

					 if (z_levels < 10) z_levels = 10;
					 addZ = (highZ - lowZ) / z_levels;
					 currZ = highZ;
					 
					 divZ = (highZ - lowZ) / nofcols;
					 plusZ = -(lowZ / divZ);
					 
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
													if (videoTransp[k] != 255) {
														m = videoTransp[k] - 8;
														if (m < 0 ) m = 0;
														if (m >= nofcols) m = nofcols - 1;
														
														if (pbWriteCols[m]) videoCol[k] = pfgbg[m];
														if (pbWriteChars[m]) videoChar[k] = pchar[m];
													}
													k++;
												}
											}
											memset(videoTransp, 255, XRES*YRES*sizeof(unsigned char));
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
							
							if (bmap && bmap->data && bmap->bCmdBlock && bmap->blockRefresh > 0 && obj3->nofBmaps > 0) {
								int ok;
								freeBitmap(bmap, 0);	
								ok = readCmdGfxTexture(bmap, bmap->pathOrBlockString);
								if (bmap->blockRefresh != 2) bmap->blockRefresh = 0;
								if (!ok) bmap = NULL;
							}
										
							if (averageZ[j] != 99999999 && averageZ[j] >= currZ && averageZ[j] <= currZ + addZ) {
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

									if (drawmode == 0 || drawmode == 4 || drawmode == 5 || drawmode == 6) {
										fgbg = pfgbg[colIndex%nofcols]; dchar = pchar[colIndex%nofcols];
										bWriteChars = pbWriteChars[colIndex%nofcols]; bWriteCols = pbWriteCols[colIndex%nofcols];

										video = videoCol;
										
										if (obj3->nofBmaps > 0 && bmap && bmap->data && (drawmode == 0 || drawmode == 5 || drawmode == 6)) {
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
											
											if (transpval >= 0) {
												int ok;											
												video = videoTransp;
												memset(videoTransp, transpval, XRES*YRES*sizeof(unsigned char));
												ok = scanConvex_tmap(v, nofFacePoints, NULL, bmap, fgbg, bDrawPerspective);
												if (ok) {
													if (bmap->extras && bmap->extrasType == EXTRAS_BITMAP) {
														video = videoTranspChar;
														memset(videoTranspChar, transpval, XRES*YRES*sizeof(unsigned char));
														scanConvex_tmap(v, nofFacePoints, NULL, (Bitmap *)bmap->extras, 0, bDrawPerspective);
														processDoubleTranspBuffer(videoTransp, videoTranspChar, videoCol, videoChar, transpval, bWriteChars, bWriteCols);
													} else
														processTranspBuffer(videoTransp, videoCol, videoChar, transpval, dchar, bWriteChars, bWriteCols);
												}
											} else {
												if (bWriteCols) scanConvex_tmap(v, nofFacePoints, NULL, bmap, fgbg, bDrawPerspective);
												video = videoChar;
												if (bWriteChars) {
													if (bmap->extras && bmap->extrasType == EXTRAS_BITMAP)
														scanConvex_tmap(v, nofFacePoints, NULL, (Bitmap *)bmap->extras, 0, bDrawPerspective);
													else
														scanConvex(v, nofFacePoints, NULL, dchar);
												}
											}
										} else {
											if (nofFacePoints > 2) {
												if (drawoption > 0 && drawoption <= BIT_NORMAL_IPOLY) {
													int option = drawoption; if (option == BIT_NORMAL_IPOLY) option=0;
													if (bWriteCols) scanPoly(v, nofFacePoints, fgbg, option);
													video = videoChar;
													if (bWriteChars) scanPoly(v, nofFacePoints, dchar, BIT_OP_NORMAL);
												} else {
													if (bWriteCols) scanConvex(v, nofFacePoints, NULL, fgbg);
													video = videoChar;
													if (bWriteChars) scanConvex(v, nofFacePoints, NULL, dchar);
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
												zcol += v[l].z/25+16;
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
											if ((drawoption>>4) > 0 && (drawoption>>4) <= BIT_NORMAL_IPOLY) {
												int option = drawoption>>4; if (option == BIT_NORMAL_IPOLY) option=0;
												if (bWriteCols) scanPoly(v, nofFacePoints, fgbg, option);
												video = videoChar;
												if (bWriteChars) scanPoly(v, nofFacePoints, dchar, BIT_OP_NORMAL);
											} else {
												if (bWriteCols) scanConvex(v, nofFacePoints, NULL, fgbg);
												video = videoChar;
												if (bWriteChars) scanConvex(v, nofFacePoints, NULL, dchar);
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
						currZ = currZ - addZ;
					}

					if (drawmode == 2 ) {
						for (i = 0; i < YRES; i++) {
							k = i*XRES;
							for (j = 0; j < XRES; j++) {
								if (videoTransp[k] != 255) {
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
					reportFileError(&errH, OP_3D, ERR_OBJECT_LOAD, opCount, fname);

				// stupid strtok, I use it in the load functions for plg and obj files, thus screwing up the existing strtok. Rereading, ugly fix...
				strcpy(argv1, insertedArgs);
				pch = strtok(argv1, "&");
				for (i = 0; i < opCount; i++) { pch = strtok (NULL, "&"); }

			}
			else
				reportArgError(&errH, OP_3D, opCount);
		}	else if (strstr(pch,"skip ") == pch) {
			// do nothing
		} else {
			char faultyOp[42], *fnd;
			strncpy(faultyOp, pch, 40);
			faultyOp[40] = 0;
			fnd = strchr(faultyOp, ' ');
			if (fnd) *fnd = 0;
			if (faultyOp[0])
				reportError(&errH, OP_UNKNOWN, ERR_OPTYPE, opCount, faultyOp);
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
			convertToGdiBitmap(XRES, YRES, videoCol, videoChar, fontIndex, &fgPalette[0], &bgPalette[0], gx, gy, outw, outh);
		//	convertToGdiBitmap(XRES, YRES, videoCol, videoChar, fontIndex, &fgPalette[0][0], &bgPalette[0][0], gx, gy);
			
			if (bWriteGdiToFile) {
					FILE *fp = fopen("GDIbuf.dat", "wb");
					if (fp != NULL) {
						int blockSize;
						fwrite(&XRES, sizeof(int), 1, fp);
						fwrite(&YRES, sizeof(int), 1, fp);
						blockSize = XRES * YRES;
						fwrite(videoCol, sizeof(unsigned char), blockSize, fp);
						fwrite(videoChar, sizeof(unsigned char), blockSize, fp);
					}
			}
	#else
			if (bPaletteSet)
				convertToText(XRES, YRES, videoCol, videoChar, fgPalette, bgPalette);
			else
				convertToText(XRES, YRES, videoCol, videoChar, NULL, NULL);
	#endif
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
			if (bServer)
				h_stdin = CreateFile("CONIN$",GENERIC_READ|GENERIC_WRITE,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
			else
				h_stdin = GetStdHandle(STD_INPUT_HANDLE);
			
			//GetConsoleMode(h_stdin, &oldfdwMode);

			fdwMode = oldfdwMode | ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT;
			fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
			SetConsoleMode(h_stdin, fdwMode);
			
			bOk = 1;
			if (mouseWait > -1) {
				res = WaitForSingleObject(h_stdin, mouseWait);
				// bug is reason it works. Don't reset old fdwMode in non-server mode
				if (res & WAIT_TIMEOUT) { if (!bServer) { process_waiting(bWait, waitTime, bServer); writeErrorLevelToFile(bWriteReturnToFile, -1, bMouse); /* SetConsoleMode(h_stdin, oldfdwMode); */ return -1; } else bOk = 0; }
			}

			res = -1;
			if (bOk)
				ReadConsoleInput(h_stdin, irInBuf, 128, &cNumRead);
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
					irInBuf[i].Event.KeyEvent.bKeyDown = 1; WriteConsoleInput(h_stdin, &irInBuf[i], 1, &iOut);
					irInBuf[i].Event.KeyEvent.bKeyDown = 0; WriteConsoleInput(h_stdin, &irInBuf[i], 1, &iOut);
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
				res2 = WaitForSingleObject(h_stdin, 1);
				if (!(res2 & WAIT_TIMEOUT))
					ReadConsoleInput(h_stdin, irInBuf, 128, &cNumRead);			

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
			FILE	*flushFile;

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

				frameCounter++;
				
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
							case 'u': bSendKeyUp = neg? 0 : 1; break;
							case 'e': bSuppressErrors = neg? 0 : 1; break;
							case 'E': bWaitAfterErrors = neg? 0 : 1; break;
							case 'o': bWriteReturnToFile = neg? 0 : 1; break;
							case 'O': bWriteReturnToFile = neg? 0 : 2; break;
							case 'C': frameCounter = 0; startT = milliseconds_now(); break;
							case 'T': bAllowRepeated3dTextures = neg? 0 : 1; break;
							case 'z': g_bSleepingWait = neg? 0 : 1; break;				
							case 'I': g_bFlushAfterELwrite = neg? 0 : 1; break;
							
#ifdef GDI_OUTPUT
							case 'f': 
							{
								int oldtx=txres, oldty=tyres;
								char *fnd, fin[64];
								int nof;
								i++; fontIndex = GetHex(pch[i]);
								if (fontIndex < 0 || fontIndex > 12) fontIndex = 6; 
								if (pch[i+1] == ':' && pch[i+2]) {
									fnd = strchr(&pch[i+2], ';');
									if (!fnd) strcpy(fin, &pch[i+2]); else { nof = fnd-&pch[i+2]; strncpy(fin, &pch[i+2], nof); fin[nof]=0; }
									nof = sscanf(fin, "%d,%d,%d,%d,%d,%d", &gx, &gy, &txres, &tyres, &outw, &outh);
									if (nof >= 3 && nof < 5) outw = txres;
									if (nof >= 4 && nof < 6) outh = tyres;
								}
							
								if (oldtx != txres || oldty != tyres) {
									setResolution(txres, tyres);
									free(videoCol); free(videoChar);	free(videoTransp); free(videoTranspChar);
									videoCol = (uchar *)calloc(XRES*YRES,sizeof(unsigned char));
									videoChar = (uchar *)calloc(XRES*YRES,sizeof(unsigned char));
									videoTransp = (uchar *)malloc(XRES*YRES*sizeof(unsigned char));
									videoTranspChar = (uchar *)malloc(XRES*YRES*sizeof(unsigned char));
									g_videoCol = videoCol;
									g_videoChar = videoChar;
									if (!videoCol || !videoChar || !videoTransp || !videoTranspChar) {
										printf("\nPANIC: Server could not re-allocate space for buffer!\n\nExit server...\n");
										return 0;
									}
								}
								break;
							}
#endif
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

	for (i = 0; i < errH.errCnt; i++) if (errH.extras[i]) free(errH.extras[i]);
	errH.errCnt = 0;

#ifdef GDI_OUTPUT
	if (g_hDc) ReleaseDC(g_hWnd, g_hDc);
	if (g_hDcBmp) ReleaseDC(g_hWnd, g_hDcBmp);
#endif
	
	if (b_pcx.data) free(b_pcx.data);
	free(averageZ);
	free(argv1);
	
	SetConsoleMode(h_stdin, oldfdwMode);

	return retVal;
}
