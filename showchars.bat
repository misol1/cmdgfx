@echo off
setlocal ENABLEDELAYEDEXPANSION
cls
mode 80,50
set UT=&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set UT=!UT!%%a\g20\g20\g20\g20
cmdgfx "text 9 0 0 %UT%\n\n 3,0" p
set UT=&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set UT=!UT!%%a\n\n
cmdgfx "text 9 0 0 %UT%\n\n 0,2" p
set UT=&set D2H=0123456789abcdef
for /L %%a in (0,1,255) do set /a HB=%%a/16, LB=%%a%%16 & for %%b in (!HB!) do for %%c in (!LB!) do set HEXV=!D2H:~%%b,1!!D2H:~%%c,1!&set UT=!UT!\g!HEXV!\g20\g20\g20\g20& set /a DIV=(%%a+1)%%16 & if !DIV!==0 set UT=!UT!\n\n
cmdgfx "text 15 0 0 %UT% 3,2" p
set UT=&for %%a in (1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,f) do set UT=!UT!\gdb\g20\g20\g20\g20\%%a0
cmdgfx "text 0 0 0 %UT% 3,34" p
cmdwiz setcursorpos 0 36
cmdwiz getch
endlocal
