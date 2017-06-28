@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 1 & cls & mode 120,80
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a XMID=120/2, YMID=80/2-1, XMID2=120/2+120
set /a DIST=4000, ROTMODE=0, RX=0, RY=0, RZ=0, MODE=1
set ASPECT=0.66666

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
  if !MODE!==0 start /B /HIGH cmdgfx_gdi "fbox 1 0 b2 0,0,200,200 & 3d objects\ball-object.obj 0,0 !RX!,!RY!,!RZ! 0,0,0 0.9,0.9,0.9,0,0,0 0,0,0,50 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0" f1
  if !MODE!==1 start /B /HIGH cmdgfx_gdi "fbox 1 0 b2 0,0,120,80 & fbox 1 0 08 120,0,120,80 & 3d objects\ball-object.obj 0,0 !RX!,!RY!,!RZ! 0,0,0 0.9,0.9,0.9,0,0,0 0,0,0,50 %XMID2%,%YMID%,!DIST!,%ASPECT% 0 0 0 & & block 0 120,0,120,80 9,4 08 0 0 ????=10b1& block 0 120,0,120,80 0,0 08" f1:0,0,240,80,120,80
  cmdgfx.exe "" nkW10
  set KEY=!errorlevel!
  if !KEY! == 32 set /A MODE=1-!MODE!
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 100 set /A DIST+=100
  if !KEY! == 68 set /A DIST-=100
  if !KEY! == 27 set STOP=1  
  if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
  if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
  if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
  if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
  if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
  if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
  if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
  if !ROTMODE! == 0 set /a RY-=7, RX+=5, RZ+=2	
)
if not defined STOP goto REP

endlocal
mode 80,50 & cls
bg font 6
