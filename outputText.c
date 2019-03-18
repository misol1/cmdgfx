#include "outputText.h"

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

	a.X = w;
	a.Y = h;

	r.Left = x;
	r.Top = y;
	r.Right = x + w;
	r.Bottom = y + h;
	ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str, a, b, &r);
	return str;
}

void clrScr(int color, int scale, int SCR_XRES, int SCR_YRES) {
	CHAR_INFO *str;
	COORD a, b;
	SMALL_RECT r;
	HANDLE hCurrHandle;
	int i;

	a.X = SCR_XRES/scale;
	a.Y = SCR_YRES/scale;
	
	hCurrHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * (a.X * a.Y));
	if (!str) return;

	for (i = 0; i < a.X*a.Y; i++) {
		str[i].Char.AsciiChar = ' ';
		str[i].Attributes = color << 4;
	}
	
	b.X = b.Y = 0;
	r.Left = 0;
	r.Top = 0;
	r.Right = a.X;
	r.Bottom = a.Y;
	WriteConsoleOutput(hCurrHandle, str, a, b, &r);
	free(str);
}


char DecToHex(int i) {
	switch(i) {
	case 0:case 1:case 2:case 3:case 4:case 5:case 6:case 7:case 8:case 9: i=i+'0'; break;
	case 10:case 11:case 12:case 13:case 14:case 15: i = 'A'+(i-10); break;
	default: i = '0';
	}
	return i;
}

char *GetAttribs(WORD attributes, char *utp, int transpChar, int transpBg, int transpFg) {
	int i;
	utp[0] = '\\';
	utp[1] = DecToHex(attributes & 0xf); if ((attributes & 0xf)==transpFg && transpChar < 0) utp[1]='v';
	utp[2] = DecToHex((attributes >> 4) & 0xf); if (((attributes>>4) & 0xf)==transpBg && transpChar < 0) utp[2]='V';
	utp[3] = 0;
	return utp;
}

#define BUF_SIZE 64000
#define STR_SIZE 12000

int saveScreenBlock(char *filename, int x, int y, int w, int h, int bEncode, int transpChar, int transpBg, int transpFg) {
	COORD a = { 1, 1 };
	COORD b = { 0, 0 };
	SMALL_RECT r;
	CHAR_INFO *str;
	char *output, attribS[16], charS[8];
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	WORD oldAttrib = 6666;
	FILE *ofp = NULL;
	int i, j;
	uchar ch;
	char fName[512];

	sprintf(fName, "%s.gxy", filename);
	ofp = fopen(fName, "w");
	if (!ofp) return 1;

	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
	if (y > screenBufferInfo.dwSize.Y || y < 0) return 2;
	if (x > screenBufferInfo.dwSize.X || x < 0) return 2;
	if (y+h > screenBufferInfo.dwSize.Y || h < 1) return 2;
	if (x+w > screenBufferInfo.dwSize.X || w < 1) return 2;

	output = (char*) malloc(BUF_SIZE);
	if (!output) return 3;
	output[0] = 0;
	str = (CHAR_INFO *) malloc (sizeof(CHAR_INFO) * STR_SIZE);
	if (!str) {
		free(output);
		return 3;
	}

	a.X = w;
	a.Y = h;

	r.Left = x;
	r.Top = y;
	r.Right = x + w;
	r.Bottom = y + h;
	ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), str, a, b, &r);

	for (j=0; j < h; j++) {
		output[0]=0;
		for (i=0; i < w; i++) {
			ch = str[i + j*w].Char.AsciiChar;
			if ((ch==transpChar && transpChar >-1) && (transpFg == -1 || transpFg == (str[i + j*w].Attributes & 0xf))  && (transpBg == -1 || transpBg == ((str[i + j*w].Attributes>>4) & 0xf)) ) {
				charS[0] = '\\'; charS[1]='-'; charS[2]=0;
			}
			else if (bEncode || ch=='\\') {
				if (bEncode > 1 || !(ch ==32 || (ch >='0' && ch <='9') || (ch >='A' && ch <='Z') || (ch >='a' && ch <='z'))) {
					int v;
					charS[0] = '\\'; charS[1] = 'g';
					v = ch / 16; charS[2]=DecToHex(v);
					v = ch % 16; charS[3]=DecToHex(v);
					charS[4]=0;
				}else {
					charS[0] = ch; charS[1]=0;
				}
			} else {
				charS[0] = ch; charS[1]=0;
			}

			if (oldAttrib == str[i + j*w].Attributes)
			sprintf(output, "%s%s", output, charS);
			else
			sprintf(output, "%s%s%s", output, GetAttribs(str[i + j*w].Attributes, attribS, transpChar, transpBg, transpFg), charS);
			oldAttrib = str[i + j*w].Attributes;
		}
		fprintf(ofp, "%s\\n", output);
	}

	free(str);
	free(output);

	fclose(ofp);
	return 0;
}


void convertToText(int mode, int scale, int palette[], int startx, int starty, CHAR_INFO *old, int mapIndex, int XRES, int YRES, uchar *video) {
	CHAR_INFO *str;
	COORD a, b;
	int col, ct;
	SMALL_RECT r;
	int scaleplus = 1;
	HANDLE hCurrHandle;
	char map[4][8] = { { 32, 0xb0, 0xb1, 0xb2, 0xdb }, { 32, '.', ':', 'k', '#' }, { 32, '.', ':', 'k', '#' }};
	char map2vary[16] = "##M7W8%KXZQAE3BQ";
	int i, j, m;

	if (scale == 1) scaleplus = 4;
	
	a.X = XRES/scale;
	a.Y = YRES/scale;
	
	hCurrHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	str = (CHAR_INFO *) calloc (sizeof(CHAR_INFO) * (a.X * a.Y), 1);
	if (!str) return;

	for (i = startx; i < a.Y; i++) {
		for (j = starty; j < a.X; j++) {
			int k = 0;
			int l = i * XRES *scale + j*scale;
			col = 0;
			ct = video[l]; if (ct > 0) { k+=scaleplus; col=ct; }
			if (scale > 1) {
				ct = video[l+1]; if (ct > 0) { k++; col=ct; }
				ct = video[l+XRES]; if (ct > 0) { k++; col=ct; }
				ct = video[l+XRES+1]; if (ct > 0) { k++; col=ct; }
			}

			m = i*a.X + j;
			str[m].Char.AsciiChar = map[mapIndex][k];
			if (mapIndex == 2 && k == 4) str[m].Char.AsciiChar = map2vary[col%16];
			str[m].Attributes = palette[col];
			if (palette[col] == -1) {
				str[m].Char.AsciiChar = map[mapIndex][2];
				if (k > 2)
				str[m].Attributes = palette[col-1] | (palette[col+1] << 4);
				else
				str[m].Attributes = palette[col-1];
			}
			if (old && k == 0) {
				str[m].Char.AsciiChar = old[m].Char.AsciiChar;
				str[m].Attributes = old[m].Attributes;
			}
			if (old && mode && (col > 9 || mode == 1))
			str[m].Char.AsciiChar = old[m].Char.AsciiChar;
		}
	}

	b.X = b.Y = 0;
	r.Left = 0;
	r.Top = 0;
	r.Right = a.X;
	r.Bottom = a.Y;
	WriteConsoleOutput(hCurrHandle, str, a, b, &r);

	free(str);
}

void setDefaultTextPalette(int palette []) {
	int i;
	for (i = 0; i < 255; i++)
	palette[i] = i % 16;
}

void setTextPalette(int palette[], int index, int cols[], int nof) {
	int i, j = 0;
	for (i = index; i < index + nof; i++)
	palette[i] = cols[j++];
}

int getConsoleDim(int bH) {
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &screenBufferInfo);
	return bH? screenBufferInfo.dwSize.Y : screenBufferInfo.dwSize.X;
}
