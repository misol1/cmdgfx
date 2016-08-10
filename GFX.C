// gfx.c

#include "gfxlib.h"

void setpixel(int x, int y, unsigned char col) {

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

int scanConvex_tmap(intVector vv[], int points, int clipedges[], Bitmap *bild, int plusVal) {
  intVector v[3];
  register int i,j;
  int ok = 0;

  if (points<3) return 0;
  
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
  return (ok > 0);
}


int scanConvex_goraud(intVector vv[], int points, int clipedges[], int I[], int goraudType, int plusVal, int divZ, int plusZ, int maxZ) {
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
/*
  if (clipedges!=NULL) { // Om clipedges innehåller klipprektangel, så klipp!
    cp=goClip(v,&outlen,clipedges);
    if (outlen<3 || cp==NULL)
      return -1;
    else if (outlen>3) {
      scanConvex(cp,outlen,zbuffer);
      return 1;
    }
  } */

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
		memset(vid+xx2,col,xx1-xx2+1);
    }
    else {
      if(xx2>=XRES) {
        if(xx1>=XRES) goto esc; else xx2=XRES-1;
		}
      if(xx1<0) {
        if(xx2<=0) goto esc; else xx1=0;
		}
		memset(vid+xx1,col,xx2-xx1+1);
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

int scan3_goraud(intVector vv[], int clipedges[], int I[], int goraudType, int plusVal, int divZ, int plusZ, int maxZ) {
  register int ysweep,xx1,xx2,yyy;
  register uchar *vid;
  int i,MINy,MAXy,MIDy=0,yEND,j;
  long int lut1,lut2,x1,x2;
  intVector *cp;
  float shadla_diff,shadra_diff,shadr_diff,shadl_diff,diff_sx,diff_sxa=0;
  float temp;

  cp=vv;
/*
  if (clipedges!=NULL) { // Om clipedges innehåller klipprektangel, så klipp!
    cp=goClip(v,&outlen,clipedges);
    if (outlen<3 || cp==NULL)
      return -1;
    else if (outlen>3) {
      scanConvex(cp,outlen,zbuffer);
      return 1;
    }
  } */

  if (goraudType == GORAUD_TYPE_Z) {
	  for (i=0; i<3; i++) {
			I[i] = cp[i].z/divZ+plusZ+8; // 6, divZ=100
			if (I[i] < 8) I[i]=8;
			if (I[i] > maxZ+8) I[i]=maxZ+8; // maxZ+8=19
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

  shadla_diff=(I[MIDy]-I[MINy])/(float)(cp[MIDy].y-cp[MINy].y+1); 
  shadra_diff=(I[MAXy]-I[MINy])/(float)(cp[MAXy].y-cp[MINy].y+1);
  shadl_diff=shadr_diff=I[MINy];

  vid=video+ysweep*XRES;
  yEND=cp[MAXy].y;
  if(yEND>YRES-1) yEND=YRES; //-1;

  while(ysweep<yEND) {  // Svep från Ymin till Ymax

    x1+=lut1; x2+=lut2;  // Lutning adderas till x-position.
    shadr_diff+=shadra_diff; shadl_diff+=shadla_diff;

    if (ysweep==cp[MIDy].y) { // Skärning ("triangel 2" börjar h„r)
      lut1=(cp[MAXy].x-cp[MIDy].x)<<16;  // Ny lutning.
      lut1/=(cp[MAXy].y-cp[MIDy].y+1);
      x1=(cp[MIDy].x)<<16;
      x1+=lut1;
      shadla_diff=(I[MAXy]-I[MIDy])/(float)(cp[MAXy].y-cp[MIDy].y+1);
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
      vid[i]=diff_sx + plusVal;
      diff_sx+=diff_sxa;  // Interpolera diffuse
    }
/*
    asm ("gloop: "
         "movl  %%esi,%%eax\n\t"
         "shrl  $16,%%eax\n\t"
         "movb  %%al, (%%ebx)\n\t"
         "incl  %%ebx\n\t"
         "addl  %%edi,%%esi\n\t"
         "decw  %%cx\n\t"
         "jnz  gloop"
         :
         : "b" (vid+xx1), "c" (xx2-xx1+1), "S" ((int)(diff_sx*65536)), "D" ((int)(diff_sxa*65536))
         : "%eax"
    );
*/

    skip:
    ysweep++;
    vid+=XRES;
  }
  return 1;
}

void fbox(int x, int y, int xrange, int yrange, uchar col) {
  register uchar *vid;
  register int i;

  if (x>=XRES || y>=YRES) return;
  if (x<0) { xrange+=x; x=0; }
  if (y<0) { yrange+=y; y=0; }
  if (x+xrange>=XRES) { xrange-=(x+xrange)-(XRES-1); }
  if (y+yrange>=YRES) { yrange-=(y+yrange)-(YRES-1); }
  if (xrange<0 || yrange<0) return;

  vid=video+y*XRES+x;
  for (i=0; i<=yrange; i++) {
    memset(vid, col, xrange+1);
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
    y1=(vid+y>=video && vid+y<v1);
    y2=(vid-y>=video && vid-y<v1);
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
    y1=(vid+y>=video && vid+y<v1);
    y2=(vid-y>=video && vid-y<v1);
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
      memset(v1, col, xx);
    v1=vid-dx+y;
    if (v1>=video && v1<v2)
      memset(v1, col, xx);

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
      memset(v1, col, xx);
    v1=vid-dx+y;
    if (v1>=video && v1<v2)
      memset(v1, col, xx);

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
int compar(int *x, int *y) {
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
        if(x1>=XRES) goto dont; else x2=XRES-1;
		}
      if(x1<0) {
        if(x2<=0) goto dont; else x1=0;
		}

		switch(bitOp) {
			case BIT_OP_OR: for (k = x1; k < x1 + x2-x1+1; k++) vid[k] |= col; break;
			case BIT_OP_AND: for (k = x1; k < x1 + x2-x1+1; k++) vid[k] &= col; break;
			case BIT_OP_XOR: for (k = x1; k < x1 + x2-x1+1; k++) vid[k] ^= col; break;
			case BIT_OP_ADD_REAL: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = vid[k]; bitTemp+=col; if (bitTemp > 255) bitTemp = 255; vid[k] = bitTemp; } break;
			case BIT_OP_SUB_REAL: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = vid[k]; bitTemp-=col; if (bitTemp < 0) bitTemp = 0; vid[k] = bitTemp; } break;
			case BIT_OP_SUB_ME_REAL: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = col; bitTemp-=vid[k]; if (bitTemp < 0) bitTemp = 0; vid[k] = bitTemp; } break;
	case BIT_OP_ADD: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = vid[k]&0xf; bitTemp+=col&0xf; if (bitTemp > 15) bitTemp = 15; bitTemp2 = (vid[k]>>4)&0xf; bitTemp2+=(col>>4)&0xf; if (bitTemp2 > 15) bitTemp2 = 15; vid[k] = (bitTemp2 << 4) | bitTemp; } break;
	case BIT_OP_SUB: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = vid[k]&0xf; bitTemp-=col&0xf; if (bitTemp < 0) bitTemp = 0; bitTemp2 = (vid[k]>>4)&0xf; bitTemp2-=(col>>4)&0xf; if (bitTemp2 < 0) bitTemp2 = 0; vid[k] = (bitTemp2 << 4) | bitTemp; } break;
	case BIT_OP_SUB_ME: for (k = x1; k < x1 + x2-x1+1; k++) { bitTemp = col&0xf; bitTemp-=vid[k]&0xf; if (bitTemp < 0) bitTemp = 0; bitTemp2 = (col>>4)&0xf; bitTemp2-=(vid[k]>>4)&0xf; if (bitTemp2 < 0) bitTemp2 = 0; vid[k] = (bitTemp2 << 4) | bitTemp; } break;
			default: memset(vid+x1,col,x2-x1+1);
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
    vp->xy_l+=vp->x_ay_l; //if (vp->xy_l > 93) vp->xy_l = 0;
    vp->yy_l+=vp->y_ay_l; //if (vp->yy_l > 93) vp->yy_l = 0;
    vp->zy_l+=vp->z_ay_l; //if (vp->zy_l > 93) vp->zy_l = 0;
  }
  else {
    vp->xy_r+=vp->x_ay_r; //if (vp->xy_r > 93) vp->xy_r = 0;
    vp->yy_r+=vp->y_ay_r; //if (vp->yy_r > 93) vp->yy_r = 0;
    vp->zy_r+=vp->z_ay_r; //if (vp->zy_r > 93) vp->zy_r = 0;
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

int ax,ay;
int uf, vf;
int ui, vi;

int scan3_tmap(intVector vv[], int clipedges[], Bitmap *tex, int plusVal) {
  register int I;
  uchar *vid;
  register int ysweep,xx1,xx2,yyy;
  register int texw, texh;
  int i,MINy,MAXy,MIDy=0,yEND, j;
  int lut1,lut2,x1,x2;
  intVector *cp;
  int upp,vpp;
  float temp;
  vec_interpolate tex_ip;

  texw = tex->xSize;
  texh = tex->ySize;
  
  cp=vv;
/*
  if (clipedges!=NULL) { // Om clipedges innehåller klipprektangel, så klipp!
    cp=goClip(v,&outlen,clipedges);
    if (outlen<3 || cp==NULL)
      return -1;
    else if (outlen>3) {
      scanConvex(cp,outlen,zbuffer);
      return 1;
    }
  } */

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

	 if (xx2 < XRES) xx2++; // newly added... ok?
	 
    for (i=xx1; i<xx2; i++) { // Rita ut pixlar mellan x-positioner.
      upp=tex_ip.ip_pos.x>>16;// /tex_ip.ip_pos.z;  // "invertera" perspektiveffekt
      vpp=tex_ip.ip_pos.y>>16;// /tex_ip.ip_pos.z;
		if (upp >= texw) upp = upp % texw;
		if (vpp >= texh) vpp = vpp % texh;
//      I=tex.data[(vpp<<9)+upp];
      I=tex->data[(vpp*texw)+upp];
      vid[i]=I + plusVal;
      vecpol_addxdelt(&tex_ip);
    }

/*
    ui=tex_ip.x_ax>>16;
    vi=tex_ip.y_ax>>16;
    uf=tex_ip.x_ax;
    vf=tex_ip.y_ax;

    asm ("pushl %%ebp\n\t"
         "movw  %%di,%%bp\n\t"
         "shrl  $16,%%edi\n\t"
         "loop: "
         "movb  (%%edx,%%ecx),%%al\n\t"
         "movb  %%al, (%%ebx)\n\t"
         "incl  %%ebx\n\t"
         "addw  uf,%%di\n\t"
         "adcb  ui,%%cl\n\t"
         "addw  vf,%%si\n\t"
         "adcb  vi,%%ch\n\t"
         "decw  %%bp\n\t"
         "jnz  loop\n\t"
         "popl %%ebp"
         :
         : "b" (vid+xx1), "D" (xx2-xx1 + (tex_ip.ip_pos.y<<16)), "d" (tex.data), "c" ((tex_ip.ip_pos.x>>16)+((tex_ip.ip_pos.y>>16)<<8)) , "S" (tex_ip.ip_pos.x)
    );
*/
/*
    ax=tex_ip.x_ax; ay=tex_ip.y_ax;

    asm ("pushl %%ebp\n\t"
         "movl  %%di,%%bp\n\t"
         "loop: "
         "movl  %%esi,%%eax\n\t"
         "movl  %%ecx,%%edi\n\t"
         "shrl  $16,%%eax\n\t"
         "shrl  $16,%%edi\n\t"
         "shll  $8,%%edi\n\t"
         "addw  %%ax,%%di\n\t"
         "movb  (%%edx,%%edi),%%al\n\t"
         "movb  %%al, (%%ebx)\n\t"
         "incl  %%ebx\n\t"
         "addl  ay,%%ecx\n\t"
         "addl  ax,%%esi\n\t"
         "decw  %%bp\n\t"
         "jnz  loop\n\t"
         "popl %%ebp"
         :
         : "b" (vid+xx1), "D" (xx2-xx1), "d" (tex.data), "S" (tex_ip.ip_pos.x), "c" (tex_ip.ip_pos.y)
    );
*/
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

  memset(video+y*XRES+x1, col, x2-x1+1);
}
