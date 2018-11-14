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
set /a H6=%errorlevel% + 3
if "%~2"=="U" set /a H6 += 4
set /a W=W6*2, H=H6*2
cls & cmdwiz showcursor 0
set /a WW=W*2

set __=.
call %0 %* | cmdgfx_gdi "" m0OW10Sf0:0,0,%WW%,%H%,%W%,%H%N315Z500
set __=
set W=&set H=&set WW=&set F6W=&set F6H=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a RX=0, RY=0, RZ=0, XMID=W/2, YMID=H/2, XMID2=W/2+W, DIST=2500, DRAWMODE=2, WW=W*2, ZVAL=500+(H-100)*6
set ASPECT=0.7083

set PAL=f e b2  f e b2  f e b1  f e b0  e 0 db  e c b2  e c b1  c 0 db  c 4 b1  c 4 b2  4 0 db  4 0 b1 4 0 b0 4 0 db  4 0 b2  4 0 b1  0 0 db  0 0 db
call :MAKESPLIT

set STOP=
:REP
for /L %%1 in (1,1,400) do if not defined STOP (
	echo "cmdgfx: fbox 8 0 . & 3d objects\torus.plg !DRAWMODE!,0 !RX!,!RY!,!RZ! 0,0,0 -1,-1,-1, 0,0,0 1,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & 3d objects\springy1.plg !DRAWMODE!,0 !RY!,!RZ!,!RZ! 0,0,0 -1,-1,-1, 0,0,0 1,-4000,0,10 !XMID2!,!YMID!,!DIST!,%ASPECT% !PAL! & !SPLITSCR:~1,-1!" f0:0,0,!WW!,!H!,!W!,!H!Z!ZVAL!
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
	
	set /a RX+=2, RY+=6, RZ-=4, RR=!RANDOM! %% 100
	if !RR! lss 10 set /a RY+=1
	if !RR! lss 5 set /a RX+=1
	
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch & set /a CKEY=!errorlevel! & if !CKEY! == 115 echo "cmdgfx: " c:0,0,%W%,%H%
	if !KEY! gtr 0 set STOP=1
	if !MOUSE_EVENT! == 1 set STOP=1
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
goto :eof

:MAKESPLIT
set SPLITSCR=""& for /l %%a in (1,2,%H%) do set SPLITSCR="!SPLITSCR:~1,-1! & block 0 %W%,%%a,%W%,1 0,%%a"
