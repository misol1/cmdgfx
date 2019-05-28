@echo off
cmdwiz setfont 6 & cls & title Z-sorted balls
set /a F8W=200, F8H=80
cmdwiz fullscreen 0
mode %F8W%,%F8H%
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xR | call %0 %* | cmdgfx_RGB "" Sf6:0,0,200,80dZ1000
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F8W=&set F8H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=200, H=80
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=2300
set /a DRAWMODE=5, NOF=7
set ASPECT=0.66

call centerwindow.bat 0 -20
call sindef.bat

set /A XROT=0,YROT=0,ZROT=0, XMUL=14000, CHMODE=1, CLR=0

set OW=16
set /A CNT=360/%OW%
set /A CNTV=%CNT%+1
set WNAME=objects\circle.ply
if exist %WNAME% goto SKIPGEN

cmdwiz print "ply\nformat ascii 1.0\nelement vertex %CNTV%\nelement face 1\nend_header\n">%WNAME%
set /A MUL=120
for /L %%a in (0,%OW%,360) do set /a S=%%a,COS=S+90 & set /a "XPOS=(%SINE(x):x=!S!*31416/180%*%MUL%>>%SHR%)" & set /A "YPOS=(%SINE(x):x=!COS!*31416/180%*%MUL%>>%SHR%)" & echo !XPOS! !YPOS! 0 >>%WNAME%
echo 24  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 0 >>%WNAME%

:SKIPGEN
set /A XP1=0,YP1=0,ZP1=-200
set /A XP2=0,YP2=0,ZP2=200
set /A XP3=200,YP3=0,ZP3=0
set /A XP4=-200,YP4=0,ZP4=0
set /A XP5=0,YP5=-200,ZP5=0
set /A XP6=0,YP6=200,ZP6=0
set /A XP7=15,YP7=-15,ZP7=0

set MUL=&set OW=&set CNT=&set CNTV=&set COS=&set STOP=

echo "cmdgfx: fbox 0 0 20"

:: set XF=X0,0,3000
set /a C16=1 & set XF=-X& if !C16!==1 set XF=X
set /a push=0, pushstep=!random! %% 200 + 100, coli=0
set colsk=skip

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

	for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do for %%d in (!DRAWMODE!) do set CRSTR="!CRSTR:~1,-1!&3d objects/plane-RGB-ball.obj !DRAWMODE!,101010 0,0,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! 10,10,10,0,0,0 0,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 b1"&set ZPP2%%c=-999999

:: should(?) work properly with z-buffer, does not (not transparent in some cases)
rem	for /L %%a in (1,1,!NOF!) do set CRSTR="!CRSTR:~1,-1!&3d objects/plane-RGB-ball.obj !DRAWMODE!,101010 0,0,0 !XPP2%%a!,!YPP2%%a!,!ZPP2%%a! 10,10,10,0,0,0 0,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 b1"
	
rem	if !CLR!==0 echo "cmdgfx: ipoly !TA!!TA!!TA! 0 ? 18 0,0,!W!,0,!W!,!H!,0,!H! & !CRSTR:~1,-1! & !MSG:~1,-1!" !XF!f6:0,0,!W!,!H!
	if !CLR!==0 echo "cmdgfx: block 0 0,0,!W!,!H! 0,0 -1 0 0 - makecol(0,0,min((x/2+y*4)/4,62)+random()*20) & !CRSTR:~1,-1! & !colsk! ipoly !COLSTR!!COLBASE! 0 ? 20 0,0,!W!,0,!W!,!H!,0,!H!" !XF!f6:0,0,!W!,!H!
	if !CLR!==1 echo "cmdgfx: fbox 0 0 20 & !CRSTR:~1,-1! & !colsk! ipoly !COLSTR!!COLBASE! 0 ? 20 0,0,!W!,0,!W!,!H!,0,!H!" !XF!f6:0,0,!W!,!H!
	if !CLR!==2 echo "cmdgfx: image img/flame.bmp 0 0 b1 -1 0,0 0 0 !W!,!H! & !CRSTR:~1,-1! & !colsk! ipoly !COLSTR!!COLBASE! 0 ? 20 0,0,!W!,0,!W!,!H!,0,!H!n" !XF!f6:0,0,!W!,!H!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

	if "!RESIZED!"=="1" set /a W=SCRW+2, H=SCRH+2, XMID=W/2, YMID=H/2, HLPY=H-2 & cmdwiz showcursor 0 & set HELPMSG="text 8 0 0 ENTER\-SPACE\-\g11\g10\-\g1f\g1e\-b\-d/D\-p\-h 1,!HLPY!"& if not !MSG!=="" set MSG=!HELPMSG!
	
	set /a XROT-=2, YROT+=1, ZROT+=1

	if !push!==1 set /a DIST-=80 & if !DIST! lss 1000 set /a push=2
	if !push!==2 set /a DIST+=80 & if !DIST! geq 2300 set /a push=0
	rem set /a pushstep-=1 & if !pushstep! leq 0 set /a pushstep=!random! %% 200 + 100, push=1
	
	if !col!==2 set HXV=0123456789abcdef&set /a coli-=1&(if !coli! leq 0 set /a col=0,coli=0&set colsk=)&for %%c in (!coli!) do set COLSTR=!HXV:~%%c,1!!HXV:~%%c,1!&set HXV=
	if !col!==1 set HXV=0123456789abcdef&set /a coli+=1&(if !coli! geq 15 set /a col=2,coli=15)&for %%c in (!coli!) do set COLSTR=!HXV:~%%c,1!!HXV:~%%c,1!&set HXV=
	
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 331 set /A NOF-=1&if !NOF! lss 2 set NOF=2
	if !KEY! == 333 set /A NOF+=1&if !NOF! gtr 7 set NOF=7
	if !KEY! == 68 set /A DIST-=120
	if !KEY! == 13 set /A CLR+=1 & if !CLR! gtr 2 set /a CLR=0
	if !KEY! == 100 set /A DIST+=120
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 120 set /a C16=1-C16 & set XF=-X& if !C16!==1 set XF=X
	if !KEY! == 27 set STOP=1
	if !KEY! == 113 set /A push=1
	if !KEY! == 99 set /A col=1,coli=0& set colsk=&set COLBASE=ffffff
	if !KEY! == 67 set /A col=1,coli=0& set colsk=&set COLBASE=000000
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
