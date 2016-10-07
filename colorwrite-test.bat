:: Colorwrite test : Mikael Sollenborn 2016
@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 6 & cls
set W=80&set H=54
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=1000
set ASPECT=1	
set DRAWMODE=0
set /A CRX=0,CRY=0,CRZ=0
set COLS=a 2 ?  a 2 ?  9 0 ?  9 0 ?  c 4 ?  c 4 ?

set CNT=50
call :MKTEXTURECUBE HB-small

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (

set CRSTR="image img\emma.txt 7 0 0 -1 0,0 "
if !CNT! gtr 200 if !CNT! lss 1200 set /A CRZ+=5,CRX+=3,CRY-=4 & set /A DIST+=4
if !CNT! gtr 1050 if !CNT! lss 1200 set /A XMID-=1
if 0==1 if !CNT! gtr 1100 if !CNT! lss 1200 set CRSTR="!CRSTR:~1,-1! & fbox e 4 ? 20,20,10,10 & box 9 1 ? 18,18,14,14 & fellipse a 1 ? 50,30,10,7 & ellipse c 4 ? 50,30,12,9 & line b 3 ? 10,50,70,50 & pixel d 0 ? 40,47 & gpoly f0??#90??#60a9#01?? 10,5,0,70,8,2,40,16,4 & tpoly img\mario1.gxy 9 0 ? -1 0,0,0,0,70,2,1,0,74,20,1,1 & image img\mario1.gxy 0 0 ? -1 15,33"
if !CNT! lss 1200 set CRSTR="!CRSTR:~1,-1! & 3d objects\cube.ply %DRAWMODE%,-1 !CRX!,!CRY!,!CRZ! 0,0,0 -150,-150,-150,0,0,0 1,0,0,10 !XMID!,%YMID%,!DIST!,%ASPECT% %COLS% "
if !CNT! == 1200 set DIST=900&set /A XMID=%W%/2
if !CNT! gtr 1200 set CRSTR="!CRSTR:~1,-1! & 3d cube-t.obj %DRAWMODE%,-1 !CRX!,!CRY!,!CRZ! 0,0,0 350,350,350,0,0,0 1,0,0,10 !XMID!,%YMID%,!DIST!,%ASPECT% 0 0 ?"
if !CNT! gtr 1200 set /A CRZ-=8,CRX+=5,CRY+=2

if !CNT! gtr 1200 cmdgfx_gdi.exe !CRSTR! kf6
if !CNT! leq 1200 cmdgfx.exe !CRSTR! k
set KEY=!ERRORLEVEL!
if !KEY! == 112 cmdwiz getch
if !KEY! == 100 set /A DIST+=100
if !KEY! == 68 set /A DIST-=100
if !KEY! == 27 set STOP=1
set /A CNT+=1
)
if not defined STOP goto LOOP

endlocal
rem del /Q cube-t.obj > nul 2>nul
mode 80,50 & cls
goto :eof

:MKTEXTURECUBE
del /Q cube-t.obj > nul 2>nul
for /F "tokens=*" %%a in (objects\cube-t.obj) do set LINE=%%a&set LINE=!LINE:dos_shade=%1!&echo !LINE!>> cube-t.obj
