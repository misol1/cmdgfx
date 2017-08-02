@echo off
bg font 1 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" SkOZ300f1:0,0,160,80W12
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
mode %W%,%H%
call centerwindow.bat 0 -20
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=1800, DRAWMODE=5, COLADD=0, ROTMODE=0
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
rem call :MAKEMULTIALPHA "Super bra"

::make complete "set" (missing {}) of .obj files, alph0-n.obj
::set ALTSET=1& call :MAKEMULTIALPHA "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{ #?|.,:;<>()[]zz'=_-+/*\&}@$~"

set ALTSET=0
::call :MAKECOMBINEDALPHA "DAWG|"

:: MAKECOMBINEDALPHA can use } for newline. But need to manually adjust xmod and ymod in 3d call
::if "%~1"=="" call :MAKECOMBINEDALPHA "HEY}BABE" 0 220 

if "%~1"=="" call :MAKECOMBINEDALPHA "SEX" 0 220 
::if "%~1"=="" call :MAKECOMBINEDALPHA "DAWG|" 1 380 
if not "%~1"=="" call :MAKECOMBINEDALPHA "%~1" %2 %3

call sindef.bat

set /a XMUL=300, YMUL=280, A1=155, A2=0, RANDPIX=2, DIV=1
set /a CM1=1 & set /a CM2=1

set /a STREAMCNT=0 & call :SETSTREAM

set /a SHOWHELP=1
set HELPMSG=text 8 0 0 SPACE\-\g11\g10\g1e\g1f\-s\-d/D\-(ENTER:\g11\g10\g1e\g1fzZ)\-h 1,78
if !SHOWHELP!==1 set MSG=%HELPMSG%

del /Q EL.dat >nul 2>nul
set EXTRA=&for /L %%a in (1,1,100) do set EXTRA=!EXTRA!xtra

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	
	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!), COLCNT3-=1

	set /a A1+=1, A2-=1, BGCOL=!COLADD!+1
	echo "cmdgfx: fbox !BGCOL! 0 b0 0,0,%W%,%H% & 3d %FN% %DRAWMODE%,!COLADD! !CRX!,!CRY!,!CRZ! 0,0,0 3,3,3,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLADD! 0 db & block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM:~1,-1! (neq(fgcol(x,y),!BGCOL!)*!CM2!+!CM1!)/!DIV!*(random()*!RANDPIX!/2+sin((x-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/5.5)/35)*(x/3)) & !MSG! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" Z100
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	if !ROTMODE! == 0 set /a CRX+=0,CRY+=0,CRZ+=11
	if !KEY! == 100 set /A DIST+=50
	if !KEY! == 68 set /A DIST-=50
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 110 set /a STREAMCNT+=1 & call :SETSTREAM
	if !KEY! == 32 set /a CM1=1-!CM1! & set /a CM2=%CM1%+1	
	if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set /a CRX=0, CRY=0, CRZ=0
	if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
	if !KEY! == 331 if !ROTMODE!==1 set /A CRY+=20
	if !KEY! == 333 if !ROTMODE!==1 set /A CRY-=20
	if !KEY! == 328 if !ROTMODE!==1 set /A CRX+=20
	if !KEY! == 336 if !ROTMODE!==1 set /A CRX-=20
	if !KEY! == 122 if !ROTMODE!==1 set /A CRZ+=20
	if !KEY! == 90 if !ROTMODE!==1 set /A CRZ-=20
	if !KEY! == 328 if !ROTMODE!==0 set /a DIV+=1 & if !DIV! gtr 10 set /a DIV=1
	if !KEY! == 336 if !ROTMODE!==0 set /a DIV-=1 & if !DIV! lss 1 set /a DIV=10
	if !KEY! == 333 if !ROTMODE!==0 set /a RANDPIX+=1
	if !KEY! == 331 if !ROTMODE!==0 set /a RANDPIX-=1 & if !RANDPIX! lss 0 set RANDPIX=0
	if !KEY! == 115 cmdwiz stringfind "!STREAM!" "04," & (if !errorlevel! gtr -1 set STREAM=!STREAM:04,=b1,!) & (if !errorlevel! equ -1 set STREAM=!STREAM:b1,=04,!)
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP
	
endlocal
echo "cmdgfx: quit"
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:SETSTREAM
if %STREAMCNT% geq 4 set /a STREAMCNT=0 
if %STREAMCNT% == 0 set STREAM="11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
if %STREAMCNT% == 1 set STREAM=92db=b9b1,a2db=fbb1,b2db=fbdb,c2db=fbb1,d2db=b9b1,e2db=9bdb,f2db=9bdb,?0db=10b0,?1db=10db,?2db=19b1,?3db=91db,?4db=9bb2,?ddb=30db,?edb=30db,?fdb=13b1
if %STREAMCNT% == 2 set STREAM="0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=91db,6???=9704,7???=79db,8???=7f04,9???=79db,a???=9704,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
if %STREAMCNT% == 3 set STREAM="?0db=00b0,01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
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
