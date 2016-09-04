@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 6 & cls
set W=80&set H=50
mode con lines=%H% cols=%W%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
call sintable.bat

set SC=90&set /a CC=!SC!+180
set SC2=270&set /a CC2=!SC2!+180
set SC3=450&set /a CC3=!SC3!+180
set SC4=630&set /a CC4=!SC4!+180&set /A CC4=!CC4!-720
set SD=0

set /a XMID=%W%/2&set /a YMID=%H%/2
set ROTSPEED=8
set REPATT=15
set I1_0=img/dos_shade.pcx 0 0 db -1&set I2_0=img/mario1.gxy 0 0 0 -1&set I3_0=gfxtest3.bat e 0 0 -1
set I1_1=img/dos_shade.pcx 0 0 db 0&set I2_1=img/mario1.gxy 0 0 0 0&set I3_1=gfxtest3.bat e 0 0 10
set IMG=1
set TR=0
set RENDERER=&set REND=1

:REP
set /a "XMUL=698+(!SIN%SD%!*640>>14), YMUL=698+(!SIN%SD%!*640>>14)"
set /a "XPOS=%XMID%+(!SIN%SC%!*%XMUL%>>14), YPOS=%YMID%+(!SIN%CC%!*%YMUL%>>14), XPOS2=%XMID%+(!SIN%SC2%!*%XMUL%>>14), YPOS2=%YMID%+(!SIN%CC2%!*%YMUL%>>14)"
set /a "XPOS3=%XMID%+(!SIN%SC3%!*%XMUL%>>14), YPOS3=%YMID%+(!SIN%CC3%!*%YMUL%>>14), XPOS4=%XMID%+(!SIN%SC4%!*%XMUL%^>^>14), YPOS4=%YMID%+(!SIN%CC4%!*%YMUL%>>14)"
cmdgfx!RENDERER! "fbox 8 0 . 0,0,79,49 & tpoly !I%IMG%_%TR%! %XPOS%,%YPOS%,0,0, %XPOS2%,%YPOS2%,%REPATT%,0, %XPOS3%,%YPOS3%,%REPATT%,%REPATT%, %XPOS4%,%YPOS4%,0,%REPATT% " k
set /a SC+=%ROTSPEED% & if !SC! geq 720 set /A SC=!SC!-720
set /a CC+=%ROTSPEED% & if !CC! geq 720 set /A CC=!CC!-720
set /a SC2+=%ROTSPEED% & if !SC2! geq 720 set /A SC2=!SC2!-720
set /a CC2+=%ROTSPEED% & if !CC2! geq 720 set /A CC2=!CC2!-720
set /a SC3+=%ROTSPEED% & if !SC3! geq 720 set /A SC3=!SC3!-720
set /a CC3+=%ROTSPEED% & if !CC3! geq 720 set /A CC3=!CC3!-720
set /a SC4+=%ROTSPEED% & if !SC4! geq 720 set /A SC4=!SC4!-720
set /a CC4+=%ROTSPEED% & if !CC4! geq 720 set /A CC4=!CC4!-720
set /a SD+=8 & if !SD! geq 720 set /A SD=!SD!-720
if %ERRORLEVEL% == 110 set /a REPATT+=1&if !REPATT! gtr 16 set REPATT=1
if %ERRORLEVEL% == 112 cmdwiz getch
if %ERRORLEVEL% == 32 set /a IMG+=1&if !IMG! gtr 3 set IMG=1
if %ERRORLEVEL% == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
if %ERRORLEVEL% == 13 set /a TR=1-%TR%
if not %ERRORLEVEL% == 27 goto REP

endlocal
cls
