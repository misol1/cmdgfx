@echo off
:REP
cmdgfx.exe "" pM
set RET=%errorlevel%
set /a "KEY=%RET%>>22, NKD=(%RET%>>21) & 1"
if not "%KEY%" == "0" echo %KEY% %NKD%
if not "%KEY%" == "27" goto REP
set KEY=&set NKD=&set RET=
