@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls
set /a W=80, H=50
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call sindef.bat

set /a SC1=45, CC1=SC1+90, SC2=CC1, CC2=SC2+90, SC3=CC2, CC3=SC3+90, SC4=CC3, CC4=SC4+90

set /a XMID=%W%/2&set /a YMID=%H%/2
set /a SD=0, ROTSPEED=4, DISTMUL=528
set /a REPATT=15
set I1_0=img/dos_shade.pcx 0 0 db -1&set I2_0=img/mario1.gxy 0 0 0 -1&set I3_0=gfxtest3.bat e 0 0 -1
set I1_1=img/dos_shade.pcx 0 0 db 0&set I2_1=img/mario1.gxy 0 0 0 0&set I3_1=gfxtest3.bat e 0 0 10
set /a IMG=1, TR=0
set RENDERER=&set /a REND=1

:REP
	set /a "XMUL=698+(%SINE(x):x=!SD!*31416/180%*!DISTMUL!>>%SHR%), YMUL=698+(%SINE(x):x=!SD!*31416/180%*!DISTMUL!>>%SHR%)"
	
	for /l %%a in (1,1,4) do set /a SV=!SC%%a!, CV=!CC%%a!& set /a "XPOS%%a=%XMID%+(%SINE(x):x=!SV!*31416/180%*!XMUL!>>%SHR%), YPOS%%a=%YMID%+(%SINE(x):x=!CV!*31416/180%*!YMUL!>>%SHR%)"
	
	cmdgfx!RENDERER! "fbox 8 0 . 0,0,79,49 & tpoly !I%IMG%_%TR%! %XPOS1%,%YPOS1%,0,0, %XPOS2%,%YPOS2%,%REPATT%,0, %XPOS3%,%YPOS3%,%REPATT%,%REPATT%, %XPOS4%,%YPOS4%,0,%REPATT% & text 7 0 0 SPACE_RETURN_n_r_p 1,48" k
	
	set /a SC1+=%ROTSPEED%, CC1+=%ROTSPEED%, SC2+=%ROTSPEED%, CC2+=%ROTSPEED%, SC3+=%ROTSPEED%, CC3+=%ROTSPEED%, SC4+=%ROTSPEED%, CC4+=%ROTSPEED%, SD+=4
	
	if %ERRORLEVEL% == 110 set /a REPATT+=1&if !REPATT! gtr 16 set REPATT=1
	if %ERRORLEVEL% == 112 cmdwiz getch
	if %ERRORLEVEL% == 32 set /a IMG+=1&if !IMG! gtr 3 set IMG=1
	if %ERRORLEVEL% == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
	if %ERRORLEVEL% == 13 set /a TR=1-%TR%
if not %ERRORLEVEL% == 27 goto REP

endlocal
cls
