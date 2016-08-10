@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 1
set W=160&set H=80
mode %W%,%H% & cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=2500
set ASPECT=1.5
set DRAWMODE=0
set BITOP=3
set BKG=0
call sintable.bat

for /L %%a in (0,1,200) do set /A SV=720+%%a & set SIN!SV!=!SIN%%a!

set CIRCS=8
set OW=30
set /A CNT=360 / %OW%
set /A CNTV=((%CNT%)*2+2) * 2 * %CIRCS%
set /A FACES=2*%CIRCS%
set WNAME=inter.ply
echo ply>%WNAME%
echo format ascii 1.0 >>%WNAME%
echo element vertex %CNTV% >>%WNAME%
echo element face %FACES% >>%WNAME%
echo end_header>>%WNAME%

set CC=1
:REP
set /A MUL=90*%CC%-50
set /A MUL2=%MUL%+40
for /L %%a in (0,%OW%,360) do set /A COS=%%a+180&for %%b in (!COS!) do set /a "XPOS=(!SIN%%a!*%MUL%>>14)" & set /A "YPOS=(!SIN%%b!*%MUL%>>14)" & echo !XPOS! !YPOS! 0 >>%WNAME% & set /a "XPOS=(!SIN%%a!*%MUL2%>>14)" & set /A "YPOS=(!SIN%%b!*%MUL2%>>14)" & echo !XPOS! !YPOS! 0 >>%WNAME%
for /L %%a in (360,%OW%,720) do set /A COS=%%a+180&for %%b in (!COS!) do set /a "XPOS=(!SIN%%a!*%MUL%>>14)-5" & set /A "YPOS=(!SIN%%b!*%MUL%>>14)" & echo !XPOS! !YPOS! 0 >>%WNAME% & set /a "XPOS=(!SIN%%a!*%MUL2%>>14)-5" & set /A "YPOS=(!SIN%%b!*%MUL2%>>14)" & echo !XPOS! !YPOS! 0 >>%WNAME%
set /A PRC=%CC%*100/%CIRCS% & cmdgfx "text 9 0 0 Generating_image(!PRC!%%)... 70,35"
set /A CC+=1
if %CC% leq %CIRCS% goto REP

for /L %%a in (720,1,1000) do set SIN%%a=

set CC=0
:REP2
set STR=&for %%a in (0 1 3 5 7 9 11 13 15 17 19 21 23 25 24 22 20 18 16 14 12 10 8 6 4 2) do set /A C=(!CC!*26)+%%a&set STR=!STR! !C!
echo 26 %STR% >>%WNAME%
set /A CC+=1
if %CC% lss %FACES% goto REP2

set /A X1=0,Y1=0,XA1=6,YA1=14,COL1=1,XM1=235,YM1=120
set /A X2=200,Y2=500,XA2=-10,YA2=11,COL2=1,XM2=130,YM2=180
set OP=XOR
set RENDERER=_gdi&set REND=0

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (

set CRSTR=""&for /L %%a in (1,1,2) do for %%b in (!X%%a!) do for %%c in (!Y%%a!) do set /A "XP=((!SIN%%b!*!XM%%a!)>>14),YP=((!SIN%%c!*!YM%%a!)>>14),X%%a+=!XA%%a!,Y%%a+=!YA%%a!" & set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,!BITOP!  0,0,0 0,0,0 1,1,1,!XP!,!YP!,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%a! 0 db"&(if !X%%a! geq 720 set /A X%%a-=720)&(if !X%%a! lss 0 set /A X%%a=720+!X%%a!)&(if !Y%%a! geq 720 set /A Y%%a-=720)&(if !Y%%a! lss 0 set /A Y%%a=720+!Y%%a!)

cmdgfx!RENDERER! "fbox !BKG! 0 20 0,0,200,100 & !CRSTR:~1,-1! & text 9 0 0 !OP!(space)\-Col1:!COL1!(Left/Right)\-Col2:!COL2!(Up/Down) 1,78" kf1
set KEY=!ERRORLEVEL!

if !KEY! == 32 set /A BITOP+=1&(if !BITOP! gtr 6 set BITOP=0)&set CNT=0&for %%a in (NORMAL OR AND XOR ADD SUB SUB-n) do (if !CNT!==!BITOP! set OP=%%a)&set /A CNT+=1
if !KEY! == 13 set /A BKG+=1&if !BKG! gtr 15 set BKG=0
if !KEY! == 331 set /A COL1-=1&if !COL1! lss 1 set COL1=15
if !KEY! == 333 set /A COL1+=1&if !COL1! gtr 15 set COL1=1
if !KEY! == 336 set /A COL2-=1&if !COL2! lss 1 set COL2=15
if !KEY! == 328 set /A COL2+=1&if !COL2! gtr 15 set COL2=1
if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
if !KEY! == 112 cmdwiz getch
if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

del /Q %WNAME%
endlocal
cls & mode 80,50
bg font 6
