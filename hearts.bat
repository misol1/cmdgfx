
@echo off
::cmdgfx "block 0 0,0,160,70 0,0 -1 0 0 - store((x-80)/13,1)+store((y-35)/13,2)+(16*sin(s1)*sin(s1)*sin(s1)+(13*cos(s2)-5*cos(2*s2)-2*cos(3*s2)-cos(4*s2)))*2

::cmdgfx "fbox 1 0 A 100,0,100,70 & block 0 0,0,200,70 0,0 -1 0 1 - - store(x/10,1)+store((y+2)/2,2)+16*s2*sin(s1)*sin(s1)*sin(s1)+50 store(x/10,1)+store((y+2)/2,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+35"

::cmdgfx "block 0 100,0,100,70 100,0 -1 0 0 ????=??03 (y+1) & block 0 0,0,200,70 0,0 -1 0 1 - - store(x/15,1)+store((y+3)/3,2)+16*s2*sin(s1)*sin(s1)*sin(s1)+50 store(x/15,1)+store((y+3)/3,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+35"

::cmdgfx "block 0 100,0,500,70 100,0 -1 0 0 ????=??03 (y+1) & block 0 0,0,500,70 0,0 -1 0 1 - - store(sin(x/3),1)+store((y+16)/16,2)+16*s2*s1*s1*s1+50 store(x/3,1)+store((y+16)/16,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+35 & fbox 0 0 0 100,0,500,70"

::cmdgfx "block 0 100,0,500,70 100,0 -1 0 0 ????=??03 (y+1) & block 0 0,0,500,70 0,0 -1 0 1 - - store(sin(x/2),1)+store((y+15)/15,2)+16*s2*s1*s1*s1+50 store(x/2,1)+store((y+15)/15,2)+13*s2*cos(s1)-5*s2*cos(s1*2)-2*s2*cos(s1*3)-s2*cos(4*s1)+35 & fbox 0 0 0 100,0,500,70"

::cmdgfx "block 0 100,0,500,70 100,0 -1 0 0 ?1??=d403,?2??=c403,?3??=4003,????=0000 (y+1) & block 0 0,0,500,70 0,0 -1 0 1 - - store(sin(x/2),1)+store((y+15)/15,2)+16*s2*s1*s1*s1+50 store(x/2,1)+store((y+15)/15,2)+13*s2*cos(s1)-5*s2*cos(s1*2)-2*s2*cos(s1*3)-s2*cos(4*s1)+35 & fbox 0 0 0 100,0,500,70"

::mode 100,70 & cmdgfx_gdi "block 0 100,0,500,70 100,0 -1 0 0 ????=??03 (y+1) & block 0 0,0,500,70 0,0 -1 0 1 - - store(sin(x/3),1)+store((y+16)/16,2)+16*s2*s1*s1*s1+50 store(x/3,1)+store((y+16)/16,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+35" f6:0,0,500,70,100,70

::mode 100,70 & cmdgfx_gdi "block 0 100,0,500,70 100,0 -1 0 0 ????=??03 (y+1+x) & block 0 0,0,500,70 0,0 -1 0 1 - - store(sin(x/3),1)+store((y+16)/16,2)+16*s2*s1*s1*s1+50 store(x/3,1)+store((y+16)/16,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+35" f6:0,0,500,70,100,70

::mode 100,70 & cmdgfx_gdi "block 0 100,0,500,70 100,0 -1 0 0 ????=??03 (y+1+x) & block 0 0,0,500,70 0,0 -1 0 1 - - store(sin(x/3),1)+store((y+16)/16,2)+16*s2*s1*s1*s1+50 store(x/3,1)+store((y+16)/16,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+35" f6:0,0,500,70,100,70 000000,110000,220000,330000,440000,550000,660000,770000,880000,990000,aa0000,bb0000,cc0000,dd0000,ee0000

::mode 100,70 & cmdgfx_gdi "block 0 100,0,500,70 100,0 -1 0 0 ????=??03 (y+1+x)%%16 & block 0 0,0,500,70 0,0 -1 0 1 - - store(sin(x/3),1)+store((y+16)/16,2)+16*s2*s1*s1*s1+50 store(x/3,1)+store((y+16)/16,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+35" f6:0,0,500,70,100,70 000000,bbddaa,220000,993333,440000,550000,660000,cc0000,880000,990000,aa0000,bb0000,ff0000,dd0000,aa9999,cc0000

goto :GDI

setlocal enableDelayedExpansion
cmdwiz setfont 6 & mode 100,70 & call centerwindow.bat 0 -15
cmdwiz setpalette 000000,440000,550000,660000,cc0000,880000,990000,aa0000,bb0000,ff0000,dd0000,aa9999,cc0000,990000,660000,330000
set PAL=0123456789abcdef
for /l %%a in () do (
	cmdgfx "block 0 100,0,500,70 100,0 -1 0 0 ????=??03 (y+1) & block 0 0,0,500,70 0,0 -1 0 1 - - store(sin(x/3),1)+store((y+16)/16,2)+16*s2*s1*s1*s1+50 store(x/3,1)+store((y+16)/16,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+35" f:0,0,500,70,100,70k !PAL!
	if !errorlevel! == 27 exit
	set PAL=!PAL:~-1!!PAL:~0,-1!
)

:GDI
setlocal enableDelayedExpansion
cmdwiz setfont 6 & mode 100,70 & set /a W=100, H=70
call centerwindow.bat 0 -15 & call prepareScale.bat 6 1
set /a W5=W*5
set PAL=000000,440000,550000,660000,cc0000,880000,990000,aa0000,bb0000,ff0000,dd0000,aa9999,cc0000,990000,660000,330000
for /l %%a in () do (
	cmdgfx_gdi "block 0 !W!,0,!W5!,!H! !W!,0 -1 0 0 ????=??03 (y+1) & block 0 0,0,!W5!,!H! 0,0 -1 0 1 - - store(sin(x/3),1)+store((y+16)/16,2)+16*s2*s1*s1*s1+!W!/2 store(x/3,1)+store((y+16)/16,2)+13*s2*cos(s1)-5*cos(s1*2)-2*cos(s1*3)-cos(4*s1)+!H!/2" f6:0,0,!W5!,!H!,!W!,!H!k !PAL! 000000,400000,800000,b00000
	if !errorlevel! == 27 exit
	set PAL=!PAL:~-6!,!PAL:~0,-7!
)

cmdwiz getch

::nice look
::cmdgfx_gdi "block 0 0,0,220,75 0,0 -1 0 0 - sin(y/13)*15*cos(x/16*y/34)*15+15 cos(x/5)*35+35 sin(y/8)*22+24 from" - 000000,000022,000044,111166,222266,333388,4444aa,6666bb,8888cc,aaaadd,ccccee,eeeecc,ddddaa,aaaa66,888833,444411
