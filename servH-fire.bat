@echo off
set /a W=80, WW=W*2
cmdwiz setfont 2 & mode %W%,75 & title Fire
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW14x | call %0 %* | cmdgfx_gdi "" Sf2:0,0,%WW%,130,%W%,75
set __=
set W=&set WW=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION

call centerwindow.bat 0 -10
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="WW" set "%%v="
echo "cmdgfx: fbox f 0 30 0,0,%WW%,130 & fbox f 0 20 0,0,%WW%,120 & fbox e 0 20 %W%,0,%W%,95"
set OUT=""&(for /L %%a in (1,1,75) do set /a "X=!RANDOM! %% %W%+%W%,FG=!RANDOM! %% 6+10" & set OUT="!OUT:~1,-1! & pixel !FG! 0 30 !X!,126")&echo "cmdgfx: !OUT:~1,-1!"
set STREAM="1060=40++,1061=40++,1062=40++,1063=40++,1064=d0++,1065=d0++,1066=c0++,1067=a0++,1050=c0++,1051=90++,1052=a0++,1053=a0++,1054=a0++,1055=80++,1056=80++,1057=70++,1030=f0++,1031=f0++,1032=f0++,1033=f0++,1034=f0++,1035=f0++,1036=f0++,1037=f0++,1038=f0++,1039=f0++,?0??=-0??"

set TRANSF0="??50=fedb,??51=feb1,??52=ecdb,??53=ecb1,??54=c4db,??55=c4b1,??56=c4b0,??57=40b1,??58=4020,??60=feb2,??61=feb0,??62=ecb2,??63=ecb0,??64=c4db,??65=c4b2,??66=c4b0,??67=40b2,??68=40b0,00b0=4025,??30=ffdb,??31=ffb1,??32=feb2,??33=ecb0,??34=c4b0,??35=c0b1,??36=c0b0,??37=40b2,??38=40b1,??39=4025,??40=4020"
set TRANSF1="??50=fbdb,??51=fbb1,??52=b9db,??53=b9b1,??54=91db,??55=91b1,??56=10db,??57=10b0,??58=1020,??60=fbdb,??61=fbb1,??62=fbb0,??63=b9b2,??64=b9b0,??65=91b2,??66=91b0,??67=10b2,??68=10b0,00b0=10b0,??30=ffdb,??31=ffb1,??32=fbb2,??33=b9b2,??34=90b2,??35=90b1,??36=90b0,??37=10b2,??38=10b1,??39=10b0,??10=4020"

set /A PW=1,COL=0, MODE=0

set /a SHOWHELP=1
set HELPMSG=text e 0 0 SPACE/f/h 1,73
if !SHOWHELP!==1 set MSG=%HELPMSG%

set /a "PWP=(!PW!+1)*3"
set /a "nf1=15-!PW!*5"
set /a "nf2=40-!PW!*10"
set /a "MOD=!PWP!-!PW!"
set /a "MOD2=!MOD!/2"

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COL!) do (

	for /L %%a in (0,1,%nf1%) do set /a "X=!RANDOM! %% %W%+%W%,J=!RANDOM! %% 50+74, J2=J+!RANDOM! %% %MOD%,X2=X+!RANDOM! %% %MOD%-!MOD2!"&echo "cmdgfx: line e 0 50 !X!,!J!,!X2!,!J2!" n
	for /L %%a in (0,1,%nf2%) do set /a "X=!RANDOM! %% %W%+%W%,J=!RANDOM! %% 50+74"&set /a "J2=!J!+!RANDOM! %% %MOD%,X2=!X!+!RANDOM! %% %MOD%-!MOD2!"&echo "cmdgfx: line e 0 60 !X!,!J!,!X2!,!J2!" n

	echo "cmdgfx: block 0 %W%,1,%W%,125 %W%,0 -1 0 0 !STREAM:~1,-1! & block 0 %W%,0,%W%,130 0,-2 -1 0 0 !TRANSF%%c:~1,-1! & !MSG!"

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul )
	
	if !KEY! == 102 set /a "LXP1=%W%+(%W%-62)/2, LXP2=LXP1-1, LXP3=LXP1+1" & echo "cmdgfx: image img\fire.txt f 0 0 20 !LXP2!,79 & image img\fire.txt f 0 0 20 !LXP3!,79 & image img\fire.txt f 0 0 20 !LXP1!,78 & image img\fire.txt f 0 0 20 !LXP1!,80 & image img\fire.txt f 0 0 20 !LXP1!,79" n
	if !KEY! == 32 set /A COL+=1&if !COL! gtr 1 set COL=0
	if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
	
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
echo "cmdgfx: quit"
title input:Q
