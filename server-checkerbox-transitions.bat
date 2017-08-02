@echo off
bg font 0 & mode 200,110 & cls
cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" kOSf0:0,0,200,110W10
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=200, H=110
if not "%~1" == "" set /a W=120, H=70

call centerwindow.bat 0 -20

mode con rate=31 delay=0
for /f "tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set TEXT=text 7 ? 0 SPACE,_ENTER(cursor),_D/d 1,108
set /a ZP=200, DIST=700, FONT=0, ROTMODE=0, NOFOBJECTS=5, RX=0, RY=0, RZ=0, RZ2=160
set ASPECT=0.605

if not "%~1" == "" set /a W*=4, H*=6, ZP=500, NOFOBJECTS=3 &set TEXT=&set FONT=a&set ASPECT=0.9075

set /a XMID=%W%/2, YMID=%H%/2, OBJINDEX=0
set OBJTEMP=box-temp.obj
set PLANETEMP=plane-temp.obj
call :SETOBJECT
set DELOBJCACHE=
set /a ACTIVE_KEY=0, TRANS=0, DOTRANS=0
set t1=!time: =0!

set /a BLOCKSIZE=10, BLSTRLEN=0
set /A BLW=(%W%-1)/%BLOCKSIZE%
set /A BLH=(%H%-1)/%BLOCKSIZE%
set BLPT=&for /L %%a in (0,1,%BLH%) do for /L %%b in (0,1,%BLW%) do set /A BLXP=10+%%b&set /A BLYP=10+%%a&set BLPT=!BLPT!!BLXP!!BLYP!
set /A BLNOFB=(%BLW%+1)*(%BLH%+1)

set /a SWIPEBLOCKSIZE=8
set /A SWBLW=0
set /A SWBLH=(%H%-1)/%SWIPEBLOCKSIZE%

set /a FADECOL=0, BLCNTORG=%XMID%+%XMID%/2, TDELAY=600
set /a EXPB=3, EXPE=EXPB+11
set /a EXT1=EXPE+1,EXT2=EXPE+2
set OUTFADE=""

set /a SWM=%W%-1, SHM=%H%-1
set FNTMP=objects\tempPlane.obj
echo usemtl cmdblock 0 0 %SWM% %SHM% >%FNTMP%
echo v  -150 -150 0 >>%FNTMP%
echo v   150 -150 0 >>%FNTMP%
echo v   150  150 0 >>%FNTMP%
echo v  -150  150 0 >>%FNTMP%
echo vt 0 0 >>%FNTMP%
echo vt 1 0 >>%FNTMP%
echo vt 1 1 >>%FNTMP%
echo vt 0 1 >>%FNTMP%
echo f 1/1/ 2/2/ 3/3/ 4/4/ >>%FNTMP%
set /A BLDIST=1550,BLMODE=0
set /a BLRX=0,BLRY=0,BLRZ=0
set /a BLTX=0,BLTY=0,BLTZ=0
del /Q EL.dat >nul 2>nul

:REP
for /L %%1 in (1,1,300) do if not defined STOP (

	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000"
	if !a! geq 1100 if !DOTRANS! == 0 set /a DOTRANS=1, REV=0, BLCNT=%BLCNTORG%, SWBLW=0
	
	if !DOTRANS! == 1 (

		if !TRANS! == 0 (
			if !SWBLW! gtr %W% set /a REV=1 & cmdwiz delay %TDELAY%
			if !SWBLW! lss 0 set /a DOTRANS=0
			set OUTFADE=""&(for /L %%a in (0,1,%SWBLH%) do set /a "BLX=%W%-!SWBLW!,BLY=%%a*%SWIPEBLOCKSIZE%,ISEVEN=%%a %% 2"&(if !ISEVEN!==0 set /a BLX=0)&set OUTFADE="!OUTFADE:~1,-1!&fbox %FADECOL% 0 db !BLX!,!BLY!,!SWBLW!,%SWIPEBLOCKSIZE%")& (if !REV!==0 set /a SWBLW+=1)& (if !REV!==1 set /a SWBLW-=1)
		)

		if !TRANS! == 1 (
			if !BLNOFB! lss 0 if !REV! == 0 set /a REV=1 & cmdwiz delay %TDELAY%
			if !REV! == 0 if !BLNOFB! geq 0 set /A "CP=(!RANDOM! %% !BLNOFB!)*4" & for %%b in (!CP!) do set CBX=!BLPT:~%%b,2!& set /A CPY=!CP!+2 & for %%c in (!CPY!) do set CBY=!BLPT:~%%c,2!&set /A CPQ=!CP!+4 & set /a "CBX=(!CBX!-10)*%BLOCKSIZE%"& set /a "CBY=(!CBY!-10)*%BLOCKSIZE%" & set OUTTMP=fbox %FADECOL% 0 db !CBX!,!CBY!,%BLOCKSIZE%,%BLOCKSIZE%          & set OUTFADE="!OUTFADE:~1,-1!&!OUTTMP:~0,26!"& for %%d in (!CPQ!) do set BLPT=!BLPT:~0,%%b!!BLPT:~%%d!& set /A BLNOFB-=1, BLSTRLEN+=27
			if !REV! == 1 set /a BLSTRLEN-=27 & for %%a in (!BLSTRLEN!) do set OUTFADE="!OUTFADE:~1,%%a!"
			if !BLSTRLEN! lss 0 set /a DOTRANS=0
		)
		
		if !TRANS! == 2 (
			if !BLDIST! gtr 6400 set /a REV=1 & cmdwiz delay %TDELAY%
			if !BLDIST! lss 1550 set /a DOTRANS=0

			set OUTFADE="&3d %FNTMP% 0,-1 0,0,0 0,0,0 1,1,1,5000,0,0 0,0,0,10 0,0,99999,1 0 0 db & fbox 0 0 db 0,0,%W%,%H% & 3d %FNTMP% 5,-1 !BLRX!,!BLRY!,!BLRZ! !BLTX!,!BLTY!,!BLTZ! 5.2,4,4,0,0,0 0,0,0,10 %XMID%,%YMID%,!BLDIST!,0.7 0 0 db "
			
			if !REV! == 0 set /a BLDIST+=30,BLRX+=13,BLRY+=3,BLRZ+=0 & if !BLDIST! gtr 2000 set /a BLTXP+=1&set /a BLTX-=!BLTXP!/2
			if !REV! == 1 set /a BLDIST-=30,BLRX-=13,BLRY-=3,BLRZ+=0 & if !BLTXP! gtr 0 set /a BLTX+=!BLTXP!/2&set /a BLTXP-=1
		)
		
		if !TRANS! geq !EXPB! if !TRANS! leq !EXPE! (
			set /a TI=!TRANS!-!EXPB!, REVLIM=-40
			if !TI!==0 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!)*col(x,y)"& set /a REVLIM=0
			if !TI!==1 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin(x)*40)*col(x,y)"
			if !TI!==2 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin((x+y/2)/10)*40)*col(x,y)"
			if !TI!==3 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin((x+y/2)/10)*40+cos(y/7)*19)*col(x,y)"
			if !TI!==4 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin((x+y/2)/5)*10)*col(x,y)"
			if !TI!==5 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin((x*y)/2)*40)*col(x,y)"
			if !TI!==6 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin(((x+10)/(y+10)))*40)*col(x,y)"
			if !TI!==7 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin(x)*22+cos(y)*22)*col(x,y)"
			if !TI!==8 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin(x/6)*22-cos(y/4)*22)*col(x,y)"
			if !TI!==9 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin((x*y)/6)*22+sin((y*y)/40)*10)*col(x,y)"
			if !TI!==10 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!+sin((x*y)/30)*22+sin((y*y)/39)*10)*col(x,y)"
			if !TI!==11 set EXPR="lss(sqrt((x-%XMID%)*(x-%XMID%)+(y-%YMID%)*(y-%YMID%)),!BLCNT!-(sin((x-80)+(y-40))*9))*col(x,y)"
			
			if !BLCNT! lss !REVLIM! set /a REV=1 & cmdwiz delay %TDELAY%
			if !BLCNT! gtr !BLCNTORG! set /a DOTRANS=0
			
			set OUTFADE=" & block 0 0,0,%W%,%H% 0,0 -1 0 0 00??=!FADECOL!!FADECOL!?? !EXPR:~1,-1!"
			(if !REV!==0 set /a BLCNT-=1) & (if !REV!==1 set /a BLCNT+=1)
		)
				
		if !TRANS! == %EXT1% (
			if !SWBLW! gtr %H% set /a REV=1 & cmdwiz delay %TDELAY%
			if !SWBLW! lss 0 set /a DOTRANS=0
			
			set OUTFADE=" & block 0 0,0,%W%,%H% 0,0 -1 0 0 - gtr(y,!SWBLW!)*col(x,y) x y+((floor(x/30)%%2)*2-1)*!SWBLW!"
			(if !REV!==0 set /a SWBLW+=1) & (if !REV!==1 set /a SWBLW-=1)
		)

		if !TRANS! == %EXT2% (
			set /a "SWBLW+=-!REV!*2+1"
			set OUTFADE=""
			set /a "BLY=%H%-!SWBLW!/3, HDBL=%H%*3"
			for /L %%a in (!BLY!,1,%H%) do set OUTFADE="!OUTFADE:~1,-1!&block 0 0,!BLY!,!W!,1 0,%%a -1"
			if !SWBLW! gtr !HDBL! set /a REV=1 & echo "cmdgfx: fbox 0 0 20 0,0,%W%,%H%" & cmdwiz delay %TDELAY%
			if !SWBLW! leq 0 set /a DOTRANS=0
		)
		
		if !TRANS! == -66 (
			if !SWBLW! gtr 55 set /a REV=1 & cmdwiz delay %TDELAY%
			if !SWBLW! lss 0 set /a DOTRANS=0
			
			set OUTFADE=" & block 0 0,0,%W%,%H% 0,0 -1 0 0 - ((floor(x/30)%%2)*gtr(y,!SWBLW!)+(1-(floor(x/30)%%2))*lss(y,%H%-!SWBLW!))*col(x,y) x y+((floor(x/30)%%2)*2-1)*!SWBLW!"
			(if !REV!==0 set /a SWBLW+=1) & (if !REV!==1 set /a SWBLW-=1)
		)
		
		if !DOTRANS! == 0 (
			set OUTFADE=""
			set t1=!time: =0!
			set /a TRANS+=1
			if !TRANS! gtr %EXT2% set /a TRANS=0
			set /a BLCNT=%BLCNTORG%
			if !TRANS! == 0 set /a SWBLW=0
			if !TRANS! == 1 set BLPT=&set /a "BLSTRLEN=0, BLNOFB=(%BLW%+1)*(%BLH%+1)" & for /L %%a in (0,1,%BLH%) do for /L %%b in (0,1,%BLW%) do set /A BLXP=10+%%b&set /A BLYP=10+%%a&set BLPT=!BLPT!!BLXP!!BLYP!
			if !TRANS! == 2 set /A BLDIST=1550,BLMODE=0, BLRX=0,BLRY=0,BLRZ=0, BLTX=0,BLTY=0,BLTZ=0
		)		
	)

	echo "cmdgfx: fbox 0 0 00 0,0,%W%,%H% & 3d %PLANETEMP% 0,58 0,0,!RZ2! 0,0,0 45,45,45,0,0,0 0,0,0,10 %XMID%,%YMID%,700,%ASPECT% 0 !PLANEMOD! db & 3d %OBJTEMP% !DRAWMODE!,!TRANSP! !RX!,!RY!,!RZ! 0,0,0 400,400,400,0,0,0 !CULL!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COL! & skip %TEXT% !OUTFADE:~1,-1! " e!DELOBJCACHE!Z%ZP%f%FONT%:0,0,%W%,%H%
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	set DELOBJCACHE=
	set /a RZ2-=4
	set /a RX+=2, RY+=5, RZ-=3
	
	if !KEY! == 32 set /a "OBJINDEX=(!OBJINDEX! + 1) %% %NOFOBJECTS%"&call :SETOBJECT&set DELOBJCACHE=D
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 100 set /a DIST+=60
	if !KEY! == 68 set /a DIST-=60
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
del /Q plane-temp.obj box-temp.obj > nul 2>nul
echo "cmdgfx: quit"
goto :eof



:SETOBJECT
set /a CULL=1, DRAWMODE=5, PLANEMOD=-8
if %OBJINDEX% == 0 set /a DRAWMODE=6 & set COL=0 -8 db 0 -8 db  0 0 db 0 0 db  0 -6 db 0 -6 db 0 -6 db 0 -6 db  0 -3 db 0 -3 db  0 -4 db 0 -4 db &set TRANSP=-1& call :CHANGETEXTURE %PLANETEMP% plane.obj& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj
if %OBJINDEX% == 1 set COL=1 -8 db 1 -8 db  1 0 db 1 0 db  3 -6 db 3 -6 db 3 -6 db 3 -6 db  0 -3 db 0 -3 db  0 -4 db 0 -4 db &set TRANSP=-1& call :CHANGETEXTURE %PLANETEMP% plane.obj& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj
if %OBJINDEX% == 2 set /a DRAWMODE=6 & set COL=0 0 db&set TRANSP=-1& call :CHANGETEXTURE %PLANETEMP% plane.obj& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj
if %OBJINDEX% == 3 set /a CULL=0 & set COL=6 4 db 6 4 db 2 2 db 2 2 db  0 2 db 0 2 db 6 5 db 6 5 db  6 6 db 6 6 db  3 6 db 3 6 db&set TRANSP=58& call :CHANGETEXTURE %PLANETEMP% plane.obj checkers2 checkers& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj checkers checkers3
if %OBJINDEX% == 4 set /a CULL=0, PLANEMOD=-1 & set COL=0 2 db 0 2 db 0 2 db 0 2 db  0 0 db 0 0 db 0 0 db 0 0 db  0 0 db 0 0 db  0 0 db 0 0 db&set TRANSP=58& call :CHANGETEXTURE %PLANETEMP% plane.obj checkers2 checkers& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj checkers checkers2 #usemtl usemtl
goto :eof

:CHANGETEXTURE <OUTFILE> <INFILE> <INSTR> <OUTSTR> <INSTR2> <OUTSTR2>  <INSTR3> <OUTSTR3>
del /Q %1 > nul 2>nul
for /F "tokens=*" %%a in (objects\%2) do set LINE=%%a&(if not "%4"=="" set LINE=!LINE:%3=%4!)&(if not "%6"=="" set LINE=!LINE:%5=%6!)&(if not "%8"=="" set LINE=!LINE:%7=%8!)&echo !LINE!>> %1
