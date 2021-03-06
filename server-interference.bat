@echo off
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Interference
if defined __ goto :START
set __=.
cmdgfx_input.exe knW16xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,180,80
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
set /a F8W=W/2, F8H=H/2
mode %F8W%,%F8H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -16
call prepareScale.bat 1

set /a XMID=%W%/2, YMID=%H%/2
set /a DIST=2500, DRAWMODE=0, BITOP=3, BKG=0
set ASPECT=0.75

call sindef.bat

set /a CIRCS=16, OW=15
set /A CNT=180 / %OW%
set /A CNTV=((%CNT%)*2+2) * 2 * %CIRCS%
set /A FACES=2*%CIRCS%
set WNAME=objects\inter.ply

if exist %WNAME% goto SKIPGEN

cmdwiz print "ply\nelement vertex %CNTV%\nelement face %FACES%\nend_header\n">%WNAME%

for /l %%b in (1,1,%CIRCS%) do (
	set /A MUL=70*%%b-39
	set /A MUL2=!MUL!+31
	set OUTP=
	for /L %%a in (0,%OW%,180) do set /A SV=%%a, CV=%%a+90 & set /a "XPOS=(%SINE(x):x=!SV!*31416/180%*!MUL!>>%SHR%), YPOS=(%SINE(x):x=!CV!*31416/180%*!MUL!>>%SHR%), XPOS2=(%SINE(x):x=!SV!*31416/180%*!MUL2!>>%SHR%), YPOS2=(%SINE(x):x=!CV!*31416/180%*!MUL2!>>%SHR%)" & set OUTP=!OUTP!!XPOS! !YPOS! 0\n!XPOS2! !YPOS2! 0\n
	for /L %%a in (180,%OW%,360) do set /A SV=%%a, CV=%%a+90 & set /a "XPOS=(%SINE(x):x=!SV!*31416/180%*!MUL!>>%SHR%)-5, YPOS=(%SINE(x):x=!CV!*31416/180%*!MUL!>>%SHR%), XPOS2=(%SINE(x):x=!SV!*31416/180%*!MUL2!>>%SHR%)-5, YPOS2=(%SINE(x):x=!CV!*31416/180%*!MUL2!>>%SHR%)" & set OUTP=!OUTP!!XPOS! !YPOS! 0\n!XPOS2! !YPOS2! 0\n
	cmdwiz print "!OUTP!">>%WNAME%
 	set /A PRC=%%b*100/%CIRCS% & echo "cmdgfx: text 9 0 0 Generating_image(!PRC!%%)... 70,35"
)

:SKIPGEN
set OUTP=
set /a FACES-=1
for /l %%b in (0,1,%FACES%) do (
	set STR=&for %%a in (0 1 3 5 7 9 11 13 15 17 19 21 23 25 24 22 20 18 16 14 12 10 8 6 4 2) do set /A "C=(%%b*26)+%%a" & set STR=!STR! !C!
	set OUTP=!OUTP!26 !STR!\n
)
cmdwiz print "!OUTP!">>%WNAME%

set /A X1=0,Y1=0,XA1=3,YA1=6,COL1=1,XM1=188,YM1=96
set /A X2=200,Y2=500,XA2=-4,YA2=5,COL2=1,XM2=104,YM2=144
set OP=XOR&set OUTP=
set /a HLPY=H-3

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set CRSTR=""&for /L %%a in (1,1,2) do set /a SV=!X%%a!, CV=!Y%%a! & set /A "XP=(%SINE(x):x=!SV!*31416/180%*!XM%%a!>>%SHR%),YP=(%SINE(x):x=!CV!*31416/180%*!YM%%a!>>%SHR%),X%%a+=!XA%%a!,Y%%a+=!YA%%a!" & set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,!BITOP!  0,0,0 0,0,0 1,1,1,!XP!,!YP!,0 0,0,0,10 !XMID!,!YMID!,%DIST%,%ASPECT% 0 !COL%%a! 20"
	
	echo "cmdgfx: fbox !BKG! 0 20 & !CRSTR:~1,-1! & text 9 ? 0 !OP!(space)\-Col1:!COL1!(Left/Right)\-Col2:!COL2!(Up/Down) 1,!HLPY!" Ff1:0,0,!W!,!H!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
	
	if "!RESIZED!"=="1" set /a "W=SCRW*2*rW/100, H=SCRH*2*rH/100, XMID=W/2, YMID=H/2, HLPY=H-3" & cmdwiz showcursor 0
		
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 32 set /A BITOP+=1&(if !BITOP! gtr 6 set BITOP=0)&set CNT=0&for %%a in (NORMAL OR AND XOR ADD SUB SUB-n) do (if !CNT!==!BITOP! set OP=%%a)&set /A CNT+=1
	if !KEY! == 13 set /A BKG+=1&if !BKG! gtr 15 set BKG=0
	if !KEY! == 331 set /A COL1-=1&if !COL1! lss 1 set COL1=15
	if !KEY! == 333 set /A COL1+=1&if !COL1! gtr 15 set COL1=1
	if !KEY! == 336 set /A COL2-=1&if !COL2! lss 1 set COL2=15
	if !KEY! == 328 set /A COL2+=1&if !COL2! gtr 15 set COL2=1
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
