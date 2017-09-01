@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
bg font 1
set /a W=160,H=80
mode %W%,%H% & cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2,YMID=%H%/2
set /a DIST=2500, DRAWMODE=0, BKG=0, NOF=6
set /A CRX=0,CRY=0,CRZ=0
set ASPECT=0.75
set BITOP=3
set OP=Xor

call sindef.bat

set OW=16
set /A CNT=360 / %OW%
set /A CNTV=%CNT%+1
set WNAME=circle.ply
cmdwiz print "ply\nformat ascii 1.0\nelement vertex %CNTV%\nelement face 1\nend_header\n">%WNAME%

set /A MUL=120
for /L %%a in (0,%OW%,360) do set /a S=%%a,COS=S+90 & set /a "XPOS=(%SINE(x):x=!S!*31416/180%*%MUL%>>%SHR%)" & set /A "YPOS=(%SINE(x):x=!COS!*31416/180%*%MUL%>>%SHR%)" & echo !XPOS! !YPOS! 0 >>%WNAME%
echo 24  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 0 >>%WNAME%

set /A XP1=0,YP1=0,ZP1=-250,COL1=1
set /A XP2=0,YP2=0,ZP2=250,COL2=2
set /A XP3=250,YP3=0,ZP3=0,COL3=4
set /A XP4=-250,YP4=0,ZP4=0,COL4=8
set /A XP5=0,YP5=-250,ZP5=0,COL5=6
set /A XP6=0,YP6=250,ZP6=0,COL6=3

set /A XROT=0,YROT=0,ZROT=0, XMUL=14000, SHR=13
set /A RX=0,RY=0,RZ=0

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set CRSTR=""

	set /a "srx=(%SINE(x):x=!XROT!*31416/180%*!XMUL!>>!SHR!),XRC=!XROT!+90"
	set /a "crx=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)
		
	set /a "sry=(%SINE(x):x=!YROT!*31416/180%*!XMUL!>>!SHR!),XRC=!YROT!+90"
	set /a "cry=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)

	set /a "srz=(%SINE(x):x=!ZROT!*31416/180%*!XMUL!>>!SHR!),XRC=!ZROT!+90"
	set /a "crz=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)

	for /L %%a in (1,1,!NOF!) do set /A "YPP=((!crx!*!YP%%a!)>>14)+((!srx!*!ZP%%a!)>>14),ZPP=((!crx!*!ZP%%a!)>>14)-((!srx!*!YP%%a!)>>14)" & set /A "XPP=((!cry!*!XP%%a!)>>14)+((!sry!*!ZPP!)>>14),ZPP2=((!cry!*!ZPP!)>>14)-((!sry!*!XP%%a!)>>14)" & set /A "XPP2=((!crz!*!XPP!)>>14)+((!srz!*!YPP!)>>14),YPP=((!crz!*!YPP!)>>14)-((!srz!*!XPP!)>>14)" & set /A ZPP2*=4 & set CRSTR="!CRSTR:~1,-1! &3d %WNAME% %DRAWMODE%,!BITOP! !RX!,!RY!,!RZ! !XPP2!,!YPP!,!ZPP2! 1,1,1,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 !COL%%a! 20"

	start "" /B /High cmdgfx_gdi.exe "fbox !BKG! 0 20 0,0,200,100 & !CRSTR:~1,-1! & text 9 ? 0 !OP!(space)\-Bg:!BKG!(ENTER)\-Balls:!NOF!(Left/Right) 1,78" f1
	cmdgfx.exe "" nkW15
	set KEY=!ERRORLEVEL!

	set /A XROT+=3,YROT+=2,ZROT+=1

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
