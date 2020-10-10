@if (true == false) @end /*
@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_RGB "" Sf2:0,0,200,150,100,75
set __=
cmdwiz showcursor 1 & goto :eof

:START
cmdwiz setfont 2 & cls & mode 100,75 & cmdwiz showcursor 0 & title RGB Fire (Space/Enter/f)
set /a W=100, H=75
call centerwindow.bat 0 -10
call prepareScale.bat 2
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

var Shell = new ActiveXObject("WScript.Shell")

var W=GetCmdVar("W"), H=GetCmdVar("H"), rW=GetCmdVar("rW"), rH=GetCmdVar("rH")

WW=W*2, HH=H*2, HLPY=H-2

var showHelp=0, helpMsg="text e 0 0 SPACE/f/h/ENTER 1," + HLPY, skip=["rem "," "]

WScript.Echo("\"cmdgfx: fbox 0 0 db \"")

MOD=5, MOD2=Math.floor(MOD/2)
COLI=0, MODE=0; setColFade(COLI);

while(true) {

	WScript.Echo("\"cmdgfx: \" nf2:0,0,"+WW+","+HH+","+W+","+H)

	WScript.Echo("\"cmdgfx: fbox f6f600 0 b1 " + 0 + "," + (H+10) + "," + W + ",5 \" n");
	
	for (i = 0; i < 14; i++) { X=GetRandom(W), J=GetRandom(10)+(H), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; WScript.Echo("\"cmdgfx: line ffffff 0 b1 " + X + "," + J + "," + X2 + "," + J2 + "\" n") }
	for (i = 0; i < 7; i++) { X=GetRandom(W), J=GetRandom(10)+(H), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; WScript.Echo("\"cmdgfx: line d0d080 0 b1 " + X + "," + J + "," + X2 + "," + J2 + "\" n") }

	if (MODE==0) WScript.Echo("\"cmdgfx: block 0 0,0,"+W+","+(H+12)+" 0,0 -1 0 0 -  shade(fgcol(x,y+1),-random()*"+RM+",-random()*"+GM+",-random()*"+(BM*2)+") & " + skip[showHelp] + helpMsg + "\" ")

	if (MODE==1) WScript.Echo("\"cmdgfx: block 0 0,0,"+W+","+(H+12)+" 0,0 -1 0 0 - store(fgcol(x,y+1),1)+store(and(s1,255),4)+store(and(shr(s1,16),255),3)+store(and(shr(s1,8),255),2)+or(or(shl(s2-random()*"+GM+"*gtr(s2,"+GM+"),8),shl(s3-random()*"+RM+"*gtr(s3,"+RM+"),16)),s4-random()*"+BM+"*gtr(s4,"+BM+"*2)-random()*"+BM+"*gtr(s4,"+BM+")) & " + skip[showHelp] + helpMsg + "\" ")

	//WScript.Echo("\"cmdgfx: ellipse 9 0 b1 40,27,17,9 \" ")

	var input = WScript.StdIn.ReadLine()
	var ti = input.split(/\s+/)
	if (ti[3] == "1")
	{
		var key=ti[5]
		if (key == "10") { exec = Shell.Exec('cmdwiz getfullscreen'); exec.StdOut.ReadAll(); if (exec.exitCode==0) Shell.Exec('cmdwiz fullscreen 1'); else Shell.Exec('cmdwiz fullscreen 0') }
		if (key == "27") break
		if (key == "13") MODE=1-MODE
		if (key == "32") { COLI++; if (COLI >= 3) COLI=0; setColFade(COLI); }
		if (key == "102") { LXP1=Math.floor((W-62)/2), LYP=H; WScript.Echo("\"cmdgfx: image img\\fire.txt d00000 0 0 20 "+LXP1+","+LYP+" \" n") }
		if (key == "104") { WScript.Echo("\"cmdgfx: line ? ? db 1,"+(H-3)+",1000,"+(H-3)); showHelp = 1-showHelp }
		if (key == "112") WScript.Echo("\"cmdgfx: \" K")
	}

	if (ti[23] == "1")
	{
		W=Math.floor(Number(ti[25])*rW/100+1), H=Math.floor(Number(ti[27])*rH/100+1)
		WW=W*2, HH=H*2
		Shell.Exec('cmdwiz showcursor 0')
		helpMsg="text e 0 0 SPACE/f/h/ENTER 1," + (H-3)
		WScript.Echo("\"cmdgfx: fbox 0 0 db \" nf2:0,0,"+WW+","+HH+","+W+","+H)
	}
}

function GetRandom(maxN) {
	return Math.floor(Math.random() * maxN)
}

function setColFade(index) {
	if (index == 0) { RM=5, GM=12, BM=16 }
	if (index == 1) { RM=10, GM=6, BM=4 }
	if (index == 2) { RM=8, GM=18, BM=3 }
}
