@echo off
set /a W=160, H=80
bg font 1 & mode %W%,%H% & cls
cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx "" OkSf1:0,0,%W%,%H%W0
set __=
set W=&set H=
cls & bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

call centerwindow.bat 0 -20

echo "cmdgfx: fbox 0 0 db 0,0,%W%,%H%"
set /a WDIV=%W%/2,HDIV=%H%/2,HM=%H%-1 & echo "cmdgfx: fellipse 1 0 db !WDIV!,!HDIV!,26,9"
set /a HM=%H%-2, HW=%W%/2-52, DELAY=16, COL=1, MODE=0, HLP=1
set HELPT=" & fbox 0 0 db 0,%HM%,%W%,2 & text a 0 0 \n\e0c\r=clear__\r1\r=circle__\r2\r=big_circle__\r3\r=line__\r4\r=eat__\r7-9\r=speed__\rp\r=mouse_draw/pause__\ra\r=color__\rm\r=mode__\rh\r=help %HW%,%HM%"
set HELP=%HELPT%
set EXTRA=&for /L %%a in (1,1,100) do set EXTRA=!EXTRA!xtra
del /Q EL.dat >nul 2>nul

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	if !MODE!==0 echo "cmdgfx: block 0 0,0,%W%,!HM! 0,0 -1 0 0 - store(gtr(col(x-1,y-1),0)+gtr(col(x,y-1),0)+gtr(col(x+1,y-1),0)+gtr(col(x-1,y),0)+gtr(col(x+1,y),0)+gtr(col(x-1,y+1),0)+gtr(col(x,y+1),0)+gtr(col(x+1,y+1),0),0)+((1-(lss(s0,2)+gtr(s0,3)))*gtr(col(x,y),0)+eq(col(x,y)*10+s0,3))*!COL! !HELP:~1,-1! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" W!DELAY!k

	rem with color shifts
	if !MODE! == 1 echo "cmdgfx: block 0 0,0,%W%,!HM! 0,0 -1 0 0 - store(col(x,y)+1,1)+store(gtr(col(x-1,y-1),0)+gtr(col(x,y-1),0)+gtr(col(x+1,y-1),0)+gtr(col(x-1,y),0)+gtr(col(x+1,y),0)+gtr(col(x-1,y+1),0)+gtr(col(x,y+1),0)+gtr(col(x+1,y+1),0),0)+((1-(lss(s0,2)+gtr(s0,3)))*gtr(col(x,y),0)+eq(col(x,y)*10+s0,3))*s1 !HELP:~1,-1! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" W!DELAY!k

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	set /a "XP=!RANDOM! %% %W%,YP=!RANDOM! %% !HM!,XW=!RANDOM! %% 6+2, YH=!RANDOM! %% 10+2" & set /a "XP2=!XP!+!RANDOM! %% 90+20, YP2=!YP!+!RANDOM! %% 60+20, XW2=!RANDOM! %% 20+10, YH2=!RANDOM! %% 20+10"
	if !KEY! == 109 set /a MODE+=1 & if !MODE! gtr 1 set MODE=0
	if !KEY! == 112 call :DRAW
	if !KEY! == 49 echo "cmdgfx: ellipse 1 0 db !XP!,!YP!,!XW!,!YH!"
	if !KEY! == 50 echo "cmdgfx: ellipse 1 0 db !WDIV!,!HDIV!,!XW2!,!YH2!"
	if !KEY! == 51 echo "cmdgfx: line 1 0 db !XP!,!HDIV!,!XP2!,!HDIV!"
	if !KEY! == 52 echo "cmdgfx: fellipse 0 0 db !WDIV!,!HDIV!,!XW2!,!YH2! & ellipse 1 0 db !WDIV!,!HDIV!,!XW2!,!YH2!"
	if !KEY! == 97 set /a COL+=1 & if !COL! gtr 15 set COL=1
	if !KEY! == 55 set DELAY=0
	if !KEY! == 56 set DELAY=100
	if !KEY! == 57 set DELAY=300
	if !KEY! == 99 echo "cmdgfx: fbox 0 0 db 0,0,!W!,!HM!"
	if !KEY! == 104 set /a HM=%H% & set HELP=" " & echo "cmdgfx: fbox 0 0 db 0,%HM%,%W%,2" & set /a HLP=1-!HLP! & if !HLP!==1 set HELP=%HELPT%& set /a HM=%H%-2
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
echo "cmdgfx: quit"
goto :eof

:DRAW
set ENDP=
:DRAWLOOP
for /L %%2 in (1,1,300) do if not defined ENDP (
	set /a KEY=0, MR=-1
	if exist EL.dat set /p MR=<EL.dat & del /Q EL.dat >nul 2>nul
	
	echo "cmdgfx: !OUT! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" W7m5n
	
	if not !MR!==-1 (
		set /a "KEY=!MR!>>22"
		set /a DL=0& set /a "MT=!MR! & 2" &if !MT! geq 1 set DL=1
		set /a DR=0& set /a "MT=!MR! & 4" &if !MT! geq 1 set DR=1
		set /a "MX=(!MR!>>5) & 511"
		set /a "MY=(!MR!>>14) & 127"
		if !DL! geq 1 echo "cmdgfx: pixel 1 0 db !MX!,!MY!" W0
		if !DR! geq 1 echo "cmdgfx: pixel 0 0 db !MX!,!MY!" W0
   )
	if !KEY!==27 set /a STOP=1,ENDP=1
	if !KEY!==112 set /a ENDP=1
	if !KEY!==99 echo "cmdgfx: fbox 0 0 db 0,0,!W!,!HM! !HELP:~1,-1!" W0
	set /a KEY=0
)
if not defined ENDP goto DRAWLOOP
