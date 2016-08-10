@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 1&cls
set W=160&set H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=7000
set ASPECT=1.5
set DRAWMODE=1
set /A CRX=0,CRY=0,CRZ=0
set COLS_0=f 0 04   f 0 04   f 0 .  7	 0 .   7 0 .   8 0 .  8 0 .  8 0 .  8 0 .   8 0 .   8 0 fa  8 0 fa  8 0 fa
set FBG_0=8 0
set COLS_1=f 0 04   f 0 04   b 0 .  9	 0 .   9 0 .   9 0 .  1 0 .  1 0 .  1 0 .   1 0 .   1 0 fa
set FBG_1=9 0

set COLCNT=0

set OW=4
set CNT=0&for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do set /A CNT+=1
set WNAME=pixels.ply
echo ply>%WNAME%
echo format ascii 1.0 >>%WNAME%
echo element vertex %CNT% >>%WNAME%
echo element face %CNT% >>%WNAME%
echo end_header>>%WNAME%
for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do echo %%c %%b %%a >>%WNAME%
set CNT=-1&for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do set /A CNT+=1&echo 1 !CNT! >>%WNAME%
set RENDERER=_gdi&set REND=0

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP for %%c in (!COLCNT!) do (
cmdgfx!RENDERER! "fbox !FBG_%%c! 20 0,0,%W%,%H% & 3d pixels.ply %DRAWMODE%,1 !CRX!,!CRY!,!CRZ! 0,0,0 120,120,120,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLS_%%c!" kf1
set KEY=!ERRORLEVEL!

set /A CRZ+=5,CRX+=3,CRY-=4

if !KEY! == 112 cmdwiz getch
if !KEY! == 32 set /A COLCNT+=1&if !COLCNT! gtr 1 set COLCNT=0
if !KEY! == 100 set /A DIST+=100
if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
if !KEY! == 68 set /A DIST-=100
if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
bg font 6
mode 80,50
del /Q pixels.ply
