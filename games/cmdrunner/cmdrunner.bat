@if (true == false) @end /*
@echo off
cmdwiz setfont 6 & cls & title Cmd runner
cmdwiz showcursor 0

if defined __ goto :START
set __=.
cmdgfx_input.exe m0unW14x | call %0 %* | cmdgfx_gdi "" Sf0:0,0,180,110W0Bs
set __=
cmdwiz setwindowstyle set standard 0x00010000L
cmdwiz setwindowstyle set standard 0x00040000L
goto :eof

:START
setlocal EnableDelayedExpansion
cmdwiz setwindowstyle clear standard 0x00010000L
cmdwiz setwindowstyle clear standard 0x00040000L
set /a F6W=180/2, F6H=110/2
mode %F6W%,%F6H%

cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w & set WINW=!errorlevel!
cmdwiz getwindowbounds h & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2, WPY=%SH%/2-%WINH%/2-20
cmdwiz setwindowpos %WPX% %WPY%

cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors

mode 80,50
echo "cmdgfx: quit"
title input:Q
endlocal
exit /b 0 */


var W=180, H=110, RY=0
var XMID=W/2, YMID=H/2-53
var DIST=2500, ASPECT=0.6925
var DRAWMODE=0, GROUNDCOL=3, PLYCHAR="db"

var MAXCUBES=30

var fs = new ActiveXObject("Scripting.FileSystemObject")
var shell = new ActiveXObject("WScript.Shell")

var HISCORE=0
var inputfile = "hiscore.dat";
if (fs.FileExists(inputfile))
{
	var f1 = fs.OpenTextFile(inputfile, 1)  // 1=ForReading
	HISCORE = parseInt(f1.ReadLine())
	f1.close()
}

var cubecols = [
	["4 c db 4 c db  4 c b1  4 c b1  4 c 20", "6 0 db 6 0 db  6 e b1  6 e b1  6 e 20", "2 a db 2 a db  2 a b1  2 a b1  2 a 20", "5 d db 5 d db  5 d b1  5 d b1  5 d 20"],
	["4 1 b2 4 1 b2  4 c b2  4 c b2  0 c b1", "6 1 b2 6 1 b2  6 e b2  6 e b2  0 e b1", "2 1 b2 2 1 b2  2 a b2  2 a b2  0 a b1", "5 1 b2 5 1 b2  5 d b2  5 d b2  0 d b1"],
	["4 0 b0 4 0 b0  4 0 b1  4 0 b1  4 0 b2", "6 0 b0 6 0 b0  6 0 b1  6 0 b1  6 0 b2", "2 0 b0 2 0 b0  2 0 b1  2 0 b1  2 0 b2", "5 0 b0 5 0 b0  5 0 b1  5 0 b1  5 0 b2"]
];

shell.Exec("cmd /c dlc.exe -p paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3");


do {
	var NOFCUBES=15, SCORE=0, TILT=0, ACTIVECUBES=0, ACCSPEED=270

	var CURRZ=30000
	var ACZ=CURRZ/MAXCUBES

	var PX=[0], PY=[0], PZ=[0], CPAL=[0]
	for (j = 1; j <= MAXCUBES; j++) {
		CURRZ-=ACZ; PZ.push(CURRZ + Math.floor(Math.random() * ACZ)); PX.push(Math.floor(Math.random() * 8000) - 4000); PY.push(-18000); CPAL.push(Math.floor(Math.random() * 4));
	}

	shell.Exec("cmd /c title input:W14"); 

	var BKSTR="fbox 0 1 b1 0,0," + W + ",10 & fbox 0 1 20 0,10," + W + ",5 & fbox 9 1 b1 0,15," + W + ",5 & fbox 9 1 db 0,19," + W + ",1  &  fbox 0 0 20 0,21," + W + ",5 & fbox 0 " + GROUNDCOL + " b2 0,23," + W + ",5 & fbox 0 " + GROUNDCOL + " b1 0,27," + W + ",10 & fbox 0 " + GROUNDCOL + " b0 0,34," + W + ",22 & fbox 8 " + GROUNDCOL + " 20 0,50," + W + ",100 "
	var stop=0, death=0

	while (stop == 0) {
		WScript.Echo("\"cmdgfx: " + BKSTR + "\" n")

		for (I = 1; I <= MAXCUBES; I++) {
			var COLD=Math.floor((PZ[I]-5000)/10500); if (COLD < 0) COLD=0
			WScript.Echo("\"cmdgfx: 3d cube.ply " + DRAWMODE + ",-1 0," + RY + ",0 " + PX[I] + ",-1800," + PZ[I] + "  -250,-250,-250,0,0,0 0,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " " + cubecols[COLD][CPAL[I]] + "\" ns")

			PZ[I]-=ACCSPEED
			if (PZ[I] < 1000) {
				PZ[I]=30000
				PX[I]=Math.floor(Math.random() * 8000) - 4000
			}
		}
		
		WScript.Echo("\"cmdgfx: image CR2.gxy 0 0 0 20 28,2 & text f 1 0 _Press_SPACE_to_play_ 80,15\"")

		var input = WScript.StdIn.ReadLine()
		var ti = input.split(" ")
		if (ti[3] == "1")
		{
			var key=ti[5]
			if (key == "27") {
				stop=2
			}
			if (key == "32") {
				stop=1
			}
		}
		RY+=8
	}

	var deadcnt=0, DEADSKIP=""
	if (stop <= 1) {
		stop=0, death=0
		shell.Exec("cmd /c title input:W15"); 
		var ACTIVE_KEY=0
		
		while (stop == 0) {
			WScript.Echo("\"cmdgfx: " + BKSTR + "\" n")
			
			for (I = 1; I <= MAXCUBES; I++) {
			
				if (PY[I] > -15000 && PZ[I] < 4000 && PZ[I] > 3500 && PX[I] > -300 && PX[I] < 300) death=1

				var COLD=Math.floor((PZ[I]-5000)/10500); if (COLD < 0) COLD=0
				WScript.Echo("\"cmdgfx: 3d cube.ply " + DRAWMODE + ",-1 0," + RY + ",0 " + PX[I] + "," + PY[I] + "," + PZ[I] + "  -250,-250,-250,0,0,0 0,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " " + cubecols[COLD][CPAL[I]] + "\" ns")

				PZ[I]-=ACCSPEED
				if (PZ[I] < 1000) {
					PZ[I]=30000
					PX[I]=Math.floor(Math.random() * 8000) - 4000 - TILT*50
					if (ACTIVECUBES <= NOFCUBES && PY[I] < -1800 && Math.random() < 0.3333) { PY[I]=-1800; ACTIVECUBES+=1; }
				}
			}

			WScript.Echo("\"cmdgfx: 3d tetramod.ply " + DRAWMODE + ",-1 0,180," + TILT + " 0,-1800,4000 -50,-50,-50,0,0,0 1,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " f " + GROUNDCOL + " " + PLYCHAR + " 7 " + GROUNDCOL + " " + PLYCHAR + " & " + DEADSKIP + "3d tetramod.ply " + DRAWMODE + ",-1 0,180," + TILT + " 0,-1900,4000 -50,-50,-50,0,0,0 1,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " 0 " + GROUNDCOL + " b2 0 " + GROUNDCOL + " b2 & text 7 1 0 SCORE:_" + SCORE + "_(" + HISCORE + ") 2,1  \" -s")

			if (death==1) {
				deadcnt++; if (deadcnt==40) stop = 1
				ACCSPEED=0, TILT+=40, DEADSKIP="skip "
			}

			var input = WScript.StdIn.ReadLine()
			var ti = input.split(" ")
			var key = ti[5]
			if (ti[3] == "1" && death==0)
			{
				if (key == "27") stop=1
				if (key == "331") ACTIVE_KEY=331
				if (key == "333") ACTIVE_KEY=333
			} else {
				if (key == "331" || key == "333") ACTIVE_KEY=0
			}

			if (death==0) {
				NOFCUBES = 15 + Math.floor(SCORE/250)
				if (NOFCUBES > MAXCUBES) NOFCUBES=MAXCUBES
				
				if (TILT > 0) TILT-=1
				if (TILT < 0) TILT+=1

				if (ACTIVE_KEY==331) TILT+=4; if (TILT > 55) TILT=55
				if (ACTIVE_KEY==333) TILT-=4; if (TILT <-55) TILT=-55

				if (TILT != 0) for (j = 1; j <= MAXCUBES; j++) PX[j]+=TILT
				
				RY+=8, SCORE+=1
				if (SCORE > HISCORE) HISCORE = SCORE
			}
		}

		f1 = fs.OpenTextFile(inputfile, 2, true)  // 2=ForWriting
		f1.WriteLine(HISCORE + "")
		f1.close()
	}

} while (stop <= 1)

shell.Exec("cmd /c taskkill.exe /F /IM dlc.exe>nul")
