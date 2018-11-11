@if (true == false) @end /*
@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_gdi "" Sf0:0,0,320,220,240,100G16,16
set __=
cmdwiz showcursor 1 & goto :eof

:START
cmdwiz setfont 6 & cls & mode 120,50 & cmdwiz showcursor 0 & title Bounce
call centerwindow.bat 0 -15
cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors
mode 80,50
echo "cmdgfx: quit"
title input:Q
exit /b 0 */

var maxBalls=500, nofShownBalls=50, w=240, h=100
var ballsX=[], ballsY=[], ballsSX=[], ballsI=[], ballsYC=[], ballsYH=[], ballsSXcale=[], ballsCol=[]
var bI = ["ball4-t.gxy"], bIw = [13,11,9], bIh = [10,8,6]

var multiCol=1, shadow=1, extraFlag=""
var showHelp=1, helpMsg="text 7 0 0 SPACE\\-ENTER\\-\\g11\\g10\\-p\\-h 1,98", skip=["rem "," "]

var Shell = new ActiveXObject("WScript.Shell")
var bx=260, w2=w+80, h2=h*2+20

for (i = 0; i < maxBalls; i++) {
	ballsX.push(Math.floor(Math.random() * w))
	ballsY.push(Math.floor(Math.random() * h))
	ballsSX.push(Math.random() * 1.8 + 0.1)
	ballsYC.push(Math.random() * Math.PI + Math.PI);
	ballsYH.push(Math.floor(Math.random() * 50) + 45);
	ballsI.push(Math.floor(Math.random() * bI.length))
	ballsSXcale.push(Math.floor(Math.random() * bIw.length))
	ballsCol.push(Math.floor(Math.random() * 6))
}

DrawBufferBalls()

while(true) {
	outString="fbox 1 0 b1 0,0," + w + "," + h + " & fbox 1 0 b0 0," + (h-8) + "," + w + ",8"
	for (i = 0; i < nofShownBalls; i++) {
		ballsX[i] = (ballsX[i] + ballsSX[i]);
		if (ballsX[i] > w || ballsX[i] < 0) ballsSX[i] = -ballsSX[i];
		ballsY[i] = Math.floor(Math.sin(ballsYC[i]) * ballsYH[i]) + (h-5);
		ballsYC[i] += 0.025; if (ballsYC[i] > Math.PI*2) { ballsYC[i] = Math.PI; } // ballsYH[i]*=0.7;
		outString += "& block 0 " + (bx + ballsSXcale[i]*20) + "," + (ballsCol[i] * 10 * multiCol) + ",13,10 " + Math.floor(ballsX[i]-bIw[ballsI[i]]/2) + "," + Math.floor(ballsY[i]-bIh[ballsI[i]]/2) + " 58"
	}
	if (shadow==1) outString += " & block 0 0,0," + w + "," + h + " 0," + h + " -1 0 0 10b1=1058" + " & block 0 0,0," + w + "," + h + " 8,-2 -1 0 0 10b?=10b1,????=10b0" + " & block 0 0," + h + "," + w + "," + h + " 0,0 58" ;
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
		if (key == "331") { nofShownBalls-=10; if (nofShownBalls <= 0) nofShownBalls = 1; extraFlag="C" }
		if (key == "333") { nofShownBalls+=10; if (nofShownBalls > maxBalls) nofShownBalls = maxBalls; extraFlag="C" }
		if (key == "112") WScript.Echo("\"cmdgfx: \" K")
	}
	if (ti[23] == "1")
	{
		w=Number(ti[25])*2+1, h=Number(ti[27])*2+1, HLPY=h-3, w2=w+80, h2=h*2+20
		Shell.Exec('cmdwiz showcursor 0')
		helpMsg="text 7 0 0 SPACE\\-ENTER\\-\\g11\\g10\\-p\\-h 1," + (h-3)
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
	bx=w+20, bx2=bx+22, bx3=bx+43
	WScript.Echo("\"cmdgfx: fbox 1 0 X & image img\\ball4-t.gxy 0 0 0 -1 " + bx + ",0 & image img\\ball4-t.gxy 0 0 0 -1 " + bx2 + ",2 0 0 11,8 & image img\\ball4-t.gxy 0 0 0 -1 " + bx3 + ",4 0 0 9,6" + "\" " + "f0:0,0,"+w2+","+h2+","+w+","+h)
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,60,10 " + bx + ",10 -1 0 0 c4??=91??,?4??=?1??,c???=9???,?c??=?9??" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,60,10 " + bx + ",20 -1 0 0 c4??=a2??,?4??=?2??,c???=a???,?c??=?a??" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,60,10 " + bx + ",30 -1 0 0 c4??=d5??,?4??=?5??,c???=d???,?c??=?d??" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,60,10 " + bx + ",40 -1 0 0 c4??=e6??,?4??=?6??,c???=e???,?c??=?e??" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,60,10 " + bx + ",50 -1 0 0 c4??=78??,?4??=?8??,c???=7???,?c??=?7??" + "\" ")
	WScript.Echo("\"cmdgfx: block 0 " + bx + ",0,60,10 " + bx + ",60 -1 0 0 c4??=b3??,?4??=?3??,c???=b???,?c??=?b??" + "\" ")
}

//outString += "& image img\\" + bI[ballsI[i]] + " 0 0 0 -1 " + Math.floor(ballsX[i]-bIw[ballsI[i]]/2) + "," + Math.floor(ballsY[i]-bIh[ballsI[i]]/2) + " 0 0 " + bIw[ballsSXcale[i]] + "," + bIh[ballsSXcale[i]]
//outString += "& fellipse " + (ballsCol[i] * multiCol + 1) + " 0 db " + Math.floor(ballsX[i]-bIw[ballsI[i]]/2) + "," + Math.floor(ballsY[i]-bIh[ballsI[i]]/2) + ",8,6"
//outString += "& fbox " + (ballsCol[i] * multiCol + 1) + " 0 db " + Math.floor(ballsX[i]-bIw[ballsI[i]]/2) + "," + Math.floor(ballsY[i]-bIh[ballsI[i]]/2) + ",12,9"
//outString += "& pixel " + (ballsCol[i] * multiCol + 1) + " 0 db " + Math.floor(ballsX[i]-bIw[ballsI[i]]/2) + "," + Math.floor(ballsY[i]-bIh[ballsI[i]]/2)
