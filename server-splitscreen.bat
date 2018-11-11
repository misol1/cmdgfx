@echo off
color 07
if defined __ goto :START
cls & cmdwiz showcursor 0 & title Split screen
set __=.
cmdgfx_input.exe knW14xR | call %0 %* | cmdgfx_gdi "" S
set __=
cls & mode 80,50 & cmdwiz showcursor 1
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 6 & cls & mode 120,70
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a W=120, H=70
set /a XMID=W/2, YMID=H/2-3, W2=80, H2=52, XMID2=W2/2, YMID2=H2/2-1, XMID3=W/2+2, HH=35, YMID3=HH/2-1
set /a DIST=2600, DIST2=12000, DIST3=4000
set /a RX=700, RY=0, RZ=0, SX=1000
set C=3366ee,
call centerwindow.bat 0 -20

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
  echo "cmdgfx: fbox 8 0 fa & 3d objects\spaceship.obj 1,0 !RX!,!RY!,0 0,0,0 100,100,100,0,0,0 0,0,0,0 !XMID!,!YMID!,%DIST%,0.93 0 0 0" f0:0,0,!W!,!H! - -
  echo "cmdgfx: fbox 8 0 _  & 3d objects\spaceship.obj 1,0 !RX!,0,!RY! 0,0,0 100,100,100,0,0,0 0,0,0,0 !XMID2!,!YMID2!,!DIST2!,0.93 0 0 0" f1:!W2!,0,!W2PP!,!H2! - -
  echo "cmdgfx: fbox 2 0 fa & 3d objects\spaceship.obj 3,0 !RY!,30,!RZ! 0,0,0 100,100,100,0,1,-1 0,0,0,0 !XMID3!,!YMID3!,%DIST3%,0.66 0 0 0" f6:0,!HH!,!WPP!,!HHPP! 000000,%C%808080,%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%

  set /p INPUT=
  for /f "tokens=1,2,4,6, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%E, SCRW=%%F, SCRH=%%G 2>nul )
  
  if "!RESIZED!"=="1" set /a "W=SCRW, H=SCRH, XMID=W/2, YMID=H/2-3, W2=(W*666)/1000+1, W2PP=W2+1, H2=(H*750)/1000, XMID2=W2/2, YMID2=H2/2-1, HH=H/2, HHPP=HH+1, WPP=W+1, XMID3=W/2+2, YMID3=HH/2-1" & cmdwiz showcursor 0
  
  if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1
  
  set /a KEY=0, RY-=16, RZ+=3
  set /a DIST2-=50 & if !DIST2! lss 600 set /a DIST2=12000
)
if not defined STOP goto REP

echo "cmdgfx: quit"
title input:Q
endlocal
