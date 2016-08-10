#ifndef ALGEBRAH
#define ALGEBRAH

typedef enum{ROT_X, ROT_Y, ROT_Z} angle;

typedef struct { float x, y, z; } Vector;
typedef struct { float x, y, z; } Pos;
typedef struct { float x, y, z; } Delta;
typedef struct { float x, y, z, w; } HomVector;
typedef struct matrix { float e[4][4]; } Matrix;

Vector Add(Vector a, Vector b);
Vector Subtract(Vector a, Vector b);
Vector Normal(Vector v[]);
Vector CrossProduct(Vector a, Vector b);
float DotProduct(Vector a, Vector b);
float Length(Vector a);
Vector Normalize(Vector a);
Vector ScalarVecMul(float t, Vector a);
Vector ScalarVecDiv(float t, Vector a);
HomVector MatVecMul(Matrix a, HomVector b);
Vector Homogenize(HomVector a);
Matrix MatMatMul(Matrix a, Matrix b);
void PrintMatrix(char *name, Matrix a);
void PrintVector(char *name, Vector a);
void PrintHomVector(char *name, HomVector a);
Matrix Scale(Vector v);
Matrix Translate(Vector v);
Matrix Rotate(float theta, angle a);
Matrix PerspectiveTrans(void);
Matrix Transpose(Matrix a);
float VecVecMul(HomVector a, HomVector b);

#define Deg2Rad(a) ((a)/180.0*3.141592)
#define randfun ((float)(rand()%200))/300.0

#endif
