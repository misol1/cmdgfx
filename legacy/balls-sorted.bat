@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1&set /a W=160, H=80, DIST=2500
mode %W%,%H% & cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W  if not %%v==DIST set "%%v="

set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=1, NOF=6
set ASPECT=0.75
set /A XROT=0,YROT=0,ZROT=0, XMUL=14000

call sindef.bat

set OW=16
set /A CNT=360 / %OW%
set /A CNTV=%CNT%+1
set WNAME=circle.ply
cmdwiz print "ply\nformat ascii 1.0\nelement vertex %CNTV%\nelement face 1\nend_header\n">%WNAME%

set /A MUL=120
for /L %%a in (0,%OW%,360) do set /a S=%%a,COS=S+90 & set /a "XPOS=(%SINE(x):x=!S!*31416/180%*%MUL%>>%SHR%)" & set /A "YPOS=(%SINE(x):x=!COS!*31416/180%*%MUL%>>%SHR%)" & echo !XPOS! !YPOS! 0 >>%WNAME%
echo 24  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 0 >>%WNAME%

set /A XP1=0,YP1=0,ZP1=-250
set /A XP2=0,YP2=0,ZP2=250
set /A XP3=250,YP3=0,ZP3=0
set /A XP4=-250,YP4=0,ZP4=0
set /A XP5=0,YP5=-250,ZP5=0
set /A XP6=0,YP6=250,ZP6=0

call :SETCOLS

set MUL=&set OW=&set CNT=&set CNTV=&set COS=&set W=&set H=&set STOP=

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set CRSTR=""

	set /a "srx=(%SINE(x):x=!XROT!*31416/180%*!XMUL!>>!SHR!),XRC=!XROT!+90"
	set /a "crx=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)
	
	set /a "sry=(%SINE(x):x=!YROT!*31416/180%*!XMUL!>>!SHR!),XRC=!YROT!+90"
	set /a "cry=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)

	set /a "srz=(%SINE(x):x=!ZROT!*31416/180%*!XMUL!>>!SHR!),XRC=!ZROT!+90"
	set /a "crz=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)
	
	for /L %%a in (1,1,!NOF!) do set /A "YPP=((!crx!*!YP%%a!)>>14)+((!srx!*!ZP%%a!)>>14),ZPP=((!crx!*!ZP%%a!)>>14)-((!srx!*!YP%%a!)>>14)" & set /A "XPP=((!cry!*!XP%%a!)>>14)+((!sry!*!ZPP!)>>14),ZPP2%%a=((!cry!*!ZPP!)>>14)-((!sry!*!XP%%a!)>>14)" & set /A "XPP2%%a=((!crz!*!XPP!)>>14)+((!srz!*!YPP!)>>14),YPP2%%a=((!crz!*!YPP!)>>14)-((!srz!*!XPP!)>>14), ZPP2%%a*=4"

	for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do set CRSTR="!CRSTR:~1,-1!&3d %WNAME% !DRAWMODE!,0 0,0,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! 1,1,1,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%c!"&set ZPP2%%c=-999999

	start "" /B /High cmdgfx_gdi.exe "fbox 1 0 20 0,0,200,100 & !CRSTR:~1,-1!" f1
	cmdgfx.exe "" nkW15
	set KEY=!ERRORLEVEL!

	set /a XROT-=3, YROT+=2, ZROT+=1

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
