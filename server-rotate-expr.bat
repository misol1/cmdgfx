@echo off
cmdwiz showcursor 0 & cmdwiz setfont 8 & title Expression rotation
if defined __ goto :START
set __=.
cmdgfx_input.exe knW18xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,330,130,110,65t4
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=110, H=65
set /a F8W=W/2, F8H=H/2
mode %F8W%,%F8H%
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

call centerwindow.bat 0 -10
call preparescale.bat 1

set /a WW=!W!*2, WWW=!W!*3, HH=!H!*2, WMID=!W!/2, HMID=!H!/2
set /a WWX=!W!+!WMID!, CMX=!WMID!+3,CMY=!HMID!-3
cmdwiz showcursor 0
cmdgfx "fbox 0 0 00"

set STREAM="??90=8?--,??80=7?--,??70=6?--,??60=5?--,??50=4?--,??40=3?--,??30=2?--,??20=1?--,??00=0000,????=??--"

set TRANSF="8???=fb45,7???=fb38,6???=b906,5???=b921,4???=9131,3???=91e6,2???=10c9,1???=10c3,0???=1000"

set /a MODE=0, FINER=1, SCNT=0, BASEROT=10
set /a BX=!W!+40,BW=!WW!-40*2 & set /a BM=!BW!/2
set V=1
set fromto=from

::optimizations
:: sin(SCNT/10)
set S1=0.0499& set S2=0.0998& set S3=0.1494
:: cos(SCNT/10)
set C1=0.998& set C2=0.995& set C3=0.988

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a SCNT=0
	for /L %%a in (1,1,!FINER!) do set /a SCNT+=BASEROT
	set /a OF=FINER
	set /a FINER+=1 & if !FINER! gtr 3 set FINER=1
	
	if !MODE!==0 set /a "PX=!W!+!RANDOM! %% !WW!, PY=!HMID!+!RANDOM! %% !H!" & set STR="fellipse 6 0 60 !PX!,!PY!,26,3 & fellipse 7 0 70 !PX!,!PY!,22,2 & fellipse 8 0 80 !PX!,!PY!,18,1 & fellipse 9 0 90 !PX!,!PY!,15,0"

	if !MODE!==1 set STR=""& (for /L %%a in (1,1,3) do set /a "PX=!W!+!RANDOM! %% !WW!, PY=!HMID!+!RANDOM! %% !H!" & set STR="!STR:~1,-1! & fellipse 5 0 50 !PX!,!PY!,5,3 & fellipse 7 0 70 !PX!,!PY!,3,2 & fellipse 8 0 80 !PX!,!PY!,2,1 & fellipse 9 0 90 !PX!,!PY!,1,0")
	
	if !MODE!==2 set STR=""& (for /L %%a in (1,1,7) do set /a "PX=!W!+!RANDOM! %% !WW!, PY=!HMID!+!RANDOM! %% !H!" & set /a "PX2=!PX!+!RANDOM! %% 10" & set /a "PX3=!PX2!+!RANDOM! %% 10" & set /a "PX4=!PX3!+!RANDOM! %% 10" & set /a "PX5=!PX4!+!RANDOM! %% 10" & set STR="!STR:~1,-1! & line 5 0 50 !PX!,!PY!,!PX2!,!PY! & line 7 0 70 !PX2!,!PY!,!PX3!,!PY! & line 8 0 80 !PX3!,!PY!,!PX4!,!PY! & line 6 0 60 !PX4!,!PY!,!PX5!,!PY!")

	for %%d in (!OF!) do echo "cmdgfx: !STR:~1,-1! & block 0 !BX!,0,!BW!,!HH! !BX!,0 -1 0 0 %STREAM:~1,-1% - !BM!+(((x-!BM!)*!C%%d!-(y-!H!)*!S%%d!)) !H!+(((x-!BM!)*!S%%d!+(y-!H!)*!C%%d!)) !fromto! & block 0 !WWX!,!HMID!,!W!,!H! 0,0 -1 0 0 %TRANSF:~1,-1% & fellipse 0 0 00 !CMX!,!CMY!,7,5" Ff1:0,0,!WWW!,!HH!,!W!,!H!

	rem Old,non-optimized. Also supports V to zoom in/out
	rem echo "cmdgfx: !STR:~1,-1! & block 0 !BX!,0,!BW!,!HH! !BX!,0 -1 0 0 %STREAM:~1,-1% - !BM!+(((x-!BM!)*cos(!SCNT!/200)-(y-!H!)*sin(!SCNT!/200)))*!V! !H!+(((x-!BM!)*sin(!SCNT!/200)+(y-!H!)*cos(!SCNT!/200)))*!V! !fromto! & block 0 !WWX!,!HMID!,!W!,!H! 0,0 -1 0 0 %TRANSF:~1,-1% & fellipse 0 0 00 !CMX!,!CMY!,7,5" Ff1:0,0,!WWW!,!HH!,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
	
	if "!RESIZED!"=="1" cmdwiz showcursor 0 & set /a "FINER=1, W=SCRW*2*rW/100+2, H=SCRH*2*rH/100+2, WW=W*2, WWW=W*3, HH=H*2, WMID=W/2, HMID=H/2" & set /a "WWX=!W!+!WMID!, CMX=!WMID!+3,CMY=!HMID!-3" & set /a "BX=!W!+40,BW=!WW!-40*2" & set /a "BM=!BW!/2" & for /L %%b in (1,1,20) do echo "cmdgfx: fbox 0 0 00"
	
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 32 echo "cmdgfx: fbox 0 0 00 0,0,!WWW!,!HH!" & set /a MODE+=1&if !MODE! gtr 2 set MODE=0
	if !KEY! == 13 set TMP=!fromto!& set fromto=& if "!TMP!"=="" set fromto=from
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
echo "cmdgfx: quit"
title input:Q
