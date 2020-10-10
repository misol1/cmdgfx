// Compilation:  gcc -O3 -ffast-math -c eextern.c & gcc -s -shared -o eextern.dll eextern.o

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


// 16 color Cmdgfx, not RGB. Does not produce start data. Only allows using color 1.
// At 1920x1080 1pixel screen, 8 threads: ~43x faster (3 fps->130 fps)

int gameOfLife(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state;
	unsigned char *py, *pym, *pyp;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;
				
			neighbours = py[xm] + py[xp] + pym[xm] + pym[x] + pym[xp] + pyp[xm] + pyp[x] + pyp[xp];
			
			state = py[x];
			if (state)
				state = (neighbours == 2 || neighbours == 3);
			else
				state = (neighbours == 3);
			*outArray++ = state;
		}
	}
}


int gameOfLife3col(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state;
	unsigned char *py, *pym, *pyp;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;
				
			neighbours = (py[xm] > 0) + (py[xp] > 0) + (pym[xm] > 0) + (pym[x] > 0) + (pym[xp] > 0) + (pyp[xm] > 0) + (pyp[x] > 0) + (pyp[xp] > 0);
			
			state = py[x];
			if (state)
				state = neighbours == 2? 2 : neighbours == 3? 3 : 0;
			else
				state = (neighbours == 3);
			*outArray++ = state;
		}
	}
}


int dayNight(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state;
	unsigned char *py, *pym, *pyp;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;
				
			neighbours = (py[xm] > 0) + (py[xp] > 0) + (pym[xm] > 0) + (pym[x] > 0) + (pym[xp] > 0) + (pyp[xm] > 0) + (pyp[x] > 0) + (pyp[xp] > 0);
			
			state = py[x];
			if (state)
				state = neighbours == 3? 3 : neighbours == 4? 4 : neighbours == 6? 6 : neighbours == 7? 7 : neighbours == 8? 8 : 0;
			else
				state = neighbours == 3? 3 : neighbours == 6? 6 : neighbours == 7? 7 : neighbours == 8? 8 : 0;
			*outArray++ = state;
		}
	}
}


int seeds(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state;
	unsigned char *py, *pym, *pyp;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;
				
			neighbours = py[xm] + py[xp] + pym[xm] + pym[x] + pym[xp] + pyp[xm] + pyp[x] + pyp[xp];
			
			state = py[x];
			if (state)
				state=0;
			else
				state = (neighbours == 2);
			*outArray++ = state;
		}
	}
}


int briansBrain(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state;
	unsigned char *py, *pym, *pyp;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;
				
			neighbours = (py[xm]==2) + (py[xp]==2) + (pym[xm]==2) + (pym[x]==2) + (pym[xp]==2) + (pyp[xm]==2) + (pyp[x]==2) + (pyp[xp]==2);
			
			state = py[x];
			if (state)
				state--;
			else
				state = (neighbours == 2) * 2;
			*outArray++ = state;
		}
	}
}

int cyclicCA(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state,ss;
	unsigned char *py, *pym, *pyp;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;

			state = py[x];
			ss = state + 1;
			
			neighbours = (py[xm]==ss) + (py[xp]==ss) + (pym[xm]==ss) + (pym[x]==ss) + (pym[xp]==ss) + (pyp[xm]==ss) + (pyp[x]==ss) + (pyp[xp]==ss);
			
			if (neighbours > 0) {
				if (ss == v1)
					state = 0;
				else
					state = ss;
			}
			*outArray++ = state;
		}
	}
}


int misolInkBlobs(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state;
	unsigned char *py, *pym, *pyp;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;
				
			neighbours = (py[xm] > 0) + (py[xp] > 0) + (pym[xm] > 0) + (pym[x] > 0) + (pym[xp] > 0) + (pyp[xm] > 0) + (pyp[x] > 0) + (pyp[xp] > 0);
			
			state = py[x];
			if (state)
				state = neighbours == 5? 5 : neighbours == 6? 6 : neighbours == 7? 7 : neighbours == 8? 8 : 0;
			else
				state = neighbours == 4? 4 : neighbours == 6? 6 : 0;
			*outArray++ = state;
		}
	}
}


int randMoore(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state, i;
	unsigned char *py, *pym, *pyp;

	int stayRules[10] = {0};
	int bornRules[10] = {0};
	int stayVal = 128, bornVal = 128;
	int slowDeath = v3;
	int liveCol = v4;

	for (i = 0; i < 8; i++) {
		stayRules[8 - i] = v1 & stayVal;
		stayVal = stayVal >> 1;
	}
	for (i = 0; i < 8; i++) {
		bornRules[8 - i] = v2 & bornVal;
		bornVal = bornVal >> 1;
	}
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;

			if (liveCol <= 1)
				neighbours = (py[xm] > 0) + (py[xp] > 0) + (pym[xm] > 0) + (pym[x] > 0) + (pym[xp] > 0) + (pyp[xm] > 0) + (pyp[x] > 0) + (pyp[xp] > 0);
			else
				neighbours = (py[xm] == liveCol) + (py[xp] == liveCol) + (pym[xm] == liveCol) + (pym[x] == liveCol) + (pym[xp]  == liveCol) + (pyp[xm]  == liveCol) + (pyp[x]  == liveCol) + (pyp[xp]  == liveCol);
			
			state = py[x];
			if (state) {
				state = slowDeath? state-1 : 0;
				if (stayRules[neighbours]) { state=neighbours; }  // for slowDeath, state=py[x] would actually be more "accurate" (but results are less interesting)
			} else {
				state = 0;
				if (bornRules[neighbours]) { state = liveCol <= 1? neighbours : liveCol; } // set state to 1 instead of neighbours to make 3-color GameOfLife look correct (flag?)
 			}
			*outArray++ = state;
		}
	}
}




int randMooreExtended(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned char *outArray,  unsigned char *sampleArray, int threadIndex)
{
	int xm,xp,xmm,xpp,ym,yp,ypp,ymm,neighbours,state, i;
	unsigned char *py, *pym, *pymm, *pyp, *pypp;

	int stayRules[32] = {0};
	int bornRules[32] = {0};
	int slowDeath = v3;
	int liveCol = v4;
	int neighbourHood = v5;
	
	int stayVal = 33554432; // 2^25
	int bornVal = 33554432;

	for (i = 0; i < 26; i++) {
		stayRules[26 - i] = (v1 & stayVal) > 0;
		stayVal = stayVal >> 1;
	}
	for (i = 0; i < 26; i++) {
		bornRules[26 - i] = (v2 & bornVal) > 0;
		bornVal = bornVal >> 1;
	}
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		ymm=y-2; if (ymm < 0) ymm=fullH + ymm;
		ypp=y+2; if (ypp >= fullH) ypp=ypp-fullH;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		pymm = &sampleArray[ymm * w];
		pypp = &sampleArray[ypp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;
			xmm=x-2; if (xmm < 0) xmm=w+xmm;
			xpp=x+2; if (xpp >= w) xpp=xpp-w;

			switch(neighbourHood) {
				// ..X..
				// .X.X.
				// X.*.X
				// .X.X.
				// ..X..
				case 0: default:
				if (liveCol <= 1)
					neighbours = (pymm[x] > 0) + (pypp[x] > 0) + (pym[xm] > 0) + (pym[xp] > 0) + (pyp[xm] > 0) + (pyp[xp] > 0) + (py[xpp] > 0) + (py[xmm] > 0);
				else
					neighbours = (pymm[x] == liveCol) + (pypp[x] == liveCol) + (pym[xm] == liveCol) + (pym[xp] == liveCol) + (pyp[xm] == liveCol) + (pyp[xp] == liveCol) + (py[xpp] == liveCol) + (py[xmm] == liveCol);
				break;
			
				// ..X..
				// .XXX.
				// XX*XX
				// .XXX.
				// ..X..
				case 1:
				if (liveCol <= 1)
					neighbours = (pymm[x] > 0) + (pypp[x] > 0) + (pym[xm] > 0) + (pym[xp] > 0) + (pyp[xm] > 0) + (pyp[xp] > 0) + (py[xpp] > 0) + (py[xmm] > 0) +
								 (pym[x] > 0) + (pyp[x] > 0) + (py[xm] > 0) + (py[xp] > 0);
				else
					neighbours = (pymm[x] == liveCol) + (pypp[x] == liveCol) + (pym[xm] == liveCol) + (pym[xp] == liveCol) + (pyp[xm] == liveCol) + (pyp[xp] == liveCol) + (py[xpp] == liveCol) + (py[xmm] == liveCol) + 
								 (pym[x] == liveCol) + (pyp[x]  == liveCol) + (py[xm]  == liveCol) + (py[xp]  == liveCol);
				break;
								 
				// .XXX.
				// X...X
				// X.*.X
				// X...X
				// .XXX.
				case 2:
				if (liveCol <= 1)
					neighbours = (pymm[x] > 0) + (pymm[xm] > 0) + (pymm[xp] > 0) + (pypp[x] > 0) + (pypp[xm] > 0) + (pypp[xp] > 0) + (py[xpp] > 0) + (py[xmm] > 0) +
								 (pym[xpp] > 0) + (pym[xmm] > 0) + (pyp[xmm] > 0) + (pyp[xpp] > 0);
				else
					neighbours = (pymm[x] == liveCol) + (pymm[xm] == liveCol) + (pymm[xp] == liveCol) + (pypp[x] == liveCol) + (pypp[xm] == liveCol) + (pypp[xp] == liveCol) + (py[xpp] == liveCol) + (py[xmm] == liveCol) +
								 (pym[xpp] == liveCol) + (pym[xmm] == liveCol) + (pyp[xmm] == liveCol) + (pyp[xpp] == liveCol);
				break;
				
				// .XXX.
				// XX.XX
				// X.*.X
				// XX.XX
				// .XXX.
				case 3:
				if (liveCol <= 1)
					neighbours = (pymm[x] > 0) + (pymm[xm] > 0) + (pymm[xp] > 0) + (pypp[x] > 0) + (pypp[xm] > 0) + (pypp[xp] > 0) + (py[xpp] > 0) + (py[xmm] > 0) +
								 (pym[xpp] > 0) + (pym[xmm] > 0) + (pyp[xmm] > 0) + (pyp[xpp] > 0) +
								 (pym[xp] > 0) + (pym[xm] > 0) + (pyp[xm] > 0) + (pyp[xp] > 0);
				else
					neighbours = (pymm[x] == liveCol) + (pymm[xm] == liveCol) + (pymm[xp] == liveCol) + (pypp[x] == liveCol) + (pypp[xm] == liveCol) + (pypp[xp] == liveCol) + (py[xpp] == liveCol) + (py[xmm] == liveCol) +
								 (pym[xpp] == liveCol) + (pym[xmm] == liveCol) + (pyp[xmm] == liveCol) + (pyp[xpp] == liveCol) +
								 (pym[xp] == liveCol) + (pym[xm] == liveCol) + (pyp[xm] == liveCol) + (pyp[xp] == liveCol);
				break;

				// .XXX.
				// XXXXX
				// XX*XX
				// XXXXX
				// .XXX.
				case 4:
				if (liveCol <= 1)
					neighbours = (pymm[x] > 0) + (pymm[xm] > 0) + (pymm[xp] > 0) + (pypp[x] > 0) + (pypp[xm] > 0) + (pypp[xp] > 0) + (py[xpp] > 0) + (py[xmm] > 0) +
								 (pym[xpp] > 0) + (pym[xmm] > 0) + (pyp[xmm] > 0) + (pyp[xpp] > 0) +
								 (pym[xp] > 0) + (pym[xm] > 0) + (pyp[xm] > 0) + (pyp[xp] > 0) +
								 (pym[x] > 0) + (pyp[x] > 0) + (py[xm] > 0) + (py[xp] > 0);
				else
					neighbours = (pymm[x] == liveCol) + (pymm[xm] == liveCol) + (pymm[xp] == liveCol) + (pypp[x] == liveCol) + (pypp[xm] == liveCol) + (pypp[xp] == liveCol) + (py[xpp] == liveCol) + (py[xmm] == liveCol) +
								 (pym[xpp] == liveCol) + (pym[xmm] == liveCol) + (pyp[xmm] == liveCol) + (pyp[xpp] == liveCol) +
								 (pym[xp] == liveCol) + (pym[xm] == liveCol) + (pyp[xm] == liveCol) + (pyp[xp] == liveCol) +
								 (pym[x] == liveCol) + (pyp[x] == liveCol) + (py[xm] == liveCol) + (py[xp] == liveCol);
				break;

				// XXXXX
				// XXXXX
				// XX*XX
				// XXXXX
				// XXXXX
				case 5:
				if (liveCol <= 1)
					neighbours = (pymm[x] > 0) + (pymm[xm] > 0) + (pymm[xp] > 0) + (pypp[x] > 0) + (pypp[xm] > 0) + (pypp[xp] > 0) + (py[xpp] > 0) + (py[xmm] > 0) +
								 (pym[xpp] > 0) + (pym[xmm] > 0) + (pyp[xmm] > 0) + (pyp[xpp] > 0) +
								 (pym[xp] > 0) + (pym[xm] > 0) + (pyp[xm] > 0) + (pyp[xp] > 0) +
								 (pym[x] > 0) + (pyp[x] > 0) + (py[xm] > 0) + (py[xp] > 0) +
								 (pymm[xmm] > 0) + (pymm[xpp] > 0) + (pypp[xmm] > 0) + (pypp[xpp] > 0);
				else
					neighbours = (pymm[x] == liveCol) + (pymm[xm] == liveCol) + (pymm[xp] == liveCol) + (pypp[x] == liveCol) + (pypp[xm] == liveCol) + (pypp[xp] == liveCol) + (py[xpp] == liveCol) + (py[xmm] == liveCol) +
								 (pym[xpp] == liveCol) + (pym[xmm] == liveCol) + (pyp[xmm] == liveCol) + (pyp[xpp] == liveCol) +
								 (pym[xp] == liveCol) + (pym[xm] == liveCol) + (pyp[xm] == liveCol) + (pyp[xp] == liveCol) +
								 (pym[x] == liveCol) + (pyp[x] == liveCol) + (py[xm] == liveCol) + (py[xp] == liveCol) +
								 (pymm[xmm] == liveCol) + (pymm[xpp] == liveCol) + (pypp[xmm] == liveCol) + (pypp[xpp] == liveCol);
				break;


				// XXXXX
				// X...X
				// X.*.X
				// X...X
				// XXXXX
				case 6:
				if (liveCol <= 1)
					neighbours = (pymm[xmm] > 0) + (pymm[xm] > 0) + (pymm[x] > 0) + (pymm[xp] > 0) + (pymm[xpp] > 0) + 
								 (pym[xmm] > 0) + (pym[xpp] > 0) + 
								 (py[xmm] > 0) + (py[xpp] > 0) + 
								 (pyp[xmm] > 0) + (pyp[xpp] > 0) + 
								 (pypp[xmm] > 0) + (pypp[xm] > 0) + (pypp[x] > 0) + (pypp[xp] > 0) + (pypp[xpp] > 0);
				else
					neighbours = (pymm[xmm] == liveCol) + (pymm[xm] == liveCol) + (pymm[x] == liveCol) + (pymm[xp] == liveCol) + (pymm[xpp] == liveCol) + 
								 (pym[xmm] == liveCol) + (pym[xpp] == liveCol) + 
								 (py[xmm] == liveCol) + (py[xpp] == liveCol) + 
								 (pyp[xmm] == liveCol) + (pyp[xpp] == liveCol) + 
								 (pypp[xmm] == liveCol) + (pypp[xm] == liveCol) + (pypp[x] == liveCol) + (pypp[xp] == liveCol) + (pypp[xpp] == liveCol);
				break;
				
				// XX.XX
				// X...X
				// ..*..
				// X...X
				// XX.XX
				case 7:
				if (liveCol <= 1)
					neighbours = (pymm[xmm] > 0) + (pymm[xm] > 0) + (pymm[xp] > 0) + (pymm[xpp] > 0) + 
								 (pym[xmm] > 0) + (pym[xpp] > 0) + 
								 (pyp[xmm] > 0) + (pyp[xpp] > 0) + 
								 (pypp[xmm] > 0) + (pypp[xm] > 0) + (pypp[xp] > 0) + (pypp[xpp] > 0);
				else
					neighbours = (pymm[xmm] == liveCol) + (pymm[xm] == liveCol) + (pymm[xp] == liveCol) + (pymm[xpp] == liveCol) + 
								 (pym[xmm] == liveCol) + (pym[xpp] == liveCol) + 
								 (pyp[xmm] == liveCol) + (pyp[xpp] == liveCol) + 
								 (pypp[xmm] == liveCol) + (pypp[xm] == liveCol) + (pypp[xp] == liveCol) + (pypp[xpp] == liveCol);
				break;
				
				
				// XX...
				// XX...
				// XX*..
				// XX...
				// XX...
				case 8:
				if (liveCol <= 1)
					neighbours = (pymm[xmm] > 0) + (pymm[xm] > 0) + 
								(pym[xmm] > 0) + (pym[xm] > 0) + 
								(py[xmm] > 0) + (py[xm] > 0) + 
								(pyp[xmm] > 0) + (pyp[xm] > 0) + 
								(pypp[xmm] > 0) + (pypp[xm] > 0);
				else
					neighbours = (pymm[xmm] == liveCol) + (pymm[xm] == liveCol) + 
								(pym[xmm] == liveCol) + (pym[xm] == liveCol) + 
								(py[xmm] == liveCol) + (py[xm] == liveCol) + 
								(pyp[xmm] == liveCol) + (pyp[xm] == liveCol) + 
								(pypp[xmm] == liveCol) + (pypp[xm] == liveCol);
				break;
				
				// XX.XX
				// .....
				// X.*.X
				// .....
				// XX.XX
				case 9:
				if (liveCol <= 1)
					neighbours = (pymm[xmm] > 0) + (pymm[xm] > 0) + (pymm[xp] > 0) + (pymm[xpp] > 0) + (pypp[xmm] > 0) + (pypp[xm] > 0) + (pypp[xp] > 0) + (pypp[xpp] > 0) + (py[xpp] > 0) +  + (py[xmm] > 0);
				else
					neighbours = (pymm[xmm] == liveCol) + (pymm[xm] == liveCol) + (pymm[xp] == liveCol) + (pymm[xpp] == liveCol) + (pypp[xmm] == liveCol) + (pypp[xm] == liveCol) + (pypp[xp] == liveCol) + (pypp[xpp] == liveCol) + (py[xpp] == liveCol) +  + (py[xmm] == liveCol);
				break;
				
				// XXXXX
				// ..X..
				// ..*..
				// ..X..
				// XXXXX
				case 10:
				if (liveCol <= 1)
					neighbours = (pymm[xmm] > 0) + (pymm[xm] > 0) + (pymm[x] > 0) + (pymm[xp] > 0) + (pymm[xpp] > 0) + 
								 (pym[x] > 0) + 
								 (pyp[x] > 0) + 
								 (pypp[xmm] > 0) + (pypp[xm] > 0) + (pypp[x] > 0) + (pypp[xp] > 0) + (pypp[xpp] > 0);
				else
					neighbours = (pymm[xmm] == liveCol) + (pymm[xm] == liveCol) + (pymm[x] == liveCol) + (pymm[xp] == liveCol) + (pymm[xpp] == liveCol) + 
								 (pym[x] == liveCol) + 
								 (pyp[x] == liveCol) + 
								 (pypp[xmm] == liveCol) + (pypp[xm] == liveCol) + (pypp[x] == liveCol) + (pypp[xp] == liveCol) + (pypp[xpp] == liveCol);
				break;
				
				// .X.X.
				// .X.X.
				// .X*X.
				// .X.X.
				// .X.X.
				case 11:
				if (liveCol <= 1)
					neighbours = (pymm[xm] > 0) + (pymm[xp] > 0) + 
								 (pym[xm] > 0) + (pym[xp] > 0) + 
								 (py[xmm] > 0) + (py[xpp] > 0) + 
								 (pyp[xm] > 0) + (pyp[xp] > 0) + 
								 (pypp[xm] > 0) + (pypp[xp] > 0);
				else
					neighbours = (pymm[xm] == liveCol) + (pymm[xp] == liveCol) + 
								 (pym[xm] == liveCol) + (pym[xp] == liveCol) + 
								 (py[xmm] == liveCol) + (py[xpp] == liveCol) + 
								 (pyp[xm] == liveCol) + (pyp[xp] == liveCol) + 
								 (pypp[xm] == liveCol) + (pypp[xp] == liveCol);
				break;

				// ...XX
				// ...XX
				// ..*..
				// XXX..
				// XXX..
				case 12:
				if (liveCol <= 1)
					neighbours = (pymm[xpp] > 0) + (pymm[xp] > 0) +
								 (pym[xpp] > 0) + (pym[xp] > 0) +
								 (pyp[xmm] > 0) + (pyp[xm] > 0) + (pyp[x] > 0) +
								 (pypp[xmm] > 0) + (pypp[xm] > 0) + (pypp[x] > 0);
				else
					neighbours = (pymm[xpp] == liveCol) + (pymm[xp] == liveCol) +
								 (pym[xpp] == liveCol) + (pym[xp] == liveCol) +
								 (pyp[xmm] == liveCol) + (pyp[xm] == liveCol) + (pyp[x] == liveCol) +
								 (pypp[xmm] == liveCol) + (pypp[xm] == liveCol) + (pypp[x] == liveCol);
				break;

				// XXXXX
				// ....X
				// XX*.X
				// X...X
				// XXXXX
				case 13:
				if (liveCol <= 1)
					neighbours = (pymm[xmm] > 0) + (pymm[xm] > 0) + (pymm[x] > 0) + (pymm[xp] > 0) + (pymm[xpp] > 0) + 
								 (pym[xpp] > 0) + 
								 (pyp[xpp] > 0) + (pyp[xmm] > 0) +
								 (py[xmm] > 0) + (py[xm] > 0) + (py[xpp] > 0) +
								 (pypp[xmm] > 0) + (pypp[xm] > 0) + (pypp[x] > 0) + (pypp[xp] > 0) + (pypp[xpp] > 0);
				else
					neighbours = (pymm[xmm] == liveCol) + (pymm[xm] == liveCol) + (pymm[x] == liveCol) + (pymm[xp] == liveCol) + (pymm[xpp] == liveCol) + 
								 (pym[xpp] == liveCol) + 
								 (pyp[xpp] == liveCol) + (pyp[xmm] == liveCol) +
								 (py[xmm] == liveCol) + (py[xm] == liveCol) + (py[xpp] == liveCol) +
								 (pypp[xmm] == liveCol) + (pypp[xm] == liveCol) + (pypp[x] == liveCol) + (pypp[xp] == liveCol) + (pypp[xpp] == liveCol);
				break;

				
			}

			
			state = py[x];
			if (state) {
				state = slowDeath? state-1 : 0;
				if (stayRules[neighbours]) { state=neighbours; }  // for slowDeath, state=py[x] would actually be more "accurate" (but results are less interesting)
			} else {
				state = 0;
				if (bornRules[neighbours]) { state = liveCol <= 1? neighbours : liveCol; }
			}
			*outArray++ = state;
		}
	}
}


/*

// The 32 bit 2-step process. More than 2x slower

int randMoore32(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long *outArray,  unsigned long *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state, i;
	unsigned long *py, *pym, *pyp;

	int stayRules[10] = {0};
	int bornRules[10] = {0};
	int stayVal = 128, bornVal = 128;
	int slowDeath = v3;
	int liveCol = v4;

	for (i = 0; i < 8; i++) {
		stayRules[8 - i] = v1 & stayVal;
		stayVal = stayVal >> 1;
	}
	for (i = 0; i < 8; i++) {
		bornRules[8 - i] = v2 & bornVal;
		bornVal = bornVal >> 1;
	}
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;

			if (liveCol <= 1)
				neighbours = (py[xm] > 0) + (py[xp] > 0) + (pym[xm] > 0) + (pym[x] > 0) + (pym[xp] > 0) + (pyp[xm] > 0) + (pyp[x] > 0) + (pyp[xp] > 0);
			else
				neighbours = (py[xm] == liveCol) + (py[xp] == liveCol) + (pym[xm] == liveCol) + (pym[x] == liveCol) + (pym[xp]  == liveCol) + (pyp[xm]  == liveCol) + (pyp[x]  == liveCol) + (pyp[xp]  == liveCol);
			
			state = py[x];
			if (state) {
				state = slowDeath? state-1 : 0;
				if (stayRules[neighbours]) { state=neighbours; }  // for slowDeath, state=py[x] would actually be more "accurate" (but results are less interesting)
			} else {
				state = 0;
				if (bornRules[neighbours]) { state = liveCol <= 1? neighbours : liveCol; }
			}
			*outArray++ = state;
		}
	}
}


int randMoore32conv(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long *outArray,  unsigned long *sampleArray, int threadIndex)
{
	int state,state2, half=w/2;
	unsigned long *py,*pyh;
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		py  = &sampleArray[y * w];
		pyh  = &sampleArray[y * w - half];
		
		outArray = outArray + half;
		for (int x = half; x < w; x++)
		{
			state = pyh[x];
			state2 = py[x];
			
			if (state) {
				int r=(state2>>16)&0xff;
				int g=(state2>>8)&0xff;
				int b=(state2)&0xff;
//				if (r < 256-6) r+=6;
//				if (g < 256-6) g+=6;
//				if (b < 256-6) b+=6;
				if (r < 256-6 && (state & 1)) r+=6;
				if (g < 256-6 && (state & 2)) g+=6;
				if (b < 256-6 && (state & 4)) b+=6;
//				if (r < 256-6 && (state & 1)) r+=6;
//				if (g < 256-16 && (state & 4)) g+=16;
//				if (b < 256-6 && (state & 2)) b+=6;
				*outArray = (r<<16)|(g<<8)|b;
			} else {
				int r=(state2>>16)&0xff;
				int g=(state2>>8)&0xff;
				int b=(state2)&0xff;
				if (r >= 2) r-=2;
				if (g >= 2) g-=2;
				if (b >= 2) b-=2;
				*outArray = (r<<16)|(g<<8)|b;
			}

			outArray++;
		}
	}
}

*/


int randMoore32compact(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long *outArray,  unsigned long *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state,state2, i;
	unsigned long *py, *pym, *pyp;
	int r,g,b;
	int rMul, gMul, bMul;
	int rNeg, gNeg, bNeg;
	int rAnd, gAnd, bAnd;

	int stayRules[10] = {0};
	int bornRules[10] = {0};
	int stayVal = 128, bornVal = 128;
	int slowDeath = v2 & 1;
	int liveCol = v2 >> 1;
	int mulPatt = v5 & 7;
	int stayPatt = 0, stayPattVal = 1;
	int mulBase;
	int topClamp, bottomClamp, bottomClampVal=0, topClampVal=255;

	for (i = 0; i < 8; i++) {
		stayRules[8 - i] = v1 & stayVal;
		stayVal = stayVal >> 1;
	}
	v1 >>= 8;
	for (i = 0; i < 8; i++) {
		bornRules[8 - i] = v1 & bornVal;
		bornVal = bornVal >> 1;
	}
	
	rMul = v3 & 127;
	if (v3 & 128) rMul = -rMul;
	v3 >>= 8;
	gMul = v3 & 127;
	if (v3 & 128) gMul = -gMul;
	v3 >>= 8;
	bMul = v3 & 127;
	if (v3 & 128) bMul = -bMul;

	rNeg = v4 & 127;
	if (v4 & 128) rNeg = -rNeg;
	v4 >>= 8;
	gNeg = v4 & 127;
	if (v4 & 128) gNeg = -gNeg;
	v4 >>= 8;
	bNeg = v4 & 127;
	if (v4 & 128) bNeg = -bNeg;

	v5 >>= 3;
	rAnd = v5 & 7;
	v5 >>= 3;
	gAnd = v5 & 7;
	v5 >>= 3;
	bAnd = v5 & 7;
	
	v5 >>= 3;
	topClamp = v5 & 1;
	if (!topClamp) topClampVal=0;
	v5 >>= 1;
	bottomClamp = v5 & 1;
	if (!bottomClamp) bottomClampVal=255;
	v5 >>= 1;
	stayPatt = v5 & 7;
	v5 >>= 3;
	stayPattVal = v5 & 255;
	
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;

			if (liveCol <= 1)
				neighbours = ((py[xm]&7) > 0) + ((py[xp]&7) > 0) + ((pym[xm]&7) > 0) + ((pym[x]&7) > 0) + ((pym[xp]&7) > 0) + ((pyp[xm]&7) > 0) + ((pyp[x]&7) > 0) + ((pyp[xp]&7) > 0);
			else
				neighbours = ((py[xm]&7) == liveCol) + ((py[xp]&7) == liveCol) + ((pym[xm]&7) == liveCol) + ((pym[x]&7) == liveCol) + ((pym[xp]&7)  == liveCol) + ((pyp[xm]&7)  == liveCol) + ((pyp[x]&7)  == liveCol) + ((pyp[xp]&7)  == liveCol);
			
			state2 = py[x];
			state = state2 & 7;
			if (state) {
				state = slowDeath? state-1 : 0;
				if (stayRules[neighbours]) { state=neighbours; if(state>7)state=7; }  // for slowDeath, state=py[x] would actually be more "accurate" (but results are less interesting)
			} else {
				state = 0;
				if (bornRules[neighbours]) { state = liveCol <= 1? neighbours : liveCol; if(state>7)state=7; }
			}
			

			r=(state2>>16)&0xff;
			g=(state2>>8)&0xff;
			b=(state2)&0xff;
			
			if (state) {
				mulBase = neighbours;
				if (mulPatt == 1) mulBase = state;
				if (mulPatt == 2) mulBase = 1;
				if (mulPatt == 3) mulBase ^= state;
				if (state & rAnd) r+=mulBase*rMul;
				if (state & gAnd) g+=mulBase*gMul;
				if (state & bAnd) b+=mulBase*bMul;
				
				if (stayPatt == 5 || stayPatt == 6) b=g=r;	
	
				/*if (r < 256-7 && (state == 1)) r+=7;
				if (g < 256-6 && (state == 4)) g+=6;
				if (b < 256-11 && (state == 2)) b+=11;
				if (b >= 1 && (state == 3)) b-=1;
				if (g >= 2 && (state == 5)) g-=2;
				if (r < 256-4 && (state == 6)) r+=4;
				if (g < 256-8 && (state == 7)) g+=8;*/
			} else {
				switch(stayPatt) {
					case 0: default: 
					r-=rNeg;
					g-=gNeg;
					b-=bNeg;
					break;

					case 1:
					if (r>=stayPattVal) r-=rNeg;
					if (r>=stayPattVal) g-=gNeg;
					if (r>=stayPattVal) b-=bNeg;
					break;
					
					case 2:
					if (b>=stayPattVal) r-=rNeg;
					if (b>=stayPattVal) g-=gNeg;
					if (b>=stayPattVal) b-=bNeg;
					break;

					case 3:
					if (g>=stayPattVal) r-=rNeg;
					if (g>=stayPattVal) g-=gNeg;
					if (g>=stayPattVal) b-=bNeg;
					break;
					
					case 4:
					if (b>=stayPattVal) r-=rNeg;
					if (b>=stayPattVal) g-=gNeg;
					if (r>=stayPattVal) b-=bNeg;
					break;

					case 5: 
					r-=rNeg;
					b=g=r;
					break;
				}
			}

			if (r>255) r=topClampVal;
			if (g>255) g=topClampVal;
			if (b>255) b=topClampVal;
			
			if (r<0) r=bottomClampVal;
			if (g<0) g=bottomClampVal;
			if (b<0) b=bottomClampVal;
			
			*outArray++ = (r<<16)|(g<<8)|(b&0xfffff8)|state;
		}
	}
}


#define SH 24

int randMoore32compact_32bit(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long *outArray,  unsigned long *sampleArray, int threadIndex)
{
	int xm,xp,ym,yp,neighbours,state,state2, i;
	unsigned long *py, *pym, *pyp;
	int r,g,b;
	int rMul, gMul, bMul;
	int rNeg, gNeg, bNeg;
	int rAnd, gAnd, bAnd;

	int stayRules[10] = {0};
	int bornRules[10] = {0};
	int stayVal = 128, bornVal = 128;
	int slowDeath = v2 & 1;
	int liveCol = v2 >> 1;
	int mulPatt = v5 & 7;
	int stayPatt = 0, stayPattVal = 1;
	int mulBase;
	int topClamp, bottomClamp, bottomClampVal=0, topClampVal=255;

	for (i = 0; i < 8; i++) {
		stayRules[8 - i] = v1 & stayVal;
		stayVal = stayVal >> 1;
	}
	v1 >>= 8;
	for (i = 0; i < 8; i++) {
		bornRules[8 - i] = v1 & bornVal;
		bornVal = bornVal >> 1;
	}
	
	rMul = v3 & 127;
	if (v3 & 128) rMul = -rMul;
	v3 >>= 8;
	gMul = v3 & 127;
	if (v3 & 128) gMul = -gMul;
	v3 >>= 8;
	bMul = v3 & 127;
	if (v3 & 128) bMul = -bMul;

	rNeg = v4 & 127;
	if (v4 & 128) rNeg = -rNeg;
	v4 >>= 8;
	gNeg = v4 & 127;
	if (v4 & 128) gNeg = -gNeg;
	v4 >>= 8;
	bNeg = v4 & 127;
	if (v4 & 128) bNeg = -bNeg;

	v5 >>= 3;
	rAnd = v5 & 7;
	v5 >>= 3;
	gAnd = v5 & 7;
	v5 >>= 3;
	bAnd = v5 & 7;
	
	v5 >>= 3;
	topClamp = v5 & 1;
	if (!topClamp) topClampVal=0;
	v5 >>= 1;
	bottomClamp = v5 & 1;
	if (!bottomClamp) bottomClampVal=255;
	v5 >>= 1;
	stayPatt = v5 & 7;
	v5 >>= 3;
	stayPattVal = v5 & 255;
	
	
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;

			if (liveCol <= 1)
				neighbours = ((py[xm]>>SH) > 0) + ((py[xp]>>SH) > 0) + ((pym[xm]>>SH) > 0) + ((pym[x]>>SH) > 0) + ((pym[xp]>>SH) > 0) + ((pyp[xm]>>SH) > 0) + ((pyp[x]>>SH) > 0) + ((pyp[xp]>>SH) > 0);
			else
				neighbours = ((py[xm]>>SH) == liveCol) + ((py[xp]>>SH) == liveCol) + ((pym[xm]>>SH) == liveCol) + ((pym[x]>>SH) == liveCol) + ((pym[xp]>>SH)  == liveCol) + ((pyp[xm]>>SH)  == liveCol) + ((pyp[x]>>SH)  == liveCol) + ((pyp[xp]>>SH)  == liveCol);
			
			state2 = py[x];
			state = state2 >> SH;
			if (state) {
				state = slowDeath? state-1 : 0;
				if (stayRules[neighbours]) { state=neighbours; /*if(state>7)state=7;*/ }  // for slowDeath, state=py[x] would actually be more "accurate" (but results are less interesting)
			} else {
				state = 0;
				if (bornRules[neighbours]) { state = liveCol <= 1? neighbours : liveCol; /*if(state>7)state=7;*/ }
			}
			

			r=(state2>>16)&0xff;
			g=(state2>>8)&0xff;
			b=(state2)&0xff;
			
			if (state) {
				mulBase = neighbours;
				if (mulPatt == 1) mulBase = state;
				if (mulPatt == 2) mulBase = 1;
				if (mulPatt == 3) mulBase ^= state;
				if (state & rAnd) r+=mulBase*rMul;
				if (state & gAnd) g+=mulBase*gMul;
				if (state & bAnd) b+=mulBase*bMul;
				
				if (stayPatt == 5 || stayPatt == 6) b=g=r;	
			} else {
				switch(stayPatt) {
					case 0: default: 
					r-=rNeg;
					g-=gNeg;
					b-=bNeg;
					break;

					case 1:
					if (r>=stayPattVal) r-=rNeg;
					if (r>=stayPattVal) g-=gNeg;
					if (r>=stayPattVal) b-=bNeg;
					break;
					
					case 2:
					if (b>=stayPattVal) r-=rNeg;
					if (b>=stayPattVal) g-=gNeg;
					if (b>=stayPattVal) b-=bNeg;
					break;

					case 3:
					if (g>=stayPattVal) r-=rNeg;
					if (g>=stayPattVal) g-=gNeg;
					if (g>=stayPattVal) b-=bNeg;
					break;
					
					case 4:
					if (b>=stayPattVal) r-=rNeg;
					if (b>=stayPattVal) g-=gNeg;
					if (r>=stayPattVal) b-=bNeg;
					break;

					case 5: 
					r-=rNeg;
					b=g=r;
					break;
				}
				
			}

			if (r>255) r=topClampVal;
			if (g>255) g=topClampVal;
			if (b>255) b=topClampVal;
			
			if (r<0) r=bottomClampVal;
			if (g<0) g=bottomClampVal;
			if (b<0) b=bottomClampVal;
			
			*outArray++ = (r<<16)|(g<<8)|(state<<SH)|b;
		}
	}
}




int randMooreExtended32compact(int w, int h, int yStart, int fullH, DWORD tickCount, int v1, int v2, int v3, int v4, int v5,  unsigned long *outArray,  unsigned long *sampleArray, int threadIndex)
{
	int xm,xp,xmm,xpp,ym,yp,ypp,ymm,neighbours,state,state2, i;
	unsigned long *py, *pym, *pymm, *pyp, *pypp;
	int r,g,b;
	int rMul, gMul, bMul;
	int rNeg, gNeg, bNeg;
	int rAnd, gAnd, bAnd;

	int stayRules[32] = {0};
	int bornRules[32] = {0};
	int mulPatt = v5 & 7;
	int stayPatt = 0, stayPattVal = 1;
	int mulBase;
	int topClamp, bottomClamp, bottomClampVal=0, topClampVal=255;

	int stayVal = 33554432; // 2^25
	int bornVal = 33554432;

	// moved in packed bits
	int slowDeath;
	int liveCol;
	int neighbourHood;


	for (i = 0; i < 26; i++) {
		stayRules[26 - i] = (v1 & stayVal) > 0;
		stayVal = stayVal >> 1;
	}
	for (i = 0; i < 26; i++) {
		bornRules[26 - i] = (v2 & bornVal) > 0;
		bornVal = bornVal >> 1;
	}
	
	rMul = v3 & 127;
	if (v3 & 128) rMul = -rMul;
	v3 >>= 8;
	gMul = v3 & 127;
	if (v3 & 128) gMul = -gMul;
	v3 >>= 8;
	bMul = v3 & 127;
	if (v3 & 128) bMul = -bMul;
	v3 >>= 8;
	slowDeath = v3 & 1;
	v3 >>= 1;
	neighbourHood = v3 & 31;

	rNeg = v4 & 127;
	if (v4 & 128) rNeg = -rNeg;
	v4 >>= 8;
	gNeg = v4 & 127;
	if (v4 & 128) gNeg = -gNeg;
	v4 >>= 8;
	bNeg = v4 & 127;
	if (v4 & 128) bNeg = -bNeg;
	v4 >>= 8;
	liveCol = v4 & 127;

	v5 >>= 3;
	rAnd = v5 & 7;
	v5 >>= 3;
	gAnd = v5 & 7;
	v5 >>= 3;
	bAnd = v5 & 7;
	
	v5 >>= 3;
	topClamp = v5 & 1;
	if (!topClamp) topClampVal=0;
	v5 >>= 1;
	bottomClamp = v5 & 1;
	if (!bottomClamp) bottomClampVal=255;
	v5 >>= 1;
	stayPatt = v5 & 7;
	v5 >>= 3;
	stayPattVal = v5 & 255;
	
	
		
 	for (int y = yStart; y < yStart + h; y++)
	{
		ym=y-1; if (ym < 0) ym=fullH-1;
		yp=y+1; if (yp >= fullH) yp=0;
		ymm=y-2; if (ymm < 0) ymm=fullH + ymm;
		ypp=y+2; if (ypp >= fullH) ypp=ypp-fullH;
		
		py  = &sampleArray[y * w];
		pym = &sampleArray[ym * w];
		pyp = &sampleArray[yp * w];
		pymm = &sampleArray[ymm * w];
		pypp = &sampleArray[ypp * w];
		
		for (int x = 0; x < w; x++)
		{
			xm=x-1; if (xm < 0) xm=w-1;
			xp=x+1; if (xp >= w) xp=0;
			xmm=x-2; if (xmm < 0) xmm=w+xmm;
			xpp=x+2; if (xpp >= w) xpp=xpp-w;

			switch(neighbourHood) {
				// ..X..
				// .X.X.
				// X.*.X
				// .X.X.
				// ..X..
				case 0: default:
				if (liveCol <= 1)
					neighbours = ((pymm[x]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pym[xm]>>SH) > 0) + ((pym[xp]>>SH) > 0) + ((pyp[xm]>>SH) > 0) + ((pyp[xp]>>SH) > 0) + ((py[xpp]>>SH) > 0) + ((py[xmm]>>SH) > 0);
				else
					neighbours = ((pymm[x]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pym[xm]>>SH) == liveCol) + ((pym[xp]>>SH) == liveCol) + ((pyp[xm]>>SH) == liveCol) + ((pyp[xp]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) + ((py[xmm]>>SH) == liveCol);
				break;
			
				// ..X..
				// .XXX.
				// XX*XX
				// .XXX.
				// ..X..
				case 1:
				if (liveCol <= 1)
					neighbours = ((pymm[x]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pym[xm]>>SH) > 0) + ((pym[xp]>>SH) > 0) + ((pyp[xm]>>SH) > 0) + ((pyp[xp]>>SH) > 0) + ((py[xpp]>>SH) > 0) + ((py[xmm]>>SH) > 0) +
								 ((pym[x]>>SH) > 0) + ((pyp[x]>>SH) > 0) + ((py[xm]>>SH) > 0) + ((py[xp]>>SH) > 0);
				else
					neighbours = ((pymm[x]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pym[xm]>>SH) == liveCol) + ((pym[xp]>>SH) == liveCol) + ((pyp[xm]>>SH) == liveCol) + ((pyp[xp]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) + ((py[xmm]>>SH) == liveCol) + 
								 ((pym[x]>>SH) == liveCol) + (pyp[x]  == liveCol) + (py[xm]  == liveCol) + (py[xp]  == liveCol);
				break;
								 
				// .XXX.
				// X...X
				// X.*.X
				// X...X
				// .XXX.
				case 2:
				if (liveCol <= 1)
					neighbours = ((pymm[x]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((py[xpp]>>SH) > 0) + ((py[xmm]>>SH) > 0) +
								 ((pym[xpp]>>SH) > 0) + ((pym[xmm]>>SH) > 0) + ((pyp[xmm]>>SH) > 0) + ((pyp[xpp]>>SH) > 0);
				else
					neighbours = ((pymm[x]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) + ((py[xmm]>>SH) == liveCol) +
								 ((pym[xpp]>>SH) == liveCol) + ((pym[xmm]>>SH) == liveCol) + ((pyp[xmm]>>SH) == liveCol) + ((pyp[xpp]>>SH) == liveCol);
				break;
				
				// .XXX.
				// XX.XX
				// X.*.X
				// XX.XX
				// .XXX.
				case 3:
				if (liveCol <= 1)
					neighbours = ((pymm[x]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((py[xpp]>>SH) > 0) + ((py[xmm]>>SH) > 0) +
								 ((pym[xpp]>>SH) > 0) + ((pym[xmm]>>SH) > 0) + ((pyp[xmm]>>SH) > 0) + ((pyp[xpp]>>SH) > 0) +
								 ((pym[xp]>>SH) > 0) + ((pym[xm]>>SH) > 0) + ((pyp[xm]>>SH) > 0) + ((pyp[xp]>>SH) > 0);
				else
					neighbours = ((pymm[x]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) + ((py[xmm]>>SH) == liveCol) +
								 ((pym[xpp]>>SH) == liveCol) + ((pym[xmm]>>SH) == liveCol) + ((pyp[xmm]>>SH) == liveCol) + ((pyp[xpp]>>SH) == liveCol) +
								 ((pym[xp]>>SH) == liveCol) + ((pym[xm]>>SH) == liveCol) + ((pyp[xm]>>SH) == liveCol) + ((pyp[xp]>>SH) == liveCol);
				break;

				// .XXX.
				// XXXXX
				// XX*XX
				// XXXXX
				// .XXX.
				case 4:
				if (liveCol <= 1)
					neighbours = ((pymm[x]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((py[xpp]>>SH) > 0) + ((py[xmm]>>SH) > 0) +
								 ((pym[xpp]>>SH) > 0) + ((pym[xmm]>>SH) > 0) + ((pyp[xmm]>>SH) > 0) + ((pyp[xpp]>>SH) > 0) +
								 ((pym[xp]>>SH) > 0) + ((pym[xm]>>SH) > 0) + ((pyp[xm]>>SH) > 0) + ((pyp[xp]>>SH) > 0) +
								 ((pym[x]>>SH) > 0) + ((pyp[x]>>SH) > 0) + ((py[xm]>>SH) > 0) + ((py[xp]>>SH) > 0);
				else
					neighbours = ((pymm[x]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) + ((py[xmm]>>SH) == liveCol) +
								 ((pym[xpp]>>SH) == liveCol) + ((pym[xmm]>>SH) == liveCol) + ((pyp[xmm]>>SH) == liveCol) + ((pyp[xpp]>>SH) == liveCol) +
								 ((pym[xp]>>SH) == liveCol) + ((pym[xm]>>SH) == liveCol) + ((pyp[xm]>>SH) == liveCol) + ((pyp[xp]>>SH) == liveCol) +
								 ((pym[x]>>SH) == liveCol) + ((pyp[x]>>SH) == liveCol) + ((py[xm]>>SH) == liveCol) + ((py[xp]>>SH) == liveCol);
				break;

				// XXXXX
				// XXXXX
				// XX*XX
				// XXXXX
				// XXXXX
				case 5:
				if (liveCol <= 1)
					neighbours = ((pymm[x]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((py[xpp]>>SH) > 0) + ((py[xmm]>>SH) > 0) +
								 ((pym[xpp]>>SH) > 0) + ((pym[xmm]>>SH) > 0) + ((pyp[xmm]>>SH) > 0) + ((pyp[xpp]>>SH) > 0) +
								 ((pym[xp]>>SH) > 0) + ((pym[xm]>>SH) > 0) + ((pyp[xm]>>SH) > 0) + ((pyp[xp]>>SH) > 0) +
								 ((pym[x]>>SH) > 0) + ((pyp[x]>>SH) > 0) + ((py[xm]>>SH) > 0) + ((py[xp]>>SH) > 0) +
								 ((pymm[xmm]>>SH) > 0) + ((pymm[xpp]>>SH) > 0) + ((pypp[xmm]>>SH) > 0) + ((pypp[xpp]>>SH) > 0);
				else
					neighbours = ((pymm[x]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) + ((py[xmm]>>SH) == liveCol) +
								 ((pym[xpp]>>SH) == liveCol) + ((pym[xmm]>>SH) == liveCol) + ((pyp[xmm]>>SH) == liveCol) + ((pyp[xpp]>>SH) == liveCol) +
								 ((pym[xp]>>SH) == liveCol) + ((pym[xm]>>SH) == liveCol) + ((pyp[xm]>>SH) == liveCol) + ((pyp[xp]>>SH) == liveCol) +
								 ((pym[x]>>SH) == liveCol) + ((pyp[x]>>SH) == liveCol) + ((py[xm]>>SH) == liveCol) + ((py[xp]>>SH) == liveCol) +
								 ((pymm[xmm]>>SH) == liveCol) + ((pymm[xpp]>>SH) == liveCol) + ((pypp[xmm]>>SH) == liveCol) + ((pypp[xpp]>>SH) == liveCol);
				break;


				// XXXXX
				// X...X
				// X.*.X
				// X...X
				// XXXXX
				case 6:
				if (liveCol <= 1)
					neighbours = ((pymm[xmm]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[x]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pymm[xpp]>>SH) > 0) + 
								 ((pym[xmm]>>SH) > 0) + ((pym[xpp]>>SH) > 0) + 
								 ((py[xmm]>>SH) > 0) + ((py[xpp]>>SH) > 0) + 
								 ((pyp[xmm]>>SH) > 0) + ((pyp[xpp]>>SH) > 0) + 
								 ((pypp[xmm]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((pypp[xpp]>>SH) > 0);
				else
					neighbours = ((pymm[xmm]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[x]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pymm[xpp]>>SH) == liveCol) + 
								 ((pym[xmm]>>SH) == liveCol) + ((pym[xpp]>>SH) == liveCol) + 
								 ((py[xmm]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) + 
								 ((pyp[xmm]>>SH) == liveCol) + ((pyp[xpp]>>SH) == liveCol) + 
								 ((pypp[xmm]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((pypp[xpp]>>SH) == liveCol);
				break;
				
				// XX.XX
				// X...X
				// ..*..
				// X...X
				// XX.XX
				case 7:
				if (liveCol <= 1)
					neighbours = ((pymm[xmm]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pymm[xpp]>>SH) > 0) + 
								 ((pym[xmm]>>SH) > 0) + ((pym[xpp]>>SH) > 0) + 
								 ((pyp[xmm]>>SH) > 0) + ((pyp[xpp]>>SH) > 0) + 
								 ((pypp[xmm]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((pypp[xpp]>>SH) > 0);
				else
					neighbours = ((pymm[xmm]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pymm[xpp]>>SH) == liveCol) + 
								 ((pym[xmm]>>SH) == liveCol) + ((pym[xpp]>>SH) == liveCol) + 
								 ((pyp[xmm]>>SH) == liveCol) + ((pyp[xpp]>>SH) == liveCol) + 
								 ((pypp[xmm]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((pypp[xpp]>>SH) == liveCol);
				break;
				
				
				// XX...
				// XX...
				// XX*..
				// XX...
				// XX...
				case 8:
				if (liveCol <= 1)
					neighbours = ((pymm[xmm]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + 
								((pym[xmm]>>SH) > 0) + ((pym[xm]>>SH) > 0) + 
								((py[xmm]>>SH) > 0) + ((py[xm]>>SH) > 0) + 
								((pyp[xmm]>>SH) > 0) + ((pyp[xm]>>SH) > 0) + 
								((pypp[xmm]>>SH) > 0) + ((pypp[xm]>>SH) > 0);
				else
					neighbours = ((pymm[xmm]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + 
								((pym[xmm]>>SH) == liveCol) + ((pym[xm]>>SH) == liveCol) + 
								((py[xmm]>>SH) == liveCol) + ((py[xm]>>SH) == liveCol) + 
								((pyp[xmm]>>SH) == liveCol) + ((pyp[xm]>>SH) == liveCol) + 
								((pypp[xmm]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol);
				break;
				
				// XX.XX
				// .....
				// X.*.X
				// .....
				// XX.XX
				case 9:
				if (liveCol <= 1)
					neighbours = ((pymm[xmm]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pymm[xpp]>>SH) > 0) + ((pypp[xmm]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((pypp[xpp]>>SH) > 0) + ((py[xpp]>>SH) > 0) +  + ((py[xmm]>>SH) > 0);
				else
					neighbours = ((pymm[xmm]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pymm[xpp]>>SH) == liveCol) + ((pypp[xmm]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((pypp[xpp]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) +  + ((py[xmm]>>SH) == liveCol);
				break;
				
				// XXXXX
				// ..X..
				// ..*..
				// ..X..
				// XXXXX
				case 10:
				if (liveCol <= 1)
					neighbours = ((pymm[xmm]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[x]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pymm[xpp]>>SH) > 0) + 
								 ((pym[x]>>SH) > 0) + 
								 ((pyp[x]>>SH) > 0) + 
								 ((pypp[xmm]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((pypp[xpp]>>SH) > 0);
				else
					neighbours = ((pymm[xmm]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[x]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pymm[xpp]>>SH) == liveCol) + 
								 ((pym[x]>>SH) == liveCol) + 
								 ((pyp[x]>>SH) == liveCol) + 
								 ((pypp[xmm]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((pypp[xpp]>>SH) == liveCol);
				break;
				
				// .X.X.
				// .X.X.
				// .X*X.
				// .X.X.
				// .X.X.
				case 11:
				if (liveCol <= 1)
					neighbours = ((pymm[xm]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + 
								 ((pym[xm]>>SH) > 0) + ((pym[xp]>>SH) > 0) + 
								 ((py[xmm]>>SH) > 0) + ((py[xpp]>>SH) > 0) + 
								 ((pyp[xm]>>SH) > 0) + ((pyp[xp]>>SH) > 0) + 
								 ((pypp[xm]>>SH) > 0) + ((pypp[xp]>>SH) > 0);
				else
					neighbours = ((pymm[xm]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + 
								 ((pym[xm]>>SH) == liveCol) + ((pym[xp]>>SH) == liveCol) + 
								 ((py[xmm]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) + 
								 ((pyp[xm]>>SH) == liveCol) + ((pyp[xp]>>SH) == liveCol) + 
								 ((pypp[xm]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol);
				break;

				// ...XX
				// ...XX
				// ..*..
				// XXX..
				// XXX..
				case 12:
				if (liveCol <= 1)
					neighbours = ((pymm[xpp]>>SH) > 0) + ((pymm[xp]>>SH) > 0) +
								 ((pym[xpp]>>SH) > 0) + ((pym[xp]>>SH) > 0) +
								 ((pyp[xmm]>>SH) > 0) + ((pyp[xm]>>SH) > 0) + ((pyp[x]>>SH) > 0) +
								 ((pypp[xmm]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[x]>>SH) > 0);
				else
					neighbours = ((pymm[xpp]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) +
								 ((pym[xpp]>>SH) == liveCol) + ((pym[xp]>>SH) == liveCol) +
								 ((pyp[xmm]>>SH) == liveCol) + ((pyp[xm]>>SH) == liveCol) + ((pyp[x]>>SH) == liveCol) +
								 ((pypp[xmm]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol);
				break;

				// XXXXX
				// ....X
				// XX*.X
				// X...X
				// XXXXX
				case 13:
				if (liveCol <= 1)
					neighbours = ((pymm[xmm]>>SH) > 0) + ((pymm[xm]>>SH) > 0) + ((pymm[x]>>SH) > 0) + ((pymm[xp]>>SH) > 0) + ((pymm[xpp]>>SH) > 0) + 
								 ((pym[xpp]>>SH) > 0) + 
								 ((pyp[xpp]>>SH) > 0) + ((pyp[xmm]>>SH) > 0) +
								 ((py[xmm]>>SH) > 0) + ((py[xm]>>SH) > 0) + ((py[xpp]>>SH) > 0) +
								 ((pypp[xmm]>>SH) > 0) + ((pypp[xm]>>SH) > 0) + ((pypp[x]>>SH) > 0) + ((pypp[xp]>>SH) > 0) + ((pypp[xpp]>>SH) > 0);
				else
					neighbours = ((pymm[xmm]>>SH) == liveCol) + ((pymm[xm]>>SH) == liveCol) + ((pymm[x]>>SH) == liveCol) + ((pymm[xp]>>SH) == liveCol) + ((pymm[xpp]>>SH) == liveCol) + 
								 ((pym[xpp]>>SH) == liveCol) + 
								 ((pyp[xpp]>>SH) == liveCol) + ((pyp[xmm]>>SH) == liveCol) +
								 ((py[xmm]>>SH) == liveCol) + ((py[xm]>>SH) == liveCol) + ((py[xpp]>>SH) == liveCol) +
								 ((pypp[xmm]>>SH) == liveCol) + ((pypp[xm]>>SH) == liveCol) + ((pypp[x]>>SH) == liveCol) + ((pypp[xp]>>SH) == liveCol) + ((pypp[xpp]>>SH) == liveCol);
				break;
			}

			state2 = py[x];
			state = state2 >> SH;
			if (state) {
				state = slowDeath? state-1 : 0;
				if (stayRules[neighbours]) { state=neighbours; /*if(state>7)state=7;*/ }  // for slowDeath, state=py[x] would actually be more "accurate" (but results are less interesting)
			} else {
				state = 0;
				if (bornRules[neighbours]) { state = liveCol <= 1? neighbours : liveCol; /*if(state>7)state=7;*/ }
			}

			r=(state2>>16)&0xff;
			g=(state2>>8)&0xff;
			b=(state2)&0xff;
			
			if (state) {
				mulBase = neighbours;
				if (mulPatt == 1) mulBase = state;
				if (mulPatt == 2) mulBase = 1;
				if (mulPatt == 3) mulBase ^= state;
				if (state & rAnd) r+=mulBase*rMul;
				if (state & gAnd) g+=mulBase*gMul;
				if (state & bAnd) b+=mulBase*bMul;
				
				if (stayPatt == 5 || stayPatt == 6) b=g=r;	
			} else {
				switch(stayPatt) {
					case 0: default: 
					r-=rNeg;
					g-=gNeg;
					b-=bNeg;
					break;

					case 1:
					if (r>=stayPattVal) r-=rNeg;
					if (r>=stayPattVal) g-=gNeg;
					if (r>=stayPattVal) b-=bNeg;
					break;
					
					case 2:
					if (b>=stayPattVal) r-=rNeg;
					if (b>=stayPattVal) g-=gNeg;
					if (b>=stayPattVal) b-=bNeg;
					break;

					case 3:
					if (g>=stayPattVal) r-=rNeg;
					if (g>=stayPattVal) g-=gNeg;
					if (g>=stayPattVal) b-=bNeg;
					break;
					
					case 4:
					if (b>=stayPattVal) r-=rNeg;
					if (b>=stayPattVal) g-=gNeg;
					if (r>=stayPattVal) b-=bNeg;
					break;

					case 5: 
					r-=rNeg;
					b=g=r;
					break;
				}
				
			}

			if (r>255) r=topClampVal;
			if (g>255) g=topClampVal;
			if (b>255) b=topClampVal;
			
			if (r<0) r=bottomClampVal;
			if (g<0) g=bottomClampVal;
			if (b<0) b=bottomClampVal;
			
			*outArray++ = (r<<16)|(g<<8)|(state<<SH)|b;

/*
			state2 = py[x];
			state = state2 >> SH;

			
			if (state) {
				state = slowDeath? state-1 : 0;
				if (stayRules[neighbours]) { state=neighbours; }  // for slowDeath, state=py[x] would actually be more "accurate" (but results are less interesting)
			} else {
				state = 0;
				if (bornRules[neighbours]) { state = liveCol <= 1? neighbours : liveCol; }
			}
			
			int r=(state2>>16)&0xff;
			int g=(state2>>8)&0xff;
			int b=(state2)&0xff;
			
			if (state) {
				if (r < 256-6 && (state & 1)) r+=6;
				if (g < 256-6 && (state & 2)) g+=6;
				if (b < 256-6 && (state & 4)) b+=6;
			} else {
				if (r >= 2) r-=2;
				if (g >= 2) g-=2;
				if (b >= 2) b-=2;
			}
			*outArray++ = (r<<16)|(g<<8)|(state<<24)|b;
			*/
			
		}
	}
}
