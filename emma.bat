@set FNAME=emma&if not "%~1"=="" set FNAME=%~1
@echo cls&gotoxy_extended 0 0 img\%FNAME%.txt 12 0 F&testlib.exe %2 %3
@set FNAME=