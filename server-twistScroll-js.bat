@if (true == false) @end /*
@echo off
if defined __ goto :START
cmdwiz showcursor 0 
set __=.
cmdgfx_input.exe knW13x | call %0 %* | cmdgfx_gdi "" SZ300f0:0,0,3160,95,160,90
set __=
goto :eof

:START
cmdwiz setfont 6 & cls & mode 80,45 & cmdwiz showcursor 0 & call centerwindow.bat 0 -20

cscript //nologo //e:javascript "%~dpnx0" %*
rem cmdwiz getch & rem Enable this line to see jscript parse errors

echo "cmdgfx: quit"
title input:Q
mode 80,50 & cmdgfx_gdi ""
exit /b 0 */


var w=160, h=90, xmid=w/2, ymid=h/2, yp=ymid + 3, mode=0, dist=12000, drawmode=0, mirror=1, mx=0, my=0

var orgsx=0.0, orgsr=0.0, cc=2.0, sx2=3.0
var imgc=0, imgcd=0, tyOffset=96000, tyOffsetDelta = 25, tyScale=3500, tmpFlag=""

var showHelp=1, helpMsg="text e 0 0 SPACE\\-\\g1e\\g1f\\g11\\g10\\-m\\-ph 1,88", msg=helpMsg

while(true) {
	outString="fbox 0 0 0 0,0,3320,95"

	/* 6 step process:
		1. Draw 45 versions of the same plane adding 4 degrees rotation per image, doing a full 180 in the offscreen buffer
		2. Draw scaled spiral image
		3. Construct each line of twist by picking from the 45 versions (based on sinus curves) on offscreen buffer, with color based on rotation
		4. Copy mirrored twister on top of spiral image with transparent color 0 and modified palette
		5. Copy original twister on top of it all with transparent color 0.
		6. Draw final image, increase spiral animation frame, scroll texture offset */
		
	var xp=240, cry=0
	for (i = 0; i < 45; i++) {
		outString += "& 3d objects/plane-twist-h.obj " + drawmode + ",-1,0," + tyOffset + ",100000," + tyScale + " 0," + cry + ",0 0,0,0 100,300,1,0,0,0 0,0,0,1 " + xp + "," + yp + "," + dist + ",0.66 0 0 db"
		cry+=15, xp+=60
	}

	outString += "& image img/spiral/" + imgcd + ".txt 8 0 0 -1 0,0 0 0 " + w + "," + 92 

	sx=orgsx, sr=orgsr
	for (i = 0; i < 95; i++) {
		xi=23 + Math.floor(Math.cos(sr) * 17) + Math.floor(Math.cos(cc) * 5), xp=210+xi*60, nxp=3000+45 + Math.floor(Math.cos(sx) * 25) + Math.floor(Math.sin(sx2) * 20), sx+=0.03, sr+=0.03
		//xi=23 + Math.floor(Math.cos(sr) * 8 * Math.cos(cc) * 2.7), xp=210+xi*60, nxp=3000+45 + Math.floor(Math.cos(sx) * 8 * Math.sin(sx2) * 4), sx+=0.03, sr+=0.02
		colmod = "";
		if (mode < 2) {
			if (xi < 4 || xi > 41) colmod=" -1 0 0 9?db=93b1"
			else if (xi > 17 && xi < 28) colmod=" -1 0 0 9?db=90b0"
			else if (xi > 13 && xi < 32) colmod=" -1 0 0 9?db=91b0"
			else if (xi > 10 && xi < 35) colmod=" -1 0 0 9?db=91b1"
		}
		outString += "& block 0 " + xp + "," + i + ",60,1 " + nxp + "," + i + colmod;
	}
	
	if (mode == 0 || mode == 2) outString += "& block 2 3000,0,160,95 " + mx + "," + my + " 0 " + mirror + " 0 9???=103a,1???=103a" 
	if (mode == 1) outString += "& block 2 3000,0,160,95 " + mx + "," + my + " 0 " + mirror + " 0 93b1=6eb2,91b1=e6fa,91b0=60db,90b0=60b2,9???=6eb2,1???=60b1" 
	outString += "& block 2 3000,0,160,95 0,0 0" 

	outString += "& skip text e 0 0 [FRAMECOUNT] 1,1 & " + msg 
	WScript.Echo("\"cmdgfx:" + outString + "\" F" + tmpFlag)
	tmpFlag=""

	tyOffset += tyOffsetDelta; if (tyOffset < -3700) tyOffset=96000
	
	orgsx+=0.025, orgsr+=0.05, cc+=0.031, sx2+=0.015
	
	imgc=(imgc+1)%(10 * 5), imgcd=Math.floor(imgc/5)

	var input = WScript.StdIn.ReadLine()
	var ti = input.split(" ")
	if (ti[3] == "1") {
		var key = ti[5]
		if (key == "27") break
		if (key == "100") { dist+=300; }
		if (key == "328") { tyOffsetDelta+=3; }
		if (key == "336") { tyOffsetDelta-=3; }
		if (key == "109") { mirror=1-mirror; mx=my=0; if (mirror == 0) { mx=30, my=-3 } }
		if (key == "104") { showHelp=1-showHelp; if (showHelp==0) msg=""; else msg=helpMsg }
		if (key == "331") { tyScale-=250; if (tyScale < 1000) tyScale=1000; tmpFlag="D" }
		if (key == "333") { tyScale+=250; if (tyScale > 20000) tyScale=20000; tmpFlag="D" }
		if (key == "32") { mode++; if (mode > 3) mode=0; }
		if (key == "112") WScript.Echo("\"cmdgfx: \" K")
	}
}
