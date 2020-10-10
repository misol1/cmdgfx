:: 3dworld : Mikael Sollenborn 2016
@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 0 & cls
set /a W=180, H=110
mode %W%,%H%
mode con rate=31 delay=0
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set RX=0&set RY=0&set RZ=0
set TX=0&set TY=0&set TZ=0

set /a XMID=%W%/2&set /a YMID=%H%/2-4
set DIST=0
set ASPECT=1.13333
set DRAWMODE=0
set GROUNDCOL=3
set MULVAL=250
set YMULVAL=125

set CUBECOLS=4 c db 4 c db  4 c b1  4 c b1  4 c 20 4 c 20  6 0 db 6 0 db  6 e b1  6 e b1  6 e 20 6 e 20
::set CUBECOLS=4 c db 4 c db  4 c b1  4 c b1  4 c 20 4 c 20

set CNT=0
set SLOTS=0
set FWORLD=data\3dworld.dat
if not "%~1" == "" if exist %1 set FWORLD=%1
for /F "tokens=*" %%i in (%FWORLD%) do (if !SLOTS!==0 call :STRLEN SLOTS "%%i")& set WRLD!CNT!=%%i&set /A CNT+=1
set YSLOTS=%CNT%

set CNT=0
set /A XC=-%SLOTS%
set /A SLOTM=%SLOTS%-1
set /A YC=-%YSLOTS%
set /A YSLOTM=%YSLOTS%-1
for /L %%i in (0,1,%YSLOTM%) do set SS=!WRLD%%i!& for /L %%j in (0,1,%SLOTM%) do set S=!SS:~%%j,1!&if not "!S!"=="-" for %%a in (!CNT!) do set sx%%a=1&set sz%%a=1&set sy%%a=!S!&set /A dx%%a = %XC%+%%j*2 & set /A dy%%a=3 & set /A dz%%a = %YC%+%%i*2 & set /A CNT+=1

set NOF_OBJECTS=%CNT%

set /A NOF_V=%NOF_OBJECTS%*8
set /A NOF_F=%NOF_OBJECTS%*6

set WNAME=objects\3dworld.ply

if exist %WNAME% set /A TX=(%XC%+%PLX%)*%MULVAL%&set TY=0&set /A TZ=(%YC%+%PLZ%)*%MULVAL%*-1 & goto SKIPGEN

echo ply>%WNAME%
echo format ascii 1.0>>%WNAME%
echo element vertex %NOF_V% >>%WNAME%
echo element face %NOF_F% >>%WNAME%
echo end_header>>%WNAME%

set Vx0=-1&set Vy0=-1&set Vz0=-1
set Vx1=1& set Vy1=-1&set Vz1=-1
set Vx2=1& set Vy2=1& set Vz2=-1
set Vx3=-1&set Vy3=1& set Vz3=-1
set Vx4=-1&set Vy4=-1&set Vz4=1
set Vx5=1& set Vy5=-1&set Vz5=1
set Vx6=1& set Vy6=1& set Vz6=1
set Vx7=-1&set Vy7=1& set Vz7=1

set F0_0=0&set F0_1=3&set F0_2=2&set F0_3=1
set F1_0=5&set F1_1=6&set F1_2=7&set F1_3=4
set F2_0=6&set F2_1=5&set F2_2=1&set F2_3=2
set F3_0=3&set F3_1=0&set F3_2=4&set F3_3=7
set F4_0=7&set F4_1=6&set F4_2=2&set F4_3=3
set F5_0=5&set F5_1=4&set F5_2=0&set F5_3=1

set /A NOF_O=%NOF_OBJECTS%-1
for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,7) do set /a vx=!Vx%%b!&(if not "!sx%%a!"=="" set /a vx*=!sx%%a!)&set /a vx+=!dx%%a!&set /a vx*=%MULVAL% & set /a vy=!Vy%%b!&(if not "!sy%%a!"=="" if !vy! lss 0 set /a vy*=!sy%%a!)&set /a vy+=!dy%%a!&set /a vy*=%YMULVAL% & set /a vz=!Vz%%b!&(if not "!sz%%a!"=="" set /a vz*=!sz%%a!)&set /a vz+=!dz%%a!&set /a vz*=%MULVAL%&echo !vx! !vy! !vz!>>%WNAME%
for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,5) do set /a f0=!F%%b_0!+%%a*8&set /a f1=!F%%b_1!+%%a*8&set /a f2=!F%%b_2!+%%a*8&set /a f3=!F%%b_3!+%%a*8&echo 4 !f0! !f1! !f2! !f3!>>%WNAME%


:SKIPGEN
set BKSTR="fbox 0 1 b1 0,0,%W%,30 & fbox 0 1 20 0,30,%W%,10 & fbox 9 1 b1 0,40,%W%,6 & fbox 9 1 db 0,46,%W%,4  &  fbox 0 0 20 0,51,%W%,5 & fbox 0 %GROUNDCOL% b2 0,53,%W%,5 & fbox 0 %GROUNDCOL% b1 0,57,%W%,10 & fbox 0 %GROUNDCOL% b0 0,64,%W%,22 & fbox 8 %GROUNDCOL% 20 0,80,%W%,100 "

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (
cmdgfx "%BKSTR:~1,-1% & 3d %WNAME% %DRAWMODE%,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,1,0,100 %XMID%,!YMID!,%DIST%,%ASPECT% !CUBECOLS!" k
set KEY=!ERRORLEVEL!

if !KEY! == 331 set /A RY+=6&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
if !KEY! == 333 set /A RY-=6&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)

if !KEY! == 328 call :MOVE 1
if !KEY! == 336 call :MOVE -1

if !KEY! == 337 set /A TY-=30
if !KEY! == 329 set /A TY+=30

if !KEY! == 335 set /A TY+=30&set /A YMID-=12
if !KEY! == 327 set /A TY-=30&set /A YMID+=12

if !KEY! == 32 set /a YMID=%H%/2-4 & set TY=0

if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

::if !KEY! == 97 set /A RX+=2
::if !KEY! == 122 set /A RX-=2

endlocal
mode 80,50
cls
cmdwiz setfont 6
goto :eof

:STRLEN <result> <string>
echo "%~2">tmpLen.dat
for %%? in (tmpLen.dat) do set /A %1=%%~z? - 4
del /Q tmpLen.dat
goto :eof

:MOVE <direction>
if !RY! lss 360 set /A AZ=-(360-!RY!)&set /A AX=360-(-!AZ!)
if !RY! geq 360 if !RY! lss 720 set /A AZ=360-(720-!RY!)&set /A AX=360-!AZ!
if !RY! geq 720 if !RY! lss 1080 set /A AZ=360-(!RY!-720)&set /A AX=-(360-!AZ!)
if !RY! geq 1080 set /A AZ=360-(!RY!-720)&set /A AX=-(360-(-!AZ!))

set /A TZ+=%AZ%*%1
set /A TX+=%AX%*%1
