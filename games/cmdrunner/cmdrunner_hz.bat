:: CmdRunner : Mikael Sollenborn 2016
@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 0&cls
set W=180&set H=110
mode con lines=%H% cols=%W%
mode con rate=31 delay=0
cmdwiz showcursor 0
color 07
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
set RY=0

set /a XMID=%W%/2&set /a YMID=%H%/2-53
set DIST=2500
set ASPECT=1.13333
set DRAWMODE=0
set MAXCUBES=30
set GROUNDCOL=3
set ACCSPEED=350
set HISCORE=0&if exist hiscore.dat for /F "tokens=*" %%i in (hiscore.dat) do set HISCORE=%%i

set CUBECOL0=4 c db 4 c db  4 c b1  4 c b1  4 c 20 4 c 20
set CUBECOL1=6 0 db 6 0 db  6 e b1  6 e b1  6 e 20 6 e 20
set CUBECOL2=2 a db 2 a db  2 a b1  2 a b1  2 a 20 2 a 20
set CUBECOL3=5 d db 5 d db  5 d b1  5 d b1  5 d 20 5 d 20
set PLYCHAR=db

:OUTERLOOP
set NOFCUBES=15
set SCORE=0
set TILT=0
set ACTIVECUBES=0

set CURRZ=30000
set /A ACZ=%CURRZ%/%MAXCUBES%
for /L %%a in (1,1,%MAXCUBES%) do set /A CURRZ-=%ACZ% & set /A PZ%%a=!CURRZ!+ !RANDOM! %% %ACZ%& set /A PX%%a=!RANDOM! %% 8000 - 4000 & set /A PY%%a=-18000&set /A COLPAL=!RANDOM!%%4&for %%b in (!COLPAL!) do set CPAL%%a=!CUBECOL%%b!
set STARTINDEX=1

set BKSTR="fbox 0 1 b1 0,0,%W%,10 & fbox 0 1 20 0,10,%W%,5 & fbox 9 1 b1 0,15,%W%,5 & fbox 9 1 db 0,19,%W%,1  &  fbox 0 0 20 0,21,%W%,5 & fbox 0 %GROUNDCOL% b2 0,23,%W%,5 & fbox 0 %GROUNDCOL% b1 0,27,%W%,10 & fbox 0 %GROUNDCOL% b0 0,34,%W%,22 & fbox 8 %GROUNDCOL% 20 0,50,%W%,100 "

set STOP=
:IDLELOOP
for /L %%1 in (1,1,500) do if not defined STOP (
set CRSTR=""
set /A INDEX=!STARTINDEX!-1
for /L %%b in (1,1,%MAXCUBES%) do set /A INDEX+=1&(if !INDEX! gtr %MAXCUBES% set INDEX=1)&for %%a in (!INDEX!) do set CRSTR="!CRSTR:~1,-1! & 3d cube.ply %DRAWMODE%,-1 0,!RY!,0 !PX%%a!,-1800,!PZ%%a! -250,-250,-250,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !CPAL%%a!"&set /A PZ%%a-=%ACCSPEED% & if !PZ%%a! lss 1000 set PZ%%a=30000&set /A PX%%a=!RANDOM! %% 8000 - 4000&set /A STARTINDEX-=1&if !STARTINDEX! lss 1 set STARTINDEX=%MAXCUBES%
cmdgfx "%BKSTR:~1,-1% & image CR2.gxy 0 0 0 20 28,2 & !CRSTR:~1,-1! & text f 1 0 _Press_SPACE_to_play_ 80,15" k
set KEY=!ERRORLEVEL!
set /a RY+=8
if !KEY! == 27 set STOP=1
if !KEY! == 32 set STOP=2
)
if not defined STOP goto IDLELOOP
if %KEY% == 27 goto ESCAPE

set STOP=
:INGAMELOOP
for /L %%1 in (1,1,500) do if not defined STOP (
set CRSTR=""
set /A INDEX=!STARTINDEX!-1, TILTHORIZ=!TILT!/4, THG=!TILT!/4/3, THG2=!TILT!/4/3, THG3=!TILT!/4/3, THG1=!TILT!/4/6, THG0=!TILT!/4/8, THG00=!TILT!/4/12, THG000=!TILT!/4/13, THG0000=0
for /L %%b in (1,1,%MAXCUBES%) do set /A INDEX+=1&(if !INDEX! gtr %MAXCUBES% set INDEX=1)& for %%a in (!INDEX!) do set CRSTR="!CRSTR:~1,-1! & 3d cube.ply %DRAWMODE%,-1 0:0,!RY!:0,0:!TILTHORIZ! !PX%%a!,!PY%%a!,!PZ%%a! -250,-250,-250,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !CPAL%%a!"&set /A PZ%%a-=%ACCSPEED% & if !PZ%%a! lss 1000 set PZ%%a=30000&set /A PX%%a=!RANDOM! %% 8000 - 4000 - !TILT!*50 &(if !ACTIVECUBES! leq !NOFCUBES! if !PY%%a! lss -1800 if !RANDOM! lss 10922 set /A PY%%a=-1800&set /A ACTIVECUBES+=1)&set /A STARTINDEX-=1&if !STARTINDEX! lss 1 set STARTINDEX=%MAXCUBES%

set /a YB1=10+!THG0000!,YB2=10-!THG0000!,YB3=15-!THG000!,YB4=15+!THG000!, YC1=15+!THG000!,YC2=15-!THG000!,YC3=21-!THG00!,YC4=21+!THG00!, YD1=19+!THG1!,YD2=19-!THG1!,YD3=21-!THG1!,YD4=21+!THG1!, YE1=21+!THG1!,YE2=21-!THG1!,YE3=24-!THG1!,YE4=24+!THG1!, YF1=23+!THG1!,YF2=23-!THG1!,YF3=28-!THG!,YF4=28+!THG!, YG1=28+!THG2!,YG2=28-!THG2!,YG3=37-!THG2!,YG4=37+!THG2!, YH1=34+!THG3!,YH2=34-!THG3!,YH3=56-!THG3!,YH4=56+!THG3!
set BKSTR2="fbox 0 1 b1 0,0,%W%,10 & poly 0 1 20 0,!YB1!,%W%,!YB2!,%W%,!YB3!,0,!YB4! & poly 9 1 b1 0,!YC1!,%W%,!YC2!,%W%,!YC3!,0,!YC4! & poly 9 1 db 0,!YD1!,%W%,!YD2!,%W%,!YD3!,0,!YD4!   & fbox 8 %GROUNDCOL% 20 0,50,%W%,100 & poly 0 0 20 0,!YE1!,%W%,!YE2!,%W%,!YE3!,0,!YE4! & poly 0 %GROUNDCOL% b2 0,!YF1!,%W%,!YF2!,%W%,!YF3!,0,!YF4! & poly 0 %GROUNDCOL% b1 0,!YG1!,%W%,!YG2!,%W%,!YG3!,0,!YG4! & poly 0 %GROUNDCOL% b0 0,!YH1!,%W%,!YH2!,%W%,!YH3!,0,!YH4!"

cmdgfx "!BKSTR2:~1,-1! !CRSTR:~1,-1! & 3d tetramod.ply %DRAWMODE%,-1 0,180,!TILT! 0,-1800,4000 -50,-50,-50,0,0,0 1,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% f %GROUNDCOL% %PLYCHAR% 7 %GROUNDCOL% %PLYCHAR% & 3d tetramod.ply %DRAWMODE%,-1 0,180,!TILT! 0,-1900,4000 -50,-50,-50,0,0,0 1,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 %GROUNDCOL% b2 0 %GROUNDCOL% b2 & text 7 1 0 SCORE:_!SCORE!_(!HISCORE!) 2,1" k
set KEY=!ERRORLEVEL!

for /L %%a in (1,1,%MAXCUBES%) do if !PY%%a! gtr -15000 if !PZ%%a! lss 4000 if !PZ%%a! gtr 3500 if !PX%%a! gtr -300 if !PX%%a! lss 300 (for /L %%a in (1,1,40) do set /A TILT+=40 & cmdgfx "!BKSTR2:~1,-1! !CRSTR:~1,-1! & 3d tetramod.ply %DRAWMODE%,-1 0,180,!TILT! 0,-1800,4000 -50,-50,-50,0,0,0 1,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% f %GROUNDCOL% %PLYCHAR% 7 %GROUNDCOL% %PLYCHAR% & text 7 1 0 SCORE:_!SCORE!_(!HISCORE!) 2,1")&set STOP=1

set /A NOFCUBES=15+!SCORE!/250 & if !NOFCUBES! gtr %MAXCUBES% set NOFCUBES=%MAXCUBES%
if not !TILT!==0 (if !TILT! gtr 0 set /A TILT-=1) & (if !TILT! lss 0 set /A TILT+=1)

if !KEY!==331 set /A TILT+=7&if !TILT! gtr 55 set TILT=55
if !KEY!==333 set /A TILT-=7&if !TILT! lss -55 set TILT=-55
if !TILT! neq 0 for /L %%a in (1,1,%MAXCUBES%) do set /A PX%%a+=!TILT!
set /a RY+=8
set /a SCORE+=1&if !SCORE! gtr !HISCORE! set HISCORE=!SCORE!
if !KEY! == 27 set STOP=1
)
if not defined STOP goto INGAMELOOP
goto OUTERLOOP

:ESCAPE
echo %HISCORE%>hiscore.dat
endlocal
mode con cols=80 lines=50
cmdwiz showcursor 1
cls
cmdwiz setfont 6
