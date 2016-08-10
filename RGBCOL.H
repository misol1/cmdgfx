// RGBcol.h

#ifndef RGBCOLH
#define RGBCOLH

#include <stdlib.h>
#include <string.h>

typedef struct RGBcol {
  unsigned char R, G, B;
} RGBcol;

typedef struct RGBcol_float {
  float fR,fG,fB;
  float dR,dG,dB;
} RGBcol_float;

// Palette
void setcol(unsigned char col, unsigned char R, unsigned char G, unsigned char B);
void setpalette(int start, int range, RGBcol cols[]);
void savecols(RGBcol cols[], int start, int range);
void fadecols(RGBcol from[], RGBcol to[], int start, int range);
void evenfade_init(RGBcol from[], RGBcol to[], RGBcol_float dto[], int start, int range, float steps);
void evenfade_cols(RGBcol cols[], RGBcol_float dto[], int start, int range);
void palcycle (RGBcol cols[], int start, int range, int cycleval);

#endif
