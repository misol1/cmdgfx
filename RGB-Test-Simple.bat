@echo off
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title RGB Test
if defined __ goto :START
set __=.
cmdgfx_input.exe knW12xR | call %0 %* | cmdgfx_RGB "" TSf1:0,0,150,80z
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=150, H=80, F6W=W/2, F6H=H/2
mode %F6W%,%F6H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -18
call prepareScale.bat 1

echo "cmdgfx: fbox ff9944 0 A 2,2,90,60 & " f1:0,0,!W!,!H!

echo "cmdgfx: line 5599ff 0 21 5,4,120,45 "

echo "cmdgfx: line 001133 ff99ff M 5,4,120,45 81,1 "

echo "cmdgfx: box ffdd33 0 db 5,4,120,45 81,1 "

echo "cmdgfx: poly ff7777 660000 ? 5,4,120,45,81,1 "

echo "cmdgfx: poly ? ? 1 5,34,32,45,3,10 "

echo "cmdgfx: image img\mario1.gxy 0 0 0 -1 5,5 "

echo "cmdgfx: image img\persona.txt 00bb88 000044 0 -1 25,25"

echo "cmdgfx: image img\ugly1.pcx 0 0 db e 45,25 "

echo "cmdgfx: ellipse aaffaa 7700cc X 25,34,20,30 "

echo "cmdgfx: ipoly ff00ff 0000ff b1 1 10,10,70,15,60,40"

echo "cmdgfx: fellipse 55ff55 0 H 125,34,10,8 "

echo "cmdgfx: text 55bbff 0 0 _Hey_Mr_Tambourine\-\a0MAN_ 10,8"

echo "cmdgfx: pixel f 4 X 0,0 "

echo "cmdgfx: tpoly img\apa.gxy 0 0 0 -1 3,3,0,0,60,7,1,0,90,40,1,1,10,20,0,1"

rem echo "cmdgfx: piixel f 4 X 110,8 "

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
	
	echo "cmdgfx: skip "
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit" & title input:Q
