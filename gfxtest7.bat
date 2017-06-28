@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls
set /a W=80, H=50
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="& set /A SHR=13

set /a SC1=45, CC1=SC1+90, SC2=CC1, CC2=SC2+90, SC3=CC2, CC3=SC3+90, SC4=CC3, CC4=SC4+90

set /a XMID=%W%/2, YMID=%H%/2
set /a SD=0, ROTSPEED=3, DISTMUL=8
set /a FNT=6

:REP
	set /a "XMUL=35+(%SINE(x):x=!SD!*31416/180%*!DISTMUL!>>%SHR%), YMUL=25+(%SINE(x):x=!SD!*31416/180%*!DISTMUL!>>%SHR%)"
	
	for /l %%a in (1,1,4) do set /a SV=!SC%%a!, CV=!CC%%a!& set /a "XPOS%%a=%XMID%+(%SINE(x):x=!SV!*31416/180%*!XMUL!>>%SHR%), YPOS%%a=%YMID%+(%SINE(x):x=!CV!*31416/180%*!YMUL!>>%SHR%)"
	
	cmdgfx_gdi "fbox 9 0 . 0,0,79,49 & gpoly 00db.01b2.01b1.01b0.11db.12b2.12b1.12b0.22db.23b2.23b1.23b0.33db.34b2.34b1.34b0.44db.45b2.45b1.45b0.55db.56b2.56b1.56b0.66db.67b2.67b1.67b0.77db.78b2.78b1.78b0 %XPOS1%,%YPOS1%,0, %XPOS2%,%YPOS2%,16, %XPOS3%,%YPOS3%,32, %XPOS4%,%YPOS4%,16 & text a 0 0 Left/right_changes_font(!FNT!) 53,48" kf!FNT! 00000f,080820,101030,181840,202050,282860,303070,383880,404090,80a090,ff9988 00200f 
	set KEY=%ERRORLEVEL%
	
	set /a SC1+=%ROTSPEED%, CC1+=%ROTSPEED%, SC2+=%ROTSPEED%, CC2+=%ROTSPEED%, SC3+=%ROTSPEED%, CC3+=%ROTSPEED%, SC4+=%ROTSPEED%, CC4+=%ROTSPEED%, SD+=3
	
	if %KEY% == 112 cmdwiz getch
	if %KEY% == 333 cmdgfx_gdi "fbox 7 0 20 0,0,80,50" f6&set /a FNT+=1&if !FNT! gtr 9 set FNT=0
	if %KEY% == 331 cmdgfx_gdi "fbox 7 0 20 0,0,80,50" f6&set /a FNT-=1&if !FNT! lss 0 set FNT=9
if not %KEY% == 27 goto REP

endlocal
cmdgfx "fbox 1 0 . 0,0,200,200"
cmdgfx "fbox 7 0 20 0,0,200,200"
