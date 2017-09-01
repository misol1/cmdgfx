@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
bg font 2 & cls & cmdwiz showcursor 0
set /a W=120, H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=1

set FN=tri.obj
echo usemtl img\mario1.gxy >%FN%
rem echo usemtl cmdblock %W% 0 40 40 >%FN%
echo v  0 0 0 >>%FN%
echo v  0 100 0 >>%FN%
echo v  66 100 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo f 1/1/ 2/2/ 3/3/ >>%FN%

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a TRZ=!CRZ!
	set OUTP="fbox 7 0 20 0,0,%W%,%H%"
	for /L %%1 in (1,1,12) do set OUTP="!OUTP:~1,-1! & 3d %FN% %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 10,10,10,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 db"&set /A TRZ+=30*4
	
	cmdgfx_gdi !OUTP! f2k
	set KEY=!ERRORLEVEL!

	set /a CRZ+=5

	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
bg font 6 & cmdwiz showcursor 1 & mode 80,50
del /Q tri.obj
