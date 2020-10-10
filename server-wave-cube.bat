@echo off
cmdwiz fullscreen 0
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Wave expression with moving object
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,320,160,176,80t5
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cls & cmdwiz showcursor 0
set /a W=176, H=80
set /a F8W=W/2, F8H=H/2
mode %F8W%,%F8H%
for /F "Tokens=1 delims==" %%v in ('set') do  if not "%%v"=="W" if not "%%v"=="H" set "%%v="

call centerwindow.bat 0 -20
call prepareScale.bat 1

set /a WW=W*2+26, HH=H+20, MW=WW/2, HHH=H*3, H2=H*2, HLPY=H-2 

set /a XC=0, YC=0, XCP=9, YCP=11, MODE=0
set /a BXA=37, BYA=22

set /a BGCOL=0, IW=W+W/2+10

set TEXT="text e 0 0 \g11\g10\g1e\g1f_d/D 1,!HLPY!"
set /a RX=0,RY=0,RZ=0, IH=H/2, DIST=600, ZVAL=500

set /a SDIST=5500, XMID=90/2, YMID=80/2
set /A TX=0,TX2=-2600,TZ=0,TZ2=0
set COLS=f %BGCOL% 04   f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% . 7 %BGCOL% . 7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% .  8 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% .  8
set ASPECT=0.4533

:REP
for /L %%1 in (1,1,300) do if not defined STOP (

  set /a TX+=12 &if !TX! gtr 2600 set TX=-2600
  set /a TX2+=12&if !TX2! gtr 2600 set TX2=-2600

  set BKG="fbox 0 %BGCOL% X 0,0,!WW!,!HH! & 3d objects\cube-t2.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 !IW!,!IH!,!DIST!,0.75 0 0 db"

  if !MODE!==0 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/!HH!+x/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H!"
  
  if !MODE!==1 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BYA!+y/!BXA!)*10 10+y+cos(!YC!/!HH!+x/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H!"
  
  if !MODE!==2 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BYA!+y/!BXA!)*10 10+y+sin(!YC!/150+x/200+y/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H!"
  
  if !MODE!==3 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/300+y/60+x/!BYA!+x/!BXA!)*10 10+y+sin(!YC!/150+x/50+y/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H!"
  
  if !MODE!==4 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!*0.4+y/!BYA!*0.4)*10 10+y+cos(!YC!/!HH!+x/!BXA!*0.4+y/!BYA!*0.4)*10 from 0,0,!W!,!H!"
  
  if !MODE!==5 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!*3+y/!BYA!*2)*6 10+y+cos(!YC!/!HH!+x/!BXA!*2+y/!BYA!*2)*4 from 0,0,!W!,!H!"
  
  if !MODE!==6 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!+y/!BYA!)*10 10+y+tan(!YC!/!HH!+x/!BXA!*40+y/!BYA!*40)*1 from 0,0,!W!,!H!"
  
  if !MODE!==7 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/40+x/!BXA!*5+y/!BYA!*8)*tan(!YC!/700+x/!BXA!*0.3+y/!BYA!*0.3)*2 from 0,0,!W!,!H!"
  
  if !MODE!==8 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/90+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/20+x/5+y/4)*tan(!YC!/1700+cos(!XC!/600)*x/90+sin(!YC!/700)*y/70)+sin(!XC!/400-!YC!/220)*8 from 0,0,!W!,!H!"
  
  echo "!OUT:~1,-1! & block 0 0,0,!W!,!H! 0,!H2! & fbox 1 %BGCOL% 20 0,0,!W!,!H! & 3d objects\starfield200_0.ply 1,1 0,0,0 !TX!,0,!TZ! 10,10,10,0,0,0 0,0,2000,10 !XMID!,!YMID!,!SDIST!,%ASPECT% !COLS! & 3d objects\starfield200_1.ply 1,1 0,0,0 !TX2!,0,!TZ2! 10,10,10,0,0,0 0,0,2000,10 !XMID!,!YMID!,!SDIST!,%ASPECT% !COLS! & block 0 0,!H2!,!W!,!H! 0,0 X & !TEXT:~1,-1!" f1:0,0,!WW!,!HHH!,!W!,!H!FZ!ZVAL!
	
  set /p INPUT=
  for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

  if "!RESIZED!"=="1" set /a "W=SCRW*2*rW/100+2, WW=W*2+26, H=SCRH*2*rH/100+2, XMID=W/2, YMID=H/2, HH=H+20, H2=H*2, HHH=H*3, MW=WW/2, HLPY=H-4, IW=W+W/2+10, IH=H/2+10, ZVAL=500+(H-80)*2" & cmdwiz showcursor 0 & if not "!TEXT:~1,-1!"=="" set TEXT="text e 0 0 \g11\g10\g1e\g1f_Enter_d/D 1,!HLPY!"

  if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
  if !KEY! == 331 set /a XCP-=1 & if !XCP! lss 0 set /a XCP=0
  if !KEY! == 333 set /a XCP+=1	
  if !KEY! == 336 set /a YCP-=1 & if !YCP! lss 0 set /a YCP=0
  if !KEY! == 328 set /a YCP+=1
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 104 set TEXT=""
  if !KEY! == 100 set /a DIST+=10
  if !KEY! == 68 set /a DIST-=10
  if !KEY! == 13 set /a MODE+=1&if !MODE! gtr 8 set /a MODE=0
  if !KEY! == 27 set STOP=1  
  set /a XC+=!XCP!, YC+=!YCP!
  set /a RX+=5, RY+=7, RZ+=2
  set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay !HH!
echo "cmdgfx: quit"
title input:Q
