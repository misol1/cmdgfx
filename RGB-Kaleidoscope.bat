@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title Kaleidoscope
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_RGB "" Sf0:0,0,220,110s
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
rem start "" /B dlc.exe -p "Cari Lekebusch_ - Obscurus Sanctus.mp3">nul
set /a W=220, H=110
set /a F6W=W/2, F6H=H/2
mode %F6W%,%F6H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
call centerwindow.bat 0 -16

set /a XMID=%W%/2, YMID=%H%/2, DIST=2100, TRIDIST=7000, DRAWMODE=0, MODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.6665

set /a S1=66, S2=12, S3=30, TRINUM=0
if "%~1" == "1" set /a S1=33, S2=24, S3=15, TRINUM=1
if "%~1" == "2" set /a S1=100, S2=8, S3=45, TRINUM=2
if "%~1" == "3" set /a S1=25, S2=30, S3=12, TRINUM=3

set FN0=objects\tri%TRINUM%.obj
set FN1=objects\tri-FS-%TRINUM%.obj
set FN2=objects\tri-FS2-%TRINUM%.obj
set FN=%FN0%

if exist %FN0% if exist %FN1% if exist %FN2% goto SKIPGEN

set FN=%FN2%
echo usemtl cmdblock 0 0 170 170 >%FN%
echo v  0 0 0 >>%FN%
echo v  0 100 0 >>%FN%
echo v  %S1% 100 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo f 1/1/ 2/2/ 3/3/ >>%FN%

set FN=%FN1%
echo usemtl cmdblock 0 0 110 110 >%FN%
echo v  0 0 0 >>%FN%
echo v  0 100 0 >>%FN%
echo v  %S1% 100 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo f 1/1/ 2/2/ 3/3/ >>%FN%

set FN=%FN0%
echo usemtl cmdblock 0 0 70 70 >%FN%
echo v  0 0 0 >>%FN%
echo v  0 100 0 >>%FN%
echo v  %S1% 100 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo f 1/1/ 2/2/ 3/3/ >>%FN%

:SKIPGEN
set /a A1=155, A2=0, A3=0, CNT=0
set /a TRANSP=0, TV=-1
set /a MONO=0 & set MONS=

set /a LIGHT=0, LTIME=990

rem set /a MODE=1, TV=20, TRANSP=1, CUPOS=35

set /a MODE=0, TV=0, TRANSP=1, CUPOS=35

set /a CS=0,CCNT=0,C0=8,C1=7,CDIV=6,CW=0 & set /a CEND=2*!CDIV! & set C2=f&set C3=f&set C4=f

set /a SHOWHELP=1
set HELPMSG=text 7 0 0 SPACE\-ENTER\-x\-p\-h 1,108
if !SHOWHELP!==1 set MSG=%HELPMSG%

set /a C16=0 & if !C16!==1 set XF=X

set STOP=
:LOOP
for /L %%_ in (1,1,300) do if not defined STOP (

	set /a A1+=1, A2+=2, A3-=1, TRZ=!CRZ!
	if !MODE!==0 set OUTP="fbox 0 0 20 & 3d objects\cube-t-RGB.obj 5,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==1 set OUTP="fbox 0 0 20 & 3d objects\cube-t-RGB2.obj 5,-1 !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 1,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==2 set OUTP="fbox 0 0 20 & 3d objects\cube-t-RGB2.obj 5,-1 !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 1,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 db 1 0 db 9 0 db 2 0 db a 0 db 3 0 db b 0 db 4 0 db c 0 db 5 0 db d 0 db 6 0 db e 0 db"

	set OUTP="!OUTP:~1,-1! & 3d !FN! %DRAWMODE%,-1 0,0,0 0,0,0 1,1,1,0,0,0 0,0,0,10 !XMID!,!YMID!,10000,%ASPECT% 0 0 db & fbox 7 0 20"
	
	for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! & 3d !FN! %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 20,20,20,0,0,0 0,0,0,10 !XMID!,!YMID!,!TRIDIST!,%ASPECT% 0 0 db"&set /A TRZ+=%S3%*4
	
	echo "cmdgfx: !OUTP:~1,-1! & !MONS! & !FADE! & skip text 7 0 0 [FRAMECOUNT] 103,108 & !MSG!" !XF!Ff0:0,0,!W!,!H! - - .-+jR
	set OUTP=

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 

	if "!RESIZED!"=="1" set /a "W=SCRW*2+2, H=SCRH*2+2, XMID=W/2, YMID=H/2, HLPY=H-4, DIST=4000-(W-222)*7, TRIDIST=7000-(W-222)*17, CUPOS=35+(W-222)/7+3" & set FN=%FN0%& (if !W! gtr 300 set FN=%FN1%)& (if !W! gtr 400 set FN=%FN2%) & cmdwiz showcursor 0 & set HELPMSG=text 7 0 0 SPACE\-ENTER\-x\-p\-h 1,!HLPY! & if !SHOWHELP!==1 set MSG=!HELPMSG!

	set /a CRZ+=3, CNT+=1

	if !CS! gtr 0 (
		set /a CP=!CCNT!/%CDIV%,CCP=!CCNT!/%CDIV%+2 & for %%a in (!CP!) do for %%b in (!CCP!) do set FADE=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=!C%%b!!C%%a!??
		if !CS!==2 set /a CCNT-=1&if !CCNT! lss 0 set /a CS=0&set FADE=
		if !CS!==1 set /a CCNT+=1&if !CCNT! gtr %CEND% set /a CCNT=%CEND%,CW+=1
		if !CW! gtr 35 set /a CW=0,CS=2,KEY=32
	)
	
	if !LIGHT! == 1 for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq %LTIME% set /a KEY=109 & set t1=!time: =0!
	if !KEY! == 115 set /A LIGHT=1-!LIGHT! & if !LIGHT! == 1 set /a KEY=109 & set t1=!time: =0!
	
	if !CNT! gtr 1307 set /a A3+=1
	if !CNT! gtr 1400 set /a CNT=0
	if !KEY! == 112 cmdwiz getch & set /a CKEY=!errorlevel! & if !CKEY! == 115 echo "cmdgfx: " c:0,0,%W%,%H%
	if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
	if !KEY! == 100 set /A DIST+=50
	if !KEY! == 68 set /A DIST-=50
	if !KEY! == 13 set /A TRANSP=1-!TRANSP!&(if !TRANSP!==1 set /a TV=20)&(if !TRANSP!==0 set /a TV=-1)
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 2 set MODE=0
	if !KEY! == 27 set STOP=1
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 120 set /a C16=1-C16 & set XF=-X& if !C16!==1 set XF=X0,3,2000
	
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
taskkill.exe /F /IM dlc.exe>nul
echo "cmdgfx: quit"
title input:Q
