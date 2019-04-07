// gfx.h
#include <stdio.h>
#include "datasize.h"

#ifndef GFXH
#define GFXH

#define repeat do
#define until(a) while(!(a)) 

typedef struct Vector {
	float x, y, z;
} Vector;

typedef struct intVector {
	int x, y;
	float z;
	Vector tex_coord;
} intVector;

extern int XRES, YRES;
extern int FRAMESIZE;
extern uchar *video;
extern int bAllowRepeated3dTextures;
extern float texture_offset_x, texture_offset_y;
extern float *ZBufVideo;


#define GORAUD_TYPE_STATIC	0
#define GORAUD_TYPE_Z		1

#define BIT_OP_NORMAL		0
#define BIT_OP_OR			1
#define BIT_OP_AND			2
#define BIT_OP_XOR			3
#define BIT_OP_ADD			4
#define BIT_OP_SUB			5
#define BIT_OP_SUB_ME		6
#define BIT_NORMAL_IPOLY	7
#define BIT_OP_ADD_REAL		8
#define BIT_OP_SUB_REAL		9
#define BIT_OP_SUB_ME_REAL	10

#ifdef _RGB32
#define BIT_OP_ADD_FGRGB	16
#define BIT_OP_ADD_RGB		17
#define BIT_OP_SUB_FGRGB	18
#define BIT_OP_SUB_RGB		19
#define BIT_OP_BLEND_FGRGB	20
#define BIT_OP_BLEND_RGB	21
#endif

int scan3(intVector vv[], int clipedges[], uchar col);
int scan3_goraud(intVector vv[], int clipedges[], int I[], int goraudType, PREPCOL plusVal, int divZ, int plusZ, int maxZ);
int scan3_tmap(intVector vv[], int clipedges[], Bitmap *tex, PREPCOL plusVal);
int scanPoly(intVector p[],int points, uchar col, uchar bitOp);
int scanConvex(intVector vv[], int points, int clipedges[], uchar col);
int scanConvex_goraud(intVector vv[], int points, int clipedges[], int I[], int goraudType, PREPCOL plusVal, int divZ, int plusZ, int maxZ);
int scanConvex_tmap(intVector vv[], int points, int clipedges[], Bitmap *bild, PREPCOL plusVal, int bPerspectiveCorrected);
void polyLine(intVector v[], int points, uchar col, uchar connect, int clip);
void circle(int x, int y, int radius, uchar col);
void ellipse(int xc, int yc, int rx, int ry, uchar col);
void filled_ellipse(int xc, int yc, int rx, int ry, uchar col);
void filled_circle(int xc, int yc, int radius, uchar col);
void box (int x, int y, int xrange, int yrange, uchar col);
void fbox(int x, int y, int xrange, int yrange, uchar col);
void line(int x1, int y1, int x2, int y2, uchar col, int clip); 
void vline(int x, int y1, int y2, uchar col); 
void hline(int x1, int x2, int y, uchar col); 
int line_clip(int *x1, int *y1, int *x2, int *y2);
void setpixel(int x, int y, uchar col);
void bezier(long n, int *xPoints, int *yPoints, uchar col);

int __scan3(intVector vv[], uchar col);
int __scanConvex(intVector vv[], int points, uchar col);
#endif
