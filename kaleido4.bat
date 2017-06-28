@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 2 & cls & cmdwiz showcursor 0
set /a W=120, H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
set /a W*=8, H*=8

set /a XMID=%W%/2, YMID=%H%/2, DIST=700, DRAWMODE=0, MODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=1

set /a S1=66, S2=12, S3=30
if "%~1" == "1" set /a S1=33, S2=24, S3=15
if "%~1" == "2" set /a S1=100, S2=8, S3=45
if "%~1" == "3" set /a S1=25, S2=30, S3=12

set FN=tri.obj
echo usemtl cmdblock 0 0 300 300 >%FN%
echo v  0 0 0 >>%FN%
echo v  0 100 0 >>%FN%
echo v  %S1% 100 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo f 1/1/ 2/2/ 3/3/ >>%FN%

set /a A1=155, A2=0, A3=0, CNT=0
set /a TRANSP=0, TV=-1

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a A1+=2, A2+=2, A3-=1, TRZ=!CRZ!
	if !MODE!==0 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t-checkers.obj 6,!TV!	!A1!,!A2!,!A3! 0,0,0 -281,-281,-281,0,0,0 1,0,0,10 150,150,!DIST!,%ASPECT% 0 -8 db 0 -2 db  0 0 db 0 0 db  0 -6 db 0 -5 db 0 -6 db 0 -2 db  0 -3 db 0 -1 db  0 -7 db 0 -4 db"
	if !MODE!==1 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\spaceship.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 181,181,181,0,0,0 1,0,0,10 150,150,!DIST!,%ASPECT% 1 0 db"
	if !MODE!==2 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\hulk.obj %DRAWMODE%,-1 !A1!,!A2!,!A3! 0,0,0 161,161,161,0,-2,0 1,0,0,10 150,150,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==3 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 181,181,181,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==4 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 81,81,81,0,0,0 0,0,0,10 85,85,-200,%ASPECT% 1 0 db"
	if !MODE!==5 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 481,481,481,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"

	for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! & 3d %FN% 1,-1 0,0,!TRZ! 0,0,0 90,90,90,0,0,0 0,0,0,10 %XMID%,%YMID%,7000,%ASPECT% 0 0 db & 3d %FN% %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 90,90,90,0,0,0 0,0,0,10 %XMID%,%YMID%,7000,%ASPECT% 0 0 db"&set /A TRZ+=%S3%*4
	
	start /B /High cmdgfx_gdi !OUTP! fa:0,0,%W%,%H%
	cmdgfx "" knW12
	set KEY=!ERRORLEVEL!

	set /a CRZ+=4, CNT+=1

	if !CNT! gtr 1307 set /a A3+=1
	if !CNT! gtr 1400 set /a CNT=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 100 set /A DIST+=50
	if !KEY! == 68 set /A DIST-=50
	if !KEY! == 13 set /A TRANSP=1-!TRANSP!&(if !TRANSP!==1 set /a TV=20)&(if !TRANSP!==0 set /a TV=-1)
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 5 set MODE=0
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
bg font 6 & cmdwiz showcursor 1 & mode 80,50
del /Q tri.obj
