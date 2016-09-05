// rgbcol.c

#include "rgbcol.h"
/*
void setpalette(int start, int range, RGBcol cols[]) {
int i, j=0;

for (i=start; i<start+range; i++) {
	setcol(i, cols[j].R, cols[j].G, cols[j].B);
	j++;
}
}

void setcol(unsigned char col, unsigned char R, unsigned char G, unsigned char B) {
outportb(0x3C8,col);
outportb(0x3C9,R);
outportb(0x3C9,G);
outportb(0x3C9,B);
}

void savecols(RGBcol cols[], int start, int range) {
int i;

for (i=start; i<start+range; i++) {
	outportb(0x03c7,i);
	cols[i].R=inportb(0x03c9);  // R”d
	cols[i].G=inportb(0x03c9); // Gr”n
	cols[i].B=inportb(0x03c9); // Bl†
}
}
*/
void fadecols(RGBcol from[], RGBcol to[], int start, int range) {
	int i;

	for (i=start; i<start+range; i++) {
		if(to[i].R<from[i].R)
		to[i].R++;
		else if (to[i].R>from[i].R)
		to[i].R--;
		if(to[i].G<from[i].G)
		to[i].G++;
		else if (to[i].G>from[i].G)
		to[i].G--;
		if(to[i].B<from[i].B)
		to[i].B++;
		else if (to[i].B>from[i].B)
		to[i].B--;
	}
}

void evenfade_init(RGBcol from[], RGBcol to[], RGBcol_float dto[], int start, int range, float steps) {
	int i;

	for (i=start; i<start+range; i++) {
		dto[i].dR=(float)(from[i].R-to[i].R)/steps;
		dto[i].fR=to[i].R;
		dto[i].dG=(float)(from[i].G-to[i].G)/steps;
		dto[i].fG=to[i].G;
		dto[i].dB=(float)(from[i].B-to[i].B)/steps;
		dto[i].fB=to[i].B;
	}
}

void evenfade_cols(RGBcol cols[], RGBcol_float dto[], int start, int range) {
	int i;

	for (i=start; i<start+range; i++) {
		cols[i].R=dto[i].fR=dto[i].fR+dto[i].dR;
		cols[i].G=dto[i].fG=dto[i].fG+dto[i].dG;
		cols[i].B=dto[i].fB=dto[i].fB+dto[i].dB;
	}
}

void palcycle (RGBcol cols[], int start, int range, int cycleval) {
	RGBcol temp[256];
	if (!cycleval) return;

	if (cycleval>0) {
		memcpy(temp,&(cols[start+range-cycleval]),sizeof(RGBcol)*cycleval);
		memmove(&(cols[start+cycleval]),&(cols[start]),sizeof(RGBcol)*range);
		memcpy(&(cols[start]),temp,sizeof(RGBcol)*cycleval);
	}
	else {
		memcpy(temp,&(cols[start]),sizeof(RGBcol)*abs(cycleval));
		memmove(&(cols[start]),&(cols[start+abs(cycleval)]),sizeof(RGBcol)*range);
		memcpy(&(cols[start+range-abs(cycleval)]),temp,sizeof(RGBcol)*abs(cycleval));
	}
}

