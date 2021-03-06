:: 3d mouse GUI : Mikael Sollenborn 2017
@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 0 & cls
set /a W=180,H=90
mode %W%,%H%
cmdwiz showcursor 0
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w & set WINW=!errorlevel!
cmdwiz getwindowbounds h & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2,WPY=%SH%/2-%WINH%/2
cmdwiz setwindowpos %WPX% %WPY%

set /a CNT=0& for %%a in (00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f) do set CH!CNT!=%%a& set /a CNT+=1

set /a XMID=%W%/2-135, YMID=%H%/2-64
set /a HH=%H%*2, YMIDCLICK=%YMID%+%H%
cmdwiz setbuffersize %W% %HH%
set ASPECT=0.75
set /a DIST=620

set PCOL0=8 0 fa
set PCOL1=8 0 :
set PCOL2=8 0 b0
set PCOL3=8 0 b1
set PCOL4=8 0 b2
set PCOL5=8 7 b1
set PCOL6=7 0 db
set PCOL7=f 7 b1
set PCOL8=f 0 db

set BGIMG=_.png
set MENUFILE=data\3dGUI.dat
if not "%~1"=="" set MENUFILE=%~1
if not exist %MENUFILE% cls & echo Error: could not load %MENUFILE%. & cmdwiz getch & goto :ESCAPE

set /a CNT=-1 & for /f "tokens=1,2,3,4 delims=;" %%i in (%MENUFILE%) do set /a CNT+=1 & (if !CNT!==0 set BGIMG=%%i&set MSCALE=%%j&set MSWING=%%k) & if !CNT! gtr 0 call :MKTEXTUREPLANE !CNT! %%i %%j&set TT=%%k&set T!CNT!=!TT:_=\-!&set C!CNT!=%%l&set G!CNT!=1&(cmdwiz stringfind "%%i" ".txt" & if !errorlevel! geq 0 set G!CNT!=0)
set /a MAXPLANES=!CNT!

set /a MINRY=320, MAXRY=1000, KEY=0, SCALE=45
if not "%MSCALE%" == "" set /a SCALE=%MSCALE%
set /a RY=!MINRY!, RYP=0, RYSPAN=%MAXRY%-%MINRY%, FORCEDRYP=0, ENDREACH=0, TP=86
set /a RYDELTA=%RYSPAN%/%MAXPLANES%
set /a MD=0, RYPMUL=4, SWING=3, ENDCOUNT=-1
set /a RYPMAX=15*!RYPMUL!
set /a SELYMID=!YMID!, SELPLANE=-1, SELRZ=0, SELSCALE=-!SCALE!
if not "%MSWING%" == "" set /a SWING=%MSWING%
set SELCMD=

:: Ad hoc, how can I properly calculate these values?
set /a RYMID=238
set /a OBSMIN=%RYMID%*4-13*4, OBSMAX=%RYMID%*4+13*4

set SELTEXT=_&set TEXTCOL=7

set BKSTR="fbox 0 1 db 0,0,%W%,300"
if exist %BGIMG% set BKSTR="%BKSTR:~1,-1% & image %BGIMG% 0 0 b1 -1 0,0 0 0 %W%,%H%"

set STOP=
:GUILOOP
for /l %%1 in (1,1,300) do if not defined STOP (
	set CRSTR=""&set TEXT=!SELTEXT!

	set /a OLDRY=!RY!, OBSPLANE=-1
	set /a "INDEX=%MAXPLANES%-(!RY!-!MINRY!)/!RYDELTA!"
	if !INDEX! geq %MAXPLANES% set /a INDEX=0 
	set /a RY+=!RYDELTA!*!INDEX!& if !RY! gtr !MAXRY! set /a "RY=!RY!-!RYSPAN!"

	set /a RYPF=!RYP!*!SWING!
	
	if !SELPLANE! geq 0 set /a SELYMID+=2, SELRZ+=8, SELSCALE-=1, MOD=!ENDCOUNT! %% 3 & if !ENDCOUNT! lss 15 if !MOD! == 0 set /a TP+=1
	set /a ENDINDEX=!ENDREACH!*!SELPLANE!
	
	for /L %%b in (1,1,%MAXPLANES%) do set /a INDEX+=1 & (if !INDEX! gtr %MAXPLANES% set /a INDEX=1) & for %%i in (!INDEX!) do set /a "RY+=!RYDELTA!,SYMID=!YMID!,SRZ=0,SSCALE=-!SCALE!, RYC=(!RY!-!MINRY!)/80" & (if !SELPLANE! lss 0 if !RY! gtr !OBSMIN! if !RY! lss !OBSMAX! set text=!T%%i!&set OBSPLANE=%%i) & (if !RYC! gtr 8 set /a RYC=8) & for %%c in (!RYC!) do (if !SELPLANE! geq 0 if %%i neq !SELPLANE! set /a SYMID=!SELYMID!) & (if !SELPLANE! geq 0 if %%i equ !SELPLANE! set /a SRZ=!SELRZ!,SSCALE=!SELSCALE!) & set /a FGCOL=0&(if !G%%i!==0 set FGCOL=!PCOL%%c:~0,2!)&(if %%i neq !ENDINDEX! set CRSTR="!CRSTR:~1,-1! & 3d objects\GUIplane.obj 1,0 !RYPF!:0,0:!RY!,!SRZ!:0 -3500:0,0:-1150,0:7000 !SSCALE!,!SSCALE!,!SSCALE!,0,0,0 0,0,0,10 %XMID%,!SYMID!,!DIST!,%ASPECT% !PCOL%%c! & 3d plane-t%%i.obj 5,0 !RYPF!:0,0:!RY!,!SRZ!:0 -3500:0,0:-1150,0:7000 !SSCALE!,!SSCALE!,!SSCALE!,0,0,0  0,0,0,10 %XMID%,!SYMID!,!DIST!,%ASPECT% !FGCOL! 0 b1") & if !RY! gtr !MAXRY! set /a "RY=!RY!-!RYSPAN!"

	start /B /High cmdgfx_gdi "%BKSTR:~1,-1% & !CRSTR:~1,-1! & text !TEXTCOL! 0 0 !TEXT! 90,!TP!" Z400f0:0,0,%W%,%H%
	cmdgfx "" M0unW12
	rem cmdgfx_gdi "%BKSTR:~1,-1% & !CRSTR:~1,-1! & text !TEXTCOL! 0 0 !TEXT! 90,!TP!" M0Z400f0:0,0,%W%,%H%
	
	if !RYP! geq 0 set /a RYP-=1 & if !RYP! lss 0 set /a RYP=0
	if !RYP! leq 0 set /a RYP+=1 & if !RYP! gtr 0 set /a RYP=0

	set RET=!errorlevel!
   if not !RET! == -1 if !SELPLANE! lss 0 (
		set /a "ME=!RET! & 1,ML=(!RET!&2)>>1, MR=(!RET!&4)>>2, MWD=MT=(!RET!&8)>>3, MWU=(!RET!&16)>>4, MX=(!RET!>>5)&511, MY=(!RET!>>14)&127"
		
		if !MD!==1 set /a "RYP=(!MX!-!OLDMX!)*!RYPMUL!" & (if !RYP! gtr !RYPMAX! set /a RYP=!RYPMAX!) & (if !RYP! lss -!RYPMAX! set /a RYP=-!RYPMAX!)
		
		if !ML!==1 (if !MD!==0 set /a ORGX=!MX!, ORGY=!MY!) & set /a MD=1
		if !ML!==0 (if !MD!==1 if "!MX!"=="!ORGX!" if "!MY!"=="!ORGY!" call :CHECK_CLICK) & set /a MD=0
		set CRSTR=
		
      set /a OLDMX=!MX!,OLDMY=!MY!
		set /a "NKEY=!RET!>>22, NKD=(!RET!>>21) & 1"
		
		if not !NKEY!==0 (
			if !NKD!==0 (
			   set KEY=!NKEY!
				if !KEY! == 27 set STOP=1
				if !KEY! == 32 if !OBSPLANE! geq 0 set /a SELPLANE=!OBSPLANE!&set SELTEXT=!TEXT!&set TEXTCOL=f&set /a FORCEDRYP=10*!RYPMUL!, ENDCOUNT=50
				if !KEY! == 13 set /a SWING=3-!SWING!, KEY=0
				if !KEY! == 112 cmdwiz getch
				set KEY=0
			)
			if !NKD!==1 set KEY=!NKEY!
		)
	)
	if not !KEY! == 0 (
		if !KEY! == 331 set /a RYP=-6*!RYPMUL!
		if !KEY! == 333 set /a RYP=6*!RYPMUL!
   )
	set CRSTR=
	
	if !FORCEDRYP! gtr 0 set RYP=-!FORCEDRYP!
			
	set /a RY=!OLDRY!-!RYP!/!RYPMUL!
	
	if !ENDCOUNT! gtr 0 set /a ENDCOUNT-=1 & if !ENDCOUNT! == 0 set /a STOP=1&for %%a in (!SELPLANE!) do set SELCMD=!C%%a!
	if !SELPLANE! geq 0 set /a "CHK=!MAXRY!-20-(!SELPLANE!-1)*%RYDELTA%, CHK2=!MAXRY!-20-(!SELPLANE!-1)*%RYDELTA%+20" & if !RY! geq !CHK! if !RY! lss !CHK2! set /a ENDREACH=1

	if !RY! gtr !MAXRY! set /a "RY=!RY!-!RYSPAN!"
	if !RY! lss !MINRY! set /a "RY=!MAXRY!-(!MINRY!-!RY!)"
)
if not defined STOP goto GUILOOP

:ESCAPE
endlocal & set SELCMD=%SELCMD%
cls & mode 80,50
cmdwiz showcursor 1
cmdwiz setfont 6
del /Q plane-t*.obj > nul 2>nul
%SELCMD%
goto :eof

:CHECK_CLICK
	if !MY! geq %H% goto :eof
	
	set /a RY=!OLDRY! 
	set /a "INDEX=%MAXPLANES%-(!RY!-!MINRY!)/!RYDELTA!"
	if !INDEX! geq %MAXPLANES% set /a INDEX=0 
	set /a RY+=!RYDELTA!*!INDEX!& if !RY! gtr !MAXRY! set /a "RY=!RY!-!RYSPAN!"
	for /L %%b in (1,1,%MAXPLANES%) do set /a INDEX+=1 & (if !INDEX! gtr %MAXPLANES% set /a INDEX=1) &set /a RY+=!RYDELTA!&set /a "RYC=(!RY!-!MINRY!)/80" & (if !RYC! gtr 8 set /a RYC=8) & for %%e in (!RYC!) do for %%c in (!INDEX!) do set CRSTR="!CRSTR:~1,-1! & 3d objects\GUIplane.obj 1,0 !RYPF!:0,0:!RY!,0:0 -3500:0,0:-1150,0:7000 -!SCALE!,-!SCALE!,-!SCALE!,0,0,0 0,0,0,10 %XMID%,%YMIDCLICK%,!DIST!,%ASPECT% 1 0 !CH%%c!"& if !RY! gtr !MAXRY! set /a "RY=!RY!-!RYSPAN!"

	cmdgfx "%BKSTR:~1,-1% & fbox 0 0 20 0,%H%,%W%,%H% & !CRSTR:~1,-1! & text !TEXTCOL! 0 0 !TEXT! 90,!TP!" Z400

	set /a CHKY=!MY!+%H%
	cmdwiz getcharat !MX! !CHKY!
	set /a CHKCHAR=!errorlevel!
   if !CHKCHAR! geq 1 if !CHKCHAR! leq %MAXPLANES% set /a SELPLANE=!CHKCHAR!,SELYMID=!YMID!&for %%a in (!SELPLANE!) do set SELTEXT=!T%%a!&set TEXTCOL=f&set /a FORCEDRYP=10*!RYPMUL!, ENDCOUNT=53
goto :eof

	
:MKTEXTUREPLANE
del /Q plane-t%1.obj > nul 2>nul
for /F "tokens=*" %%a in (objects\GUIplane2.obj) do set LINE=%%a&set LINE=!LINE:emma.txt=%2!&set LINE=!LINE:5=%3!&echo !LINE!>> plane-t%1.obj
