@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls
set /a W=80, H=50
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call sindef.bat

set /a SC1=45, CC1=SC1+90, SC2=CC1, CC2=SC2+90, SC3=CC2, CC3=SC3+90, SC4=CC3, CC4=SC4+90

set /a XMID=%W%/2, YMID=%H%/2
set /a SD=0, ROTSPEED=4, DISTMUL=8

:REP
	set /a "XMUL=35+(%SINE(x):x=!SD!*31416/180%*!DISTMUL!>>%SHR%), YMUL=25+(%SINE(x):x=!SD!*31416/180%*!DISTMUL!>>%SHR%)"
	
	for /l %%a in (1,1,4) do set /a SV=!SC%%a!, CV=!CC%%a!& set /a "XPOS%%a=%XMID%+(%SINE(x):x=!SV!*31416/180%*!XMUL!>>%SHR%), YPOS%%a=%YMID%+(%SINE(x):x=!CV!*31416/180%*!YMUL!>>%SHR%)"
	
	cmdgfx "fbox 8 0 . 0,0,79,49 & tpoly img\dos_shade.pcx 0 0 db -1 %XPOS1%,%YPOS1%,0,0, %XPOS2%,%YPOS2%,1,0, %XPOS3%,%YPOS3%,1,1, %XPOS4%,%YPOS4%,0,1 " k
	
	set /a SC1+=%ROTSPEED%, CC1+=%ROTSPEED%, SC2+=%ROTSPEED%, CC2+=%ROTSPEED%, SC3+=%ROTSPEED%, CC3+=%ROTSPEED%, SC4+=%ROTSPEED%, CC4+=%ROTSPEED%, SD+=4
	
	if %ERRORLEVEL% == 112 cmdwiz getch
if not %ERRORLEVEL% == 27 goto REP

endlocal
cls
