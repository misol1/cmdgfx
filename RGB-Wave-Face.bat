@echo off
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Wave expression
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xRz55 | call %0 %* | cmdgfx_RGB_32 "" Sf1:0,0,320,160,147,80t4
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cls & cmdwiz showcursor 0
set /a W=147, H=80
set /a F8W=W/2, F8H=H/2
mode %F8W%,%F8H%
for /F "Tokens=1 delims==" %%v in ('set') do  if not "%%v"=="W" if not "%%v"=="H" set "%%v="
set /a WW=W*2+26, HH=H+20, MW=WW/2

call centerwindow.bat 0 -20

set /a XC=0, YC=0, XCP=9, YCP=11, MODE=0
set /a BXA=37, BYA=22

set /a BGCOL=0, IC=0, CC=15
set /a IX=MW-10, IW=MW+10

set /a CNT=0 & for %%a in (hmm.bmp 6hld.bmp water2.bmp flame.bmp 123.bmp ) do set I!CNT!=%%a & set /a CNT+=1

set TEXT="text e 0 0 Space_\g11\g10\g1e\g1f_Enter 1,78"

:REP
for /L %%1 in (1,1,300) do if not defined STOP for %%i in (!IC!) do for %%c in (!CC!) do (

  set BKG="fbox 0 0 04 1!H!,0,!WW!,!HH! & fbox 1 %BGCOL% 20 0,0,!WW!,!HH! & image img\!I%%i! %%c 0 0 e !IX!,0 0 0 !IW!,!HH!"

  if !MODE!==0 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/!HH!+x/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==1 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BYA!+y/!BXA!)*10 10+y+cos(!YC!/!HH!+x/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==2 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BYA!+y/!BXA!)*10 10+y+sin(!YC!/150+x/200+y/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==3 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/300+y/60+x/!BYA!+x/!BXA!)*10 10+y+sin(!YC!/150+x/50+y/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==4 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!*0.4+y/!BYA!*0.4)*10 10+y+cos(!YC!/!HH!+x/!BXA!*0.4+y/!BYA!*0.4)*10 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==5 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!*3+y/!BYA!*2)*6 10+y+cos(!YC!/!HH!+x/!BXA!*2+y/!BYA!*2)*4 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==6 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!+y/!BYA!)*10 10+y+tan(!YC!/!HH!+x/!BXA!*40+y/!BYA!*40)*1 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==7 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/!HH!+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/40+x/!BXA!*5+y/!BYA!*8)*tan(!YC!/700+x/!BXA!*0.3+y/!BYA!*0.3)*2 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==8 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? x+!MW!+sin(!XC!/90+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/20+x/5+y/4)*tan(!YC!/1700+cos(!XC!/600)*x/90+sin(!YC!/700)*y/70)+sin(!XC!/400-!YC!/220)*8 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  if !MODE!==9 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,!WW!,!HH! 0,0 -1 0 0 ? ? y+x/20+(!MW!-20)+sin(!XC!/300+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/225+x/!BXA!+y/!BYA!)*10 from 0,0,!W!,!H! & !TEXT:~1,-1!"
  
  echo "!OUT:~1,-1!" f1:0,0,!WW!,!HH!,!W!,!H!F
	
  set /p INPUT=
  for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

  if "!RESIZED!"=="1" set /a "W=SCRW*2+2, WW=W*2+26, H=SCRH*2+2, HH=H+20, MW=WW/2, HLPY=H-4, IX=MW-10, IW=MW+10" & cmdwiz showcursor 0 & if not "!TEXT:~1,-1!"=="" set TEXT="text e 0 0 Space_\g11\g10\g1e\g1f_Enter 1,!HLPY!"

  if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
  if !KEY! == 331 set /a XCP-=1 & if !XCP! lss 0 set /a XCP=0
  if !KEY! == 333 set /a XCP+=1	
  if !KEY! == 336 set /a YCP-=1 & if !YCP! lss 0 set /a YCP=0
  if !KEY! == 328 set /a YCP+=1
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 104 set TEXT=""
  if !KEY! == 32 set /a IC+=1&if !IC! geq %CNT% set /a IC=0
  if !KEY! == 13 set /a MODE+=1&if !MODE! gtr 9 set /a MODE=0
  if !KEY! == 27 set STOP=1  
  set /a XC+=!XCP!, YC+=!YCP!
  set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay !HH!
echo "cmdgfx: quit"
title input:Q
