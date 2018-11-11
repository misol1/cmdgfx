@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off
cd /D "%~dp0"
if defined __ goto :START

cls & cmdwiz setfont 6
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100
cmdwiz getconsoledim sw
set /a W6=%errorlevel% + 1
cmdwiz getconsoledim sh
set /a H6=%errorlevel% + 2
set /a W=W6*2, H=H6*2

set __=.
call %0 %* | cmdgfx_gdi "" %TOP%m0OSf0:0,0,%W%,%H%W30 000000,555555
set __=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set W6=&set H6=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a RX=2*53, RY=6*53, RZ=-4*53
set /a XMID=!W!/2, YMID=!H!/2
set /a DRAWMODE=0, DIST=500, RANDVAL=3
set ASPECT=1.2

set PAL=0 0 fe 0 0 b1 0 0 fe 0 0 b0
set FNAME=eye.obj& set MOD=4.0,4.0,4.0, 0,-132,0 1

set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	echo "cmdgfx: fbox 0 0 A & 3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & 3d objects\!FNAME! 3,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & block 0 0,0,!W!,!H! 0,0 -1 0 0 ? random()*!RANDVAL!+fgcol(y,y) & skip %EXTRA%%EXTRA%%EXTRA%"

	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
		
	set /a RX+=2, RY+=6, RZ-=4
	
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! neq 0 set STOP=1
	if !MOUSE_EVENT! neq 0 set STOP=1
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 150
echo "cmdgfx: quit"
title input:Q

