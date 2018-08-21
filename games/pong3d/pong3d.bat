:: Pong3d: Mikael Sollenborn 2017

@echo off
cls & cmdwiz setfont 6 & cmdwiz showcursor 0 & title Pong 3d
if defined __ goto :START
set __=.
cmdgfx_input.exe m0nuW12x | call %0 %* | cmdgfx_gdi.exe "" Sf0:0,0,220,110
set __=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION

set /a W=220, H=110
set /a F6W=W/2, F6H=H/2
mode %F6W%,%F6H% & cls
cmdwiz showcursor 0
rem NOTE: on Win7, clearing SystemRoot env variable will cause Windows API PlaySound to fail (used by e.g. cmdwiz playsound)
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==SystemRoot set "%%v="

cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w & set WINW=!errorlevel!
cmdwiz getwindowbounds h & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2, WPY=%SH%/2-%WINH%/2-20
cmdwiz setwindowpos %WPX% %WPY%

set /a XMID=%W%/2, YMID=%H%/2, DIST=1500
set ASPECT=0.6666
for %%a in (1 2 3) do set /a HISCORE%%a=0 & if exist hiscore%%a.dat for /F "tokens=*" %%i in (hiscore%%a.dat) do set /a HISCORE%%a=%%i

set FN=square.obj
set FL=bl-logo.obj

set SOUNDOFF=
set SOUNDCMD=start "" /B cmdwiz playsound

goto OUTERLOOP

set /a MULVAL=100
set /a Vx0=-1, Vy0=-1, Vz0=-1
set /a Vx1=1,  Vy1=-1, Vz1=-1
set /a Vx2=1,  Vy2=1,  Vz2=-1
set /a Vx3=-1, Vy3=1,  Vz3=-1
set /a Vx4=-1, Vy4=-1, Vz4=1
set /a Vx5=1,  Vy5=-1, Vz5=1
set /a Vx6=1,  Vy6=1,  Vz6=1
set /a Vx7=-1, Vy7=1,  Vz7=1

set /a F0_0=0, F0_1=3, F0_2=2, F0_3=1
set /a F1_0=5, F1_1=6, F1_2=7, F1_3=4
set /a F2_0=6, F2_1=5, F2_2=1, F2_3=2
set /a F3_0=3, F3_1=0, F3_2=4, F3_3=7
set /a F4_0=7, F4_1=6, F4_2=2, F4_3=3
set /a F5_0=5, F5_1=4, F5_2=0, F5_3=1

set logo0=111---11--111---11-----11--111-
set logo1=1--1-1--1-1--1-1---------1-1--1
set logo2=111--1--1-1--1-1-11----111-1--1
set logo3=1----1--1-1--1-1--1------1-1--1
set logo4=1-----11--1--1--11-----11--111-

del /Q %FL%>nul 2>nul
set NOF_B=0
cmdwiz stringlen %logo0%&set /A NOF=!errorlevel!-1&set /A NOFDIV=!NOF!/2
for /L %%j in (0,1,4) do (
	for /L %%i in (0,1,%NOF%) do (
	  set S=!logo%%j:~%%i,1!
		if not !S!==- (
		  set /A X=-!NOFDIV!+%%i,Y=%%j-2,Z=1
		  for %%a in (!X!) do for %%b in (!Y!) do for %%c in (!Z!) do (
			 for /L %%d in (0,1,7) do set /a vx=!Vx%%d!+!X!*2&set /a vx=!vx!*%MULVAL% & set /a vy=!Vy%%d!+!Y!*2&set /a vy=!vy!*%MULVAL%-%MULVAL%/2 & set /a vz=!Vz%%d!+!Z!&set /a vz=!vz!*%MULVAL%&echo v !vx! !vy! !vz!>>%FL%
			 for %%e in (!NOF_B!) do for /L %%f in (0,1,1) do set /a f0=!F%%f_0!+%%e*8+1&set /a f1=!F%%f_1!+%%e*8+1&set /a f2=!F%%f_2!+%%e*8+1&set /a f3=!F%%f_3!+%%e*8+1&echo f !f0!// !f1!// !f2!// !f3!// >>%FL%
		  )
		  set /A NOF_B+=1
		)
	)
)
for /L %%a in (0,1,4) do set logo%%a=

:OUTERLOOP
set /a GAMEOVER=0, SCORE=0, CNT=0
set /a RX=0,RY=0,RZ=0

set STOP=&set ESCKEY=

%SOUNDOFF% %SOUNDCMD% sfx\tone.wav

echo "cmdgfx: fbox 2 0 20 0,0,%W%,%H% & image background.gxy 2 0 0 -1 0,0 & 3d %FL% 3,-1 !RX!,!RY!,!RZ! -60,1520,0 1,2,1,0,0,0 0,0,0,0 %XMID%,!YMID!,20000,%ASPECT% a 0 b1 2 0 b1" f0
echo "cmdgfx: fbox 2 0 20 0,0,%W%,%H% & box 2 0 fa 0,0,28,17 & & text e 0 0 1=Easy_2=Hard_3=God\n\n\-\-\70S=Sound_On/Off\n\n\c0\-Press_ESC_to_quit 5,2 & text 9 0 0 \a0\-INGAME_CONTROLS:\r\n\n\70Cursor_Keys\r_-_Move\n\n\rMouse_Press\r_-_Move\n\n\70Esc_\r_-_Abort 6,9" f6:40,29,29,18

:IDLELOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	echo "cmdgfx: fbox 2 0 20 0,0,%W%,%H% & image background.gxy 2 0 0 -1 0,0 & 3d %FL% 3,-1 !RX!,!RY!,!RZ! -60,1520,0 1,2,1,0,0,0 0,0,0,0 %XMID%,!YMID!,20000,%ASPECT% a 0 b1 2 0 b1" Ff0:0,0,%W%,50

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul )
	
	if !K_DOWN! == 1 (
		if !KEY! == 49 set /a DIFF=1, STOP=1
		if !KEY! == 50 set /a DIFF=2, STOP=1
		if !KEY! == 51 set /a DIFF=3, STOP=1
		if !KEY! == 27 set STOP=1&set ESCKEY=1
		if !KEY! == 115 set OLDS=!SOUNDOFF!&(if "!OLDS!"=="" set SOUNDOFF=rem&%SOUNDCMD% sfx\beep-00.wav)&(if "!OLDS!"=="rem" set SOUNDOFF=&%SOUNDCMD% sfx\tone.wav)
	)
		
	if !CNT! lss 480 set /A RX+=12
	if !CNT! gtr 480 set /A RY+=12
	if !CNT! gtr 840 set /A CNT=-1&set RX=0&set RY=0
	set /A CNT+=1
	set /a KEY=0
)
if not defined STOP goto IDLELOOP
if defined ESCKEY goto OUTOF

echo AW16>inputflags.dat

set /a MAX_X=320, MAX_Y=210

set /a X=0, Y=0, MOVESPEED=9, PAD_SIZE=10
set /a PAD_COLLIDER=14 * !PAD_SIZE!
set /a AIMDIV=!PAD_COLLIDER! / 5
set COL=7

set /a BALL_X=0, BALL_Y=0, BALL_Z=0, BALL_SPEED=50, BALL_DIR=1, BALL_XP=1, BALL_YP=4, BALL_SIZE=3, MAX_BALL_P=10
set /a MAX_INIT_BALL_XP=4, MAX_INIT_BALL_YP=4
set /a "BALL_XP=%RANDOM% %% (!MAX_INIT_BALL_XP! * 2-1) - !MAX_INIT_BALL_XP!, BALL_YP=%RANDOM% %% (!MAX_INIT_BALL_YP!* 2-1) - !MAX_INIT_BALL_YP!"
set BALL_COL=a

set /a ENEMY_X=0, ENEMY_Y=0, ENEMY_SPEED=20, MAX_ENEMY_MOVE=3, ENEMY_PAD_SIZE=10, ENEMY_Z_POS=6000
set /a ENEMY_PAD_COLLIDER=12 * !ENEMY_PAD_SIZE!
set /a AIMDIV_ENEMY=!PAD_COLLIDER! / 3
set ENEMY_COL=9

set /a ERRCNT=0, KEY=0
for %%a in (331 333 328 336) do set /a ACTIVE_KEY%%a=0

set /a HISCORE=!HISCORE1!
if !DIFF!==2 set ENEMY_COL=c & set /a BALL_SPEED=70, MAX_ENEMY_MOVE=8, ENEMY_SPEED=9, MAX_BALL_P=13, MAX_INIT_BALL_XP=6, MAX_INIT_BALL_YP=6, AIMDIV=!PAD_COLLIDER! / 10, AIMDIV_ENEMY=!PAD_COLLIDER! / 6, HISCORE=!HISCORE2!
if !DIFF!==3 set ENEMY_COL=d & set /a BALL_SPEED=140, MAX_ENEMY_MOVE=12, ENEMY_SPEED=6, MAX_INIT_BALL_XP=10, MAX_BALL_P=14, MAX_INIT_BALL_YP=10, AIMDIV=!PAD_COLLIDER! / 14, AIMDIV_ENEMY=!PAD_COLLIDER! / 9, HISCORE=!HISCORE3!

if !BALL_XP!==0 if !BALL_YP! == 0 set /a "BALL_XP=%RANDOM% %% (!MAX_INIT_BALL_XP!) + 1"

%SOUNDOFF% %SOUNDCMD% sfx\deckeditoropen.wav

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	echo "cmdgfx: image background.gxy 2 0 0 -1 0,0 & 3d %FN% 3,-1 0,0,0 !ENEMY_X!,!ENEMY_Y!,%ENEMY_Z_POS% %ENEMY_PAD_SIZE%,%ENEMY_PAD_SIZE%,%ENEMY_PAD_SIZE%,0,0,0 0,0,0,0 %XMID%,%YMID%,%DIST%,%ASPECT% !ENEMY_COL! 0 fe & 3d %FN% 3,-1 0,0,0 !BALL_X!,!BALL_Y!,!BALL_Z! %BALL_SIZE%,%BALL_SIZE%,%BALL_SIZE%,0,0,0 0,0,0,0 %XMID%,%YMID%,%DIST%,%ASPECT% !BALL_COL! 0 fe & 3d %FN% 3,-1 0,0,0 !X!,!Y!,0 %PAD_SIZE%,%PAD_SIZE%,%PAD_SIZE%,0,0,0 0,0,0,0 %XMID%,%YMID%,%DIST%,%ASPECT% !COL! 0 fe & text e 0 0 Score:_!SCORE!_\e0(!HISCORE!) 2,1 & !ERR!" Ff0:0,0,%W%,%H%

	set /a ERRCNT-=1 & if !ERRCNT! lss 0 set ERR=
	if !GAMEOVER!==1 set STOP=1

	set /a BALL_X+=!BALL_XP!
	set /a BALL_Y+=!BALL_YP!
	set /a BALL_Z+=!BALL_SPEED! * !BALL_DIR!
	if !BALL_Z! geq %ENEMY_Z_POS% call :ENEMY_COLLIDE
	if !BALL_Z! leq 0 call :PLY_COLLIDE
	if !BALL_X! leq -%MAX_X% set /a BALL_XP=-!BALL_XP!, BALL_X=-%MAX_X% & %SOUNDOFF% %SOUNDCMD%  sfx\beep-00.wav
	if !BALL_X! geq %MAX_X% set /a BALL_XP=-!BALL_XP!, BALL_X=%MAX_X% & %SOUNDOFF% %SOUNDCMD%  sfx\beep-00.wav
	if !BALL_Y! leq -%MAX_Y% set /a BALL_YP=-!BALL_YP!, BALL_Y=-%MAX_Y% & %SOUNDOFF% %SOUNDCMD%  sfx\beep-00.wav
	if !BALL_Y! geq %MAX_Y% set /a BALL_YP=-!BALL_YP!, BALL_Y=%MAX_Y% & %SOUNDOFF% %SOUNDCMD%  sfx\beep-00.wav
	
	set /a "XDELT=(!BALL_X! - !ENEMY_X!) * 1000"
	set /a "XENEMY_MOVE=(!XDELT!/!ENEMY_SPEED!) / 1000"
	if !XENEMY_MOVE! gtr %MAX_ENEMY_MOVE% set /a XENEMY_MOVE=%MAX_ENEMY_MOVE%
	if !XENEMY_MOVE! lss -%MAX_ENEMY_MOVE% set /a XENEMY_MOVE=-%MAX_ENEMY_MOVE%
	set /a ENEMY_X=!ENEMY_X! + !XENEMY_MOVE!
	if !ENEMY_X! leq -%MAX_X% set /a ENEMY_X=-%MAX_X%
	if !ENEMY_X! geq %MAX_X% set /a ENEMY_X=%MAX_X%
	
	set /a "YDELT=(!BALL_Y! - !ENEMY_Y!) * 1000"
	set /a "YENEMY_MOVE=(!YDELT!/!ENEMY_SPEED!) / 1000"
	if !YENEMY_MOVE! gtr %MAX_ENEMY_MOVE% set /a YENEMY_MOVE=%MAX_ENEMY_MOVE%
	if !YENEMY_MOVE! lss -%MAX_ENEMY_MOVE% set /a YENEMY_MOVE=-%MAX_ENEMY_MOVE%
	set /a ENEMY_Y=!ENEMY_Y! + !YENEMY_MOVE!
	if !ENEMY_Y! leq -%MAX_Y% set /a ENEMY_Y=-%MAX_Y%
	if !ENEMY_Y! geq %MAX_Y% set /a ENEMY_Y=%MAX_Y%
	
	set STOPCHK=
	for /L %%2 in (1,1,8) do if not defined STOPCHK (
		set /p INPUT=

		set EV_BASE="!INPUT:~0,1!"
		if !EV_BASE!=="E" set /a STOPCHK=1
			
		if !EV_BASE! == "M" for /f "tokens=4,6,8,10,12,14,16" %%A in ("!INPUT!") do ( set /a "X=(%%A-55)*6, Y=(-%%B+27)*6" 2>nul )
	  
		if !EV_BASE! == "K" (
			for /f "tokens=1,2,4,6" %%A in ("!INPUT!") do ( set /a K_DOWN=%%C, KEY=%%D 2>nul )
			if !K_DOWN! == 1 (
				for %%a in (331 333 328 336) do if !KEY! == %%a set /a ACTIVE_KEY%%a=1
				if !KEY! == 27 set STOP=1
				if !KEY! == 112 cmdwiz getch
			)
			if !K_DOWN! == 0 (
				for %%a in (331 333 328 336) do if !KEY! == %%a set /a ACTIVE_KEY%%a=0
			)
		)
	)

	if !ACTIVE_KEY331!==1 set /A X-=!MOVESPEED! & if !X! leq -%MAX_X% set /a X=-%MAX_X%
	if !ACTIVE_KEY333!==1 set /A X+=!MOVESPEED! & if !X! geq %MAX_X% set /a X=%MAX_X%
	if !ACTIVE_KEY336!==1 set /A Y-=!MOVESPEED! & if !Y! leq -%MAX_Y% set /a Y=-%MAX_Y%
	if !ACTIVE_KEY328!==1 set /A Y+=!MOVESPEED! & if !Y! geq %MAX_Y% set /a Y=%MAX_Y%
)
if not defined STOP goto LOOP

echo -AW12>inputflags.dat

if !GAMEOVER!==0 goto OUTERLOOP
for /l %%a in (1,1,50) do echo "cmdgfx: text f 0 0 G_A_M_E___O_V_E_R\n\n\n\n\c0\-\-\-PRESS_SPACE 6,4" f2:41,34,29,14

for %%a in (1 2 3) do if !DIFF!==%%a if %SCORE% gtr !HISCORE%%a! set /a HISCORE%%a=%SCORE% & echo !HISCORE%%a! > hiscore%%a.dat

:QLOOP
cmdwiz getch & if not !errorlevel!==32 goto QLOOP
echo "cmdgfx: " f0:0,0,%W%,%H%

goto OUTERLOOP

:OUTOF
title input:Q
endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
goto :eof

:PLY_COLLIDE
set /a BALL_DIR=1, BALL_Z=0
set /a XD=!BALL_X!-!X!, YD=!BALL_Y!-!Y!
set /a BALL_XP+=!XD!/!AIMDIV!
if !BALL_XP! leq -%MAX_BALL_P% set /a BALL_XP=-%MAX_BALL_P%
if !BALL_XP! geq %MAX_BALL_P% set /a BALL_XP=%MAX_BALL_P%
set /a BALL_YP+=!YD!/!AIMDIV!
if !BALL_YP! leq -%MAX_BALL_P% set /a BALL_YP=-%MAX_BALL_P%
if !BALL_YP! geq %MAX_BALL_P% set /a BALL_YP=%MAX_BALL_P%
if !XD! lss 0 set /a XD=-!XD!
if !YD! lss 0 set /a YD=-!YD!
if !XD! gtr !PAD_COLLIDER! set /a GAMEOVER=1
if !YD! gtr !PAD_COLLIDER! set /a GAMEOVER=1
if %GAMEOVER% == 0 %SOUNDOFF% %SOUNDCMD% sfx\deckeditoropen.wav
if %GAMEOVER% == 1 %SOUNDOFF% %SOUNDCMD% sfx\alert.wav
goto :eof

:ENEMY_COLLIDE
set /a BALL_DIR=-1, BALL_Z=%ENEMY_Z_POS%, INC_SCORE=0
set /a XD=!BALL_X!-!ENEMY_X!, YD=!BALL_Y!-!ENEMY_Y!
set /a BALL_XP+=!XD!/!AIMDIV_ENEMY!
if !BALL_XP! leq -%MAX_BALL_P% set /a BALL_XP=-%MAX_BALL_P%
if !BALL_XP! geq %MAX_BALL_P% set /a BALL_XP=%MAX_BALL_P%
set /a BALL_YP+=!YD!/!AIMDIV_ENEMY!
if !BALL_YP! leq -%MAX_BALL_P% set /a BALL_YP=-%MAX_BALL_P%
if !BALL_YP! geq %MAX_BALL_P% set /a BALL_YP=%MAX_BALL_P%
if !XD! lss 0 set /a XD=-!XD!
if !YD! lss 0 set /a YD=-!YD!
if !XD! gtr !ENEMY_PAD_COLLIDER! set /a INC_SCORE=1
if !YD! gtr !ENEMY_PAD_COLLIDER! set /a INC_SCORE=1
if !INC_SCORE!==1 set /a SCORE+=1, ERRCNT=50 & set ERR=box e 0 db 0,0,219,109 & set /a "BALL_X=0, BALL_Y=0, BALL_Z=1, BALL_DIR=1, BALL_XP=%RANDOM% %% (!MAX_INIT_BALL_XP! * 2-1) - !MAX_INIT_BALL_XP!, BALL_YP=%RANDOM% %% (!MAX_INIT_BALL_YP!* 2-1) - !MAX_INIT_BALL_YP!" & set /a X=0, Y=0, ENEMY_X=0, ENEMY_Y=0
if !INC_SCORE!==1 if !BALL_XP!==0 if !BALL_YP! == 0 set /a "BALL_XP=%RANDOM% %% (!MAX_INIT_BALL_XP!) + 1"
if !INC_SCORE!==1 if !SCORE! gtr !HISCORE! set /a HISCORE=!SCORE!
if !INC_SCORE!==1 %SOUNDOFF% %SOUNDCMD% sfx\card.wav
if !INC_SCORE!==0 %SOUNDOFF% %SOUNDCMD% sfx\switch.wav
