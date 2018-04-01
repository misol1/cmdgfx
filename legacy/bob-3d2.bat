@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1 & cls & mode 120,80
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a XMID=120/2, YMID=80/2-4, XMID2=120/2+120
set /a DIST=4000, ROTMODE=0, RX=0, RY=0, RZ=0, MODE=1, WAVE=0
set /a MOONC=0, MOONMOVE=1, MOONX=17
set ASPECT=0.66666

call sindef.bat

:REP
for /L %%1 in (1,1,300) do if not defined STOP (

  if !MOONMOVE!==1 for %%a in (!MOONC!) do set /a A1=%%a & set /a "MOONX=!XMID!+(%SINE(x):x=!A1!*31416/180/2%*35>>!SHR!), MOONC+=2"

  if !MODE!==0 start /B /HIGH cmdgfx_gdi "fbox 1 0 b2 0,0,120,80 & fbox 1 0 08 120,0,120,80 & 3d objects\ball-object.obj 0,0 !RX!,!RY!,!RZ! 0,0,0 0.9,0.9,0.9,0,0,0 0,0,0,50 %XMID2%,%YMID%,!DIST!,%ASPECT% 0 0 0 & block 0 120,0,120,80 0,0 08 & block 0 0,0,120,70 0,50 0 0 0 ? ? x+0 (70-y)/2 & block 0 120,0,120,80 0,0 08 " f1:0,0,240,80,120,80
  
  if !MODE!==1 start /B /HIGH cmdgfx_gdi "fbox 1 0 b2 0,0,120,80 & fbox 1 0 08 120,0,120,80 & 3d objects\ball-object.obj 0,0 !RX!,!RY!,!RZ! 0,0,0 0.9,0.9,0.9,0,0,0 0,0,0,50 %XMID2%,%YMID%,!DIST!,%ASPECT% 0 0 0 & block 0 120,0,120,80 0,0 08 & fellipse f 1 b1 !MOONX!,13,10,7 & fellipse f 7 db !MOONX!,13,9,6 & fellipse f 1 b1 !MOONX!,53,9,3 & fellipse f 0 db !MOONX!,53,8,2 & fellipse f 1 b1 !MOONX!,60,6,2 & fellipse f 0 db !MOONX!,60,5,2 & block 0 0,0,120,70 0,50 0 0 0 10b2=10b0,10b1=10b0,?c??=?4??,?a??=?2??,?f??=?7?? ? x+sin(y/2+!WAVE!/10)*6 (65-y)/0.66 & line 0 1 dc 0,50,120,50 & block 0 120,0,120,80 0,0 08" f1:0,0,240,80,120,80

  rem try y divison by 0.75 or 0.66 or 2
  
  cmdgfx.exe "" nkW10
  set KEY=!errorlevel!
  if !KEY! == 32 set /A MODE=1-!MODE!
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 100 set /A DIST+=100
  if !KEY! == 68 set /A DIST-=100
  if !KEY! == 27 set STOP=1
  if !KEY! == 109 set /A MOONMOVE=1-!MOONMOVE!
  if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set /a RX=0,RY=0,RZ=0
  if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
  if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
  if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
  if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
  if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
  if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
  if !ROTMODE! == 0 set /a RY-=7, RX+=5, RZ+=2
  set /a WAVE+=1
)
if not defined STOP goto REP

endlocal
mode 80,50 & cls
cmdwiz setfont 6
