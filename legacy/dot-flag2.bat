@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1 & cls & mode 180,80 & cmdwiz showcursor 0
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a XC=0, YC=0, XCP=8, YCP=5, MXC=600, MYC=0
set /a D1=2, D2=2, D3=2, D4=2
set /a BXA=6, BYA=4 & set /a BY=-!BYA!
set BALLS=""
cmdwiz setbuffersize 360 k
if "%~1" == "" set /a YMOD=9 & for /L %%a in (1,1,16) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,26) do set BALLS="!BALLS:~1,-1!&pixel f 1 . !BX!,!BY!"& set /a BX+=!BXA!
if not "%~1" == "" set /a YMOD=4, BYA=6 & for /L %%a in (1,1,11) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,26) do set /a COL=%%a+0 & set BALLS="!BALLS:~1,-1!&fellipse !COL! 1 . !BX!,!BY!,3,3"& set /a BX+=!BXA!
cmdgfx "fbox 1 0 db 180,0,180,80 & %BALLS:~1,-1%"
cmdwiz saveblock btemp 180 0 180 80
cmdwiz setbuffersize 180 k
set BALLS=

call sindef.bat

:REP
for /L %%1 in (1,1,300) do if not defined STOP (

  set /a A1=!MYC!/4, A2=!MXC!/13 & set /a "YMUL=(%SINE(x):x=!A1!*31416/180%*20>>!SHR!), XMUL=(%SINE(x):x=!A2!*31416/180%*15>>!SHR!)"

  start /B /HIGH cmdgfx_gdi "fbox 1 0 db 180,0,180,80 & fbox 1 0 b1 0,0,180,80 & image btemp.gxy 0 0 0 -1 180,0 & block 0 0,0,330,80 0,0 -1 0 0 ? ? 17+x-180+sin(!XC!/100+floor((x-180)/!BXA!)*0.!D1!+floor(y/!BYA!)*0.!D2!)*!XMUL!+eq(fgcol(x,y),1)*500  !YMOD!+y+cos(!YC!/100+floor((x-180)/!BXA!)*0.!D3!+floor(y/!BYA!)*0.!D4!)*!YMUL!" f1:0,0,330,80
  
  cmdgfx.exe "" knW10
  set KEY=!errorlevel!
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
  set /a XC+=!XCP!, YC+=!YCP!, MYC+=1, MXC+=2
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100 & mode 80,50 & cls
cmdwiz setfont 6 & cmdwiz showcursor 1
del /Q btemp.gxy >nul 2>nul
