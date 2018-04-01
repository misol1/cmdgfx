:: Texturemap ignore-color scroll : Mikael Sollenborn 2016
@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION

cls & cmdwiz setfont 1
set W=200&set H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=700
set ASPECT=0.6
set c=0
set /A RX=0,RY=0,RZ=0
set FN=genplane.obj

set /A XW=40,YW=10
set /A YROT=0
set HELPT=text 1 0 0 'p'_to_pause,_'y'_for_y_rotation,_'space'_to_reset_rotation,_'left/right'_for_direction,_'d/D'_to_zoom,_'t'_to_switch_char,_'l'_for_lens,_'m'_for_mario,_'h'_to_hide_text 13,78
set HELP=&set HLP=0
set DIR=1&set LENS=1&set MARIO=0

set BKG="fbox 1 0 20 0,0,%W%,%H% & fellipse 1 0 20 %XMID%,%YMID%,108,37 & fellipse 9 0 20 %XMID%,%YMID%,100,35 & fellipse b 0 20 %XMID%,%YMID%,94,33 & fellipse f 0 20 %XMID%,%YMID%,90,31"
cmdgfx !BKG!

set NOFSECT=100
set /A STEPT=10000/%NOFSECT%
echo usemtl img\scroll_text2.pcx >%FN%
set /A SL=0,SR=%STEPT%
set FCNT=1
set XPP=12
set XW=0&set XW2=%XPP%
set /A NOFPREP=%NOFSECT%-10
set DRAWMODE=0
set CNT=0

:PREPLOOP
if %SR% geq 10000 set SL=0&set SR=1500
set SLP=0.%SL%&if %SL% lss 1000 set SLP=0.0%SL%&if %SL% lss 100 set SLP=0.00%SL%
set SRP=0.%SR%&if %SR% lss 1000 set SRP=0.0%SR%&if %SR% lss 100 set SRP=0.00%SR%

echo v  %XW% -%YW% 0 >>%FN%
echo v  %XW2% -%YW% 0 >>%FN%
echo v  %XW2%  %YW% 0 >>%FN%
echo v  %XW%  %YW% 0 >>%FN%
echo vt %SLP% 0.0 >>%FN%
echo vt %SRP% 0.0 >>%FN%
echo vt %SRP% 1.0 >>%FN%
echo vt %SLP% 1.0 >>%FN%

set /A FCNT2=%FCNT%+1
set /A FCNT3=%FCNT%+2
set /A FCNT4=%FCNT%+3
echo f %FCNT%/%FCNT%/ %FCNT2%/%FCNT2%/ %FCNT3%/%FCNT3%/ %FCNT4%/%FCNT4%/>>%FN%

set /A SL+=%STEPT%,SR+=%STEPT%
set /A FCNT+=4
set /A XW+=%XPP%
set /A XW2+=%XPP%

set /A CNT+=1
if %CNT% lss %NOFPREP% goto PREPLOOP

set CHAR=.
set CHARI=0
set XP=30

set /A SX=0,SXA=3,XMUL=40
set /A SX2=0,SXA2=2,XMUL2=10
set /A SY=0,SYA=2,YMUL=10
set /A XMP=%XMID%, YMP=300

call sindef.bat

set CNT=0

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (

set BKG2=""
if !LENS!==1 set BKG2=" & fellipse 7 0 fa !XMP!,!YMP!,30,25 & fellipse 4 0 20 !XMP!,!YMP!,27,24 & fellipse c 0 20 !XMP!,!YMP!,23,24 & fellipse e 0 20 !XMP!,!YMP!,18,24 & fellipse f 0 20 !XMP!,!YMP!,6,5 "
if !MARIO!==1 set /A "MN=(!CNT! %% 10)/5 + 1"&set BKG2="!BKG2:~1,-1! & image img\mario!MN!.gxy 0 0 0 0 9,28"

start "" /B /High cmdgfx_gdi "%BKG:~1,-1% !BKG2:~1,-1! & 3d %FN% %DRAWMODE%,0  !RX!,0,0 !XP!,0,0 8,8,8,0,0,0 0,-2000,4000,0 %XMID%,%YMID%,!DIST!,%ASPECT% ? 0 !CHAR! & !HELP!" f1
cmdgfx "" nkW12
set KEY=!ERRORLEVEL!
set BKG2=

set /A CNT+=1
if !CNT! lss 350 set /A YMP-=1 & if !YMP! lss %YMID% set YMP=%YMID%
if !CNT! == 140 set YROT=1
if !CNT! gtr 350 (
	set /a "XMP=%XMID%+(%SINE(x):x=!SX!*31416/180%*!XMUL!>>!SHR!)-(%SINE(x):x=!SX2!*31416/180%*!XMUL2!>>!SHR!)"
	set /a "YMP=%YMID%+(%SINE(x):x=!SY!*31416/180%*!YMUL!>>!SHR!)"
	
	set /A SX+=!SXA!&if !SX! gtr 359 set SX=0
	set /A SX2+=!SXA2!&if !SX2! gtr 359 set SX2=0
	set /A SY+=!SYA!&if !SY! gtr 359 set SY=0
)
if !CNT! == 1000 if !HLP!==0 set KEY=104

if !YROT! == 1 set /A RX+=10

set /A XP-=!DIR!*3
if !XP! lss -7500 set XP=30
if !XP! gtr 100 set XP=-7500

if !KEY! == 116 set CCNT=0&for %%a in (b0 .) do (if !CCNT!==!CHARI! set CHAR=%%a)&set /A CCNT+=1
if !KEY! == 116 set /A CHARI+=1&if !CHARI! geq 2 set CHARI=0
if !KEY! == 100 set /A DIST+=30
if !KEY! == 68 set /A DIST-=30
if !KEY! == 333 set DIR=-1
if !KEY! == 331 set DIR=1
if !KEY! == 32 set /A RX=0,RY=0,RZ=0,XROT=0,YROT=0,ZROT=0,DIST=700,CNT=10000
if !KEY! == 104 set /A HLP=1-!HLP! & (if !HLP!==1 set HELP=!HELPT!)&(if !HLP!==0 set HELP=)
if !KEY! == 112 cmdwiz getch
if !KEY! == 108 set /A LENS=1-!LENS!
if !KEY! == 109 set /A MARIO=1-!MARIO!
if !KEY! == 121 set /A YROT=1-!YROT!
if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
mode 80,50 & cls & cmdwiz setfont 6
del /Q genplane.obj>nul 2>nul
