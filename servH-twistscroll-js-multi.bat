@if (true == false) @end /*
@echo off
if defined __ goto :START
cmdwiz showcursor 0 
set __=.
cmdgfx_input.exe knW13x | call %0 %* | cmdgfx_gdi "" SZ300f0:0,0,3320,95,160,90
set __=
goto :eof

:START
cmdwiz setfont 6 & cls & mode 80,45 & cmdwiz showcursor 0 

call centerwindow.bat 0 -20

cscript //nologo //e:javascript "%~dpnx0" %*
rem cmdwiz getch & rem Enable this line to see jscript parse errors

echo "cmdgfx: quit"
title input:Q
mode 80,50 & cmdgfx_gdi ""
exit /b 0 */


var w=160, h=90, xmid=w/2, ymid=h/2, yp=ymid + 3
var dist=12000, drawmode=5

var orgsx=0.0, orgsr=0.0, cc=2.0, sx2=3.0
var imgc=0, imgcd=0, tyOffset=-17000

while(true) {
	outString="fbox 0 0 0 0,0,3320,95"

	/* 6 step process:
		1. Draw 45 versions of the same plane adding 4 degrees rotation per image, doing a full 180 on the offscreen buffer
		2. Draw spiral image
		3. Construct each line of twist1 by picking from the 45 versions (based on sinus curves) on offscreen buffer
		4. Construct each line of twist2 by picking from the 45 versions (based on sinus curves) on offscreen buffer
		5. Copy the two twisters on top of spiral image with transparent color 0
		6. Draw final image, scroll texture offset */
		
	var xp=240, cry=0
	for (i = 0; i < 45; i++) {
		outString += "& 3d objects/plane-twist.obj " + drawmode + ",-1,0," + tyOffset + ",100000,15000 0," + cry + ",0 0,0,0 110,300,1,0,0,0 0,0,0,1 " + xp + "," + yp + "," + dist + ",0.66 0 0 db"
		cry+=15, xp+=60
	}

	outString += "& image img/spiral/" + imgcd + ".txt 8 0 0 -1 0,0 0 0 " + w + "," + 92 

	sx=orgsx, sr=orgsr
	for (i = 0; i < 95; i++) {
		xi=23 + Math.floor(Math.sin(sr) * 17) + Math.floor(Math.sin(cc) * 5), xp=210+xi*60, nxp=3000+55 + Math.floor(Math.sin(sx) * 25) + Math.floor(Math.sin(sx2) * 20), sx+=0.01, sr+=0.03
		outString += "& block 0 " + xp + "," + i + ",60,1 " + nxp + "," + i;
	}

	sx=orgsx, sr=orgsr
	for (i = 0; i < 95; i++) {
		xi=23 + Math.floor(Math.cos(sr) * 17) + Math.floor(Math.cos(cc) * 5), xp=210+xi*60, nxp=3160+45 + Math.floor(Math.cos(sx) * 25) + Math.floor(Math.sin(sx2) * 20), sx+=0.03, sr+=0.02
		/* colmod = "";
		if (xi > 12 && xi < 33) colmod=" -1 0 0 9?db=91b0"
		if (xi > 17 && xi < 28) colmod=" -1 0 0 9?db=90b0"
		if (xi < 4 || xi > 41) colmod=" -1 0 0 9?db=93b1" */
		outString += "& block 0 " + xp + "," + (i+4) + ",60,1 " + nxp + "," + i; // + colmod;
	}

	outString += "& block 2 3000,0,160,95 0,0 0 0 0 9???=103a,1???=103a" 
	
	outString += "& block 2 3160,0,160,95 0,0 0" 

	outString += "&  text e 0 0 [FRAMECOUNT] 1,1" 
	WScript.Echo("\"cmdgfx:" + outString + "\" F")

	tyOffset += 100
	
	orgsx+=0.025, orgsr+=0.05, cc+=0.031, sx2+=0.015
	
	imgc=(imgc+1)%(10 * 5), imgcd=Math.floor(imgc/5)

	var input = WScript.StdIn.ReadLine()
	var ti = input.split(" ")
	if (ti[3] == "1") {
		var key = ti[5]
		if (key == "27") break
		if (key == "112") WScript.Echo("\"cmdgfx: \" K")
	}
}
