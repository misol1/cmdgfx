@echo off
setlocal
if "%~1" == "" echo Usage: showgxy file [x] [y] [xflip] [yflip] [w h] & cmdwiz getch & goto :eof
if not exist "%~1" echo Error: File not found. & goto :eof
set /a X=0, Y=0, XF=0, YF=0, W=-1, H=-1, COND=0
if not "%~2" == "" set /a X=%~2
if not "%~3" == "" set /a Y=%~3
if not "%~4" == "" set /a XF=%~4
if not "%~5" == "" set /a YF=%~5
if not "%~6" == "" set /a W=%~6
if not "%~7" == "" set /a H=%~7

if %W% gtr 0 set /a COND+=1
if %H% gtr 0 set /a COND+=1
if %COND% == 2 cmdgfx "image %~1 7 0 0 -1 %X%,%Y% %XF% %YF% %W%,%H%" p
if %COND% lss 2 cmdgfx "image %~1 7 0 0 -1 %X%,%Y% %XF% %YF%" p
endlocal
