@echo off
bg font 1 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" kOSf1:0,0,320,100,147,80W12
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cls & mode 147,80 & cmdwiz showcursor 0
set FNT=1
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==FNT set "%%v="

set /a XC=0, YC=0, XCP=9, YCP=11, MODE=0
set /a BXA=37, BYA=22

set /a XMID=90/2, YMID=80/2, BGCOL=0, IC=4, CC=15

set /a CNT=0 & for %%a in (myface.txt evild.txt ugly0.pcx mario1.gxy emma.txt glass.txt fract.txt checkers.gxy mm.txt wall.pcx apa.gxy ful.gxy) do set I!CNT!=%%a & set /a CNT+=1

set TEXT="text e 0 0 Space_c_\g11\g10\g1e\g1f_Enter 1,78"

set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra
del /Q EL.dat >nul 2>nul

:REP
for /L %%1 in (1,1,300) do if not defined STOP for %%i in (!IC!) do for %%c in (!CC!) do (

  set BKG="fbox 0 0 04 180,0,200,100 & fbox 1 %BGCOL% 20 0,0,200,100 & image img\!I%%i! %%c 0 0 e 150,0 0 0 170,100"

  if !MODE!==0 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/100+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/100+x/!BXA!+y/!BYA!)*10 from & !TEXT:~1,-1!"
  
  if !MODE!==1 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/100+x/!BYA!+y/!BXA!)*10 10+y+cos(!YC!/100+x/!BXA!+y/!BYA!)*10 from & !TEXT:~1,-1!"
  
  if !MODE!==2 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/100+x/!BYA!+y/!BXA!)*10 10+y+sin(!YC!/150+x/200+y/!BXA!+y/!BYA!)*10 from & !TEXT:~1,-1!"
  
  if !MODE!==3 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/300+y/60+x/!BYA!+x/!BXA!)*10 10+y+sin(!YC!/150+x/50+y/!BXA!+y/!BYA!)*10 from & !TEXT:~1,-1!"
  
  if !MODE!==4 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/100+x/!BXA!*0.4+y/!BYA!*0.4)*10 10+y+cos(!YC!/100+x/!BXA!*0.4+y/!BYA!*0.4)*10 from & !TEXT:~1,-1!"
  
  if !MODE!==5 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/100+x/!BXA!*3+y/!BYA!*2)*6 10+y+cos(!YC!/100+x/!BXA!*2+y/!BYA!*2)*4 from & !TEXT:~1,-1!"
  
  if !MODE!==6 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/100+x/!BXA!+y/!BYA!)*10 10+y+tan(!YC!/100+x/!BXA!*40+y/!BYA!*40)*1 from & !TEXT:~1,-1!"
  
  if !MODE!==7 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/100+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/40+x/!BXA!*5+y/!BYA!*8)*tan(!YC!/700+x/!BXA!*0.3+y/!BYA!*0.3)*2 from & !TEXT:~1,-1!"
  
  if !MODE!==8 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? x+160+sin(!XC!/90+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/20+x/5+y/4)*tan(!YC!/1700+cos(!XC!/600)*x/90+sin(!YC!/700)*y/70)+sin(!XC!/400-!YC!/220)*8 from & !TEXT:~1,-1!"
  
  if !MODE!==9 set OUT="cmdgfx: !BKG:~1,-1! & block 0 0,0,320,100 0,0 -1 0 0 ? ? y+x/20+140+sin(!XC!/300+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/225+x/!BXA!+y/!BYA!)*10 from & !TEXT:~1,-1!"
  
  echo "!OUT:~1,-1! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" f%FNT%:0,0,320,100,147,80
	
  if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
  if !KEY! == 331 set /a XCP-=1 & if !XCP! lss 0 set /a XCP=0
  if !KEY! == 333 set /a XCP+=1	
  if !KEY! == 336 set /a YCP-=1 & if !YCP! lss 0 set /a YCP=0
  if !KEY! == 328 set /a YCP+=1
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 104 set TEXT=""
  if !KEY! == 13 set /a MODE+=1&if !MODE! gtr 9 set /a MODE=0
  if !KEY! == 32 set /a IC+=1&if !IC! geq %CNT% set /a IC=0
  if !KEY! == 99 set /a CC+=1&if !CC! gtr 15 set /a CC=1
  if !KEY! == 27 set STOP=1  
  set /a XC+=!XCP!, YC+=!YCP!
  set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100 & mode 80,50 & cls
bg font 6 & cmdwiz showcursor 1
echo "cmdgfx: quit"
