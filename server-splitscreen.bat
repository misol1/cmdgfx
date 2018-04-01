@echo off
if defined __ goto :START
cls & cmdwiz showcursor 0
set __=.
cmdgfx_input.exe knW14x | call %0 %* | cmdgfx_gdi "" S
set __=
cls & mode 80,50 & cmdwiz showcursor 1
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 6 & cls & mode 120,70 & rem 120,73 to include scroller below
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a XMID=120/2, YMID=70/2-3, XMID2=80/2, YMID2=52/2-1, XMID3=120/2+2, YMID3=35/2-1
set /a DIST=2600, DIST2=12000, DIST3=4000
set /a RX=700, RY=0, RZ=0, SX=1000
set C=3366ee,
call centerwindow.bat 0 -20

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
  echo "cmdgfx: fbox 8 0 fa 0,0,120,70 & 3d objects\spaceship.obj 1,0 !RX!,!RY!,0 0,0,0 100,100,100,0,0,0 0,0,0,0 %XMID%,%YMID%,%DIST%,0.93 0 0 0" f0:0,0,120,70 - -
  echo "cmdgfx: fbox 8 0 _ 0,0,80,52 & 3d objects\spaceship.obj 1,0 !RX!,0,!RY! 0,0,0 100,100,100,0,0,0 0,0,0,0 %XMID2%,%YMID2%,!DIST2!,0.93 0 0 0" f1:80,0,80,52 - -
  echo "cmdgfx: fbox 2 0 fa 0,0,120,35 & 3d objects\spaceship.obj 3,0 !RY!,30,!RZ! 0,0,0 100,100,100,0,1,-1 0,0,0,0 %XMID3%,%YMID3%,%DIST3%,0.66 0 0 0" f6:0,35,120,35 000000,%C%808080,%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%
  rem echo "cmdgfx: image img\scroll_text2.pcx 4 0 db -1 !SX!,0" fa:0,845,1000,20 - -

  set /p INPUT=
  for /f "tokens=1,2,4,6" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul )
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1
  
  set /a KEY=0, RY-=16, RZ+=3
  set /a DIST2-=50 & if !DIST2! lss 600 set /a DIST2=12000
  set /a SX-=3 & if !SX! lss -1000 set /a SX=1000
)
if not defined STOP goto REP

echo "cmdgfx: quit"
title input:Q
endlocal
