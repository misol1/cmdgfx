#include "r3d.h"

#define PI 3.1415926535897932

// Note: Does NOT properly parse e.g. -3.399e-15, IFF e is larger than 9 (sets result to 0 in that case)
float naiveToF(const char *p) {
	static float pow10[10] = { 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };
	
	float r = 0.0;
	int neg = 0;
	if (*p == '-') {
		neg = 1;
		++p;
	}
	while (*p >= '0' && *p <= '9') {
		r = (r*10.0) + (*p - '0');
		++p;
	}
	if (*p == '.') {
		float f = 0.0;
		int n = 0;
		++p;
		while (*p >= '0' && *p <= '9') {
			f = (f*10.0) + (*p - '0');
			++p;
			++n;
		}
		r += f / pow10[n];
	}
	
	if(*p == 'e' && *(p+1) == '-') {
		int n = 0;
		p = p + 2;
		while (*p >= '0' && *p <= '9') {
			n = (n*10.0) + (*p - '0');
			++p;
		}
		if (n > 9) r = 0; else r /= pow10[n];
	}
	
	if (neg) {
		r = -r;
	}
	return r;
}

int naiveAtoi(const char *p) {
	int n = 0;
	int neg = 0;
	if (*p == '-') {
		neg = 1;
		++p;
	}

	while (*p >= '0' && *p <= '9') {
		n = (n*10.0) + (*p - '0');
		++p;
	}
	
	if (neg) n = -n;	 
	return n;
}

char *strgets(char *in, char *ut, int max) {
	int nof;
	char *ch;
	
	if (*in == 0) return NULL;

	ch = strchr(in, '\n');
	if (ch == NULL) 
		nof = strlen(in);
	else {
		nof = ch - in;
	}

	if (nof > max) nof = max;
	strncpy (ut, in, nof);
	ut[nof] = 0;
	//printf("%s\n", ut); getch();
	
	in = in + nof + (ch? 1 : 0);
	return in;
}


int readIntSequence(char *fr, int *out, char *delims, int maxRead) {
	int read = 0;
	int n = 0, ok;
	int neg;
	//	int delen = strlen(delims);

	do {
		while (*fr == delims[0] || *fr == delims[1]) fr++;

		neg = 0;
		if (*fr == '-') {
			neg = 1;
			++fr;
		}
		n = 0; ok = 0;
		while (*fr >= '0' && *fr <= '9') {
			n = (n*10.0) + (*fr - '0');
			++fr;
			ok = 1;
		}
		if (ok) {
			if (neg) n = -n;
			out[read] = n;
			read++;
		}
	} while (read < maxRead && (*fr == delims[0] || *fr == delims[1]));
	
	return read;
}

/*
void Make_torus_object(point3d obj[],float shaper) {
	float c,d,e,f,g;
	int i,j;

	d=0;
	for (i=0; i<60; i++) {
		c=0; d+=(2*PI)/60;
		e=250; f=e; g=f/(10*shaper);
		for (j=0; j<60; j++) {
			obj[i*60+j].x=sin(d)*e;
			obj[i*60+j].y=cos(d)*e;
			obj[i*60+j].z=sin(c)*f;
			c+=(2*PI)/60;
			e+=sin(c)*g;
		}
	}
}

void Make_ball_object(point3d obj[], float shaper) {
	float c,d,e;
	int i,j;

	d=0;
	for (i=0; i<60; i++) {
		c=0; d+=(2*PI)/120;
		e=sin(d*shaper)*625; 

		for (j=0; j<60; j++) {
			obj[i*60+j].x=sin(c)*e;
			obj[i*60+j].y=cos(c)*e;
			obj[i*60+j].z=cos(d)*625;
			c+=(2*PI)/60;
		}
	}
}

void Make_cube_object(point3d obj[]) {
	int i,j,k, i2,j2,k2;
	i2=-500; j2=-500; k2=-500;

	for (i=0; i<15; i++) {
		j2=-500;
		for (j=0; j<15; j++) {
			k2=-500;
			for (k=0; k<15; k++) {
				obj[k+j*15+i*15*15].x=k2;
				obj[k+j*15+i*15*15].y=j2;
				obj[k+j*15+i*15*15].z=i2;
				k2+=70;
			}
			j2+=70;
		}
		i2+=70;
	}
} */

void rot3dPoints(point3d obj[], int points, int xg, int yg, int distance, float rx, float ry, float rz, float aspect, int movex, int movey, int movez, int bAllowOnlyPositiveZ, int projectionDepth) {
	float srx, crx, sry, cry, srz ,crz;
	int i, pe, ped, xpp, ypp, zpp, xpp2, H;
	float asp;

	if (projectionDepth == 0) projectionDepth = 500;
	H = projectionDepth << 12; // projectionDepth decides the "narrowness" of projection (the higher, the more narrow)
	
	asp = aspect;
	/// asp = (aspect/((float)XRES/(float)YRES));

	srx=sin(rx); crx=cos(rx); sry=sin(ry);
	cry=cos(ry); srz=sin(rz); crz=cos(rz);

	for (i=0; i<points; i++) {

		ypp=obj[i].y*crx + obj[i].z*srx;
		zpp=obj[i].z*crx - obj[i].y*srx;

		xpp=obj[i].x*cry + zpp*sry;
		obj[i].vz=zpp*cry - obj[i].x*sry;

		xpp2=xpp*crz + ypp*srz;
		ypp=ypp*crz - xpp*srz;

		xpp2 += movex;
		ypp -= movey;
		obj[i].vz += movez;
		
		ped = distance+obj[i].vz; if (!ped) ped = 1;
		if (ped < MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION) {
			if (bAllowOnlyPositiveZ || (!bAllowOnlyPositiveZ && ped >-MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION)) {
				ped = MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION;
			}
		}
		pe=H/ped;

		obj[i].vx=((xpp2*pe)>>12)+xg;
		obj[i].vy=((ypp*pe)>>12)*asp+yg;
	}
}


void rot3dPoints_doubleRotation(point3d obj[], int points, int xg, int yg, int distance, float rx, float ry, float rz, float aspect, int movex, int movey, int movez, int bAllowOnlyPositiveZ, int projectionDepth, float rx2, float ry2, float rz2, int movex2, int movey2, int movez2 ) {
	float srx, crx, sry, cry, srz, crz;
	float srx2, crx2, sry2, cry2, srz2, crz2;
	int i, pe, ped, xpp, ypp, zpp, xpp2, ypp2, H;
	float asp;

	if (projectionDepth == 0) projectionDepth = 500;
	H = projectionDepth << 12; // projectionDepth decides the "narrowness" of projection (the higher, the more narrow)
	
//	asp = (aspect/((float)XRES/(float)YRES));
	asp = aspect;

	srx=sin(rx); crx=cos(rx); sry=sin(ry);
	cry=cos(ry); srz=sin(rz); crz=cos(rz);

	srx2=sin(rx2); crx2=cos(rx2); sry2=sin(ry2);
	cry2=cos(ry2); srz2=sin(rz2); crz2=cos(rz2);

	for (i=0; i<points; i++) {

		ypp=obj[i].y*crx + obj[i].z*srx;
		zpp=obj[i].z*crx - obj[i].y*srx;

		xpp=obj[i].x*cry + zpp*sry;
		obj[i].vz=zpp*cry - obj[i].x*sry;

		xpp2=xpp*crz + ypp*srz;
		ypp=ypp*crz - xpp*srz;

		xpp2 += movex;
		ypp -= movey;
		obj[i].vz += movez;

		
		ypp2=ypp*crx2 + obj[i].vz*srx2;
		zpp=obj[i].vz*crx2 - ypp*srx2;

		xpp=xpp2*cry2 + zpp*sry2;
		obj[i].vz=zpp*cry2 - xpp2*sry2;

		xpp2=xpp*crz2 + ypp2*srz2;
		ypp2=ypp2*crz2 - xpp*srz2;

		xpp2 += movex2;
		ypp2 -= movey2;
		obj[i].vz += movez2;		
		
		ped = distance+obj[i].vz; if (!ped) ped = 1;
		if (ped < MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION) {
			if (bAllowOnlyPositiveZ || (!bAllowOnlyPositiveZ && ped >-MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION)) {
				ped = MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION;
			}
		}
		pe=H/ped;

		obj[i].vx=((xpp2*pe)>>12)+xg;
		obj[i].vy=((ypp2*pe)>>12)*asp+yg;
	}
}



void freeObj3d(obj3d *obj) {
	int i;
	if (!obj) return;
	if (obj->objData) free(obj->objData);
	if (obj->faceData) free(obj->faceData);
	if (obj->texCoords) free(obj->texCoords);
	if (obj->texData) free(obj->texData);
	if (obj->bmaps) {
		for (i = 0; i < obj->nofBmaps; i++)
			if (obj->bmaps[i]) freeBitmap(obj->bmaps[i], 1); 
		free(obj->bmaps);
	}
	if (obj->faceBitmapIndex) free(obj->faceBitmapIndex);
	free(obj);
}

obj3d *readPly(char *fname, float scale, float modx, float mody, float modz) {
	char keywords[8][64] = { "ply", "element face ", "element vertex ", "end_header" };
	char data[256], *fr, *fpos;
	int i,j,k,l, nofread;
	char * pch, *filedata;
	float x,y,z;
	obj3d *obj;
	FILE *fp;

	fp = fopen(fname, "r");
	if (!fp)
		return NULL;

	obj = (obj3d *) calloc(sizeof(obj3d), 1);
	if (!obj) {
		fclose(fp);
		return NULL;
	}
	obj->nofFaces = obj->nofPoints = 0;

	filedata = (char *)malloc(3000000 * sizeof(char));
	if (!filedata) {
		fclose(fp);
		free(obj);
		return NULL;
	}

	nofread = fread(filedata, 1, 3000000, fp);
	filedata[nofread] = 0;
	fr = filedata;
	fclose(fp);

	do {
		fr = strgets(fr, data, 255);
		if (fr) {
			fpos = strstr(data, keywords[1]);
			if (fpos)
			obj->nofFaces = atoi((char *)fpos + strlen(keywords[1]));
			fpos = strstr(data, keywords[2]);
			if (fpos)
			obj->nofPoints = atoi((char *)fpos + strlen(keywords[2]));
		}
	} while(fr && strstr(data, keywords[3]) == NULL);

	if (!fr || obj->nofFaces < 1 || obj->nofPoints < 1) {
		fclose(fp);
		free(obj);
		free(filedata);
		return NULL;
	}	  

	obj->objData = (point3d *) malloc(sizeof(point3d) * obj->nofPoints); if (!obj->objData) { fclose(fp); freeObj3d(obj); return NULL; }
	obj->faceData = (int *) malloc(sizeof(int) * R3D_MAX_V_PER_FACE * obj->nofFaces); if (!obj->faceData) { fclose(fp); freeObj3d(obj); return NULL; }
	
	for (i = 0, j = 0; i < obj->nofPoints; i++) {
		fr = strgets(fr, data, 255);
		if (!fr) {
			fclose(fp);
			freeObj3d(obj);
			return NULL;
		}

		pch = strtok (data," \t");
		nofread = x=y=z=0;
		while (pch != NULL && nofread < 3) {
			if (nofread == 0) x = naiveToF(pch);
			else if (nofread == 1) y = naiveToF(pch);
			else if (nofread == 2) z = naiveToF(pch);
			nofread++;
			pch = strtok (NULL, " \t");
		}

		if (nofread == 3) {
			obj->objData[j].x = (x+modx) * scale;
			obj->objData[j].y = (y+mody) * scale;
			obj->objData[j].z = (z+modz) * scale;
			obj->objData[j].ox = x;
			obj->objData[j].oy = y;
			obj->objData[j].oz = z;
			j++;
		} else i--;
	}
	
	for (i = 0, j = 0; i < obj->nofFaces; i++) {
		fr = strgets(fr,data, 255);
		if (!fr) {
			freeObj3d(obj); fclose(fp); return NULL;
		}
		k = j*R3D_MAX_V_PER_FACE;
		nofread = readIntSequence(data, &obj->faceData[k], " \t", R3D_MAX_V_PER_FACE);
		if (nofread >= 2 && obj->faceData[k] < R3D_MAX_V_PER_FACE && obj->faceData[k] == nofread-1) {
			for (l = k+1; l < obj->faceData[k] + k; l++)
				if(obj->faceData[l] < 0 || obj->faceData[l] >= obj->nofPoints) {
					freeObj3d(obj); fclose(fp); return NULL;
				}
			j++;
		} else {
			i--;
		}
	}

	/*
for (j = 0; j < obj->nofPoints; j++) {
	printf("%d %d %d\n", obj->objData[j].x, obj->objData[j].y, obj->objData[j].z);
}
printf("\n");
for (j = 0; j < obj->nofFaces; j++) {
	printf("%d %d %d %d %d %d\n", obj->faceData[j*R3D_MAX_V_PER_FACE], obj->faceData[j*R3D_MAX_V_PER_FACE+1], obj->faceData[j*R3D_MAX_V_PER_FACE+2], obj->faceData[j*R3D_MAX_V_PER_FACE+3], obj->faceData[j*R3D_MAX_V_PER_FACE+4], obj->faceData[j*R3D_MAX_V_PER_FACE]+5);
}
	
	printf("%d %d\n", obj->nofFaces, obj->nofPoints);
	getch();	*/
	
	//  fclose(fp);
	free(filedata);
	return obj;
}


obj3d *readObj(char *fname, float scale, float modx, float mody, float modz, int dec1, readTexture fpReadTexture, int bAllowRepeated3dTextures) {
	char keywords[8][64] = { "v ", "vn ", "vt ", "f ", "usemtl " };
	int nofV = 0, nofN = 0, nofT = 0, nofF = 0, nofB = 0;
	int i,j, bmapIndex = 0, nofread;
	char data[256], *fr, *fpos;
	char *lfpos, *filedata;
	float x,y,z;
	obj3d *obj;
	FILE *fp;

	fp = fopen(fname, "r");
	if (!fp)
		return NULL;

	filedata = (char *)malloc(3000000 * sizeof(char));
	if (!filedata) {
		fclose(fp);
		return NULL;
	}

	nofread = fread(filedata, 1, 3000000, fp);
	filedata[nofread] = 0;
	fr = filedata;
	fclose(fp);

	do {
		fr = strgets(fr, data, 255);
		if (fr) {
			fpos = strstr(data, keywords[0]); // v
			if (fpos == data) nofV++;
			fpos = strstr(data, keywords[1]); // vn
			if (fpos == data) nofN++;
			fpos = strstr(data, keywords[2]); // vt
			if (fpos == data) nofT++;
			fpos = strstr(data, keywords[3]); // f
			if (fpos == data) nofF++;
			fpos = strstr(data, keywords[4]); // usemtl
			if (fpos == data) nofB++;
		}
	} while(fr);

	//  printf("%d %d %d %d\n", nofV, nofF, nofN, nofT);
	if (nofV < 1 || nofF < 1) {
		free(filedata);
		return NULL;
	}

	obj = (obj3d *) calloc(sizeof(obj3d), 1);
	if (!obj || nofV < 1 || nofF < 1) {
		free(filedata);
		return NULL;
	}
	
	obj->nofPoints = nofV;
	obj->nofFaces = nofF;
	obj->nofBmaps = nofB;
	obj->nofNormals = nofN;
	obj->nofTexturePoints = nofT;

	obj->objData = (point3d *) malloc(sizeof(point3d) * obj->nofPoints); if (!obj->objData) { freeObj3d(obj); free(filedata); return NULL; }
	obj->faceData = (int *) calloc(sizeof(int) * R3D_MAX_V_PER_FACE * obj->nofFaces, 1); if (!obj->faceData) { free(filedata); freeObj3d(obj); return NULL; }
	if (nofT > 0) {
		obj->texCoords = (float *) malloc(sizeof(float) * 2 * nofT);
		obj->texData = (int *) calloc(sizeof(int) * R3D_MAX_V_PER_FACE * obj->nofFaces, 1);
		if (!obj->texCoords || !obj->texData) { freeObj3d(obj); free(filedata); return NULL; }
	}
	if (nofB > 0) {
		obj->bmaps = (Bitmap **) calloc(sizeof( Bitmap *) * nofB, 1);
		obj->faceBitmapIndex = (int *) calloc(sizeof(int) * obj->nofFaces, 1);
		if (!obj->bmaps || !obj->faceBitmapIndex) { freeObj3d(obj); free(filedata); return NULL; }
	}
	nofF = nofV = nofT = nofN = 0;	

	fr = filedata;	
	
	do {
		fr = strgets(fr, data, 255);
		if (fr) {
			fpos = strstr(data, keywords[0]); // v
			if (fpos == data) {
				char * pch;
				pch = strtok (data," \t");
				pch = strtok (NULL, " \t");
				nofread = x=y=z=0;
				while (pch != NULL && nofread < 3) {
					if (nofread == 0) x = naiveToF(pch);
					else if (nofread == 1) y = naiveToF(pch);
					else if (nofread == 2) z = naiveToF(pch);
					nofread++;
					pch = strtok (NULL, " \t");
				}

				if (nofread == 3) {
					obj->objData[nofV].x = (x+modx) * scale;
					obj->objData[nofV].y = (y+mody) * scale;
					obj->objData[nofV].z = (z+modz) * scale;
					
					obj->objData[nofV].ox = x;
					obj->objData[nofV].oy = y;
					obj->objData[nofV].oz = z;
					nofV++;
				}
			}
			
			fpos = strstr(data, keywords[1]); // vn
			if (fpos == data) nofN++;

			fpos = strstr(data, keywords[2]); // vt
			if (fpos == data) {
				char * pch;
				pch = strtok (data," \t");
				pch = strtok (NULL, " \t");
				nofread = x=y=0;
				while (pch != NULL && nofread < 2) {
					if (nofread == 0) x = naiveToF(pch);
					else if (nofread == 1) y = naiveToF(pch);
					nofread++;
					pch = strtok (NULL, " \t");
				}
				
				if (nofread == 2) {
					if (x<0) x=-x;
					if (x>1 && !bAllowRepeated3dTextures) x=1;
					if (y<0) y=-y;
					if (y>1 && !bAllowRepeated3dTextures) y=1;
					obj->texCoords[nofT*2] = x;
					obj->texCoords[nofT*2+1] = y;
					nofT++;
				}
			}

			fpos = strstr(data, keywords[4]); // usemtl
			if (fpos == data) {
				if ((lfpos=strchr(data, '\n')) != NULL)
				*lfpos = '\0';

				if (obj->bmaps[bmapIndex]) {
					freeBitmap(obj->bmaps[bmapIndex], 1);
				}
				
				obj->bmaps[bmapIndex] = (Bitmap *) malloc(sizeof(Bitmap));
				if (obj->bmaps[bmapIndex]) {
					if (fpReadTexture)
					j = fpReadTexture(obj->bmaps[bmapIndex], (char *)&data[strlen(keywords[4])] );
					else
					j = PCXload(obj->bmaps[bmapIndex], (char *)&data[strlen(keywords[4])] );
					if (j) {
						bmapIndex++;
					} else {
						obj->bmaps[bmapIndex] = NULL;
					}
				}
				//printf("%d %s\n", j, (char *)&data[strlen(keywords[4])]); getch();
				//printf("%d\n", bmapIndex); getch();
			}
			
			fpos = strstr(data, keywords[3]); // f
			if (fpos == data) {
				char * pch;
				pch = strtok (data," \t");
				pch = strtok (NULL, " \t");
				j = 0;
				while (pch != NULL) {
					//	nofread = sscanf(pch, "%d/%d/%d ", &obj->faceData[nofF*R3D_MAX_V_PER_FACE + j + 1] ,&dumv1, &dumv2);
					nofread = readIntSequence(pch, &obj->faceData[nofF*R3D_MAX_V_PER_FACE + j + 1], "/", 3);
					if (nofread > 0) {
						if (obj->texData && nofread > 1) { obj->texData[nofF*R3D_MAX_V_PER_FACE + j + 1] = obj->faceData[nofF*R3D_MAX_V_PER_FACE + j + 2] - 1; }
						obj->faceData[nofF*R3D_MAX_V_PER_FACE + j + 1]--;
						j++;
					}
					pch = strtok (NULL, " \t");
				}
				obj->faceData[nofF*R3D_MAX_V_PER_FACE] = j;
				if (dec1) obj->faceData[nofF*R3D_MAX_V_PER_FACE]--;
				if (obj->faceBitmapIndex) obj->faceBitmapIndex[nofF] = (bmapIndex > 0)? bmapIndex - 1 : 0;
				nofF++;
			}
		}
	} while(fr);

	if(nofV != obj->nofPoints || obj->nofFaces != nofF || obj->nofNormals != nofN || obj->nofTexturePoints != nofT) {
		// printf("%d %d  %d %d   %d %d   %d %d\n", nofV, obj->nofPoints,obj->nofFaces,nofF,obj->nofNormals,nofN,obj->nofTexturePoints,nofT); getch();
		freeObj3d(obj); free(filedata); return NULL;
	}

	for (j = 0; j < obj->nofFaces; j++) {
		for (i = 0; i < obj->faceData[j*R3D_MAX_V_PER_FACE]; i++) {
		  if (obj->faceData[j*R3D_MAX_V_PER_FACE + i] < 0) obj->faceData[j*R3D_MAX_V_PER_FACE + i] = obj->nofPoints + 1 + obj->faceData[j*R3D_MAX_V_PER_FACE + i];
		  if (obj->faceData[j*R3D_MAX_V_PER_FACE + i] > obj->nofPoints || obj->faceData[j*R3D_MAX_V_PER_FACE + i] < 0)  { freeObj3d(obj); free(filedata); return NULL; }
		}
	}

	// Too messed up to check for now: bmapIndex is increased if a palette is set, and also I naively assume there are as many texture points specified as vertices.
	/* if (bmapIndex > 0) {
		for (j = 0; j < obj->nofFaces; j++) {
			for (i = 0; i < obj->faceData[j*R3D_MAX_V_PER_FACE]; i++) {
			  if (obj->texData[j*R3D_MAX_V_PER_FACE + i] >= obj->nofTexturePoints || obj->texData[j*R3D_MAX_V_PER_FACE + i] < 0)  { freeObj3d(obj); free(filedata); return NULL; }
			}
		}
	} */
	
	/*
for (j = 0; j < obj->nofPoints; j++) {
	printf("%d %d %d\n", obj->objData[j].x, obj->objData[j].y, obj->objData[j].z);
}
printf("\n");
for (j = 0; j < obj->nofFaces; j++) {
	printf("%d %d %d %d %d %d\n", obj->faceData[j*R3D_MAX_V_PER_FACE], obj->faceData[j*R3D_MAX_V_PER_FACE+1], obj->faceData[j*R3D_MAX_V_PER_FACE+2], obj->faceData[j*R3D_MAX_V_PER_FACE+3], obj->faceData[j*R3D_MAX_V_PER_FACE+4], obj->faceData[j*R3D_MAX_V_PER_FACE]+5);
}
	
printf("\n");
for (j = 0; j < obj->nofFaces; j++) {
	printf("%d %d %d %d %d %d\n", obj->texData[j*R3D_MAX_V_PER_FACE], obj->texData[j*R3D_MAX_V_PER_FACE+1], obj->texData[j*R3D_MAX_V_PER_FACE+2], obj->texData[j*R3D_MAX_V_PER_FACE+3], obj->texData[j*R3D_MAX_V_PER_FACE+4], obj->texData[j*R3D_MAX_V_PER_FACE]+5);
}
printf("\n");
for (j = 0; j < nofT; j++) {
	printf("%f %f\n", obj->texCoords[j*2], obj->texCoords[j*2+1]);
}
	printf("%d %d\n", obj->nofFaces, obj->nofPoints);
	getch();	
*/

	obj->nofBmaps = bmapIndex;

	free(filedata);
	return obj;
}


/* Räknar ut normaler för samtliga vertex i ett objekt */
/*
void insertnormal(Object *o) {
int i, j;
Triangle *tri;
Vector t[3], n, *v;

tri = o->triangles;
for (i = 0; i < o->nt; i++) {
	for (j = 0; j < 3; j++) {
		memcpy(&(t[j]), &(o->vertices[tri->vertex[j]].world), sizeof(Vector));
	}

	n = Normal(t);
	for (j = 0; j < 3; j++) {
		v = &(o->vertices[tri->vertex[j]].normal);
		*v = Add(*v, n);
	}
	tri++;
}

for (i = 0; i < o->nv; i++) {
	v = &(o->vertices[i].normal);
	*v = ScalarVecDiv(Length(*v), *v);
}
}
*/

/* Läser en rad från en PLG-fil */
char *PLG_getline(char *s, int n, FILE *fp) {
	char buf[4096];
	int i, j;

	for (;;) {
		if (!fgets(buf, sizeof buf, fp))
			return 0;
		/* kill trailing CR */
		buf[strlen(buf)-1] = 0;
		/* eat leading white space */
		for (i = 0; isspace(buf[i]); i++)
			;
		/* buf[i] is now 1st non-white character */
		/* copy remaining characters, up to NULL or # into s */
		for (j = 0; j < n && buf[i+j] != 0 && buf[i+j] != '#'; j++)
			s[j] = buf[i+j];
		s[j] = 0;
		/* make sure we really got something */
		if (strlen(s))		
			return s;
	}
}

obj3d *readPlg(char *fname, float scale, float modx, float mody, float modz) {
	char buf[4096], *bufp;
	char name[128];
	char texname[128];
	int i, polys, nv;
	FILE *fp;
	obj3d *obj = NULL;
	float x,y,z;
	int nofread;
	char * pch;
	
	fp = fopen(fname, "r");
	if (!fp) {
		return NULL;
	}
	if ((bufp = PLG_getline(buf, sizeof(buf), fp)) != NULL) {
		strcpy(texname, "");
		nofread = sscanf(bufp, "%s %d %d %s", name, &nv, &polys, texname);
		if (nofread < 3 || nv < 1 || polys < 1)
			return NULL;
		
		obj = (obj3d *) calloc(sizeof(obj3d), 1);
		if (!obj) {
			return NULL;
		}
		
		obj->nofPoints = nv;
		obj->nofFaces = polys;
		obj->objData = (point3d *) malloc(sizeof(point3d) * obj->nofPoints); if (!obj->objData) { fclose(fp); freeObj3d(obj); return NULL; }
		obj->faceData = (int *) malloc(sizeof(int) * R3D_MAX_V_PER_FACE * obj->nofFaces); if (!obj->faceData) { fclose(fp); freeObj3d(obj); return NULL; }

		/* read vertices */
		for (i = 0; i < nv; i++) {
			if (!(bufp = PLG_getline(buf, sizeof buf, fp))) {
				//fprintf(stderr, "PLG file %s truncated?\n", fname);
				freeObj3d(obj);
				fclose(fp);
				return NULL;
			}
			
			// nofread = sscanf(bufp, "%f %f %f", &x, &y, &z);
			pch = strtok (bufp," \t");
			nofread = x=y=z=0;
			while (pch != NULL && nofread < 3) {
				if (nofread == 0) x = naiveToF(pch);
				else if (nofread == 1) y = naiveToF(pch);
				else if (nofread == 2) z = naiveToF(pch);
				nofread++;
				pch = strtok (NULL, " \t");
			}
			
			if (nofread == 3) {
				obj->objData[i].x = (x+modx) * scale;
				obj->objData[i].y = (y+mody) * scale;
				obj->objData[i].z = ((z+modz) * scale) * -1;  // PLG files are defined in a left-handed system

				obj->objData[i].ox = x;
				obj->objData[i].oy = y;
				obj->objData[i].oz = z;
			} else i--;
		}

		/* read (convex, hopefully) polygons */
		for (i = 0; i < polys; i++) {
			int j, n;
			char *token;
			if (!(bufp = PLG_getline(buf, sizeof buf, fp))) {
				//fprintf(stderr, "PLG file %s truncated?\n", fname);
				freeObj3d(obj);
				fclose(fp);
				return NULL;
			}
			token = strtok(bufp, " "); //sscanf(token, "%x", &color);
			token = strtok(0, " ");
			if (!token) { freeObj3d(obj); fclose(fp); return NULL; }
			n = naiveAtoi(token);
			if (n >= R3D_MAX_V_PER_FACE) { freeObj3d(obj); fclose(fp); return NULL; }
			obj->faceData[i*R3D_MAX_V_PER_FACE] = n;

			for (j = 0; j < n; j++) {
				token = strtok(0, " ");
				if (!token) { freeObj3d(obj); fclose(fp); return NULL; }
				
				obj->faceData[i*R3D_MAX_V_PER_FACE+j+1] = naiveAtoi(token);
				if (obj->faceData[i*R3D_MAX_V_PER_FACE+j+1] >= obj->nofPoints || obj->faceData[i*R3D_MAX_V_PER_FACE+j+1] < 0) { freeObj3d(obj); fclose(fp); return NULL; }
			}
		}
		// insertnormal(op);	

		/*
for (int j = 0; j < obj->nofPoints; j++) {
	printf("%d %d %d\n", obj->objData[j].x, obj->objData[j].y, obj->objData[j].z);
}
printf("\n");
for (int j = 0; j < obj->nofFaces; j++) {
	printf("%d %d %d %d %d %d %d\n", obj->faceData[j*R3D_MAX_V_PER_FACE], obj->faceData[j*R3D_MAX_V_PER_FACE+1], obj->faceData[j*R3D_MAX_V_PER_FACE+2], obj->faceData[j*R3D_MAX_V_PER_FACE+3], obj->faceData[j*R3D_MAX_V_PER_FACE+4], obj->faceData[j*R3D_MAX_V_PER_FACE+5], obj->faceData[j*R3D_MAX_V_PER_FACE+6]);
}

	printf("%d %d\n", obj->nofFaces, obj->nofPoints);
	getch();	
*/
	}

	fclose(fp);
	return obj;
}
