@if (true == false) @end /*
@echo off
cmdwiz setfont 6 & cls & title Cmd runner
cmdwiz showcursor 0

if defined __ goto :START
set __=.
cmdgfx_input.exe m0unW14xR | call %0 %* | cmdgfx_RGB_32 "" Sfa:0,0,180,110t4
set __=
goto :eof

:START
setlocal EnableDelayedExpansion
set /a W=180, H=110
set /a F6W=W/2, F6H=H/2
mode %F6W%,%F6H%

cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w & set WINW=!errorlevel!
cmdwiz getwindowbounds h & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2, WPY=%SH%/2-%WINH%/2-20
cmdwiz setwindowpos %WPX% %WPY%

call prepareScale.bat 0

cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors

mode 80,50
echo "cmdgfx: quit"
title input:Q
endlocal
exit /b 0 */

var fs = new ActiveXObject("Scripting.FileSystemObject")
var shell = new ActiveXObject("WScript.Shell")

function Execute(cmd) {
	var exec = shell.Exec("cmd /c " + cmd)
	exec.StdOut.ReadAll()
	return exec.exitCode
}
function GetCmdVar(name) {
	return Execute("exit %" + name + "%")
}

var W=GetCmdVar("W")+1, H=GetCmdVar("H")+1, rW=GetCmdVar("rW"), rH=GetCmdVar("rH")
var RY=0, XMID=W/2, YMID=H/2-53
var DIST=2500, ASPECT=1
var DRAWMODE=0, GROUNDCOL=3, PLYCHAR="."
var ZVAL=500, LOGOX=28, TEXTX=80, NIGHTY=22

var MAXCUBES=30
var SHADOW=true
var NIGHTSKIP=""
var NIGHT=false
var USENIGHT=true

var TOP=""
var SCRW=Execute('cmdwiz getdisplaydim w');
var SCRH=Execute('cmdwiz getdisplaydim h');
var FONTW=1, FONTH=1

var HISCORE=0
var inputfile = "hiscore.dat";
if (fs.FileExists(inputfile))
{
	var f1 = fs.OpenTextFile(inputfile, 1)  // 1=ForReading
	HISCORE = parseInt(f1.ReadLine())
	f1.close()
}
var cubecols = [
	["red1", "yel1", "green1", "purp1"],
	["red2", "yel2", "green2", "purp2"],
	["red3", "yel3", "green3", "purp3"]
];
var shadowcols = ["shad1","shad2","shad3"];
var nightcols =  ["a 0 . ","a 0 . ","2 0 ."];

shell.Exec("cmd /c dlc.exe -p paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3 paparazzi.mp3");
Resize(180/2,110/2);

do {
	var NOFCUBES=15, SCORE=0, NIGHTCNT=0, TILT=0, ACTIVECUBES=0, NIGHT=false, NIGHTSKIP="", DRAWMODE=0, ACCSPEED=270

	var CURRZ=30000
	var ACZ=CURRZ/MAXCUBES

	var PX=[0], PY=[0], PZ=[0], CPAL=[0], HGHT=[0], YP=[0], ACT=[0]
	
	for (j = 1; j <= MAXCUBES; j++) {
		CURRZ-=ACZ; PZ.push(CURRZ + Math.floor(Math.random() * ACZ)); PX.push(Math.floor(Math.random() * 8000) - 4000); CPAL.push(Math.floor(Math.random() * 4)); HGHT.push(Math.floor(Math.random() * 400) + 250); PY.push(-1800+(HGHT[j]-250)); ACT.push(0);
	}

	var STARTINDEX=1
	shell.Exec("cmd /c title input:W14");

	var stop=0, death=0
	
	while (stop == 0) {
		//BKSTR = "fbox 0 0 db" // // 86 vs 58 FPS fullscreen (101 fps if no fbox at all). (315 FPS with no bg no 3d, 100 FPS with NO 3d objects just stretched image)
		WScript.Echo("\"cmdgfx: " + BKSTR + "\" n")

		if (!NIGHT && SHADOW)
			for (I = 1; I <= MAXCUBES; I++) {
				var COLD=Math.floor((PZ[I]-5000)/10500); if (COLD < 0) COLD=0
				WScript.Echo("\"cmdgfx: 3d RGB/obj/" + shadowcols[COLD] + ".obj " + DRAWMODE + ",-1 0," + (RY) + ",0 " + PX[I] + "," + (PY[I]-HGHT[I]-20) + "," + PZ[I] + "  -450,-10,-450,0,0,0 0,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " " + "0 0 ." +"\" n'")
			}

		I=STARTINDEX-1
		for (j = 1; j <= MAXCUBES; j++) {
			I++
			if (I > MAXCUBES) I=1;
			var COLD=Math.floor((PZ[I]-5000)/10500); if (COLD < 0) COLD=0
			WScript.Echo("\"cmdgfx: 3d RGB/obj/" + cubecols[COLD][CPAL[I]] + ".obj " + DRAWMODE + ",-1 0," + RY + ",0 " + PX[I] + ","+PY[I]+"," + PZ[I] + "  250,"+(-HGHT[I])+",-250,0,0,0 1,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " " + "0 0 ." +"\" n")

			// fog attempt
			//if (j==Math.floor(MAXCUBES/5) || j==Math.floor(MAXCUBES/5)*2) WScript.Echo("\"cmdgfx: ipoly 60222266 0 db 20 0,0,"+W+",0,"+W+","+H+",0,"+H+"\" n")
			
			PZ[j]-=ACCSPEED
			if (PZ[I] < 1000) {
				PZ[I]=30000
				PX[I]=Math.floor(Math.random() * 8000) - 4000
				STARTINDEX-=1; if (STARTINDEX < 1) STARTINDEX=MAXCUBES
			}
		}

		WScript.Echo("\"cmdgfx: image CR2.gxy 0 0 0 20 "+LOGOX+",2 & text f 1 0 _Press_SPACE_to_play_ "+TEXTX+",15 0 & skip text e 1 0 [FRAMECOUNT] 5,5 0 \" Z"+ZVAL+"fa:0,0,"+W+","+H+TOP)

		var input = WScript.StdIn.ReadLine()
		var ti = input.split(/\s+/) // input.split(" ") splits "a  a" into 3 tokens (one empty middle). Using regexp for "consume n spaces between each token", because cmdgfx_input uses double spaces to separate data sections

		if (ti[3] == "1")
		{
			var key=ti[5]
			if (key == "27") { stop=2 }
			if (key == "32") { stop=1 }
			if (key == "10") { ForceLegacyFullscreen(); }
		}
		
		if (ti[23] == "1") {
			Resize(ti[25],ti[27]);
		}
			
		RY+=8
	}


	var deadcnt=0, DEADSKIP=""
	if (stop <= 1) {
		stop=0, death=0
		shell.Exec("cmd /c title input:W15"); 
		var ACTIVE_KEY=0
		
		while (stop == 0) {
			BKNSTR=BKSTR; if (NIGHT) BKNSTR="fbox 0 0 db & line 2 0 = 0,"+NIGHTY+","+W+","+NIGHTY+" "
			WScript.Echo("\"cmdgfx: " + BKNSTR + "\" n")

			if (!NIGHT && SHADOW)
				for (I = 1; I <= MAXCUBES; I++) {
					var COLD=Math.floor((PZ[I]-5000)/10500); if (COLD < 0) COLD=0
					if (ACT[I] == 1) WScript.Echo("\"cmdgfx: 3d RGB/obj/" + shadowcols[COLD] + ".obj " + DRAWMODE + ",-1 0," + (RY) + ",0 " + PX[I] + "," + (PY[I]-HGHT[I]-20) + "," + PZ[I] + "  -450,-10,-450,0,0,0 0,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " " + "0 0 ." +"\" n'")
				}
			
			I=STARTINDEX-1
			for (j = 1; j <= MAXCUBES; j++) {
				I++
				if (I > MAXCUBES) I=1;
			
				if (ACT[I] == 1 && PZ[I] < 4000 && PZ[I] > 3500 && PX[I] > -300 && PX[I] < 300) death=1

				var COLD=Math.floor((PZ[I]-5000)/10500); if (COLD < 0) COLD=0
				var COLS=cubecols[COLD][CPAL[I]]; if (NIGHT) COLS=nightcols[COLD];
				if (NIGHT) {
					if (ACT[I] == 1) WScript.Echo("\"cmdgfx: 3d cube.ply " + DRAWMODE + ",-1 0," + RY + ",0 " + PX[I] + ","+PY[I]+"," + PZ[I] + "  250,"+(-HGHT[I])+",-250,0,0,0 0,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " " + COLS + "\" n")
				} else {
					if (ACT[I] == 1) WScript.Echo("\"cmdgfx: 3d RGB/obj/" + COLS + ".obj " + DRAWMODE + ",-1 0," + RY + ",0 " + PX[I] + ","+PY[I]+"," + PZ[I] + "  250,"+(-HGHT[I])+",-250,0,0,0 1,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " " + "0 0 ." + "\" n")
				}
				
				PZ[I]-=ACCSPEED
				if (PZ[I] < 1000) {
					PZ[I]=30000
					PX[I]=Math.floor(Math.random() * 8000) - 4000 - TILT*50
					if (ACTIVECUBES <= NOFCUBES && ACT[I] == 0 && Math.random() < 0.3333) { ACT[I]=1; ACTIVECUBES+=1; }
					STARTINDEX-=1; if (STARTINDEX < 1) STARTINDEX=MAXCUBES
				}
			}

			PLS1=" f ",PLS2=" 7 "; if (NIGHT) PLS1=" a ",PLS2=" 2 ";
			WScript.Echo("\"cmdgfx: 3d tetramod.ply " + 0 + ",-1 0,180," + TILT + " 0,-1800,4000 -50,-50,-50,0,0,0 1,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + PLS1 + GROUNDCOL + " " + PLYCHAR + PLS2 + GROUNDCOL + " " + PLYCHAR + " & " + NIGHTSKIP + DEADSKIP + " 3d tetramod.ply " + DRAWMODE + ",-1 0,180," + TILT + " 0,-1900,4000 -50,-50,-50,0,0,0 1,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " 003535 0 . & text 7 1 0 SCORE:_" + SCORE + "_(" + HISCORE + ") 2,1 0 \" Z"+ZVAL+"fa:0,0,"+W+","+H+TOP)

			if (death==1) {
				deadcnt++; if (deadcnt==40) stop = 1
				ACCSPEED=0, TILT+=40, DEADSKIP="skip "
			}

			var input = WScript.StdIn.ReadLine()
			var ti = input.split(/\s+/)
			var key = ti[5]
			if (ti[3] == "1" && death==0)
			{
				if (key == "27") stop=1
				if (key == "10") { ForceLegacyFullscreen(); }
				if (key == "331") ACTIVE_KEY=331
				if (key == "333") ACTIVE_KEY=333
			} else {
				if (key == "331" || key == "333") ACTIVE_KEY=0
			}
			if (ti[23] == "1") {
				Resize(ti[25],ti[27]);
			}
			
			if (death==0) {
				NOFCUBES = 15 + Math.floor(SCORE/250)
				if (NOFCUBES > MAXCUBES) NOFCUBES=MAXCUBES
				
				if (TILT > 0) TILT-=1
				if (TILT < 0) TILT+=1

				if (ACTIVE_KEY==331) { TILT+=4; if (TILT > 55) TILT=55 }
				if (ACTIVE_KEY==333) { TILT-=4; if (TILT <-55) TILT=-55 }

				if (TILT != 0) for (j = 1; j <= MAXCUBES; j++) PX[j]+=TILT
				
				RY+=8, SCORE+=1, NIGHTCNT+=1
				if (USENIGHT && NIGHTCNT >= 2000 && !NIGHT) { NIGHTCNT=0, NIGHT=true, NIGHTSKIP="skip ", DRAWMODE=3 }
				if (USENIGHT && NIGHTCNT >= 1000 && NIGHT) { NIGHTCNT=0, NIGHT=false, NIGHTSKIP="", DRAWMODE=0 }
				if (SCORE > HISCORE) HISCORE = SCORE
			}
		}

		f1 = fs.OpenTextFile(inputfile, 2, true)  // 2=ForWriting
		f1.WriteLine(HISCORE + "")
		f1.close()
	}

} while (stop <= 1)

shell.Exec("cmd /c taskkill.exe /F /IM dlc.exe>nul")

function Resize(XRes, YRes) {
	shell.Exec('cmdwiz showcursor 0')
	W=Math.floor((Number(XRes)+1)*2*4*rW/100), H=Math.floor((Number(YRes)+1)*2*6*rH/100)+1
	if (TOP=="U") { W=Math.floor(SCRW/FONTW); if (FONTW>1) W+=1; H=Math.floor(SCRH/FONTH); if (FONTH>1) H+=1; }
	YMDIV=2.1; if (H<110*4) YMDIV=2
	XMID=Math.floor(W/2), YMID=Math.floor(H/2)-52-Math.floor((H-110)/YMDIV)
	ZMUL=2.7; if (H<110*4) ZMUL=2.3
	ZVAL=500+Math.floor((H-110)*ZMUL)
	BKSTR="image bgshade-RGB.bmp 0 0 0 -1 0,0 0 0 "+(W+2)+","+(H+10)+" "
	//BKSTR="image bgshade-pixel.gxy 0 0 0 -1 0,0 0 0 "+(W+2)+","+(H+10)+" "
	//BKSTR="fbox 0 0 ."
	LOGOX=Math.floor(W/2)-62
	TEXTX=Math.floor(W/2)-10*4
	NIGHTY=Math.floor(H*0.2)
}

function Execute(cmd) {
	var exec = shell.Exec("cmd /c " + cmd)
	exec.StdOut.ReadAll()
	return exec.exitCode
}

function ForceLegacyFullscreen() {
	exitCode=Execute('cmdwiz getfullscreen');
	if (exitCode==0) {
		cmdwo=Execute('cmdwiz getconsoledim sw'); cmdho=Execute('cmdwiz getconsoledim sh'); cmdxo=Execute('cmdwiz getwindowbounds x'); cmdyo=Execute('cmdwiz getwindowbounds y');
		res=Execute('cmdwiz fullscreen 1');
		if (res < 0) TOP="U"; // had to use legacy mode
	} else {
		shell.Exec('cmdwiz fullscreen 0')
		if (TOP=="U") { shell.Exec('cmd /c mode ' + cmdwo + ',' + cmdho); shell.Exec('cmdwiz setwindowpos ' + cmdxo + ' ' + cmdyo); TOP="-U" }
	}
}
