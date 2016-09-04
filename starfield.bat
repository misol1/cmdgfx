:: Stars & Cube : Mikael Sollenborn 2016
@echo off
setlocal ENABLEDELAYEDEXPANSION
cls & cmdwiz setfont 1
set W=200&set H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set NOF_STARS=400&if not "%~1"=="" set /A NOF_STARS=%~1

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=11000
set SDIST=5500
set ASPECT=1.13333
set DRAWMODE=1
set DIR=0
if !DIR!==0 set /A TX=0,TX2=-2600,RX=0,RY=0,RZ=0,CRX=0,CRY=0,CRZ=0,TZ=0,TZ2=0
if !DIR!==1 set /A TX=0,TX2=0,RX=0,RY=0,RZ=0,CRX=0,CRY=0,CRZ=0,TZ=0,TZ2=-4000
set COLS=f 0 04   f 0 .  f 0 . f 0 .  f 0 . f 0 .  7 0 . 7 0 .  7 0 .  7 0 .  7 0 .  7 0 . 7 0 . 7 0 .  7 0 .  7 0 .  8 0 .  8 0 .  8 0 . 8 0 .  8 0 .  8 0 . 8 0 . 8 0 . 8 0 .  8 0 fa  8 0 fa  8 0 fa

set COLS2_0= f 0 05  f 0 #  f 0 #   f 0 13  7 0 #  7 0 13  7 0 13  7 0 :  7 0 :   8 0 #  8 0 :  8 0 .  8 0 fa
set COLS2_1= 9 0 05  9 0 #  9 0 #   9 0 13  1 0 #   1 0 #  1 0 13  1 0 :  1 0 :   1 0 :  1 0 :  1 0 .  1 0 fa
set COLS2_2= c 0 05  c 0 #  c 0 #   c 0 13  4 0 #   4 0 #  4 0 13  4 0 :  4 0 :   4 0 :  4 0 :  4 0 .  4 0 fa
set COLS2_3= a 0 05  a 0 #  a 0 #   a 0 13  2 0 #   2 0 #  2 0 13  2 0 :  2 0 :   2 0 :  2 0 :  2 0 .  2 0 fa
set COLS2_4= b 0 05  b 0 #  b 0 #   b 0 13  3 0 #   3 0 #  3 0 13  3 0 :  3 0 :   3 0 :  3 0 :  3 0 .  3 0 fa
set COLS2_5= d 0 05  d 0 #  d 0 #   5 0 13  5 0 #   5 0 #  5 0 13  5 0 :  5 0 :   5 0 :  5 0 :  5 0 .  5 0 fa
set COLS2_6= e 0 05  e 0 #  e 0 #   6 0 13  6 0 #   6 0 #  6 0 13  6 0 :  6 0 :   6 0 :  6 0 :  6 0 .  6 0 fa
set COLCNT=1

set HELP=text 3 0 0 SPACE\-to\-change\-color,\-ENTER\-to\-change\-stars,\-z\-to\-rotate_stars,\-d/D\-to\-zoom 58,78
set ROTSTARS=0

set FCNT=0
:SETUPLOOP
set WNAME=starfield%FCNT%.ply
echo ply>%WNAME%
echo format ascii 1.0 >>%WNAME%
set /A NOF_V=%NOF_STARS% * 1
echo element vertex %NOF_V% >>%WNAME%
echo element face %NOF_STARS% >>%WNAME%
echo end_header>>%WNAME%

for /L %%a in (1,1,%NOF_STARS%) do set /A vx=!RANDOM! %% 240 -120 & set /A vy=!RANDOM! %% 200 -100 & set /A vz=!RANDOM! %% 400-160 & echo !vx! !vy! !vz!>>%WNAME%
set CNT=0&for /L %%a in (1,1,%NOF_STARS%) do set /A CNT1=!CNT!&set /A CNT+=1& echo 1 !CNT1! >>%WNAME%
set /A FCNT+=1
if %FCNT% lss 2 goto SETUPLOOP
set RENDERER=&set REND=1

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP for %%c in (!COLCNT!) do (
cmdgfx!RENDERER! "3d starfield0.ply %DRAWMODE%,1 !RX!,!RY!,!RZ! !TX!,0,!TZ! 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,%ASPECT% !COLS! & 3d starfield1.ply %DRAWMODE%,1 !RX!,!RY!,!RZ! !TX2!,0,!TZ2! 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,%ASPECT% !COLS! & 3d objects\cube.ply 1,0 !CRX!,!CRY!,!CRZ! 0,0,0 -500,-250,-500,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,1.9 !COLS2_%%c! & %HELP%" kf1
set KEY=!ERRORLEVEL!

if !DIR!==0 set /A TX+=10&if !TX! gtr 2600 set TX=-2600
if !DIR!==0 set /A TX2+=10&if !TX2! gtr 2600 set TX2=-2600
if !DIR!==1 set /A TZ-=100&if !TZ! lss -4000 set TZ=4000
if !DIR!==1 set /A TZ2-=100&if !TZ2! lss -4000 set TZ2=4000

set /A CRZ+=7,CRX+=4,CRY-=5

if !ROTSTARS!==1 (if !DIR!==1 set /A RZ+=3)&(if !DIR!==0 set /A RY+=5)

if !KEY! == 112 cmdwiz getch
if !KEY! == 32 set /A COLCNT+=1&if !COLCNT! gtr 6 set COLCNT=0
if !KEY! == 100 set /A DIST+=100
if !KEY! == 68 set /A DIST-=100
if !KEY! == 13 set /A DIR=1-!DIR!&(if !DIR!==0 set /A TX=0,TX2=-2600,RX=0,RY=0,RZ=0,TZ=0,TZ2=0)&(if !DIR!==1 set /A TX=0,TX2=0,RX=0,RY=0,RZ=0,TZ=0,TZ2=-4000)
if !KEY! == 122 set /A ROTSTARS=1-!ROTSTARS!
if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
mode 80,50 & cls & cmdwiz setfont 6
del /Q starfield?.ply >nul
