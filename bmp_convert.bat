@echo off & setlocal enabledelayedexpansion

if "%~2"=="" echo Usage: bmp_convert image.bmp gray^|invert^|mirror^|flip^|contrast(1)^|poster(1)^|light(1)^|saturate(1)^|soften(1)^|mono(1)^|custom(1)^|blend(2)^|noise(2)^|pixelate(2)^|color(3)^|tint(3)^|border(4)^|replacecol(7) [value [value2 [value3 ...]]] & goto :eof
if not "%~x1"==".bmp" echo Error: Only bmp files supported & goto :eof
if not exist "%~1" echo Error: No such file & goto :eof

set /a V1=0, V2=0, V3=0, V4=0, V5=0, V6=0, V7=0, XF=0, YF=0
if not "%~3"=="" set V1=%3
if not "%~4"=="" set V2=%4
if not "%~5"=="" set V3=%5
if not "%~6"=="" set V4=%6
if not "%~7"=="" set V5=%7
if not "%~8"=="" set V6=%8
if not "%~9"=="" set V7=%9

set fName="%~1"
set XTRA=""
for /F "tokens=2,4" %%a in ('cmdwiz gxyinfo %fName%') do set /a W=%%a,H=%%b,WW=%%a*2,HH=%%b*2
set fName=%fName: =~%

cmdgfx_RGB "image %fName:~1,-1% 0 0 0 -1 0,0" fa:0,0,%W%,%H%

set OP="NOP"
if %2==contrast set OP="store(fgcol(x,y),0)+shade(s0,(fgr(s0)-128)*%V1%,(fgg(s0)-128)*%V1%,(fgb(s0)-128)*%V1%)"
if %2==gray 	set OP="store(fgcol(x,y),0)+store((fgr(s0)*0.2126+fgg(s0)*0.7152+fgb(s0)*0.0722),1)+makecol(s1,s1,s1)"
if %2==invert 	set OP="store(fgcol(x,y),0)+makecol(255-fgr(s0),255-fgg(s0),255-fgb(s0))"
if %2==poster 	set OP="store(fgcol(x,y),0)+makecol(floor(fgr(s0)/%V1%)*%V1%,floor(fgg(s0)/%V1%)*%V1%,floor(fgb(s0)/%V1%)*%V1%)"
if %2==light 	set OP="shade(fgcol(x,y),%V1%,%V1%,%V1%)"
if %2==color 	set OP="shade(fgcol(x,y),%V1%,%V2%,%V3%)"
if %2==tint 	set OP="store(fgcol(x,y),0)+makecol(fgr(s0)*%V1%,fgg(s0)*%V2%,fgb(s0)*%V3%)"
if %2==mirror 	set OP=""&set XF=1
if %2==flip 	set OP=""&set YF=1
if %2==saturate set OP="store(fgcol(x,y),0)+store((fgr(s0)*0.2126+fgg(s0)*0.7152+fgb(s0)*0.0722),1)+makecol(max(min(-s1*%V1%+fgr(s0)*(1+%V1%),255),0),max(min(-s1*%V1%+fgg(s0)*(1+%V1%),255),0),max(min(-s1*%V1%+fgb(s0)*(1+%V1%),255),0))"
if %2==replacecol set OP="store(fgcol(x,y),0)+store(lss(abs(fgr(s0)-%V2%)+abs(fgg(s0)-%V3%+abs(fgb(s0)-%V4%)),(%V1%+1)),1)+s1*makecol(%V5%,%V6%,%V7%)+(1-s1)*s0"
if %2==soften set OP="store(fgcol(x,y),0)+store(fgcol(x-1,y),1)+store(fgcol(x+1,y),2)+store(fgcol(x,y-1),3)+store(fgcol(x,y+1),4)+makecol((fgr(s0)+fgr(s1)+fgr(s2)+fgr(s3)+fgr(s4))/5,(fgg(s0)+fgg(s1)+fgg(s2)+fgg(s3)+fgg(s4))/5,(fgb(s0)+fgb(s1)+fgb(s2)+fgb(s3)+fgb(s4))/5)"& if %V1% gtr 1 set /a V1-=1 & for /L %%a in (1,1,!V1!) do set XTRA="!XTRA:~1,-1! & block 0 0,0,%W%,%H% 0,0 -1 %XF% %YF% - !OP:~1,-1!"
if %2==noise if %V2%==0	set OP="shade(fgcol(x,y),random()*(%V1%*2)-%V1%,random()*(%V1%*2)-%V1%,random()*(%V1%*2)-%V1%)"
if %2==noise if %V2% gtr 0 set OP="store(random()*(%V1%*2)-%V1%,0)+shade(fgcol(x,y),s0,s0,s0)"
if %2==pixelate set OP=""& set XTRA="& block 0 0,0,%W%,%H% 0,0,%V1%,%V2% & block 0 0,0,%V1%,%V2% 0,0,%W%,%H%"
if %2==blend set OP=""& set fName2="%~3"&set fName2=!fName2: =~!&set XTRA="& image !fName2:~1,-1! 0 0 0 -1 %W%,0 0 0 %W%,%H% & block 0,%V2% %W%,0,%W%,%H% 0,0"
if %2==mono  set OP="store(fgcol(x,y),0)+store((fgr(s0)*0.2126+fgg(s0)*0.7152+fgb(s0)*0.0722),1)+gtr(s1,%V1%)*makecol(255,255,255)"
if %2==border  set OP="store(lss(x,%V1%)+lss(y,%V1%)+gtr(x,!W!-%V1%)+gtr(y,!H!-%V1%),0)+gtr(s0,0)*makecol(%~4,%~5,%6)+fgcol(x,y)*eq(s0,0)"
if %2==custom set OP=""& set XTRA="& %~3"

if %OP%=="NOP" echo Error: No such operation & goto :eof

cmdgfx_RGB "image %fName:~1,-1% 0 0 0 -1 0,0 & block 0 0,0,%W%,%H% 0,0 -1 %XF% %YF% - %OP:~1,-1% %XTRA:~1,-1%" fa:%W%,0,%WW%,%H%,%W%,%H%c:0,0,%W%,%H%,2

move /Y capture-0.bmp "%~dpn1-2%~x1" > nul
echo.
echo Converted image saved to input folder as: %~n1-2%~x1

endlocal
