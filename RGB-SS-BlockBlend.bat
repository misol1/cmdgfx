@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off

cd /D "%~dp0"
if defined __ goto :START

cmdwiz setfont 2
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%/8+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/8+1

set /a WW=W*2, WWW=W*3

set __=.
cmdgfx_input.exe m0nW8xR | call %0 %* | cmdgfx_RGB "" %TOP%Sf2:0,0,%WWW%,%H%,%W%,%H%
set __=
cls
cmdwiz fullscreen 0 & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="WW" if not "%%v"=="WWW" if not "%%v"=="H" set "%%v="
set /a WW2=WW+100
echo "cmdgfx: fbox 0 0 db & image img\123.bmp 0 0 K 0 !WW!,0 0 0 100,100 & image img\6hld.bmp 0 0 K 0 !WW2!,0 0 0 100,100"

call sindef.bat

set DRAW=""&set STOP=&set OUTP=&set OUTP2=

set /a P1=4,P2=3,P3=-2,P4=-1, SC=285,CC=-30,SC2=-295,CC2=-113

set /a "KEY=0, XMID=W/2, YMID=H/2, XMUL=(W-20)/4, YMUL=(H-20)/3, XMUL2=(W-30)/4, YMUL2=(H-20)/4"

set /a XI=5, XD=1, PC=250

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	echo "cmdgfx: !DRAW:~1,-1!" Ff2:0,0,!WWW!,!H!,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, MOUSE_EVENT=%%E 2>nul )
	
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! neq 0 set STOP=1
	if !MOUSE_EVENT! neq 0 set STOP=1
	
	set DRAW=""

	set /a "SC+=!P1!, CC+=!P2!, SC2+=!P3!, CC2+=!P4!, RAND=!RANDOM! %% 1000"
	if !RAND! lss 100 set /a SC2+=1
	if !RAND! gtr 900 set /a CC-=1
	if !RAND! gtr 500 if !RAND! lss 600 set /a SC+=1
	
	for %%a in (!SC!) do for %%b in (!CC!) do for %%d in (!SC2!) do for %%e in (!CC2!) do set /a A1=%%a,A2=%%b,A3=%%d,A4=%%e & set /a "XPOS=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!)+(%SINE(x):x=!A4!*31416/180%*!XMUL2!>>!SHR!), YPOS=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)+(%SINE(x):x=!A3!*31416/180%*!YMUL2!>>!SHR!)"

	for %%a in (!SC!) do for %%b in (!CC!) do for %%d in (!SC2!) do for %%e in (!CC2!) do set /a A1=%%a,A2=%%b,A3=%%d,A4=%%e & set /a "XPOS2=!XMID!+(%SINE(x):x=!A3!*31416/180%*!YMUL!>>!SHR!)+(%SINE(x):x=!A2!*31416/180%*!XMUL2!>>!SHR!), YPOS2=!YMID!+(%SINE(x):x=!A4!*31416/180%*!XMUL!>>!SHR!)+(%SINE(x):x=!A1!*31416/180%*!YMUL2!>>!SHR!)"
	
	
	set /a XPOS-=50, YPOS-=50, XPOS2-=50, YPOS2-=50 
	set /a XI+=!XD!, PC+=1
	if !XI! gtr 35 set /a XD=-1
	if !XI! leq 5 set /a XD=1
	set DRAW="block 2,8 !WW!,0,100,100 !XPOS!,!YPOS! db & block 0,32 !WW2!,0,100,100 !XI!,5 -1"
	if !PC! geq 500 set /a PC=0 & set DRAW="!DRAW:~1,-1! & block 0 !WW2!,0,100,100 140,20,66,66 -1 1 0 ????=??6b"

	set OUTP=&set OUTP2=&set OUTP3=

	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
