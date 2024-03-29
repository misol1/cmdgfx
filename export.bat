@echo off
mkdir export
copy /Y *.bat export
del /Q export\makeall.bat export\emma.bat export\export.bat export\panic.bat export\cpmake.bat export\altmakeall.bat export\distrib.bat export\prepRc.bat export\makeRGB.bat
for %%a in (3dworld.dat 3dworld2.dat cmdgfx.exe cmdgfx_gdi.exe cmdwiz.exe 3dworld-maze.dat 3dGUI.dat 3dGUI2.dat 3dGUI-RGB.dat cmdgfx_input.exe cmdgfx_RGB.exe pixelfnt.exe cmdgfx_VT.exe cmdgfx_RGB_32.exe eextern.dll) do copy /Y %%a export
xcopy /Y /S /I img export\img
xcopy /Y /S /I objects export\objects
xcopy /Y /S /I games export\games
xcopy /Y /S /I legacy export\legacy
xcopy /Y /S /I BWin export\BWin
xcopy /Y /S /I data export\data
cd export
zip -r cmdgfx .
cd ..
