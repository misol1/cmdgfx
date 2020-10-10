// Compilation:  gcc -O3 -ffast-math -c eextern.c & gcc -shared -o eextern.dll eextern.o & strip eextern.dll

#ifndef PI
#define PI  3.141592
#endif
#define PIHALF 1.570796
#define TAU    6.2831853
#define PI_SQ  9.869604

#include <math.h>
#include <windows.h>

typedef struct { float x, y; } vec2;
typedef struct { float x, y, z; } vec3;

// BhaskaraI sin approximation (including home-cooked fmod)
float bhSin(float x) {
	float neg = 1;
	if (x < 0) { x=-x; neg=-1; }
	int dv = x / TAU; x = x - dv * TAU; //= x=fmod(x, TAU);
	if (x > PI) { neg=-neg; x = PI - (TAU - x); }
	return (16*x*(PI-x))/(5*PI_SQ-4*x*(PI-x))*neg;
}

float bhCos(float x) {
	return bhSin(PIHALF - x);
}

// ~2.5x faster 
int GRY(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long long *outArray,  unsigned long long *sampleArray, int threadIndex)
{
	float C1=(float)v3/20, C2=(float)v4/8;

 	for (int y = yStart; y < yStart + h; y++)
	{
		float fxy=bhCos((float)y/34)*C2;
		for (int x = 0; x < w; x++)
		{
			float s1 = C1*bhSin((float)x/7) + fxy;
			*outArray++ = ((int)(bhSin(s1/10)+bhCos(s1/24)*127+127)<<16) | ((int)(bhCos(s1/4)*127+127)<<8); 
		}
	}
}

// ~8.5x faster (25x for 1920x1080 pixel font)
int twister(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long long *outArray,  unsigned long long *sampleArray, int threadIndex)
{
	float s0,s1,s2,s3,s4,s5,s6,s7, fw=w,fh=fullH;
	float A1=(float)v1;
	unsigned long long *sampl = &sampleArray[yStart * w];
	unsigned long long col;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		s1 = (float)y / fh - 0.5;
		s2 = s1 + A1/20 + sin(s1) * sin(A1/40)*PI;
		s3 = 0.35 * sin(s2);
		s4 = 0.35 * sin(s2+2.0943);
		s5 = 0.35 * sin(s2+4.1886);
		s6 = 0.35 * sin(s2+6.2829);
		
		for (int x = 0; x < w; x++)
		{
			col = 0;
			s0 = (float)x / fw - 0.5;
			s7 = (s0-s3) / (s4-s3);
			if (s7 >= 0 && s7 < 1) col = sampl[(int)(s7*fw)];
			s7 = (s0-s4) / (s5-s4);
			if (s7 >= 0 && s7 < 1 && s4 < s5) col = sampl[(int)(s7*fw)];
			s7 = (s0-s5) / (s6-s5);
			if (s7 >= 0 && s7 < 1 && s5 < s6) col = sampl[(int)(s7*fw)];
			*outArray++ = col;
		}
		
		sampl = sampl + w;
	}
}


// Org plasma loops 7 times, not 5
int multiPlasma(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long long *outArray,  unsigned long long *sampleArray, int threadIndex)
{
	float fw=w, fh=fullH;
	float A1=(float)v1;
	vec2 uv, r;
	
	float time=A1/20;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		float uvy = ((float)y / fh - 0.5) * 8.0;
		
		for (int x = 0; x < w; x++)
		{
			uv.x = ((float)x / fw - 0.5) * 8.0;
			uv.y = uvy;
			float i0=1.0;
			float i1=1.0;
			float i2=1.0;
			float i4=0.0;
			for(int s=0; s < 5; s++)
			{
				r.x=bhCos(uv.y*i0-i4+time/i1)/i2;
				r.y=bhSin(uv.x*i0-i4+time/i1)/i2;
				uv.x+=r.x-r.y*0.3;
				uv.y+=r.y+r.x*0.3;
				
				i0*=1.93;
				i1*=1.15;
				i2*=1.7;
				i4+=0.05+0.1*time*i1;
			}
			float r=bhSin(uv.x-time);
			float b=bhSin(uv.y+time);
			float g=bhSin((uv.x+uv.y+bhSin(time*0.5))*0.5);
			*outArray++ = ((int)(r*127+127)<<16)|((int)(g*127+127)<<8)|(int)(b*127+127);
		}
	}
}

// ??x faster (lots)
int julia(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long long *outArray,  unsigned long long *sampleArray, int threadIndex)
{
	float fw=w, fh=fullH;
	float C1=(float)v3;
	int maxIt=50, i;

	float s4 = ((C1/8+60)+(60-(w-238)/9))/10000;
	float s5 = (C1/8+60)/200;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			float s0 = ((float)x-(fw/2+20)+20)*s4;
			float s1 = ((float)y-fh/2)*s4;
			float s0sq, s1sq;
			
			for (i = 0; i < maxIt; i++) {
				s0sq=s0*s0;
				s1sq=s1*s1;
				s1=2*s0*s1+s5;
				s0=s0sq-s1sq-0.7;
				if (s0sq+s1sq > 2.5) break;
			}
			
			float v=(float)i/(float)maxIt;
			for (i=0; i<1; i++)
				v = v*(2-v);
			*outArray++ = ((int)(v*127)<<8)|(int)(v*255);
		}
	}
}
