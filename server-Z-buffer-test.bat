@echo off
set /a F6W=240/2, F6H=90/2
if not defined __ cmdwiz fullscreen 0
cmdwiz setfont 6 & mode %F6W%,%F6H% & cls & title Z buffer test
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe m0nuW10xR | call %0 %* | cmdgfx_gdi "" Sf0:0,0,240,90Bs
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=240, H=90
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -15

set /a "XMID=%W%/2, YMID=%H%/2"
set /a DIST=2500, DIST2=2500, DRAWMODE=5, ROTMODE=0, SHOWHELP=1
set ASPECT=0.675
set /A RX=0,RY=0,RZ=0

set HELPMSG="text 3 0 0 SPACE\-n\-D/d\-ENTER\-\g1e\g1f\g11\g10\-h 2,88"
set MSG=%HELPMSG%

set /a OBJINDEX=2, NOFOBJECTS=5
call :SETOBJECT
set /a ACTIVE_KEY=0, SOBJI=0

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
   set /a DISTMM=DIST-40
   if !SOBJI!==0 set SK0=&set SK1=skip
   if !SOBJI!==1 set SK0=skip&set SK1=
   echo "cmdgfx: fbox 8 0 fa 0,0,!W!,!H! & !MSG:~1,-1! & 3d objects/!FNAME! !DRAWMODE!,!O! !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,0 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & !SK0! 3d objects/hulk.obj !DRAWMODE!,-1 !RZ!,!RX!,!RY! 0,0,0 240,240,240, 0,-2,0 1,0,0,0 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 db 0 0 b1 & !SK1! 3d objects/!FNAME! !DRAWMODE!,!O! !RZ!,!RZ!,!RY! 0,0,0 !MOD!,0,0,0 !XMID!,!YMID!,!DISTMM!,%ASPECT% !PAL!" Ff0:0,0,!W!,!H!
	
   if !ROTMODE! == 0 set /a RX+=2,RY+=3,RZ-=4

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 
	
	if "!RESIZED!"=="1" set /a W=SCRW*2+1, H=SCRH*2+1, XMID=W/2, YMID=H/2, HLPY=H-2 & cmdwiz showcursor 0 & set HELPMSG="text 3 0 0 SPACE\-n\-D/d\-ENTER\-\g1e\g1f\g11\g10\-h 2,!HLPY!"& if not !MSG!=="" set MSG=!HELPMSG!
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
			if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set /a RX=0,RY=0,RZ=0
			if !KEY! == 110 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
			if !KEY! == 104 set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG="")&if !SHOWHELP!==1 set MSG=!HELPMSG!
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 27 set STOP=1
			if !KEY! == 32 set /A SOBJI=1-SOBJI
		)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)
	)
	
	if !ACTIVE_KEY! gtr 0 (
		if !ROTMODE!==1 (
			if !ACTIVE_KEY! == 331 set /a RY+=8
			if !ACTIVE_KEY! == 333 set /a RY-=8
			if !ACTIVE_KEY! == 328 set /a RX+=8
			if !ACTIVE_KEY! == 336 set /a RX-=8
			if !ACTIVE_KEY! == 122 set /a RZ+=8
			if !ACTIVE_KEY! == 90 set /a RZ-=8
		)
		if !ACTIVE_KEY! == 100 set /a DIST+=20
		if !ACTIVE_KEY! == 68 set /a DIST-=20
   )
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:SETOBJECT
if %OBJINDEX% == 0 set FNAME=cube-t5.obj& set MOD=400,400,400, 0,0,0 0&set O=20
if %OBJINDEX% == 1 set FNAME=cube-t4.obj&set MOD=400,400,400, 0,0,0 0&set O=78
if %OBJINDEX% == 2 set FNAME=cube-t3.obj& set MOD=400,400,400, 0,0,0 1&set O=-1
if %OBJINDEX% == 3 set FNAME=cube-t6.obj& set MOD=400,400,400, 0,0,0 0&set O=20
if %OBJINDEX% == 4 set FNAME=hulk.obj& set MOD=240,240,240, 0,-2,0 1&set O=-1
call :SETCOL %DRAWMODE%
goto :eof

:SETCOL
if %OBJINDEX% == 0 set PAL=f 0 db f 0 db a 0 db a 0 db 0 0 db 0 0 db 0 0 db 0 0 db  f 1 db f 1 db  e 0 db e 0 db
if %OBJINDEX% == 1 set PAL=0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  7 0 db 7 0 db  d 0 db d 0 db
if %OBJINDEX% == 2 set PAL=0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  f 1 db f 1 db  e 0 db e 0 db
if %OBJINDEX% == 3 set PAL=f 2 db f 2 db b 3 db b 3 db d 5 db d 5 db 7 4 db 7 4 db  f 1 db f 1 db  f 6 db f 6 db
if %OBJINDEX% == 4 set PAL=0 0 db 0 0 b1 
