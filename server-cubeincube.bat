@echo off
cmdwiz setfont 8 & cls & title Cube in cube
set /a F8W=160/2, F8H=80/2
mode %F8W%,%F8H%
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW10xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,400,80,160,80
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F8W=&set F8H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -20

set /a XXTRA=80
set /a WW=W*2+XXTRA, BOXW=W+XXTRA
set /a XMID=!W!/2, YMID=!H!/2, DIST=4000, DRAWMODE=1, NOFCUBES=5, COLCNT=0, COLNOF=3
set /a OFFXMID=W+XMID+XXTRA
for /L %%a in (1,1,%NOFCUBES%) do set /a CRX%%a=0,CRY%%a=0,CRZ%%a=0
set CNT=1 & for %%a in (3,3,3,3,3) do set /a CRXA!CNT!=%%a, CNT+=1
set CNT=1 & for %%a in (-4,-4,-4,-4,-4) do set /a CRYA!CNT!=%%a, CNT+=1
set CNT=1 & for %%a in (5,5,5,5,5) do set /a CRZA!CNT!=%%a, CNT+=1
set ASPECT=0.7
set COLS1=1 0 db 1 0 db  2 0 db 2 0 db  3 0 db 3 0 db
set COLS2=4 0 db 4 0 db  5 0 db 5 0 db  6 0 db 6 0 db
set COLS3=1 0 db 1 0 db  2 0 db 2 0 db  3 0 db 3 0 db
set COLS4=7 0 db 7 0 db  1 0 db 1 0 db  9 0 db 9 0 db
set COLS5=1 0 db 1 0 db  2 0 db 2 0 db  3 0 db 3 0 db
set COL0=00000f,080820,101030,181840,202050,282860,303070,383880,404090,405090,515995,282870,101030,181840,202050,282860,303070  000820
set COL1=00000f,080820,101030,181834,203050,283858,303070,503880,604090,705090,717995,686870,102040,183840,203050,282860,103070  000820
set COL2=- -
set /a XP=W+XXTRA, RW=WW, CNT=0
set /a BX2=XMID-105, BX3=XMID-60, BY3=YMID-43, BX4=XMID-40, BY4=YMID-30, BX5=XMID-30, BY5=YMID-10
set /a OPT=1

set /a SHOWHELP=1
set HELPMSG=text 8 0 0 SPACE\-d/D\-o\-h 1,78
if !SHOWHELP!==1 set MSG=%HELPMSG%

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do (

	rem General/non-optimized
	if !OPT!==0 echo "cmdgfx: fbox 0 0 db 0,0,%RW%,!H! & 3d objects\cube.ply 4,0 !CRX1!,!CRY1!,!CRZ1! 0,0,0 -790,-790,-790,0,0,0 1,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% %COLS5% & fbox 0 0 db !W!,0,!BOXW!,!H! & 3d objects\cube.ply 4,0 !CRX2!,!CRY2!,!CRZ2! 0,0,0 -480,-480,-480,0,0,0 1,0,0,10 !OFFXMID!,!YMID!,!DIST!,%ASPECT% %COLS4% & block 0 0,0,!RW!,!H! 0,0 -1 0 0 - xor(col(x,y),col(x+!XP!,y)) - - - 0,0,!W!,!H! & fbox 0 0 db !W!,0,!BOXW!,!H! & 3d objects\cube.ply 4,0 !CRX3!,!CRY3!,!CRZ3! 0,0,0 -270,-270,-270,0,0,0 1,0,0,10 !OFFXMID!,!YMID!,!DIST!,%ASPECT% %COLS3% & block 0 0,0,!RW!,!H! 0,0 -1 0 0 - xor(col(x,y),col(x+!XP!,y)) - - - 0,0,!W!,!H! & fbox 0 0 db !W!,0,!BOXW!,!H! & 3d objects\cube.ply 4,0 !CRX4!,!CRY4!,!CRZ4! 0,0,0 -160,-160,-160,0,0,0 1,0,0,10 !OFFXMID!,!YMID!,!DIST!,%ASPECT% %COLS2% & block 0 0,0,!RW!,!H! 0,0 -1 0 0 - xor(col(x,y),col(x+!XP!,y)) - - - 0,0,!W!,!H! & fbox 0 0 db !W!,0,!BOXW!,!H! & 3d objects\cube.ply 4,0 !CRX5!,!CRY5!,!CRZ5! 0,0,0 -60,-60,-60,0,0,0 1,0,0,10 !OFFXMID!,!YMID!,!DIST!,%ASPECT% %COLS1% & block 0 0,0,!RW!,!H! 0,0 -1 0 0 - xor(col(x,y),col(x+!XP!,y)) - - - 0,0,!W!,!H! & !MSG! & skip text 7 0 0 [FRAMECOUNT] 1,1" Ff1:0,0,!WW!,!H!,!W!,!H! !COL%%c!

	rem Optimized/non-scaleable (using BX/BY variables)
	if !OPT!==1 echo "cmdgfx: fbox 0 0 db 0,0,%RW%,!H! & 3d objects\cube.ply 4,0 !CRX1!,!CRY1!,!CRZ1! 0,0,0 -790,-790,-790,0,0,0 1,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% %COLS5% & fbox 0 0 db !W!,0,!BOXW!,!H! & 3d objects\cube.ply 4,0 !CRX2!,!CRY2!,!CRZ2! 0,0,0 -480,-480,-480,0,0,0 1,0,0,10 !OFFXMID!,!YMID!,!DIST!,%ASPECT% %COLS4% & block 0 0,0,!RW!,!H! 0,0 -1 0 0 - xor(col(x,y),col(x+!XP!,y)) - - - !BX2!,0,210,!H! & fbox 0 0 db !W!,0,!BOXW!,!H! & 3d objects\cube.ply 4,0 !CRX3!,!CRY3!,!CRZ3! 0,0,0 -270,-270,-270,0,0,0 1,0,0,10 !OFFXMID!,!YMID!,!DIST!,%ASPECT% %COLS3% & block 0 0,0,!RW!,!H! 0,0 -1 0 0 - xor(col(x,y),col(x+!XP!,y)) - - - !BX3!,!BY3!,120,86 & fbox 0 0 db !W!,0,!BOXW!,!H! & 3d objects\cube.ply 4,0 !CRX4!,!CRY4!,!CRZ4! 0,0,0 -160,-160,-160,0,0,0 1,0,0,10 !OFFXMID!,!YMID!,!DIST!,%ASPECT% %COLS2% & block 0 0,0,!RW!,!H! 0,0 -1 0 0 - xor(col(x,y),col(x+!XP!,y)) - - - !BX4!,!BY4!,80,60 & fbox 0 0 db !W!,0,!BOXW!,!H! & 3d objects\cube.ply 4,0 !CRX5!,!CRY5!,!CRZ5! 0,0,0 -60,-60,-60,0,0,0 1,0,0,10 !OFFXMID!,!YMID!,!DIST!,%ASPECT% %COLS1% & block 0 0,0,!RW!,!H! 0,0 -1 0 0 - xor(col(x,y),col(x+!XP!,y)) - - - !BX5!,!BY5!,60,20 & !MSG! & skip text 7 0 0 [FRAMECOUNT] 1,1" Ff1:0,0,!WW!,!H!,!W!,!H! !COL%%c!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
		
	if "!RESIZED!"=="1" set /a "W=SCRW*2+2, WW=W*2+XXTRA, H=SCRH*2+2, XMID=W/2, YMID=H/2, OFFXMID=W+XMID+XXTRA, BOXW=W+XXTRA, XP=W+XXTRA, RW=WW, HLPY=H-3, BX2=XMID-105, BX3=XMID-60, BY3=YMID-43, BX4=XMID-40, BY4=YMID-30, BX5=XMID-30, BY5=YMID-10" & cmdwiz showcursor 0 & set HELPMSG=text 8 0 0 SPACE\-d/D\-o\-h 1,!HLPY!& if !SHOWHELP!==1 set MSG=!HELPMSG!
		
	for /L %%a in (1,1,%NOFCUBES%) do set /a CRX%%a+=!CRXA%%a!,CRY%%a+=!CRYA%%a!,CRZ%%a+=!CRZA%%a!
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 111 set /A OPT=1-OPT
	if !KEY! == 27 set STOP=1
	if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
	if !KEY! == 32 set /a COLCNT+=1&if !COLCNT! geq !COLNOF! set /a COLCNT=0
	set /a CNT+=1 & if !CNT! gtr 300 set /a "CNT=0, RND=!RANDOM! %% %NOFCUBES%, V=(!RANDOM! %% 2)*2-1, XYZ=!RANDOM! %% 3" & for %%a in (!RND!) do (if !XYZ!==0 set /a CRXA%%a+=!V!) & (if !XYZ!==1 set /a CRYA%%a+=!V!) & (if !XYZ!==2 set /a CRZA%%a+=!V!) 
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
