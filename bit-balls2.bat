@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 1
set W=160&set H=80
mode %W%,%H% & cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=2500
set ASPECT=1.5
set DRAWMODE=0
set /A CRX=0,CRY=0,CRZ=0
set BITOP=3
set OP=Xor
set BKG=0

call sintable.bat
for /L %%a in (0,1,180) do set /A SV=720+%%a & set SIN!SV!=!SIN%%a!

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

set /A XP1=0,YP1=0,ZP1=-250,COL1=1
set /A XP2=0,YP2=0,ZP2=250,COL2=2
set /A XP3=250,YP3=0,ZP3=0,COL3=4
set /A XP4=-250,YP4=0,ZP4=0,COL4=8
set /A XP5=0,YP5=-250,ZP5=0,COL5=6
set /A XP6=0,YP6=250,ZP6=0,COL6=3

set /A XROT=0,YROT=0,ZROT=0
set /A RX=0,RY=0,RZ=0

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (
set CRSTR=""

for %%a in (!XROT!) do set /A srx=!SIN%%a!
set /A XRC=!XROT!+180&for %%a in (!XRC!) do set /A crx=!SIN%%a!
for %%a in (!YROT!) do set /A sry=!SIN%%a!
set /A YRC=!YROT!+180&for %%a in (!YRC!) do set /A cry=!SIN%%a!
for %%a in (!ZROT!) do set /A srz=!SIN%%a!
set /A ZRC=!ZROT!+180&for %%a in (!ZRC!) do set /A crz=!SIN%%a!

for /L %%a in (1,1,!NOF!) do set /A "YPP=((!crx!*!YP%%a!)>>14)+((!srx!*!ZP%%a!)>>14),ZPP=((!crx!*!ZP%%a!)>>14)-((!srx!*!YP%%a!)>>14)" & set /A "XPP=((!cry!*!XP%%a!)>>14)+((!sry!*!ZPP!)>>14),ZPP2=((!cry!*!ZPP!)>>14)-((!sry!*!XP%%a!)>>14)" & set /A "XPP2=((!crz!*!XPP!)>>14)+((!srz!*!YPP!)>>14),YPP=((!crz!*!YPP!)>>14)-((!srz!*!XPP!)>>14)" & set /A ZPP2*=4 & set CRSTR="!CRSTR:~1,-1! &3d %WNAME% %DRAWMODE%,!BITOP! !RX!,!RY!,!RZ! !XPP2!,!YPP!,!ZPP2! 1,1,1,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%a! 0 db"
cmdgfx.exe "fbox !BKG! 0 20 0,0,200,100 & !CRSTR:~1,-1! & text 9 0 0 !OP!(space)\-Bg:!BKG!(ENTER)\-Balls:!NOF!(Left/Right) 1,78" k
set KEY=!ERRORLEVEL!

set /A XROT+=6,YROT+=4,ZROT+=2
if !XROT! geq 720 set /A XROT-=720
if !YROT! geq 720 set /A YROT-=720
if !ZROT! geq 720 set /A ZROT-=720

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
bg font 6
mode 80,50
cls
