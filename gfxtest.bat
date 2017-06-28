@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls
set /a W=80, H=50
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="& set /A SHR=13

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
