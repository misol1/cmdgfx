@fc datasize.h datasize_RGB_32.h>nul
@if not %errorlevel%==0 type datasize_RGB_32.h> datasize.h
@del /Q cmdgfx_RGB_32.exe >nul 2>nul
@move /Y cmdgfx_RGB.exe cmdgfx_RGB_64.exe 
@make cmdgfx_RGB.exe
@ren cmdgfx_RGB.exe cmdgfx_RGB_32.exe
@move /Y cmdgfx_RGB_64.exe cmdgfx_RGB.exe 
@strip cmdgfx_RGB_32.exe
