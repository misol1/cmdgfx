#include <math.h>
#include <stdio.h>
#include "algebra.h"

/* Diverse funktioner från Grafik gk. */

Matrix Scale(Vector v) {            /* get scalematrix */
	Matrix m = { v.x,   0,   0,   0,
						0, v.y,   0,   0,
						0,   0, v.z,   0, 
						0,   0,   0,   1 };
	return m;
}

Matrix Translate(Vector v) {        /* get translationmatrix */
	Matrix m = {1,  0,  0, v.x,
					0,  1,  0, v.y,
					0,  0,  1, v.z,
					0,  0,  0,   1 };
	return m;
}

Matrix Rotate(float theta, angle a) {    /* get rotatationmatrix */
	Matrix Rx = {  1, 0, 0, 0,
						0, (float)cos(theta), (float)-(sin(theta)), 0,
						0, (float)sin(theta), (float)cos(theta), 0,
						0, 0, 0, 1 };

	Matrix Ry = { (float)cos(theta), 0, (float)sin(theta), 0,
						0, 1, 0, 0,
						(float)-(sin(theta)), 0, (float)cos(theta), 0,
						0, 0, 0, 1 };

	Matrix Rz = {  (float)cos(theta), (float)-(sin(theta)), 0, 0,
						(float)sin(theta), (float)cos(theta), 0, 0,
						0, 0, 1, 0,
						0, 0, 0, 1 };

	/* which matrix to return depends on which angle user wants */
	switch (a) {
	case ROT_X:
		return Rx;

	case ROT_Y:
		return Ry;

	case ROT_Z:
		return Rz;
	}
	return Rx;
}

Vector CrossProduct(Vector a, Vector b) {
	Vector v = { a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x };
	return v;
}

float DotProduct(Vector a, Vector b) {
	return a.x*b.x + a.y*b.y + a.z*b.z;
}

Vector Subtract(Vector a, Vector b) {
	Vector v = { a.x-b.x, a.y-b.y, a.z-b.z };
	return v;
}

Vector Add(Vector a, Vector b) {
	Vector v = { a.x+b.x, a.y+b.y, a.z+b.z };
	return v;
}    

float Length(Vector a) {
	return (float)sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
}

Vector Normalize(Vector a) {
	float len = Length(a);
	Vector v = { a.x/len, a.y/len, a.z/len };
	return v;
}

Vector ScalarVecDiv(float t, Vector a) {
	Vector b = { a.x/t, a.y/t, a.z/t };
	return b;
}

Vector ScalarVecMul(float t, Vector a) {
	Vector b = { a.x*t, a.y*t, a.z*t };
	return b;
}

HomVector MatVecMul(Matrix a, HomVector b) {
	HomVector h;
	h.x = b.x*a.e[0][0] + b.y*a.e[0][1] + b.z*a.e[0][2] + b.w*a.e[0][3];
	h.y = b.x*a.e[1][0] + b.y*a.e[1][1] + b.z*a.e[1][2] + b.w*a.e[1][3];
	h.z = b.x*a.e[2][0] + b.y*a.e[2][1] + b.z*a.e[2][2] + b.w*a.e[2][3];
	h.w = b.x*a.e[3][0] + b.y*a.e[3][1] + b.z*a.e[3][2] + b.w*a.e[3][3];
	return h;
}


float VecVecMul(HomVector a, HomVector b) {
	float d;
	d = a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w;
	return d;
}

Vector Homogenize(HomVector h) {
	Vector a;
	if (h.w == 0.0) {
		fprintf(stderr, "Homogenize: w = 0\n");
		a.x = a.y = a.z = 9999999;
		return a;
	}
	a.x = h.x / h.w;
	a.y = h.y / h.w;
	a.z = h.z / h.w;
	return a;
}

Matrix MatMatMul(Matrix a, Matrix b) {
	Matrix c;
	int i, j, k;
	for (i = 0; i < 4; i++) {
		for (j = 0; j < 4; j++) {
			c.e[i][j] = 0.0;
			for (k = 0; k < 4; k++)
			c.e[i][j] += a.e[i][k] * b.e[k][j];
		}
	}
	return c;
}

void PrintMatrix(char *name, Matrix a) {
	int i, j;

	puts(name);
	for (i = 0; i < 4; i++) {
		for (j = 0; j < 4; j++) 
		printf("%6.5lf ", a.e[i][j]);
		printf("\n");
	}
}

void PrintVector(char *name, Vector a) {
	printf("%s: %6.5lf %6.5lf %6.5lf\n", name, a.x, a.y, a.z);
}

void PrintHomVector(char *name, HomVector a) {
	printf("%s: %6.5lf %6.5lf %6.5lf %6.5lf\n", name, a.x, a.y, a.z, a.w);
}

Vector Normal(Vector v[]) {
	Vector n = CrossProduct(Subtract(v[1], v[0]), Subtract(v[2], v[0]));
	return n;
}

Matrix Transpose(Matrix a) {
	int i,j;
	Matrix b;

	for (i=0; i<4; i++) {
		for (j=0; j<4; j++) {
			b.e[i][j]=a.e[j][i];
		}
	}
	return b;
}
