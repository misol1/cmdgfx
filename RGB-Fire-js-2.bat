@if (true == false) @end /*
@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_RGB "" Sf2:0,0,200,180,100,90
set __=
cmdwiz showcursor 1 & goto :eof

:START
cmdwiz setfont 2 & cls & mode 100,90 & cmdwiz showcursor 0 & title RGB Fire 2 : SPACE/Enter
call centerwindow.bat 0 -10
cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors
mode 80,50
echo "cmdgfx: quit"
title input:Q
exit /b 0 */

var showHelp=0, helpMsg="text e 0 0 SPACE/f/h/ENTER/r 1,73", skip=["rem "," "]
var Shell = new ActiveXObject("WScript.Shell")

W=80, H=75, WW=W*2, HH=H*2
WScript.Echo("\"cmdgfx: fbox 0 0 db \"")

MOD=35, MOD2=Math.floor(MOD/2)
SEED=0; MODE=1; COLI=0; setColFade(COLI); YD=12

while(true) {

	WScript.Echo("\"cmdgfx: fbox 0 0 b1 " + 0 + "," + (H+10) + "," + W + ",65 \" nf2:0,0,"+WW+","+HH+","+W+","+H)

	if (SEED==0) {
		for (i = 0; i < 8; i++) { X=GetRandom(W), J=GetRandom(10)+(H), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; WScript.Echo("\"cmdgfx: line ffffff 0 b1 " + X + "," + J + "," + X2 + "," + J2 + "\" n") }
		for (i = 0; i < 7; i++) { X=GetRandom(W), J=GetRandom(10)+(H), J2=J+GetRandom(MOD), X2=X+GetRandom(MOD)-MOD2; WScript.Echo("\"cmdgfx: line d0d080 0 b1 " + X + "," + J + "," + X2 + "," + J2 + "\" n") }
	}  else {
		WScript.Echo("\"cmdgfx: block 0 0,"+(H+4)+","+W+",1 0,"+(H+4)+" -1 0 0 - store(floor(random()*2)*255,0)+makecol(s0,s0,s0) \" n");
	}
	
	if (MODE==0) WScript.Echo("\"cmdgfx: block 0 0,0,"+W+","+(H+YD)+" 0,0 -1 0 0 - store(fgcol(x,y+1),0)+store(fgcol(x+y%2*2-1,y+1),1)+makecol((fgr(s0)+fgr(s1))/"+RD+",(fgg(s0)+fgg(s1))/"+GD+",(fgb(s0)+fgb(s1))/"+BD+") & skip text 9 0 0 [FRAMECOUNT] 10,10 & " + skip[showHelp] + helpMsg + "\" ")

	if (MODE==1) WScript.Echo("\"cmdgfx: block 0 0,0,"+W+","+(H+YD)+" 0,0 -1 0 0 - store(fgcol(x,y+1),0)+store(fgcol(x-1,y+1),1)+store(fgcol(x+1,y+1),2)+store(fgcol(x,y+2),3)+makecol((fgr(s0)+fgr(s1)+fgr(s2)+fgr(s3))/"+RD+",(fgg(s0)+fgg(s1)+fgg(s2)+fgg(s3))/"+GD+",(fgb(s0)+fgb(s1)+fgb(s2)+fgb(s3))/"+BD+") & skip text 9 0 0 [FRAMECOUNT] 10,10 & " + skip[showHelp] + helpMsg + "\" ")


	// WScript.Echo("\"cmdgfx: ellipse 9 0 b1 40,27,17,9 \" ")

	var input = WScript.StdIn.ReadLine()
	var ti = input.split(/\s+/)
	if (ti[3] == "1")
	{
		var key=ti[5]
		if (key == "10") { exec = Shell.Exec('cmdwiz getfullscreen'); exec.StdOut.ReadAll(); if (exec.exitCode==0) Shell.Exec('cmdwiz fullscreen 1'); else Shell.Exec('cmdwiz fullscreen 0') }
		if (key == "27") break
		if (key == "13") { MODE=1-MODE; setColFade(COLI); }
		if (key == "32") { COLI++; if (COLI >= 4) COLI=0; setColFade(COLI); }
		if (key == "102") { LXP1=Math.floor((W-62)/2), LYP=H; WScript.Echo("\"cmdgfx: image img\\fire.txt d00000 0 0 20 "+LXP1+","+LYP+" \" n") }
		if (key == "104") { WScript.Echo("\"cmdgfx: line ? ? db 1,"+(H-3)+",1000,"+(H-3)); showHelp = 1-showHelp }
		if (key == "112") WScript.Echo("\"cmdgfx: \" K")
		if (key == "114") { SEED=1-SEED; }
		if (key == "336") { YD-=3; if (YD < 2) YD=2; }
		if (key == "328") { YD+=3;if (YD > 12) YD=12; }
		if (key == "97") { CH1=GetRandom(8)+1; CH2=GetRandom(8)+1; WScript.Echo("\"cmdgfx: fbox 0 0 " + CH1 + CH2 + " \" nf2:0,0,"+WW+","+HH+","+W+","+H) }
	}

	if (ti[23] == "1")
	{
		W=Number(ti[25])+1, H=Number(ti[27])+1 
		WW=W*2, HH=H*2
		setColFade(COLI);
		Shell.Exec('cmdwiz showcursor 0')
		helpMsg="text e 0 0 SPACE/f/h/ENTER 1," + (H-3)
		WScript.Echo("\"cmdgfx: fbox 0 0 db \" nf2:0,0,"+WW+","+HH+","+W+","+H)
	}
}

function GetRandom(maxN) {
	return Math.floor(Math.random() * maxN)
}

function setColFade(index) {
	if (index == 0) { RD=2, GD=2.05, BD=2.2 }
	if (index == 1) { RD=2.01, GD=2.05, BD=2.2 }
	if (index == 2) { RD=2.1, GD=2, BD=2.05 }
	if (index == 3) { RD=2.2, GD=2.05, BD=2 }
	RD+=MODE*2; GD+=MODE*2; BD+=MODE*2;
}
