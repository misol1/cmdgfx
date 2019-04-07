// bmap.c

#include <stdio.h>
#include <stdlib.h>
#include "gfxlib.h"
#include "datasize.h"

int PCXload (Bitmap *bild,char filename[]) {
	FILE *ifp;
	uchar c,d;
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

		bild->data=(uchar *)calloc((PCXh.Xmax+1)*(PCXh.Ymax+1)*4, sizeof(uchar));
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


#ifdef _RGB32

unsigned int endianReadInt(FILE* file) {
	unsigned char  b[4]; 
	unsigned int i;

   if ( fread( b, 1, 4, file) < 4 )
     return 0;
   i = (b[3]<<24) | (b[2]<<16) | (b[1]<<8) | b[0]; // big endian
   //i = (b[0]<<24) | (b[1]<<16) | (b[2]<<8) | b[3]; // little endian
   return i;
}

unsigned short int endianReadShort(FILE* file) {
	unsigned char  b[2]; 
	unsigned short s;

   if ( fread( b, 1, 2, file) < 2 )
     return 0;
   s = (b[1]<<8) | b[0]; // big endian
   //s = (b[0]<<8) | b[1]; // little endian
   return s;
}


int BMPload (Bitmap *image,char filename[]) {
    FILE *file = NULL;
    unsigned long size;                 // size of the image in bytes.
    unsigned long i;                    // standard counter.
    unsigned short int planes;          // number of planes in image (must be 1) 
    unsigned short int bpp;             // number of bits per pixel (must be 24)
    unsigned int temp;                          // temporary color storage for bgr-rgb conversion.
	unsigned char *data = NULL;
	int j, k, mod, modSize;
	
    if ((file = fopen(filename, "rb"))==NULL)
    {
		//printf("File Not Found : %s\n",filename);
		return 0;
    }
    
    // seek through the bmp header, up to the width/height:
    fseek(file, 18, SEEK_CUR);

    if (!(image->xSize = endianReadInt(file))) {
		//printf("Error reading width from %s.\n", filename);
		goto OUT;
    }
    //printf("Width of %s: %lu\n", filename, image->xSize);
    
    if (!(image->ySize = endianReadInt(file))) {
		//printf("Error reading height from %s.\n", filename);
		goto OUT;
    }
    //printf("Height of %s: %lu\n", filename, image->ySize);
    
	mod = image->xSize % 4;
	
    size = image->xSize * image->ySize;

    if (!(planes=endianReadShort(file))) {
		//printf("Error reading planes from %s.\n", filename);
		goto OUT;
    }
    if (planes != 1) {
		//printf("Planes from %s is not 1: %u\n", filename, planes);
		goto OUT;
    }

    if (!(bpp = endianReadShort(file))) {
		//printf("Error reading bpp from %s.\n", filename);
		goto OUT;
    }
    if (bpp != 24) {
		//printf("Bpp from %s is not 24: %u\n", filename, bpp);
		goto OUT;
    }
	
    // seek past the rest of the bitmap header.
    fseek(file, 24, SEEK_CUR);

    image->data = (uchar *) malloc(size * sizeof(uchar));
    if (image->data == NULL) {
		//printf("Error allocating memory for color-corrected image data");
		goto OUT;
    }
	
	modSize = size * 3 + image->ySize * mod;
    data = (unsigned char *) malloc(modSize);
    if (data == NULL) {
		//printf("Error allocating memory for color-corrected image data");
		goto OUT;
    }
	
    if ((i = fread(data, modSize, 1, file)) != 1) {
		//printf("Error reading image data from %s.\n", filename);
		goto OUT;
    }

	j = (image->ySize - 1) * image->xSize;
	k = 0;
    for (i=0; i<modSize; i+=3) { // reverse all colors. (bgr -> rgb)
		image->data[j + k] = (data[i]) | (data[i+1]<<8) | (data[i+2]<<16);
		k++; if(k == image->xSize) { k=0; j-= image->xSize; i+=mod; }
    }

OUT:
	if (data) free(data);
	if (file) fclose(file);
    return 1;
}



int BMPsave (uchar *cols, char filename[], int w, int h){
	long buffer_size, byte_width;
	unsigned char b1;
	unsigned short b2;
	unsigned long b4;
	int i, j, k;
	FILE *fp;
	
	byte_width = w * 3;
	byte_width = (byte_width + 3) & ~3;	// aligned to 4 bytes
	buffer_size = byte_width * h;

	if ((fp = fopen(filename, "wb")) == NULL) {
		//printf("Couldn't open the file!!\n");
		return 0;
	}
	
	/* can't write struct in single call because compiler might put in alignments */
	b1='B'; fwrite(&b1, 1, 1, fp);
  	b1='M'; fwrite(&b1, 1, 1, fp);
	b4 = 14 + 40 + buffer_size; fwrite(&b4, 4, 1, fp);
	b4 = 0; fwrite(&b4, 4, 1, fp);
	b4 = 14 + 40; fwrite(&b4, 4, 1, fp);

	/* write image header */
	b4=40; fwrite(&b4, 4, 1, fp);
	b4=w; fwrite(&b4, 4, 1, fp);
	b4=h; fwrite(&b4, 4, 1, fp);
	b2=1; fwrite(&b2, 2, 1, fp);
	b2=24; fwrite(&b2, 2, 1, fp);
	b4=0; fwrite(&b4, 4, 1, fp);
	b4=buffer_size; fwrite(&b4, 4, 1, fp);
	b4=2952; fwrite(&b4, 4, 1, fp);
	b4=2952; fwrite(&b4, 4, 1, fp);
	b4=0; fwrite(&b4, 4, 1, fp);
	b4=0; fwrite(&b4, 4, 1, fp);
		
	/* order of colors are blue, green, red */	
	for (i=h-1; i>=0; i--) {
		for (j=0; j<w; j++) {
			b1=(cols[i*w+j]) & 0xff; fwrite(&b1, 1, 1, fp); // b
			b1=(cols[i*w+j]>>8) & 0xff; fwrite(&b1, 1, 1, fp); // g
			b1=(cols[i*w+j]>>16) & 0xff; fwrite(&b1, 1, 1, fp); // r
		}
		/* row alignment */
		for (k=0; k < (byte_width - w*3); k++) {
			fputc(0, fp);
		}
	}
	
	fclose(fp);
	return 1;
}

int BXYsave (unsigned char *chars, uchar *cols, char filename[], int w, int h) {
	unsigned char b1;
	unsigned long b4;
	FILE *fp;
	
	if ((fp = fopen(filename, "wb")) == NULL) {
		//printf("Couldn't open the file!!\n");
		return 0;
	}
	
	b4=w; fwrite(&b4, 4, 1, fp);
	b4=h; fwrite(&b4, 4, 1, fp);

	fwrite(cols, 8, w*h, fp);
	fwrite(chars, 1, w*h, fp);
	
	fclose(fp);
	return 1;
}


int BXYload (Bitmap *bCols,Bitmap *bChars,char filename[]) {
	unsigned long b4;
	FILE *fp;
	int w,h;
	unsigned char *chTemp;
	
	if ((fp = fopen(filename, "rb")) == NULL) {
		//printf("Couldn't open the file!!\n");
		return 0;
	}
	
	fread(&b4, 4, 1, fp); w = bCols->xSize=bChars->xSize=b4;
	fread(&b4, 4, 1, fp); h = bCols->ySize=bChars->ySize=b4;

	chTemp = (unsigned char *)malloc(w*h);
	bChars->data = (uchar *)malloc(w*h*sizeof(uchar));
	bCols->data = (uchar *)malloc(w*h*sizeof(uchar));
	
	fread(bCols->data, 8, w*h, fp);
	fread(chTemp, 1, w*h, fp);
	
	for (int i = 0; i < w*h; i++) bChars->data[i] = chTemp[i];
	
	free(chTemp);
	
	fclose(fp);
	return 1;
}


#endif



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
	register uchar *vid=video+x+y*XRES, *bmp=bild->data, *v1=video+FRAMESIZE;
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
	register uchar *vid=video+x+y*XRES,*bmp=bild->data;
	register uchar *v1=video+FRAMESIZE, *bbmp;
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
	register uchar *vid=video+x+y*XRES,*bmp=bild->data;
	register uchar *v1=video+FRAMESIZE, *bbmp;
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
	register uchar *vid=video+x+y*XRES, *bmp=bild->data, *v1=video+FRAMESIZE;
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
