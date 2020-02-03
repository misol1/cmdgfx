@echo off
cmdwiz setfont 8 & cls & title Z-sorted balls
set /a F8W=160/2, F8H=80/2
cmdwiz fullscreen 0
mode %F8W%,%F8H%
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xR | call %0 %* | cmdgfx_RGB "" Sf1:0,0,160,80d
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F8W=&set F8H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=2500
set /a DRAWMODE=0, NOF=6
set ASPECT=0.75

call centerwindow.bat 0 -20
call sindef.bat

set /A XROT=0,YROT=0,ZROT=0, XMUL=14000, CHMODE=1, CLR=0, XTRW=0,XTRH=0

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
set /A XP1=0,YP1=0,ZP1=-250
set /A XP2=0,YP2=0,ZP2=250
set /A XP3=250,YP3=0,ZP3=0
set /A XP4=-250,YP4=0,ZP4=0
set /A XP5=0,YP5=-250,ZP5=0
set /A XP6=0,YP6=250,ZP6=0

set MUL=&set OW=&set CNT=&set CNTV=&set COS=&set STOP=

set /a SHOWHELP=1
set HELPMSG="text 8 0 0 ENTER\-SPACE\-\g11\g10\-\g1f\g1e\-b\-d/D\-p\-h 1,78"
set MSG=""&if !SHOWHELP!==1 set MSG=%HELPMSG%

set /a CNT=0 & for %%a in (14 10 7 1 3) do set BO!CNT!=%%a& set /a CNT+=1
set BITOP=0

set /a OPA=128
call :MK_HEX %OPA% OP

set /a TAIL=22
call :MK_HEX %TAIL% TA

call :SETCOLS

echo "cmdgfx: fbox 0 0 20"

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

	for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do for %%d in (!DRAWMODE!) do set CRSTR="!CRSTR:~1,-1!&3d %WNAME% !DRAWMODE!,!BITOP0! 0,0,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! 1,1,1,0,0,0 0,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !COL%%c!"&set ZPP2%%c=-999999

	if !CLR!==0 echo "cmdgfx: ipoly !TA!!TA!!TA! 0 ? 18 0,0,!W!,0,!W!,!H!,0,!H! & !CRSTR:~1,-1! & !MSG:~1,-1!" Ff1:0,0,!W!,!H!!TOP!
	if !CLR!==1 echo "cmdgfx: fbox 0 0 20 & !CRSTR:~1,-1! & !MSG:~1,-1!" Ff1:0,0,!W!,!H!
	if !CLR!==2 echo "cmdgfx: image img/6hld.bmp 0 0 b1 -1 0,0 0 0 !W!,!H! & !CRSTR:~1,-1! & !MSG:~1,-1!" Ff1:0,0,!W!,!H!!TOP!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

	if "!RESIZED!"=="1" set /a W=SCRW*2+2+XTRW, H=SCRH*2+2+XTRH, XMID=W/2, YMID=H/2, HLPY=H-2 & cmdwiz showcursor 0 & set HELPMSG="text 8 0 0 ENTER\-SPACE\-\g11\g10\-\g1f\g1e\-b\-d/D\-p\-h 1,!HLPY!"& if not !MSG!=="" set MSG=!HELPMSG!
	
	set /a XROT-=3, YROT+=2, ZROT+=1

	rem Restores pos/size after exit legacy fullscreen (uses mode.com, thus PATH variable must be intact)
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz getconsoledim sw&set CMDWO=!errorlevel!&cmdwiz getconsoledim sh&set CMDHO=!errorlevel!&cmdwiz getwindowbounds x&set CMDXO=!errorlevel!&&cmdwiz getwindowbounds y&set CMDYO=!errorlevel!&cmdwiz fullscreen 1&if !errorlevel! lss 0 set LEG=1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0&if "!LEG!"=="1" mode !CMDWO!,!CMDHO!&cmdwiz setwindowpos !CMDXO! !CMDYO!)

	rem Standard: makes no attempt at restoring pos/size after exit legacy fullscreen
	rem if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	
	if !KEY! == 98 set /a BITOP+=1&(if !BITOP! gtr 4 set BITOP=0) & call :SETCOLS
	if !KEY! == 331 set /A NOF-=1&if !NOF! lss 2 set NOF=2
	if !KEY! == 333 set /A NOF+=1&if !NOF! gtr 6 set NOF=6
	if !KEY! == 336 set /A OPA-=10&(if !OPA! lss 10 set /a OPA=10) & call :MK_HEX !OPA! OP & call :SETCOLS
	if !KEY! == 328 set /A OPA+=10&(if !OPA! gtr 255 set /a OPA=255) & call :MK_HEX !OPA! OP & call :SETCOLS
	if !KEY! == 84 set /A TAIL-=4&(if !TAIL! lss 2 set /a TAIL=2) & call :MK_HEX !TAIL! TA
	if !KEY! == 116  set /A TAIL+=4&(if !TAIL! gtr 50 set /a TAIL=50) & call :MK_HEX !TAIL! TA
	if !KEY! == 32 set /A CHMODE=1-CHMODE & call :SETCOLS
	if !KEY! == 68 set /A DIST-=120
	if !KEY! == 13 set /A CLR+=1 & if !CLR! gtr 2 set /a CLR=0
	if !KEY! == 100 set /A DIST+=120
	if !KEY! == 104 set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG="")&if !SHOWHELP!==1 set MSG=!HELPMSG!
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:SETCOLS
for %%g in (!BITOP!) do set BITOP0=!BO%%g!
if !CHMODE!==0 set COL1=%OP%ee77ff 0 P&set COL2=%OP%6666ff 0 B&set COL3=%OP%55ffff 0 M&set COL4=%OP%ff6644 0 R&set COL5=%OP%00ff66 0 G&set COL6=%OP%ffff88 0 Y
if !CHMODE!==1 set COL1=%OP%ee77ff 0 db&set COL2=%OP%6666ff 0 db&set COL3=%OP%55ffff 0 db&set COL4=%OP%ff6644 0 db&set COL5=%OP%00ff66 0 db&set COL6=%OP%ffff88 0 db
goto :eof

:MK_HEX
set HXV=0123456789abcdef
set /a "HN=%1 / 16, LN=%1 %% 16"
set %2=!HXV:~%HN%,1!!HXV:~%LN%,1!
set HXV=
