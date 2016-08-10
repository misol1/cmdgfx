:: CmdRunner : Mikael Sollenborn 2016
:: NOT faster than single-threaded... ?? because of file-writing (master) + reading+building string(slave)? Should I send the strings instead? Or have cmdgfx accept a file as input?

@echo off
setlocal ENABLEDELAYEDEXPANSION

set "myID=%~2"
if "%~1" neq "" goto %1

rem Define auxiliary variables
rem http://www.dostips.com/forum/viewtopic.php?f=3&t=6134
set LF=^
%Do not remove this line 1/2%
%Do not remove this line 2/2%
for /F %%a in ('copy /Z "%~F0" NUL') do set "CR=%%a"
set "spaces= "
for /L %%i in (1,1,10) do set "spaces=!spaces!!spaces!"

cd /D "%~DP0"

bg font 0&cls
set W=180&set H=110
mode con lines=%H% cols=%W%
mode con rate=31 delay=0
cmdwiz showcursor 0
color 07
::for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="
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
set NEWTHREAD=1

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

::echo Example A: Main code send commands to a chain of waiting service threads
if %NEWTHREAD%==1 "%~NX0" IDLELOOP 3>&1 1>&2 | "%~NX0" ThreadA 1
if %NEWTHREAD%==1 goto :eof


:IDLELOOP
del /Q a? 2>NUL
set SWITCH=0
set "output=draw%spaces%"
::final string length should be 1021!! (plus added newline(CRLF) from echo = 1023)
set "output=%output:~0,1016%"
set "exitcmd=exit%spaces%"
set "exitcmd=%exitcmd:~0,1016%"
set NEWTHREAD=0
echo 0 >key
set KEY=0

set STOP=
:IDLELOOPER
for /L %%1 in (1,1,100) do if not defined STOP for /L %%2 in (1,1,100) do if not defined STOP (
set /A INDEX=!STARTINDEX!-1
for /L %%b in (1,1,%MAXCUBES%) do set /A INDEX+=1&(if !INDEX! gtr %MAXCUBES% set INDEX=1)& for %%a in (!INDEX!) do echo  ^& 3d cube.ply %DRAWMODE%,-1 0,!RY!,0 !PX%%a!,-1800,!PZ%%a! -250,-250,-250,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !CPAL%%a!>>a!SWITCH!&set /A PZ%%a-=%ACCSPEED% & if !PZ%%a! lss 1000 set PZ%%a=30000&set /A PX%%a=!RANDOM! %% 8000 - 4000&set /A STARTINDEX-=1&if !STARTINDEX! lss 1 set STARTINDEX=%MAXCUBES%
echo 1: !SWITCH! !output!>&3
set /A TSWITCH=1-!SWITCH!
:WAITLOOP
if exist a!TSWITCH! goto WAITLOOP
if exist key set /p KEY=<key
set /a RY+=8
set /A SWITCH=1-!SWITCH!
if !KEY! == 27 set STOP=1
if !KEY! == 32 set STOP=2
)
if not defined STOP goto IDLELOOPER
if %KEY% == 27 goto ESCAPE

:INGAMELOOP
set CRSTR=""
set /A INDEX=%STARTINDEX%-1
for /L %%b in (1,1,%MAXCUBES%) do set /A INDEX+=1&(if !INDEX! gtr %MAXCUBES% set INDEX=1)& for %%a in (!INDEX!) do set CRSTR="!CRSTR:~1,-1! & 3d cube.ply %DRAWMODE%,-1 0,%RY%,0 !PX%%a!,!PY%%a!,!PZ%%a! -250,-250,-250,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !CPAL%%a!"&set /A PZ%%a-=%ACCSPEED% & if !PZ%%a! lss 1000 set PZ%%a=30000&set /A PX%%a=!RANDOM! %% 8000 - 4000 - %TILT%*50 &(if %ACTIVECUBES% leq !NOFCUBES! if !PY%%a! lss -1800 if !RANDOM! lss 10922 set /A PY%%a=-1800&set /A ACTIVECUBES+=1)&set /A STARTINDEX-=1&if !STARTINDEX! lss 1 set STARTINDEX=%MAXCUBES%

cmdgfx "%BKSTR:~1,-1% %CRSTR:~1,-1% & 3d tetramod.ply %DRAWMODE%,-1 0,180,%TILT% 0,-1800,4000 -50,-50,-50,0,0,0 1,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% f %GROUNDCOL% %PLYCHAR% 7 %GROUNDCOL% %PLYCHAR% & 3d tetramod.ply %DRAWMODE%,-1 0,180,%TILT% 0,-1900,4000 -50,-50,-50,0,0,0 1,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 %GROUNDCOL% b2 0 %GROUNDCOL% b2 & text 7 1 0 SCORE:_%SCORE%_(%HISCORE%) 2,1" k
set KEY=%ERRORLEVEL%
for /L %%a in (1,1,%MAXCUBES%) do if !PY%%a! gtr -15000 if !PZ%%a! lss 4000 if !PZ%%a! gtr 3500 if !PX%%a! gtr -300 if !PX%%a! lss 300 (for /L %%a in (1,1,40) do set /A TILT+=40 & cmdgfx "%BKSTR:~1,-1% %CRSTR:~1,-1% & 3d tetramod.ply %DRAWMODE%,-1 0,180,!TILT! 0,-1800,4000 -50,-50,-50,0,0,0 1,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% f %GROUNDCOL% %PLYCHAR% 7 %GROUNDCOL% %PLYCHAR% & text 7 1 0 SCORE:_%SCORE%_(%HISCORE%) 2,1")&goto OUTERLOOP

set /A NOFCUBES=15+%SCORE%/250 & if !NOFCUBES! gtr %MAXCUBES% set NOFCUBES=%MAXCUBES%
if not %TILT%==0 (if %TILT% gtr 0 set /A TILT-=1) & (if %TILT% lss 0 set /A TILT+=1)

if %KEY%==331 set /A TILT+=7&if !TILT! gtr 55 set TILT=55
if %KEY%==333 set /A TILT-=7&if !TILT! lss -55 set TILT=-55
if %TILT% gtr 0 for /L %%a in (1,1,%MAXCUBES%) do set /A PX%%a+=%TILT%
if %TILT% lss 0 for /L %%a in (1,1,%MAXCUBES%) do set /A PX%%a+=%TILT%
set /a RY+=8
set /a SCORE+=1&if !SCORE! gtr %HISCORE% set HISCORE=!SCORE!
if not %KEY% == 27 goto INGAMELOOP
goto OUTERLOOP

:ESCAPE
echo %HISCORE%>hiscore.dat
echo 1: !SWITCH! %exitcmd%>&3
endlocal
mode con cols=80 lines=50
cmdwiz showcursor 1
del /Q key>nul
cls
bg font 6
goto :eof


:ThreadA
   rem Get a command from main code or previous thread
   set /P "command="
   for /F "tokens=1-3" %%a in ("%command%") do (
      if "%%a" equ "%myID%:" (
         rem Command intended for this thread: execute it
			if "%%c" == "draw" (
::          echo ThreadA #%myID%, received command: "%%c" %%b > CON
				cmdgfx "%BKSTR:~1,-1% & image CR2.gxy 0 0 0 20 28,2 & insert a%%b & text f 1 0 _Press_SPACE_to_play_ 80,15" k
				echo !ERRORLEVEL!>key
				del /Q a%%b
			)
		) else (
         rem Pass command to next thread in the chain
         echo %command%
      )
   )
if "%command:~5,4%" neq "exit" goto ThreadA
::echo ThreadA #%myID%, terminating... > CON
goto :EOF
