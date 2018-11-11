@if (true == false) @end /*
@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_gdi "" Sf2:0,0,160,150,80,75
set __=
cmdwiz showcursor 1 & goto :eof

:START
cmdwiz setfont 2 & cls & mode 80,75 & cmdwiz showcursor 0 & title Fire
call centerwindow.bat 0 -10
cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors
mode 80,50
echo "cmdgfx: quit"
title input:Q
exit /b 0 */

var showHelp=1, helpMsg="text e 0 0 SPACE/f/h 1,73", skip=["rem "," "]

var Shell = new ActiveXObject("WScript.Shell")

W=80, H=75, WW=W*2, HH=H*2

WScript.Echo("\"cmdgfx: fbox f 0 30 0,0,"+WW+",130 & fbox f 0 20 0,0,"+WW+",120 & fbox e 0 20 "+W+",0,"+W+",95\"")

var STREAM="1060=40++,1061=40++,1062=40++,1063=40++,1064=d0++,1065=d0++,1066=c0++,1067=a0++,1050=c0++,1051=90++,1052=a0++,1053=a0++,1054=a0++,1055=80++,1056=80++,1057=70++,1030=f0++,1031=f0++,1032=f0++,1033=f0++,1034=f0++,1035=f0++,1036=f0++,1037=f0++,1038=f0++,1039=f0++,?0??=-0??"

var TRANSF=["??50=fedb,??51=feb1,??52=ecdb,??53=ecb1,??54=c4db,??55=c4b1,??56=c4b0,??57=40b1,??58=4020,??60=feb2,??61=feb0,??62=ecb2,??63=ecb0,??64=c4db,??65=c4b2,??66=c4b0,??67=40b2,??68=40b0,00b0=4025,??30=ffdb,??31=ffb1,??32=feb2,??33=ecb0,??34=c4b0,??35=c0b1,??36=c0b0,??37=40b2,??38=40b1,??39=4025,??40=4020",
			"??50=fbdb,??51=fbb1,??52=b9db,??53=b9b1,??54=91db,??55=91b1,??56=10db,??57=10b0,??58=1020,??60=fbdb,??61=fbb1,??62=fbb0,??63=b9b2,??64=b9b0,??65=91b2,??66=91b0,??67=10b2,??68=10b0,00b0=10b0,??30=ffdb,??31=ffb1,??32=fbb2,??33=b9b2,??34=90b2,??35=90b1,??36=90b0,??37=10b2,??38=10b1,??39=10b0,??10=4020" ];

PW=1, COL=0, MODE=0

showHelp=1
helpMsg="text e 0 0 SPACE/f/h 1,73"

PWP=(PW+1)*3, nf1=15-PW*5, nf2=40-PW*10
MOD=PWP-PW, MOD2=Math.floor(MOD/2)

while(true) {

	WScript.Echo("\"cmdgfx: \" nf2:0,0,"+WW+","+HH+","+W+","+H)

	for (i = 0; i < nf1; i++) { X=GetRandom(W)+W, J=GetRandom(50)+(H-1), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; WScript.Echo("\"cmdgfx: line e 0 50 " + X + "," + J + "," + X2 + "," + J2 + "\" n") }
	for (i = 0; i < nf2; i++) { X=GetRandom(W)+W, J=GetRandom(50)+(H-1), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; WScript.Echo("\"cmdgfx: line e 0 60 " + X + "," + J + "," + X2 + "," + J2 + "\" n") }

	WScript.Echo("\"cmdgfx: block 0 "+W+",1,"+WW+","+(H+50)+" "+W+",0 -1 0 0 "+STREAM+" & block 0 "+W+",0,"+W+","+(H+55)+" 0,-2 -1 0 0 "+TRANSF[COL]+" & " + skip[showHelp] + helpMsg + "\" ")

	var input = WScript.StdIn.ReadLine()
	var ti = input.split(/\s+/)
	if (ti[3] == "1")
	{
		var key=ti[5]
		if (key == "10") { exec = Shell.Exec('cmdwiz getfullscreen'); exec.StdOut.ReadAll(); if (exec.exitCode==0) Shell.Exec('cmdwiz fullscreen 1'); else Shell.Exec('cmdwiz fullscreen 0') }
		if (key == "27") break
		if (key == "32") COL = 1 - COL
		if (key == "102") { LXP1=W+Math.floor((W-62)/2), LXP2=LXP1-1, LXP3=LXP1+1, LYP=H+4; WScript.Echo("\"cmdgfx: image img\\fire.txt f 0 0 20 "+LXP2+","+LYP+" & image img\\fire.txt f 0 0 20 "+LXP3+","+LYP+" & image img\\fire.txt f 0 0 20 "+LXP1+","+(LYP-1)+" & image img\\fire.txt f 0 0 20 "+LXP1+","+(LYP+1)+" & image img\\fire.txt f 0 0 20 "+LXP1+","+LYP+"\" n") }
		if (key == "104") showHelp = 1 - showHelp
		if (key == "112") WScript.Echo("\"cmdgfx: \" K")
	}
	
	if (ti[23] == "1")
	{
		W=Number(ti[25])+1, H=Number(ti[27])+1, WW=W*2, HH=H*2
		Shell.Exec('cmdwiz showcursor 0')
		helpMsg="text e 0 0 SPACE/f/h 1," + (H-3)
		//WScript.Echo("\n\n" + W); WScript.Echo("\"cmdgfx: \" K")
		PWP=(PW+1)*3, nf1=Math.floor(W/5)-PW*5, nf2=Math.floor(W/2)-PW*10
	}
}

function GetRandom(maxN) {
	return Math.floor(Math.random() * maxN)
}
