@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1
set W=160&set H=80
mode %W%,%H% & cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=2000
set ASPECT=1.5
set DRAWMODE=0
set /A CRX=0,CRY=0,CRZ=0
set BITOP=3
set OP=Xor
set BKG=0

call sintable.bat
for /L %%a in (0,1,360) do set /A SV=720+%%a & set SIN!SV!=!SIN%%a!

set OW=32
set /A CNT=720 / %OW%
set /A CNTV=%CNT%+1
set WNAME=circle.ply
echo ply>%WNAME%
echo format ascii 1.0 >>%WNAME%
echo element vertex %CNTV% >>%WNAME%
echo element face 1 >>%WNAME%
echo end_header>>%WNAME%

set /A NOF=6

set /A MUL=150
for /L %%a in (0,%OW%,720) do set /A COS=%%a+180&for %%b in (!COS!) do set /a "XPOS=(!SIN%%a!*%MUL%>>14)" & set /A "YPOS=(!SIN%%b!*%MUL%>>14)" & echo !XPOS! !YPOS! 0 >>%WNAME%
echo 24  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 0 >>%WNAME%

for /L %%a in (720,1,1200) do set SIN%%a=

set /A XM=240,YM=160

set /A XA1=5,YA1=3,ZA1=-5,COL1=1,ZM1=1100
set /A XA2=-5,YA2=4,ZA2=4,COL2=2,ZM2=1400
set /A XA3=4,YA3=2,ZA3=2,COL3=4,ZM3=1900
set /A XA4=7,YA4=-5,ZA4=7,COL4=8,ZM4=800
set /A XA5=-3,YA5=4,ZA5=-6,COL5=6,ZM5=1000
set /A XA6=3,YA6=5,ZA6=-4,COL6=1,ZM6=1200

for /L %%a in (1,1,6) do set /A X%%a=%%a*40&set /A Y%%a=%%a*90&&set /A Z%%a=%%a*70

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (
set CRSTR=""
for /L %%a in (1,1,!NOF!) do for %%b in (!X%%a!) do for %%c in (!Y%%a!) do for %%d in (!Z%%a!) do set /A "XP=((!SIN%%b!*!XM!)>>14),YP=((!SIN%%c!*!YM!)>>14),ZP=((!SIN%%d!*!ZM%%a!)>>14)+500,X%%a+=!XA%%a!,Y%%a+=!YA%%a!,Z%%a+=!ZA%%a!" & set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,!BITOP!  0,0,0 0,0,0 1,1,1,!XP!,!YP!,!ZP! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%a! 0 db"&(if !X%%a! geq 720 set /A X%%a-=720)&(if !X%%a! lss 0 set /A X%%a=720+!X%%a!)&(if !Y%%a! geq 720 set /A Y%%a-=720)&(if !Y%%a! lss 0 set /A Y%%a=720+!Y%%a!)&(if !Z%%a! geq 720 set /A Z%%a-=720)&(if !Z%%a! lss 0 set /A Z%%a=720+!Z%%a!)
cmdgfx.exe "fbox !BKG! 0 20 0,0,200,100 & !CRSTR:~1,-1! & text 9 0 0 !OP!(space)\-Bg:!BKG!(ENTER)\-Balls:!NOF!(Left/Right) 1,78" k
set KEY=!ERRORLEVEL!

if !KEY! == 32 set /A BITOP+=1&(if !BITOP! gtr 6 set BITOP=0)&set CNT=0&for %%a in (NORMAL OR AND XOR ADD SUB SUB-n) do (if !CNT!==!BITOP! set OP=%%a)&set /A CNT+=1
if !KEY! == 13 set /A BKG+=1&if !BKG! gtr 15 set BKG=0
if !KEY! == 331 set /A NOF-=1&if !NOF! lss 1 set NOF=1
if !KEY! == 333 set /A NOF+=1&if !NOF! gtr 6 set NOF=6
if !KEY! == 112 cmdwiz getch
if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

del /Q %WNAME%
endlocal
cmdwiz setfont 6
mode 80,50
cls
cmdwiz showcursor 1
