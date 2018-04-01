@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1 & cls & cmdwiz showcursor 0
set /a W=160, H=80
mode %W%,%H%
call centerwindow.bat
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=2000, DRAWMODE=5, COLADD=0, ROTMODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.6665
set TEXTURE=img\alpha.pcx
::set TEXTURE=img\alpha1.pcx

goto SKIP
::use index 62 to get "
call :MAKESINGLEALPHA 0 " " 62
::use | to get !
call :MAKESINGLEALPHA 0 "|"
::OR index 66
call :MAKESINGLEALPHA 0 " " 66

::use index 86 to get \
call :MAKESINGLEALPHA 0 " " 86

::use index 88 to get %
call :MAKESINGLEALPHA 0 " " 88

:: use quotes for safety
call :MAKESINGLEALPHA 0 "&"
call :MAKESINGLEALPHA 0 " "

call :MAKESINGLEALPHA 0 "S"
:SKIP

::call :MAKESINGLEALPHA 0 "S"

:: if set {=", }=%, | is still !
::set ALTSET=0
rem call :MAKEMULTIALPHA "Super fine"

::make complete "set" (missing {}) of .obj files, alph0-n.obj
::set ALTSET=1& call :MAKEMULTIALPHA "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{ #?|.,:;<>()[]zz'=_-+/*\&}@$~"

set ALTSET=0

:: MAKECOMBINEDALPHA can use } for newline. But need to manually adjust xmod and ymod in 3d call
::if "%~1"=="" call :MAKECOMBINEDALPHA "HEY}BABE" 0 220 

::if "%~1"=="" call :MAKECOMBINEDALPHA "SEX" 0 200 
if "%~1"=="" call :MAKECOMBINEDALPHA "DAWG|" 1 380 
if not "%~1"=="" call :MAKECOMBINEDALPHA "%~1" %2 %3

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	
	set /a BGCOL=!COLADD!+1
	start "" /B /High cmdgfx_gdi "fbox !BGCOL! 0 b0 0,0,%W%,%H% & 3d %FN% %DRAWMODE%,!COLADD! !CRX!,!CRY!,!CRZ! 0,0,0 3,3,3,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLADD! 0 db" Z100f1
	cmdgfx.exe "" knW12
	set KEY=!ERRORLEVEL!
	
	if !ROTMODE! == 0 set /a CRX+=0,CRY+=0,CRZ+=11
	if !KEY! == 100 set /A DIST+=50
	if !KEY! == 68 set /A DIST-=50
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 32 set /a COLADD+=1&if !COLADD! gtr 6 set COLADD=0
	if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set /a CRX=0, CRY=0, CRZ=0
	if !KEY! == 331 if !ROTMODE!==1 set /A CRY+=20
	if !KEY! == 333 if !ROTMODE!==1 set /A CRY-=20
	if !KEY! == 328 if !ROTMODE!==1 set /A CRX+=20
	if !KEY! == 336 if !ROTMODE!==1 set /A CRX-=20
	if !KEY! == 122 if !ROTMODE!==1 set /A CRZ+=20
	if !KEY! == 90 if !ROTMODE!==1 set /A CRZ-=20
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP
	
endlocal
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof


:: Texture coordinates for plane returned in TX1,TY1,TX2,TY2
:GETALPHACOORDS <inAlpha> <inIndex>
set ERR=
if "%~1" == "" set /a ERR=1 & goto :eof
set INDEX=
if not "%~2" == "" set /a INDEX=%~2
if not "%ALTSET%"=="1" if "%INDEX%" == "" cmdwiz stringfind "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789z #?|.,:;<>()[]{}'=_-+/*\&z@$~" "%~1" & set INDEX=!ERRORLEVEL!
if "%ALTSET%"=="1" if "%INDEX%" == "" cmdwiz stringfind "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{ #?|.,:;<>()[]zz'=_-+/*\&}@$~" "%~1" & set INDEX=!ERRORLEVEL!
if %INDEX% lss 0 set /a ERR=1 & goto :eof
if %INDEX% geq 92 set /a ERR=1 & goto :eof
set /a YI=%INDEX% / 31, XI=%INDEX% %% 31
set /a XDELT=10000/31
set /a YDELT=10000/3
call :SETCOORD TX1 %XDELT% %XI%
call :SETCOORD TY1 %YDELT% %YI%
set /a XI+=1, YI+=1
call :SETCOORD TX2 %XDELT% %XI%
call :SETCOORD TY2 %YDELT% %YI%
goto :eof

:SETCOORD <out> <delta> <index>
set ZEROS=000000000000
set /a VAL=%2*%3
if %VAL%==0 set %1=0&goto :eof
if %VAL% geq 10000 set %1=1&goto :eof
cmdwiz stringlen "%VAL%"
set /a LEN=4-!errorlevel!
set %1=0.!ZEROS:~0,%LEN%!%VAL%
goto :eof

:MAKESINGLEALPHA
if "%~2" == "" goto :eof
call :GETALPHACOORDS "%~2" %~3
if not "%ERR%" == "" goto :eof
set FN=alph%~1.obj
echo usemtl %TEXTURE%>%FN%
echo v  -150 -251.16 0 >>%FN%
echo v   150 -251.16 0 >>%FN%
echo v   150  251.16 0 >>%FN%
echo v  -150  251.16 0 >>%FN%
echo vt %TX1% %TY1% >>%FN%
echo vt %TX2% %TY1% >>%FN%
echo vt %TX2% %TY2% >>%FN%
echo vt %TX1% %TY2% >>%FN%
echo f 1/1/ 2/2/ 3/3/ 4/4/ >>%FN%
goto :eof

:MAKEMULTIALPHA
if "%~1" == "" goto :eof
cmdwiz stringlen "%~1"
set /a LEN=!errorlevel!
set /a CNT=0
set STR="%~1"
for /L %%a in (1,1,%LEN%) do call :MAKESINGLEALPHA !CNT! "!STR:~%%a,1!" & set /a CNT+=1
goto :eof


:MAKECOMBINEDSINGLEALPHA
if "%~1" == "" goto :eof
call :GETALPHACOORDS "%~1"
if not "%ERR%" == "" goto :eof
echo v  %XP1% %YP1% 0 >>%FN%
echo v  %XP2% %YP1% 0 >>%FN%
echo v  %XP2% %YP2% 0 >>%FN%
echo v  %XP1% %YP2% 0 >>%FN%
echo vt %TX1% %TY1% >>%FN%
echo vt %TX2% %TY1% >>%FN%
echo vt %TX2% %TY2% >>%FN%
echo vt %TX1% %TY2% >>%FN%
echo f %F1%/%F1%/ %F2%/%F2%/ %F3%/%F3%/ %F4%/%F4%/ >>%FN%
goto :eof

:MAKECOMBINEDALPHA
if "%~1" == "" goto :eof
cmdwiz stringlen "%~1"
set /a LEN=!errorlevel!
set /a F1=1,F2=2,F3=3,F4=4
set /a AW=300,AH=502
if not "%~3" == "" if "%~2"=="1" set /a AH=%~3
if not "%~3" == "" if not "%~2"=="1" set /a AW=%~3
set STR="%~1"

if not "%~2"=="1" set /a XP1=-%AW%*(!LEN!/2)-%AW%/2*(!LEN!%% 2), YP1=-%AH%+%AH%/2, XPP=%AW%, YPP=0
if "%~2"=="1" set /a YP1=-%AH%*(!LEN!/2)-%AH%/2*(!LEN!%% 2), XP1=-%AW%+%AW%/2, XPP=0, YPP=%AH%
set /a XP1+=(%AW%-300)/2
set /a YP1+=(%AH%-502)/2
set /a ORGXP1=%XP1%

set /a XP2=%XP1%+300
set /a YP2=%YP1%+502

set FN=alphComb.obj
echo usemtl %TEXTURE%>%FN%

for /L %%a in (1,1,%LEN%) do set CH="!STR:~%%a,1!"& (if !CH!=="}" set /a YP1+=%AH%, XP1=%ORGXP1%-%XPP%) & call :MAKECOMBINEDSINGLEALPHA !CH! & set /a F1+=4,F2+=4,F3+=4,F4+=4,XP1+=%XPP%,YP1+=%YPP% & set /a XP2=!XP1!+300,YP2=!YP1!+502
goto :eof
