@if (true == false) @end /*
@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off
cd /D "%~dp0"
if defined __ goto :START
cmdwiz setfont 2 & cls
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%/8+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/8+1
set /a HH=H*2

set __=.
call %0 %* | cmdgfx_RGB "" m0O%TOP%Sf2:0,0,%W%,%HH%,%W%,%H%t5
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
var HH=H*2
WScript.Echo("\"cmdgfx: fbox 0 0 db \"")

MOD=35, MOD2=Math.floor(MOD/2)
SEED=0; COLI=0; setColFade(COLI); YD=12

while(true) {

	WScript.Echo("\"cmdgfx: fbox 0 0 b1 " + 0 + "," + (H+10) + "," + W + ",65 \" nf2:0,0,"+W+","+HH+","+W+","+H)

	if (SEED==0) {
		for (i = 0; i < 8; i++) { X=GetRandom(W), J=GetRandom(10)+(H), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; WScript.Echo("\"cmdgfx: line ffffff 0 b1 " + X + "," + J + "," + X2 + "," + J2 + "\" n") }
		for (i = 0; i < 7; i++) { X=GetRandom(W), J=GetRandom(10)+(H), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; WScript.Echo("\"cmdgfx: line d0d080 0 b1 " + X + "," + J + "," + X2 + "," + J2 + "\" n") }
	}  else {
		WScript.Echo("\"cmdgfx: block 0 0,"+(H+4)+","+W+",1 0,"+(H+4)+" -1 0 0 - store(floor(random()*2)*255,0)+makecol(s0,s0,s0) \" n");
	}
	
	WScript.Echo("\"cmdgfx: block 0 0,0,"+W+","+(H+YD)+" 0,0 -1 0 0 - store(fgcol(x,y+1),0)+store(fgcol(x-1,y+1),1)+store(fgcol(x+1,y+1),2)+store(fgcol(x,y+2),3)+makecol((fgr(s0)+fgr(s1)+fgr(s2)+fgr(s3))/"+RD+",(fgg(s0)+fgg(s1)+fgg(s2)+fgg(s3))/"+GD+",(fgb(s0)+fgb(s1)+fgb(s2)+fgb(s3))/"+BD+")\" ")

	if (fs.FileExists("EL.dat")) {
		iStream = fs.OpenTextFile("EL.dat", 1, false)
		winData = iStream.ReadLine()
		iStream.Close()
		fs.DeleteFile("EL.dat")
		EL = Number(winData)
		key = EL >> 22
		if (key == 112) { Execute("cmdwiz getch"); key=0 }
		if (key == 32) { key=0; COLI++; if (COLI >= 3) COLI=0; setColFade(COLI); }
		if (key != 0) break;
		if ((EL & 1) == 1) break; // mouse event
	}
}

function GetRandom(maxN) {
	return Math.floor(Math.random() * maxN)
}

function setColFade(index) {
	if (index == 0) { RD=2, GD=2.05, BD=2.2 }
	if (index == 1) { RD=2.1, GD=2, BD=2.05 }
	if (index == 2) { RD=2.2, GD=2.05, BD=2 }
	RD+=2; GD+=2; BD+=2;
}
