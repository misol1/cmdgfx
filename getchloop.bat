@echo off
:LAB
cmdwiz getch
set KEY=%ERRORLEVEL%
if not "%KEY%" == "0" echo %KEY%
if "%KEY%" == "27" goto OUT
goto LAB
:OUT
set KEY=
