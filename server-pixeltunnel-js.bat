@if (true == false) @end /*
@echo off
cmdwiz setfont 8 & cls
set /a F8W=160/2, F8H=80/2
mode %F8W%,%F8H%
cmdwiz showcursor 0 & title Pixel tunnel
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,160,80
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F8W=&set F8H=
goto :eof

:START
call centerwindow.bat 0 -20
cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors
mode 80,50
echo "cmdgfx: quit"
title input:Q
exit /b 0 */

var fs = new ActiveXObject("Scripting.FileSystemObject")
var Shell = new ActiveXObject("WScript.Shell")

var W=160, H=80
var XMID=Math.floor(W/2), YMID=Math.floor(H/2)
var DIST=2000, DRAWMODE=1
var CRX=0,CRY=0,CRZ=0, ZROT=0
var ASPECT=0.75
var DEG2RAD=Math.PI/180
var NOF=25

var WNAME="objects\\tunnel-circle.ply"
var OWI=1, OWV=[2, 8, 16, 32, 60]
MakeCircle(WNAME, OWV[OWI])

var ADD1=4, ADD2=2, BDIST=1200, DISTADD=250
var PZ=[0], PR=[0], PRC=[0]
PrepareTunnel()

var DIVROTX=16, DIVROTY=16, SPEED=30, COLSET=0
SetColors(COLSET)

var SHOWHELP=1
var HELPMSG="text 7 0 0 SPACE\\-ENTER\\-\\g11\\g10\\g1e\\g1f\\-Z/z\\-X/x\\-Y/y\\-s\\-p\\-h 1,78"
var MSG=""; if (SHOWHELP==1) MSG=HELPMSG
var static=0, staticskip=["skip", ""]

// set actually wanted start values
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
	
	//WScript.Echo("\"cmdgfx: fbox " + BGC + " 20 0,0," + W + "," + H + " & " + CRSTR + " & " + MSG + "\"")
	//WScript.Echo("\"cmdgfx: block 0 0,0," + W + "," + H + " 0,0 -1 0 0 " + "f004=f02e,f02e=702e,702e=802e,802e=80fa,????=0000" + " & " + CRSTR + " & " + MSG + "\"")
	WScript.Echo("\"cmdgfx: fbox " + BGC + " 20 0,0," + W + "," + H + " & " + staticskip[static] + " block 0 0,0," + W + "," + H + " 0,0 -1 0 0 " + " 3???=1004,2???=302e,????=1020 random()*12" + " & " + CRSTR + " & " + MSG + "\"" + " f1:0,0," + W + "," + H)
	
	var input = WScript.StdIn.ReadLine()
	var ti = input.split(/\s+/) // input.split(" ") splits "a  a" into 3 tokens (one empty middle). Using regexp for "consume n spaces between each token", because cmdgfx_input uses double spaces to separate data sections
	if (ti[3] == "1")
	{
		var key=ti[5]
		if (key == "27") break;
		if (key == "10") { exec = Shell.Exec('cmdwiz getfullscreen'); exec.StdOut.ReadAll(); if (exec.exitCode==0) Shell.Exec('cmdwiz fullscreen 1'); else Shell.Exec('cmdwiz fullscreen 0') }
		if (key == "13") { OWI++; if (OWI >= OWV.length) OWI=0; MakeCircle(WNAME, OWV[OWI]); WScript.Echo("\"cmdgfx: \" D") }
		if (key == "328") { SPEED+=1; if (SPEED > 100) SPEED=100 }
		if (key == "336") { SPEED-=1; if (SPEED < 15) SPEED=15 }
		if (key == "120") { DIVROTX+=1; if (DIVROTX > 200) DIVROTX=200 }
		if (key == "88") { DIVROTX-=1; if (DIVROTX < 8) DIVROTX=8 }
		if (key == "121") { DIVROTY+=1; if (DIVROTY > 150) DIVROTY=150 }
		if (key == "89") { DIVROTY-=1; if (DIVROTY < 8) DIVROTY=8 }
		if (key == "90") ZROT+=1; if (ZROT > 10) ZROT=10
		if (key == "122") ZROT-=1; if (ZROT < 0) ZROT=0
		if (key == "104") { SHOWHELP=1-SHOWHELP; if (SHOWHELP==0) MSG=""; else MSG=HELPMSG }
		if (key == "32") { COLSET+=1; if (COLSET > 3) COLSET=0; SetColors(COLSET); }
		if (key == "112") WScript.Echo("\"cmdgfx: \" K")
		if (key == "331") { NOF-=5; if (NOF < 10) NOF=10; else PrepareTunnel() }
		if (key == "333") { NOF+=5; if (NOF > 70) NOF=70; else PrepareTunnel() }
		if (key == "115") { static=1-static }
	}
	
	if (ti[23] == "1")
	{
		W=Number(ti[25])*2+1, H=Number(ti[27])*2+1, XMID=Math.floor(W/2), YMID=Math.floor(H/2), HLPY=H-3
		Shell.Exec('cmdwiz showcursor 0')
		HELPMSG="text 7 0 0 SPACE\\-ENTER\\-\\g11\\g10\\g1e\\g1f\\-Z/z\\-X/x\\-Y/y\\-s\\-p\\-h 1," + HLPY
		if (SHOWHELP==1) MSG=HELPMSG
		BDIST = 900+W*2
		PrepareTunnel()
		//WScript.Echo("\n\n" + W); WScript.Echo("\"cmdgfx: \" K")
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
