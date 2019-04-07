@fc datasize.h datasize_default.h>nul
@if not %errorlevel%==0 type datasize_default.h> datasize.h
make testlib.exe
make cmdgfx.exe
make cmdgfx_gdi.exe
make cmdgfx_input.exe
@strip cmdgfx.exe
@strip cmdgfx_gdi.exe
@strip cmdgfx_input.exe
@strip testlib.exe
