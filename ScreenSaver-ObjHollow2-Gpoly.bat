@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off
cd /D "%~dp0"
if defined __ goto :START

cls & cmdwiz setfont 6
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100
cmdwiz getdisplaydim w
set /a W=%errorlevel%/3+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/3+1
cmdwiz showcursor 0

set __=.
call %0 %* | cmdgfx_gdi "" %TOP%m0OW10Sfc:0,0,%W%,%H%N315
set __=&set W=&set H=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a RX=0, RY=0, RZ=0, XMID=W/2, YMID=H/2, XMID2=W/2+W, DIST=2500, ZVAL=100+(H-100)*6, ASPECT=1
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra

set DRAWMODE=2
set RGBPAL=000011,ffffff,eeeeee,dddddd,cccccc,bbbbbb,aaaaaa,999999,888888,777777,666666,555555,444444,333333,222222,111111
::set RGBPAL=000011,ffffff,eeeeee,dddddd,cccccc,bbbbbb,aaaaaa,999999,777788,666677,555566,444455,333344,222233,111122,000011
set PAL=2 0 0  3 0 0  4 0 0  5 0 0  6 0 0  7 0 0  8 0 0  9 0 0  a 0 0  b 0 0  c 0 0  d 0 0  e 0 0  f 0 0  f 0 0  f 0 0
set DRAWOP=01

::set DRAWMODE=0&set PAL=a 0 0  e 0 0  a 0 0  e 0 0  e 0 0  a 0 0  e 0 0  a 0 0 c 0 0  c 0 0  c 0 0  c 0 0  c 0 0  c 0 0  c 0 0  c 0 0  & set RGBPAL=- & set DRAWOP=7

:REP
for /L %%1 in (1,1,400) do if not defined STOP (
	echo "cmdgfx: fbox 0 0 . & 3d objects\hollowGPoly.plg !DRAWMODE!,!DRAWOP! !RX!,!RY!,!RZ! 0,0,0 -1,-1,-0.25, 0,0,0 1,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" fc:0,0,!W!,!H!Z!ZVAL! %RGBPAL%
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
	
	set /a RX+=2, RY+=6, RZ-=4, RR=!RANDOM! %% 100
	if !RR! lss 10 set /a RY+=1
	if !RR! lss 5 set /a RX+=1
	
	if !KEY! == 32 set /a KEY=0, DRAWMODE-=1 & if !DRAWMODE! lss 1 set /a DRAWMODE=2
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! gtr 0 set STOP=1
	if !MOUSE_EVENT! == 1 set STOP=1
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
