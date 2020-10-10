@echo off
color 07
if defined __ goto :START
cls & cmdwiz showcursor 0 & title Absolute move - single output screen - resizeable
set __=.
cmdgfx_input.exe knW10xR | call %0 %* | cmdgfx_gdi "" SG256,8fa:0,0,640,480
set __=
cls & mode 80,50 & cmdwiz showcursor 1
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=80, H=40
cmdwiz setfont 6 & cls & mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set')  do if not %%v==H if not %%v==W set "%%v="

set /a NOFSCROLLS=9, YP=19, XMUL=6, W*=8, H*=12

call centerwindow.bat 0 -20
call prepareScale.bat 10

set MSG1=" This would most likely not be acceptable in e.g. an action game, but might be ok for some applications."
set MSG2=" The \f0F\r flag (which is only effective one frame) tells the server to flush the buffer and drop all following input that might have accumulated over stdin."
set MSG3=" On each run, the server checks for the existence of this file in the current folder."
set MSG4=" The main reason that would be desired is if a script occasionally \c4dynamically re-creates\r one or more 3d object files with the same name as was previously used."
set MSG5=" If you want to make sure that the next command run by the server is actually what you send *now*, you can write to a file called 'servercmd.dat' instead of sending strings into the queue over the pipe."
set MSG6=" Basically, there seems to be a limit to the size of the buffer between the client and the server."
set MSG7=" In other words, the client keeps running immediately, without waiting for the server to finish rendering."
set MSG8=" The server is perfectly capable of timing how fast it can run at maximum with the W flag, but it is important to keep in mind that this is not true for the client script!"
set MSG9=" When running cmdgfx externally, all flags are initially Off, and we might want to turn them On. However, when running as a server, flags may already be On and we might want to turn them Off at some point."

set /a CNT=0 & for %%a in (4  6  8  16 5  7  8  16 12 10) do set /a FW!CNT!=%%a, CNT+=1
set /a CNT=0 & for %%a in (6  8  8  8  12 12 12 12 16 18) do set /a FH!CNT!=%%a, CNT+=1
set /a CNT=1 & for %%a in (   31 18 14 8  62 40 12 39 10) do set /a YA!CNT!=%%a*rH/100, CNT+=1

set /a CNT=1 & for %%a in (5 8 9 7  3  1  8 2  0) do set /a FI!CNT!=%%a, CNT+=1
set /a CNT=1 & for %%a in (6 4 8 14 12 10 7 13 9) do set /a FS!CNT!=%%a, CNT+=1
set /a CNT=1 & for %%a in (9 e c a  d  f  b 7  8) do set FC!CNT!=%%a& set /a CNT+=1

call :PREPTEXTS

:REP
for /L %%1 in (1,1,3000) do if not defined STOP (

  echo "cmdgfx: fbox 0 0 0" nfa:0,0,!W!,!H!
  for /l %%a in (1,1,%NOFSCROLLS%) do set /a CXP=!XP%%a!/%XMUL% & echo "cmdgfx: text !FC%%a! 0 0 !SCROLL%%a:~1,-1! !CXP!,!YP%%a! !FI%%a!" n & set /a XP%%a-=!FS%%a! & if !XP%%a! lss !ENDX%%a! set /a XP%%a=!W!*%XMUL%
  echo "cmdgfx: "
  
  set /p INPUT=
  for /f "tokens=1,2,4,6, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%E, SCRW=%%F, SCRH=%%G 2>nul )
  
  if "!RESIZED!" == "1" set /a W=SCRW*8*rW/100+7, H=SCRH*12*rH/100+11 & cmdwiz showcursor 0 & call :PREPTEXTS
  
  if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1
  set /a KEY=0
)
if not defined STOP goto REP

echo "cmdgfx: quit"
title input:Q
endlocal
goto :eof

:PREPTEXTS
set /a "YPEXTRA=(H-480)/%NOFSCROLLS%"
set /a YP=19+YPEXTRA/2
for /l %%c in (1,1,%NOFSCROLLS%) do (
	set MSGTEMP=!MSG%%c!& set MSGTEMP=!MSGTEMP: =_!& set SCROLL%%c=!MSGTEMP!
	cmdwiz stringlen !SCROLL%%c!
	for %%b in (!FI%%c!) do (
		set /a W%%c=!errorlevel! * !FW%%b!
		set /a ENDX%%c=!errorlevel! * !FW%%b! * -%XMUL%
		set /a XP%%c=%W% + !RANDOM! %% 100, YP%%c=!YP!
		set /a XP%%c*=%XMUL%
		set /a YP+=!FH%%b!*2+!YA%%c!
		set /a YP+=!YPEXTRA!
	)
)
