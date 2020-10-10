@echo off
cmdwiz setfont 6 & cls & title Z-sorted balls
set /a F8W=200, F8H=80
cmdwiz fullscreen 0
mode %F8W%,%F8H%
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xR | call %0 %* | cmdgfx_RGB "" Sf6:0,0,400,500,200,80dZ1000
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F8W=&set F8H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=200, H=80
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

call centerwindow.bat 0 -20
call prepareScale.bat 6 1
call sindef.bat

set /a XMID=%W%/2, YMID=%H%/2, DIST=2300
set /a DRAWMODE=5, NOF=7
set ASPECT=0.66

set /A XROT=0,YROT=0,ZROT=0, XMUL=14000, CHMODE=1, CLR=0, XTRW=0, XTRH=0

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

echo "cmdgfx: fbox 0 0 20"
call :DRAWBALLS

set /a push=0, pushstep=!random! %% 200 + 100, coli=0
set colsk=skip
set /a noise=0&set NS=&if !noise!==0 set NS=skip
set /a bkclear=1&set BS=&if !bkclear!==0 set BS=skip

::0,0,3000
set CONV16=color16 0 2
set /a C16=1 & set XF=skip& if !C16!==1 set XF=

set /a HELP=1
set HS=&if !HELP!==0 set HS=skip
set /a HLPY=H-2
set MSG="text 8 0 0 x\-ENTER\-\g11\g10\-qcC\-d/D\-p\-h 1"

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

	for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do for %%d in (!DRAWMODE!) do set CRSTR="!CRSTR:~1,-1!&3d objects/colblockballs/ball%%c.obj !DRAWMODE!,101010 0,0,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! 10,10,10,0,0,0 0,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 b1"&set ZPP2%%c=-999999

	if !CLR!==0 echo "cmdgfx: !BS! block 0 0,0,!W!,!H! 0,0 -1 0 0 - makecol(0,0,min((x/2+y*4)/4,62)+random()*20) & !CRSTR:~1,-1! & !NS! block 0 0,0,!W!,!H! 0,0 -1 0 0 - shade(fgcol(x,y),random()*40-20,random()*40-20,random()*40-20) &  !colsk! ipoly !COLSTR!!COLBASE! 0 ? 20 0,0,!W!,0,!W!,!H!,0,!H! & !XF! %CONV16% & !HS! !MSG:~1,-1!,!HLPY!" f6:0,0,400,500,!W!,!H!!TOP!
	if !CLR!==1 echo "cmdgfx: fbox 0 0 20 0,0,!W!,!H!& !CRSTR:~1,-1! & !colsk! ipoly !COLSTR!!COLBASE! 0 ? 20 0,0,!W!,0,!W!,!H!,0,!H! & !XF! %CONV16% & !HS! !MSG:~1,-1!,!HLPY!" f6:0,0,400,500,!W!,!H!!TOP!
	if !CLR!==2 echo "cmdgfx: image img/flame.bmp 0 0 b1 -1 0,0 0 0 !W!,!H! & !CRSTR:~1,-1! & !colsk! ipoly !COLSTR!!COLBASE! 0 ? 20 0,0,!W!,0,!W!,!H!,0,!H! & !XF! %CONV16% & !HS! !MSG:~1,-1!,!HLPY!" f6:0,0,400,500,!W!,!H!!TOP!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

	if "!RESIZED!"=="1" set /a W=SCRW*rW/100+2+XTRW, H=SCRH*rH/100+2+XTRH, XMID=W/2, YMID=H/2, HLPY=H-4 & cmdwiz showcursor 0 & call :DRAWBALLS
	
	set /a XROT-=2, YROT+=1, ZROT+=1

	if !push!==1 set /a DIST-=80 & if !DIST! lss 1300 set /a push=2
	if !push!==2 set /a DIST+=80 & if !DIST! geq 2300 set /a push=0
	rem set /a pushstep-=1 & if !pushstep! leq 0 set /a pushstep=!random! %% 200 + 100, push=1
	
	if !col!==2 set HXV=0123456789abcdef&set /a coli-=1&(if !coli! leq 0 set /a col=0,coli=0&set colsk=)&for %%c in (!coli!) do set COLSTR=!HXV:~%%c,1!!HXV:~%%c,1!&set HXV=
	if !col!==1 set HXV=0123456789abcdef&set /a coli+=1&(if !coli! geq 15 set /a col=2,coli=15)&for %%c in (!coli!) do set COLSTR=!HXV:~%%c,1!!HXV:~%%c,1!&set HXV=
	
	rem Experimental: Creates a "real" fullscreen even for legacy console + restores pos/size after exiting fullscreen (uses mode.com, thus PATH variable must be intact)
	rem Actually the method used in RGB-Balls2.bat is preferable (no use of gettaskbarinfo), but keeping this if that method should cause issues later somehow
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz getconsoledim sw&set CMDWO=!errorlevel!&cmdwiz getconsoledim sh&set CMDHO=!errorlevel!&cmdwiz getwindowbounds x&set CMDXO=!errorlevel!&&cmdwiz getwindowbounds y&set CMDYO=!errorlevel!&cmdwiz fullscreen 1&if !errorlevel! lss 0 set TOP=U&cmdwiz gettaskbarinfo a&set AH=!errorlevel!&(if !AH! lss 0 set /a XTRW=9,XTRH=5)&(if !AH!==0 cmdwiz gettaskbarinfo p&set POS=!errorlevel!&(if !POS! lss 2 cmdwiz gettaskbarinfo h&set /a XTRW=0,XTRH=!errorlevel!/12+1)&(if !POS! geq 2 cmdwiz gettaskbarinfo w&set /a XTRW=!errorlevel!/8+1,XTRH=0))) & (if !ISFS! gtr 0 cmdwiz fullscreen 0&if "!TOP!"=="U" mode !CMDWO!,!CMDHO!&cmdwiz setwindowpos !CMDXO! !CMDYO!&set TOP=-U&set /a XTRW=0,XTRH=0)
	
	rem Restores pos/size after exit legacy fullscreen (uses mode.com, thus PATH variable must be intact)
	rem if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz getconsoledim sw&set CMDWO=!errorlevel!&cmdwiz getconsoledim sh&set CMDHO=!errorlevel!&cmdwiz getwindowbounds x&set CMDXO=!errorlevel!&&cmdwiz getwindowbounds y&set CMDYO=!errorlevel!&cmdwiz fullscreen 1&if !errorlevel! lss 0 set LEG=1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0&if "!LEG!"=="1" mode !CMDWO!,!CMDHO!&cmdwiz setwindowpos !CMDXO! !CMDYO!)

	rem Standard: makes no attempt at restoring pos/size after exit legacy fullscreen
	rem if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	
	if !KEY! == 331 set /A NOF-=1&if !NOF! lss 2 set NOF=2
	if !KEY! == 333 set /A NOF+=1&if !NOF! gtr 7 set NOF=7
	if !KEY! == 68 set /A DIST-=120
	if !KEY! == 13 set /A CLR+=1 & if !CLR! gtr 2 set /a CLR=0
	if !KEY! == 100 set /A DIST+=120
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 120 set /a C16=1-C16 & set XF=skip& if !C16!==1 set XF=
	if !KEY! == 27 set STOP=1
	if !KEY! == 104 set /a HELP=1-HELP & set HS=&if !HELP!==0 set HS=skip
	if !KEY! == 113 set /a push=1
	if !KEY! == 114 set /a noise=1-noise&set NS=&if !noise!==0 set NS=skip
	if !KEY! == 98 set /a bkclear=1-bkclear&set BS=&if !bkclear!==0 set BS=skip
	if !KEY! == 99 set /a col=1,coli=0& set colsk=&set COLBASE=ffffff
	if !KEY! == 67 set /a col=1,coli=0& set colsk=&set COLBASE=000000
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:DRAWBALLS
echo "cmdgfx: image img\ball.bmp 0 0 db -1 0,420" !XF!f6:0,0,400,500,!W!,!H!

echo "cmdgfx: block 0 0,420,48,48 50,420 -1 0 0 - store(fgcol(x,y),0)+makecol(fgg(s0),fgb(s0),fgr(s0))"
echo "cmdgfx: block 0 0,420,48,48 100,420 -1 1 0 - store(fgcol(x,y),0)+makecol(fgb(s0),fgr(s0),fgg(s0))"
echo "cmdgfx: block 0 0,420,48,48 150,420 -1 0 0 - store(fgcol(x,y),0)+makecol(fgr(s0),fgr(s0),fgb(s0))"
echo "cmdgfx: block 0 0,420,48,48 200,420 -1 0 1 - store(fgcol(x,y),0)+makecol(fgr(s0),fgg(s0),fgr(s0))"
echo "cmdgfx: block 0 0,420,48,48 250,420 -1 1 1 - store(fgcol(x,y),0)+makecol(fgg(s0),fgr(s0),fgr(s0))"
echo "cmdgfx: block 0 0,420,48,48 300,420 -1 0 0 - store(fgcol(x,y),0)+makecol(fgr(s0),fgg(s0),fgb(s0))"
echo "cmdgfx: block 0 0,420,48,48 0,420 -1 0 1 - store(fgcol(x,y),0)+makecol(fgr(s0),fgg(s0),fgb(s0))"
rem echo "cmdgfx: block 0 0,420,48,48 0,420 -1 0 0 - store(fgcol(x,y),0)+makecol(fgg(s0),fgg(s0),fgg(s0))"
