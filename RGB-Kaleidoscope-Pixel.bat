@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title Kaleidoscope (SPACE d/D)
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13xR | call %0 %* | cmdgfx_RGB "" Sfa:0,0,220,110
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

set /a XMID=%W%/2, YMID=%H%/2, DIST=1500, TRIDIST=1700, DRAWMODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=1

set /a S1=66, S2=12, S3=30, TRINUM=0
if "%~1" == "1" set /a S1=33, S2=24, S3=15, TRINUM=1
if "%~1" == "2" set /a S1=100, S2=8, S3=45, TRINUM=2
if "%~1" == "3" set /a S1=25, S2=30, S3=12, TRINUM=3

set FN3=objects\tri-FS3-%TRINUM%.obj
set FN=%FN3%

if exist %FN3% goto SKIPGEN

set FN=%FN3%
echo usemtl cmdcolblock 0 0 320 320 >%FN%
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

set /a MODE=1, TV=0, TRANSP=1, CUPOS=35, BCLR=20

set CONV16=color16 0 f 3000 \g20.-+jR
set /a C16=0 & set XF=skip& if !C16!==1 set XF=

set STOP=
:LOOP
for /L %%_ in (1,1,300) do if not defined STOP (

	set SCLR=skip & set /a BCLR-=1 & if !BCLR! gtr 0 set SCLR=
	set /a A1+=1, A2+=2, A3-=1, TRZ=!CRZ!
	if !MODE!==0 set OUTP="!SCLR! fbox 0 0 db & fbox 0 0 db 0,0,320,320 & 3d objects\cube-t-RGB.obj 0,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 ?"
	if !MODE!==1 set OUTP="!SCLR! fbox 0 0 db & fbox 0 0 db 0,0,320,320 & 3d objects\cube-t-RGB2.obj 0,-1 !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 1,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 ?"
	if !MODE!==2 set OUTP="!SCLR! fbox 0 0 db & fbox 0 0 db 0,0,320,320 & 3d objects\cube-t-RGB2.obj 0,-1 !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 1,0,0,10 !CUPOS!,!CUPOS!,!DIST!,%ASPECT% 0 0 ? 1 0 ? 9 0 ? 2 0 ? a 0 ? 3 0 ? b 0 ? 4 0 ? c 0 ? 5 0 ? d 0 ? 6 0 ? e 0 ?"

	rem set OUTP="!OUTP:~1,-1! & 3d !FN! %DRAWMODE%,-1 0,0,0 0,0,0 1,1,1,0,0,0 0,0,0,10 !XMID!,!YMID!,10000,%ASPECT% ? ? ? & fbox 7 0 ?"
	
	for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! & 3d !FN! %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 20,20,20,0,0,0 0,0,0,10 !XMID!,!YMID!,!TRIDIST!,%ASPECT% 0 0 ?"&set /A TRZ+=%S3%*4
	
	echo "cmdgfx: !OUTP:~1,-1! & !XF! %CONV16% & text f 0 0 [FRAMECOUNT] 10,10 4" Ffa:0,0,!W!,!H!
	set OUTP=

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 

	if "!RESIZED!"=="1" set /a "W=SCRW*8+7, H=SCRH*12+11, XMID=W/2, YMID=H/2, DIST=1400-(W-882)/2, TRIDIST=1700-(W-882)/1, HLPY=H-4, CUPOS=35+(W-222)/7+3, BCLR=20" & cmdwiz showcursor 0

	set /a CRZ+=3, CNT+=1
	
	if !CNT! gtr 1307 set /a A3+=1
	if !CNT! gtr 1400 set /a CNT=0
	if !KEY! == 112 cmdwiz getch & set /a CKEY=!errorlevel! & if !CKEY! == 115 echo "cmdgfx: " c:0,0,%W%,%H%
	if !KEY! == 100 set /A DIST+=50
	if !KEY! == 68 set /A DIST-=50
	if !KEY! == 13 set /A TRANSP=1-!TRANSP!&(if !TRANSP!==1 set /a TV=20)&(if !TRANSP!==0 set /a TV=-1)
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 2 set MODE=0
	if !KEY! == 27 set STOP=1
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 120 set /a C16=1-C16 & set XF=skip& if !C16!==1 set XF=
	
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
taskkill.exe /F /IM dlc.exe>nul
echo "cmdgfx: quit"
title input:Q
