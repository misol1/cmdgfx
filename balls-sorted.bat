@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1&set /a W=160, H=80, DIST=2500
mode %W%,%H% & cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W  if not %%v==DIST set "%%v="

set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=1, NOF=6
set ASPECT=1.5

call sintable.bat
for /L %%a in (0,1,180) do set /A SV=720+%%a & set SIN!SV!=!SIN%%a!
for /L %%a in (0,1,900) do set S%%a=!SIN%%a!&set SIN%%a=

set OW=32
set /A CNT=720 / %OW%
set /A CNTV=%CNT%+1
set WNAME=circle.ply
cmdwiz print "ply\nformat ascii 1.0\nelement vertex %CNTV%\nelement face 1\nend_header\n">%WNAME%

set /A MUL=150
for /L %%a in (0,%OW%,720) do set /A COS=%%a+180&for %%b in (!COS!) do set /a "XPOS=(!S%%a!*%MUL%>>14)" & set /A "YPOS=(!S%%b!*%MUL%>>14)" & echo !XPOS! !YPOS! 0 >>%WNAME%
echo 24  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 0 >>%WNAME%

set /A XP1=0,YP1=0,ZP1=-250
set /A XP2=0,YP2=0,ZP2=250
set /A XP3=250,YP3=0,ZP3=0
set /A XP4=-250,YP4=0,ZP4=0
set /A XP5=0,YP5=-250,ZP5=0
set /A XP6=0,YP6=250,ZP6=0

call :SETCOLS

set /A XROT=0,YROT=0,ZROT=0

set MUL=&set OW=&set CNT=&set CNTV=&set COS=&set W=&set H=&set STOP=

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set CRSTR=""

	for %%a in (!XROT!) do set /A srx=!S%%a!
	set /A XRC=!XROT!+180&for %%a in (!XRC!) do set /A crx=!S%%a!
	for %%a in (!YROT!) do set /A sry=!S%%a!
	set /A YRC=!YROT!+180&for %%a in (!YRC!) do set /A cry=!S%%a!
	for %%a in (!ZROT!) do set /A srz=!S%%a!
	set /A ZRC=!ZROT!+180&for %%a in (!ZRC!) do set /A crz=!S%%a!

	for /L %%a in (1,1,!NOF!) do set /A "YPP=((!crx!*!YP%%a!)>>14)+((!srx!*!ZP%%a!)>>14),ZPP=((!crx!*!ZP%%a!)>>14)-((!srx!*!YP%%a!)>>14)" & set /A "XPP=((!cry!*!XP%%a!)>>14)+((!sry!*!ZPP!)>>14),ZPP2%%a=((!cry!*!ZPP!)>>14)-((!sry!*!XP%%a!)>>14)" & set /A "XPP2%%a=((!crz!*!XPP!)>>14)+((!srz!*!YPP!)>>14),YPP2%%a=((!crz!*!YPP!)>>14)-((!srz!*!XPP!)>>14), ZPP2%%a*=4"

	for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do set CRSTR="!CRSTR:~1,-1!&3d %WNAME% !DRAWMODE!,0 0,0,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! 1,1,1,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%c!"&set ZPP2%%c=-999999

	cmdgfx.exe "fbox 1 0 20 0,0,200,100 & !CRSTR:~1,-1!" k
	set KEY=!ERRORLEVEL!

	set /A XROT+=7,YROT+=5,ZROT+=3
	if !XROT! geq 720 set /A XROT-=720
	if !YROT! geq 720 set /A YROT-=720
	if !ZROT! geq 720 set /A ZROT-=720

	if !KEY! == 331 set /A NOF-=1&if !NOF! lss 2 set NOF=2
	if !KEY! == 333 set /A NOF+=1&if !NOF! gtr 6 set NOF=6
	if !KEY! == 32 set /a DRAWMODE=1-!DRAWMODE!&call :SETCOLS
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

del /Q %WNAME%
endlocal
cmdwiz setfont 6
mode 80,50
cls
goto :eof

:SETCOLS
set COL1=9 1 db 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b2 9 1 b0
set COL2=a 2 db a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b2 a 2 b0
set COL3=c 4 db c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b2 c 4 b0
set COL4=7 8 db 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b2 7 8 b0
set COL5=e 6 db e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b2 e 6 b0
set COL6=b 3 db b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b2 b 3 b0
if %DRAWMODE%==1 goto :eof
set COL1=1 0 db&set COL2=2 0 db&set COL3=4 0 db&set COL4=8 0 db&set COL5=6 0 db&set COL6=3 0 db
