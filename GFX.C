// gfx.c

#include "gfxlib.h"
#include "r3d.h"
#include <math.h>

void setpixel(int x, int y, uchar col) {

	if(x>=0 && x<XRES && y>=0 && y<YRES)
		video[y*XRES + x] = col;
}

int scanConvex(intVector vv[], int points, int clipedges[], uchar col) {
	intVector v[3];
	register int i;
	int ok = 0;

	memcpy(v,vv,sizeof(intVector));
	if (points<3) return 0;
	for (i=1; i<points-1; i++) {
		memcpy(&(v[1]),&(vv[i]),sizeof(intVector)<<1);
		ok += scan3(v, clipedges, col);
	}
	return (ok > 0);
}

int drawtpolyperspdivsubtri(intVector *tri, Bitmap *bild, PREPCOL plusVal);
int drawtpolyperspsubtri(intVector *tri, Bitmap *bild, PREPCOL plusVal);

int scanConvex_tmap_perspective(intVector vv[], int points, int clipedges[], Bitmap *bild, PREPCOL plusVal) {
	intVector v[3];
	register int i,j;
	int ok = 0;
	int bTexRepOrg = bAllowRepeated3dTextures;
	
	if (points < 3) return 0;
	
	if (texture_offset_x != 0 || texture_offset_y != 0) {
		bAllowRepeated3dTextures = 1;
	
		for (i=0; i<points; i++) {
			vv[i].tex_coord.x += texture_offset_x;
			vv[i].tex_coord.y += texture_offset_y;
		}
	}

	memcpy(v,vv,sizeof(intVector));
	v[0].tex_coord.x *= (float)bild->xSize - 1;
	v[0].tex_coord.y *= (float)bild->ySize - 1;
	v[0].tex_coord.z = 1;
	
	v[0].z += bild->projectionDistance;
	if (v[0].z < MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION) v[0].z = MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION;
	
	for (i=1; i<points-1; i++) {
		memcpy(&(v[1]),&(vv[i]),sizeof(intVector)<<1);
		for (j=1; j<3; j++) {
			v[j].tex_coord.x *= (float)bild->xSize - 1;
			v[j].tex_coord.y *= (float)bild->ySize - 1;
			v[j].tex_coord.z = 1;
			
			// adjust z values to what we actually divided with in perspective projection
			v[j].z += bild->projectionDistance;
			if (v[j].z < MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION) v[j].z = MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION;
		}

//		ok += drawtpolyperspdivsubtri(v, bild, plusVal); // works properly only with 256x256 textures
		ok += drawtpolyperspsubtri(v, bild, plusVal);
	}
	
	bAllowRepeated3dTextures = bTexRepOrg;
	
	return (ok > 0);
}


int scanConvex_tmap(intVector vv[], int points, int clipedges[], Bitmap *bild, PREPCOL plusVal, int bPerspectiveCorrected) {
	intVector v[3];
	register int i,j;
	int ok = 0;
	int bTexRepOrg = bAllowRepeated3dTextures;
	
	if (points < 3) return 0;

	if (bPerspectiveCorrected) {
		return scanConvex_tmap_perspective(vv, points, clipedges, bild, plusVal);
	}

	if (texture_offset_x != 0 || texture_offset_y != 0) {
		bAllowRepeated3dTextures = 1;
	
		for (i=0; i<points; i++) {
			vv[i].tex_coord.x += texture_offset_x;
			vv[i].tex_coord.y += texture_offset_y;
		}
	}

	memcpy(v,vv,sizeof(intVector));
	
	v[0].tex_coord.x *= (float)bild->xSize - 1;
	v[0].tex_coord.y *= (float)bild->ySize - 1;
	v[0].tex_coord.z = 1;
	for (i=1; i<points-1; i++) {
		memcpy(&(v[1]),&(vv[i]),sizeof(intVector)<<1);
		for (j=1; j<3; j++) {
			v[j].tex_coord.x *= (float)bild->xSize - 1;
			v[j].tex_coord.y *= (float)bild->ySize - 1;
			v[j].tex_coord.z = 1;
		}
		ok += scan3_tmap(v, clipedges, bild,plusVal);
	}
	
	bAllowRepeated3dTextures = bTexRepOrg;
	
	return (ok > 0);
}


int scanConvex_goraud(intVector vv[], int points, int clipedges[], int I[], int goraudType, PREPCOL plusVal, int divZ, int plusZ, int maxZ) {
	intVector v[3];
	int I2[3];
	register int i;
	int ok = 0;

	memcpy(v,vv,sizeof(intVector));
	memcpy(I2,I,sizeof(int));
	if (points<3) return 0;
	for (i=1; i<points-1; i++) {
		memcpy(&(v[1]),&(vv[i]),sizeof(intVector)<<1);
		memcpy(&(I2[1]),&(I[i]),sizeof(int)<<1);
		ok += scan3_goraud(v, clipedges, I2, goraudType, plusVal, divZ, plusZ, maxZ);
	}
	return (ok > 0);
}


/*
scan3:
Fyller trianglar(polygoner med 3 koordinater).
Returnerar -1 om polygonen var korrupt, annars 1.
*/

int scan3(intVector vv[], int clipedges[], uchar col) {
	register int ysweep,xx1,xx2,yyy;
	register uchar *vid;
	int i,MINy,MAXy,MIDy=0,yEND;
	long int lut1,lut2,x1,x2;
	intVector *cp;

	cp=vv;

	// Om alla koordinater har samma y-position, rita ej ut ngt.
	if (cp[0].y==cp[1].y && cp[1].y==cp[2].y) return 0;
	if (cp[0].y < 0 && cp[1].y < 0 && cp[2].y < 0) return 0;
	if (cp[0].x < 0 && cp[1].x < 0 && cp[2].x < 0) return 0;
	if (cp[0].y >= YRES && cp[1].y >= YRES && cp[2].y >= YRES) return 0;
	if (cp[0].x >= XRES && cp[1].x >= XRES && cp[2].x >= XRES) return 0;

	xx1=cp[0].x; yyy=cp[0].y;
	// Om två(eller fler) punkter har samma x- och y-koordinat är triangeln korrupt.
	for (i=1; i<3; i++) 
	if (cp[i].x==xx1 && cp[i].y==yyy)
	return 0;

	// Bestämning av punkt med minsta, mellersta och största y-v„rde.

	MINy=0;
	if (cp[1].y<cp[MINy].y) MINy=1;
	if (cp[2].y<cp[MINy].y) MINy=2;

	MAXy=0;
	if (cp[1].y>cp[MAXy].y) MAXy=1;
	if (cp[2].y>cp[MAXy].y) MAXy=2;

	for (i=0; i<3; i++)
	if(i!=MAXy && i!=MINy) MIDy=i;

	// Här bestäms "linjernas" lutning. För att slippa flyttal "simuleras"
	// dessa istället genom att vänsterskifta 16 steg.

	ysweep=cp[MINy].y;
	lut1=(cp[MIDy].x-cp[MINy].x)<<16; lut1/=(cp[MIDy].y-cp[MINy].y+1);
	lut2=(cp[MAXy].x-cp[MINy].x)<<16; lut2/=(cp[MAXy].y-cp[MINy].y+1);
	x1=x2=(cp[MINy].x)<<16;

	vid=video+ysweep*XRES;

	yEND=cp[MAXy].y;
	if(yEND>YRES-1) yEND=YRES; //-1;

	while(ysweep<yEND) {  // Svep från Ymin till Ymax

		x1+=lut1; x2+=lut2;  // Lutning adderas till x-position.

		if (ysweep==cp[MIDy].y) { // Skärning ("triangel 2" börjar här)
			lut1=(cp[MAXy].x-cp[MIDy].x)<<16; lut1/=(cp[MAXy].y-cp[MIDy].y+1);
			x1=(cp[MIDy].x)<<16;
			x1+=lut1;
		}

		if (ysweep<0) goto esc;
		xx1=x1>>16; xx2=x2>>16; // Här "skalas" x-värdet ned igen genom högerskift.
		if (xx2<=xx1) {
			if(xx1>=XRES) {
				if(xx2>=XRES) goto esc; else xx1=XRES-1;
			}
			if(xx2<0) {
				if(xx1<=0) goto esc; else xx2=0;
			}
			MYMEMSET(vid+xx2,col,xx1-xx2+1);
		}
		else {
			if(xx2>=XRES) {
				if(xx1>=XRES) goto esc; else xx2=XRES-1;
			}
			if(xx1<0) {
				if(xx2<=0) goto esc; else xx1=0;
			}
			MYMEMSET(vid+xx1,col,xx2-xx1+1);
		}

esc:
		ysweep++;
		vid+=XRES;
	}
	return 1;
}


/*
scan3_goraud:
Fyller trianglar(polygoner med 3 koordinater). Goraudshade.
Returnerar -1 om polygonen var korrupt, annars 1.
*/

int scan3_goraud(intVector vv[], int clipedges[], int I[], int goraudType, PREPCOL plusVal, int divZ, int plusZ, int maxZ) {
	register int ysweep,xx1,xx2,yyy;
	register uchar *vid;
	int i,MINy,MAXy,MIDy=0,yEND,j;
	long int lut1,lut2,x1,x2;
	intVector *cp;
	float shadla_diff,shadra_diff,shadr_diff,shadl_diff,diff_sx,diff_sxa=0;
	float temp;

	cp=vv;

	if (goraudType == GORAUD_TYPE_Z) {
		for (i=0; i<3; i++) {
			I[i] = cp[i].z/divZ+plusZ+8;
			if (I[i] < 8) I[i]=8;
			if (I[i] > maxZ+8) I[i]=maxZ+8;
		}
		//	  I[2]++; // weird
	}

	// Om alla koordinater har samma y-position, rita ej ut ngt.
	if (cp[0].y==cp[1].y && cp[1].y==cp[2].y) return 0;
	if (cp[0].y < 0 && cp[1].y < 0 && cp[2].y < 0) return 0;
	if (cp[0].x < 0 && cp[1].x < 0 && cp[2].x < 0) return 0;
	if (cp[0].y >= YRES && cp[1].y >= YRES && cp[2].y >= YRES) return 0;
	if (cp[0].x >= XRES && cp[1].x >= XRES && cp[2].x >= XRES) return 0;

	xx1=cp[0].x; yyy=cp[0].y;
	// Om två(eller fler) punkter har samma x- och y-koordinat är triangeln korrupt
	for (i=1; i<3; i++)
	if (cp[i].x==xx1 && cp[i].y==yyy)
	return 0;

	// Bestämning av punkt med minsta, mellersta och största y-värde.

	MINy=0;
	if (cp[1].y<cp[MINy].y) MINy=1;
	if (cp[2].y<cp[MINy].y) MINy=2;

	MAXy=0;
	if (cp[1].y>cp[MAXy].y) MAXy=1;
	if (cp[2].y>cp[MAXy].y) MAXy=2;

	for (i=0; i<3; i++)
	if(i!=MAXy && i!=MINy) MIDy=i;

	// Här bestäms "linjernas" lutning. För att slippa flyttal "simuleras"
	// dessa istället genom att vänsterskifta 16 steg.

	ysweep=cp[MINy].y;
	lut1=(cp[MIDy].x-cp[MINy].x)<<16;
	lut1/=(cp[MIDy].y-cp[MINy].y+1);
	lut2=(cp[MAXy].x-cp[MINy].x)<<16;
	lut2/=(cp[MAXy].y-cp[MINy].y+1);
	x1=x2=(cp[MINy].x)<<16;

	shadla_diff=(I[MIDy]-I[MINy]+0.01)/(float)(cp[MIDy].y-cp[MINy].y+1); // 0.01 to avoid rounding/edge bug
	shadra_diff=(I[MAXy]-I[MINy]+0.01)/(float)(cp[MAXy].y-cp[MINy].y+1);
	shadl_diff=shadr_diff=I[MINy];

	vid=video+ysweep*XRES;
	yEND=cp[MAXy].y;
	if(yEND>YRES-1) yEND=YRES;

	while(ysweep<yEND) {  // Svep från Ymin till Ymax

		x1+=lut1; x2+=lut2;  // Lutning adderas till x-position.
		shadr_diff+=shadra_diff; shadl_diff+=shadla_diff;

		if (ysweep==cp[MIDy].y) { // Skärning ("triangel 2" börjar här)
			lut1=(cp[MAXy].x-cp[MIDy].x)<<16;  // Ny lutning.
			lut1/=(cp[MAXy].y-cp[MIDy].y+1);
			x1=(cp[MIDy].x)<<16;
			x1+=lut1;
			shadla_diff=(I[MAXy]-I[MIDy]+0.01)/(float)(cp[MAXy].y-cp[MIDy].y+1);
			shadl_diff=I[MIDy];
			shadl_diff+=shadla_diff;
		}

		if (ysweep<0) goto skip;
		xx1=x1>>16; xx2=x2>>16; // Här "skalas" x-värdet ned igen genom högerskift.

		if (xx1>xx2) {
			j=xx2; xx2=xx1; xx1=j;
			diff_sx=shadr_diff; //+12; No ambient light
			diff_sxa=-(shadr_diff-shadl_diff)/(float)(xx2-xx1);
			if(xx2>=XRES) {
				if(xx1>=XRES) goto skip; else xx2=XRES-1;
			}
			if(xx1<0) {
				if(xx2<=0) goto skip; else { diff_sx+=diff_sxa*(-xx1); xx1=0; }
			}
		}
		else {
			diff_sx=shadl_diff; //+12; No ambient light
			temp=xx2-xx1;
			if(temp!=0)
			diff_sxa=-(shadl_diff-shadr_diff)/temp;
			if(xx2>=XRES) {
				if(xx1>=XRES) goto skip; else xx2=XRES-1;
			}
			if(xx1<0) {
				if(xx2<=0) goto skip; else { diff_sx+=diff_sxa*(-xx1); xx1=0; }
			}
		}

		for (i=xx1; i<=xx2; i++) { // Rita ut pixlar mellan x-positioner.
			vid[i]=(PREPCOL)diff_sx PLUSVAL_OP plusVal;
			diff_sx+=diff_sxa;  // Interpolera diffuse
		}
skip:
		ysweep++;
		vid+=XRES;
	}
	return 1;
}

void fbox(uchar *inVid, int x, int y, int xrange, int yrange, uchar col) {
	register uchar *vid;
	register int i;

	if (x>=XRES || y>=YRES) return;
	if (x<0) { xrange+=x; x=0; }
	if (y<0) { yrange+=y; y=0; }
	if (x+xrange>=XRES) { xrange-=(x+xrange)-(XRES-1); }
	if (y+yrange>=YRES) { yrange-=(y+yrange)-(YRES-1); }
	if (xrange<0 || yrange<0) return;

	vid=inVid+y*XRES+x;
	for (i=0; i<=yrange; i++) {
		MYMEMSET(vid, col, xrange+1);
		vid+=XRES;
	}
}

void box (int x, int y, int xrange, int yrange, uchar col) {
	hline(x, x+xrange, y, col);
	hline(x, x+xrange, y+yrange, col);
	vline(x, y, y+yrange, col);
	vline(x+xrange, y, y+yrange, col);
}

void circle(int xp, int yp, int radius, uchar col) {
	register int d, x, xx, y, ye;
	register uchar *vid=video+xp+yp*XRES;

	ellipse(xp, yp, radius, radius, col); //too lazy to make clipping for this
	return;

	d = 3-(radius<<1);
	x = xx = 0;
	y = ye = radius;
	y*=XRES;

	repeat {
		vid[x+y] = col;
		vid[-x+y] = col;
		vid[x-y] = col;
		vid[-x-y] = col;
		vid[ye+xx] = col;
		vid[ye-xx] = col;
		vid[-ye+xx] = col;
		vid[-ye-xx] = col;
		if (d < 0)
		d=d+(x<<2) + 6;
		else {
			d=d+((x-ye)<<2) + 10;
			y-=XRES; ye--;
		}
		x++; xx+=XRES;
	} until (x>ye);
}


void ellipse(int xc, int yc, int rx, int ry, uchar col) {
	register uchar *vid=video+xc+yc*XRES, *v1=video+FRAMESIZE;
	register int x, y;
	int T1,T2,T3,T4,T5,T6,T7,T8,T9;
	int D1,D2;
	int y1,y2;

	if(rx < 0) rx=-rx;
	if(ry < 0) ry=-ry;

	T1=rx*rx;
	T2=T1<<1;
	T3=T1<<2;
	T4=ry*ry;
	T5=T4<<1;
	T6=T4<<2;
	T7=rx*T5;
	T8=T7<<1;
	T9=0;

	D1=T2-T7+(T4>>1);
	D2=(T1>>1)-T8+T5;

	x=rx; y=0;
	while (D2<0) {
		y1=(vid+y-xc>=video && vid+y-xc<v1);
		y2=(vid-y-xc>=video && vid-y-xc<v1);
		if (x+xc>=0 && x+xc<XRES) {
			if (y1) vid[x+y]=col;
			if (y2) vid[x-y]=col;
		}
		if (xc-x>=0 && xc-x<XRES) {
			if (y1) vid[-x+y]=col;
			if (y2) vid[-x-y]=col;
		}
		y+=XRES;
		T9+=T3;
		if (D1<0) {
			D1+=T9+T2;
			D2+=T9;
		}
		else {
			x--;
			T8+=-T6;
			D1+=T9+T2-T8;
			D2+=T9+T5-T8;
		}
	}
	repeat {
		y1=(vid+y-xc>=video && vid+y-xc<v1);
		y2=(vid-y-xc>=video && vid-y-xc<v1);
		if (x+xc>=0 && x+xc<XRES) {
			if (y1) vid[x+y]=col;
			if (y2) vid[x-y]=col;
		}
		if (xc-x>=0 && xc-x<XRES) {
			if (y1) vid[-x+y]=col;
			if (y2) vid[-x-y]=col;
		}
		x--;
		T8+=-T6;
		if (D2<0) {
			y+=XRES;
			T9+=T3;
			D2+=T9+T5-T8;
		}
		else
		D2+=T5-T8;
	} until (x<0);
}


void filled_ellipse(int xc, int yc, int rx, int ry, uchar col) {
	register uchar *vid=video+xc+yc*XRES, *v1, *v2=video+FRAMESIZE;
	register int x, y, xx, bx, dx;
	int T1,T2,T3,T4,T5,T6,T7,T8,T9;
	int D1,D2;

	if(rx < 0) rx=-rx;
	if(ry < 0) ry=-ry;
	
	T1=rx*rx;
	T2=T1<<1;
	T3=T1<<2;
	T4=ry*ry;
	T5=T4<<1;
	T6=T4<<2;
	T7=rx*T5;
	T8=T7<<1;
	T9=0;

	D1=T2-T7+(T4>>1);
	D2=(T1>>1)-T8+T5;

	x=rx; y=0;
	while (D2<0) {
		xx=x<<1; bx=xc-x; dx=x;
		if (bx+xx>=XRES) { if (bx>=XRES) goto stop1; else xx-=(bx+xx)-XRES;}
		if (bx<0) { if (bx+xx<0) goto stop1; else xx+=bx, dx=xc;}
		v1=vid-dx-y;
		if (v1>=video && v1<v2)
			MYMEMSET(v1, col, xx);
		v1=vid-dx+y;
		if (v1>=video && v1<v2)
			MYMEMSET(v1, col, xx);

stop1:
		y+=XRES;
		T9+=T3;
		if (D1<0) {
			D1+=T9+T2;
			D2+=T9;
		}
		else {
			x--;
			T8+=-T6;
			D1+=T9+T2-T8;
			D2+=T9+T5-T8;
		}
	}
	repeat {
		xx=x<<1; bx=xc-x; dx=x;
		if (bx+xx>=XRES) { if (bx>=XRES) goto stop2; else xx-=(bx+xx)-XRES;}
		if (bx<0) { if (bx+xx<0) goto stop2; else xx+=bx, dx=xc;}
		v1=vid-dx-y;
		if (v1>=video && v1<v2)
			MYMEMSET(v1, col, xx);
		v1=vid-dx+y;
		if (v1>=video && v1<v2)
			MYMEMSET(v1, col, xx);

stop2:
		x--;
		T8+=-T6;
		if (D2<0) {
			y+=XRES;
			T9+=T3;
			D2+=T9+T5-T8;
		}
		else
			D2+=T5-T8;
	} until (x<0);
}

void filled_circle(int xc, int yc, int radius, uchar col) {
	filled_ellipse(xc, yc, radius, radius, col);
}


/* Används av den generella polygonritar-rutinen.
Representerar en lutning och position mellan två punkter 
*/
struct pline {
	long int xpos,xlut;
	int Yactive, Yinactive;
};

/* Compar:
Hjälpfunktion som används av systemfunktionen qsort i den generella
polygonritaren. 
*/
int compar(const void *vx, const void *vy) {
	int *x = (int *)vx;
	int *y = (int *)vy;
	
	if (*x<*y) return -1;
	return (*x>*y);
}

/* scanPoly:
	Fyller polygoner av valfri typ(konvexa eller konkava) med 3 koordinater
	eller fler.
	Returnerar -1 om polygonen var korrupt, annars 1.
*/

int scanPoly(intVector p[],int points, uchar col, uchar bitOp) {
	register int i,k,ysweep, x1, x2;
	int MAXy,j,xes[5000];
	struct pline linje[5000];
	register uchar *vid;
	int divVal;
	int bitTemp,bitTemp2;
#ifdef _RGB32
	int r,g,b;
	long long r2,g2,b2;
#endif

	if (points<3) return 0; // Returnera 0 om färre än 3 punkter(korrupt poly)
	p[points].x=p[0].x; p[points].y=p[0].y; // Sista punkt=första punkt.

	/* Bestäm lutning, inledande xpos och mellan vilka y-koordinater denna linje"
	i polygonen är "aktiv". Görs mellan P1 och P2, P2 och P3... Pn-1 och Pn.
	Flyttal "simuleras" genom vänsterskiftning för xlutning och xposition. */

	for (i=0; i<points; i++) {
		if (p[i].y<=p[i+1].y) { // Linjen går "uppåt"
			linje[i].Yactive=p[i].y;
			linje[i].Yinactive=p[i+1].y;
			linje[i].xpos=p[i].x<<16;
			linje[i].xlut=(p[i+1].x-p[i].x)<<16;
			divVal = (p[i+1].y-p[i].y+1);
			if (divVal == 0) return 0;
			linje[i].xlut/=divVal;
		}
		else { // Linjen går "nedåt"
			linje[i].Yactive=p[i+1].y;
			linje[i].Yinactive=p[i].y;
			linje[i].xpos=p[i+1].x<<16;
			linje[i].xlut=(p[i].x-p[i+1].x)<<16;
			divVal=(p[i].y-p[i+1].y+1);
			if (divVal == 0) return 0;
			linje[i].xlut/=divVal;
		}
	}

	// Här bestäms start och slutposition i Y för polygonen.

	ysweep=linje[0].Yactive;
	for (i=0; i<points; i++)
		if(linje[i].Yactive<ysweep)
			ysweep=linje[i].Yactive;
	MAXy=linje[0].Yinactive;
	for (i=0; i<points; i++)
		if(linje[i].Yinactive>MAXy)
			MAXy=linje[i].Yinactive;

	vid=video+ysweep*XRES;
	if(MAXy>YRES) MAXy=YRES;

	while(ysweep<MAXy) {
		j=0;
		/* Alla "linjer" som har en punkt på aktuell sveplinje får sin xposition
	uppdaterad och läggs i array av xpositioner mellan vilka pixlar ritas */
		for(i=0; i<points; i++) {
			if(ysweep>=linje[i].Yactive && ysweep<linje[i].Yinactive) {
				linje[i].xpos+=linje[i].xlut;
				xes[j]=linje[i].xpos>>16;
				j++;
			}
		}
		if (ysweep < 0) goto dont;
		qsort(xes,j,sizeof(int),compar);  // Sortera xpositioner

		for(i=0; i<j; i+=2) { // Rita pixlar mellan sorterade xpositioner.
			x1=xes[i]; x2=xes[i+1];
			if(x2>=XRES) {
				if(x1>=XRES) continue; else x2=XRES-1;
			}
			if(x1<0) {
				if(x2<=0) continue; else x1=0;
			}

			switch(bitOp) {
#ifdef _RGB32
			case BIT_OP_ADD_FGRGB: for (k = x1; k < x1 + x2-x1+1; k++) { b = (((vid[k] & 0xff) + (col & 0xff)) ); g = ((((vid[k]>>8) & 0xff) + ((col >> 8) & 0xff)) ); r = ((((vid[k]>>16) & 0xff) + ((col >> 16) & 0xff)) ); if(b>255)b=255; if(g>255)g=255; if(r>255)r=255; vid[k] = b | (g<<8) | (r<<16) | (col & 0xffffff00000000); } break;
			case BIT_OP_ADD_RGB: for (k = x1; k < x1 + x2-x1+1; k++) { b = (((vid[k] & 0xff) + (col & 0xff)) ); g = ((((vid[k]>>8) & 0xff) + ((col >> 8) & 0xff)) ); r = ((((vid[k]>>16) & 0xff) + ((col >> 16) & 0xff)) ); b2 = ((((vid[k]>>32) & 0xff) + ((col >> 32) & 0xff)) ); g2 = ((((vid[k]>>40) & 0xff) + ((col >> 40) & 0xff)) ); r2 = ((((vid[k]>>48) & 0xff) + ((col >> 48) & 0xff)) );  if(b>255)b=255; if(g>255)g=255; if(r>255)r=255;if(b2>255)b2=255; if(g2>255)g2=255; if(r2>255)r2=255; vid[k] = b | (g<<8) | (r<<16) | (b2<<32)  | (g2<<40)  | (r2<<48); } break;

			case BIT_OP_SUB_FGRGB: for (k = x1; k < x1 + x2-x1+1; k++) { b = (((vid[k] & 0xff) - (col & 0xff)) ); g = ((((vid[k]>>8) & 0xff) - ((col >> 8) & 0xff)) ); r = ((((vid[k]>>16) & 0xff) - ((col >> 16) & 0xff)) ); if(b<0)b=0; if(g<0)g=0; if(r<0)r=0; vid[k] = b | (g<<8) | (r<<16) | (col & 0xffffff00000000); } break;
			case BIT_OP_SUB_RGB: for (k = x1; k < x1 + x2-x1+1; k++) { b = (((vid[k] & 0xff) - (col & 0xff)) ); g = ((((vid[k]>>8) & 0xff) - ((col >> 8) & 0xff)) ); r = ((((vid[k]>>16) & 0xff) - ((col >> 16) & 0xff)) ); b2 = ((((vid[k]>>32) & 0xff) - ((col >> 32) & 0xff)) ); g2 = ((((vid[k]>>40) & 0xff) - ((col >> 40) & 0xff)) ); r2 = ((((vid[k]>>48) & 0xff) - ((col >> 48) & 0xff)) );  if(b<0)b=0; if(g<0)g=0; if(r<0)r=0;if(b2<0)b2=0; if(g2<0)g2=0; if(r2<0)r2=0; vid[k] = b | (g<<8) | (r<<16) | (b2<<32)  | (g2<<40)  | (r2<<48); } break;
			
			case BIT_OP_BLEND_FGRGB: for (k = x1; k < x1 + x2-x1+1; k++) { int blNew, blOrg; blNew=(col >> 24) & 0xff; blOrg=255-blNew;  b=((((vid[k] & 0xff) * blOrg / 256) + ((col & 0xff) * blNew / 256))); g=(((((vid[k]>>8) & 0xff) * blOrg / 256) + (((col>>8) & 0xff) * blNew / 256))); r=(((((vid[k]>>16) & 0xff) * blOrg / 256) + (((col>>16) & 0xff) * blNew / 256))); vid[k] = b | (g<<8) | (r<<16) | (col & 0xffffff00000000); } break;

			case BIT_OP_BLEND_RGB: for (k = x1; k < x1 + x2-x1+1; k++) { int blNew, blOrg, bl2New, bl2Org; blNew=(col >> 24) & 0xff; blOrg=255-blNew; bl2New=(col >> 56) & 0xff; bl2Org=255-bl2New; b=((((vid[k] & 0xff) * blOrg / 256) + ((col & 0xff) * blNew / 256))); g=(((((vid[k]>>8) & 0xff) * blOrg / 256) + (((col>>8) & 0xff) * blNew / 256))); r=(((((vid[k]>>16) & 0xff) * blOrg / 256) + (((col>>16) & 0xff) * blNew / 256))); b2=(((((vid[k]>>32) & 0xff) * bl2Org / 256) + (((col>>32) & 0xff) * bl2New / 256))); g2=(((((vid[k]>>40) & 0xff) * bl2Org / 256) + (((col>>40) & 0xff) * bl2New / 256))); r2=(((((vid[k]>>48) & 0xff) * bl2Org / 256) + (((col>>48) & 0xff) * bl2New / 256)));  vid[k] = b | (g<<8) | (r<<16) | (b2<<32)  | (g2<<40)  | (r2<<48); } break;
#endif
			case BIT_OP_OR: for (k = x1; k < x1 + x2-x1+1; k++) vid[k] |= col; break;
			case BIT_OP_AND: for (k = x1; k < x1 + x2-x1+1; k++) vid[k] &= col; break;
			case BIT_OP_XOR: for (k = x1; k < x1 + x2-x1+1; k++) vid[k] ^= col; break;
			case BIT_OP_ADD_REAL: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = vid[k]; bitTemp+=col; if (bitTemp > 255) bitTemp = 255; vid[k] = bitTemp; } break;
			case BIT_OP_SUB_REAL: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = vid[k]; bitTemp-=col; if (bitTemp < 0) bitTemp = 0; vid[k] = bitTemp; } break;
			case BIT_OP_SUB_ME_REAL: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = col; bitTemp-=vid[k]; if (bitTemp < 0) bitTemp = 0; vid[k] = bitTemp; } break;
			case BIT_OP_ADD: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = vid[k]&0xf; bitTemp+=col&0xf; if (bitTemp > 15) bitTemp = 15; bitTemp2 = (vid[k]>>4)&0xf; bitTemp2+=(col>>4)&0xf; if (bitTemp2 > 15) bitTemp2 = 15; vid[k] = (bitTemp2 << 4) | bitTemp; } break;
			case BIT_OP_SUB: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = vid[k]&0xf; bitTemp-=col&0xf; if (bitTemp < 0) bitTemp = 0; bitTemp2 = (vid[k]>>4)&0xf; bitTemp2-=(col>>4)&0xf; if (bitTemp2 < 0) bitTemp2 = 0; vid[k] = (bitTemp2 << 4) | bitTemp; } break;
			case BIT_OP_SUB_ME: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = col&0xf; bitTemp-=vid[k]&0xf; if (bitTemp < 0) bitTemp = 0; bitTemp2 = (col>>4)&0xf; bitTemp2-=(vid[k]>>4)&0xf; if (bitTemp2 < 0) bitTemp2 = 0; vid[k] = (bitTemp2 << 4) | bitTemp; } break;
			default: MYMEMSET(vid+x1,col,x2-x1+1);
			}
		}

dont:
		ysweep++;
		vid+=XRES;
	}
	return 1;
}

int line_clip(int *x1, int *y1, int *x2, int *y2) {
	int xa=*x1, xb=*x2, ya=*y1, yb=*y2;

	if ( (xa<0 && xb<0) || (ya<0 && yb<0) || (xa>=XRES && xb>=XRES) || (ya>=YRES && yb>=YRES) )
	return 0;

	if (xa < 0) {
		if (xa-xb!=0)
		ya += (float)(ya-yb)/(float)(xa-xb)*(float)(-xa);
		xa = 0;
	}
	else if (xb < 0) {
		if (xb-xa!=0)
		yb += (float)(yb-ya)/(float)(xb-xa)*(float)(-xb);
		xb = 0;
	}

	if (xa >= XRES) {
		if (xa-xb!=0)
		ya -= (float)(ya-yb)/(float)(xa-xb)*(float)(xa-(XRES-1));
		xa = XRES-1;
	}
	else if (xb >= XRES) {
		if (xb-xa!=0)
		yb -= (float)(yb-ya)/(float)(xb-xa)*(float)(xb-(XRES-1));
		xb = XRES-1;
	}

	if (ya < 0) {
		if (ya-yb!=0)
		xa += (float)(xa-xb)/(float)(ya-yb)*(float)(-ya);
		ya = 0;
	}
	else if (yb < 0) {
		if (yb-ya!=0)
		xb += (float)(xb-xa)/(float)(yb-ya)*(float)(-yb);
		yb = 0;
	}
	if (ya >= YRES) {
		if (ya-yb!=0)
		xa -= (float)(xa-xb)/(float)(ya-yb)*(float)(ya-(YRES-1));
		ya = YRES-1;
	}
	else if (yb >= YRES) {
		if (yb-ya!=0)
		xb -= (float)(xb-xa)/(float)(yb-ya)*(float)(yb-(YRES-1));
		yb = YRES-1;
	}

	if (ya<0) ya=0; if (ya>=YRES) ya=YRES-1;
	if (yb<0) yb=0; if (yb>=YRES) yb=YRES-1;
	if (xa<0) xa=0; if (xa>=XRES) xa=XRES-1;
	if (xb<0) xb=0; if (xb>=XRES) xb=XRES-1;

	*x1 = xa; *y1 = ya;
	*x2 = xb; *y2 = yb;
	return 1;
}


void line(int x1, int y1, int x2, int y2, uchar col, int clip) {
	register uchar *vid;
	int delta_x, delta_y;
	int major_axis, direction; 
	int double_delta_x; 
	int double_delta_y;
	int diff_double_deltas; 
	int error, temp; 

	if (clip)
		if (!line_clip(&x1, &y1, &x2, &y2))
			return;

	// by making sure y1 is greater than y2 we eliminate different line
	// possibilites. So, if this condition is false, we just switch our 
	// coordinates. Now we know the line goes from top to bottom. We just 
	// need to know if it goes left to right or right to left. 
	if(y1 > y2) { 
		temp=y1; y1=y2; y2=temp;  // swap y1 and y2
		temp=x1; x1=x2; x2=temp;  // swap x1 and x2
	}

	delta_x = x2 - x1;        // will determine L->R or R->L 
	delta_y = y2 - y1;        // has to be positive because line goes T->B 

	if(delta_x > 0)           // delta_x is positive: going left to right
	direction = 1; 
	else {                    // delta_x is negative: going right to left 
		delta_x = -delta_x;     // need absolute length of this axis later on 
		direction = -1; 
	} 

	if(delta_x > delta_y)
		major_axis = 0;      // our main axis is the x
	else
		major_axis = 1;      // our main axis in the y

	vid=video+y1*XRES;

	switch(major_axis) {      // what is our main axis
	case 0:                 // major axis is the x
		double_delta_y = delta_y + delta_y; 
		diff_double_deltas = double_delta_y - (delta_x + delta_x); 
		error = double_delta_y - delta_x; 

		vid[x1]=col;
		while(delta_x--) {      // loop for the length of the major axis
			if(error >= 0) {      // if the error is greater than or equal to zero:
				vid+=XRES;            // increase the minor axis (y)
				error += diff_double_deltas;
			}
			else error += double_delta_y;
			x1 += direction;      // increase the major axis to next pixel
			vid[x1]=col;
		}
		break;

	case 1:    // major axis is the y
		double_delta_x = delta_x + delta_x;
		diff_double_deltas = double_delta_x - (delta_y + delta_y);
		error = double_delta_x - delta_y;

		vid[x1]=col;
		while(delta_y--) {      // loop for the length of the major axis
			if(error >= 0) {      // if the error is greater than or equal to zero:
				x1 += direction;    // increase the minor axis (x)
				error += diff_double_deltas;
			} else error += double_delta_x;
			vid+=XRES;            // increase major axis to next pixel
			vid[x1]=col;
		}
		break;
	}
}


/* // no better...
void line(int x, int y, int x2, int y2, uchar col, int clip) {
	int i,j,l, la;
	int e,f,g;
	uchar *vid;
	
	if (clip)
		if (!line_clip(&x, &y, &x2, &y2))
			return;
    
	i = x2-x; if (i<0) i = -i;
	j = y2-y; if (j<0) j = -j;

	if (i < j) {
		f = j;
		e = x2 - x;
		e = ((e+1) << 16)/f;
		g = x << 16;

		if (y > y2) {
			la = -1; y2--;
		} else {
			la = 1; y2++;
		}

		vid = &video[y*XRES];
		for (l = y; l != y2; l+=la) {
			vid[g>>16] = col;
			vid+=XRES;
			g = g + e;
		}
	} else {
		f = i;
		e = y2 - y;
		e = ((e+1) << 16)/f;
		g = y << 16;

		if (x > x2) {
			la = -1; x2--;
		} else {
			la = 1;	x2++;
		}

		vid = video;
		for (l = x; l != x2; l+=la) {
			vid[(g>>16)*XRES + l] = col;
			g = g + e;
		}
	}
}
*/

void polyLine(intVector v[], int points, uchar col, uchar connect, int clip) {
	register int i;

	if (connect) {
		v[points].x=v[0].x;
		v[points].y=v[0].y;
		points++;
	}
	for (i=0; i<points-1; i++) {
		line(v[i].x, v[i].y, v[i+1].x, v[i+1].y, col, clip);
	}
}

typedef struct vec_interpolate {
	double xy_l,yy_l,zy_l;
	double xy_r,yy_r,zy_r;
	double x_ay_l,y_ay_l,z_ay_l;
	double x_ay_r,y_ay_r,z_ay_r;
	int x_ax, y_ax, z_ax;
	intVector ip_pos;
} vec_interpolate;


/* Initierar värden för interpolering av en vektor i "y-led" */

void vecpolinit(vec_interpolate *vp, Vector v1, Vector v2, double div_val, int left) {
	if (left) {
		vp->x_ay_l=(v1.x-v2.x)/div_val;
		vp->y_ay_l=(v1.y-v2.y)/div_val;
		vp->z_ay_l=(v1.z-v2.z)/div_val;
		vp->xy_l=v2.x;
		vp->yy_l=v2.y;
		vp->zy_l=v2.z;
	}
	else {
		vp->x_ay_r=(v1.x-v2.x)/div_val;
		vp->y_ay_r=(v1.y-v2.y)/div_val;
		vp->z_ay_r=(v1.z-v2.z)/div_val;
		vp->xy_r=v2.x;
		vp->yy_r=v2.y;
		vp->zy_r=v2.z;
	}
}

/* Interpolerar vektor i "y-led" */

void vecpol_addydelt(vec_interpolate *vp, int left) {
	if (left) {
		vp->xy_l+=vp->x_ay_l;
		vp->yy_l+=vp->y_ay_l;
		vp->zy_l+=vp->z_ay_l;
	}
	else {
		vp->xy_r+=vp->x_ay_r;
		vp->yy_r+=vp->y_ay_r;
		vp->zy_r+=vp->z_ay_r;
	}
}

/* Initierar värden för interpolering av en vektor i "x-led" */

void vecpolinit_x(vec_interpolate *vp, double div_val, int rev) {
	if (!rev) {
		vp->ip_pos.x=vp->xy_l*65536;
		vp->ip_pos.y=vp->yy_l*65536;
		vp->ip_pos.z=vp->zy_l*65536;
		vp->x_ax=-(vp->xy_l-vp->xy_r)*65536/div_val;
		vp->y_ax=-(vp->yy_l-vp->yy_r)*65536/div_val;
		vp->z_ax=-(vp->zy_l-vp->zy_r)*65536/div_val;
	}
	else {
		vp->ip_pos.x=vp->xy_r*65536;
		vp->ip_pos.y=vp->yy_r*65536;
		vp->ip_pos.z=vp->zy_r*65536;
		vp->x_ax=-(vp->xy_r-vp->xy_l)*65536/div_val;
		vp->y_ax=-(vp->yy_r-vp->yy_l)*65536/div_val;
		vp->z_ax=-(vp->zy_r-vp->zy_l)*65536/div_val;
	}
}

/* Interpolerar vektor i "x-led" */

void vecpol_addxdelt(vec_interpolate *vp) {
	vp->ip_pos.x+=vp->x_ax;
	vp->ip_pos.y+=vp->y_ax;
	vp->ip_pos.z+=vp->z_ax;
}

int scan3_tmap(intVector vv[], int clipedges[], Bitmap *tex, PREPCOL plusVal) {
	register uchar I;
	uchar *vid;
	register int ysweep,xx1,xx2,yyy;
	register int texw, texh;
	int i,MINy,MAXy,MIDy=0,yEND, j;
	int lut1,lut2,x1,x2;
	intVector *cp;
	unsigned int upp,vpp;
	float temp;
	vec_interpolate tex_ip;

	texw = tex->xSize;
	texh = tex->ySize;

	cp=vv;

	// Om alla koordinater har samma y-position, rita ej ut ngt.
	if (cp[0].y==cp[1].y && cp[1].y==cp[2].y) return 0;
	if (cp[0].y < 0 && cp[1].y < 0 && cp[2].y < 0) return 0;
	if (cp[0].x < 0 && cp[1].x < 0 && cp[2].x < 0) return 0;
	if (cp[0].y >= YRES && cp[1].y >= YRES && cp[2].y >= YRES) return 0;
	if (cp[0].x >= XRES && cp[1].x >= XRES && cp[2].x >= XRES) return 0;

	xx1=cp[0].x; yyy=cp[0].y;
	// Om två(eller fler) punkter har samma x- och y-koordinat är triangeln korrupt.
	for (i=1; i<3; i++)
	if (cp[i].x==xx1 && cp[i].y==yyy)
	return 0;
	// Bestämning av punkt med minsta, mellersta och största y-värde.

	MINy=0;
	if (cp[1].y<cp[MINy].y) MINy=1;
	if (cp[2].y<cp[MINy].y) MINy=2;

	MAXy=0;
	if (cp[1].y>cp[MAXy].y) MAXy=1;
	if (cp[2].y>cp[MAXy].y) MAXy=2;

	for (i=0; i<3; i++)
	if(i!=MAXy && i!=MINy) MIDy=i;

	// Här bestäms "linjernas" lutning. För att slippa flyttal "simuleras"
	// dessa istället genom att vänsterskifta 16 steg.

	ysweep=cp[MINy].y;
	lut1=(cp[MIDy].x-cp[MINy].x)<<16; lut1/=(cp[MIDy].y-cp[MINy].y+1);
	lut2=(cp[MAXy].x-cp[MINy].x)<<16; lut2/=(cp[MAXy].y-cp[MINy].y+1);
	x1=x2=(cp[MINy].x)<<16;
	vecpolinit(&tex_ip, vv[MIDy].tex_coord, vv[MINy].tex_coord,(double)(cp[MIDy].y-cp[MINy].y+1), 1);
	vecpolinit(&tex_ip, vv[MAXy].tex_coord, vv[MINy].tex_coord,(double)(cp[MAXy].y-cp[MINy].y+1), 0);

	vid=video+ysweep*XRES;

	yEND=cp[MAXy].y;
	if(yEND>YRES) yEND=YRES;

	while(ysweep<yEND) {  // Svep från Ymin till Ymax

		x1+=lut1; x2+=lut2;  // Lutning adderas till x-position.
		vecpol_addydelt(&tex_ip, 1); vecpol_addydelt(&tex_ip, 0);

		if (ysweep==cp[MIDy].y) { // Skärning ("triangel 2" börjar här)
			lut1=(cp[MAXy].x-cp[MIDy].x)<<16; lut1/=(cp[MAXy].y-cp[MIDy].y+1);
			x1=(cp[MIDy].x)<<16;
			x1+=lut1;
			vecpolinit(&tex_ip, vv[MAXy].tex_coord, vv[MIDy].tex_coord,(double)(cp[MAXy].y-cp[MIDy].y+1), 1);
			vecpol_addydelt(&tex_ip, 1);
		}

		if(ysweep<0) goto ut;
		xx1=x1>>16; xx2=x2>>16; // Här "skalas" x-värdet ned igen genom högerskift.

		if (xx1>xx2) {
			j=xx2; xx2=xx1; xx1=j;
			vecpolinit_x(&tex_ip, (double)(xx2-xx1), 1);
			if(xx2>XRES) {
				if(xx1>=XRES) goto ut; else xx2=XRES;
			}
			if(xx1<0) {
				if(xx2<=0) goto ut; else { tex_ip.ip_pos.x+=tex_ip.x_ax*(-xx1); tex_ip.ip_pos.y+=tex_ip.y_ax*(-xx1); xx1=0; }
			}
		}
		else {
			temp=xx2-xx1;
			if(temp==0) goto ut;
			vecpolinit_x(&tex_ip, (double)(xx2-xx1), 0);
			if(xx2>XRES) {
				if(xx1>=XRES) goto ut; else xx2=XRES;
			}
			if(xx1<0) {
				if(xx2<=0) goto ut; else { tex_ip.ip_pos.x+=tex_ip.x_ax*(-xx1); tex_ip.ip_pos.y+=tex_ip.y_ax*(-xx1); xx1=0; }
			}
		}

		if (xx2 < XRES) xx2++;
		
		for (i=xx1; i<xx2; i++) { // Rita ut pixlar mellan x-positioner.
			upp=tex_ip.ip_pos.x>>16;
			vpp=tex_ip.ip_pos.y>>16;
			if (upp >= texw) upp = upp % texw;
			if (vpp >= texh) vpp = vpp % texh;
			I=tex->data[(vpp*texw)+upp];
			vid[i]=I PLUSVAL_OP plusVal;
			vecpol_addxdelt(&tex_ip);
		}

ut:
		ysweep++;
		vid+=XRES;
	}
	return 1;
}

void vline(int x, int y1, int y2, uchar col) { 
	int tmp, i;
	uchar *vid;

	if (y1 > y2) { tmp=y1; y1=y2; y2=tmp;}

	if (x < 0 || x >= XRES) return;
	if (y1 < 0) { if (y2 < 0) return; y1=0;}
	if (y2 >= YRES) { if (y1 >= YRES) return; y2=YRES-1; }

	vid = (video+x+y1*XRES);
	for(i = y2-y1+1; i > 0; i--) {
		*vid = col;
		vid = vid + XRES;
	}
}

void hline(int x1, int x2, int y, uchar col) { 
	int tmp;

	if (x1 > x2) { tmp=x1; x1=x2; x2=tmp;}

	if (y < 0 || y >= YRES) return;
	if (x1 < 0) { if (x2 < 0) return; x1=0;}
	if (x2 >= XRES) { if (x1 >= XRES) return; x2=XRES-1; }

	MYMEMSET(video+y*XRES+x1, col, x2-x1+1);
}


/*
	General Bezier curve
	Number of control points is n+1
	0 <= mu < 1    IMPORTANT, the last point is not computed
*/
void curvePoint_N(long n, long *px, long *py, double mu, int *xPoints, int *yPoints) {
	long   k, kn, nn, nkn;
	double blend, muk, munk;
	double bx = 0.0, by = 0.0;

	muk = 1;
	munk = pow(1-mu, (double)n);

	for (k=0; k <= n; k++) {
		nn = n;
		kn = k;
		nkn = n - k;
		blend = muk * munk;
		muk *= mu;
		munk /= (1-mu);
		while (nn >= 1) {
			blend *= nn;
			nn--;
			if (kn > 1) {
				blend /= (double)kn;
				kn--;
			}
			if (nkn > 1) {
				blend /= (double)nkn;
				nkn--;
			}
		}
		bx += (double)xPoints[k] * blend;
		by += (double)yPoints[k] * blend;
	}

	*px = (long)bx;
	*py = (long)by;
}


void bezier(long n, int *xPoints, int *yPoints, uchar col) {
	double mu = 0, mua;
	long i, gran = 20;
	long oldx = xPoints[0], oldy = yPoints[0];
	double ddSx=0, ddSy=0;
	long x,y;
	
	i = (n-3)*5;
	if (i > 0) gran += i;
	
	mua = 1.0 / (double) gran;
	
	for (i = 0; i < gran+1; i++)
	{
		curvePoint_N(n,&x,&y,mu,xPoints,yPoints);
		line(oldx, oldy, x, y, col, 1);
		oldx = x; oldy = y;
		
		mu = mu + mua;
	}
}


// Texturemapper with perspective correction at every Nth pixel (scanline
//	subdivision), subpixels and subtexels, uses floats all the way through
//	except for when drawing each N-pixel span

// Currently not used, since supports 256x256 texture only

/*

static float dizdx, duizdx, dvizdx, dizdy, duizdy, dvizdy;
static float dizdxn, duizdxn, dvizdxn;
static float xa, xb, iza, uiza, viza;
static float dxdya, dxdyb, dizdya, duizdya, dvizdya;
static char *texture;

// Subdivision span-size

#define SUBDIVSHIFT	4
#define SUBDIVSIZE	(1 << SUBDIVSHIFT)

static void drawtpolyperspdivsubtriseg(int y1, int y2, int xSize, int ySize, PREPCOL plusVal);

int drawtpolyperspdivsubtri(intVector *tri, Bitmap *bild, PREPCOL plusVal)
{
	float x1, y1, x2, y2, x3, y3;
	float iz1, uiz1, viz1, iz2, uiz2, viz2, iz3, uiz3, viz3;
	float dxdy1, dxdy2, dxdy3;
	float tempf;
	float denom;
	float dy;
	int y1i, y2i, y3i;
	int side;

	// Shift XY coordinate system (+0.5, +0.5) to match the subpixeling technique

	x1 = (float)tri[0].x + 0.5;
	y1 = (float)tri[0].y + 0.5;
	x2 = (float)tri[1].x + 0.5;
	y2 = (float)tri[1].y + 0.5;
	x3 = (float)tri[2].x + 0.5;
	y3 = (float)tri[2].y + 0.5;

	if (y1==y2 && y2==y3) return 0;
	if (y1 < 0 && y2 < 0 && y3 < 0) return 0;
	if (x1 < 0 && x2 < 0 && x3 < 0) return 0;
	if (y1 >= YRES &&  y2 >= YRES && y3 >= YRES) return 0;
	if (x1 >= XRES &&  x2 >= XRES && x3 >= XRES) return 0;

	// Calculate alternative 1/Z, U/Z and V/Z values which will be interpolated

	iz1 = 1 / tri[0].z;
	iz2 = 1 / tri[1].z;
	iz3 = 1 / tri[2].z;
	uiz1 = tri[0].tex_coord.x * iz1;
	viz1 = tri[0].tex_coord.y * iz1;
	uiz2 = tri[1].tex_coord.x * iz2;
	viz2 = tri[1].tex_coord.y * iz2;
	uiz3 = tri[2].tex_coord.x * iz3;
	viz3 = tri[2].tex_coord.y * iz3;

	texture = bild->data;

	// Sort the vertices in increasing Y order

#define swapfloat(x, y) tempf = x; x = y; y = tempf;
	if (y1 > y2)
	{
		swapfloat(x1, x2);
		swapfloat(y1, y2);
		swapfloat(iz1, iz2);
		swapfloat(uiz1, uiz2);
		swapfloat(viz1, viz2);
	}
	if (y1 > y3)
	{
		swapfloat(x1, x3);
		swapfloat(y1, y3);
		swapfloat(iz1, iz3);
		swapfloat(uiz1, uiz3);
		swapfloat(viz1, viz3);
	}
	if (y2 > y3)
	{
		swapfloat(x2, x3);
		swapfloat(y2, y3);
		swapfloat(iz2, iz3);
		swapfloat(uiz2, uiz3);
		swapfloat(viz2, viz3);
	}
#undef swapfloat

	y1i = y1;
	y2i = y2;
	y3i = y3;

	// Skip poly if it's too thin to cover any pixels at all

	if ((y1i == y2i && y1i == y3i)
	    || ((int) x1 == (int) x2 && (int) x1 == (int) x3))
		return 0;

	// Calculate horizontal and vertical increments for UV axes (these
	//  calcs are certainly not optimal, although they're stable (handles any dy being 0)

	denom = ((x3 - x1) * (y2 - y1) - (x2 - x1) * (y3 - y1));

	if (!denom)		// Skip poly if it's an infinitely thin line
		return 0;

	denom = 1 / denom;	// Reciprocal for speeding up
	dizdx = ((iz3 - iz1) * (y2 - y1) - (iz2 - iz1) * (y3 - y1)) * denom;
	duizdx = ((uiz3 - uiz1) * (y2 - y1) - (uiz2 - uiz1) * (y3 - y1)) * denom;
	dvizdx = ((viz3 - viz1) * (y2 - y1) - (viz2 - viz1) * (y3 - y1)) * denom;
	dizdy = ((iz2 - iz1) * (x3 - x1) - (iz3 - iz1) * (x2 - x1)) * denom;
	duizdy = ((uiz2 - uiz1) * (x3 - x1) - (uiz3 - uiz1) * (x2 - x1)) * denom;
	dvizdy = ((viz2 - viz1) * (x3 - x1) - (viz3 - viz1) * (x2 - x1)) * denom;

	// Horizontal increases for 1/Z, U/Z and V/Z which step one full span ahead

	dizdxn = dizdx * SUBDIVSIZE;
	duizdxn = duizdx * SUBDIVSIZE;
	dvizdxn = dvizdx * SUBDIVSIZE;

	// Calculate X-slopes along the edges

	if (y2 > y1)
		dxdy1 = (x2 - x1) / (y2 - y1);
	if (y3 > y1)
		dxdy2 = (x3 - x1) / (y3 - y1);
	if (y3 > y2)
		dxdy3 = (x3 - x2) / (y3 - y2);

	// Determine which side of the poly the longer edge is on

	side = dxdy2 > dxdy1;

	if (y1 == y2)
		side = x1 > x2;
	if (y2 == y3)
		side = x3 > x2;

	if (!side)	// Longer edge is on the left side
	{
		// Calculate slopes along left edge

		dxdya = dxdy2;
		dizdya = dxdy2 * dizdx + dizdy;
		duizdya = dxdy2 * duizdx + duizdy;
		dvizdya = dxdy2 * dvizdx + dvizdy;

		// Perform subpixel pre-stepping along left edge

		dy = 1 - (y1 - y1i);
		xa = x1 + dy * dxdya;
		iza = iz1 + dy * dizdya;
		uiza = uiz1 + dy * duizdya;
		viza = viz1 + dy * dvizdya;

		if (y1i < y2i)	// Draw upper segment if possibly visible
		{
			// Set right edge X-slope and perform subpixel pre-stepping

			xb = x1 + dy * dxdy1;
			dxdyb = dxdy1;

			drawtpolyperspdivsubtriseg(y1i, y2i, bild->xSize, bild->ySize, plusVal);
		}
		if (y2i < y3i)	// Draw lower segment if possibly visible
		{
			// Set right edge X-slope and perform subpixel pre-stepping

			xb = x2 + (1 - (y2 - y2i)) * dxdy3;
			dxdyb = dxdy3;

			drawtpolyperspdivsubtriseg(y2i, y3i, bild->xSize, bild->ySize, plusVal);
		}
	}
	else	// Longer edge is on the right side
	{
		// Set right edge X-slope and perform subpixel pre-stepping

		dxdyb = dxdy2;
		dy = 1 - (y1 - y1i);
		xb = x1 + dy * dxdyb;

		if (y1i < y2i)	// Draw upper segment if possibly visible
		{
			// Set slopes along left edge and perform subpixel pre-stepping

			dxdya = dxdy1;
			dizdya = dxdy1 * dizdx + dizdy;
			duizdya = dxdy1 * duizdx + duizdy;
			dvizdya = dxdy1 * dvizdx + dvizdy;
			xa = x1 + dy * dxdya;
			iza = iz1 + dy * dizdya;
			uiza = uiz1 + dy * duizdya;
			viza = viz1 + dy * dvizdya;

			drawtpolyperspdivsubtriseg(y1i, y2i, bild->xSize, bild->ySize, plusVal);
		}
		if (y2i < y3i)	// Draw lower segment if possibly visible
		{
			// Set slopes along left edge and perform subpixel pre-stepping

			dxdya = dxdy3;
			dizdya = dxdy3 * dizdx + dizdy;
			duizdya = dxdy3 * duizdx + duizdy;
			dvizdya = dxdy3 * dvizdx + dvizdy;
			dy = 1 - (y2 - y2i);
			xa = x2 + dy * dxdya;
			iza = iz2 + dy * dizdya;
			uiza = uiz2 + dy * duizdya;
			viza = viz2 + dy * dvizdya;

			drawtpolyperspdivsubtriseg(y2i, y3i, bild->xSize, bild->ySize, plusVal);
		}
	}
	
	return 1;
}

static void drawtpolyperspdivsubtriseg(int y1, int y2, int xSize, int ySize, PREPCOL plusVal)
{
	uchar *scr, *scrEnd;
	int x1, x2;
	int x, xcount;
	float z, dx;
	float iz, uiz, viz;
	int u1, v1, u2, v2, u, v, du, dv;
	int maxTexPos = xSize * ySize, texPos;
	
	while (y1 < y2)		// Loop through all lines in segment
	{
		x1 = xa;
		x2 = xb;

		// Perform subtexel pre-stepping on 1/Z, U/Z and V/Z

		dx = 1 - (xa - x1);
		iz = iza + dx * dizdx;
		uiz = uiza + dx * duizdx;
		viz = viza + dx * dvizdx;

		scr = &video[y1 * XRES + x1];

		// Calculate UV for the first pixel

		z = 65536 / iz;
		u2 = uiz * z;
		v2 = viz * z;

		// Length of line segment

		xcount = x2 - x1;

		if (y1 >= 0 && y1 < YRES) {
			
			while (xcount >= SUBDIVSIZE)	// Draw all full-length spans
			{
				// Step 1/Z, U/Z and V/Z to the next span

				iz += dizdxn;
				uiz += duizdxn;
				viz += dvizdxn;

				u1 = u2;
				v1 = v2;

				// Calculate UV at the beginning of next span

				z = 65536 / iz;
				u2 = uiz * z;
				v2 = viz * z;

				u = u1;
				v = v1;

				// Calculate linear UV slope over span

				du = (u2 - u1) >> SUBDIVSHIFT;
				dv = (v2 - v1) >> SUBDIVSHIFT;

				x = SUBDIVSIZE;
				while (x--)	// Draw span
				{
					// Copy pixel from texture to screen

					texPos = ((((int) v) & 0xff0000) >> 8) + ((((int) u) & 0xff0000) >> 16);
					if (texPos < maxTexPos && texPos >= 0 && x1 > 0 && x1 < XRES)
						*scr = texture[texPos] PLUSVAL_OP plusVal;
					scr++;
					x1++;
					
					// Step horizontally along UV axes

					u += du;
					v += dv;
				}

				xcount -= SUBDIVSIZE;	// One span less
			}

			if (xcount)	// Draw last, non-full-length span
			{
				// Step 1/Z, U/Z and V/Z to end of span

				iz += dizdx * xcount;
				uiz += duizdx * xcount;
				viz += dvizdx * xcount;

				u1 = u2;
				v1 = v2;

				// Calculate UV at end of span

				z = 65536 / iz;
				u2 = uiz * z;
				v2 = viz * z;

				u = u1;
				v = v1;


				// Calculate linear UV slope over span

				du = (u2 - u1) / xcount;
				dv = (v2 - v1) / xcount;

				while (xcount--)	// Draw span
				{
					// Copy pixel from texture to screen

					texPos = ((((int) v) & 0xff0000) >> 8) + ((((int) u) & 0xff0000) >> 16);
					if (texPos < maxTexPos && texPos >= 0 && x1 > 0 && x1 < XRES)
						*scr = texture[texPos] PLUSVAL_OP plusVal;
					scr++;
					x1++;
					
					// Step horizontally along UV axes

					u += du;
					v += dv;
				}
			}

		}
		
		// Step vertically along both edges

		xa += dxdya;
		xb += dxdyb;
		iza += dizdya;
		uiza += duizdya;
		viza += dvizdya;

		y1++;
	}
}
*/

// Texturemapper with full perspective correction, subpixels and subtexels, uses floats all the way through

static float dizdx, duizdx, dvizdx, dizdy, duizdy, dvizdy;
static float xa, xb, iza, uiza, viza;
static float dxdya, dxdyb, dizdya, duizdya, dvizdya;
static uchar *texture;

static void drawtpolyperspsubtriseg(int y1, int y2, int xSize, int ySize, PREPCOL plusVal);
static void drawtpolyperspsubtriseg_ZBuffer(int y1, int y2, int xSize, int ySize, PREPCOL plusVal);

void (*drawPerspFunc)(int y1, int y2, int xSize, int ySize, PREPCOL plusVal);

int drawtpolyperspsubtri(intVector *tri, Bitmap *bild, PREPCOL plusVal)
{
	float x1, y1, x2, y2, x3, y3;
	float iz1, uiz1, viz1, iz2, uiz2, viz2, iz3, uiz3, viz3;
	float dxdy1, dxdy2, dxdy3;
	float tempf;
	float denom;
	float dy;
	int y1i, y2i, y3i;
	int side;

	drawPerspFunc = ZBufVideo != NULL? drawtpolyperspsubtriseg_ZBuffer : drawtpolyperspsubtriseg;
	
	// Shift XY coordinate system (+0.5, +0.5) to match the subpixeling technique
	
	x1 = (float)tri[0].x + 0.5;
	y1 = (float)tri[0].y + 0.5;
	x2 = (float)tri[1].x + 0.5;
	y2 = (float)tri[1].y + 0.5;
	x3 = (float)tri[2].x + 0.5;
	y3 = (float)tri[2].y + 0.5;

	if (y1==y2 && y2==y3) return 0;
	if (y1 < 0 && y2 < 0 && y3 < 0) return 0;
	if (x1 < 0 && x2 < 0 && x3 < 0) return 0;
	if (y1 >= YRES &&  y2 >= YRES && y3 >= YRES) return 0;
	if (x1 >= XRES &&  x2 >= XRES && x3 >= XRES) return 0;

	// Calculate alternative 1/Z, U/Z and V/Z values which will be interpolated

	iz1 = 1 / tri[0].z;
	iz2 = 1 / tri[1].z;
	iz3 = 1 / tri[2].z;
	
	uiz1 = tri[0].tex_coord.x * iz1;
	viz1 = tri[0].tex_coord.y * iz1;
	uiz2 = tri[1].tex_coord.x * iz2;
	viz2 = tri[1].tex_coord.y * iz2;
	uiz3 = tri[2].tex_coord.x * iz3;
	viz3 = tri[2].tex_coord.y * iz3;
	
	texture = bild->data;

	// Sort the vertices in ascending Y order

#define swapfloat(x, y) tempf = x; x = y; y = tempf;
	if (y1 > y2)
	{
		swapfloat(x1, x2);
		swapfloat(y1, y2);
		swapfloat(iz1, iz2);
		swapfloat(uiz1, uiz2);
		swapfloat(viz1, viz2);
	}
	if (y1 > y3)
	{
		swapfloat(x1, x3);
		swapfloat(y1, y3);
		swapfloat(iz1, iz3);
		swapfloat(uiz1, uiz3);
		swapfloat(viz1, viz3);
	}
	if (y2 > y3)
	{
		swapfloat(x2, x3);
		swapfloat(y2, y3);
		swapfloat(iz2, iz3);
		swapfloat(uiz2, uiz3);
		swapfloat(viz2, viz3);
	}
#undef swapfloat

	y1i = y1;
	y2i = y2;
	y3i = y3;

	// Skip poly if it's too thin to cover any pixels at all

	if ((y1i == y2i && y1i == y3i)
	    || ((int) x1 == (int) x2 && (int) x1 == (int) x3))
		return 0;

	// Calculate horizontal and vertical increments for UV axes (these
	//  calcs are certainly not optimal, although they're stable (handles any dy being 0)

	denom = ((x3 - x1) * (y2 - y1) - (x2 - x1) * (y3 - y1));

	if (!denom)		// Skip poly if it's an infinitely thin line
		return 0;	

	denom = 1 / denom;	// Reciprocal for speeding up
	dizdx = ((iz3 - iz1) * (y2 - y1) - (iz2 - iz1) * (y3 - y1)) * denom;
	duizdx = ((uiz3 - uiz1) * (y2 - y1) - (uiz2 - uiz1) * (y3 - y1)) * denom;
	dvizdx = ((viz3 - viz1) * (y2 - y1) - (viz2 - viz1) * (y3 - y1)) * denom;
	dizdy = ((iz2 - iz1) * (x3 - x1) - (iz3 - iz1) * (x2 - x1)) * denom;
	duizdy = ((uiz2 - uiz1) * (x3 - x1) - (uiz3 - uiz1) * (x2 - x1)) * denom;
	dvizdy = ((viz2 - viz1) * (x3 - x1) - (viz3 - viz1) * (x2 - x1)) * denom;

	// Calculate X-slopes along the edges

	if (y2 > y1)
		dxdy1 = (x2 - x1) / (y2 - y1);
	if (y3 > y1)
		dxdy2 = (x3 - x1) / (y3 - y1);
	if (y3 > y2)
		dxdy3 = (x3 - x2) / (y3 - y2);

	// Determine which side of the poly the longer edge is on

	side = dxdy2 > dxdy1;

	if (y1 == y2)
		side = x1 > x2;
	if (y2 == y3)
		side = x3 > x2;

	if (!side)	// Longer edge is on the left side
	{
		// Calculate slopes along left edge

		dxdya = dxdy2;
		dizdya = dxdy2 * dizdx + dizdy;
		duizdya = dxdy2 * duizdx + duizdy;
		dvizdya = dxdy2 * dvizdx + dvizdy;

		// Perform subpixel pre-stepping along left edge

		dy = 1 - (y1 - y1i);
		xa = x1 + dy * dxdya;
		iza = iz1 + dy * dizdya;
		uiza = uiz1 + dy * duizdya;
		viza = viz1 + dy * dvizdya;

		if (y1i < y2i)	// Draw upper segment if possibly visible
		{
			// Set right edge X-slope and perform subpixel pre-stepping

			xb = x1 + dy * dxdy1;
			dxdyb = dxdy1;

			(*drawPerspFunc)(y1i, y2i, bild->xSize, bild->ySize, plusVal);
		}
		if (y2i < y3i)	// Draw lower segment if possibly visible
		{
			// Set right edge X-slope and perform subpixel pre-stepping

			xb = x2 + (1 - (y2 - y2i)) * dxdy3;
			dxdyb = dxdy3;

			(*drawPerspFunc)(y2i, y3i, bild->xSize, bild->ySize, plusVal);
		}
	}
	else	// Longer edge is on the right side
	{
		// Set right edge X-slope and perform subpixel pre-stepping

		dxdyb = dxdy2;
		dy = 1 - (y1 - y1i);
		xb = x1 + dy * dxdyb;

		if (y1i < y2i)	// Draw upper segment if possibly visible
		{
			// Set slopes along left edge and perform subpixel pre-stepping

			dxdya = dxdy1;
			dizdya = dxdy1 * dizdx + dizdy;
			duizdya = dxdy1 * duizdx + duizdy;
			dvizdya = dxdy1 * dvizdx + dvizdy;
			xa = x1 + dy * dxdya;
			iza = iz1 + dy * dizdya;
			uiza = uiz1 + dy * duizdya;
			viza = viz1 + dy * dvizdya;

			(*drawPerspFunc)(y1i, y2i, bild->xSize, bild->ySize, plusVal);
		}
		if (y2i < y3i)	// Draw lower segment if possibly visible
		{
			// Set slopes along left edge and perform subpixel pre-stepping

			dxdya = dxdy3;
			dizdya = dxdy3 * dizdx + dizdy;
			duizdya = dxdy3 * duizdx + duizdy;
			dvizdya = dxdy3 * dvizdx + dvizdy;
			dy = 1 - (y2 - y2i);
			xa = x2 + dy * dxdya;
			iza = iz2 + dy * dizdya;
			uiza = uiz2 + dy * duizdya;
			viza = viz2 + dy * dvizdya;

			(*drawPerspFunc)(y2i, y3i, bild->xSize, bild->ySize, plusVal);
		}
	}
	
	return 1;
}

static void drawtpolyperspsubtriseg(int y1, int y2, int xSize, int ySize, PREPCOL plusVal)
{
	uchar *scr;
	int x1, x2;
	float z, u, v, dx;
	float iz, uiz, viz;
	int texPos, maxTexPos = xSize * ySize;

	while (y1 < y2)	// Loop through all lines in the segment
	{
		x1 = xa;
		x2 = xb;

		// Perform subtexel pre-stepping on 1/Z, U/Z and V/Z

		dx = 1 - (xa - x1);
		iz = iza + dx * dizdx;
		uiz = uiza + dx * duizdx;
		viz = viza + dx * dvizdx;

		scr = &video[y1 * XRES + x1];

		if (x1 <= 0) {
			int xp=-x1;
			scr = scr + xp;
			iz += dizdx * xp;
			uiz += duizdx * xp;
			viz += dvizdx * xp;
			x1=0;
		}
		
		if (y1 >= 0 && y1 < YRES) {
			while (x1++ < x2 && x1 <= XRES)	// Draw horizontal line
			{
				// Calculate U and V from 1/Z, U/Z and V/Z
				
				if (iz == 0) iz = 0.001;
				z = 1 / iz;
				
				u = uiz * z;
				v = viz * z;

				if (bAllowRepeated3dTextures) {
					if (u >= xSize) u = ((int)u) % xSize;
					if (v >= ySize) v = ((int)v) % ySize;
				}

				// Copy pixel from texture to screen

				texPos = ((((int) v) ) * (xSize)) + (((int) u) );
				if (texPos < maxTexPos && texPos >= 0)
					*scr = texture[texPos] PLUSVAL_OP plusVal;
				scr++;

				// Step 1/Z, U/Z and V/Z horizontally

				iz += dizdx;
				uiz += duizdx;
				viz += dvizdx;
			}
		}

		// Step along both edges

		xa += dxdya;
		xb += dxdyb;
		iza += dizdya;
		uiza += duizdya;
		viza += dvizdya;

		y1++;
	}
}


static void drawtpolyperspsubtriseg_ZBuffer(int y1, int y2, int xSize, int ySize, PREPCOL plusVal)
{
	uchar *scr;
	int x1, x2;
	float z, u, v, dx;
	float iz, uiz, viz;
	int texPos, maxTexPos = xSize * ySize;
	float *zBufScr;

	while (y1 < y2)	// Loop through all lines in the segment
	{
		x1 = xa;
		x2 = xb;

		// Perform subtexel pre-stepping on 1/Z, U/Z and V/Z

		dx = 1 - (xa - x1);
		iz = iza + dx * dizdx;
		uiz = uiza + dx * duizdx;
		viz = viza + dx * dvizdx;

		scr = &video[y1 * XRES + x1];

		zBufScr = &ZBufVideo[y1 * XRES + x1];

		if (x1 <= 0) {
			int xp=-x1;
			zBufScr = zBufScr + xp;
			scr = scr + xp;
			iz += dizdx * xp;
			uiz += duizdx * xp;
			viz += dvizdx * xp;
			x1=0;
		}
		
		if (y1 >= 0 && y1 < YRES) {
			while (x1++ < x2 && x1 <= XRES)	// Draw horizontal line
			{
				// Calculate U and V from 1/Z, U/Z and V/Z
				
				if (iz == 0) iz = 0.001;
				
				if (iz + 0.00000001 < *zBufScr) { // the 0.00000001 is a hack for cmdgfx since we sometimes draw the same poly twice
					zBufScr++;
					scr++;
					iz += dizdx;
					uiz += duizdx;
					viz += dvizdx;
					continue;
				}
				
				z = 1 / iz;

				*zBufScr = iz;
				zBufScr++;
				
				u = uiz * z;
				v = viz * z;

				if (bAllowRepeated3dTextures) {
					if (u >= xSize) u = ((int)u) % xSize;
					if (v >= ySize) v = ((int)v) % ySize;
				}

				// Copy pixel from texture to screen

				texPos = ((((int) v) ) * (xSize)) + (((int) u) );
				if (texPos < maxTexPos && texPos >= 0)
					*scr = texture[texPos] PLUSVAL_OP plusVal;
				scr++;

				// Step 1/Z, U/Z and V/Z horizontally

				iz += dizdx;
				uiz += duizdx;
				viz += dvizdx;
			}
		}

		// Step along both edges

		xa += dxdya;
		xb += dxdyb;
		iza += dizdya;
		uiza += duizdya;
		viza += dvizdya;

		y1++;
	}
}


static void drawpolyseg(int y1, int y2, int col);
int __scan3(intVector tri[], uchar col) {

	float x1, y1, x2, y2, x3, y3;
	float iz1, uiz1, viz1, iz2, uiz2, viz2, iz3, uiz3, viz3;
	float dxdy1, dxdy2, dxdy3;
	float tempf;
	float denom;
	float dy;
	int y1i, y2i, y3i;
	int side;

	// Shift XY coordinate system (+0.5, +0.5) to match the subpixeling technique
	
	x1 = (float)tri[0].x + 0.5;
	y1 = (float)tri[0].y + 0.5;
	x2 = (float)tri[1].x + 0.5;
	y2 = (float)tri[1].y + 0.5;
	x3 = (float)tri[2].x + 0.5;
	y3 = (float)tri[2].y + 0.5;

	if (y1==y2 && y2==y3) return 0;
	if (y1 < 0 && y2 < 0 && y3 < 0) return 0;
	if (x1 < 0 && x2 < 0 && x3 < 0) return 0;
	if (y1 >= YRES &&  y2 >= YRES && y3 >= YRES) return 0;
	if (x1 >= XRES &&  x2 >= XRES && x3 >= XRES) return 0;

	// Calculate alternative 1/Z, U/Z and V/Z values which will be interpolated

	iz1 = 1 / tri[0].z;
	iz2 = 1 / tri[1].z;
	iz3 = 1 / tri[2].z;
	
	uiz1 = tri[0].tex_coord.x * iz1;
	viz1 = tri[0].tex_coord.y * iz1;
	uiz2 = tri[1].tex_coord.x * iz2;
	viz2 = tri[1].tex_coord.y * iz2;
	uiz3 = tri[2].tex_coord.x * iz3;
	viz3 = tri[2].tex_coord.y * iz3;
	
	// Sort the vertices in ascending Y order

#define swapfloat(x, y) tempf = x; x = y; y = tempf;
	if (y1 > y2)
	{
		swapfloat(x1, x2);
		swapfloat(y1, y2);
		swapfloat(iz1, iz2);
		swapfloat(uiz1, uiz2);
		swapfloat(viz1, viz2);
	}
	if (y1 > y3)
	{
		swapfloat(x1, x3);
		swapfloat(y1, y3);
		swapfloat(iz1, iz3);
		swapfloat(uiz1, uiz3);
		swapfloat(viz1, viz3);
	}
	if (y2 > y3)
	{
		swapfloat(x2, x3);
		swapfloat(y2, y3);
		swapfloat(iz2, iz3);
		swapfloat(uiz2, uiz3);
		swapfloat(viz2, viz3);
	}
#undef swapfloat

	y1i = y1;
	y2i = y2;
	y3i = y3;

	// Skip poly if it's too thin to cover any pixels at all

	if ((y1i == y2i && y1i == y3i)
	    || ((int) x1 == (int) x2 && (int) x1 == (int) x3))
		return 0;

	// Calculate horizontal and vertical increments for UV axes (these
	//  calcs are certainly not optimal, although they're stable (handles any dy being 0)

	denom = ((x3 - x1) * (y2 - y1) - (x2 - x1) * (y3 - y1));

	if (!denom)		// Skip poly if it's an infinitely thin line
		return 0;	

	denom = 1 / denom;	// Reciprocal for speeding up
	dizdx = ((iz3 - iz1) * (y2 - y1) - (iz2 - iz1) * (y3 - y1)) * denom;
	duizdx = ((uiz3 - uiz1) * (y2 - y1) - (uiz2 - uiz1) * (y3 - y1)) * denom;
	dvizdx = ((viz3 - viz1) * (y2 - y1) - (viz2 - viz1) * (y3 - y1)) * denom;
	dizdy = ((iz2 - iz1) * (x3 - x1) - (iz3 - iz1) * (x2 - x1)) * denom;
	duizdy = ((uiz2 - uiz1) * (x3 - x1) - (uiz3 - uiz1) * (x2 - x1)) * denom;
	dvizdy = ((viz2 - viz1) * (x3 - x1) - (viz3 - viz1) * (x2 - x1)) * denom;

	// Calculate X-slopes along the edges

	if (y2 > y1)
		dxdy1 = (x2 - x1) / (y2 - y1);
	if (y3 > y1)
		dxdy2 = (x3 - x1) / (y3 - y1);
	if (y3 > y2)
		dxdy3 = (x3 - x2) / (y3 - y2);

	// Determine which side of the poly the longer edge is on

	side = dxdy2 > dxdy1;

	if (y1 == y2)
		side = x1 > x2;
	if (y2 == y3)
		side = x3 > x2;

	if (!side)	// Longer edge is on the left side
	{
		// Calculate slopes along left edge

		dxdya = dxdy2;
		dizdya = dxdy2 * dizdx + dizdy;
		duizdya = dxdy2 * duizdx + duizdy;
		dvizdya = dxdy2 * dvizdx + dvizdy;

		// Perform subpixel pre-stepping along left edge

		dy = 1 - (y1 - y1i);
		xa = x1 + dy * dxdya;
		iza = iz1 + dy * dizdya;
		uiza = uiz1 + dy * duizdya;
		viza = viz1 + dy * dvizdya;

		if (y1i < y2i)	// Draw upper segment if possibly visible
		{
			// Set right edge X-slope and perform subpixel pre-stepping

			xb = x1 + dy * dxdy1;
			dxdyb = dxdy1;

			drawpolyseg(y1i, y2i, col);
		}
		if (y2i < y3i)	// Draw lower segment if possibly visible
		{
			// Set right edge X-slope and perform subpixel pre-stepping

			xb = x2 + (1 - (y2 - y2i)) * dxdy3;
			dxdyb = dxdy3;

			drawpolyseg(y2i, y3i, col);
		}
	}
	else	// Longer edge is on the right side
	{
		// Set right edge X-slope and perform subpixel pre-stepping

		dxdyb = dxdy2;
		dy = 1 - (y1 - y1i);
		xb = x1 + dy * dxdyb;

		if (y1i < y2i)	// Draw upper segment if possibly visible
		{
			// Set slopes along left edge and perform subpixel pre-stepping

			dxdya = dxdy1;
			dizdya = dxdy1 * dizdx + dizdy;
			duizdya = dxdy1 * duizdx + duizdy;
			dvizdya = dxdy1 * dvizdx + dvizdy;
			xa = x1 + dy * dxdya;
			iza = iz1 + dy * dizdya;
			uiza = uiz1 + dy * duizdya;
			viza = viz1 + dy * dvizdya;

			drawpolyseg(y1i, y2i, col);
		}
		if (y2i < y3i)	// Draw lower segment if possibly visible
		{
			// Set slopes along left edge and perform subpixel pre-stepping

			dxdya = dxdy3;
			dizdya = dxdy3 * dizdx + dizdy;
			duizdya = dxdy3 * duizdx + duizdy;
			dvizdya = dxdy3 * dvizdx + dvizdy;
			dy = 1 - (y2 - y2i);
			xa = x2 + dy * dxdya;
			iza = iz2 + dy * dizdya;
			uiza = uiz2 + dy * duizdya;
			viza = viz2 + dy * dvizdya;

			drawpolyseg(y2i, y3i, col);
		}
	}
	
	return 1;

}

static void drawpolyseg(int y1, int y2, int col)
{
	uchar *scr;
	int x1, x2;
	float z, u, v, dx;
	float iz, uiz, viz;

	while (y1 < y2)		// Loop through all lines in the segment
	{
		x1 = xa;
		x2 = xb;

		// Perform subtexel pre-stepping on 1/Z, U/Z and V/Z

		dx = 1 - (xa - x1);
		iz = iza + dx * dizdx;
		uiz = uiza + dx * duizdx;
		viz = viza + dx * dvizdx;

		scr = &video[y1 * XRES + x1];

		if (y1 >= 0 && y1 < YRES) {
			while (x1++ < x2 && x1 <= XRES)	// Draw horizontal line
			{
				// Calculate U and V from 1/Z, U/Z and V/Z
				if (x1 <= 0) {
					scr++;
					iz += dizdx;
					uiz += duizdx;
					viz += dvizdx;
					continue;
				}
				
				//if (iz == 0) iz = 0.001;
				//z = 1 / iz;

				*scr = col;
				scr++;
				
				// Step 1/Z, U/Z and V/Z horizontally

				iz += dizdx;
				uiz += duizdx;
				viz += dvizdx;
			}
		}

		// Step along both edges

		xa += dxdya;
		xb += dxdyb;
		iza += dizdya;
		uiza += duizdya;
		viza += dvizdya;

		y1++;
	}
}


int __scanConvex(intVector vv[], int points, uchar col) {
	intVector v[3];
	register int i;
	int ok = 0;

	memcpy(v,vv,sizeof(intVector));
	if (points<3) return 0;
	for (i=1; i<points-1; i++) {
		memcpy(&(v[1]),&(vv[i]),sizeof(intVector)<<1);
		ok += __scan3(v, col);
	}
	return (ok > 0);
}
