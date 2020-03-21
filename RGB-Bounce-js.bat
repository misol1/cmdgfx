@if (true == false) @end /*
@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_RGB_32 "" Sf0:0,0,420,420,240,100G24,16t8
set __=
cmdwiz showcursor 1 & goto :eof

:START
cmdwiz setfont 6 & cls & mode 120,50 & cmdwiz showcursor 0 & title RGB Bounce
call centerwindow.bat 0 -15
cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors
mode 80,50
echo "cmdgfx: quit"
title input:Q
exit /b 0 */

var maxBalls=500, nofShownBalls=40, w=240, h=100
var ballsX=[], ballsY=[], ballsSX=[], ballsI=[], ballsYC=[], ballsYH=[], ballsSXcale=[], ballsCol=[], ballsJ=[], ballsOpa=[]
var bI = ["ball4-t.gxy"], bIw = [28,24,20,16,14], bIh = [20,18,15,12,9]

var multiCol=1, shadow=1, extraFlag="", opacity=0
var showHelp=1, helpMsg="text 7 0 0 SPACE\\-ENTER\\-\\g11\\g10\\-o\\-p\\-h 1,98", skip=["rem "," "]

var Shell = new ActiveXObject("WScript.Shell")
var bx=280, w2=w+140, h2=h*2+20
w2=w+140, h2=h*4+20

for (i = 0; i < maxBalls; i++) {
	ballsX.push(Math.floor(Math.random() * w))
	ballsY.push(Math.floor(Math.random() * h))
	ballsSX.push(Math.random() * 1.8 + 0.1)
	ballsYC.push(Math.random() * Math.PI + Math.PI);
	ballsYH.push(Math.floor(Math.random() * 50) + 45);
	ballsI.push(Math.floor(Math.random() * bIw.length))
	ballsJ.push(Math.floor(Math.random() * 7))
	ballsSXcale.push(Math.floor(Math.random() * bIw.length))
	ballsCol.push(Math.floor(Math.random() * 6))
	ballsOpa.push(Math.floor(Math.random() * 150)+105)
}

DrawBufferBalls()

while(true) {
	outString="fbox 111130 0 b1 0,0," + w + "," + h + " & fbox 191940 0 b1 0," + (h-8) + "," + w + ",8"
	for (i = 0; i < nofShownBalls; i++) {
		ballsX[i] = (ballsX[i] + ballsSX[i]);
		if (ballsX[i] > w || ballsX[i] < 0) ballsSX[i] = -ballsSX[i];
		ballsY[i] = Math.floor(Math.sin(ballsYC[i]) * ballsYH[i]) + (h-5);
		ballsYC[i] += 0.025; if (ballsYC[i] > Math.PI*2) { ballsYC[i] = Math.PI; } // ballsYH[i]*=0.7;
		//outString += "& block 0,128 " + bx + "," + (50*ballsJ[i]*multiCol) + ",48,48 " + (Math.floor(ballsX[i]-bIw[ballsI[i]]/2)-1) + "," + (Math.floor(ballsY[i]-bIh[ballsI[i]]/2)-1) + "," + (bIw[ballsI[i]]+2) + "," + (bIh[ballsI[i]]+2) + " 58"
		if (opacity == 1)
			outString += "& block 0,"+ballsOpa[i]+" " + bx + "," + (50*ballsJ[i]*multiCol) + ",48,48 " + Math.floor(ballsX[i]-bIw[ballsI[i]]/2) + "," + Math.floor(ballsY[i]-bIh[ballsI[i]]/2) + "," + bIw[ballsI[i]] + "," + bIh[ballsI[i]]+" 58"
		else
			outString += "& block 0 " + bx + "," + (50*ballsJ[i]*multiCol) + ",48,48 " + Math.floor(ballsX[i]-bIw[ballsI[i]]/2) + "," + Math.floor(ballsY[i]-bIh[ballsI[i]]/2) + "," + bIw[ballsI[i]] + "," + bIh[ballsI[i]]+" 58"
	}
	if (shadow==1) outString += " & fbox d 0 03 0,"+h+","+w+","+h+" & block 0 0,0," + w + "," + h + " 0," + h + " b1" + " & block 0 0," + h + "," + w + "," + h + " 8,-3 03 0 0 - 0000 &  block 0 0," + h + "," + w + "," + h + " 0,0 03" ;

	WScript.Echo("\"cmdgfx:" + outString + " & " + skip[showHelp] + helpMsg + " & text a 0 0 " + nofShownBalls + ":_[FRAMECOUNT] 1,1" + "\" " + extraFlag + "f0:0,0,"+w2+","+h2+","+w+","+h)
	extraFlag=""

	var input = WScript.StdIn.ReadLine()
	var ti = input.split(/\s+/)
	if (ti[3] == "1")
	{
		var key=ti[5]
		if (key == "10") { exec = Shell.Exec('cmdwiz getfullscreen'); exec.StdOut.ReadAll(); if (exec.exitCode==0) Shell.Exec('cmdwiz fullscreen 1'); else Shell.Exec('cmdwiz fullscreen 0') }
		if (key == "27") break
		if (key == "32") multiCol = 1 - multiCol
		if (key == "13") shadow = 1 - shadow
		if (key == "104") showHelp = 1 - showHelp
		if (key == "111") opacity = 1 - opacity
		if (key == "331") { nofShownBalls-=10; if (nofShownBalls <= 0) nofShownBalls = 1; extraFlag="C" }
		if (key == "333") { nofShownBalls+=10; if (nofShownBalls > maxBalls) nofShownBalls = maxBalls; extraFlag="C" }
		if (key == "112") WScript.Echo("\"cmdgfx: \" K")
	}
	if (ti[23] == "1")
	{
		w=Number(ti[25])*2+1, h=Number(ti[27])*2+1, HLPY=h-3, w2=w+140, h2=h*2+20+350
		Shell.Exec('cmdwiz showcursor 0')
		helpMsg="text 7 0 0 SPACE\\-ENTER\\-\\g11\\g10\\-o\\-p\\-h 1," + (h-3)
		DrawBufferBalls();
		for (i = 0; i < maxBalls; i++) {
			if (ballsX[i] > w) ballsX[i] = w-5
			ballsSX[i] = Math.random() * (w/200.0) + 0.1
			ballsYH[i] = Math.floor(Math.random() * h/2) + (h/2-5)
		}	
		//WScript.Echo("\n\n" + W); WScript.Echo("\"cmdgfx: \" K")
	}
}

function DrawBufferBalls() {
	bx=w+60
	WScript.Echo("\"cmdgfx: fbox 1 0 X & image img\\ball.bmp 0 0 db 101010 " + bx + ",0 \" " + "f0:0,0,"+w2+","+h2+","+w+","+h)
	//brighten(bx,0,48,48, -20,-20,-20);
	contrast(bx,0,48,48, 0.25);
	//invert(bx,0,48,48);
	//grayscale(bx,0,48,48);
	//tint(bx,0,48,48, 1,0.6,0.6);
	//posterize(bx,0,48,48, 100);
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,48,48 " + bx + ",50 -1 0 0 - store(fgcol(x,y),0)+makecol(fgg(s0),fgb(s0),fgr(s0))" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,48,48 " + bx + ",100 -1 0 0 - store(fgcol(x,y),0)+makecol(fgb(s0),fgr(s0),fgg(s0))" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,48,48 " + bx + ",150 -1 0 0 - store(fgcol(x,y),0)+makecol(fgr(s0),fgr(s0),fgb(s0))" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,48,48 " + bx + ",200 -1 0 0 - store(fgcol(x,y),0)+makecol(fgr(s0),fgg(s0),fgr(s0))" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,48,48 " + bx + ",250 -1 0 0 - store(fgcol(x,y),0)+makecol(fgr(s0),fgr(s0),fgr(s0))" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,48,48 " + bx + ",300 -1 0 0 - store(fgcol(x,y),0)+makecol(fgg(s0),fgr(s0),fgr(s0))" + "\" ")
}

function brighten(x,y,w,h, r,g,b) {
	WScript.Echo("\"cmdgfx: block 0 " + x + "," + y + "," +w + "," + h + " " + x + "," + y + " -1 0 0 - shade(fgcol(x,y),"+r+","+g+","+b+") \" " );
}

function contrast(x,y,w,h, amount) {
	WScript.Echo("\"cmdgfx: block 0 " + x + "," + y + "," + w + "," + h + " " + x + "," + y + " -1 0 0 - store(fgcol(x,y),0)+shade(s0,(fgr(s0)-128)*"+amount+",(fgg(s0)-128)*"+amount+",(fgb(s0)-128)*"+amount+") \" " );
}

function invert(x,y,w,h) {
	WScript.Echo("\"cmdgfx: block 0 " + x + "," + y + "," + w + "," + h + " " + x + "," + y + " -1 0 0 - store(fgcol(x,y),0)+makecol(255-fgr(s0),255-fgg(s0),255-fgb(s0)) \" " );
}

function grayscale(x,y,w,h) {
	WScript.Echo("\"cmdgfx: block 0 " + x + "," + y + "," + w + "," + h + " " + x + "," + y + " -1 0 0 - store(fgcol(x,y),0)+store((fgr(s0)*0.2126+fgg(s0)*0.7152+fgb(s0)*0.0722),1),makecol(s1,s1,s1) \" " );
}

function tint(x,y,w,h, r,g,b) {
	WScript.Echo("\"cmdgfx: block 0 " + x + "," + y + "," + w + "," + h + " " + x + "," + y + " -1 0 0 - store(fgcol(x,y),0)+makecol(fgr(s0)*"+r+",fgg(s0)*"+g+",fgb(s0)*"+b+") \" " );
}

function posterize(x,y,w,h, a) {
	WScript.Echo("\"cmdgfx: block 0 " + x + "," + y + "," + w + "," + h + " " + x + "," + y + " -1 0 0 - store(fgcol(x,y),0)+makecol(floor(fgr(s0)/"+a+")*"+a+",floor(fgg(s0)/"+a+")*"+a+",floor(fgb(s0)/"+a+")*"+a+") \" " );
}
