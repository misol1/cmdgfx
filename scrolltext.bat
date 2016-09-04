:: Texturemap scroll : Mikael Sollenborn 2016
@echo off
setlocal ENABLEDELAYEDEXPANSION

cls & cmdwiz setfont 1
set W=200&set H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=5000
set ASPECT=1.5
set c=0
set /A RX=0,RY=0,RZ=0
set FN=genplane.obj

set /A XW=40,YW=10
set /A XROT=0,YROT=0,ZROT=0
set HELPT=text a 0 0 'p'_to_pause,_'z'_for_z_rotation,_'y'_for_y_rotation,_'x'_for_x_rotation,_'space'_to_reset_all_rotation,_'left/right'_for_direction,_'d/D'_to_zoom,_'t'_to_switch_char,_'h'_to_hide_text 6,78
set HELP=
set HLP=0
set DIR=1

set TRANSPCOL=0
if %TRANSPCOL% geq 0 set BKG=fbox 1 0 fa 0,0,%W%,%H%&cmdgfx "!BKG!"

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

set CHAR=db
set CHARI=0

set CNT=0
set XP=30

copy /Y %FN% 2%FN%>nul
set RENDERER=&set REND=1

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (
if "%~1"=="" cmdgfx!RENDERER! "%BKG% & 3d 2%FN% %DRAWMODE%,%TRANSPCOL% !RY!,0,!RX! 0,0,0 110,110,110,!XP!,0,0 0,-2000,4000,0 %XMID%,%YMID%,7000,%ASPECT% 0 0 . & 3d %FN% %DRAWMODE%,%TRANSPCOL% !RX!,!RY!,!RZ! 0,0,0 16,16,16,!XP!,0,0 0,-2000,4000,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 !CHAR! & !HELP!" kf1
if not "%~1"=="" cmdgfx!RENDERER! "%BKG% & 3d %FN% %DRAWMODE%,%TRANSPCOL%  !RX!,!RY!,!RZ! 0,0,0 16,16,16,!XP!,0,0 0,-2000,4000,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 !CHAR! & !HELP!" kf1
set KEY=!ERRORLEVEL!

if !YROT! == 1 set /A RX+=14
if !XROT! == 1 set /A RY+=6
if !ZROT! == 1 set /A RZ+=4

set /A XP-=!DIR!
if !XP! lss -1000 set XP=30
if !XP! gtr 100 set XP=-1000

set /A CNT+=1
if !CNT!==40 set ZROT=1
if !CNT! gtr 80 if !CNT! lss 200 set /A DIST-=20
if !CNT!==195 set YROT=1
if !CNT! gtr 380 if !CNT! lss 500 set /A DIST+=20
if !CNT!==605 set YROT=0&set RX=0
if !CNT!==640 set XROT=1
if !CNT!==1200 if "!HELP!"=="" set KEY=104

if !KEY! == 116 set CCNT=0&for %%a in (04 fe . b0 db) do (if !CCNT!==!CHARI! set CHAR=%%a)&set /A CCNT+=1
if !KEY! == 116 set /A CHARI+=1&if !CHARI! geq 5 set CHARI=0
if !KEY! == 100 set /A DIST+=30
if !KEY! == 68 set /A DIST-=30
if !KEY! == 333 set DIR=-1
if !KEY! == 331 set DIR=1
if !KEY! == 32 set /A RX=0,RY=0,RZ=0,XROT=0,YROT=0,ZROT=0,DIST=5000,CNT=10000
if !KEY! == 104 set /A HLP=1-!HLP! & (if !HLP!==1 set HELP=!HELPT!)&(if !HLP!==0 set HELP=)
if !KEY! == 112 cmdwiz getch
if !KEY! == 120 set /A XROT=1-!XROT!
if !KEY! == 121 set /A YROT=1-!YROT!
if !KEY! == 122 set /A ZROT=1-!ZROT!
if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

::cmdgfx "3d %FN% 3,-1 %RX%,%RY%,%RZ% 0,0,0 16,%XP%,0,0 0,0,0,0 %XMID%,%YMID%,%DIST%,%ASPECT% 1 0 db" kp

endlocal
mode 80,50 & cls & cmdwiz setfont 6
del /Q genplane.obj>nul 2>nul
del /Q 2genplane.obj>nul 2>nul
