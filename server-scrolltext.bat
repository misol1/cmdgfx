@echo off
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Scrolltext
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,200,80
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION

set /a W=200, H=80
set /a F8W=W/2, F8H=H/2
mode %F8W%,%F8H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="
call centerwindow.bat 0 -16
call prepareScale.bat 1

set /a XMID=%W%/2, YMID=%H%/2, DIST=5000, RX=0,RY=0,RZ=0
set ASPECT=0.6
set FN=objects\scroll-planes.obj

set /a XW=40,YW=10, XROT=0,YROT=0,ZROT=0, HLP=0, DIR=1, DRAWMODE=0
set HELP=text a 0 0 'p'_to_pause,_'z'_for_z_rotation,_'y'_for_y_rotation,_'x'_for_x_rotation,_'space'_to_reset_all_rotation,_'left/right'_for_direction,_'d/D'_to_zoom,_'t'_to_switch_char,_'h'_to_hide_text
set SH=skip
set /a HLPX=6, HLPY=H-3
set HLPPOS=!HLPX!,!HLPY!

set /a TRANSPCOL=0
set BKG=fbox 1 0 fa

if exist %FN% goto SKIPGEN

set /A NOFSECT=100
set /A STEPT=10000/%NOFSECT%
echo usemtl img\scroll_text2.pcx >%FN%
set /a SL=0, SR=%STEPT%, FCNT=1, XPP=12
set /a XW=0, XW2=%XPP%
set /a NOFPREP=%NOFSECT%-10-1

for /l %%a in (0,1,%NOFPREP%) do (
	if !SR! geq 10000 set /a SL=0, SR=1500
	set SLP=0.!SL!&if !SL! lss 1000 set SLP=0.0!SL!&if !SL! lss 100 set SLP=0.00!SL!
	set SRP=0.!SR!&if !SR! lss 1000 set SRP=0.0!SR!&if !SR! lss 100 set SRP=0.00!SR!

	set OUTP=!OUTP!v  !XW! -%YW% 0\nv  !XW2! -%YW% 0\nv  !XW2!  %YW% 0\nv  !XW!  %YW% 0\nvt !SLP! 0.0\nvt !SRP! 0.0\nvt !SRP! 1.0\nvt !SLP! 1.0\n

	set /a FCNT2=!FCNT!+1, FCNT3=!FCNT!+2, FCNT4=!FCNT!+3
	set OUTP=!OUTP!f !FCNT!/!FCNT!/ !FCNT2!/!FCNT2!/ !FCNT3!/!FCNT3!/ !FCNT4!/!FCNT4!/\n

	if %%a==50 cmdwiz print "!OUTP!">>%FN% & set OUTP=

	set /A SL+=%STEPT%,SR+=%STEPT%
	set /A FCNT+=4, XW+=%XPP%, XW2+=%XPP%, CNT+=1
)
cmdwiz print "%OUTP%">>%FN% & set OUTP=

:SKIPGEN
set CHAR=db
set /a CHARI=0, CNT=0, XP=30

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	if "%~1"=="" echo "cmdgfx: %BKG% & 3d %FN% %DRAWMODE%,%TRANSPCOL% !RY!,0,!RX! 0,0,0 110,110,110,!XP!,0,0 0,-2000,4000,0 !XMID!,!YMID!,7000,%ASPECT% 0 0 . & 3d %FN% %DRAWMODE%,%TRANSPCOL% !RX!,!RY!,!RZ! 0,0,0 16,16,16,!XP!,0,0 0,-2000,4000,0 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 !CHAR! & !SH! !HELP! !HLPPOS!" Ff1:0,0,!W!,!H!
	if not "%~1"=="" echo "cmdgfx: %BKG% & 3d %FN% %DRAWMODE%,%TRANSPCOL%  !RX!,!RY!,!RZ! 0,0,0 16,16,16,!XP!,0,0 0,-2000,4000,0 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 !CHAR! & !SH! !HELP! !HLPPOS!" Ff1:0,0,!W!,!H!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 
	
	if "!RESIZED!"=="1" set /a "W=SCRW*2*rW/100+2, H=SCRH*2*rH/100+2, XMID=W/2, YMID=H/2, HLPX=W/2-190/2, HLPY=H-4" & set HLPPOS=!HLPX!,!HLPY! & cmdwiz showcursor 0

	if !YROT! == 1 set /A RX+=14
	if !XROT! == 1 set /A RY+=6
	if !ZROT! == 1 set /A RZ+=4

	set /A XP-=!DIR!
	if !XP! lss -1000 set XP=30
	if !XP! gtr 100 set XP=-1000

	set /A CNT+=1
	if !CNT!==40 set ZROT=1
	if !CNT! gtr 80 if !CNT! lss 200 set /A DIST-=20
	if !CNT!==195 set YROT=1
	if !CNT! gtr 380 if !CNT! lss 500 set /A DIST+=20
	if !CNT!==605 set /a YROT=0, RX=0
	if !CNT!==640 set XROT=1
	if !CNT!==1200 if "!SH!"=="skip" set /a KEY=104

	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 116 set CCNT=0&for %%a in (04 fe . b0 db) do (if !CCNT!==!CHARI! set CHAR=%%a)&set /A CCNT+=1
	if !KEY! == 116 set /A CHARI+=1&if !CHARI! geq 5 set CHARI=0
	if !KEY! == 100 set /A DIST+=30
	if !KEY! == 68 set /A DIST-=30
	if !KEY! == 333 set DIR=-1
	if !KEY! == 331 set DIR=1
	if !KEY! == 32 set /A RX=0,RY=0,RZ=0,XROT=0,YROT=0,ZROT=0,DIST=5000,CNT=10000
	if !KEY! == 104 set /A HLP=1-!HLP! & (if !HLP!==1 set SH=)&(if !HLP!==0 set SH=skip)
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 120 set /A XROT=1-!XROT!
	if !KEY! == 121 set /A YROT=1-!YROT!
	if !KEY! == 122 set /A ZROT=1-!ZROT!
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
