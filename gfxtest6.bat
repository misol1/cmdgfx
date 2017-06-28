@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls
set /a W=80, H=50
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="& set /A SHR=13

set /a SC1=45, CC1=SC1+90, SC2=CC1, CC2=SC2+90, SC3=CC2, CC3=SC3+90, SC4=CC3, CC4=SC4+90

set /a XMID=%W%/2, YMID=%H%/2
set /a SD=0, ROTSPEED=3, DISTMUL=8
set /a COL2=10 & set COL2C=a
set /a COL1=15 & set COL1C=f

:REP
	set /a "XMUL=35+(%SINE(x):x=!SD!*31416/180%*!DISTMUL!>>%SHR%), YMUL=25+(%SINE(x):x=!SD!*31416/180%*!DISTMUL!>>%SHR%)"
	
	for /l %%a in (1,1,4) do set /a SV=!SC%%a!, CV=!CC%%a!& set /a "XPOS%%a=%XMID%+(%SINE(x):x=!SV!*31416/180%*!XMUL!>>%SHR%), YPOS%%a=%YMID%+(%SINE(x):x=!CV!*31416/180%*!YMUL!>>%SHR%)"
	
	cmdgfx "fbox 8 0 . 0,0,79,49 & gpoly %COL1C%%COL2C%db.%COL1C%%COL2C%b2.%COL1C%%COL2C%b1.%COL1C%%COL2C%b0.%COL1C%%COL2C%b0 %XPOS1%,%YPOS1%,0, %XPOS2%,%YPOS2%,2, %XPOS3%,%YPOS3%,4, %XPOS4%,%YPOS4%,2 & text 7 0 0 SPACE_RETURN 1,48" k
	set /a KEY=%ERRORLEVEL%
	
	set /a SC1+=%ROTSPEED%, CC1+=%ROTSPEED%, SC2+=%ROTSPEED%, CC2+=%ROTSPEED%, SC3+=%ROTSPEED%, CC3+=%ROTSPEED%, SC4+=%ROTSPEED%, CC4+=%ROTSPEED%, SD+=3
	
	if %KEY% == 32 set /A COL2+=1&(if !COL2! == 16 set COL2=0)&set CNT=0&for %%a in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do (if !COL2!==!CNT! set COL2C=%%a)&set /A CNT+=1
	if %KEY% == 13 set /A COL1+=1&(if !COL1! == 16 set COL1=0)&set CNT=0&for %%a in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do (if !COL1!==!CNT! set COL1C=%%a)&set /A CNT+=1
	if %KEY% == 112 cmdwiz getch
if not %KEY% == 27 goto REP

endlocal
cls
