@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 0 & cls & cmdwiz showcursor 0
set /a W=220, H=110
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=0, MODE=1
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.6665

set /a S1=100, S2=5, S3=80

set FN=tri.obj
echo usemtl cmdblock 0 0 70 70>%FN%
echo v  -50 -50 0 >>%FN%
echo v   50 -50 0 >>%FN%
echo v   50  50 0 >>%FN%
echo v  -50  50 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo vt 1 0 >>%FN%
echo f 1/1/ 2/2/ 3/3/ 4/4/ >>%FN%

set /a A1=155, A2=0, A3=0, CNT=0
set /a TRANSP=1, TV=20, TRANSP2=1, TV2=20, CENT=1000

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a A1+=1, A2+=2, A3-=1, TRZ=!CRZ!, TRZ2+=4
	if !MODE!==0 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,4000,%ASPECT% 1 0 db"
	if !MODE!==1 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t6.obj 5,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,4000,%ASPECT% 1 0 db 9 0 db 2 0 db a 0 db 3 0 db b 0 db 4 0 db c 0 db 5 0 db d 0 db 6 0 db e 0 db"
	if !MODE!==2 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\spaceship.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 410,410,410,0,0,0 1,0,0,10 35,35,!DIST!,%ASPECT% 1 0 db"
	if !MODE!==3 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t-checkers.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==4 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\hulk.obj %DRAWMODE%,-1 !A1!,!A2!,!A3! 0,0,0 210,210,210,0,-2,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==5 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==6 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==7 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 1 0 db"

	set OUTP="!OUTP:~1,-1! &  3d %FN% 0,-1 0,0,0 0,0,0 1,1,1,0,0,0 0,0,0,10 0,0,9000,2 0 0 db & fbox 9 0 20 0,0,%W%,%H%"
	
	for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! &  3d %FN% %DRAWMODE%,!TV2! 0:0,0:0,!TRZ2!:!TRZ! 0,!CENT!,0 20,20,20,0,0,0 0,0,0,10 %XMID%,%YMID%,7000,%ASPECT% 0 0 db"&set /A TRZ+=%S3%*4
	
	start /B /High cmdgfx_gdi "!OUTP:~1,-1! & text 7 0 0 SPACE_ENTER_t_A/a 99,108" f0:0,0,%W%,%H%
	cmdgfx "" knW12
	set KEY=!ERRORLEVEL!

	set /a CRZ+=3, CNT+=1

	if !CNT! gtr 1307 set /a A3+=1
	if !CNT! gtr 1400 set /a CNT=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 100 set /A DIST+=50
	if !KEY! == 68 set /A DIST-=50
	if !KEY! == 97 set /A CENT-=50
	if !KEY! == 65 set /A CENT+=50
	if !KEY! == 13 set /A TRANSP=1-!TRANSP!&(if !TRANSP!==1 set /a TV=20)&(if !TRANSP!==0 set /a TV=-1)
	if !KEY! == 116 set /A TRANSP2=1-!TRANSP2!&(if !TRANSP2!==1 set /a TV2=20)&(if !TRANSP2!==0 set /a TV2=-1)
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 7 set MODE=0
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
bg font 6 & cmdwiz showcursor 1 & mode 80,50
del /Q tri.obj
