@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
bg font 1 & cls & cmdwiz showcursor 0
set /a W=160, H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=1
set /a CRX=0,CRY=0,CRZ=0, OW=4, COLCNT=0
set ASPECT=0.75
set COLS_0=f 0 04   f 0 04   f 0 .  7	 0 .   7 0 .   8 0 .  8 0 .  8 0 .  8 0 .   8 0 .   8 0 fa  8 0 fa  8 0 fa
set COLS_1=f 0 04   f 0 04   b 0 .  9	 0 .   9 0 .   9 0 .  1 0 .  1 0 .  1 0 .   1 0 .   1 0 fa

set CNT=0&for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do set /A CNT+=1
set WNAME=pixels.ply
cmdwiz print "ply\nformat ascii 1.0\nelement vertex %CNT%\nelement face %CNT%\nend_header\n" > %WNAME%
for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do echo %%c %%b %%a >>%WNAME%
set /a CNT=-1&for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do set /a CNT+=1&echo 1 !CNT! >>%WNAME%

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do (
	start /B /High cmdgfx_gdi "fbox 7 0 20 0,0,%W%,%H% & 3d pixels.ply %DRAWMODE%,1 !CRX!,!CRY!,!CRZ! 0,0,0 120,120,120,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLS_%%c!" f1
	cmdgfx "" nkW12
	set KEY=!ERRORLEVEL!

	set /a CRZ+=5,CRX+=3,CRY-=4

	if !KEY! == 112 cmdwiz getch
	if !KEY! == 32 set /A COLCNT+=1&if !COLCNT! gtr 1 set COLCNT=0
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
bg font 6 & cmdwiz showcursor 1 & mode 80,50
del /Q pixels.ply
