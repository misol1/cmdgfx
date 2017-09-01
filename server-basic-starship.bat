@echo off
if defined __ goto :START
bg font 6 & cls & mode 80,50
set __=.
cmdgfx_input.exe knW4x | call %0 %* | cmdgfx_gdi "" Sf6:0,0,80,50
set __=
cls
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls & mode 80,50
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a XMID=80/2, YMID=50/2-1
set /a DIST=4000, DRAWMODE=1, END=0
set /a RX=700, RY=0, RZ=0
set ASPECT=0.9375

call centerwindow.bat 0 -20

set HELPMSG=text 1 0 0 Space\-Esc\-h 1,48
set MSG=%HELPMSG%
set /a SHOWHELP=1

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
  
  echo "cmdgfx: fbox 7 0 20 0,0,80,50 & 3d objects\spaceship.obj !DRAWMODE!,0 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0 & !MSG!" F

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul )

  if !KEY! == 112 cmdwiz getch
  if !KEY! == 32 set /A DRAWMODE+=1&if !DRAWMODE! gtr 3 set DRAWMODE=0
	if !KEY! == 104 set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
  
  if !KEY! == 27 if !END!==0 set END=1
  if !END! == 1 set /a "CHK=(!RY! %% 1440)*-1, DIST+=5" & if !CHK! geq 720 if !CHK! lss 730 set END=2
  if !END! == 2 set /a DIST+=120,RZ-=3 & if !DIST! gtr 25000 set STOP=1
  set /a KEY=0
  
  if !END! lss 2 set /a RY-=6
)
if not defined STOP goto REP

cmdwiz delay 100
echo "cmdgfx: quit"
echo Q>inputflags.dat
endlocal
