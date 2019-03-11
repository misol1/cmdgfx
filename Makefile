# Makefile for small gfx lib

OBJECTS = gfx.o r3d.o rgbcol.o bmap.o testlib.o outputText.o algebra.o tinyexpr.o
TARGET  = testlib.exe
OBJECTSLIB = gfx.o r3d.o bmap.o tinyexpr.o cmdgfx.o
TARGETLIB  = cmdgfx.exe
OBJECTSLIBGDI = gfx.o r3d.o bmap.o tinyexpr.o cmdgfx_gdi.o
TARGETLIBGDI  = cmdgfx_gdi.exe
INPUTLIB = cmdgfx_input.o
TARGETINPUT  = cmdgfx_input.exe
#CC      = cl
#CC      = C:\Dos\tcc\tcc32\tcc.exe
#CC      = gcc -O3 -Wall
CC      = gcc -O3 -Wno-trigraphs
CCFLAG  =

testlib.exe : $(OBJECTS)
	$(CC) $(CCFLAG) -o $(TARGET) $(OBJECTS) rc\testlib.o -lgdi32 -lwinmm

cmdgfx.exe : $(OBJECTSLIB)
	$(CC) $(CCFLAG) -o $(TARGETLIB) $(OBJECTSLIB) rc\cmdgfx.o

cmdgfx_gdi.exe : $(OBJECTSLIBGDI)
	$(CC) $(CCFLAG) -o $(TARGETLIBGDI) $(OBJECTSLIBGDI)  rc\cmdgfx_gdi.o -lgdi32

cmdgfx_input.exe : $(INPUTLIB)
	$(CC) $(CCFLAG) -o $(TARGETINPUT) $(INPUTLIB) rc\cmdgfx_input.o

cmdgfx_input.o : cmdgfx_input.c
	$(CC) $(CCFLAG) -c cmdgfx_input.c

testlib.o : testlib.c gfx.h bmap.h rgbcol.h r3d.h
	$(CC) $(CCFLAG) -c testlib.c

cmdgfx.o : cmdgfx.c gfx.h bmap.h rgbcol.h r3d.h
	$(CC) $(CCFLAG) -c cmdgfx.c

cmdgfx_gdi.o : cmdgfx.c gfx.h bmap.h rgbcol.h r3d.h
	$(CC) $(CCFLAG) -o cmdgfx_gdi.o -D GDI_OUTPUT -c cmdgfx.c

bmap.o : bmap.c bmap.h rgbcol.h gfx.h
	$(CC) $(CCFLAG) -c bmap.c

rgbcol.o : rgbcol.c rgbcol.h
	$(CC) $(CCFLAG) -c rgbcol.c

r3d.o : r3d.c r3d.h
	$(CC) $(CCFLAG) -c r3d.c

gfx.o : gfx.c gfx.h
	$(CC) $(CCFLAG) -c gfx.c
	
outputText.o : outputText.c outputText.h
	$(CC) $(CCFLAG) -c outputText.c

algebra.o : algebra.c algebra.h
	$(CC) $(CCFLAG) -c algebra.c
	
tinyexpr.o : tinyexpr.c tinyexpr.h
	$(CC) $(CCFLAG) -c tinyexpr.c

clean :
	rm *.o
#	@for %a in ($(OBJECTS) $(TARGET)) do del %a>nul
# 	@for %a in ($(OBJECTS) $(TARGET) *.bak *.lst *.obj) do del %a>nul
