@fc datasize.h datasize_RGB.h>nul
@if not %errorlevel%==0 type datasize_RGB.h> datasize.h
make cmdgfx_RGB.exe
make cmdgfx_VT.exe
@strip cmdgfx_RGB.exe
@strip cmdgfx_VT.exe
