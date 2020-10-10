@echo off
set /a W=160, H=80
cmdwiz setfont 1 & mode %W%,%H% & cls & title Game of Life
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW16xR | call %0 %* | cmdgfx "" Sf1:0,0,%W%,%H%t4r2
set __=
set W=&set H=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="
call centerwindow.bat 0 -20
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra

echo "cmdgfx: fbox 0 0 db 0,0,%W%,%H%"
set /a WDIV=%W%/2,HDIV=%H%/2,HM=%H%-1 & echo "cmdgfx: fellipse 1 0 db !WDIV!,!HDIV!,26,9"
set /a HM=%H%-2, HW=%W%/2-52, DELAY=16, COL=1, MODE=0, HLP=1
set HELPT=" & fbox 0 0 db 0,%HM%,%W%,2 & text a 0 0 \n\e0c\r=clear__\r1\r=circle__\r2\r=big_circle__\r3\r=line__\r4\r=eat__\r7-9\r=speed__\rp\r=mouse_draw/pause__\ra\r=color__\rm\r=mode__\rh\r=help %HW%,%HM%"
set HELP=%HELPT%

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (	

	if !MODE!==0 echo "cmdgfx: block 0 0,0,!W!,!HM! 0,0 -1 0 0 - store(gtr(col(x-1,y-1),0)+gtr(col(x,y-1),0)+gtr(col(x+1,y-1),0)+gtr(col(x-1,y),0)+gtr(col(x+1,y),0)+gtr(col(x-1,y+1),0)+gtr(col(x,y+1),0)+gtr(col(x+1,y+1),0),0)+((1-(lss(s0,2)+gtr(s0,3)))*gtr(col(x,y),0)+eq(col(x,y)*10+s0,3))*!COL! !HELP:~1,-1! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" f:0,0,!W!,!H!

	rem with color shifts
	if !MODE! == 1 echo "cmdgfx: block 0 0,0,!W!,!HM! 0,0 -1 0 0 - store(col(x,y)+1,1)+store(gtr(col(x-1,y-1),0)+gtr(col(x,y-1),0)+gtr(col(x+1,y-1),0)+gtr(col(x-1,y),0)+gtr(col(x+1,y),0)+gtr(col(x-1,y+1),0)+gtr(col(x,y+1),0)+gtr(col(x+1,y+1),0),0)+((1-(lss(s0,2)+gtr(s0,3)))*gtr(col(x,y),0)+eq(col(x,y)*10+s0,3))*s1 !HELP:~1,-1! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" f:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
	
	if "!RESIZED!"=="1" set /a W=SCRW, H=SCRH, XMID=W/2, YMID=H/2, WDIV=W/2,HDIV=H/2, HLPY=H-3, HM=H-2, HW=W/2-52 & echo "cmdgfx: fbox 0 0 db 0,0,!W!,!HM!" f:0,0,!W!,!H! & cmdwiz showcursor 0 & set HELPT=" & fbox 0 0 db 0,!HM!,!W!,2 & text a 0 0 \n\e0c\r=clear__\r1\r=circle__\r2\r=big_circle__\r3\r=line__\r4\r=eat__\r7-9\r=speed__\rp\r=mouse_draw/pause__\ra\r=color__\rm\r=mode__\rh\r=help !HW!,!HM!"& if !HLP!==1 set HELP=!HELPT!
	
	set /a "XP=!RANDOM! %% !W!,YP=!RANDOM! %% !HM!,XW=!RANDOM! %% 6+2, YH=!RANDOM! %% 10+2" & set /a "XP2=!XP!+!RANDOM! %% 90+20, YP2=!YP!+!RANDOM! %% 60+20, XW2=!RANDOM! %% 20+10, YH2=!RANDOM! %% 20+10"
	if !KEY! == 109 set /a MODE+=1 & if !MODE! gtr 1 set MODE=0
	if !KEY! == 112 call :DRAW
	if !KEY! == 49 echo "cmdgfx: ellipse 1 0 db !XP!,!YP!,!XW!,!YH!"
	if !KEY! == 50 echo "cmdgfx: ellipse 1 0 db !WDIV!,!HDIV!,!XW2!,!YH2!"
	if !KEY! == 51 echo "cmdgfx: line 1 0 db !XP!,!HDIV!,!XP2!,!HDIV!"
	if !KEY! == 52 echo "cmdgfx: fellipse 0 0 db !WDIV!,!HDIV!,!XW2!,!YH2! & ellipse 1 0 db !WDIV!,!HDIV!,!XW2!,!YH2!"
	if !KEY! == 97 set /a COL+=1 & if !COL! gtr 15 set COL=1
	if !KEY! == 55 set /a DELAY=16 & echo W!DELAY!k>inputflags.dat
	if !KEY! == 56 set /a DELAY=100 & echo W!DELAY!k>inputflags.dat
	if !KEY! == 57 set /a DELAY=300 & echo W!DELAY!k>inputflags.dat
	if !KEY! == 99 echo "cmdgfx: fbox 0 0 db 0,0,!W!,!HM!"
	if !KEY! == 104 set /a HM=!H! & set HELP=""& echo "cmdgfx: fbox 0 0 db 0,!HM!,!W!,2" & set /a HLP=1-!HLP! & if !HLP!==1 set HELP=!HELPT!& set /a HM=!H!-2
	if !KEY! == 27 set STOP=1
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	set /a KEY=0
)
if not defined STOP goto LOOP

cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:DRAW
echo W10m0>inputflags.dat
set /a KEY=0
set ENDP=
:DRAWLOOP
for /L %%2 in (1,1,300) do if not defined ENDP (
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D,  M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 	

	if "!RESIZED!"=="1" set /a W=SCRW, H=SCRH, XMID=W/2, YMID=H/2, WDIV=W/2,HDIV=H/2, HLPY=H-3, HM=H-2, HW=W/2-52 & echo "cmdgfx: fbox 0 0 db 0,0,!W!,!HM!" f:0,0,!W!,!H! & cmdwiz showcursor 0 & set HELPT=" & fbox 0 0 db 0,!HM!,!W!,2 & text a 0 0 \n\e0c\r=clear__\r1\r=circle__\r2\r=big_circle__\r3\r=line__\r4\r=eat__\r7-9\r=speed__\rp\r=mouse_draw/pause__\ra\r=color__\rm\r=mode__\rh\r=help !HW!,!HM!"& if !HLP!==1 set HELP=!HELPT!
		
	echo "cmdgfx: !HELP:~1,-1!" Ff:0,0,!W!,!H!
	
	if not "!EV_BASE:~0,1!" == "N" (
		if !M_EVENT!==1 (
			if !M_LB! geq 1 echo "cmdgfx: pixel 1 0 db !M_X!,!M_Y!" n
			if !M_RB! geq 1 echo "cmdgfx: pixel 0 0 db !M_X!,!M_Y!" n
		)
   )
	if !KEY!==10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY!==27 set /a STOP=1,ENDP=1
	if !KEY!==112 set /a ENDP=1
	if !KEY!==99 echo "cmdgfx: fbox 0 0 db 0,0,!W!,!HM! !HELP:~1,-1!" n
	set /a KEY=0
)
if not defined ENDP goto DRAWLOOP
echo W!DELAY!k>inputflags.dat
