@echo off
bg font 8 & cls
set /a F8W=180/2, F8H=80/2
mode %F8W%,%F8H%
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW12x | call %0 %* | cmdgfx_gdi "" Sf1:0,0,330,80,180,80
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
set F8W=&set F8H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="
call centerwindow.bat 0 -20

set /a XC=0, YC=0, XCP=8, YCP=5, MXC=600, MYC=0
set /a D1=2, D2=2, D3=2, D4=2
set /a BXA=6, BYA=4 & set /a BY=-!BYA!
set BALLS=""&set BALLS2=""
set /a YMOD=9, BYA=4 & for /L %%a in (1,1,16) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,26) do set BALLS="!BALLS:~1,-1!&pixel f 1 . !BX!,!BY!"& set /a BX+=!BXA!
set /a YMOD=4, BYA=6 & set /a BY=-4 & for /L %%a in (1,1,11) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,26) do set /a COL=%%a+0 & set BALLS2="!BALLS2:~1,-1!&fellipse !COL! 1 . !BX!,!BY!,3,3"& set /a BX+=!BXA!
echo "cmdgfx: fbox 1 0 db 180,0,180,80 & %BALLS:~1,-1%" c:180,0,150,80
echo "cmdgfx: fbox 1 0 db 180,0,180,80 & %BALLS2:~1,-1%" c:180,0,150,80
set BALLS=&set BALLS2=
set /a MODE=0
if !MODE!==0 set /a YMOD=9, BYA=4
if !MODE!==1 set /a YMOD=4, BYA=6
set TEXT=text e 0 0 Space_\g11\g10\g1e\g1f_1-4(+shift) 1,78

call sindef.bat

:REP
for /L %%1 in (1,1,300) do if not defined STOP (

  set /a A1=!MYC!/4, A2=!MXC!/13 & set /a "YMUL=(%SINE(x):x=!A1!*31416/180%*20>>!SHR!), XMUL=(%SINE(x):x=!A2!*31416/180%*15>>!SHR!)"

  echo "cmdgfx: fbox 1 0 db 180,0,180,80 & fbox 1 0 b1 0,0,180,80 & image capture-!MODE!.gxy 0 0 0 -1 180,0 & block 0 0,0,330,80 0,0 -1 0 0 ? ? 17+x-180+sin(!XC!/100+floor((x-180)/!BXA!)*0.!D1!+floor(y/!BYA!)*0.!D2!)*!XMUL!+eq(fgcol(x,y),1)*500  !YMOD!+y+cos(!YC!/100+floor((x-180)/!BXA!)*0.!D3!+floor(y/!BYA!)*0.!D4!)*!YMUL! to 180,0,150,80 & !TEXT!" F
  
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul )
  
  if !KEY! == 32 set /a MODE=1-!MODE! & (if !MODE!==0 set /a YMOD=9, BYA=4) & if !MODE!==1 set /a YMOD=4, BYA=6
  if !KEY! == 331 set /a XCP-=1 & if !XCP! lss 0 set /a XCP=0
  if !KEY! == 333 set /a XCP+=1
  if !KEY! == 336 set /a YCP-=1 & if !YCP! lss 0 set /a YCP=0
  if !KEY! == 328 set /a YCP+=1
  if !KEY! == 49 set /a D1+=1 & if !D1! gtr 9 set /a D1=9
  if !KEY! == 50 set /a D2+=1 & if !D2! gtr 9 set /a D2=9
  if !KEY! == 51 set /a D3+=1 & if !D3! gtr 9 set /a D3=9
  if !KEY! == 52 set /a D4+=1 & if !D4! gtr 9 set /a D4=9
  if !KEY! == 33 set /a D1-=1 & if !D1! lss 0 set /a D1=0
  if !KEY! == 34 set /a D2-=1 & if !D2! lss 0 set /a D2=0
  if !KEY! == 35 set /a D3-=1 & if !D3! lss 0 set /a D3=0
  if !KEY! == 207 set /a D4-=1 & if !D4! lss 0 set /a D4=0
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1  
  set /a XC+=!XCP!, YC+=!YCP!, MYC+=1, MXC+=2, KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 300
echo "cmdgfx: quit"
echo Q>inputflags.dat
del /Q capture-?.gxy >nul 2>nul
