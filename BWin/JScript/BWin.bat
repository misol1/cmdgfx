@if (true == false) @end /*
@echo off
setlocal EnableDelayedExpansion
cd "%~dp0"
if not defined __ (
	if exist NewDrop rd /S /Q NewDrop >nul 2>nul
	if not "%~1"=="" (
		call :PROCESS_NEWDROP %* 
		mode 60,30 & tasklist /FI "WINDOWTITLE eq BWin misol GUI 101" | find "cmd.exe" >nul 2>nul & set /a isNew=!errorlevel!
		if "!isNew!"=="0" goto :eof
	)
)
set /a W=120, H=75, WPAGES=3, WWW=W*WPAGES, HH=H*2, FONT=2, MAXTW=256, MAXTH=256
cmdwiz setfont %FONT% & mode %W%,%H% & cls & cmdwiz showcursor 0
if not defined __ (
	cmdwiz getquickedit & set /a QE=!errorlevel!
	cmdwiz setquickedit 0
	set __=.
	cmdgfx_input M30nxW30R | call %0 %* | cmdgfx_gdi "" Sf%FONT%:0,0,%WWW%,%HH%,%W%,%H%G%MAXTW%,%MAXTH%N250
	cmdwiz setquickedit !QE!
	cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
	endlocal
	goto :eof
)

title BWin misol GUI 101
if exist centerwindow.bat call centerwindow.bat 0 -20
set DIRCMD=
::cmdwiz setwindowpos k k topmost

cscript //nologo //e:javascript "%~dpnx0" %*
::cmdwiz getch & rem Enable this line to see jscript parse errors

echo "cmdgfx: quit"
title input:Q
rd /S /Q _processed >nul 2>nul
mode 80,50 & cmdgfx_gdi ""
endlocal
exit /b 0 */


function Window(name, init, update, content, x, y, width, height, xa, ya, closeable, resizeable, scrollable, maximized, keyboardHog) {
	this.name = name;
	this.init = init;
	this.update = update;
	this.content = content;
	this.x = x;
	this.y = y;
	this.width = width;
	this.height = height;
	this.xa = xa;
	this.ya = ya;
	this.closeable = closeable;
	this.resizeable = resizeable;
	this.scrollable = scrollable;
	this.maximized = maximized;
	this.keyboardHog = keyboardHog;
	this.xo = this.yo = this.wo = this.ho = 0;
}

function WindowStart(w) {
	eval(w.init)
}

function WindowUpdate(w) {
	eval(w.update)
}

function Execute(cmd) {
	var exec = Shell.Exec("cmd /c " + cmd)
	exec.StdOut.ReadAll()
	return exec.exitCode
}

function ExecuteAsync(cmd) {
	var exec = Shell.Exec("cmd /c " + cmd)
}

function GetCmdVar(name) {
	return Execute("exit %" + name + "%")
}

var windows = [
    new Window("Animation", "w.index=0", "w.index=(w.index+1)% 20, REPL1=Math.floor(w.index/2)", "image img/spiral/REPL1.txt 8 0 # -1 OFF_X,OFF_Y 0 0 OFF_W,OFF_H", 7,28, 50,40, 0,0, true, true, false, false, 0),
	 
	 new Window("Test Image", "", "", "image img/apa.gxy 0 0 0 -1 OFF_X,OFF_Y 0 0 OFF_W,OFF_H", 71,6, 40,30, 1,1, true, true, false, false, 0),
	 
	 new Window("centerwindow.bat", "", "", "image centerwindow.bat \\b 0 0 -1 OFF_X,OFF_Y", 63,55, 52,16, 1,1, true, false, true, false, 0),
	 
	 new Window("Plasma", "w.a1=0,w.a2=0", "w.a1+=(w.a1+1)% 20, w.a2+=(w.a2+3)% 50, REPL1=w.a1, REPL2=w.a2", "block 0 OFF_X,OFF_Y,OFF_W,OFF_H OFF_X,OFF_Y -1 0 0 01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db random()*1.5+sin((x-REPL1/4)/80)*(y/2)+cos((y+REPL2/5)/35)*(x/3)", 10,4, 50,35, 1,1, true, true, false, false, 0),
	 
    new Window("Doom", "w.index=0", "w.index=(w.index+1)% 20, REPL1=Math.floor(w.index/10)", "image img/uglyREPL1.pcx 0 0 # 14 OFF_X,OFF_Y 0 0 OFF_W,OFF_H", 29,12, 50,40, 0,-1, true, true, false, false, 0),
	 
    new Window("3d Object", "w.ry=0", "w.ry+=22, REPL1=w.ry, REPL2=MID_OFF_X, REPL3=MID_OFF_Y, REPL4=12000-OFF_W*35", "3d objects/shark.ply 2,1 REPL1,REPL1,0 0,0,0 2,2,2,0,0,0 0,0,0,0 REPL2,REPL3,REPL4,1 PAL3D", 65,33, 50,40, 0,0, true, true, false, false, 0),
	 
    new Window("Scroll", "w.index=0", "w.index=(w.index+1)% 230, REPL1=OFF_X - Math.floor(w.index/3)", "text a 0 0 ______________________________________Scrolling_without_\\e0block\\r_operation...____________________________________ REPL1,OFF_Y", 11,69, 35,3, 1,1, true, false, false, false, 0),

	new Window("Time", "", "var d = new Date(); REPL1=OFF_X+11, REPL2=d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2), REPL3=('0' + d.getHours()).slice(-2) + ':' + ('0' + d.getMinutes()).slice(-2) + ':' + ('0' + d.getSeconds()).slice(-2)", "text b 0 0 REPL2 OFF_X,OFF_Y & text f 0 0 REPL3 REPL1,OFF_Y", 1,1, 25,5, 3,2, true, false, false, false, 0),
	
	new Window("Explorer \\80(SPACE=open, \\g1e\\g1f\\g11\\g10=move)", "w.path=File.GetAbsolutePathName('.').substring(2); w.offset=0, w.current=0, w.readFiles=false;", "if (w.readFiles == false) { w.readFiles=true; w.offset=0, w.current=0; Execute('if not exist _processed mkdir _processed >nul 2>nul'); Execute('dir /B /AD /OGN \"' + w.path + '\" > _processed\\\\folderlist.txt'); Execute('dir /B /A-D /OGN \"' + w.path + '\" > _processed\\\\filelist.txt'); w.files=[]; w.folders=[]; w.folders.push('..'); var iStream = File.OpenTextFile('_processed\\\\folderlist.txt', 1, false); while(!iStream.AtEndOfStream) { w.folders.push(iStream.ReadLine()); } iStream.Close(); iStream = File.OpenTextFile('_processed\\\\filelist.txt', 1, false); while(!iStream.AtEndOfStream) { w.files.push(iStream.ReadLine()); } iStream.Close(); }" +
	"if (w == focusWin) {" +
		"if (KEY==32 || M_LB_DBL==1) { if (w.current >= w.folders.length) { Execute('if not exist NewDrop mkdir NewDrop >nul 2>nul'); tempPath=w.path; if (tempPath.length > 1) tempPath += '\\\\'; Execute('copy /Y \"' + tempPath + w.files[w.current - w.folders.length] + '\" NewDrop >nul 2>nul'); Execute('echo Done>NewDrop\\\\Done.txt 2>nul'); } else { if (w.current > 0) { if (w.path.length > 1) w.path += '\\\\'; w.path += w.folders[w.current]; w.readFiles=false; } else { li = w.path.lastIndexOf('\\\\'); if (li > 0) { w.path=w.path.substring(0,li); } else { w.path = '\\\\'; } w.readFiles=false; } } } " +
		"if (KEY==328) w.current--; if (w.current < 0) w.current=0;" +
		"if (KEY==336) w.current++; if (w.current >= w.folders.length + w.files.length - 1) w.current=w.folders.length + w.files.length - 1;" +
		"if (KEY==331) w.current=0;" +
		"if (KEY==333) w.current=w.folders.length + w.files.length - 1;" +
		"if (M_LB ==1) w.current=M_Y - w.y - 2; if (w.current < 0) w.current=0; if (w.current >= w.folders.length + w.files.length - 1) w.current=w.folders.length + w.files.length - 1;" +
	"}" +
	"w.offset=0; if (w.current > (w.height-4)) w.offset=-(w.current-(w.height-4));" +
	"out='\\\\0f\\\\b0'; tempI=0; for (j=0; j < w.folders.length; j++) { if (tempI == w.current) out += '\\\\r' + w.folders[j] + '/\\\\r'; else out+=w.folders[j] + '/'; out+='\\\\n'; tempI++; }" +
	"out+='\\\\0f\\\\70'; for (j=0; j < w.files.length; j++) { if (tempI == w.current) out += '\\\\r' + w.files[j] + '\\\\r'; else out+=w.files[j]; out+='\\\\n'; tempI++; }" +
	"REPL1=out.replace(/ /g,'_'), REPL2=w.path.replace(/\\\\/g,'/'), REPL3=OFF_Y + w.offset; if (w.path.length > 1) REPL2 += '/';", "text b 0 0 \\nREPL1 OFF_X,REPL3 & text e 0 0 REPL2__________________________________________________________________________________________________________________________________________________________ OFF_X,OFF_Y", 54,37,64,35,1,1,true,true,false,false,1)
	
	
];

// for (i = 0; i < 90; i++) windows.push(new Window("centerwindow.bat", "", "", "image centerwindow.bat \\b 0 0 -1 OFF_X,OFF_Y", 63,55, 52,16, 1,1, true, false, true, false, 0))

var Shell = new ActiveXObject("WScript.Shell");
var File = new ActiveXObject("Scripting.FileSystemObject");

var FONT=GetCmdVar("FONT")
var W=GetCmdVar("W")
var H=GetCmdVar("H")
var WPAGES=GetCmdVar("WPAGES")
var MAXTW=GetCmdVar("MAXTW")
var MAXTH=GetCmdVar("MAXTH")
var WWW=W*WPAGES, HH=H*2

var MID_OFF_X=W+(WWW-W)/2
var MID_OFF_Y=H, SEL_WIN=0, DRAG_MODE=0, KEY=0
var BORDER_TEXT_XP=5, BORDER_CLOSE_XP=5, FULLSCREEN=false
var BKG="3 0 fa"
var BKGUPDATE=""
var BORDER_COL="7 0"
var TITLE_COL="7 0"
var FOCUS_COL="f 0"
var RESIZE_COL="f 0"
var CLOSE_COL="7 0"
var MAX_COL="7 0"
var CLEAR_COL="0 0 20"
var TEXT_COL="b 0"
var SS = []; SS[0]="skip"; SS[1]=""
var PAL3D="f b b2 f b b2 f b b1 f b b0 b 0 db b 7 b2 b 7 b1 7 0 db 9 7 b1 9 7 b2 9 0 db 9 1 b1 9 1 b0 1 0 db 1 0 b2 1 0 b1 0 0 db"
var IGNORE_SIZE=false

var NOF_WIN=1000

if (File.FileExists("NewDrop/Done.txt")) NOF_WIN=0

if (NOF_WIN < windows.length) windows.splice(NOF_WIN, windows.length - NOF_WIN)

for (i = 0; i < windows.length; i++) {
	win = windows[i];
	if (win.maximized) {
		win.xo=win.x, win.yo=win.y, win.wo=win.width, win.ho=win.height
		win.x=0, win.y=0, win.width=W, win.height=H
	}
}

for (i = 0; i < windows.length; i++) { WindowStart(windows[i]); }

while(true) {
	var winStr=""

	if (BKGUPDATE != "")
		eval(BKGUPDATE)
	
	var TBKG=BKG.replace(/OFF_W/g, W)
	var TBKG=TBKG.replace(/OFF_H/g, H)
	WScript.Echo("\"cmdgfx: fbox " + TBKG + "\" n")
	
	for (i = 0; i < windows.length; i++) {
		winStr=""
	
		win = windows[i]
		if(win.maximized) { win.width = W; win.height=H; }

		var REPL1=0, REPL2=0, REPL3=0, REPL4=0, REPL5=0, REPL6=0, REPL7=0, REPL8=0, REPL9=0, REPL0=0
		var x = MID_OFF_X - Math.floor(win.width/2), y = MID_OFF_Y - Math.floor(win.height/2)
		var OFF_X = x + win.xa, OFF_Y = y + win.ya, OFF_W = win.width, OFF_H = win.height 

		focusWin = windows[windows.length - 1]
	
		WindowUpdate(win);
						
		var content = win.content
		content = content.replace(/OFF_X/g, OFF_X)
		content = content.replace(/OFF_Y/g, OFF_Y)
		content = content.replace(/OFF_W/g, OFF_W)
		content = content.replace(/OFF_H/g, OFF_H)
		content = content.replace(/REPL1/g, REPL1)
		content = content.replace(/REPL2/g, REPL2)
		content = content.replace(/REPL3/g, REPL3)
		content = content.replace(/REPL4/g, REPL4)
		content = content.replace(/REPL5/g, REPL5)
		content = content.replace(/REPL6/g, REPL6)
		content = content.replace(/REPL7/g, REPL7)
		content = content.replace(/REPL8/g, REPL8)
		content = content.replace(/REPL9/g, REPL9)
		content = content.replace(/REPL0/g, REPL0)
		content = content.replace(/PAL3D/g, PAL3D)
		
		var textPos = x + BORDER_TEXT_XP
		var closePos= x + (win.width-1) - BORDER_CLOSE_XP
		var borderRightX = x + (win.width-1)
		var borderBottomY = y + (win.height-1)
		var maxPos = closePos - 2
		var name = win.name.replace(/ /g,"_")
		var tCol = TITLE_COL; if (i == windows.length - 1) tCol=FOCUS_COL
		
		var ifclose="skip"; if (win.closeable) ifclose=""
		var ifmax="skip"; if (win.resizeable) ifmax=""
		var RESIZE=win.resizeable; if (win.maximized) RESIZE=false
		var ifresize="skip"; if (RESIZE) ifresize=""
		
		var box="box " + BORDER_COL + " cd " + x + "," + y + "," + (win.width-1) + "," + (win.height-1) + " & box " + BORDER_COL + " ba " + x + "," + y + ",0," + (win.height-1) + " & box " + BORDER_COL + " ba " + borderRightX + "," + y + ",0," + (win.height-1)
		box += " & text " + tCol + " 0 _" + name + "_ " + textPos + "," + y
		box += " & " + ifclose + " text " + CLOSE_COL + " 0 _X_ " + closePos + "," + y
		box += " & " + ifmax + " text " + MAX_COL + " 0 _\\gf2_ " + maxPos + "," + y
		box += " & pixel " + BORDER_COL + " c9 " + x + "," + y + " & pixel " + BORDER_COL + " bb " + borderRightX + "," + y + " & pixel " + BORDER_COL + " c8 " + x + "," + borderBottomY + " & pixel " + BORDER_COL + " bc " + borderRightX + "," + borderBottomY
		box += " & " + ifresize + " pixel " + RESIZE_COL + " fe " + borderRightX + "," + borderBottomY
		
		winStr += " & fbox " + CLEAR_COL + " " + x + "," + y + "," + win.width + "," + win.height + " & " + content + " & " + box + " & block 0 " + x + "," + y +"," + win.width + "," + win.height + " " + win.x + "," + win.y
		// WScript.Echo(content)
		
		WScript.Echo("\"cmdgfx: " + winStr + "\" n")
	}

	WScript.Echo("\"cmdgfx: \" ")

	var input = WScript.StdIn.ReadLine()
	var tokens = input.split(/\s+/)
	
	var KEY = Number(tokens[5])
	var M_EVENT = Number(tokens[7])
	var M_X = Number(tokens[9])
	var M_Y = Number(tokens[11])
	var M_LB = Number(tokens[13])
	var M_RB = Number(tokens[15])
	var M_LB_DBL = Number(tokens[17])
	var M_RB_DBL = Number(tokens[19])
	var M_WHEEL = Number(tokens[21])
	var SIZE_EVENT = Number(tokens[23])
	var SIZE_W = Number(tokens[25])
	var SIZE_H = Number(tokens[27])

	if (M_EVENT==1 && windows.length > 0) {
		if (M_LB==1) {
			if (SEL_WIN == 0) {
				SEL_WIN=-2, SEL_INDEX=-1, CLOSE_WIN=-1, MAX_WIN=-1
				
				for (i=0; i < windows.length; i++) {
					win = windows[i]
					BORDER_RIGHT_X=win.x+win.width-1, BORDER_BOTTOM_Y=win.y+win.height-1
					CLOSEPOS=win.x+win.width-1-BORDER_CLOSE_XP+1, MAXPOS=CLOSEPOS-2
					if (M_X >= win.x && M_Y >= win.y && M_X <= BORDER_RIGHT_X && M_Y <= BORDER_BOTTOM_Y) { SEL_WIN=i+1, DRAG_MODE=1; if (win.maximized) DRAG_MODE=0 }
					if (win.closeable && M_X == CLOSEPOS && M_Y == win.y) { SEL_WIN=-2, CLOSE_WIN=i+1 }
					if (win.resizeable && win.maximized==false && M_X == BORDER_RIGHT_X && M_Y == BORDER_BOTTOM_Y) { SEL_WIN=i+1, DRAG_MODE=2 }
					if (win.resizeable && M_X == MAXPOS && M_Y == win.y) { SEL_WIN=i+1, DRAG_MODE=0, MAX_WIN=i+1 }
				}
				
				if (SEL_WIN > 0) {
					win = windows[SEL_WIN-1]
					ORGMX=M_X, ORGMY=M_Y, ORGWX=win.x, ORGWY=win.y, ORGWW=win.width, ORGWH=win.height
					if (SEL_WIN-1 < windows.length - 1) {
						windows.splice(SEL_WIN-1, 1); windows.push(win);
					}
				}
				
				if (CLOSE_WIN > 0) { windows.splice(CLOSE_WIN-1, 1) }

				if (MAX_WIN > 0) { win=windows[windows.length-1]; if (win.maximized==false) { win.xo=win.x, win.yo=win.y, win.wo=win.width, win.ho=win.height, win.x=0, win.y=0, win.width=W, win.height=H, win.maximized=true } else { win.x=win.xo, win.y=win.yo, win.width=win.wo, win.height=win.ho, win.maximized=false } }
				
			} else if (SEL_WIN > 0) {
				if (DRAG_MODE == 1) { win=windows[windows.length-1]; win.x=ORGWX + M_X-ORGMX, win.y=ORGWY + M_Y-ORGMY }
				if (DRAG_MODE == 2) { 
					win=windows[windows.length-1];
					win.width=ORGWW + M_X-ORGMX, win.height=ORGWH + M_Y-ORGMY
					if (win.height < 4) win.height=4
					if (win.height > H) win.height=H
					if (win.width > W) win.width=W
					if (win.width < win.name.length + 16) win.width=win.name.length + 16
				}
			}
		} else {
			SEL_WIN=0, DRAG_MODE=0
		}
		
		if (M_WHEEL != 0 && windows.length > 0) { win=windows[windows.length-1]; if (win.scrollable) { win.ya-=M_WHEEL*2; if (win.ya >= 1) win.ya=1 }}
	}
	
	if (KEY > 0) {
		var KBHOG=0; if (windows.length > 0) KBHOG=windows[windows.length - 1].keyboardHog
	
		if (KEY == 27) break
		if (KEY == 112 && KBHOG == 0) WScript.Echo("\"cmdgfx: \" K")
		if (KEY == 9 && KBHOG < 3 && windows.length > 1) {
			var shiftPressed = Execute('cmdwiz getkeystate shift > nul')
			if (shiftPressed) {
				var lastwin = windows.pop(); windows.splice(0, 0, lastwin);
			} else {
				var firstwin = windows[0]; windows.splice(0, 1); windows.push(firstwin);
			}
		} 
		
		if (windows.length > 0) {
			win = windows[windows.length - 1];
		
			if (win.maximized==false) {
				if (KBHOG == 0) {
					if (KEY == 328) { win.y-=1, LIM=-win.height+1; if (win.y <= LIM) win.y=LIM }
					if (KEY == 336) { win.y+=1; if (win.y >= H-1) win.y=H-1 }
					if (KEY == 331) { win.x-=1, LIM=-win.width+1; if (win.x <= LIM) win.x=LIM }
					if (KEY == 333) { win.x+=1; if (win.x >= W-1) win.x=W-1 }
				}
				if (win.resizeable) {
					if (KEY == 411) { win.width-=1; if (win.width < 16+win.name.length) win.width=16+win.name.length }
					if (KEY == 413) { win.width+=1; if (win.width > W) win.width=W }
					if (KEY == 408) { win.height-=1; if (win.height < 4) win.height=4 }
					if (KEY == 416) { win.height+=1; if (win.height > H) win.height=H }
				} 
			}
			if (win.scrollable) {
				if (KEY == 329) { win.ya+=1; if (win.ya >= 1) win.ya=1 }
				if (KEY == 337) { win.ya-=1; }
				//if (KEY == 327) { win.xa+=1; if (win.xa >= 1) win.xa=1 }
				//if (KEY == 335) { win.xa-=1; tmp=-MAXTW+win.width; if (win.xa < tmp) win.xa=tmp }
			}
			var tmp = -MAXTH+win.height; if (win.ya < tmp) win.ya=tmp
		}

		if (FULLSCREEN == false) {
			if (KEY == 371) { W-=3; if (W < 60) W=60; WWW=W*WPAGES, MID_OFF_X=W+(WWW-W)/2 }
			if (KEY == 372) { W+=3; WWW=W*WPAGES, MID_OFF_X=W+(WWW-W)/2 }
			if (KEY == 397) { H-=3; if (H < 40) H=40; HH=H*2, MID_OFF_Y=H }
			if (KEY == 401) { H+=3; HH=H*2, MID_OFF_Y=H }
			if (KEY == 371 || KEY == 372 || KEY == 397 || KEY == 401) {
				Execute('mode ' + W + "," + H); WScript.Echo("\"cmdgfx: \" f" + FONT + ":0,0," + WWW + "," + HH + "," + W + "," + H)
				IGNORE_SIZE=true
			}
		}

		if (KEY == 10 || (KEY == 13 && KBHOG < 2)) {
			SetFullScreen(!FULLSCREEN)
			IGNORE_SIZE=true
		}
	}
	
	if (SIZE_EVENT==1) {
		if (IGNORE_SIZE==false) {
			W=SIZE_W; H=SIZE_H;
			WWW=W*WPAGES, MID_OFF_X=W+(WWW-W)/2;
			HH=H*2, MID_OFF_Y=H
			WScript.Echo("\"cmdgfx: \" f" + FONT + ":0,0," + WWW + "," + HH + "," + W + "," + H)
			Execute('cmdwiz showcursor 0')
			FULLSCREEN = Execute('cmdwiz getfullscreen')
		}
		IGNORE_SIZE=false
	}
	
	if (File.FileExists("NewDrop/Done.txt")) {
		NewDrop()
	}
}

function NewDrop() {
	var NEW_X=6, NEW_Y=6, OLDFS=FULLSCREEN, OW=W, OH=H

	Execute("if not exist _processed mkdir _processed >nul 2>nul")

	var f = File.GetFolder("NewDrop"); 
	var fc = new Enumerator(f.files); 
	for (; !fc.atEnd(); fc.moveNext()) { 
	
		var name = fc.item().name
		var convname = name.replace(/ /g,"~")
		var ext = ""
		var tokens = name.split("\.")
		if (tokens.length > 1) ext = tokens[tokens.length - 1]
	
		if (name != "Done.txt") {
				Execute('copy /Y "' + fc.item() + '" _processed >nul 2>nul')

			if (ext == "wav") {
				ExecuteAsync('cmdwiz playsound "' + name + '"')
			} else if (ext == "cfg") {
				var iStream = File.OpenTextFile(fc.item(), 1, false)
				var winData = ""
				while(!iStream.AtEndOfStream) { winData += iStream.ReadLine() + "\n" }
				iStream.Close()
				eval(winData)
			} else {
				var NOCODE="\\", SCALE="", init="", update="", XA=1, YA=1, SCROLL=true
				
				if (ext == "pcx" || ext == "gxy") { NOCODE="", SCALE="OFF_W,OFF_H", XA=0, YA=0, SCROLL=false }
				var content = "image _processed/" + convname + " " + NOCODE + TEXT_COL + " 0 -1 OFF_X,OFF_Y 0 0 " + SCALE
				if (ext == "ply" || ext == "plg" || ext == "obj") { 
					init="w.ry=0"
					update="w.ry+=22, REPL1=w.ry, REPL2=MID_OFF_X, REPL3=MID_OFF_Y, REPL4=12000-(OFF_W*35)"
					content="3d _processed/" + convname + " 2,1 REPL1,REPL1,0 0,0,0 2,2,2,0,0,0 0,0,0,0 REPL2,REPL3,REPL4,1 PAL3D"
					XA=0, YA=0, SCROLL=false
				}
				
				var win = new Window(name, init, update, content, NEW_X,NEW_Y, 50,40, XA, YA, true, true, SCROLL, false, 0)

				if (ext == "met") {
					var iStream = File.OpenTextFile(fc.item(), 1, false)
					var winData = ""
					while(!iStream.AtEndOfStream) { winData += iStream.ReadLine() + "\n" }
					iStream.Close()
					var w=win
					eval(winData)
				}
				
				if (win.init != "") WindowStart(win)

				if (win.maximized) {
					win.xo=win.x, win.yo=win.y, win.wo=win.width, win.ho=win.height
					win.x=0, win.y=0, win.width=W, win.height=H
				}
				
				windows.push(win)
				NEW_X+=2; NEW_Y+=2
			}
		}
	} 

	if (W != OW || H != OH) {
		if (OLDFS == true) {
			OLDW=W, OLDH=H
			W=OW, H=OH
		} else {
			WWW=W*WPAGES, MID_OFF_X=W+(WWW-W)/2
			HH=H*2, MID_OFF_Y=H
			Execute('mode ' + W + "," + H); WScript.Echo("\"cmdgfx: \" f" + FONT + ":0,0," + WWW + "," + HH + "," + W + "," + H)
		}
	}
	
	if (FULLSCREEN != OLDFS) SetFullScreen(FULLSCREEN)
	
	Execute("rd /S /Q NewDrop")
	
	for (i=0; i < 5; i++)
		Execute("cmdwiz setwindowpos k k")
}

function SetFullScreen(bFull) {
	if(bFull) {
		FULLSCREEN=true
		OLDWX = Execute('cmdwiz getwindowbounds x')
		OLDWY = Execute('cmdwiz getwindowbounds y')
		OLDW=W, OLDH=H
		Execute('cmdwiz fullscreen 1')
		Execute('cmdwiz showcursor 0')
		W = Number(Execute('cmdwiz getconsoledim sw')) + 1
		H = Number(Execute('cmdwiz getconsoledim sh')) + 3
		WWW=W*WPAGES, HH=H*2
		WScript.Echo("\"cmdgfx: \" f" + FONT + ":0,0," + WWW + "," + HH + "," + W + "," + H)
	} else {
		FULLSCREEN=false
		Execute('cmdwiz fullscreen 0')
		Execute('cmdwiz showcursor 0')
		Execute('cmdwiz setwindowpos ' + OLDWX + ' ' + OLDWY)
		W=OLDW, H=OLDH
		Execute('mode ' + W + "," + H)
		WWW=W*WPAGES, HH=H*2
		WScript.Echo("\"cmdgfx: \" f" + FONT + ":0,0," + WWW + "," + HH + "," + W + "," + H)
	}
	MID_OFF_X=W+(WWW-W)/2
}

// inclusive min and inclusive max
function GetRandom(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

/*
:PROCESS_NEWDROP
if "%~1" == "" goto :eof
mkdir NewDrop >nul 2>nul
:REP
copy /y "%~1" NewDrop> nul 2>nul
shift
if not "%~1" == "" goto :REP
echo Done>NewDrop\Done.txt
goto :eof
*/
