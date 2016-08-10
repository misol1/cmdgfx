@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 6 & cls
set W=80&set H=50
mode con lines=%H% cols=%W%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="
call sintable.bat

set SC=0&set CC=180
set SC2=50&set SC3=350
set /a XMID=%W%/2&set /a YMID=%H%/2
set /a XMUL=%W%/3&set /a YMUL=%H%/3

:REP
set /a XPOS=%XMID%-8+(!SIN%SC%!*%XMUL%^>^>14)
set /a YPOS=%YMID%-7+(!SIN%CC%!*%YMUL%^>^>14)
set /a XPOS2=%XMID%-4+(!SIN%SC2%!*%XMUL%^>^>14)
set /a YPOS3=%YMID%-4+(!SIN%SC3%!*18^>^>14)
cmdgfx "fellipse 0 b b0 40,25,40,30 & fellipse 0 0 b0 40,25,35,25 & ellipse 5 0 03 40,25,%XPOS2%,%YPOS3% & line f 4 : %XPOS2%,40,%XPOS%,%YPOS% & ipoly 6 0 # 0  50,37,80,37,55,49,65,30,75,49 & poly 0 1 20 %XPOS%,20,50,%YPOS%,%XPOS2%,10" k
set /a SC+=6 & if !SC! geq 720 set /A SC=!SC!-720
set /a CC+=6 & if !CC! geq 720 set /A CC=!CC!-720
set /a SC2+=5 & if !SC2! geq 720 set /A SC2=!SC2!-720
set /a SC3+=3 & if !SC3! geq 720 set /A SC3=!SC3!-720
if not %ERRORLEVEL% == 27 goto REP

endlocal
cls
