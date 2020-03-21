@set FNAME=emma&if not "%~1"=="" set FNAME=%~1
@mode 80,50
title n/N=obj, o=mode, d/D, U=skel, ^^X,Y,Z/xXyYzZ/qQwW=reset/rot/move, b=logo, s/S=bg
@echo cls&cmdgfx "image img\%FNAME%.txt 12 0 0 -1 0,0" & testlib.exe %2 %3
@set FNAME=
