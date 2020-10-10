@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off

if defined __ goto :START

cd /D "%~dp0"
cls & cmdwiz setfont 8
mode 40,20 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%/6+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/8+1

cls & cmdwiz showcursor 0

set __=.
cmdgfx_input.exe m0nW14x | call %0 %* | cmdgfx_gdi "" %TOP%Sf1:0,0,!W!,!H!t4
cls & cmdwiz fullscreen 0 & cmdwiz showmousecursor 1 & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set __=& set W6=& set H6=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

set STREAM="01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"

call sindef.bat

set /a XMUL=300, YMUL=280, A1=155, A2=0, COLCNT3=0, FADEIN=0, FADEVAL=0, XMID=W/2, YMID=H/2
set ASPECT=0.6
set RANDPIX=1.5

set /a CNT=0

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!), RX+=7,RY+=12,RZ+=2, COLCNT3-=1, FADEIN+=!FADEVAL!/2, FADEVAL+=1

    set /a A1+=2, A2+=1 & echo "cmdgfx: block 0 0,0,!W!,!H! 0,0 -1 0 0 !STREAM:~1,-1! sin((x+!COLCNT!/10)/110)*88*sin((y+!COLCNT2!/5)/65)*98 & 3d objects\hulk.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 !XMID!,!YMID!,1600,%ASPECT% 0 9 0  0 9 0  0 9 1 0 9 0 & skip text a 0 0 [FRAMECOUNT] 1,1" Ff1:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a KEY=%%D, MOUSE_EVENT=%%E 2>nul ) 

	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! neq 0 set STOP=1
	if !MOUSE_EVENT! neq 0 set STOP=1
	
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
