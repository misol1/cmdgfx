#include <stdio.h>
#include <string.h>
#include <windows.h>

CHAR_INFO * readScreenBlock();
void clrScr(int color, int scale, int SCR_XRES, int SCR_YRES);
void convertToText(int mode, int scale, int palette[], int startx, int starty, CHAR_INFO *old, int mapIndex, int XRES, int YRES, unsigned char *video);

int saveScreenBlock(char *filename, int x, int y, int w, int h, int bEncode, int transpChar, int transpBg, int transpFg);

void setDefaultTextPalette(int palette []);
void setTextPalette(int palette[], int index, int cols[], int nof);

int getConsoleDim(int bH);
