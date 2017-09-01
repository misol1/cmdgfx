@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
bg font 1 & cls & cmdwiz showcursor 0
set /a W=160, H=80
mode %W%,%H%
call centerwindow.bat
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
 
set /a NOF_STARS=60, SDIST=4500, BGCOL=0
set /A TX=0,TX2=-2600
set COLS=f %BGCOL% 04   f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% . 7 %BGCOL% . 7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% .  8 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% .
set WNAME=starfield.ply
echo ply>%WNAME%
echo format ascii 1.0 >>%WNAME%
set /A NOF_V=%NOF_STARS% * 1
echo element vertex %NOF_V% >>%WNAME%
echo element face %NOF_STARS% >>%WNAME%
echo end_header>>%WNAME%
for /L %%a in (1,1,%NOF_STARS%) do set /A vx=!RANDOM! %% 240 -120 & set /A vy=!RANDOM! %% 200 -100 & set /A vz=!RANDOM! %% 400-160 & echo !vx! !vy! !vz!>>%WNAME%
set CNT=0&for /L %%a in (1,1,%NOF_STARS%) do set /A CNT1=!CNT!&set /A CNT+=1& echo 1 !CNT1! >>%WNAME%


set /a XMID=%W%/2, YMID=%H%/2, DIST=34000, DRAWMODE=5, COLADD=0, ROTMODE=0, EXIT=0, EXITCNT=200, EXITDIV=200
set /a CRX=0,CRY=0,CRZ=0,AW=1800,AH=502
set ASPECT=0.6665

set ALPHABET="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{ #?|.,:;<>()[]zz'=_-+/*\&}@$~"

set SENTENCE="ALPHABET"
if not "%~1"=="" set SENTENCE="%~1"

cmdwiz stringlen %SENTENCE% & set /a SENTLEN=!errorlevel!
set /a CNT=0
for /L %%a in (0,1,%SENTLEN%) do set CH="!SENTENCE:~%%a,1!"&cmdwiz stringfind %ALPHABET% !CH!&set /a RET=!errorlevel! & if not !RET!==-1 set CH!CNT!=!RET!&set /a "XM!CNT!=!RANDOM! %% 14000-7000,YM!CNT!=(!RANDOM! %% 14000-7000)*%EXITDIV%,ZM!CNT!=(!RANDOM! %% 14000-7000)*%EXITDIV%" & set /a "RXP!CNT!=!RANDOM! %% 20, RYP!CNT!=!RANDOM! %% 20, RZP!CNT!=!RANDOM! %% 20" & set /a CNT+=1

set /a XP=-%AW%*(!SENTLEN!/2)-%AW%/2*(!SENTLEN!%% 2)
set /a XP+=(%AW%-300)/2
set /a ORGXP=%XP%
set /a SENTLEN-=1
set /a BGCOL=0
::set /a BGCOL=!COLADD!+1

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a TX+=13, TX2+=13, XP=%ORGXP%
	if !TX!  gtr 2600 set /a TX=-2600
	if !TX2! gtr 2600 set /a TX2=-2600

	set OUTP=""
	for /L %%a in (0,1,%SENTLEN%) do set /a "RX%%a+=!RXP%%a!,RY%%a+=!RYP%%a!,RZ%%a+=!RZP%%a!, COLADD=(%%a %% 7), CYP=!YM%%a!/!EXITDIV!, CZP=!ZM%%a!/!EXITDIV!" & set OUTP="!OUTP:~1,-1!&3d objects\letters\alph!CH%%a!.obj %DRAWMODE%,!COLADD! !RX%%a!:!CRX!,!RY%%a!:!CRY!,!RZ%%a!:!CRZ! !XP!,!CYP!,!CZP! 8,10,8,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLADD! 0 db"& set /a XP+=%AW%

	start "" /B /High cmdgfx_gdi "fbox !BGCOL! 0 b0 0,0,%W%,%H% & 3d starfield.ply 1,1 0,0,0 !TX!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.6 %COLS% & 3d starfield.ply 1,1 0,0,0 !TX2!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.6 %COLS% &!OUTP:~1,-1!" Z300f1
	set OUTP=
	cmdgfx.exe "" knW12
	set KEY=!ERRORLEVEL!
	
	if !EXIT! == 0 if !ROTMODE! == 0 set /a "CRX=(!CRX!+2) %% 1440,CRY=(!CRY!+5) %% 1440,CRZ=(!CRZ!+7) %% 1440"

	if !KEY! gtr 0 (
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
		if !KEY! == 27 if !EXIT! == 0 set /a EXIT=1 & for /L %%a in (0,1,%SENTLEN%) do set /a "RX%%a=!RX%%a! %% 1440,RY%%a=!RY%%a! %% 1440,RZ%%a=!RZ%%a! %% 1440, RXP%%a=12,RYP%%a=12,RZP%%a=12"
	)
	
	if !EXIT! == 1 (
		set /a "CRX+=11,CRY+=11,CRZ+=11" & (if !CRX! gtr 1420 set /a CRX=1440)&(if !CRY! gtr 1420 set /a CRY=1440)&(if !CRZ! gtr 1420 set /a CRZ=1440)
		
		set /a EXITCNT-=1
		if !EXITCNT! lss 0 set STOP=1
		set /a EXITDIVP+=1
		set /a EXITDIV+=!EXITDIVP!
		if !EXITCNT! gtr 80 set /a DIST+=120
		if !EXITCNT! leq 80 set /a DIST+=1400
		for /L %%a in (0,1,%SENTLEN%) do (if !RX%%a! geq 1440 set RX%%a=1440)&(if !RY%%a! geq 1440 set RY%%a=1440)&(if !RZ%%a! geq 1440 set RZ%%a=1440)
	)
)
if not defined STOP goto LOOP
	
:SLUT	
endlocal
bg font 6 & cmdwiz showcursor 1 & mode 80,50
del /Q starfield.ply >nul
goto :eof
