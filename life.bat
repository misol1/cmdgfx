@echo off
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
bg font 1 & mode %W%,%H%
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="
cmdwiz setbuffersize %W% %H% & cmdwiz showcursor 0

cmdgfx "fbox 0 0 db 0,0,%W%,%H%"
set /a WDIV=%W%/2,HDIV=%H%/2 & cmdgfx "fellipse 1 0 db !WDIV!,!HDIV!,26,9" p
set /a HM=%H%-2, HW=%W%/2-52, DELAY=0, COL=1, MODE=0, HLP=1
set HELPT=" & fbox 0 0 db 0,%HM%,%W%,2 & text a 0 0 \n\e0c\r=clear__\r1\r=circle__\r2\r=big_circle__\r3\r=line__\r4\r=eat__\r7-9\r=speed__\rp\r=mouse_draw/pause__\ra\r=color__\rm\r=mode__\rh\r=help %HW%,%HM%"
set HELP=%HELPT%

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	rem Use no storage, a bit slower
	rem cmdgfx "block 0 0,0,%W%,!HM! 0,0 -1 - 0 0 (1-(lss(col(x-1,y-1)+col(x,y-1)+col(x+1,y-1)+col(x-1,y)+col(x+1,y)+col(x-1,y+1)+col(x,y+1)+col(x+1,y+1),2)+gtr(col(x-1,y-1)+col(x,y-1)+col(x+1,y-1)+col(x-1,y)+col(x+1,y)+col(x-1,y+1)+col(x,y+1)+col(x+1,y+1),3)))*col(x,y)+eq(col(x,y)*10+col(x-1,y-1)+col(x,y-1)+col(x+1,y-1)+col(x-1,y)+col(x+1,y)+col(x-1,y+1)+col(x,y+1)+col(x+1,y+1),3) & %HELP:~1,-1%" kpw!DELAY!

	rem With storage, NOTE: "store" needs to be last on the line! (to make tinyexpr evaluate it before other expressions)
	rem cmdgfx "block 0 0,0,%W%,!HM! 0,0 -1 0 0 - store(col(x-1,y-1)+col(x,y-1)+col(x+1,y-1)+col(x-1,y)+col(x+1,y)+col(x-1,y+1)+col(x,y+1)+col(x+1,y+1),0)+(1-(lss(s0,2)+gtr(s0,3)))*col(x,y)+eq(col(x,y)*10+s0,3) & %HELP:~1,-1%" kpw!DELAY!

	rem As above, but all colors ok, not just color 1
	if !MODE!==0 cmdgfx "block 0 0,0,%W%,!HM! 0,0 -1 0 0 - store(gtr(col(x-1,y-1),0)+gtr(col(x,y-1),0)+gtr(col(x+1,y-1),0)+gtr(col(x-1,y),0)+gtr(col(x+1,y),0)+gtr(col(x-1,y+1),0)+gtr(col(x,y+1),0)+gtr(col(x+1,y+1),0),0)+((1-(lss(s0,2)+gtr(s0,3)))*gtr(col(x,y),0)+eq(col(x,y)*10+s0,3))*!COL! !HELP:~1,-1!" kpw!DELAY!

	rem As above, but with color shifts
	if !MODE! == 1 cmdgfx "block 0 0,0,%W%,!HM! 0,0 -1 0 0 - store(col(x,y)+1,1)+store(gtr(col(x-1,y-1),0)+gtr(col(x,y-1),0)+gtr(col(x+1,y-1),0)+gtr(col(x-1,y),0)+gtr(col(x+1,y),0)+gtr(col(x-1,y+1),0)+gtr(col(x,y+1),0)+gtr(col(x+1,y+1),0),0)+((1-(lss(s0,2)+gtr(s0,3)))*gtr(col(x,y),0)+eq(col(x,y)*10+s0,3))*s1 !HELP:~1,-1!" kpw!DELAY!
	
	set KEY=!errorlevel!
	set /a "XP=!RANDOM! %% %W%,YP=!RANDOM! %% !HM!,XW=!RANDOM! %% 6+2, YH=!RANDOM! %% 10+2" & set /a "XP2=!XP!+!RANDOM! %% 90+20, YP2=!YP!+!RANDOM! %% 60+20, XW2=!RANDOM! %% 20+10, YH2=!RANDOM! %% 20+10"
	if !KEY! == 109 set /a MODE+=1 & if !MODE! gtr 1 set MODE=0
	if !KEY! == 112 call :DRAW
	if !KEY! == 49 cmdgfx "ellipse 1 0 db !XP!,!YP!,!XW!,!YH!" p
	if !KEY! == 50 cmdgfx "ellipse 1 0 db !WDIV!,!HDIV!,!XW2!,!YH2!" p
	if !KEY! == 51 cmdgfx "line 1 0 db !XP!,!HDIV!,!XP2!,!HDIV!" p
	if !KEY! == 52 cmdgfx "fellipse 0 0 db !WDIV!,!HDIV!,!XW2!,!YH2! & ellipse 1 0 db !WDIV!,!HDIV!,!XW2!,!YH2!" p
	if !KEY! == 97 set /a COL+=1 & if !COL! gtr 15 set COL=1
	if !KEY! == 55 set DELAY=0
	if !KEY! == 56 set DELAY=100
	if !KEY! == 57 set DELAY=300
	if !KEY! == 99 cmdgfx "fbox 0 0 db 0,0,!W!,!H!"
	if !KEY! == 104 set /a HM=%H% & set HELP=" " & cmdgfx "fbox 0 0 db 0,%HM%,%W%,2" p & set /a HLP=1-!HLP! & if !HLP!==1 set HELP=%HELPT%& set /a HM=%H%-2
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
bg font 6 & mode 80,50 & cls
cmdwiz showcursor 1
goto :eof

:DRAW
	set KEY=0
	cmdwiz getch_or_mouse>nul
	set MR=%ERRORLEVEL%
	if %MR%==-1 goto ENDINPUT
	set /a MT=%MR% ^& 1 &if not !MT! == 0 (
	  set /a KEY=%MR%/2
	  goto ENDINPUT
	)
	set DL=0& set /a MT=%MR% ^& 2 &if !MT! geq 1 set DL=1
	set DR=0& set /a MT=%MR% ^& 4 &if !MT! geq 1 set DR=1
	set /a MX=(%MR%^>^>10) ^& 2047
	set /a MY=(%MR%^>^>21) ^& 1023
	if %DL% geq 1 cmdgfx "pixel 1 0 db %MX%,%MY%" p
	if %DR% geq 1 cmdgfx "pixel 0 0 db %MX%,%MY%" p
	:ENDINPUT
	if %KEY%==27 set STOP=1
	if %KEY%==99 cmdgfx "fbox 0 0 db 0,0,!W!,!H! !HELP:~1,-1!"
if %KEY% == 0 goto DRAW
set KEY=0
