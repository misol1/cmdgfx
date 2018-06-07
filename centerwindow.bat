@cmdwiz getdisplaydim w
@set SW=%errorlevel%
@cmdwiz getdisplaydim h
@set SH=%errorlevel%
@cmdwiz getwindowbounds w
@set WINW=%errorlevel%
@cmdwiz getwindowbounds h
@set WINH=%errorlevel%
@set /a WPX=%SW%/2-%WINW%/2,WPY=%SH%/2-%WINH%/2
@if not "%1"=="" set /a WPX+=%1
@if not "%2"=="" set /a WPY+=%2
@cmdwiz setwindowpos %WPX% %WPY%
@set SW=&set SH=&set WINW=&set WINH=&set WPX=&set WPY=
