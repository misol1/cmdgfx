@echo off
bg font 0 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" kOSf0:0,0,220,110W10
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
rem start "" /B dlc.exe -p "Cari Lekebusch_ - Obscurus Sanctus.mp3">nul
set /a W=220, H=110
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
del /Q EL.dat >nul 2>nul

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=0, MODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.6665

set /a S1=66, S2=12, S3=30
if "%~1" == "1" set /a S1=33, S2=24, S3=15
if "%~1" == "2" set /a S1=100, S2=8, S3=45
if "%~1" == "3" set /a S1=25, S2=30, S3=12

set FN=tri.obj
echo usemtl cmdblock 0 0 70 70 >%FN%
echo v  0 0 0 >>%FN%
echo v  0 100 0 >>%FN%
echo v  %S1% 100 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo f 1/1/ 2/2/ 3/3/ >>%FN%

set /a A1=155, A2=0, A3=0, CNT=0
set /a TRANSP=0, TV=-1
set /a MONO=0 & set MONS=

set /a LIGHT=0, LTIME=990

set /a MODE=1, TV=20, TRANSP=1

set /a CS=0,CCNT=0,C0=8,C1=7,CDIV=6,CW=0 & set /a CEND=2*!CDIV! & set C2=f&set C3=f&set C4=f

set STOP=
:LOOP
for /L %%_ in (1,1,300) do if not defined STOP (

	set /a A1+=1, A2+=2, A3-=1, TRZ=!CRZ!
	if !MODE!==0 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,4000,%ASPECT% 1 0 db"
	if !MODE!==1 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t6.obj 5,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,4000,%ASPECT% 1 0 db 9 0 db 2 0 db a 0 db 3 0 db b 0 db 4 0 db c 0 db 5 0 db d 0 db 6 0 db e 0 db"
	if !MODE!==2 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\spaceship.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 410,410,410,0,0,0 1,0,0,10 35,35,!DIST!,%ASPECT% 1 0 db"
	if !MODE!==3 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t-checkers.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==4 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\hulk.obj %DRAWMODE%,-1 !A1!,!A2!,!A3! 0,0,0 210,210,210,0,-2,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==5 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==6 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==7 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 1 0 db"

	for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! & 3d %FN% 1,-1 0,0,!TRZ! 0,0,0 20,20,20,0,0,0 0,0,0,10 %XMID%,%YMID%,7000,%ASPECT% 0 0 db & 3d %FN% %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 20,20,20,0,0,0 0,0,0,10 %XMID%,%YMID%,7000,%ASPECT% 0 0 db"&set /A TRZ+=%S3%*4
	
	echo "cmdgfx: !OUTP:~1,-1! & !MONS! & !FADE! & text 7 0 0 [FRAMECOUNT] 103,108"
	set OUTP=

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	set /a CRZ+=3, CNT+=1

	if !CS! gtr 0 (
		set /a CP=!CCNT!/%CDIV%,CCP=!CCNT!/%CDIV%+2 & for %%a in (!CP!) do for %%b in (!CCP!) do set FADE=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=!C%%b!!C%%a!??
		if !CS!==2 set /a CCNT-=1&if !CCNT! lss 0 set /a CS=0&set FADE=
		if !CS!==1 set /a CCNT+=1&if !CCNT! gtr %CEND% set /a CCNT=%CEND%,CW+=1
		if !CW! gtr 35 set /a CW=0,CS=2,KEY=32
	)
	
	if !LIGHT! == 1 for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq %LTIME% set /a KEY=109 & set t1=!time: =0!
	if !KEY! == 115 set /A LIGHT=1-!LIGHT! & if !LIGHT! == 1 set /a KEY=109 & set t1=!time: =0!
	
	if !CNT! gtr 1307 set /a A3+=1
	if !CNT! gtr 1400 set /a CNT=0
	if !KEY! == 112 cmdwiz getch & set /a CKEY=!errorlevel! & if !CKEY! == 115 echo "cmdgfx: " c:0,0,%W%,%H%
	if !KEY! == 102 if !CS!==0 set /a CS=1,CCNT=0
	if !KEY! == 100 set /A DIST+=50
	if !KEY! == 68 set /A DIST-=50
	if !KEY! == 13 set /A TRANSP=1-!TRANSP!&(if !TRANSP!==1 set /a TV=20)&(if !TRANSP!==0 set /a TV=-1)
	if !KEY! == 109 set /A MONO=1-!MONO!&(if !MONO!==1 set MONS=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=fe??)&(if !MONO!==0 set MONS=)
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 7 set MODE=0
	if !KEY! == 27 set STOP=1
	
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
del /Q tri.obj
taskkill.exe /F /IM dlc.exe>nul
echo "cmdgfx: quit"
