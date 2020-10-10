@if (@CodeSection == @Batch) @then
@echo off
if "%~1"=="_EXPLAB" call :EXPLAB %0 & goto :eof
if "%~1"=="_GETCURSOR" call :GETCURSOR & goto :eof
cmdwiz setfont 6 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xR | call %0 %* | cmdgfx_RGB "" Sf0:0,0,238,102t8G500,8
set __=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal EnableDelayedExpansion
set /a W=238, H=102
set /a F6W=W/2, F6H=H/2
mode %F6W%,%F6H%
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" if /I not "%%v"=="PATH" if /I not "%%v"=="SystemRoot" set "%%v="
set /a rW=100, rH=100
cmdwiz getdisplayscale
if !errorlevel! neq 100 (
	cmdwiz getwindowbounds w e & set /a "aW=!errorlevel!, pW=W*4, rW=(aW*100)/pW"
	cmdwiz getwindowbounds h e & set /a "aH=!errorlevel!, pH=H*6, rH=(aH*100)/pH"
	set /a W=W*rW/100, H=H*rH/100
)	
call centerwindow.bat 0 -12
call sindef.bat

set title="RGB Expression Lab (enter, right/left, m, t, c, f, d, 1-9, p)"
title !title:~1,-1! (0 : 0)

set /a MODE=0, MSET=0, XMUL=300, YMUL=280, A1=155, A2=0, DBGY=3, MCNT=0, USEDLAB=0, TRANSF=0, WRAP=0&set TS=-
set /a DBG=0 & set DS=rem& if !DBG!==1 set DS=

set EXPR="store(x+C1,1)+makecol(s1,s1,s1)"
del /Q explab.dat>nul 2>nul
set /a MM0=28, MM1=21, CLRCNT=5
for %%a in (!MSET!) do set /a MAXMODE=!MM%%a!
set C16S=skip&set /a C16=0&if !C16!==1 set C16S=
set /a FPS=0 & set FSKIP=& if !FPS!==0 set FSKIP=skip
set /a FCLEAR=0, SPLIM=1
set LKEY=""& set SCHR="()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\] _ abcdefghijklmnopqrstuvwxyz{|}~"
set /a IMGCNT=0& set IMGSKIP=skip& set IMG=123.bmp

set /a A1D=1, A2D=-2, USETHREADS=1, TMPW=0, FONT=0, WMUL=2, HMUL=2, HADD=4

:LOOP
for /L %%1 in (0,1,255) do if not defined STOP (

	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)

	set TMPIS=!IMGSKIP!&set TMPIMG=!IMG!
	if !TMPW!==1 if !MODE! neq 20 if !MODE! neq 24 set /a TMPW=0 & echo "" r!WRAP! >servercmd.dat
	
	set /a A1+=A1D, A2+=A2D
	if !MODE! == -1 (
		for %%c in (!COLCNT!) do set EXPRP=!EXPR:C1=%%c!
	) else (
		if !MSET! == 0 (
			if !MODE! == 0 set EXPRP="store(C1/20*fsin(x/24)-fcos(x/19+y/34)*C2/80,1)+makecol(fsin(s1/10)*127+127,fcos(s1/2)*127+127,0)"
			
			if !MODE! == 1 set EXPRP="store(fcos((x+y)/8)+fsin((y/6+(C1/10))/25)*127+127,3)+makecol(fcos(s3/70+x/56)*127+127,fsin(s3/20-(x+C2)/74)*127+127,fcos(s3/9)*50+50)"
			
			if !MODE! == 2 set EXPRP="store(fsin((x-C1)/80)*(y/2)+fcos((y+C2/5)/35)*(x/3),1)+store(fsin((y/12*(C1/100))/25)*127+127,3)+makecol(s3,fsin(s1/6)*60+90,fcos(s1/10)*127+127)"
			
			if !MODE! == 3 set EXPRP="store(C1/20*fsin(x/7)+fcos(y/34)*C2/8,1)+makecol(fsin(s1/10)+fcos(s1/24)*127+127,fcos(s1/4)*127+127,0)"
			
			if !MODE! == 4 set EXPRP="store(fsin(x/5)*fcos(C1/55)*12,3)+makecol(fcos((s3+x)/35)*77+77,fsin((s3-y)/12)*127+127,fcos(s3/20)*50+50)"
					
			if !MODE! == 5 set EXPRP="store(tan((x-C1)/24)*(y/50)+cos((y+C2/6)/35)*(x/3),1)+makecol(80,sin(s1/6)*60+90,sin(s1/10)*127+127)"
			
			if !MODE! == 6 set EXPRP="store(x+C1,1)+makecol(cos(s1/83)*80+80,cos((A1+x)/7)*34+sin((y+C2/5)/(15+C2/80-C1/40))*67+128,sin(s1/84)*100+100)"
			
			if !MODE! == 7 set EXPRP="store(fsin((x+C1-C2/4)/100)*(fcos(x/(y+240+C2/10))*3)*(y+C2/5)/16,1)+makecol(fcos(s1+x/8)*127+127,fcos(s1/2-C1/66)*127+127,fcos((s1/6+C1)/20)*127+127)"
			
			if !MODE! == 8 set EXPRP="store(fsin((x+C1-C2/4)/100)*(tan((x+300)/(y+240+C2/10))*3)*(y*5+C2/5)/16,1)+makecol(fcos(s1/15+x/18)*127+127,fcos(s1/50)*127+127,fcos((s1+C1)/20)*127+127)"
			
			if !MODE! == 9 set EXPRP="store(x+C1/3+fsin(y/45+A1/17)*40,1)+makecol(s1,fcos(A2/30+x/17)*90+90,fsin(y*x/1000)*100+100+random()*40)"

			if !MODE! == 10 set EXPRP="store(perlin((x+C1/2+200)/(36+C2/30),(y+C1/3+120)/(36+C1/40))*380,1)+makecol(abs(s1),abs(s1)/2,max(s1,0))"
			
			if !MODE! == 11 set EXPRP="store(abs(perlin(fcos((x+300)/362+C2/337-(y+100)/118)+x/150,fsin((y+A2/8)/98+C1/430)))*500,1)+makecol(s1/2+C1/10+40,s1/1.5,s1)"
		
			if !MODE! == 12 set EXPRP="store(abs(perlin(155*(C1/345-fcos(y/6)/3)/56,y/78+C2/500*(fcos(x/5)*2+5)/5))*490,1)+makecol(s1,s1,s1/1.2)"
		
			if !MODE! == 13 set EXPRP="store(abs(perlin(perlin((x+200)/162+C2/237,(y+100)/58)+x/50,perlin((y+200)/98+C1/430,(x+300)/115+C2/390)))*500,1)+makecol(s1/2+C1/10+40,s1/1.5,s1)"

			if !MODE! == 14 set EXPRP="store(x/SCRW-0.5,0)+store(y/SCRH-0.5,1)+store(3-3*length(s0*2,s1*2),3)+store(s3+1.5*sin(A1/40+s0*8)*cos(s1*3-A2/91.5),3)+makecol255(s3*255,pow(max(s3,0),2)*0.4*255,pow(max(s3,0),3)*0.15*255)"

			if !MODE! == 15 set EXPRP="store(abs(perlin(((x+50)/5*(y+44)/6*(C2/12+200))/60000,((y+75)/5*(x+166)/3*(C1/6+200))/200000))*350,1)+makecol(s1,s1/2,s1)"
			
			if !MODE! == 16 set EXPRP="store(tan((x-C1/10)/40)*fsin(y/6)*3+fcos(((y+x)+C2/5)/35)*(x/3),1)+makecol(s1/2,tan(s1/20)/20,fcos(s1/5)*127+127)"

			if !MODE! == 17 set EXPRP="store(x-SCRW/2,2)+store(y-SCRH/2,3)+store(lss(sqrt(s2*s2+s3*s3),C1/(3.2-(SCRW-238)/50)+70+fsin(x)*22+fcos(y)*22),1)+makecol(s1*200,s1*90,s1*(140+fcos(x/5+C1/20*fsin(y/50))*90))"
			
			if !MODE! == 18 set TMPIS=&set TMPIMG=123.bmp& set EXPRP="col(x+fsin(y/19+A1/10)*30,y+fcos(x/76+A2/35)*15)"

			if !MODE! == 19 set TMPIS=&set TMPIMG=123.bmp& set EXPRP="store(col(x,y),0)+store(C2/750+0.5,1)+blend(s0,s1*255,fgr(s0),fgr(s0),fgr(s0))"
			
			if !MODE! == 20 set TMPIS=&set TMPIMG=123.bmp& set EXPRP="store(A1/12,4)+store(x/SCRW-0.5,0)+store(y/1.6/SCRH-0.3,1)+store(length(s0,s1),2)+store(atan2(s0,s1)+s4*0.3,0)+store(0.3/s2+s4*0.5,1)+store(col(s1*40+fsin(s0)*50,s1*40),3)+makecol255(fgr(s3)*s2*4,fgg(s3)*s2*4,fgb(s3)*s2*4)"& if !TMPW!==0 set /a TMPW=1 & echo "" r2 >servercmd.dat
			
			if !MODE! == 21 set TMPIS=&set TMPIMG=6hld.bmp& set EXPRP="store(fsin(A1/60)*(SCRW/4),3)+store((x-s3)/SCRW-0.5,0)+store(((y-C2/38)/SCRH-0.5)/(SCRW/SCRH)/0.66,1)+store(length(s0,s1)*1500,2)+col(SCRW/2+s2*s0+s3,SCRH/2+s2*s1+C2/38)*lss(s2,300)+col(x,y)*geq(s2,300)"

			if !MODE! == 22 set TMPIS=&set TMPIMG=123.bmp&(if !IMGCNT!==2 set TMPIMG=6hld.bmp)& set EXPRP="store((x+C1/7)/SCRW-0.5,0)+store((y+C2/11)/SCRH*SCRH/SCRW/0.66-0.35,1)+store(255-pow(length(s0,s1)*45,2),2)+store(fgb(col(x-1,y))-fgb(col(x+SCRW/100,y)),3)+store(355-s3*((x/SCRW-s0)*10)+s3*((y/SCRH-s1)*100),4)+store(s2*s4/300,3)+store(s2*geq(s2,0)+lss(s2,90)*((700-abs(s2-90)))/100,2)+makecol255(s3*s2/400,s3*s2/1200,s3*(s2)/2000)"
			
			if !MODE! == 23 set TMPIS=&set TMPIMG=6hld.bmp& set EXPRP="store(x/SCRW-0.5,0)+store(y/SCRH-0.5,1)+store(s1+A1/20+fsin(s1)*sin(A1/40)*3.14,2)+store(0.35*fsin(s2),3)+store(0.35*fsin(s2+2.0943),4)+store((s0-s3)/(s4-s3),5)+store(geq(s5,0)*lss(s5,1),6)+store(col(s5*SCRW,y)*s6,7)+store(0.35*fsin(s2+4.1886),3)+store((s0-s4)/(s3-s4),5)+store(geq(s5,0)*lss(s5,1)*lss(s4,s3),6)+store((1-s6)*s7+col(s5*SCRW,y)*s6,7)+store(0.35*sin(s2+6.283),4)+store((s0-s3)/(s4-s3),5)+store(geq(s5,0)*lss(s5,1)*lss(s3,s4),6)+(1-s6)*s7+col(s5*SCRW,y)*s6"

			if !MODE! == 24 set TMPIS=&set TMPIMG=6hld.bmp& set EXPRP="store(x/SCRW-0.5,0)+store((y/SCRH-0.5)*SCRH/SCRW/0.66,1)+store(abs(atan2(s1,s0)),2)+store(pow(length(s0,s1),0.9),3)+store(abs(mod(s2+0.224,0.897)-0.448)/(1+s3),2)+store(fcos(s2)*s3*1.6,0)+store(fsin(s2)*s3*1.6,1)+store(A1/150,6)+store(s0*fcos(s6)-s1*fsin(s6)-0.2*fsin(s6),7)+store(s0*fsin(s6)+s1*fcos(s6)+0.2*fcos(s6),8)+col(s7*SCRW,s8*SCRH)"& if !TMPW!==0 set /a TMPW=1 & echo "" r2 >servercmd.dat
			
			if !MODE! == 25 set TMPIS=&set TMPIMG=6hld.bmp& set EXPRP="store(x/SCRW*1.5-0.75,0)+store(y/SCRH*1.5-0.75,1)+store(length(s0,s1),8)+store(atan2(s1,s0)+3.14,1)+store(s8-0.5,0)+store(fsin(s1+A1/65)*SCRH/2+SCRH/2,8)+store(s1+A1/20+fsin(s1)*fsin(A1/40)*3.14,2)+store(0.15*fsin(s2),3)+store(0.15*sin(s2+2.0943),4)+store((s0-s3)/(s4-s3),5)+store(geq(s5,0)*lss(s5,1),6)+store(col(s5*SCRW,s8)*s6,7)+store(0.15*fsin(s2+4.1886),3)+store((s0-s4)/(s3-s4),5)+store(geq(s5,0)*lss(s5,1)*lss(s4,s3),6)+store((1-s6)*s7+col(s5*SCRW,s8)*s6,7)+store(0.15*fsin(s2+6.283),4)+store((s0-s3)/(s4-s3),5)+store(geq(s5,0)*lss(s5,1)*lss(s3,s4),6)+(1-s6)*s7+col(s5*SCRW,s8)*s6"

			if !MODE! == 26 set TMPIS=&set TMPIMG=6hld.bmp&set EXPRP="DLL:eextern:twister:A1,A2,C1,C2,L1"

 			if !MODE! == 27 set EXPRP="DLL:eextern:multiPlasma:A1"

			if !MODE! == 28 set EXPRP="DLL:eextern:julia:A1,A2,C1,C2,L1"
			
		) else (
		
			if !MODE! == 0 set EXPRP="store(fsin(0.1),0)+store(fcos(0.1),1)+store(x-SCRW/2,2)+store(y-SCRH/2,3)+shade(fgcol((s2*s1-s3*s0+SCRW/2)/0.98-SCRH/51,(s2*s0+s3*s1+SCRH/2)/0.98),-4,-4,-4)+store(eq(mod(A2,3),0),4)+250*s4*lss(random(),0.1)*or(gtr(y,SCRH-9),lss(y,9))"

			if !MODE! == 1 set EXPRP="store(random()*140+col(y+C1/3,y)-col(y+C2,y/4)-gtr(y,C2)*900,0)+makecol(s0,s0,s0)"

			if !MODE! == 2 set EXPRP="store(gtr(fgcol(x-1,y-1),0)+gtr(fgcol(x,y-1),0)+gtr(fgcol(x+1,y-1),0)+gtr(fgcol(x-1,y),0)+gtr(fgcol(x+1,y),0)+gtr(fgcol(x-1,y+1),0)+gtr(fgcol(x,y+1),0)+gtr(fgcol(x+1,y+1),0),0)+((1-(lss(s0,2)+gtr(s0,3)))*gtr(fgcol(x,y),0)+eq(fgcol(x,y)*10+s0,3))*255+store(eq(mod(A1,80),0),4)+60*s4*lss(random(),0.04)"
			
			if !MODE! == 3 set EXPRP="store(fgcol(x,y+1),0)+store(fgcol(x-1,y+1),1)+store(fgcol(x+1,y+1),2)+store(fgcol(x,y+2),3)+makecol((fgr(s0)+fgr(s1)+fgr(s2)+fgr(s3))/4,(fgg(s0)+fgg(s1)+fgg(s2)+fgg(s3))/4.06,(fgb(s0)+fgb(s1)+fgb(s2)+fgb(s3))/4.2)*lss(y,SCRH-3)+store(geq(y,SCRH-3)*(perlin(x/(15+random()*25)+random()*2,0)*127),4)+makecol(s4,s4,s4)"

			if !MODE! == 4 set EXPRP="store(fsin(0.1),0)+store(fcos(0.1),1)+store(x-SCRW/2,2)+store(y-SCRH/2,3)+shade(col((s2*s1-s3*s0+SCRW/2)/0.98-SCRH/(64+C1/10),(s2*s0+s3*s1+SCRH/2)/0.98+C2/100),-4,-4,-4)+makecol(sin(A1/100)*120+120,cos(A2/190)*40+40,sin(A1/70)*90+90)*lss(random(),0.8)*geq(gtr(y,SCRH-6)+lss(y,6)+lss(x,6)+gtr(x,SCRW-6),1)"

			if !MODE! == 5 set EXPRP="store((sin((x-C1/4+C2/10)/80)+1)*(gtr(y,fcos((x-A2)/55)*(C1/6)+70)*20)*2,0)+makecol(s0,s0*1.4,s0*1.6+random()*50)"

			if !MODE! == 6 set EXPRP="store(((C1/2+180)+80)/10000,4)+store((x-(SCRW/2+20)+20)*s4,0)+store((y-SCRH/2)*s4,1)+store(0,2)+store((C1/2+180)/200,4)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0+s1*s1,4)+s2,2)+makecol(0,s2*15,s2*31)"

			if !MODE! == 7 set EXPRP="store(((x/SCRW)*2-1)*(SCRW/SCRH*0.66),0)+store((y/SCRH)*2-1,1)+store(length(s0,s1),2)+store(1-sqrt(abs((0.9+C2/1390+C1/1180)-s2)/(C1/190+2.6)),3)+makecol255(s3*205,s3*25,fsin(x/66)+fcos(A2/80+y/99)*50+50)"

			if !MODE! == 8 set EXPRP="store(((x/SCRW)*2-1)*(SCRW/SCRH*0.66),0)+store((y/SCRH)*2-1,1)+store(length(s0,s1),2)+store(1-sqrt(abs(1-s2))/(C2/1400-0.6)-0.3,3)+store(s3+perlin((x+s2*A1/2)/(s2*6),(y+s2*A1/2)/(s2*4))*pow(s2,1)*0.8,3)+makecol255(s3*205,s3*25,0)"
			
			if !MODE! == 9 set EXPRP="store(x/SCRW-0.5,0)+store(y/SCRH-0.5,1)+store(log(sqrt(s0*s0+s1*s1)),2)+store(atan2(s0,s1),3)+store(fcos(10*s0-A1/20)+fcos(5*s2-A1/20)+fcos(2*6*(s2*fsin(1.047)+s3*fcos(1.047))+A1/20),4)+makecol255(fsin(s4+A1/60)*250,s4*250,fsin(s4+A1/40)*250)"
			
			if !MODE! == 10 set EXPRP="store(x/SCRW-0.5,0)+store(y/SCRH/1.6-0.32,1)+store(0.5+0.5*fsin(A1/60),2)+store(-(s0*s0+s1*s1),3)+store(1+0.5*fsin((s3+A1/60*0.035)/0.013),3)+makecol255(s3*(s0+0.5)*355,s3*(s1+0.5)*355,s3*s2*355)"

			if !MODE! == 11 set EXPRP="store(1+2*x/SCRW-0.5,0)+store(1+2*y/SCRH/1.6-0.32,1)+store(fsin(A1/24)/3+1.4,2)+store(fsin(A1/35)/1.5+1.3,3)+store(fsin(sqrt(pow(s0-s2,2)+pow(s1-s3,2))*40),4)+store(fsin(sqrt(pow(s0-(s3+0.2),2)+pow(s1-s2+C1/400,2))*40),3)+store((sign(s3)*sign(s4)+1.5)*255,4)+makecol255(s4,s4/5,s4/2.5)"

			if !MODE! == 12 set EXPRP="store(x/SCRW-0.5,0)+store(y/1.8/SCRH-0.3,1)+store(A1/40,2)+store(s0*fcos(s2)-s1*fsin(s2),3)+store(s1*fcos(s2)+s0*fsin(s2),4)+store(fsin(A1/30)*35+54,0)+store(perlin(perlin(s3*s0*0.4+70+fsin(A2/1600)*150,0.5),s4*s0*0.4+20+fsin(A2/700)*130),3)+makecol255(100*s3+abs(s3)*700+C1/10,400*s3+C1/10,500*abs(s3)+C2/7+50)"

			if !MODE! == 13 set EXPRP="store(fsin(A1/22)*55+70,1)+store(4*s1-length(mod(abs(x-SCRW/2),s1)-s1/2,mod(abs(y-SCRH/2),s1)-s1/2)*10,0)+makecol255(pow(s0,1.8)/(s1/9),s0/2+s0*mod((abs(x-SCRW/2))/s1+gtr(x,SCRW/2),3),s0*mod((abs(y-SCRH/2))/s1+gtr(y,SCRH/2),3))"

			if !MODE! == 14 set EXPRP="store(perlin((perlin(fsin(A1/110)*2+(x+400)/90,fsin(A1/118)*4.2+(y+300)/70)*200)/(40+C1/35),(y+50)/85)*400,0)+makecol255(fsin(s0/30)*239,abs(s0)*1.4,s0*3.4)"

			if !MODE! == 15 set EXPRP="store(max(fsin(y/78+C2/250)*60,fsin(x/45+C1/167)*75),0)+store(perlin((perlin(fsin(A1/170)*3+(x+400)/90,C1/450+(y+200)/70)*100)/(20+C1/40),(y-100)/45+C2/300)*906,1)+makecol255(s0*4+s1/10,fsin(x/125+C2/274+C1/400)*90+s1/1.5,s1)"

			if !MODE! == 16 set EXPRP="store(abs(perlin(155*(C1/345-fcos(fsin(y/80+C1/420+C2/250)*9+x/5)/3)/56,x/78+C2/500*(fcos(y/1.5)*2+5)/5))*490,1)+makecol(s1,s1/1.2,s1/1)"
			
			if !MODE! == 17 set EXPRP="store(A1/20,4)+store(x/SCRW-0.5,0)+store(y/1.6/SCRH-0.3,1)+store(length(s0,s1),2)+store(atan2(s0,s1)+s4*0.3,0)+store(0.3/s2+s4*0.5,1)+store(perlin(fsin(s0)+s1*2,s1*2)*s2*s2*2.8,3)+makecol255(s3*10000,10+abs(s3)*1500,abs(s3)*4600)"
			
			if !MODE! == 18 set EXPRP="store(x/SCRW/2-0.25,0)+store(y/SCRH/4.5-0.11,1)+store(length(s0,s1)/3,2)+store(atan2(s1,s0),3)+store(fsin(100*(sqrt(s2)-0.02*s3-0.3*((A1+s1*(150+C2/0.9))/140)))*650,4)+store(length(x-SCRW/2,y-SCRH/2)/150,1)+makecol255(s4/2+C1/8+160,max(s4/6,100)+fsin((s3/2.5+A1*1)*25)*1620*(s1*s1),fsin((s3/5+A1*1)*25)*1840*s1*s1*4+160)"

			if !MODE! == 19 set EXPRP="store(x/SCRW/2-0.25,0)+store(y/SCRH/4.5-0.11,1)+store(length(s0,s1)/3,2)+store(atan2(s1+C1/5000,s0+C2/8000),3)+store(fsin(100*(sqrt(s2)-0.02*perlin(s3,s3*2)*1-A1/1000-0.3))*650,4)+makecol255(s4/2+C1/8+160,fsin(s3*s3)*100,fsin(A1/34)*90+130+fsin(s3*s3)*50)"

			if !MODE! == 20 set EXPRP="store(26,4)+store(s4/2,3)+store(abs(mod(A1/1.5+floor(x/s4)*2+floor(y/s4)*4,s4)-s3),1)+store(lss(abs(s3-mod(x,s4)),s1)*lss(abs(s3-mod(y,s4)),s1),0)+makecol255(s0*s1*13,s0*s1*10,s0*s1*25)"

			if !MODE! == 21 set EXPRP="store(A1/20,4)+store(x/SCRW-0.5+fsin(s4/2.7)*0.2,0)+store(y/1.6/SCRH-0.3+cos(s4/3)*0.11,1)+store(length(s0,s1),2)+store(atan2(s0,s1)+s4*0.3,0)+store(0.3/s2+s4*0.5,1)+store(perlin(fsin(s0)*(2+fsin(A1/150)*3)*1+s1*2,s1*2)*s2*s2*2.8,3)+makecol255(s3*10000+fsin(s0)*s2*1000,10+abs(s3)*1500+fsin(s0*3)*s2*250,abs(s3)*4600+fsin(s0*2)*750*s2)"
			
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

	set CLEARFLAG=& set /a FCLEAR-=1 & if !FCLEAR! gtr 0 set CLEARFLAG=C
	set FLUSHFLAG=F& if !SPLIM!==0 set FLUSHFLAG=

	echo "cmdgfx: !CLRSKIP! fbox 0 0 db & !TMPIS! image img/!TMPIMG! 0 0 db -1 0,0 0 0 !W!,!H! & block 0 0,0,!W!,!H! 0,0 -1 0 0 !TS! !EXPRP:~1,-1! & !C16S! color16 0 -+jW & !FSKIP! text f 0 0 [FRAMECOUNT] 1,1 !BF! & !DS! line ? ? db 1,!DBGY!,500,!DBGY! & text f 0 0 !EXPRP:~1,-1! 1,!DBGY!" !FLUSHFLAG!f!FONT!:0,0,!W!,!H!!CLEARFLAG!
	set EXPRP=
	
	if exist explab.dat set /a MODE=-1 & set /P EXPR=<explab.dat & set /a CLRCNT=15 & set /a FCLEAR=5 & del /Q explab.dat >nul 2>nul & call :SETTITLE -1 -1 
	
	set /a MCNT+=1 & if !MCNT! geq 7 set /a A2+=1, MCNT=0

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
			
	if !KEY! neq 0 (
		if !KEY! leq 126 if !KEY! geq 40 set /A MKEY=!KEY!-40+1 & for %%M in (!MKEY!) do set LKEY="!SCHR:~%%M,1!"

		set /a NEXT=0 & (if !KEY! == 32 set /a NEXT=1) & (if !KEY! == 333 set /a NEXT=1) 
		if !NEXT! == 1 set /a FCLEAR=5 & set /A MODE+=1&(if !MODE! gtr !MAXMODE! set MODE=0)&set /a CLRCNT=10&call :SETTITLE !MSET! !MODE!
		if !KEY! == 331 set /a FCLEAR=5 & set /A MODE-=1&(if !MODE! lss 0 set MODE=!MAXMODE!)&set /a CLRCNT=10&call :SETTITLE !MSET! !MODE!

		if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz getconsoledim sw&set CMDWO=!errorlevel!&cmdwiz getconsoledim sh&set CMDHO=!errorlevel!&cmdwiz getwindowbounds x&set CMDXO=!errorlevel!&&cmdwiz getwindowbounds y&set CMDYO=!errorlevel!&cmdwiz fullscreen 1&if !errorlevel! lss 0 set LEG=1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0&if "!LEG!"=="1" mode !CMDWO!,!CMDHO!&cmdwiz setwindowpos !CMDXO! !CMDYO!)

		if !LKEY! == "m" set /a FCLEAR=5 & set /a MSET=1-MSET, MODE=0, CLRCNT=10 & call :SETTITLE !MSET! !MODE! & for %%a in (!MSET!) do set /a MAXMODE=!MM%%a!
		
		if !LKEY! == "d" set /a CLRCNT=15 & set /a DBG=1-DBG & set DS=&if !DBG!==0 set DS=rem
		if !LKEY! == "p" cmdwiz getch
		if !LKEY! == "t" set TS=-& set /a TRANSF+=1, CLRCNT=10 & (if !TRANSF! gtr 2 set /a TRANSF=0) & (if !TRANSF!==1 set TS=a:f???=??db,e???=??db,d???=??db,c???=??db,b???=??b2,a???=??b2,9???=??b2,8???=??b2,7???=??b1,6???=??b1,5???=??b1,4???=??b1,3???=??b0,2???=??b0,1???=??b0,0???=?0b1) & (if !TRANSF!==2 set TS=a:f???=??02,e???=??02,d???=??40,c???=??57,b???=??4d,a???=??4e,9???=??2a,8???=??6a,7???=??2b,6???=??7a,5???=??3d,4???=??3d,3???=??2d,2???=??2d,1???=??2e,0???=?02e)
		if !LKEY! == "c" set /a FCLEAR=5 & set C16S=skip&set /a C16=1-C16&if !C16!==1 set C16S=

		if !LKEY! == "i" set /a IMGCNT+=1&(if !IMGCNT! gtr 2 set /a IMGCNT=0)& set IMGSKIP=skip & set IMG=123.bmp& (if !IMGCNT! gtr 0 set IMGSKIP=) & (if !IMGCNT! gtr 1 set IMG=6hld.bmp)
		if !LKEY! == "T" set /a FCLEAR=5 & set /a USETHREADS=1-USETHREADS & (if !USETHREADS!==0 echo "" t1>servercmd.dat) & (if !USETHREADS!==1 echo "" t6>servercmd.dat)
		if !LKEY! == "w" set /a WRAP+=1 & (if !WRAP! gtr 2 set /a WRAP=0) & echo "" r!WRAP!>servercmd.dat
		if !LKEY! == "S" cmdwiz print !EXPR! > outExpr.txt 
		if !LKEY! == "f" set /a FCLEAR=5, CLRCNT=15 & set /a FPS=1-FPS & set FSKIP=& if !FPS!==0 set FSKIP=skip
		if !LKEY! == "W" set /a FCLEAR=5 & set /a SPLIM=1-SPLIM, WF=SPLIM*15 & title input:W!WF!

		if !LKEY! == "0" set BF=&set /a RESIZED=1, FONT=0, WMUL=2, HMUL=2, HADD=4
		if !LKEY! == "1" set BF=&set /a RESIZED=1, FONT=0, WMUL=2, HMUL=2, HADD=4
		if !LKEY! == "2" set BF=&set WMUL=2*4/6&set HMUL=2*6/8&set /a RESIZED=1, FONT=1, HADD=3
		if !LKEY! == "3" set BF=&set WMUL=2*4/8&set HMUL=2*6/8&set /a RESIZED=1, FONT=2, HADD=3
		if !LKEY! == "4" set BF=&set /a RESIZED=1, FONT=6, WMUL=1, HMUL=1, HADD=1
		if !LKEY! == "5" set BF=&set WMUL=2*4/12&set HMUL=2*6/16&set /a RESIZED=1, FONT=8, HADD=0
		if !LKEY! == "6" set BF=2&set WMUL=2&set HMUL=2*6/4&set FONT=d& set /a RESIZED=1, HADD=6
		if !LKEY! == "7" set BF=2&set WMUL=2*4/3&set HMUL=2*6/3&set FONT=c& set /a RESIZED=1, HADD=9
		if !LKEY! == "8" set BF=2&set FONT=b& set /a RESIZED=1, WMUL=4, HMUL=6, HADD=15
		if !LKEY! == "9" set BF=2&set FONT=a& set /a RESIZED=1, WMUL=8, HMUL=12, HADD=30
		
		if !KEY! == 13 set /a MODE=-1,USEDLAB+=1 & call :SETTITLE -1 -1 & start "Expression Lab" cmd /C %0 _EXPLAB >nul 2>nul & call :NOP
		if !KEY! == 27 set STOP=1
	)

	if "!RESIZED!"=="1" set /a W=SCRW*!WMUL!*rW/100+1, H=SCRH*!HMUL!*rH/100+2 & set /a FCLEAR=20, CLRCNT=20 & cmdwiz showcursor 0 & cmdwiz getfullscreen & if !errorlevel! == 2 set /a H+=HADD 
	
	set /a KEY=0
	set LKEY=""
)
if not defined STOP goto LOOP

if !USEDLAB! gtr 0 for /l %%a in (1,1,!USEDLAB!) do cmdwiz showwindow close "/w:Expression Lab">nul 2>nul
endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:SETTITLE
title !title:~1,-1! (%1 : %2)
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
set /a CPX=0, CPY=1
:GETCURSORLOOP
cmdwiz getcursorpos x
set /a TCPX=%errorlevel%
if %TCPX% neq 0 set /a CPX=%TCPX%
cmdwiz getcursorpos y
if %TCPX% neq 0 set /a CPY=%errorlevel%

cmdwiz delay 500
if exist setCp.dat if %CPX% neq 0 (
	cmdwiz delay 800
	cmdwiz getcursorpos x & set /a NPX=!errorlevel!
	cmdwiz getcursorpos y & set /a NPY=!errorlevel!
	set /a DELTA=NPX-CPX
	if !CPY! lss !NPY! if !NPY! gtr 1 set /a DELTA=NPX & cmdwiz getconsoledim w & set /a DELTA+=!errorlevel!-CPX
	if !DELTA! gtr 0 cmdwiz sendkey 0x25 p !DELTA!
	rem cmdwiz setcursorpos %CPX% %CPY% & rem Sets right cursor pos, but messes up the internal input pos for set /p
	del /Q setCp.dat >nul 2>nul
)
goto :GETCURSORLOOP
endlocal

:NOP
goto :eof
@end

WScript.CreateObject("WScript.Shell").SendKeys(WScript.Arguments(0));
