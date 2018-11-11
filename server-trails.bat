@echo off
if defined __ goto :START
set __=.
cls & cmdwiz setfont 6 & cmdwiz showcursor 0 & title Trails
set /a W=110, H=55
mode %W%,%H%
set /a W*=2, H*=2
cmdgfx_input.exe knW12xR | call %0 %* | cmdgfx_gdi "" Sf0:0,0,%W%,%H%Z500
set __=
set W=&set H=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
call centerwindow.bat 0 -20

set /a XMID=%W%/2, YMID=%H%/2
set /a CRX=0,CRY=0,CRZ=0,CNT=0
set /a MODE=0, SHOWHELP=1

set TPALETTE0=0 0 0  0 0 0  0 0 0  0 0 0  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db & set /a TL0=10
set TPALETTE1=b 7 b1 & set /a TL1=3
set TPALETTE2=b 7 b1 & set /a TL2=2
set TPALETTE3=b 7 b1 & set /a TL2=1
set TPALETTE=!TPALETTE%MODE%!
set TRAIL_LEN=!TL%MODE%!

set TRANSFORM=b7b1=70db,70db=97b1,97b1=97b2,97b2=90db,90db=91b1,91b1=91b0,91b0=10db,10db=10b2,10b2=10b1,10b1=10b0,10b0=00db
::set TRANSFORM=b7b1=70db,70db=97b1,97b1=97b2,97b2=90db,90db=91b1,91b1=91b0,91b0=1021,10db=10b2,10b2=10b1,10b1=10b0,10b0=00db

set /a HLPX=2, HLPY=H-2, ZVAL=500
set HELPMSG=text 3 0 0 SPACE\-\g11\g10\-dD\-h !HLPX!,!HLPY!
set MSG=& if !SHOWHELP!==1 set MSG=!HELPMSG!

set STOP=
:LOOP
for /L %%_ in (1,1,300) do if not defined STOP (

	set /a CRZ+=2, CRY+=3, CRX+=7, CNT+=1
	set SKIP=skip & if !CNT! geq !TRAIL_LEN! set SKIP= & set /a CNT=0
	
	if !MODE!==0 echo "cmdgfx: !SKIP! block 0 0,0,!W!,!H! 0,0 -1 0 0 %TRANSFORM% & 3d objects\torus.plg 1,0 !CRX!,!CRY!,!CRZ! 0,0,0 -1,-1,-1,0,0,0 0,0,0,0 !XMID!,!YMID!,1500,0.66 !TPALETTE! & !MSG!" f0:0,0,!W!,!H!Z!ZVAL!
 	if !MODE!==1 echo "cmdgfx: !SKIP! block 0 0,0,!W!,!H! 0,0 -1 0 0 %TRANSFORM% & 3d objects\plane.obj 3,0 !CRX!,!CRY!,!CRZ! 0,0,0 50,50,50,0,0,0 0,0,0,0 !XMID!,!YMID!,3000,0.66 !TPALETTE! & !MSG!" f0:0,0,!W!,!H!Z!ZVAL!
	if !MODE!==2 echo "cmdgfx: !SKIP! block 0 0,0,!W!,!H! 0,0 -1 0 0 %TRANSFORM% & 3d objects\plot-torus.ply 3,0 !CRX!,!CRY!,!CRZ! 0,0,0 1,1,1,0,0,0 0,0,0,0 !XMID!,!YMID!,4000,0.66 !TPALETTE! & !MSG!" f0:0,0,!W!,!H!Z!ZVAL!
	if !MODE!==3 echo "cmdgfx: !SKIP! block 0 0,0,!W!,!H! 0,0 -1 0 0 %TRANSFORM% & 3d objects\icosahedron.ply 3,0 !CRX!,!CRY!,!CRZ! 0,0,0 500,500,500,0,0,0 0,0,0,0 !XMID!,!YMID!,2700,0.66 !TPALETTE! & !MSG!" f0:0,0,!W!,!H!Z!ZVAL!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

	if "!RESIZED!"=="1" set /a "W=SCRW*2, H=SCRH*2, XMID=W/2, YMID=H/2, HLPX=2, HLPY=H-2" & cmdwiz showcursor 0 & set HELPMSG=text 3 0 0 SPACE\-\g11\g10\-dD\-h !HLPX!,!HLPY!&if !SHOWHELP!==1 set MSG=!HELPMSG!
		
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	if !KEY! == 32 set /a MODE+=1 & (if !MODE! gtr 3 set /a MODE=0) & for %%a in (!MODE!) do set TPALETTE=!TPALETTE%%a!&set TRAIL_LEN=!TL%%a!
	if !KEY! == 331 set /a TRAIL_LEN-=1 & if !TRAIL_LEN! lss 1 set /a TRAIL_LEN=1
	if !KEY! == 333 set /a TRAIL_LEN+=1
	if !KEY! == 68 set /a ZVAL+=10
	if !KEY! == 100 set /a ZVAL-=10 & if !ZVAL! lss 10 set /a ZVAL=10
	if !KEY! == 104 set /a SHOWHELP=1-!SHOWHELP!&set MSG=& echo "cmdgfx: line 0 0 0 0,!HLPY!,25,!HLPY!" & if !SHOWHELP!==1 set MSG=!HELPMSG!
	set /a KEY=0
)
if not defined STOP goto LOOP
endlocal
echo "cmdgfx: quit"
title input:Q
