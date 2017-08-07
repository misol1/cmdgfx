@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls
set /a W=80, H=50
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat
call sindef.bat

set /a SC=0, CC=180
set /a SC2=50, SC3=350
set /a XMID=%W%/2, YMID=%H%/2
set /a XMUL=21, YMUL=13

:REP
	set /a "XPOS=%XMID%-8+(%SINE(x):x=!SC!/2*31416/180%*!XMUL!>>%SHR%)"
	set /a "YPOS=%YMID%-7+(%SINE(x):x=!CC!/2*31416/180%*!YMUL!>>%SHR%)"
	set /a "XPOS2=%XMID%-4+(%SINE(x):x=!SC2!/2*31416/180%*!XMUL!>>%SHR%)"
	set /a "YPOS3=%YMID%-4+(%SINE(x):x=!SC3!/2*31416/180%*!YMUL!>>%SHR%)"
	cmdgfx "fellipse 0 b b0 40,25,40,30 & fellipse 0 0 b0 40,25,35,25 & ellipse 5 0 03 40,25,%XPOS2%,%YPOS3% & line f 4 : %XPOS2%,40,%XPOS%,%YPOS% & ipoly 6 0 # 0  50,37,80,37,55,49,65,30,75,49 & poly 0 1 20 %XPOS%,20,50,%YPOS%,%XPOS2%,10" k
	set /a SC+=6, CC+=6, SC2+=5, SC3+=3
if not %ERRORLEVEL% == 27 goto REP

endlocal
cls
