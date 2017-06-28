@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls & mode 80,50
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a XMID=80/2, YMID=50/2-1
set /a DIST=4000, DRAWMODE=1, END=0
set /a RX=700, RY=0, RZ=0
set ASPECT=0.9375

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
  cmdgfx "3d objects\spaceship.obj !DRAWMODE!,0 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0" k
  set KEY=!errorlevel!
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 32 set /A DRAWMODE+=1&if !DRAWMODE! gtr 3 set DRAWMODE=0
  
  if !KEY! == 27 if !END!==0 set END=1
  if !END! == 1 set /a "CHK=(!RY! %% 1440)*-1, DIST+=5" & if !CHK! geq 720 if !CHK! lss 730 set END=2
  if !END! == 2 set /a DIST+=120,RZ-=3 & if !DIST! gtr 25000 set STOP=1

  if !END! lss 2 set /a RY-=6
)
if not defined STOP goto REP

endlocal
cls
