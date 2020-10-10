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

set __=.
call %0 %* | cmdgfx_gdi "" %TOP%Sf2:0,0,!WW!,!HH!,!W!,!H!m0Ot6
set __=
cls & cmdwiz fullscreen 0 & cmdwiz setfont 6 & cmdwiz showcursor 1 & goto :eof

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
var WW=W*2, HH=H*2

//WScript.Echo("\"cmdgfx: fbox f 0 30 0,0,"+WW+",130 & fbox f 0 20 0,0,"+WW+",120 & fbox e 0 20 "+W+",0,"+W+",95\"")

var STREAM="1060=40++,1061=40++,1062=40++,1063=40++,1064=d0++,1065=d0++,1066=c0++,1067=a0++,1050=c0++,1051=90++,1052=a0++,1053=a0++,1054=a0++,1055=80++,1056=80++,1057=70++,1030=f0++,1031=f0++,1032=f0++,1033=f0++,1034=f0++,1035=f0++,1036=f0++,1037=f0++,1038=f0++,1039=f0++,?0??=-0??"

var TRANSF=["??50=fedb,??51=feb1,??52=ecdb,??53=ecb1,??54=c4db,??55=c4b1,??56=c4b0,??57=40b1,??58=4020,??60=feb2,??61=feb0,??62=ecb2,??63=ecb0,??64=c4db,??65=c4b2,??66=c4b0,??67=40b2,??68=40b0,00b0=4025,??30=ffdb,??31=ffb1,??32=feb2,??33=ecb0,??34=c4b0,??35=c0b1,??36=c0b0,??37=40b2,??38=40b1,??39=4025,??40=4020",
			"??50=fbdb,??51=fbb1,??52=b9db,??53=b9b1,??54=91db,??55=91b1,??56=10db,??57=10b0,??58=1020,??60=fbdb,??61=fbb1,??62=fbb0,??63=b9b2,??64=b9b0,??65=91b2,??66=91b0,??67=10b2,??68=10b0,00b0=10b0,??30=ffdb,??31=ffb1,??32=fbb2,??33=b9b2,??34=90b2,??35=90b1,??36=90b0,??37=10b2,??38=10b1,??39=10b0,??10=4020" ];

PW=1, COL=0, MODE=0

PWP=(PW+1)*3, nf1=Math.floor(W/5)-PW*5, nf2=Math.floor(W/2)-PW*10
MOD=PWP-PW, MOD2=Math.floor(MOD/2)

while(true) {

	WScript.Echo("\"cmdgfx: \" W0nf2:0,0,"+WW+","+HH+","+W+","+H)

	s = ""; for (i = 0; i < nf1; i++) { X=GetRandom(W)+W, J=GetRandom(50)+(H-1), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; s = s + "line e 0 50 " + X + "," + J + "," + X2 + "," + J2 + "& "; }
	WScript.Echo("\"cmdgfx: " + s + "\" n")

	s = ""; for (i = 0; i < nf2; i++) { X=GetRandom(W)+W, J=GetRandom(50)+(H-1), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; s = s + "line e 0 60 " + X + "," + J + "," + X2 + "," + J2 + "& "; }
	WScript.Echo("\"cmdgfx: " + s + "\" n")

	WScript.Echo("\"cmdgfx: block 0 "+W+",1,"+W+","+(H+50)+" "+W+",0 -1 0 0 "+STREAM+" & block 0 "+W+",0,"+W+","+(H+55)+" 0,-2 -1 0 0 "+TRANSF[COL]+ "\" W13")
	
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
}

function GetRandom(maxN) {
	return Math.floor(Math.random() * maxN)
}
