@if (true == false) @end /*
@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title L-System 3d (right/left Space i/I p Enter d/D p x/y/z a/A n)
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xR | call %0 %* | cmdgfx_gdi "" Sfa:0,0,1600,900N2500L150,8
set __=
goto :eof

:START
set /a W6=1600/8, H6=900/12
mode %W6%,%H6%
call centerwindow.bat 0 -16

cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors

set W6=&set H6=
echo "cmdgfx: quit"
title input:Q
cmdwiz showcursor 1 & mode 80,50
del /Q l-system.obj>nul
exit /b 0
*/

function LSystem(name, axiom, rules, linelen, linecolor, iterations, rotationX, startRotationX, rotationY, startRotationY) {
    this.name = name
	this.axiom = axiom
    this.rules = rules
    this.linelen = linelen
    this.linecolor = linecolor
    this.iterations = iterations
    this.rotationX = rotationX
    this.startRotationX = startRotationX
    this.rotationY = rotationY
    this.startRotationY = startRotationY
}


var LSystems = [
    new LSystem("3d-Plant7", "F", ["F->FF[+F+F][/F\\F][-\\F]" ], 38, "2", 4, 22.5, 180, 22.5, 0)
   ,new LSystem("Leaf", "a", ["F->>F<", "a->F[+/1]F2", "b->F[-\\3]Fa", "x->a", "y->b", "1->x", "2->b", "3->y" ], 36, "c", 13, 45, 180, 25, 0)
   ,new LSystem("Triangle", "F+F+F", ["F->F-F+F"], 95, "9", 7, 120, 0, 0, 0)
   ,new LSystem("3d-Plant6", "F", ["F->F[+F][-F][/F][\\F]" ], 38, "2", 4, 22.5, 180, 22.5, 0)
   ,new LSystem("Hexagonal Gosper", "XF", ["X->X+1F++1F-FX--FXFX-1F+","Y->-FX+YFYF++YF+FX--FX-Y","1->Y"], 60, "b", 4, 60, 90, 0, 0)
   ,new LSystem("Rotated Von Koch Snowflake", "F++F++F", ["F->F/-F++F/-F"], 15, "f", 5, 60, 90, 0.35, 90)
   ,new LSystem("Sierpinski Arrowhead", "YF", ["X->1F+XF+1", "Y->XF-YF-X", "1->Y"], 50, "5", 7, 60, 90, 0, 0)
   ,new LSystem("Weed", "F", ["F->FF/-[12]+\\[12]", "X->+F\\2", "Y->-FX","1->X","2->Y" ], 38, "8", 6, 32.5, 180, 32.5, 0)
   ,new LSystem("Board", "F+F+F+F", ["F->FF+F+F+F+FF"], 40, "5", 4, 90, 0, 0, 0)
   ,new LSystem("Stick", "X", ["F->FF", "X->F/[+X]F/[-X]+X\\"], 23, "2", 7, 20, 180, 20, 0)
   ,new LSystem("Bush 1", "Y", ["X->X[-FFF][+FFF]FX", "Y->YF/X[+Y][-Y]\\\\"], 40, "2", 6, 25.7, 180, 25.7, 0)
   ,new LSystem("Bush 2", "F", ["F->FF+[+F-//F-F]-[-F+F\\+F]"], 55, "2", 4, 22.5, 180, 22.5, 0)
   ,new LSystem("Bush 3", "F", ["F->F[+/FF][\\-F\\F]F[-F][+//F]F"], 38, "2", 4, 35, 180, 35, 0)
   ,new LSystem("Hilbert", "X", ["X->-1F+XFX+F1-", "Y->+XF-YFY-FX+", "1->Y"], 65, "d", 6, 90, 0, 0, 0)
   ,new LSystem("Tiles", "F/+F/+F/+F", ["F->FF+F-F+F+FF"], 95, "9", 3, 90, 0, 45, 0)
   ,new LSystem("Pentaplexity", "F++F++F++F++F", ["F->F++F++F|F-F++F"], 45, "f", 4, 36, 0, 0, 0)
   ,new LSystem("Curved Dragon Curve", "FX", ["X->X+1F+", "Y->-F/X/-Y", "1->Y"], 95, "a", 13, 90, 0, 0.05, 0)
   ,new LSystem("Crystal", "F+F+F+F", ["F->FF+F++F+F"], 30, "e", 4, 90, 0, 0, 0)
   ,new LSystem("Rotated Koch Curve", "F+F+F+F", ["F->F+/F-F-F//F+F+/F-F/"], 22, "c", 3, 90, 0, 0.5, 90)
   ,new LSystem("Pentaplexity3d", "F++F++F++F++F", ["F->F++/F++//F|F-F++F"], 45, "f", 4, 36, 0, 3, 0)
   ,new LSystem("Houdini", "F-F-F-F-F-F-F-F", ["F->F-–-F+F+F+F+F+F+F-–-F" ], 39, "d", 3, 14.5, 90, 0, 0)
   ,new LSystem("Board", "F+F+F+F", ["F->FF+F+F+F+FF"], 40, "5", 4, 150, 0, 0, 0)

];

function DrawState(x, y, z, currRotX, currRotY, swap, linelen, rotationX, rotationY, currVertex) {
	this.x = x
	this.y = y
	this.z = z
	this.currRotX = currRotX
	this.currRotY = currRotY
	this.swap = swap
	this.linelen = linelen
	this.rotationX = rotationX
	this.rotationY = rotationY
	this.currVertex = currVertex
}

function DrawSystem() {

	LS = LSystems[systemIndex]
	
	current = LS.axiom
	rules = LS.rules
	linelen = LS.linelen
	color = LS.linecolor
	iterations = LS.iterations + extraIteration
	if (iterations < 1) { iterations=1; extraIteration++; }
	rotationX = LS.rotationX + modRotX
	rotationY = LS.rotationY
	currRotX = LS.startRotationX*(Math.PI/180)
	currRotY = LS.startRotationY*(Math.PI/180)
	if (singleAxis) currRotY = 0;
	xp = yp = zp = 0
	isFlat = true

	rotationX = rotationX*(Math.PI/180)
	rotationY = rotationY*(Math.PI/180)
	linelen = linelen/iterations
	reverse = 180*(Math.PI/180)

	for (i=0; i < iterations; i++) {
		for (j=0; j < rules.length; j++) {
			current = current.replace(new RegExp(rules[j].substring(0,1), 'g'), rules[j].substring(3))
		}
	}

	drawStates = []
	swap = 1
	
	vertexCounter = currVertex = 1

	var fh = fso.CreateTextFile("l-system.obj", 2, false); 
	
	if (useBobs > 0) fh.WriteLine("usemtl img\\ball4-t.gxy");
	
	for (i=0; i < current.length; i++) {
		ch = current.substring(i,i+1)
		if (ch == "+") currRotX+=rotationX*swap
		if (ch == "-") currRotX-=rotationX*swap
		if (ch == "/" && !singleAxis && rotationY != 0) currRotY+=rotationY*swap, isFlat = false
		if (ch == "\\" && !singleAxis && rotationY != 0) currRotY-=rotationY*swap, isFlat = false
		if (ch == "|") currRotX+=reverse
		if (ch == ">") linelen *= lineScaleFactor
		if (ch == "<") linelen /= lineScaleFactor
		if (ch == "(") rotation -= turnAngleIncrement
		if (ch == ")") rotation += turnAngleIncrement
		if (ch == "&") swap=-swap
		if (ch == "[") drawStates.push(new DrawState(xp, yp, zp, currRotX, currRotY, swap, linelen, rotationX, rotationY, currVertex))
		if (ch == "]") {
			drawState = drawStates.pop()
			xp = drawState.x, yp = drawState.y, zp = drawState.z, currRotX = drawState.currRotX, currRotY = drawState.currRotY, swap = drawState.swap, linelen = drawState.linelen, rotationX = drawState.rotationX, rotationY = drawState.rotationY, currVertex = drawState.currVertex;
		}
		if (ch == "@") {
			fh.WriteLine("v " + xp.toFixed(1) + " " + yp.toFixed(1) + " " + zp.toFixed(1))
			fh.WriteLine("f " + vertexCounter + "//" )
			vertexCounter += 1
		}
		if (ch == "F" || ch == "f") {
			oldxp = xp, oldyp = yp, oldzp = zp
			
			// calculate Fwd Vector with polar coordinates
			yf = Math.cos(currRotX)*Math.cos(currRotY)
			xf = Math.cos(currRotX)*Math.sin(currRotY)
			zf = Math.sin(currRotX)
			
			xp = xp+xf*linelen
			yp = yp+yf*linelen
			zp = zp+zf*linelen
			
			if(ch == "F") { 
				fh.WriteLine("v " + oldxp.toFixed(1) + " " + oldyp.toFixed(1) + " " + oldzp.toFixed(1))
				fh.WriteLine("v " + xp.toFixed(1) + " " + yp.toFixed(1) + " " + zp.toFixed(1))
				if (useBobs > 0)
					fh.WriteLine("f " + (vertexCounter+1) + "// ");
				if (useBobs != 1)
					fh.WriteLine("f " + vertexCounter + "// " + (vertexCounter+1) + "//" )
				vertexCounter += 2
			}
		}
	}
	fh.Close(); 
}

lineScaleFactor = 1.36
turnAngleIncrement = 5*(Math.PI/180)
singleAxis = false

systemIndex = 0
drawNextSystem = true

RX=0, RY=0, RZ=0
RXD=0, RYD=4, RZD=0
manualRotation = false
DIST=3000
color="9"
extraFlag=""
extraIteration=0

lightPalette = "f X 0 e X 0 d X 0 c X 0 b X 0 a X 0 9 X 0 8 X 0 7 X 0 6 X 0 5 X 0 4 X 0 3 X 0 2 X 0 1 X 0"
lightPaletteRGB = "000000,000030,000060,111190,2222c0,3333ff,4444ff,5555ff,6666ff,7777ff,9999ff,aaaaff,bbbbff,ccccff,ddddff,ffffff"
flatLightPaletteRGB = "000000,1111aa,2525bb,3838cc,4e4edd,5555dd,5e5eee,6666ee,7777ff,8888ff,9999ff,aaaaff,bbbbff,ccccff,ddddff,eeeeff"
useLight=true
useBobs=0

W=1600, H=900, XMID=W/2, YMID=H/2

fso = new ActiveXObject("Scripting.FileSystemObject"); 
Shell = new ActiveXObject("WScript.Shell")

modRotX = 0

while(true) {

	if (drawNextSystem) {
		DrawSystem()
		drawNextSystem = false
	}

	if (useLight)
		WScript.Echo("\"cmdgfx: fbox 0 0 0 & 3d l-system.obj " + (useBobs > 0? 0 : 1) + "," + (isFlat? 0:1) + " " + RX + ","  + RY + "," + RZ + " 0,0,0 1,1,1,0,0,0 0,-3000,0,0 " + XMID + "," + YMID + "," + DIST + ",1 " + lightPalette + " \" F" + extraFlag + "fa:0,0," + W + "," + H + " " + (isFlat?flatLightPaletteRGB : lightPaletteRGB) )
	else
		WScript.Echo("\"cmdgfx: fbox 0 0 0 & 3d l-system.obj " + (useBobs > 0? 0 : 3) + ",-1 " + RX + ","  + RY + "," + RZ + " 0,0,0 1,1,1,0,0,0 0,-3000,0,0 " + XMID + "," + YMID + "," + DIST + ",1 " + (useBobs == 0? color : useBobs == 1? 1 : 8) + " X 0  \" F" + extraFlag + "fa:0,0," + W + "," + H + " - -")
	
	extraFlag = ""

	if (!manualRotation)
		RX += RXD, RY += RYD, RZ += RZD
	
	var input = WScript.StdIn.ReadLine()
	var ti = input.split(/\s+/)
	if (ti[3] == "1")
	{
		var key = ti[5]
		if (key == "27") break
		else if (key == "10") { exec = Shell.Exec('cmdwiz getfullscreen'); exec.StdOut.ReadAll(); if (exec.exitCode==0) Shell.Exec('cmdwiz fullscreen 1'); else Shell.Exec('cmdwiz fullscreen 0') }
		else if (key == "120") { if (manualRotation) RX += 12; else RXD = RXD==0? 4 : 0 }
		else if (key == "121") { if (manualRotation) RY += 12; else RYD = RYD==0? 4 : 0 }
		else if (key == "122") { if (manualRotation) RZ += 12; else RZD = RZD==0? 4 : 0 }
		else if (key == "88") { if (manualRotation) RX -= 12 }
		else if (key == "89") { if (manualRotation) RY -= 12 }
		else if (key == "90") { if (manualRotation) RZ -= 12 }
		else if (key == "100") DIST+=40
		else if (key == "68") DIST-=40
		else if (key == "109") manualRotation = !manualRotation
		else if (key == "110") { RZ=0; RX=90; RY=360; RXD=4; RYD=RZD=0 }
		else if (key == "98") { useBobs++; if (useBobs > 2) useBobs=0; drawNextSystem=true; extraFlag="D"; }
		else if (key == "32") useLight = !useLight
		else if (key == "105") { extraIteration--; drawNextSystem=true; extraFlag="D"; }
		else if (key == "73") { extraIteration++; drawNextSystem=true; extraFlag="D"; }
		else if (key == "13") { singleAxis=!singleAxis; drawNextSystem=true; extraFlag="D"; }
		else if (key == "112") WScript.Echo("\"cmdgfx: \" K")
		else if (key == "114") RX = RY = RZ = 0
		else if (key == "115") { exec = Shell.Exec('cmd /c echo ' + modRotX + ' >>modXOut.txt'); exec.StdOut.ReadAll(); }
		else if (key == "331") { modRotX = 0; drawNextSystem=true; extraFlag="D"; extraIteration=0; systemIndex--; if (systemIndex < 0) systemIndex=LSystems.length-1 }
		else if (key == "97") { modRotX += 0.2; drawNextSystem=true; extraFlag="D"; }
		else if (key == "65") { modRotX -= 0.2; drawNextSystem=true; extraFlag="D"; }

		else if (key != "0") { modRotX = 0; drawNextSystem=true; extraFlag="D"; extraIteration=0; systemIndex++; if (systemIndex >= LSystems.length) systemIndex=0 }
	}
	
	if (ti[23] == "1")
	{
		W=Number(ti[25])*8+1, H=Number(ti[27])*12+1
		XMID=Math.floor(W/2), YMID=Math.floor(H/2)
		Shell.Exec('cmdwiz showcursor 0')
	}
}

/*
Character        Meaning
   F	         Move forward by line length drawing a line
   f	         Move forward by line length without drawing a line
   +	         Turn left by turning angle
   -	         Turn right by turning angle
   |	         Reverse direction (ie: turn by 180 degrees)
   &	         Swap the meaning of + and -
   [	         Push current drawing state onto stack
   ]	         Pop current drawing state from the stack
   >	         Multiply the line length by the line length scale factor
   <	         Divide the line length by the line length scale factor
   @	         Draw a dot with line width radius
   (	         Decrement turning angle by turning angle increment
   )	         Increment turning angle by turning angle increment
Not implemented:
   #	         Increment the line width by line width increment
   !	         Decrement the line width by line width increment
   {	         Open a polygon
   }	         Close a polygon and fill it with fill colour
*/
