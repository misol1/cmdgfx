@if (@CodeSection == @Batch) @then
@echo off
if "%~1"=="_EXPLAB" call :EXPLAB %0 & goto :eof
if "%~1"=="_GETCURSOR" set /a CPX=0 & call :GETCURSOR & goto :eof
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title RGB Plasma / Lab
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xRz50 | call %0 %* | cmdgfx_RGB "" Sf0:0,0,238,102t6G500,8
set __=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal EnableDelayedExpansion
set /a W=238, H=102
set /a F6W=W/2, F6H=H/2
mode %F6W%,%F6H%
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" if /I not "%%v"=="PATH" if /I not "%%v"=="SystemRoot" set "%%v="
call centerwindow.bat 0 -12
call sindef.bat

set /a MODE=0, MSET=0, XMUL=300, YMUL=280, A1=155, A2=0, HLPY=100, DBGY=98, MCNT=0, USEDLAB=0, TRANSF=0&set TS=-
set HELP="text 7 0 0 ENTER=LAB,_RIGHT/LEFT,_M,_T,_P,_H"
set /a SHOWHELP=1 & set HS=& if !SHOWHELP!==0 set HS=skip
set /a DBG=0 & set DS=rem& if !DBG!==1 set DS=

set EXPR="store(x+C1,1)+makecol(s1,s1,s1)"
del /Q explab.dat>nul 2>nul
set /a MM0=20, MM1=6, CLRCNT=5
for %%a in (!MSET!) do set /a MAXMODE=!MM%%a!

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)

	set /a A1+=1, A2-=2
	if !MODE! == -1 (
		for %%c in (!COLCNT!) do set EXPRP=!EXPR:C1=%%c!
	) else (
		if !MSET! == 0 (
			if !MODE! == 0 set EXPRP="store(C1/20*sin(x/24)-cos(x/19+y/34)*C2/80,1)+makecol(sin(s1/10)*127+127,cos(s1/2)*127+127,0)"
			
			if !MODE! == 1 set EXPRP="store(cos((x+y)/8)+sin((y/6+(C1/10))/25)*127+127,3)+makecol(cos(s3/70+x/56)*127+127,sin(s3/20-(x+C2)/74)*127+127,cos(s3/9)*50+50)"
			
			if !MODE! == 2 set EXPRP="store(sin((x-C1)/80)*(y/2)+cos((y+C2/5)/35)*(x/3),1)+store(sin((y/12*(C1/100))/25)*127+127,3)+makecol(s3,sin(s1/6)*60+90,cos(s1/10)*127+127)"
			
			if !MODE! == 3 set EXPRP="store(C1/20*sin(x/7)+cos(y/34)*C2/8,1)+makecol(sin(s1/10)+cos(s1/24)*127+127,cos(s1/4)*127+127,0)"
			
			if !MODE! == 4 set EXPRP="store(sin(x/5)*cos(C1/55)*12,3)+makecol(cos((s3+x)/35)*77+77,sin((s3-y)/12)*127+127,cos(s3/20)*50+50)"
					
			if !MODE! == 5 set EXPRP="store(tan((x-C1)/24)*(y/50)+cos((y+C2/6)/35)*(x/3),1)+makecol(80,sin(s1/6)*60+90,sin(s1/10)*127+127)"
			
			if !MODE! == 6 set EXPRP="store(x+C1,1)+makecol(cos(s1/83)*80+80,cos((A1+x)/7)*34+sin((y+C2/5)/(15+C2/80-C1/40))*67+128,sin(s1/84)*100+100)"
			
			if !MODE! == 7 set EXPRP="store(sin((x+C1-C2/4)/100)*(cos(x/(y+240+C2/10))*3)*(y+C2/5)/16,1)+makecol(cos(s1+x/8)*127+127,cos(s1/2-C1/66)*127+127,cos((s1/6+C1)/20)*127+127)"
			
			if !MODE! == 8 set EXPRP="store(sin((x-C1/4)/80)*(y/2)+cos((y+C2/5)/35)*(x/3),1)+store(sin((y/12*(C1/100))/25)*127+127,3)+makecol(s3,s2,cos(s1/10)*127+127)"
			
			if !MODE! == 9 set EXPRP="store(sin(((cos(x/140+C1/70)*y/5)*(C1/116))/36)*127+127,1)+store(sin(((cos(x/190)*y/6)*(C1/116))/36)*127+127,2)+store(sin((y/12*(C1/10))/25)*(cos(x/17)/2)*127+127,3)+makecol(s3,s2,s1)"
			
			if !MODE! == 10 set EXPRP="store(sin((x-C1/4)/80)*(y/2)+cos((y+C2/5.5)/35)*(x/3),2)+makecol(cos(s2/10+C1/30)*90+90,cos(C1/150-C2/170)*64+64,sin(s2/120-y/75)*127+127)"
			
			if !MODE! == 11 set EXPRP="store(sin((x+C1-C2/4)/100)*(tan((x+300)/(y+240+C2/10))*3)*(y*5+C2/5)/16,1)+makecol(cos(s1/15+x/18)*127+127,cos(s1/50)*127+127,cos((s1+C1)/20)*127+127)"
			
			if !MODE! == 12 set EXPRP="store(x+C1/3+sin(y/45+A1/17)*40,1)+makecol(s1,cos(A2/30+x/17)*90+90,sin(y*x/1000)*100+100+random()*40)"

			if !MODE! == 13 set EXPRP="store(perlin((x+C1/2+200)/(36+C2/30),(y+C1/3+120)/(36+C1/40))*380,1)+makecol(abs(s1),abs(s1)/2,max(s1,0))"
			
			if !MODE! == 14 set EXPRP="store(abs(perlin(cos((x+300)/362+C2/337-(y+100)/118)+x/150,sin((y+A2/8)/98+C1/430)))*500,1)+makecol(s1/2+C1/10+40,s1/1.5,s1)"
		
			if !MODE! == 15 set EXPRP="store(abs(perlin(155*(C1/345-cos(y/6)/3)/56,y/78+C2/500*(cos(x/5)*2+5)/5))*490,1)+makecol(s1,s1,s1/1.2)"
		
			if !MODE! == 16 set EXPRP="store(abs(perlin(perlin((x+200)/162+C2/237,(y+100)/58)+x/50,perlin((y+200)/98+C1/430,(x+300)/115+C2/390)))*500,1)+makecol(s1/2+C1/10+40,s1/1.5,s1)"

			if !MODE! == 17 set EXPRP="store(x/SCRW-0.5,0)+store(y/SCRH-0.5,1)+store(3-3*length(s0*2,s1*2),3)+store(s3+1.5*sin(A1/40+s0*8)*cos(s1*3-A2/91.5),3)+makecol(clamp255(s3*255),clamp255(pow(max(s3,0),2)*0.4*255),clamp255(pow(max(s3,0),3)*0.15*255))"
			
			if !MODE! == 18 set EXPRP="store(sin((x-C1/4)/80)*(y/2)+cos((y+C2/5)/35)*(x/3),1)+makecol(50,tan(s1/20),cos(s1/5)*127+127)"
			
			if !MODE! == 19 set EXPRP="store(tan((x-C1/10)/40)*sin(y/6)*3+cos(((y+x)+C2/5)/35)*(x/3),1)+makecol(s1/2,tan(s1/20)/20,cos(s1/5)*127+127)"

			if !MODE! == 20 set EXPRP="store(x-SCRW/2,2)+store(y-SCRH/2,3)+store(lss(sqrt(s2*s2+s3*s3),C1/(3.2-(SCRW-238)/50)+70+sin(x)*22+cos(y)*22),1)+makecol(s1*200,s1*90,s1*(140+cos(x/5+C1/20*sin(y/50))*90))"
		) else (
		
			if !MODE! == 0 set EXPRP="store(sin(0.1),0)+store(cos(0.1),1)+store(x-SCRW/2,2)+store(y-SCRH/2,3)+shade(fgcol((s2*s1-s3*s0+SCRW/2)/0.98-SCRH/51,(s2*s0+s3*s1+SCRH/2)/0.98),-4,-4,-4)+store(eq(mod(A2,3),0),4)+250*s4*lss(random(),0.1)*or(gtr(y,SCRH-9),lss(y,9))"

			if !MODE! == 1 set EXPRP="store(random()*140+col(y+C1/3,y)-col(y+C2,y/4)-gtr(y,C2)*900,0)+makecol(s0,s0,s0)"

			if !MODE! == 2 set EXPRP="store(gtr(fgcol(x-1,y-1),0)+gtr(fgcol(x,y-1),0)+gtr(fgcol(x+1,y-1),0)+gtr(fgcol(x-1,y),0)+gtr(fgcol(x+1,y),0)+gtr(fgcol(x-1,y+1),0)+gtr(fgcol(x,y+1),0)+gtr(fgcol(x+1,y+1),0),0)+((1-(lss(s0,2)+gtr(s0,3)))*gtr(fgcol(x,y),0)+eq(fgcol(x,y)*10+s0,3))*255+store(eq(mod(A1,80),0),4)+60*s4*lss(random(),0.04)"
			
			if !MODE! == 3 set EXPRP="store(fgcol(x,y+1),0)+store(fgcol(x-1,y+1),1)+store(fgcol(x+1,y+1),2)+store(fgcol(x,y+2),3)+makecol((fgr(s0)+fgr(s1)+fgr(s2)+fgr(s3))/4,(fgg(s0)+fgg(s1)+fgg(s2)+fgg(s3))/4.05,(fgb(s0)+fgb(s1)+fgb(s2)+fgb(s3))/4.2)*lss(y,SCRH-3)+store(geq(y,SCRH-3)*(random()*127+C2/10+80),4)+makecol(s4,s4,s4)"

			if !MODE! == 4 set EXPRP="store((sin((x-C1/4+C2/10)/80)+1)*(gtr(y,cos((x-A2)/55)*(C1/6)+70)*20)*2,0)+makecol(s0,s0*1.4,s0*1.6+random()*50)"

			if !MODE! == 5 set EXPRP="store(sin(0.1),0)+store(cos(0.1),1)+store(x-SCRW/2,2)+store(y-SCRH/2,3)+shade(col((s2*s1-s3*s0+SCRW/2)/0.98-SCRH/(64+C1/10),(s2*s0+s3*s1+SCRH/2)/0.98+C2/100),-4,-4,-4)+makecol(sin(A1/100)*120+120,cos(A2/190)*40+40,sin(A1/70)*90+90)*lss(random(),0.8)*geq(gtr(y,SCRH-6)+lss(y,6)+lss(x,6)+gtr(x,SCRW-6),1)"

			if !MODE! == 6 set EXPRP="store(((C1/2+180)+80)/10000,4)+store((x-(SCRW/2+20)+20)*s4,0)+store((y-SCRH/2)*s4,1)+store(0,2)+store((C1/2+180)/200,4)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+makecol(0,s2*15,s2*31)"
		)

		for %%c in (!COLCNT!) do set EXPRP=!EXPRP:C1=%%c!
	)

	for %%c in (!COLCNT2!) do set EXPRP=!EXPRP:C2=%%c!
	for %%c in (!A1!) do set EXPRP=!EXPRP:A1=%%c!
	for %%c in (!A2!) do set EXPRP=!EXPRP:A2=%%c!
	for %%c in (!W!) do set EXPRP=!EXPRP:SCRW=%%c!
	for %%c in (!H!) do set EXPRP=!EXPRP:SCRH=%%c!
	set EXPRP=!EXPRP:L1=%%1!
	
	set CLRSKIP=skip&set /a CLRCNT-=1&if !CLRCNT! gtr 0 set CLRSKIP=
	
	echo "cmdgfx: !CLRSKIP! fbox 0 0 db & block 0 0,0,!W!,!H! 0,0 -1 0 0 !TS! !EXPRP:~1,-1! & !HS! !HELP:~1,-1!__(!MODE!) 1,!HLPY! & !DS! line ? ? db 1,!DBGY!,500,!DBGY! & text f 0 0 !EXPRP:~1,-1! 1,!DBGY!" Ff0:0,0,!W!,!H!

	if exist explab.dat set /a MODE=-1 & set /P EXPR=<explab.dat & set /a CLRCNT=15 & del /Q explab.dat >nul 2>nul
	
	set /a MCNT+=1 & if !MCNT! geq 7 set /a A2+=1, MCNT=0
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
	
	if "!RESIZED!"=="1" set /a W=SCRW*2+1, H=SCRH*2+1, HLPY=H-3, DBGY=HLPY-3 & cmdwiz showcursor 0 & set /a CLRCNT=20
	set /a NEXT=0 & (if !KEY! == 32 set /a NEXT=1) & (if !KEY! == 333 set /a NEXT=1) 
	if !NEXT! == 1 set /A MODE+=1&(if !MODE! gtr !MAXMODE! set MODE=0)&set /a CLRCNT=10
	if !KEY! == 331 set /A MODE-=1&(if !MODE! lss 0 set MODE=!MAXMODE!)&set /a CLRCNT=10
	
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz getconsoledim sw&set CMDWO=!errorlevel!&cmdwiz getconsoledim sh&set CMDHO=!errorlevel!&cmdwiz getwindowbounds x&set CMDXO=!errorlevel!&&cmdwiz getwindowbounds y&set CMDYO=!errorlevel!&cmdwiz fullscreen 1&if !errorlevel! lss 0 set LEG=1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0&if "!LEG!"=="1" mode !CMDWO!,!CMDHO!&cmdwiz setwindowpos !CMDXO! !CMDYO!)

	if !KEY! == 109 set /a MSET=1-MSET, MODE=0, CLRCNT=10 & for %%a in (!MSET!) do set /a MAXMODE=!MM%%a!
	
	if !KEY! == 100 set /a CLRCNT=15 & set /a DBG=1-DBG & set DS=&if !DBG!==0 set DS=rem
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 116 set TS=-& set /a TRANSF=1-TRANSF, CLRCNT=10 & if !TRANSF!==1 set TS=a:f???=??db,e???=??db,d???=??db,c???=??db,b???=??b2,a???=??b2,9???=??b2,8???=??b2,7???=??b1,6???=??b1,5???=??b1,4???=??b1,3???=??b0,2???=??b0,1???=??b0,0???=?0b1
	if !KEY! == 104 set /a CLRCNT=15 & set /a SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set HS=skip)& if !SHOWHELP!==1 set HS=

	if !KEY! == 13 set /a MODE=-1,USEDLAB+=1 & start "Expression Lab" cmd /C %0 _EXPLAB >nul 2>nul & call :NOP
	if !KEY! == 27 set STOP=1
	
	set /a KEY=0
)
if not defined STOP goto LOOP

if !USEDLAB! gtr 0 for /l %%a in (1,1,!USEDLAB!) do cmdwiz showwindow close "/w:Expression Lab">nul 2>nul
endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:EXPLAB
cmdwiz setfont 2
mode 180,4
del /Q explab.dat>nul 2>nul

set XPR="store(x+C1,1)+makecol(s1,s1,s1)"

start "" /B cmd /C %1 _GETCURSOR >nul 2>nul & call :NOP

:INPLOOP
set "XPR=%XPR:(={(}%"
set "XPR=%XPR:)={)}%"
set "XPR=%XPR:+={+}%"
set "XPR=%XPR:[={[}%"
set "XPR=%XPR:]={]}%"

CScript //nologo //E:JScript "%~F0" %XPR%
cls & echo.
set /P "XPR=Exp: "
echo "%XPR%">explab.dat
echo SETCP>setCp.dat
goto :INPLOOP
goto :eof

:GETCURSOR
setlocal EnableDelayedExpansion
:GETCURSORLOOP
cmdwiz getcursorpos x
if %errorlevel% neq 0 set /a CPX=%errorlevel%

cmdwiz delay 200
if exist setCp.dat if %CPX% neq 0 (
	cmdwiz delay 500
	cmdwiz getcursorpos x
	set /a DELTA=!errorlevel!-CPX
	if !DELTA! gtr 0 cmdwiz sendkey 0x25 p !DELTA!
	rem cmdwiz setcursorpos %CPX% k & rem Sets right cursor pos, but messes up the internal input pos for set /p
	del /Q setCp.dat >nul 2>nul
)
goto :GETCURSORLOOP
endlocal

:NOP
goto :eof
@end

WScript.CreateObject("WScript.Shell").SendKeys(WScript.Arguments(0));
