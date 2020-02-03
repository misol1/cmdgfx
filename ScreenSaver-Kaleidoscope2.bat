@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off

if defined __ goto :START
cd /D "%~dp0"

cls & cmdwiz setfont 6
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%/4+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/6+1

cls & cmdwiz showcursor 0

set __=.
call %0 %* | cmdgfx_gdi "" %TOP%m0OSf0:0,0,%W%,%H%W13%2
set __=
cls
cmdwiz fullscreen 0 & cmdwiz showmousecursor 1 & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=2200, DRAWMODE=0, MODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.6665

set /a S1=66, S2=12, S3=30
if "%~1" == "1" set /a S1=33, S2=24, S3=15
if "%~1" == "2" set /a S1=100, S2=8, S3=45
if "%~1" == "3" set /a S1=25, S2=30, S3=12

set /a CUPOS=75, DIST=2200, CUZP=500, TRIDIST=3500
::W leq 1680
if %W% leq 428 set /a CUPOS=55, DIST=2600,TRIDIST=3700
::W leq 1366(1280)
if %W% leq 348 set /a CUPOS=47, DIST=2900, TRIDIST=5000
::W leq 1024
if %W% leq 264 set /a CUPOS=40, DIST=3200, TRIDIST=5500
::W leq 800
if %W% leq 208 set /a CUPOS=35, DIST=4000, TRIDIST=7000
::W geq 1920
if %W% geq 520 set /a CUPOS=75, DIST=2100, TRIDIST=2500

set /a TRISIZE=145
if %H% leq 145 set /a TRISIZE=110
if %H% leq 110 set /a TRISIZE=70

set FN=tri.obj
echo usemtl cmdblock 0 0 %TRISIZE% %TRISIZE% >%FN%
echo v  -25 -25 0 >>%FN%
echo v  25 -25 0 >>%FN%
echo v  0 25 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo f 1/1/ 2/2/ 3/3/ >>%FN%

set /a A1=155, A2=0, A3=0, CNT=0
set /a MODE=1, TV=20, RV=0, CE=1

set STOP=
:LOOP
for /L %%_ in (1,1,300) do if not defined STOP (

	set /a A1+=2, A2+=3, A3-=1, TRZ=!CRZ!
	if !MODE!==0 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,!DIST!,%ASPECT% 1 0 db"
	if !MODE!==1 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t6.obj 5,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,!DIST!,%ASPECT% 1 0 db 9 0 db 2 0 db a 0 db 3 0 db b 0 db 4 0 db c 0 db 5 0 db d 0 db 6 0 db e 0 db"
	if !MODE!==2 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\spaceship.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 410,410,410,0,0,0 1,0,0,10 %CUPOS%,%CUPOS%,!DIST!,%ASPECT% 1 0 db"
	if !MODE!==3 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t-checkers.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==4 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\hulk.obj %DRAWMODE%,-1 !A1!,!A2!,!A3! 0,0,0 210,210,210,0,-2,0 0,0,0,10 %CUPOS%,%CUPOS%,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==5 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==6 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==7 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,!DIST!,%ASPECT% 1 0 db"

	set /a ZZT=0, XXT=-500*5, YYT=-800*3, ZZT2=0,CPP=-2
	for /L %%2 in (1,1,5) do set /a YYT+=980, XXT=-490*5, ZZT=!ZZT2!, ZZT2+=180*4*!RV!, CPP+=1, CPP2=CPP & for /L %%1 in (1,1,10) do set OUTP="!OUTP:~1,-1! & 3d %FN% 1,-1 0:0,0:0,!ZZT!:!TRZ! !XXT!,!YYT!,0 20,20,20,0,0,0 0,0,0,10 %XMID%,%YMID%,%TRIDIST%,%ASPECT% 0 0 db & 3d %FN% %DRAWMODE%,-1 0:0,0:0,!ZZT!:!TRZ! !XXT!,!YYT!,0 20,20,20,0,0,0 0,0,0,10 %XMID%,%YMID%,%TRIDIST%,%ASPECT% !CPP2! 0 db"&set /A ZZT+=180*4, XXT+=490, CPP2+=1*!CE!
	
	echo "cmdgfx: !OUTP:~1,-1!"
	set OUTP=

	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"

	set /a CRZ+=4, CNT+=1
	if !CNT! gtr 137 set /a A2+=1
	if !CNT! gtr 140 set /a CNT=0
	
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch & set /a CKEY=!errorlevel! & if !CKEY! == 115 echo "cmdgfx: " c:0,0,%W%,%H%
	if !KEY! == 13 set /a RV=1-!RV!, KEY=0
	if !KEY! == 32 set /a CE=1-!CE!, KEY=0
	if !KEY! gtr 0 set STOP=1
	if !MOUSE_EVENT! == 1 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
del /Q tri.obj
echo "cmdgfx: quit"
