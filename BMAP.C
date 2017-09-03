// bmap.c

#include <stdio.h>
#include <stdlib.h>
#include "gfxlib.h"

int PCXload (Bitmap *bild,char filename[]) {
	FILE *ifp;
	unsigned char c,d;
	unsigned int i,j=0,k=0;
	struct PCXheader PCXh;
	unsigned char *filedata = NULL;

	ifp=fopen(filename,"rb");
	if (ifp!=NULL) { // Öppna fil
		fread(&PCXh,1,128,ifp);       // Läs in PCX-headern
		fseek(ifp,-768,2);            // "Hoppa" i filen till palettpositionen

		for (i=0; i<256; i++) { // Fyll en array med färgvärdena
			bild->cols[i].R=fgetc(ifp);
			bild->cols[i].G=fgetc(ifp);
			bild->cols[i].B=fgetc(ifp);
		}

		fseek(ifp,128,0);  // Hoppa förbi headern.

		bild->data=(unsigned char *)calloc((PCXh.Xmax+1)*(PCXh.Ymax+1)*4, sizeof(unsigned char));
		if (bild->data==NULL) {
			return 0;
		}
		filedata=(unsigned char *)malloc((PCXh.Xmax+1)*(PCXh.Ymax+1)*4 *  sizeof(unsigned char));
		if (filedata==NULL) {
			free(bild->data);
			return 0;
		}
		fread(filedata, 1, (PCXh.Xmax+1)*(PCXh.Ymax+1)*4, ifp);
		fclose(ifp);
		
		bild->xSize=PCXh.Xmax+1;
		bild->ySize=PCXh.Ymax+1;
		bild->transpVal = -1;

		while (j<(PCXh.Xmax+1)*(PCXh.Ymax+1)) {
			c=filedata[k++];
			if (c>192) {     // Enligt PCX enkla RLE-kodning så innebär ett värde
				c-=192;        // över 192 att vi ska repetera nästföljande byte
				d=filedata[k++];  // (värde-192) gånger.
			}
			else {
				d=c; c=1;
			}

			for (i=0; i<c; i++)
				bild->data[j++]=d;
		}
		free(filedata);
		return 1;
	}

	if (filedata) free(filedata);
	
	return 0;
}


void freeBitmap(Bitmap *bild, int bFreeBasePointer) {
	if (!bild)
		return;
	if (bild->data)
		free(bild->data);
	if (bild->extras) {
		if (bild->extrasType == EXTRAS_BITMAP) {
			freeBitmap((Bitmap *)bild->extras, 1);
		} else {
			free(bild->extras);
		}
	}
	if (bFreeBasePointer)
		free(bild);
}

/*
void putBitmap (int x, int y, Bitmap *bild) {
	register unsigned char *vid=video+x+y*XRES, *bmp=bild->data, *v1=video+FRAMESIZE;
	register int i, xsize = bild->xSize;

	if (x>=XRES || y>=YRES || (x<0 && x+bild->xSize<0) || (y<0 && y+bild->ySize<0) )
		return;
	if (x<0) { vid-=x; bmp-=x; xsize+=x; x=0; }
	if (x+xsize>=XRES) { xsize-=(x+xsize)-XRES; }

	for (i=0; i<bild->ySize; i++) {
		if (vid>=video && vid<v1) {
			memcpy(vid,bmp,xsize);
		}
		vid+=XRES; bmp+=bild->xSize;
	}
}


void putBitmap_scaled (int x, int y, int xrange, int yrange, Bitmap *bild) {
	register unsigned char *vid=video+x+y*XRES,*bmp=bild->data;
	register unsigned char *v1=video+FRAMESIZE, *bbmp;
	register int i,j;
	float dx,dy,x0,y0=0,xs=0;

	if (x>=XRES || y>=YRES || (x<0 && x+xrange<0) || (y<0 && y+yrange<0) )
		return;

	dx=(float)(bild->xSize)/(float)(xrange);
	dy=(float)(bild->ySize)/(float)(yrange);

	if (x+xrange>=XRES) { xrange-=(x+xrange)-XRES; }
	if (x<0) { xrange+=x; vid-=x; xs=dx*(-x);}

	for (j=0; j<yrange; j++) {
		x0=xs;
		if (vid>=video && vid<v1) {
			bbmp=bmp+(int)(y0)*bild->xSize;
			for (i=0; i<xrange; i++) {
				vid[i]=bbmp[(int)x0];
				x0+=dx;
			}
		}
		vid+=XRES;
		y0+=dy;
	}
}

void put_transBitmap_scaled (int x, int y, int xrange, int yrange, Bitmap *bild) {
	register unsigned char *vid=video+x+y*XRES,*bmp=bild->data;
	register unsigned char *v1=video+FRAMESIZE, *bbmp;
	register int i,j;
	float dx,dy,x0,y0=0,xs=0;

	if (x>=XRES || y>=YRES || (x<0 && x+xrange<0) || (y<0 && y+yrange<0) )
		return;

	dx=(float)(bild->xSize)/(float)(xrange);
	dy=(float)(bild->ySize)/(float)(yrange);

	if (x+xrange>=XRES) { xrange-=(x+xrange)-XRES; }
	if (x<0) { xrange+=x; vid-=x; xs=dx*(-x);}

	for (j=0; j<yrange; j++) {
		x0=xs;
		if (vid>=video && vid<v1) {
			bbmp=bmp+(int)(y0)*bild->xSize;
			for (i=0; i<xrange; i++) {
				if (bbmp[(int)x0])
				vid[i]=bbmp[(int)x0];
				x0+=dx;
			}
		}
		vid+=XRES;
		y0+=dy;
	}
}
*/

void put_transparent_Bitmap (int x, int y, Bitmap *bild) {
	register unsigned char *vid=video+x+y*XRES, *bmp=bild->data, *v1=video+FRAMESIZE;
	register int i,j, xsize = bild->xSize;

	if (x>=XRES || y>=YRES || (x<0 && x+bild->xSize<0) || (y<0 && y+bild->ySize<0) )
		return;
	if (x<0) { vid-=x; bmp-=x; xsize+=x; x=0;}
	if (x+xsize>=XRES) { xsize-=(x+xsize)-XRES; }

	for (i=0; i<bild->ySize; i++) {
		if (vid>=video && vid<v1) {
			for (j=0; j<xsize; j++) {
				if (bmp[j])
				vid[j]=bmp[j];
			}
		}
		vid+=XRES; bmp+=bild->xSize;
	}
}

void shadeBitmap (int x, int y, Bitmap *bild, int addon) {
	register int i,j, xsize = bild->xSize;
	register uchar *vid=video+x+y*XRES,*bmap=bild->data,*vvid,*v1=video+FRAMESIZE;

	if (x>=XRES || y>=YRES || (x<0 && x+bild->xSize<0) || (y<0 && y+bild->ySize<0) )
		return;
	if (x<0) { vid-=x; bmap-=x; xsize+=x; x=0; }
	if (x+xsize>=XRES) { xsize-=(x+xsize)-XRES; }

	if (addon==0) {
		for(i=0; i<bild->ySize*XRES; i+=XRES) {
			vvid=vid+i;
			if (vvid>=video && vvid<v1) {
				for(j=0; j<xsize; j++)
				if(bmap[j])
				vvid[j]+=bmap[j];
			}
			bmap+=bild->xSize;
		}
	}
	else {
		for(i=0; i<bild->ySize*XRES; i+=XRES) {
			vvid=vid+i;
			if (vvid>=video && vvid<v1) {
				for(j=0; j<xsize; j++)
				if(bmap[j])
				vvid[j]+=addon;
			}
			bmap+=bild->xSize;
		}
	}	
}
