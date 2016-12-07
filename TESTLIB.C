// Gfx lib used for cmdline text output

#include <stdio.h>
#include <math.h>
#include <string.h>
#include <conio.h>
#include <windows.h>
#include "gfxlib.h"
#include "outputText.h"

int XRES, YRES, FRAMESIZE;
uchar *video;
int SCR_XRES, SCR_YRES;

void wait_vblank(int maxWaitTime) {
	static int oldTime = 0;
	
	int deltaWait = (oldTime+maxWaitTime) - timeGetTime();
	while (deltaWait > 0) {
		deltaWait = (oldTime+maxWaitTime) - timeGetTime();
	}
	//if (deltaWait > 0 && deltaWait <= maxWaitTime) {
	//Sleep(deltaWait);
	
	oldTime = timeGetTime();
}

void setResolution(int resX, int resY) {
	XRES=resX;
	YRES=resY;
	FRAMESIZE=XRES*YRES;
}

void change_clipedges(int clipedges[], int chx_1, int chy_1, int chx_2, int chy_2) {
	if (clipedges[2]+chx_2<=clipedges[0]+chx_1 ||
			clipedges[3]+chy_2<=clipedges[1]+chy_1)
	return;

	clipedges[0]+=chx_1;
	if (clipedges[0]<0) clipedges[0]=0;
	if (clipedges[0]>=SCR_XRES) clipedges[0]=SCR_XRES;

	clipedges[1]+=chy_1;
	if (clipedges[1]<0) clipedges[1]=0;
	if (clipedges[1]>=SCR_YRES) clipedges[1]=SCR_YRES;

	clipedges[2]+=chx_2;
	if (clipedges[2]<0) clipedges[2]=0;
	if (clipedges[2]>=SCR_XRES) clipedges[2]=SCR_XRES;

	clipedges[3]+=chy_2;
	if (clipedges[3]<0) clipedges[3]=0;
	if (clipedges[3]>=SCR_YRES) clipedges[3]=SCR_YRES;
}

void set_clipbox (int clipedges[], char *base) {
	int x1=clipedges[0],y1=clipedges[1],x2=clipedges[2],y2=clipedges[3];

	if (x2<=x1 || y2<=y1 || x1<0 || x1>SCR_XRES || y1<0 || y1>SCR_YRES ||
			x2<0 || x2>SCR_XRES || y2<0 || y2>SCR_YRES) {
		return;
	}

	video=base+x1+y1*SCR_XRES;
	XRES=x2-x1; YRES=y2-y1;
	FRAMESIZE=XRES*YRES;
}


void drawcurve (float cpoints[][2], int nof_points, uchar col, int xg, int yg, int granularity, int mon, int outline) {
	float x, y, talj, namn, oldx, oldy = 0, xmin, xmax;
	int i, j, fcol;

	for (i = 1, xmin = xmax = cpoints[0][0]; i < nof_points; i++) {
		if (cpoints[i][0] < xmin)
		xmin = cpoints[i][0];
		if (cpoints[i][0] > xmax)
		xmax = cpoints[i][0];
	}
	if ((xmin+xg)<1) { if ((xmax+xg)<1) return; else xmin=-xg-1; }
	if ((xmax+xg)>=XRES) { if ((xmin+xg)>=XRES) return; else xmax=XRES-xg; }

	for (x = xmin, oldx = -10000; x < xmax; x += granularity) {
		for (i = y = 0; i < nof_points; i++) {
			for (j = 0, talj = namn = 1; j < nof_points; j++) {
				if (i != j) {
					talj *= x - cpoints[j][0];
					namn *= cpoints[i][0] - cpoints[j][0];
				}
			}
			y += cpoints[i][1] * (talj / namn);
		}
		if (oldx > -10000) {
			if (mon) {
				vline(x + xg, y + yg, YRES, col);
			}
			else {
				fcol = (y + yg) / 6 + 20;
				if (fcol < 24) fcol = 24; if (fcol > 31) fcol = 31;
				vline(x + xg, y + yg, YRES, fcol);
				if (outline) {
					line(x + xg, y + yg, oldx + xg, oldy + yg, col, 1);
				}
			}
		}
		oldx = x, oldy = y;
	}
}


obj3d *switchObj3d(int index, obj3d *old) {
	obj3d *obj = NULL;
	switch(index) {
	default: break;
	case 0: obj = readPly("testlib\\ply\\icosahedron.ply", 400, 0,0,0); break;
	case 1: obj = readPly("testlib\\ply\\shark.ply", 400, 0,0,0); break;
	case 2: obj = readPly("testlib\\ply\\airplane.ply", 1,  -900,-600,-130); break;
	case 3: obj = readPly("testlib\\ply\\ant.ply", 40, 0,0,0); break;
	case 4: obj = readPly("testlib\\ply\\apple.ply", 6400, 0,-0.03,0); break;
	case 5: obj = readPly("testlib\\ply\\big_atc.ply", 150, 0,0,0); break;
	case 6: obj = readPly("testlib\\ply\\big_dodge.ply", 60, 0,0,0); break;
	case 7: obj = readPly("testlib\\ply\\big_porsche.ply", 70, 0,0,0); break;
	case 8: obj = readPly("testlib\\ply\\big_spider.ply", 180, -3,-3,-2); break;
	case 9: obj = readPly("testlib\\ply\\chopper.ply", 6,  0,-40,0); break;
	case 10: obj = readPly("testlib\\ply\\dolphins.ply", 2,  0,0,0); break;
	case 11: obj = readPly("testlib\\ply\\egret.ply", 0.4,  -400,-400,0); break;
	case 12: obj = readPly("testlib\\ply\\fracttree.ply", 140,  0,0,0); break;
	case 13: obj = readPly("testlib\\ply\\helix.ply", 10,  0,0,0); break;
	case 14: obj = readPly("testlib\\ply\\hind.ply", 50,  0,0,0); break;
	case 15: obj = readPly("testlib\\ply\\ketchup.ply", 90,  -2,-3,-4); break;
	case 16: obj = readPly("testlib\\ply\\scissors.ply", 120,  -5,0,0); break;
	case 17: obj = readPly("testlib\\ply\\sphere.ply", 2.8,  0,0,0); break;
	case 18: obj = readPly("testlib\\ply\\steeringweel.ply", 2,  0,0,0); break;
	case 19: obj = readPly("testlib\\ply\\teapot.ply", 160,  0,-0.3,-0.8); break;
	case 20: obj = readPly("testlib\\ply\\trashcan.ply", 11,  0,0,0); break;
	case 21: obj = readPly("testlib\\ply\\urn2.ply", 300,  0,0,0); break;
	case 22: obj = readPly("testlib\\ply\\weathervane.ply", 1,  0,0,0); break;

	case 23: obj = readObj("testlib\\obj\\elephav.obj", 1,  0,-360,0, 0, NULL); break;

	case 24: obj = readPlg("testlib\\plg\\torus.plg", 1.3, 0,0,0); break;
	case 25: obj = readPlg("testlib\\plg\\sphere.plg", 1.8, 0,0,0); break;
	case 26: obj = readPlg("testlib\\plg\\pot.plg", 1.4, 0,0,0); break;
	case 27: obj = readPlg("testlib\\plg\\springy1.plg", 0.23, 0,0,0); break;
	case 28: obj = readPlg("testlib\\plg\\ncc1701.plg", 0.5, 0,0,0); break;
	case 29: obj = readPlg("testlib\\plg\\chopper.plg", 0.3, 0,-800,-800); break;
	case 30: obj = readPlg("testlib\\plg\\nya\\balloon.plg", 4, 0,0,0); break;
	case 31: obj = readPlg("testlib\\plg\\nya\\biplane.plg", 10, -10,-30,-25); break;
	case 32: obj = readPlg("testlib\\plg\\nya\\bishban.plg", 0.5, 0,-700,0); break;
	case 33: obj = readPlg("testlib\\plg\\nya\\cylinder.plg", 1.6, 0,0,0); break;
	case 34: obj = readPlg("testlib\\plg\\nya\\f.plg", 3, 0,0,0); break;
	case 35: obj = readPlg("testlib\\plg\\nya\\octcone.plg", 0.7, 0,0,0); break;
	case 36: obj = readPlg("testlib\\plg\\nya\\pharaoh.plg", 2, 0,0,0); break;
	case 37: obj = readPlg("testlib\\plg\\nya\\spider.plg", 0.8, 0,0,0); break;
	case 38: obj = readPlg("testlib\\plg\\nya\\tree.plg", 6, 0,-80,0); break;

	case 39: obj = readObj("testlib\\obj\\FinalBaseMesh.obj", 50,  0,-10,0, 1, NULL); break;
	case 40: obj = readObj("testlib\\obj\\Elexis_nude.obj", 330,  0,-2,0, 0, NULL); break;
	case 41: obj = readObj("testlib\\obj\\Hulk.obj", 230,  0,-2,0, 0, NULL); break;
	}
	if (obj) {
		if (old) freeObj3d(old);
		return obj;
	} else
	return old;
}


#define Z_LEVELS 10

int main(int argc, char *argv[]) {
	int i, j, k, xg, yg, nof_points = 5, twave = 1;
	uchar *virtual, ch=0, mon=0;
	uchar clip=0, logo=0, two=1, utlin=0, text=0, show=1, skeleton = 0;
	uchar usebg = 0, usebgchars = 0;
	float cpoints[50][2], cc = 1.6, aa=0;
	float add[50], accum[50], add2[50], accum2[50];
	intVector vv[3];
	int I[24], tx;
	int clipedges[4]={2,2,0,0};
	int txres, tyres;
	Bitmap b_pcx, b_sides[6];
	int paletteIndex = 0;
	int *palettes[8];
	int *palette;
	int col, vblank=0;
	obj3d *obj3 = NULL;
	float us[4] = {0,  1,  1,  0};
	float vs[4] = {0,  0,  1,  1};
	int goraudType = GORAUD_TYPE_Z;
	int flatType = 0;
	float aspect = 1.133333;
	int mapIndex = 0;
	int bChangePalette = 0;
	long timer;
	int timerCnt = 0, timerMaxCnt = 0;

	int palette1[256];
	int p_first8pip[16] = { 0, 15, 0, 7, 3, 12,7,15 }; // for pipo der
	//  int p_first8[16] = { 0, 1, 3, 1, 8, 7,15,0,4,5 }; // for texa, b, c
	int p_first8[16] = { 0, 4, 2, 6, 1, 5, 3, 8,7,0,0 }; // for hulk2
	//  int p_first8[16] = { 0, 0, 0, 1, 2, 8, 10, 15,14,0,0 }; // for hulk  ; possibly change 1 to -1 for dark green
	//  int p_first8E[16] = { 0, 4, -1, 12, -1, 7, 0, 0 }; // for Elexis
	//  int p_first8E[16] = { 0, 4, -1, 7, -1, 15, 0, 0 }; // for Elexis, alternative
	int p_first8E[16] = { 0, -1, 4, -1, 7, -1, 15, 0, }; // for Elexis, alternative
	int p_shade[16] = { 15, -1, 11, -1, 7, -1, 9, -1, 1, -1, 0 };
	//  int p_shade[16] = { 15, 15, 11, 11, 7, 7, 9, 9, 1, 1, 0 };
	int p_shade2[24] = { 15, -1, 12, -1, 4, -1, 7, -1, 1, -1, 0, -1, 2, -1, 14, -1, 1 };

	int palette2[256];
	int p2_shade[16] = { 9, 15+(7<<4), 10+(2<<4), 13+(5<<4), 11+(3<<4), 9+(1<<4), 14+(6<<4), 7+(8<<4), 4+(12<<4), 10+(2<<4), 9+(1<<4) };
	int p2_shade2[24] = { 15, 14, 13, 11, 7, 7, 9, 9, 15, 7, 8, 8 };

	int palette3[256];
	int p3_first8[16] = { 0, 12, 0, 14, 4, 12,7,14 };  
	int p3_shade[16] = { 9, 15, 9, 15, 11, 7, 8, 3, 1, 7, 11, 15, 9, 15, 1 };
	int p3_shade2[24] = { 1,1,1,1,1,1,9,1,1,1,1,1,1,1,1 };

	point3d triangle[50];
	float rx=0,ry=0,rz=0;
	float rxa=0.01, rya=-0.02, rza=0.008;
	int dist=2700;
	intVector v[24];
	int scale = 2;
	int objIndex = 0;
	float *averageZ;
	float lowZ, highZ, addZ, currZ;
	int culling = 1, depthSort = 1;
	int captureCnt = 1, result, contCapture = 0;
	char fname[64];

	CHAR_INFO *old = NULL;
	old = readScreenBlock();

	palettes[0] = palette1;
	palettes[1] = palette2;
	palettes[2] = palette3;
	palette = palettes[0];

	averageZ = (float *) malloc(32000*sizeof(float));
	if (!averageZ) { printf("Err: Couldn't allocate memory for averages\n"); return 0; }

	if (argc > 1)
	sscanf(argv[1],"%f",&aspect);
	if (argc > 2)
	sscanf(argv[2],"%d",&scale);

	if (scale == 1) dist = 5000;

	timeBeginPeriod(1);
	
	setDefaultTextPalette(palette1);
	setTextPalette(palette1, 0, p_first8pip, 9);
	setTextPalette(palette1, 8, p_shade, 11);
	//  setTextPalette(palette1, 0, p_first8, 10);
	setTextPalette(palette1, 24, p_shade2, 16);

	setDefaultTextPalette(palette2);
	setTextPalette(palette2, 0, p_first8, 8);
	setTextPalette(palette2, 8, p2_shade, 11);
	setTextPalette(palette2, 24, p2_shade2, 16);

	setDefaultTextPalette(palette3);
	setTextPalette(palette3, 0, p3_first8, 8);
	setTextPalette(palette3, 8, p3_shade, 11);
	setTextPalette(palette3, 24, p3_shade2, 16);

	palette1[64] = 0;

	triangle[0].x=-250; triangle[0].y=-250; triangle[0].z=-250;
	triangle[0].u=0; triangle[0].v=0;
	triangle[1].x=-250; triangle[1].y=250; triangle[1].z=-250;
	triangle[1].u=0; triangle[1].v=1;
	triangle[2].x=250; triangle[2].y=250; triangle[2].z=-250;
	triangle[2].u=1; triangle[2].v=1;
	triangle[3].x=250; triangle[3].y=-250; triangle[3].z=-250;
	triangle[3].u=1; triangle[3].v=0;
	for(i=0; i<4; i++) { triangle[i+4].x=triangle[3-i].x; triangle[i+4].y=triangle[3-i].y; triangle[i+4].z=250;
		triangle[i+4].u=triangle[3-i].u; triangle[i+4].v=triangle[3-i].v; }
	for(i=0; i<4; i++) { triangle[i+8].x=triangle[3-i].x; triangle[i+8].z=triangle[3-i].y; triangle[i+8].y=-250;
		triangle[i+8].u=triangle[3-i].u; triangle[i+8].v=triangle[3-i].v; }
	for(i=0; i<4; i++) { triangle[i+12].x=triangle[i].x; triangle[i+12].z=triangle[i].y; triangle[i+12].y=250;
		triangle[i+12].u=triangle[i].u; triangle[i+12].v=triangle[i].v; }
	for(i=0; i<4; i++) { triangle[i+16].z=triangle[i].x; triangle[i+16].y=triangle[i].y; triangle[i+16].x=250;
		triangle[i+16].u=triangle[i].u; triangle[i+16].v=triangle[i].v; }
	for(i=0; i<4; i++) { triangle[i+20].z=triangle[3-i].x; triangle[i+20].y=triangle[3-i].y; triangle[i+20].x=-250;
		triangle[i+20].u=triangle[3-i].u; triangle[i+20].v=triangle[3-i].v; }
	
	vv[0].x=-40; vv[0].y=10; vv[1].x=30; vv[1].y=-30; vv[2].x=400; vv[2].y=220;
	I[0]=8; I[1]=19; I[2]=18; I[3]=9;

	if (!(PCXload (&b_pcx,"testlib\\TX\\rip45_2.pcx"))) return 0;

	//  if (!(PCXload (&b_sides[0],"testlib\\TX\\rip45_3.pcx"))) return 0;
	//  if (!(PCXload (&b_sides[2],"testlib\\TX\\rip45_3.pcx"))) return 0;
	//  if (!(PCXload (&b_sides[4],"testlib\\TX\\rip45_3.pcx"))) return 0;

	if (!(PCXload (&b_sides[0],"testlib\\TX\\hulkBody2.pcx"))) return 0;
	if (!(PCXload (&b_sides[2],"testlib\\TX\\hulkBody2.pcx"))) return 0;
	if (!(PCXload (&b_sides[4],"testlib\\TX\\hulkBody2.pcx"))) return 0;

	//  if (!(PCXload (&b_sides[0],"testlib\\TX\\text_a2.pcx"))) return 0;
	//  if (!(PCXload (&b_sides[2],"testlib\\TX\\text_b.pcx"))) return 0;
	//  if (!(PCXload (&b_sides[4],"testlib\\TX\\text_c.pcx"))) return 0;

	b_sides[1] = b_sides[0];
	b_sides[3] = b_sides[2];
	b_sides[5] = b_sides[4];

	obj3 = switchObj3d(objIndex, obj3);

	if (!obj3) { printf("Failed to read 3d object!\n"); return 0; }

	txres = getConsoleDim(0);
	tyres = getConsoleDim(1);

	setResolution(txres*scale, tyres*scale+1);
	xg = XRES/2, yg = YRES/2+1;
	SCR_XRES = XRES; SCR_YRES = YRES;
	tx = XRES;
	clipedges[2] = XRES - 2;
	clipedges[3] = YRES - 2;

	virtual = (uchar *)calloc(XRES*YRES,sizeof(unsigned char));
	if (virtual == NULL) {
		printf("Error: Couldn't allocate memory for framebuffer!\n");
		return 0;
	}
	video = virtual;

	for (i = 0; i < 30; i++) {
		accum[i] = (float)(rand()%200)/300.0;
		add[i] = 0.005 + (float)(rand()%10)/3000.0;
		accum2[i] = (float)(rand()%200)/300.0;
		add2[i] = 0.005 + (float)(rand()%10)/3000.0;
	}

	if (clip) set_clipbox (clipedges, virtual);

	/*
{ // for 120x80 screen (set font to 1)
	int rx=83*scale;
	int ry=83*scale;
	int i;
	int col = 1;
	for (i = 0; i < 14; i++) {
		filled_ellipse(60*scale, 40*scale, rx,ry, col);
		col = 1-col;
		rx-=6*scale;
		ry-=6*scale;
	}
}
convertToText(usebgchars, scale, palette, clipedges[0], clipedges[1], usebg? old : NULL, mapIndex, XRES, YRES, video);
return 1;
*/


	while (ch != 27 && timerCnt < timerMaxCnt+1) {
		if (two > 0) {
			for (i = 0; i < nof_points; i++) {
				cpoints[i][0] = i*(360/(nof_points-1)) + (sin(accum[i])*10)-180;
				cpoints[i][1] = (cos(accum[i])*10 + sin(accum2[i])*10) * (float)((6-abs(5-i))/2.0) *cc;
				accum[i] += add[i];
				accum2[i] += add2[i];
			}
			drawcurve (cpoints, nof_points, 24, XRES/2, YRES/2, 1, mon, utlin);
		}
		if (two > 1) {
			for (i = 0; i < nof_points; i++) {
				cpoints[i+nof_points][0] = i*(360/(nof_points-1)) + (sin(accum[i+nof_points])*10)-180;
				cpoints[i+nof_points][1] = (cos(accum[i+nof_points])*10 + sin(accum2[i+nof_points])*10) * (float)((6-abs(5-i))/2.0) *cc;
				accum[i+nof_points] += add[i+nof_points];
				accum2[i+nof_points] += add2[i+nof_points];
			}
			drawcurve (&(cpoints[nof_points]), nof_points, 30, XRES/2, YRES/2, 1, mon, utlin);
		}
		
		rx+=rxa; ry+=rya; rz+=rza;

		if (show == 2) {
			rot3dPoints(triangle, 24, xg, yg, dist, rx, ry, rz, aspect, 0,0,0, 0,0);
			for(j=0; j<6; j++) {
				for(i=0; i<4; i++) {
					v[i].x=triangle[i+j*4].vx; v[i].y=triangle[i+j*4].vy;
					v[i].tex_coord.x=triangle[i+j*4].u; v[i].tex_coord.y=triangle[i+j*4].v;
					v[i].z=triangle[i+j*4].vz; 
					v[i].tex_coord.z=1.0;
				}

				if (!culling || (((v[1].x - v[0].x) * (v[2].y - v[1].y)) - ((v[2].x - v[1].x) * (v[1].y - v[0].y)) < 0)) {
					if (flatType == 1) {
						col = v[0].z/100+14;
						if (col < 8) col=8;
						if (col > 19) col=19;
					} else col = j+10;
					if (text == 0) {
						scanConvex(v, 4, clipedges, col);
					} else if (text == 1)
					scanConvex_tmap(v, 4, clipedges, &b_sides[j], flatType==1? col:0, 0);
					else if (text == 2)
					scanConvex_goraud(v, 4, clipedges, I, goraudType, flatType==1? col:0, 100,6,11);
					else
					polyLine(v, 4, j+10, 1, 1); 
					
					if (skeleton) polyLine(v, 4, 0, 1, 1); 
				}
			}
		}

		if (show == 1 && depthSort) {
			rot3dPoints(obj3->objData, obj3->nofPoints, xg, yg, dist, rx, ry, rz, aspect, 0,0,0, 0,0);
			
			lowZ = 99999999; highZ = -99999999;
			for(j=0; j<obj3->nofFaces; j++) {
				addZ = 0;
				for(i=0; i<obj3->faceData[j*R3D_MAX_V_PER_FACE]; i++) {
					addZ += obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vz;
				}
				addZ /= (float)i;
				if (addZ > highZ) highZ = addZ;
				if (addZ < lowZ) lowZ = addZ;
				averageZ[j] = addZ;
			}

			addZ = (highZ - lowZ) / Z_LEVELS;
			currZ = highZ;
			
			for (k = 0; k <= Z_LEVELS+1; k++) {
				for(j=0; j<obj3->nofFaces; j++) {
					if (averageZ[j] >= currZ && averageZ[j] <= currZ + addZ) {
						for(i=0; i<obj3->faceData[j*R3D_MAX_V_PER_FACE]; i++) {
							v[i].x=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vx; v[i].y=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vy;
							v[i].z=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vz; 
							if (obj3->texCoords) {
								v[i].tex_coord.x=obj3->texCoords[obj3->texData[i+1+j*R3D_MAX_V_PER_FACE] * 2];
								v[i].tex_coord.y=obj3->texCoords[obj3->texData[i+1+j*R3D_MAX_V_PER_FACE] * 2+1];
							} else {
								v[i].tex_coord.x=us[i%3]; v[i].tex_coord.y=vs[i%3];
							}
							v[i].tex_coord.z=1.0;
						}
						
						if (!culling || (((v[1].x - v[0].x) * (v[2].y - v[1].y)) - ((v[2].x - v[1].x) * (v[1].y - v[0].y)) < 0)) {
							if (flatType == 1) {
								col = v[0].z/100+14;
								if (col < 8) col=8;
								if (col > 19) col=19;
							} else col = (j%7)+10;
							if (text == 0) {
								scanConvex(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], clipedges, col);
							} else if (text == 1) {
								if (obj3->nofBmaps > 0 && obj3->bmaps[obj3->faceBitmapIndex[j]]) {
									scanConvex_tmap(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], clipedges, obj3->bmaps[obj3->faceBitmapIndex[j]], flatType==1? col:0, 0);
								} else
								scanConvex_tmap(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], clipedges, &b_sides[j%6], flatType==1? col:0, 0);
							} else if (text == 2)
							scanConvex_goraud(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], clipedges, I, goraudType, flatType==1? col:0, 100,6,11);
							else
							polyLine(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], (j%7)+10, 1, 1); 

							if (skeleton) polyLine(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], 0, 1, 1); 
						}
					}
				}
				currZ = currZ - addZ;
			}  
		}

		
		if (show == 1 && !depthSort) {
			rot3dPoints(obj3->objData, obj3->nofPoints, xg, yg, dist, rx, ry, rz, aspect, 0,0,0, 0,0);
			for(j=0; j<obj3->nofFaces; j++) {
				for(i=0; i<obj3->faceData[j*R3D_MAX_V_PER_FACE]; i++) {
					v[i].x=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vx; v[i].y=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vy;
					v[i].z=obj3->objData[obj3->faceData[i+1+j*R3D_MAX_V_PER_FACE]].vz;
					if (obj3->texCoords) {
						v[i].tex_coord.x=obj3->texCoords[obj3->texData[i+1+j*R3D_MAX_V_PER_FACE] * 2];
						v[i].tex_coord.y=obj3->texCoords[obj3->texData[i+1+j*R3D_MAX_V_PER_FACE] * 2+1];
					} else {
						v[i].tex_coord.x=us[i%3]; v[i].tex_coord.y=vs[i%3];
					}
					v[i].tex_coord.z=1.0;
				}
				
				if (!culling || (((v[1].x - v[0].x) * (v[2].y - v[1].y)) - ((v[2].x - v[1].x) * (v[1].y - v[0].y)) < 0)) {
					if (flatType == 1) {
						col = v[0].z/100+14;
						if (col < 8) col=8;
						if (col > 19) col=19;
					} else col = (j%7)+10;
					if (text == 0) {
						scanConvex(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], clipedges, col);
					} else if (text == 1) {
						if (obj3->nofBmaps > 0 && obj3->bmaps[obj3->faceBitmapIndex[j]])
						scanConvex_tmap(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], clipedges, obj3->bmaps[obj3->faceBitmapIndex[j]], flatType==1? col:0, 0);
						else
						scanConvex_tmap(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], clipedges, &b_sides[j%6], flatType==1? col:0, 0);
					} else if (text == 2)
					scanConvex_goraud(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], clipedges, I, goraudType, flatType==1? col:0, 100,6,11);
					else
					polyLine(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], (j%7)+10, 1, 1);
					
					if (skeleton) polyLine(v, obj3->faceData[j*R3D_MAX_V_PER_FACE], 0, 1, 1); 
				}
			}
		}
		

		if (logo) {
			aa=aa+0.03;
			if (logo == 1) put_transparent_Bitmap (-40+sin(aa)*80*twave, 1, &b_pcx);
			if (logo == 2) shadeBitmap (-40+sin(aa)*80*twave, 1, &b_pcx, 0);
		}

		if (clip) {
			convertToText(usebgchars, scale, palette, clipedges[0], clipedges[1], usebg? old : NULL, mapIndex, XRES, YRES, video);
			memset(virtual,0, FRAMESIZE);
		}
		else {
			convertToText(usebgchars, scale, palette, 0, 0, usebg? old : NULL, mapIndex, XRES, YRES, video);
			memset(virtual,0, FRAMESIZE);
		}

		if (timerMaxCnt == 0 && vblank)
			wait_vblank(5);

		if (kbhit()) {
			ch = getch();
			if (ch == 0) ch = getch();

			if (ch=='c') {
				clrScr(0,scale,SCR_XRES, SCR_YRES); 
				clip = 1 - clip;
				if (clip == 0) { video=virtual; XRES=SCR_XRES; YRES=SCR_YRES; FRAMESIZE=XRES*YRES; }
				else { set_clipbox (clipedges, virtual); }
			}
			if (ch=='s') usebg = 1 - usebg;
			if (ch=='S') { usebgchars++; if (usebgchars > 2) usebgchars = 0; }
			if (ch=='o') { text++; if (text > 3) text=0; bChangePalette=1; }
			if (ch=='u') utlin = 1 - utlin;
			if (ch=='U') skeleton = 1 - skeleton;
			if (ch=='t') { two++; if (two > 2) two = 0; }
			if (ch=='b') { logo++; if (logo > 2) logo = 0; }
			if (ch=='B') { twave = 1-twave; }
			if (ch=='m') mon = 1 - mon;
			if (ch=='M') { mapIndex++; if (mapIndex > 2) mapIndex = 0; }
			if (ch=='C') { show++; if (show > 2) show = 0; }
			if (ch=='>') cc += 0.1;
			if (ch=='<') { cc -= 0.1; if (cc < 0) cc = 0; }
			if (ch=='+'  && nof_points < 20 ) nof_points++;
			if (ch=='-'  && nof_points > 2 ) nof_points--;
			if (ch=='1' && clip) { clrScr(0,scale,SCR_XRES, SCR_YRES); change_clipedges (clipedges, 2, 2, -2, -2); set_clipbox (clipedges, virtual); }
			if (ch=='2' && clip) { change_clipedges (clipedges, -2, -2, 2, 2); set_clipbox (clipedges, virtual); }
			if (ch=='p') { while (!kbhit()); ch = getch(); if (!ch) getch();}
			if (ch=='P') { paletteIndex++; if (paletteIndex > 2) paletteIndex = 0; palette = palettes[paletteIndex]; }
			if (ch=='D') dist-=100;
			if (ch=='d') dist+=100;
			if (ch=='N') { objIndex++; if (objIndex > 41) objIndex=0; obj3 = switchObj3d(objIndex, obj3); bChangePalette=1; }
			if (ch=='n') { objIndex--; if (objIndex < 0) objIndex=41; obj3 = switchObj3d(objIndex, obj3); bChangePalette=1; }
			if (ch=='g') { goraudType++; if (goraudType > 1) goraudType = 0; }
			if (ch=='G') { flatType++; if (flatType > 1) flatType = 0; }
			if (ch==1) { rxa=0; rx=0; rya=0; ry=0; rza=0; rz=0; }
			if (ch==25) { rxa=0;  }
			if (ch==24) { rya=0;  }
			if (ch==26) { rza=0; }
			if (ch=='x') { rya-=0.005; }
			if (ch=='X') { rya+=0.005; }
			if (ch=='y') { rxa-=0.005; }
			if (ch=='Y') { rxa+=0.005; }
			if (ch=='z') { rza-=0.005; }
			if (ch=='Z') { rza+=0.005; }
			if (ch=='q') { xg-=1; }
			if (ch=='Q') { xg+=1; }
			if (ch=='v') { vblank = 1-vblank; }
			if (ch=='w') { yg-=1; }
			if (ch=='W') { yg+=1; }
			if (ch=='T') { timerCnt = 0; timerMaxCnt = 1000; timer = GetTickCount(); }
			if (ch==17) { xg=XRES/2; yg=YRES/2; }
			if (ch=='.') culling = 1 - culling;
			if (ch==',') depthSort = 1 - depthSort;
			if (ch=='k') {
				sprintf(fname, "%s-%d", "capture", captureCnt); 
				result = saveScreenBlock(fname, 0, 0, XRES/2, YRES/2, 1, -1, -1, -1); 
				if (result == 0) { printf("Saved %s.gxy\n", fname); getch(); captureCnt++; }
				contCapture = 0;
			}
			if (ch=='K') {
				contCapture = 1 - contCapture;
			}
			
			if (bChangePalette) {
				setTextPalette(palette1, 0, p_first8pip, 9);
				setTextPalette(palette1, 8, p_shade, 11);
				if(text==1) {
					if (objIndex == 40)
					setTextPalette(palette1, 0, p_first8E, 9);
					else
					setTextPalette(palette1, 0, p_first8, 10);
				}
				bChangePalette = 0;
			}
		}
		
		if (contCapture) {
			sprintf(fname, "%s-%d", "capture", captureCnt); 
			result = saveScreenBlock(fname, 0, 0, XRES/2, YRES/2, 1, -1, -1, -1); 
			if (result == 0) { printf("Saved %s.gxy\n", fname); captureCnt++; }
		}
		
		if (timerMaxCnt > 0)
		timerCnt++;
		
	}

	timeEndPeriod(1);

	if (timerMaxCnt > 0)
		printf("\n%ld %ld\n", (GetTickCount()-timer)/1000,  GetTickCount()-timer);  

	free(obj3);
	free(virtual);
	free(b_pcx.data);
	free(averageZ);
	//  if (obj3) freeObj3d(obj3);
	return 1;
}
