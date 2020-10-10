@if (true == false) @end /*
@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title L-System (right/left c d b i/I)
if defined __ goto :START
set __=.
cmdgfx_input.exe knW50xzR | call %0 %* | cmdgfx_gdi "" Sfa:0,0,1600,900
set __=
goto :eof

:START
set /a W=1600, H=900
set /a W6=W/8, H6=H/12
mode %W6%,%H6%
call centerwindow.bat 0 -16
call prepareScale.bat 10 1

cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors

set W6=&set H6=&set W=&set H=
echo "cmdgfx: quit"
title input:Q
cmdwiz showcursor 1 & mode 80,50
exit /b 0
*/

function Execute(cmd) {
	var exec = Shell.Exec("cmd /c " + cmd)
	exec.StdOut.ReadAll()
	return exec.exitCode
}
function GetCmdVar(name) {
	return Execute("exit %" + name + "%")
}

function LSystem(name, axiom, rules, linelen, linecolor, iterations, rotation, startRotation, updateFrequency, x, y) {
    this.name = name
	this.axiom = axiom
    this.rules = rules
    this.linelen = linelen
    this.linecolor = linecolor
    this.iterations = iterations
    this.rotation = rotation
    this.startRotation = startRotation
	this.updateFrequency = updateFrequency
	this.x = x
	this.y = y
}


var LSystems = [
    new LSystem("Plant", "X", ["X->1+[[X]-X]-1[-1X]+X", "F->FF", "1->F" ], 38, "2", 6, 25, 150, 10, 400, 870)
   ,new LSystem("Leaf", "a", ["F->>F<", "a->F[+1]F2", "b->F[-3]Fa", "x->a", "y->b", "1->x", "2->b", "3->y" ], 36, "c", 13, 45, 180, 2, 800, 860)
   ,new LSystem("Triangle", "F+F+F", ["F->F-F+F"], 95, "9", 7, 120, 0, 2, 800, 790)
   ,new LSystem("Hexagonal Gosper", "XF", ["X->X+1F++1F-FX--FXFX-1F+","Y->-FX+YFYF++YF+FX--FX-Y","1->Y"], 60, "b", 4, 60, 90, 4, 900, 850)
   ,new LSystem("Von Koch Snowflake", "F++F++F", ["F->F-F++F-F"], 15, "f", 5, 60, 90, 3, 400, 660)
   ,new LSystem("Sierpinski Arrowhead", "YF", ["X->1F+XF+1", "Y->XF-YF-X", "1->Y"], 50, "5", 7, 60, 90, 2, 360, 50)
   ,new LSystem("Weed", "F", ["F->FF-[12]+[12]", "X->+F2", "Y->-FX","1->X","2->Y" ], 38, "8", 6, 22.5, 180, 2, 800, 850)
   ,new LSystem("Board", "F+F+F+F", ["F->FF+F+F+F+FF"], 40, "5", 4, 90, 0, 6, 400, 50)
   ,new LSystem("Stick", "X", ["F->FF", "X->F[+X]F[-X]+X"], 23, "2", 7, 20, 180, 3, 800, 860)
   ,new LSystem("Bush 1", "Y", ["X->X[-FFF][+FFF]FX", "Y->YFX[+Y][-Y]"], 40, "2", 6, 25.7, 180, 3, 810, 840)
   ,new LSystem("Bush 2", "F", ["F->FF+[+F-F-F]-[-F+F+F]"], 55, "2", 4, 22.5, 180, 3, 810, 840)
   ,new LSystem("Bush 3", "F", ["F->F[+FF][-FF]F[-F][+F]F"], 38, "2", 4, 35, 180, 5, 800, 830)
   ,new LSystem("Hilbert", "X", ["X->-1F+XFX+F1-", "Y->+XF-YFY-FX+", "1->Y"], 65, "d", 6, 90, 0, 4, 1100, 120)
   ,new LSystem("Tiles", "F+F+F+F", ["F->FF+F-F+F+FF"], 95, "9", 3, 90, 0, 4, 850, 680)
   ,new LSystem("Pentaplexity", "F++F++F++F++F", ["F->F++F++F|F-F++F"], 45, "f", 4, 36, 0, 4, 400, 180)
   ,new LSystem("Crystal", "F+F+F+F", ["F->FF+F++F+F"], 30, "e", 4, 90, 0, 4, 450, 150)
   ,new LSystem("Square Sierpinski", "F+XF+F+XF", ["X->XF-F+F-XF+F+XF-F+F-X"], 35, "b", 5, 90, 0, 4, 350, 450)
   ,new LSystem("Koch Curve", "F+F+F+F", ["F->F+F-F-FF+F+F-F"], 22, "c", 3, 90, 0, 4, 550, 220)
   ,new LSystem("Dragon Curve", "FX", ["X->X+1F+", "Y->-FX-Y", "1->Y"], 95, "a", 13, 90, 0, 2, 920, 670)
   ,new LSystem("Rings", "F+F+F+F", ["F->FF+F+F+F+F+F-F"], 25, "c", 4, 90, 0, 6, 380, 660)
   ,new LSystem("Skipper", "F+F+F+F", ["F->F+1-FF+F+FF+F1+FF-1+FF-F-FF-F1-FFF", "f->ffffff", "1->f" ], 25, "9", 2, 90, 0, 10, 550, 220)
   ,new LSystem("Houdini", "F-F-F-F-F-F-F-F", ["F->F-–-F+F+F+F+F+F+F-–-F" ], 25, "f", 4, 45, 0, 150, 500, 550)
   ,new LSystem("Houdini", "F-F-F-F-F-F-F-F", ["F->F-–-F+F+F+F+F+F+F-–-F" ], 120, "b", 2, 45, 0, 150, 610, 520)
   ,new LSystem("Houdini", "F-F-F-F-F-F-F-F", ["F->F-–-F+F+F+F+F+F+F-–-F" ], 39, "d", 3, 14.5, 0, 150, 800, 450)
];

function DrawState(x, y, currRot, swap, linelen, rotation) {
	this.x = x
	this.y = y
	this.currRot = currRot
	this.swap = swap
	this.linelen = linelen
	this.rotation = rotation
}

function DrawSystem() {
	if (newRes) WScript.Echo("\"cmdgfx: fbox 1 0 0" + "\" " + "fa:0,0," + W + "," + H)
	if (clearScreen) WScript.Echo("\"cmdgfx: fbox 0 0 0" + "\" ")

	LS = LSystems[systemIndex]
	newRes = false
	
	current = LS.axiom
	rules = LS.rules
	linelen = LS.linelen
	color = LS.linecolor
	iterations = LS.iterations + extraIteration
	if (iterations < 1) { iterations=1; extraIteration++; }
	rotation = LS.rotation
	currRot = LS.startRotation*(Math.PI/180)
	scrUpdateFreq = LS.updateFrequency
	xp = LS.x + XPP, yp = LS.y + YPP

	rotation = rotation*(Math.PI/180)
	linelen = linelen/iterations
	if (expDrawing)
		scrUpdateFreq = Math.pow(scrUpdateFreq, iterations)
	else
		scrUpdateFreq = (scrUpdateFreq + 20) * iterations
	scrUpdateCounter = 0
	reverse = 180*(Math.PI/180)

	for (i=0; i < iterations; i++) {
		for (j=0; j < rules.length; j++) {
			current = current.replace(new RegExp(rules[j].substring(0,1), 'g'), rules[j].substring(3))
		}
	}

	bez = ""; if (drawBezier) bez = " "+Math.floor(W/2)+","+Math.floor(H/2)
	drawStates = []
	swap = 1

	for (i=0; i < current.length; i++) {
		ch = current.substring(i,i+1)
		if (ch == "+") currRot+=rotation*swap
		if (ch == "-") currRot-=rotation*swap
		if (ch == "|") currRot+=reverse
		if (ch == ">") linelen *= lineScaleFactor
		if (ch == "<") linelen /= lineScaleFactor
		if (ch == "(") rotation -= turnAngleIncrement
		if (ch == ")") rotation += turnAngleIncrement
		if (ch == "&") swap=-swap
		if (ch == "[") drawStates.push(new DrawState(xp, yp, currRot, swap, linelen, rotation))
		if (ch == "]") {
			drawState = drawStates.pop()
			xp = drawState.x, yp = drawState.y, currRot = drawState.currRot, swap = drawState.swap, linelen = drawState.linelen, rotation = drawState.rotation;
		}
		if (ch == "@") WScript.Echo("\"cmdgfx: pixel " + color + " 0 X " + Math.floor(xp) + "," + Math.floor(yp) + " \" n")
		if (ch == "F" || ch == "f") {
			oldxp = xp, oldyp = yp;
			xp = xp+Math.sin(currRot)*linelen
			yp = yp+Math.cos(currRot)*linelen
			if(ch == "F") WScript.Echo("\"cmdgfx: line " + color + " 0 X " + Math.floor(oldxp) + "," + Math.floor(oldyp) + "," + Math.floor(xp) + "," + Math.floor(yp) + bez + " \" n")
		}
	
		scrUpdateCounter++; if (seeDrawing && scrUpdateCounter >= scrUpdateFreq) { scrUpdateCounter=0; WScript.Echo("\"cmdgfx: \" ") }
	}

	WScript.Echo("\"cmdgfx: \" ")
}

WScript.Echo("\"cmdgfx: fbox 0 0 0" + "\" ")

clearScreen = true
seeDrawing = true
expDrawing = false
lineScaleFactor = 1.36
turnAngleIncrement = 5
turnAngleIncrement = turnAngleIncrement*(Math.PI/180)
drawBezier = false
extraIteration=0

systemIndex = 0
drawNextSystem = true
drawCounter = 0
newRes = false
firstRun = true

Shell = new ActiveXObject("WScript.Shell")
var W=GetCmdVar("W"), H=GetCmdVar("H"), rW=GetCmdVar("rW"), rH=GetCmdVar("rH")
XPP=Math.floor((W-1600)/2), YPP=Math.floor((H-900)/2)
YPP=0

while(true) {

	if (drawNextSystem) {
		DrawSystem()
		drawNextSystem = false
	}

	drawCounter++;
	if (drawCounter > 20) { WScript.Echo("\"cmdgfx: \" "); drawCounter = 0 }

	var input = WScript.StdIn.ReadLine()
	var ti = input.split(/\s+/)
	if (ti[3] == "1")
	{
		var key = ti[5]
		if (key == "27") break
		else if (key == "10") { exec = Shell.Exec('cmdwiz getfullscreen'); exec.StdOut.ReadAll(); if (exec.exitCode==0) Shell.Exec('cmdwiz fullscreen 1'); else Shell.Exec('cmdwiz fullscreen 0') }
		else if (key == "105") { extraIteration--; drawNextSystem=true; }
		else if (key == "73") { extraIteration++; if (extraIteration > 0) extraIteration=0; else drawNextSystem=true; }
		else if (key == "98") { drawBezier = !drawBezier; drawNextSystem=true; }
		else if (key == "99") { clearScreen = !clearScreen; if(clearScreen) drawNextSystem=true; }
		else if (key == "100") { seeDrawing = !seeDrawing; }
		else if (key == "331") { drawNextSystem=true; extraIteration=0; systemIndex--; if (systemIndex < 0) systemIndex=LSystems.length-1 }
		else if (key != "0") { drawNextSystem=true; extraIteration=0; systemIndex++; if (systemIndex >= LSystems.length) systemIndex=0 }
	}
	
	if (ti[23] == "1")
	{
		W=Math.floor(Number(ti[25])*8*rW/100+1), H=Math.floor(Number(ti[27])*12*rH/100+1)
		XPP=Math.floor((W-1600)/2), YPP=Math.floor((H-900)/2)
		Shell.Exec('cmdwiz showcursor 0')
		//Shell.Exec('cmdwiz setbuffersize - -')

		if (firstRun == false) {
			drawNextSystem = true
			newRes = true
		}
		firstRun = false
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

