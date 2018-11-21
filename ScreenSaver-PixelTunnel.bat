@if (true == false) @end /*
@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off
cd /D "%~dp0"
if defined __ goto :START
cmdwiz setfont 8 & cls
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100
cmdwiz getconsoledim sw
set /a W=%errorlevel% * 2 + 4
cmdwiz getconsoledim sh
set /a H=%errorlevel% * 2 + 10
set __=.
call %0 %* | cmdgfx_gdi "" m0OW13%TOP%Sf1:0,0,%W%,%H%
set __=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set TOP=
goto :eof

:START
cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors
mode 80,50
echo "cmdgfx: quit"
title input:Q
exit /b 0 */

function Execute(cmd) {
	var exec = Shell.Exec("cmd /c " + cmd)
	exec.StdOut.ReadAll()
	return exec.exitCode
}

function GetCmdVar(name) {
	return Execute("exit %" + name + "%")
}

var fs = new ActiveXObject("Scripting.FileSystemObject")
var Shell = new ActiveXObject("WScript.Shell")

var W=GetCmdVar('W'), H=GetCmdVar('H')
var XMID=Math.floor(W/2), YMID=Math.floor(H/2)
var DIST=2000, DRAWMODE=1
var CRX=0,CRY=0,CRZ=0, ZROT=0, NOF=25
var ASPECT=0.75
var DEG2RAD=Math.PI/180

var WNAME="objects\\tunnel-circle.ply"
var OWI=1, OWV=[2, 8, 16, 32, 60]
MakeCircle(WNAME, OWV[OWI])

var ADD1=4, ADD2=2, BDIST=900+W*2, DISTADD=250
var PZ=[0], PR=[0], PRC=[0]
PrepareTunnel()

var DIVROTX=16, DIVROTY=16, SPEED=30, COLSET=0
SetColors(COLSET)

var static=0, staticskip=["skip", ""]

static=1, ZROT=1, COLSET=3, NOF=60, OWI=4; MakeCircle(WNAME, OWV[OWI]); PrepareTunnel(); SetColors(COLSET);

while (true) {
	var CRSTR="", j=jj
	
	for (i = 1; i <= NOF; i++) {
		XP=Math.floor(Math.sin(PR[j]*DEG2RAD)*((PZ[j]+BDIST)/DIVROTX))
		YP=Math.floor(Math.sin(PRC[j]*DEG2RAD)*((PZ[j]+BDIST)/DIVROTY))
		PZ[j]-=SPEED
		PR[j]+=ADD1, PRC[j]+=ADD2
		C=Math.floor((PZ[j]+BDIST)/COLDIV) ; if (C < 0) C=0
	
		CRSTR = CRSTR + " & 3d " + WNAME + " " + DRAWMODE + ",0 0,0," + CRZ + " 0,0,0 1,1,1," + XP + "," + YP + "," + PZ[j] + " 0,0,0,10 " + XMID + "," + YMID + "," + DIST + "," + ASPECT + " " + COL[C]
	  
		if (PZ[j] < -BDIST) { PZ[j]=DISTMAX, PR[j]+=NOF*ADD1, PRC[j]+=NOF*ADD2; jj+=1; if (jj > NOF) jj=1 }
		j-=1; if (j < 1) j=NOF
	}
	
	WScript.Echo("\"cmdgfx: fbox " + BGC + " 20 0,0," + W + "," + H + " & " + staticskip[static] + " block 0 0,0," + W + "," + H + " 0,0 -1 0 0 " + " 3???=1004,2???=302e,????=1020 random()*12" + " & " + CRSTR + " \"" + " f1:0,0," + W + "," + H)
	
	if (fs.FileExists("EL.dat")) {
		iStream = fs.OpenTextFile("EL.dat", 1, false)
		winData = iStream.ReadLine()
		iStream.Close()
		fs.DeleteFile("EL.dat")
		EL = Number(winData)
		key = EL >> 22
		if (key == 112) { Execute("cmdwiz getch"); key=0 }
		if (key != 0) break;
		if ((EL & 1) == 1) break; // mouse event
	}

	CRZ+=ZROT
}

function SetColors(colindex) {
	if (colindex == 0) { BGC="8 0"; COL=["f 0 04", "f 0 04", "f 0 .", "f 0 .", "7 0 .", "7 0 .", "8 0 .", "8 0 .", "8 0 .", "8 0 fa"]; }
	if (colindex == 1) { BGC="1 0"; COL=["f 0 04", "f 0 04", "b 0 .", "b 0 .", "9 0 .", "9 0 .", "1 0 .", "1 0 .", "1 0 .", "1 0 fa"]; }
	if (colindex == 2) { BGC="9 0"; COL=["f 0 db", "f b b1", "b 0 02", "b 0 04", "b 0 .", "9 0 .", "9 0 .", "1 0 .", "1 0 fa", "1 0 fa"]; }
	if (colindex == 3) { BGC="5 0"; COL=["f d b2", "f d 02", "d 0 04", "d 0 07", "d 0 .", "5 0 .", "5 0 .", "5 0 .", "5 0 .", "5 0 fa"]; }
}

function MakeCircle(fname, OW) {
	var MUL=147, OUTP="", CNT=0
	var CNTV=Math.floor(360/OW) + 1;

	var f1 = fs.OpenTextFile(fname, 2, true) // 2=ForWriting
	f1.WriteLine("ply\nformat ascii 1.0\nelement vertex " + CNTV + "\nelement face " + CNTV + "\nend_header\n")

	for (j = 0; j <= 360; j+=OW) { XPOS=Math.sin(j*DEG2RAD)*MUL; YPOS=Math.sin((j+90)*DEG2RAD)*MUL; OUTP=OUTP + Math.floor(XPOS) + " " + Math.floor(YPOS) + " 0\n"; }
	for (j = 0; j <= 360; j+=OW) { OUTP=OUTP + "1 " + CNT + "\n"; CNT++; }
	f1.WriteLine(OUTP)
	f1.close()
}

function PrepareTunnel() {
	CDIST=-BDIST
	for (j = 1; j <= NOF; j++) {
		PZ[j] = CDIST
		CDIST += DISTADD
		PR[j] = j * ADD1
		PRC[j] = j * ADD2
	}
	DISTMAX=CDIST
	COLDIV=Math.floor((DISTMAX+BDIST)/10)
	jj = NOF;
}
