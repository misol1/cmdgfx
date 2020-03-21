@if (true == false) @end /*
@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@rem if not defined __ cmdwiz sendkey 0x5b d & cmdwiz sendkey 0x44 p & cmdwiz sendkey 0x5b u & cmdwiz delay 200 & cmdwiz sendkey 0x12 d & cmdwiz sendkey 0x09 p & cmdwiz sendkey 0x12 u & rem Run over desktop
@echo off
cd /D "%~dp0"
if defined __ goto :START
cmdwiz setfont 6 & cls
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%/4+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/6+1

set __=.
call %0 %* | cmdgfx_RGB "" m0O%TOP%Sf0:0,0,%W%,%H%W13t4
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

cmdwiz setwindowtransparency 33

set /a XMID=%W%/2, YMID=%H%/2, DIST=2100, TRIDIST=7000, DRAWMODE=0, MODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.6665

set /a S1=66, S2=12, S3=30, TRINUM=0

set FN0=objects\tri%TRINUM%.obj
set FN1=objects\tri-FS-%TRINUM%.obj
set FN2=objects\tri-FS2-%TRINUM%.obj

set /a A1=155, A2=0, A3=0, CNT=0

set /a MODE=0, TV=0, TRANSP=1, CUPOS=35

set /a "DIST=4000-(W-222)*7, TRIDIST=7000-(W-222)*17, CUPOS=35+(W-222)/7+3"
set FN=%FN0%& (if !W! gtr 300 set FN=%FN1%)& (if !W! gtr 400 set FN=%FN2%)

set STOP=
:LOOP
for /L %%_ in (1,1,300) do if not defined STOP (

	set /a A1+=1, A2+=2, A3-=1, TRZ=!CRZ!
	if !MODE!==0 set OUTP="fbox 0 0 20 & 3d objects\cube-t-RGB.obj 5,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==1 set OUTP="fbox 0 0 20 & 3d objects\cube-t-RGB2.obj 5,-1 !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 1,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==2 set OUTP="fbox 0 0 20 & 3d objects\cube-t-RGB2.obj 5,-1 !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 1,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 db 1 0 db 9 0 db 2 0 db a 0 db 3 0 db b 0 db 4 0 db c 0 db 5 0 db d 0 db 6 0 db e 0 db"

	set OUTP="!OUTP:~1,-1! & 3d !FN! %DRAWMODE%,-1 0,0,0 0,0,0 1,1,1,0,0,0 0,0,0,10 !XMID!,!YMID!,10000,%ASPECT% 0 0 db & fbox 7 0 20"
	
	for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! & 3d !FN! %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 20,20,20,0,0,0 0,0,0,10 !XMID!,!YMID!,!TRIDIST!,%ASPECT% 0 0 db"&set /A TRZ+=%S3%*4
	
	echo "cmdgfx: !OUTP:~1,-1!" f0:0,0,!W!,!H!
	set OUTP=

	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
	
	set /a CRZ+=3, CNT+=1

	if !CNT! gtr 1307 set /a A3+=1
	if !CNT! gtr 1400 set /a CNT=0
	if !KEY! == 112 cmdwiz getch & set /a KEY=0
	if !KEY! == 100 set /a KEY=0 & cmdwiz sendkey 0x5b d & cmdwiz sendkey 0x44 p & cmdwiz sendkey 0x5b u & cmdwiz delay 300 & cmdwiz sendkey 0x12 d & cmdwiz sendkey 0x09 p & cmdwiz sendkey 0x12 u 
	if !KEY! == 32 set /A MODE+=1, KEY=0&if !MODE! gtr 2 set MODE=0
	if !KEY! gtr 0 set STOP=1
	if !MOUSE_EVENT! neq 0 set STOP=1	
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
