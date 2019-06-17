@echo off
color 07
if defined __ goto :START
cls & cmdwiz showcursor 0 & title Bigfonts - split screen
set __=.
cmdgfx_input.exe knW14xR | call %0 %* | cmdgfx_gdi "" S
set __=
cls & mode 80,50 & cmdwiz showcursor 1
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 6 & cls & mode 120,66
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a W=120, H=70
set /a W2=80, H2=52, XMID3=W/2+2, HH=35, YMID3=HH/2-1
set /a DIST3=4000
set /a RX=700, RY=0, RZ=0
set C=3366ee,
call centerwindow.bat 0 -20

set /a CNT=0 & for %%a in (6 8 8 8 12 12 12 12 16 18) do set /a FH!CNT!=%%a, CNT+=1

set FONTSCR=""& set /a YP=0
for /l %%a in (0,1,9) do set /a COL=6+%%a & set FONTSCR="!FONTSCR:~1,-1!text !COL! 0 01 This_is_font_%%a 1,!YP! %%a &"& set /a YP+=!FH%%a!

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
  echo "cmdgfx: fbox 8 0 fa & !FONTSCR:~1,-1!" f0:0,0,!W!,!H! - -
  echo "cmdgfx: fbox 8 0 20  & !FONTSCR:~1,-1! & skip What?" fa:!W2!,0,!W2PP!,!H2! - -
  echo "cmdgfx: fbox 2 0 fa & 3d objects\spaceship.obj 3,0 !RY!,30,!RZ! 0,0,0 100,100,100,0,1,-1 0,0,0,0 !XMID3!,!YMID3!,%DIST3%,0.66 0 0 0 & text 0 0 = Alien_Intruders\g21 9,9 1 & text 3 0 fe Alien_Intruders\g21 10,10 1" f6:0,!HH!,!WPP!,!HHPP! 000000,%C%808080,ffffff,%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%%C%

  set /p INPUT=
  for /f "tokens=1,2,4,6, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%E, SCRW=%%F, SCRH=%%G 2>nul )
  
  if "!RESIZED!"=="1" set /a "W=SCRW, H=SCRH, W2=((W*500)/1000+1)*8, W2PP=W2+1, H2=((H*500)/1000)*12,HH=H/2, HHPP=HH+1, WPP=W+1, XMID3=W/2+2, YMID3=HH/2-1" & cmdwiz showcursor 0
  
  if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1
  
  set /a KEY=0, RY-=16, RZ+=3
)
if not defined STOP goto REP

echo "cmdgfx: quit"
title input:Q
endlocal
