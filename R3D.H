#ifndef R3DH
#define R3DH

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "math.h"
#include "bmap.h"

#define MAGIC_NUMBER_TOO_CLOSE_FOR_PROJECTION 100

typedef struct point3d {
	int x,y,z;
	int vx,vy,vz;
	float u,v;
	float ox,oy,oz;
} point3d;

extern int XRES, YRES;

void Make_torus_object(point3d obj[], float shaper);
void Make_ball_object(point3d obj[], float shaper);
void Make_cube_object(point3d obj[]);
void rot3dPoints(point3d obj[], int points, int xg, int yg, int distance, float rx, float ry, float rz, float aspect, int movex, int movey, int movez, int bAllowOnlyPositiveZ, int projectionDepth);
void rot3dPoints_doubleRotation(point3d obj[], int points, int xg, int yg, int distance, float rx, float ry, float rz, float aspect, int movex, int movey, int movez, int bAllowOnlyPositiveZ, int projectionDepth, float rx2, float ry2, float rz2, int movex2, int movey2, int movez2);

#define R3D_MAX_V_PER_FACE 28

typedef struct obj3d {
	int nofPoints;
	int nofFaces;
	point3d *objData;
	int *faceData;

	int nofNormals;
	int nofTexturePoints;
	float *texCoords;
	int *texData;
	int *faceBitmapIndex;
	Bitmap **bmaps;
	int nofBmaps;
} obj3d;

typedef int (*readTexture)(Bitmap *bmap, char *fname);

obj3d *readObj(char *fname, float scale, float modx, float mody, float modz, int dec1, readTexture fpReadTexture);
obj3d *readPly(char *fname, float scale, float modx, float mody, float modz);
obj3d *readPlg(char *fname, float scale, float modx, float mody, float modz);
void freeObj3d(obj3d *obj);

#endif
