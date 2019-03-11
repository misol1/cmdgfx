# cmdgfx / cmdgfx_gdi / cmdgfx_input
Windows command line graphic primitives and 3d, for text based games/demos by Mikael Sollenborn (2016-2019)

## Comparison 

The main difference between cmdgfx and cmdgfx_gdi is that while the former outputs actual text into the cmd window buffer, the output of cmdgfx_gdi is not text but a bitmap, simulating text output.

Producing a bitmap instead of text may seem nonsensical, but there is a simple explanation: it is (usually) much faster! That is because the Windows API to output text to a console is very slow, as soon as there is more than one color in the output.

The cmdgfx_gdi executable is larger than cmdgfx, because bitmap font data is embedded inside the program. This means that while cmdgfx will use any current font set in the console window, cmdgfx_gdi only supports a small subset of embedded fonts: raster fonts 0-9, plus the specialized fonts a-c which are so called pixel fonts (1 character is 1 'pixel', font a is 1x1 size, font b 2x2 and font c 3x3). Apart from being faster and supporting pixel fonts, there are also a few other things cmdgfx_gdi can do that cmdgfx cannot (see list below).

Use cmdgfx:
  1. For single output, not animating in a loop (speed is not crucial)
  2. When the resulting characters actually need to be put into the text buffer
  3. When needing to use another font than the 9 raster fonts or pixel fonts
  4. If output is monochrome/single color (speed will be same or better)

Use cmdgfx_gdi:
  1. When speed is of the essence (when making animations)
  2. When needing to write pixels instead of characters
  3. When needing to write to desktop instead of current window (set flag U)
  4. When needing to place the output with pixel precision instead of character precision (set a flag, then use f flag)
  5. For advanced users, it is possible to get more than 16 color output by splitting the output into blocks and setting an individual palette for each
  6. For adcanced users, it is possible to use more than one font on a single screen, by splitting the output into blocks and using a different font for each

cmdgfx_input:

Used to process and forward input (key/mouse/resizing). Can be used as standalone program but in this context typically used in a pipe chain looking like:

cmdgfx_input | script.bat | cmdgfx
  

cmdgfx.exe
----------
```
CmdGfx v1.0 : Mikael Sollenborn 2016-2019

Usage: cmdgfx [operations] [flags] [fgpalette] [bgpalette]

Drawing operations (separated by &):

poly     fgcol bgcol char x1,y1,x2,y2,x3,y3[,x4,y4...,y24]
ipoly    fgcol bgcol char bitop x1,y1,x2,y2,x3,y3[,x4,y4...,y24]
gpoly    palette x1,y1,c1,x2,y2,c2,x3,y3,c3[,x4,y4,c4...,c24]
tpoly    image fgcol bgcol char transpchar/transpcol x1,y1,tx1,ty1,x2,y2,tx2,ty2,x3,y3,tx3,ty3[...,ty24]
image    image fgcol bgcol char transpchar/transpcol x,y [xflip] [yflip] [w,h]
box      fgcol bgcol char x,y,w,h
fbox     fgcol bgcol char x,y,w,h
line     fgcol bgcol char x1,y1,x2,y2 [bezierPx1,bPy1[,...,bPx6,bPy6]]
pixel    fgcol bgcol char x,y
circle   fgcol bgcol char x,y,r
fcircle  fgcol bgcol char x,y,r
ellipse  fgcol bgcol char x,y,rx,ry
fellipse fgcol bgcol char x,y,rx,ry
text     fgcol bgcol char string x,y
block    mode[:1233] x,y,w,h x2,y2 [transpchar] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from]
3d       objectfile drawmode,drawoption[,tex_x_offset,tex_y_offset,tex_x_scale,tex_y_scale]
         rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod
         face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]
insert   file
skip
rem

```

## Flags

Flags marked with - can be turned OFF in server by preceding it with -

Set flags in 4 ways:
1. If not using server, flags are the third argument after string of operations
2. If running as server, flags are also put after the operations
3. To force flag changes in server (skip queue), create file 'servercmd.dat' in start folder. Start file with operations within "", then blank space and flags
4. If 'I' flag has been set, window title can be set to send operations/flags. Title must be prefixed with 'output:'. Example: title output: "" e

Debug:
- \*-*/ d  Print entire line causing the error if error happens
- \*-*/ e  Ignore/hide all error messages
- \*-*/ E  Wait for key press after error

Input/timing (cmdgfx_input prefered):
- k  Return keys (in ERRORLEVEL, and in EL.dat if server on and o/O flag set)
  K  As above, but not persistent, and will *wait* for key press
- m[i]  Return input (mouse/key) info (in ERRORLEVEL, and in EL.dat if server on and o/O flags set). Set i to wait max i ms. Format of bit pattern: kkkkkkkkuyyyyyyyyxxxxxxxxxWwrlM where M=1 if mouse event, l=left click, r=right click, w/W=mouse wheel up/down, x/y=mouse coordinates, u=key up, k is keycode (0=no key)
- M[i]  As above, but reports mouse move even if no mouse key pressed
- u  Also send keyboard UP events for m and M flags
- wi  Wait i ms after each frame
- Wi  Wait up to i ms after each frame (use for smooth frame rate)
- z  Enable sleeping wait (for w and W flag). Uses less CPU but less smooth

Output:
  c:x,y,w,h,format,i  Capture buffer to file, as capture-i.gxy (i starts at 0 and increases). 0-6 params. Format=0 for txt format. Last param can force i
  f:x,y,w,h  Set output buffer position and size. 0-4 params
  n  Produce no output. Used to create a frame in several steps

3d:
  b  Clear Z-buffer (only makes sense if n flag was just used)
- B  Create Z-buffer (only 3d mode 5 supported if s flag not set)
  D  Clear all 3d objects in memory
  Li,j  Set z-light range to i,j. Used for 3d in mode 1. Default: 25,16
- N[i]  Auto center 3d objects. If i is set, enable auto scaling by i
  Ri  Rotation granularity for 3d. Default is 4, i.e. full circle is 360*4
- s  Z-buffer support for flat shade in 3d modes 0,1,4. Handles edge bug for pcx textures
- T  Support repeated texture coordinates (above 1.0)
  Zi  Set projection depth i for all 3d operations. Default: 500

Other:
  C  Clear frame counter (print using [FRAMECOUNT] in string for text op)
  Gi,j  Set maximum allowed width and height of gxy files. Default: 256,256
  p  Preserve the content of the cmd window text buffer when starting cmdgfx

Server:
  F  Flush the pipe input buffer between script and server
- i  If set, ignore the file 'servercmd.dat' even if present
- I  If set, support setting title to supply commands to cmdgfx
- J  When an input event happens, flush buffer between script and server
- o  Each frame, write return value (input events) to EL.dat
- O  Same as o, but only write to El.dat if an event happened (usually better)
  S  Enable server mode






cmdgfx_gdi.exe
--------------
```
CmdGfx_gdi v1.0 : Mikael Sollenborn 2016-2019

Usage: cmdgfx_gdi [operations] [flags] [fgpalette] [bgpalette]

Drawing operations (separated by &):

poly     fgcol bgcol char x1,y1,x2,y2,x3,y3[,x4,y4...,y24]
ipoly    fgcol bgcol char bitop x1,y1,x2,y2,x3,y3[,x4,y4...,y24]
gpoly    palette x1,y1,c1,x2,y2,c2,x3,y3,c3[,x4,y4,c4...,c24]
tpoly    image fgcol bgcol char transpchar/transpcol x1,y1,tx1,ty1,x2,y2,tx2,ty2,x3,y3,tx3,ty3[...,ty24]
image    image fgcol bgcol char transpchar/transpcol x,y [xflip] [yflip] [w,h]
box      fgcol bgcol char x,y,w,h
fbox     fgcol bgcol char x,y,w,h
line     fgcol bgcol char x1,y1,x2,y2 [bezierPx1,bPy1[,...,bPx6,bPy6]]
pixel    fgcol bgcol char x,y
circle   fgcol bgcol char x,y,r
fcircle  fgcol bgcol char x,y,r
ellipse  fgcol bgcol char x,y,rx,ry
fellipse fgcol bgcol char x,y,rx,ry
text     fgcol bgcol char string x,y
block    mode[:1233] x,y,w,h x2,y2 [transpchar] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from]
3d       objectfile drawmode,drawoption[,tex_x_offset,tex_y_offset,tex_x_scale,tex_y_scale]
         rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod
         face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]
insert   file
skip
rem

```
Syntax above is exactly the same as cmdgfx.exe, but listed again for clarity.

Below follows help sections where cmdgfx_gdi differs from cmdgfx:


cmdgfx_input.exe
----------
```
CmdGfx_input v1.0 : Mikael Sollenborn 2017-2019

Usage: cmdgfx_input [flags]

[flags]: 'k' forward last keypress, 'K' wait for/forward key, 'wn/Wn' wait/await n ms, 'm[wait]' forward key/PRESSED
         mouse events with optional wait, 'M[wait]' forward key/ALL mouse events with optional wait, 'z' sleep instead
         of busy wait, 'u' enable forwarding key-up events for M/m flag, 'n' send non-events, 'A' send all events,
         possibly several per wait (combined special keys not available), 'x' pad each message to be 1024 bytes,
         'i' ignore inputflags.dat, 'I' ignore title flags, 'R' report window size changes.

Flags can be modified during runtime by writing to 'inputflags.dat'. Precede a flag with '-' to cancel a previously set
flag. Exit the server by including a 'Q' or 'q' flag.

It is also possible to communicate with cmdgfx_input by setting the title of the current window with the prefix 'input:'
followed by one or more flags.

```

cmdwiz.exe
----------
```
CmdWiz (Unicode) v1.4 : Mikael Sollenborn 2015-2018
With contributions from Steffen Ilhardt and Carlos Montiers Aguilera

Usage: cmdwiz [getconsoledim setbuffersize getconsolecolor getch getkeystate
               flushkeys getquickedit setquickedit getmouse getch_or_mouse
               getch_and_mouse getcharat getcolorat showcursor getcursorpos
               setcursorpos print saveblock copyblock moveblock inspectblock
               playsound delay stringfind stringlen gettime await getexetype
               cache setwindowtransparency getwindowbounds setwindowpos
               setwindowsize getdisplaydim getmousecursorpos setmousecursorpos
               showmousecursor insertbmp savefont setfont gettitle getwindowstyle
               setwindowstyle gxyinfo getpalette setpalette fullscreen getfullscreen
               showwindow sendkey windowlist] [params]

Use "cmdwiz operation /?" for info on arguments and return values
```
