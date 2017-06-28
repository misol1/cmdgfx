@echo off
setlocal EnableDelayedExpansion
set OLMB=0
bg font 2
set /a SCRW=120 & set /a SCRWW=!SCRW!*2
mode %SCRW%,70
cmdwiz setbuffersize %SCRWW% k
color 07
cls

set /a XP=7, YP=4, BUTTONWIDTH=38, ACCBW=0, CHAR=0, OFFCOL=9

set /a PX1=0+%XP%+%ACCBW%,PY1=0+%YP%,PX2=30,PY2=20, LX=11+%XP%+%ACCBW%,LY=10+%YP%, ACCBW+=%BUTTONWIDTH%, CHAR+=1
set B1="fbox 0 1 20 %PX1%,%PY1%,%PX2%,%PY2% & text 7 1 0 PICK_ME %LX%,%LY%"
set B1H="fbox 0 9 20 %PX1%,%PY1%,%PX2%,%PY2% & text f 9 0 YES_YES %LX%,%LY%"
set B1P="fbox 0 a 20 %PX1%,%PY1%,%PX2%,%PY2% & text f a 0 ALRIGHT %LX%,%LY%"
set /a PX1+=%SCRW%
set B1OFF="fbox %OFFCOL% 0 0%CHAR% %PX1%,%PY1%,%PX2%,%PY2%"

set /a PX1=15+%XP%+%ACCBW%,PY1=10+%YP%,PX2=15,PY2=10, LX=11+%XP%+%ACCBW%,LY=10+%YP%, ACCBW+=%BUTTONWIDTH%, CHAR+=1
set B2="ellipse 0 0 x %PX1%,%PY1%,%PX2%,%PY2% & fellipse 0 1 20 %PX1%,%PY1%,%PX2%,%PY2% & text 7 1 0 Option_2 %LX%,%LY%"
set B2H="fellipse 0 1 20 %PX1%,%PY1%,%PX2%,%PY2% & ellipse 9 0 db %PX1%,%PY1%,%PX2%,%PY2% & text f 1 0 Option_2 %LX%,%LY%"
set B2P="ellipse 0 0 x %PX1%,%PY1%,%PX2%,%PY2% & fellipse 0 a 20 %PX1%,%PY1%,%PX2%,%PY2% & text f a 0 Option_2 %LX%,%LY%"
set /a PX1+=%SCRW%
set B2OFF="fellipse %OFFCOL% 0 0%CHAR% %PX1%,%PY1%,%PX2%,%PY2%"

set /a PX1=15+%XP%+%ACCBW%,PY1=0+%YP%,PX2=0+%XP%+%ACCBW%,PY2=22+%YP%,PX3=30+%XP%+%ACCBW%,PY3=22+%YP%, LX=11+%XP%+%ACCBW%,LY=13+%YP%, ACCBW+=%BUTTONWIDTH%, CHAR+=1
set B3="poly 0 1 20 %PX1%,%PY1%,%PX2%,%PY2%,%PX3%,%PY3% & text 7 1 0 Option_3 %LX%,%LY%"
set B3H="poly 0 9 - %PX1%,%PY1%,%PX2%,%PY2%,%PX3%,%PY3% & text f 9 0 Option_3 %LX%,%LY%"
set B3P="poly 0 a 20 %PX1%,%PY1%,%PX2%,%PY2%,%PX3%,%PY3% & text f a 0 Option_3 %LX%,%LY%"
set /a PX1+=%SCRW%,PX2+=%SCRW%,PX3+=%SCRW%
set B3OFF="poly %OFFCOL% 0 0%CHAR% %PX1%,%PY1%,%PX2%,%PY2%,%PX3%,%PY3%"

call :PROCESS_HOVER_BUTTONS 3 %SCRW% RESULT

echo %RESULT%

endlocal
goto :eof


:PROCESS_HOVER_BUTTONS <nofButtons> <screenWidth> <returnValue>
if "%~3" == "" echo Insufficient parameters & goto :eof
cmdwiz getquickedit & set /a QE=!errorlevel!
cmdwiz setquickedit 0
cmdwiz showcursor 0
set /a NOFB=%1, SCRW=%2, HOVERINDEX=32, MX=-100, MY=-100

set OUTP=""
for /L %%a in (1,1,%NOFB%) do set OUTP="!OUTP:~1,-1! & !B%%aOFF:~1,-1! & !B%%a:~1,-1!"
cmdgfx %OUTP% p

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
   cmdwiz getch_and_mouse>mouse_out.txt

   for /F "tokens=1,3,5,7,9,11,13 delims= " %%a in (mouse_out.txt) do set EVENT=%%a&set KEY=%%b&set MOUSE_EVENT=%%c&set NEW_MX=%%d&set NEW_MY=%%e&set LMB=%%f

   if "!MOUSE_EVENT!"=="1" ( 
      set /a OR=0& (if !NEW_MX! neq !MX! set OR=1) & (if !NEW_MY! neq !MY! set OR=1) & if !OR!==1 (

         set /a CHKX=!NEW_MX!+%SCRW%
         cmdwiz getcharat !CHKX! !NEW_MY!
         set /a CHKCHAR=!errorlevel!

         if !CHKCHAR! geq 1 if !CHKCHAR! neq !HOVERINDEX! (
            if !CHKCHAR! leq %NOFB% for %%a in (!CHKCHAR!) do cmdgfx !B%%aH! p
            if !HOVERINDEX! leq %NOFB% for %%a in (!HOVERINDEX!) do cmdgfx !B%%a! p
            set /a HOVERINDEX=!CHKCHAR!
         )

         set /a MX=!NEW_MX!, MY=!NEW_MY!
      )

      if !LMB! == 1 if !OLMB! == 0 if !HOVERINDEX! leq %NOFB% (
         for %%a in (!HOVERINDEX!) do set OUTP=!B%%aP!
         cmdgfx !OUTP! p
         set /a STOP=1, %3=!HOVERINDEX!
      )
   )
   set OLMB=!LMB!

   if !KEY! geq 49 if !KEY! leq 57 (
      set /a KCHOICE=!KEY!-48
      if !KCHOICE! leq %NOFB% (
         for %%a in (!KCHOICE!) do set OUTP=!B%%aP!
         cmdgfx !OUTP! p
         set /a STOP=1, %3=!KCHOICE!
      )
   )

   if !KEY! == 27 set /a STOP=1, %3=0
)
if not defined STOP goto LOOP

del /Q mouse_out.txt>nul
cmdwiz setquickedit %QE%
cmdwiz showcursor 1