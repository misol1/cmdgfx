# cmdgfx / cmdgfx_gdi / cmdgfx_RGB / cmdgfx_input
Windows command line graphic primitives and 3d, for text based games/demos by Mikael Sollenborn (2016-2019)

Initially, cmdgfx was made to be used with Batch scripts. There is, however, nothing that stops using other scripting languages as well, such as Jscript or Python. In fact, doing so will increase speed drastically. In several provided examples in the archive (marked with the postfix '-js'), a hybrid solution is used for increased speed, where Batch does the initial setup, and the rest of the script uses Jscript.

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
  4. When needing to place the output with pixel precision instead of character precision (set 'a' flag, then use 'f' flag)
  5. For advanced users, it is possible to get more than 16 color output by splitting the output into blocks and setting an individual palette for each
  6. For advanced users, it is possible to use more than one font on a single screen, by splitting the output into blocks and using a different font for each

cmdgfx_RGB : The main difference between cmdgfx_RGB and cmdgfx_gdi is that the former can read/write 24 bit RGB colors. It can also use 24 bit BMP files as input for images, textures etc. Colors are stored as 24-bit RRGGBB values, which is something that e.g. the block colExpr has to take into account to produce meaningful values.

Only use cmdgfx_RGB if RGB output is actually needed. The program reads/writes about 8 times as much data as cmdgfx/cmdgfx_gdi, and is therefore significantly slower. On top of that, it may have early version bugs and issues.

cmdgfx_input:

Used to process and forward input (key/mouse/resizing). Can be used as standalone program but in this context typically used in a pipe chain looking like:

cmdgfx_input | script.bat | cmdgfx
  
There are many example scripts in the archive which shows this usage, as it is the recommended way to handle input for scripts using cmdgfx.

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
block    mode[:1233] x,y,w,h x2,y2[,w2,h2[,rz]] [transpchar] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from]
3d       objectfile drawmode,drawoption[,tex_x_offset,tex_y_offset,tex_x_scale,tex_y_scale]
         rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod
         face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]
insert   file
skip
rem

Arguments within brackets are optional, but if used they must be written in the given order from left to right. For example, to set [xflip] for the block operation, [transpchar] must be specified first.

'cmdgfx /? operation' to see operation info, e.g. 'cmdgfx /? fbox'

'cmdgfx /? flags' for information about flags.

'cmdgfx /? server' for info on running as server.

'cmdgfx /? palette' for info on setting the color palette.

'cmdgfx /? compare' for a comparison of cmdgfx and cmdgfx_gdi.

```

## Flags

Flags marked with - can be turned OFF in server by preceding it with -

Set flags in 4 ways:
1. If not using server, flags are the third argument after string of operations
2. If running as server, flags are also put after the operations
3. To force flag changes in server (skip queue), create file 'servercmd.dat' in start folder. Start file with operations within "", then blank space and flags
4. If 'I' flag has been set, window title can be set to send operations/flags. Title must be prefixed with 'output:'. Example: title output: "" e

Debug:
- \- d  Print entire line causing the error if error happens
- \- e  Ignore/hide all error messages
- \- E  Wait for key press after error

Input/timing (cmdgfx_input prefered):
- \- k  Return keys (in ERRORLEVEL, and in EL.dat if server on and o/O flag set)
-   K  As above, but not persistent, and will *wait* for key press
- \- m[i]  Return input (mouse/key) info (in ERRORLEVEL, and in EL.dat if server on and o/O flags set). Set i to wait max i ms. Format of bit pattern: kkkkkkkkuyyyyyyyyxxxxxxxxxWwrlM where M=1 if mouse event, l=left click, r=right click, w/W=mouse wheel up/down, x/y=mouse coordinates, u=key up, k is keycode (0=no key)
- \- M[i]  As above, but reports mouse move even if no mouse key pressed
- \- u  Also send keyboard UP events for m and M flags
- \- wi  Wait i ms after each frame
- \- Wi  Wait up to i ms after each frame (use for smooth frame rate)
- \- z  Enable sleeping wait (for w and W flag). Uses less CPU but less smooth

Output:
-  c:x,y,w,h,format,i  Capture buffer to file, as capture-i.gxy (i starts at 0 and increases). 0-6 params. Format=0 for txt format. Last param can force i
-  f:x,y,w,h  Set output buffer position and size. 0-4 params
-  n  Produce no output. Used to create a frame in several steps

3d:
-   b  Clear Z-buffer (only makes sense if n flag was just used)
- \- B  Create Z-buffer (only 3d mode 5 supported if s flag not set)
-   D  Clear all 3d objects in memory
-   Li,j  Set z-light range to i,j. Used for 3d in mode 1. Default: 25,16
- \- N[i]  Auto center 3d objects. If i is set, enable auto scaling by i
-   Ri  Rotation granularity for 3d. Default is 4, i.e. full circle is 360*4
- \- s  Z-buffer support for flat shade in 3d modes 0,1,4. Handles edge bug for pcx textures
- \- T  Support repeated texture coordinates (above 1.0)
-   Zi  Set projection depth i for all 3d operations. Default: 500

Other:
-  C  Clear frame counter (print using [FRAMECOUNT] in string for text op)
-  Gi,j  Set maximum allowed width and height of gxy files. Default: 256,256
-  p  Preserve the content of the cmd window text buffer when starting cmdgfx

Server:
-   F  Flush the pipe input buffer between script and server
- \- i  If set, ignore the file 'servercmd.dat' even if present
- \- I  If set, support setting title to supply commands to cmdgfx
- \- J  When an input event happens, flush buffer between script and server
- \- o  Each frame, write return value (input events) to EL.dat
- \- O  Same as o, but only write to El.dat if an event happened (usually better)
-   S  Enable server mode


## Server

Running cmdgfx as a server has several advantages, mostly regarding speed. The overhead of running an executable each frame disappears, and 3d objects are kept in memory and don't have to be re-read with each use. Server functionality also presents some problems, such as dealing with asynchronicity and input lag.

In order to run as server, the S flag must be set, and the program needs to be last in a pipe chain, such as: call program.bat | cmdgfx.exe  S . For practical purposes, it is a better idea to have the script call itself this way than to have to type it manually each time. There are many example batch scripts included with this program that show how do to this.

To send operations from the script to the program, use the echo command with a prefix of 'cmdgfx:' within quotes (optionally followed by flags and palette(s)), e.g: echo "cmdgfx: fbox 9 0 A". If the string sent does not have the prefix, the server simply prints it to stdout and otherwise ignores it. It is also possible to send operations either by writing (without 'cmdgfx' prefix) to the file 'servercmd.dat', or (if I flag set) by setting the title of the window, prefixed with 'output:'. These two methods have the advantage that they bypass the frame queue over the pipe and are processed immediately.

Setting flags: see the separate help section for flags. Note that flags can be disabled by preceding with -.

Dealing with input lag: because the batch script may execute faster than cmdgfx, a queue of frames to render may build up over the pipe, which can result in input lag. Actually, the best way to deal with this is to use the separate 'cmdgfx_input' program to handle input, because when put at the beginning of the pipe chain (like: cmdgfx_input.exe m0nW10 | call program.bat | cmdgfx  S) it can control the speed of the batch script, preventing it from running faster than the server. Most of the example scripts included with the program use this approach. Without cmdgfx_input, the best approach is to set the O flag (see flag section), and send in extra data (~2000 characters) prefixed by 'skip' with each call to the server to fill up the pipe buffer to prevent the server from lagging behind.

Quitting the server: To exit the server, use echo as usual but follow 'cmdgfx:' with 'quit'. Using servercmd.dat or setting the title is also supported.


## Palette

Unlike cmdgfx_gdi, setting the palette for cmdgfx does not set new RGB colors. Instead, it rearranges the existing palette indices of the 16 colors. To actually set RGB colors for cmdgfx, use the program 'cmdwiz' with the 'setpalette' operation.

The foreground palette for cmdgfx is set as parameter 3, always following flags (use - to set no flags). The background palette can also be set as parameter 4 (it is NOT copied from parameter 3 if omitted).

All 16 color indices can potentially be rearranged, but does not have to be.

The default palette looks like 0123456789abcdef, which means index 0 is color 0, index 10 is color 10(a) etc. As an example, to keep index 0 and 1 as black and dark blue, but set index 2 to light blue, index 3 to cyan, and index 4 to white, use 019bf as palette.

If runninng as server, default palette can be restored by using - as palette.

## Operations

### Poly

Poly - draw a filled polygon of characters

Syntax: poly fgcol bgcol char x1,y1,x2,y2,x3,y3[,x4,y4...,y24]

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

A minimum of 3 coordinates (max 24) must be specified to draw a polygon.

The poly operation cannot properly draw self-intersecting polygons. For that, use the ipoly operation.

### Ipoly

Ipoly - draw a filled polygon of characters (supporting self-intersection)

Syntax: ipoly fgcol bgcol char bitop x1,y1,x2,y2,x3,y3[,x4,y4...,y24]

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

Except for the 3d operation, ipoly is the only operation that supports bit operations (bitop is only used for color, not char).

Possible bitop values: 0=Normal, 1=Or, 2=And, 3=Xor, 4=Add, 5=Sub, 6=Sub-n, 7=regular

A minimum of 3 coordinates (max 24) must be specified to draw a polygon.

Note that ipoly can be used to simulate other operations such as fbox if bitop is needed. Fcircle, fellipse, line, and pixel can also be simulated with ipoly, though it is slightly cumbersome.

### Gpoly

Gpoly - draw a goraud-shaded polygon of characters

Syntax: gpoly palette x1,y1,c1,x2,y2,c2,x3,y3,c3[,x4,y4,c4...,c24]

The 'palette' should be a number of fcol+bgcol+char combinations (all in hexadecimal notation), typically gradually going from one color to the next, separated by '.' An example of a 5 step palette fading from black to light blue would be 10b0.10b1.10db.19b1.1920

A minimum of 3 coordinates (max 24) must be specified to draw a polygon. The third argument per coordinate (cn), is an index number into the palette used, where 0 denotes the first index, and n+1 denotes the last. Thus, a full use of the above palette for a triangle polygon could look like: gpoly 10b0.10b1.10db.19b1.1920 2,2,0, 60,2,2, 2,30,5

The gpoly operation cannot draw self-intersecting polygons.

### Tpoly

Tpoly - draw an affine texture-mapped polygon of characters

Syntax: tpoly image fgcol bgcol char transpchar/transpcol x1,y1,tx1,ty1,x2,y2,tx2,ty2,x3,y3,tx3,ty3[...,ty24]

'filename' should point to a gxy file, a 16 color pcx file, or any other (preferably text) file.

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Unlike the image operation, fgcol and bgcol are not ignored but instead *added* to the texture's foreground and background colors. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position. Precede fgcol or bgcol with '-' to force using that color instead of the colors in the image.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Note that char is ignored unless the image is a pcx file. Use '?' to keep the character in the buffer at each position.

A minimum of 3 coordinates (max 24) must be specified to draw a polygon. For each coordinate you must also specify x and y floating point texture coordinates. 0,0 is the top left coordinate and 1,1 is the bottom right. It is also possible to repeat the texture in x and/or y by specifying a value larger than 1, i.e. 2.5 to repeat the texture 2.5 times. Unlike the 3d operation, the 'T' flag does not have to be set for this to work properly.

The tpoly operation cannot draw self-intersecting polygons.

### Image 

Image - draw an image or text file of characters

Syntax: image filename fgcol bgcol char transpchar/transpcol x,y [xflip] [yflip] [w,h]

'filename' should point to a gxy file, a 16 color pcx file, or any other (preferably text) file.

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' for fgcol to keep the foreground color in the buffer at each position, and use '?' for bgcol to keep the background color in the buffer at each position. Precede fgcol and/or bgcol with '-' to force the color used. Precede fgcol with '\\' to ignore/type out all gxy control codes inside the file.

Note that fgcol only has effect for txt files and bgcol will have no effect for a gxy or pcx file (unless forcing fgcol and/or bgcol with '-', or if using '?').

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position. For a gxy file or text file, the char argument has no effect unless '?' is used.

'transpchar' or 'transpcol' can be used to make part of the image transparent. For a gxy file and text file, set 'transpchar' to either a char or a two-digit hexadecimal character to make that character transparent. For a pcx file, set 'transpcol' to 0-15 to make that color transparent.

X and y are column and row coordinates with 0,0 as top left.

Both 'xflip' and 'yflip' are normally 0. Set 'xflip' to 1 to flip the image horizontally, and set 'yflip' to 1 to flip the image vertically.

Specify 'w' and 'h' (width and height) to scale the image to the given width and height. Negative values are not allowed.

### Box

Box - draw an outline rectangle of characters

Syntax: box fgcol bgcol char x,y,w,h

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

X and y are column and row coordinates with 0,0 as top left. A width and height of 0 still draws one single character. Negative width and/or height is also accepted.

### Fbox

Fbox - draw a rectangle filled with characters

Syntax: fbox fgcol bgcol char [x,y,w,h]

If the last four arguments are omitted, fbox fills the entire buffer.

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

X and y are column and row coordinates with 0,0 as top left. A width and height of 0 still draws one single character. A negative width or height will make the box invisible.

### Line

Line - draw a line (or bezier line) of characters

Syntax: line fgcol bgcol char x,y,x2,y2 [bezierPx1,bPy1[,...,bPx6,bPy6]]

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

X and y are column and row coordinates with 0,0 as top left. The line is drawn from x1,y1 to x2,y2.

To draw a bezier (curved) line instead of a straight line, specify atleast 1 and up to 6 control points.

### Pixel

Pixel - draw a single character

Syntax: pixel fgcol bgcol char x,y

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

X and y are column and row coordinates with 0,0 as top left.

### Circle

Circle - draw an outlined circle of characters

Syntax: circle fgcol bgcol char x,y,radius

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

X and y are column and row coordinates with 0,0 as top left. The given position is used as the center of the circle. A radius of 0 still draws one single character. A negative radius gives the same result as a positive radius.

Note that unless the font used has the same pixel width and height (such as bitmap font 2), the circle will not look perfectly round. Therefore it is often preferable to use an ellipse instead.

### Fcircle

Fcircle - draw an filled circle of characters

Syntax: fcircle fgcol bgcol char x,y,radius

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

X and y are column and row coordinates with 0,0 as top left. The given position is used as the center of the circle. A negative radius gives the same result as a positive radius.

Note that unless the font used has the same pixel width and height (such as bitmap font 2), the circle will not look perfectly round. Therefore it is often preferable to use an ellipse instead.

### Ellipse

Ellipse - draw an outlined ellipse of characters

Syntax: ellipse fgcol bgcol char x,y,rx,ry

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

X and y are column and row coordinates with 0,0 as top left. The given position is used as the center of the ellipse. Rx and ry are the x and y radius. Rx and ry of 0 still draws one single character. Negative radius values give the same result as positive ones.

### Fellipse

Fellipse - draw a filled ellipse of characters

Syntax: fellipse fgcol bgcol char x,y,rx,ry

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' to keep the foreground AND background color in the buffer at each position.

Char can be specified either as a character, or as a hexadecimal ASCII value in the range 0-255. Use '?' to keep the character in the buffer at each position.

X and y are column and row coordinates with 0,0 as top left. The given position is used as the center of the ellipse. Rx and ry are the x and y radius. Negative radius values give the same result as positive ones.

### Text

Text - write a formatted text string

Syntax: text fgcol bgcol char string x,y

Fgcol and bgcol values range from 0-15 and can be specified either as decimal or hex. Use 'u' and 'U' for current foreground or background color of the cmd window. Use '?' for fgcol to keep the foreground color in the buffer at each position, and use '?' for bgcol to keep the background color in the buffer at each position. Precede fgcol and/or bgcol with '-' to force the color used. Precede fgcol with '\\' to ignore/type out all gxy control codes inside the text.

Char has no meaning for the text operation, unless '?' is used to keep the character in the buffer at each position.

The 'string' allows formatting text output using the same control codes used in gxy files. Note that it is *not* possible to write blank spaces in the string. Instead, spaces must be written as underscores (_), or as \\g20, or as \\- to skip writing the character. To actually write an underscore in a string, use the Ascii code formatting \\g5f

The following gxy control codes are supported in the string:

- \\r: restore previous fgcol and bgcol
- \\gxx: ascii character in hex (xx)
- \\n: newline (new line starts from initial x position)
- \\-: skip character (transparent)
- \\\\  : print \\  
- \\xx: fgcol and bgcol in hex, e.g. \\A0 for green text on black background. Use 'k' to keep the current fgcol and/or bgcol, and 'u' and 'U' to use current foreground/background color of the cmd window

Apart from blank space, a few other characters must be written using control codes, including & (\\g26), " (\\g22), and possibly ! (\\g21) and % (\\g25)

X and y are column and row coordinates with 0,0 as top left.

### Block

Block - copy, move, and transform a block of characters

Syntax: block mode[:1233] x,y,w,h x2,y2[,w2,h2[,rz]] [transpchar/transpcol] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from] [mvx,mvy,mvw,mvh]

In its most simple form, the block operation is used to copy or move a rectangular block of characters from one place to another. For example, to copy a block of character from position 10,10 with width and height of 5,5 to position 0,0, use: block 0 10,10,5,5 0,0

mode[:1233]  Essentially, there are two modes: 0=copy and 1=move, but also 2=copy and 3=move (see transparency below). If using move (mode 1 or 3), we can optionally specify the character to fill the empty area after the move (default is blank space with color 7 and background color 0). In order to make a block move and fill in with exclamation points (ASCII hex value 21), with color 15(f) and background color 4, use: block 1:f421 10,10,5,5 0,0

x,y,w,h x2,y2[,w2,h2[,rz]]: X and y are column and row coordinates with 0,0 as top left. X2,y2 is destination. Negative coordinates are ok, but not negative width/height. Optionally, the block can be scaled by setting w2 and h2, as well as rotated with rz (only 90,180,270 degrees supported). Scaling is done before rotation.

[transpchar/transpcol]: when making the copy or move, either a character (mode 0 and 1) or a foreground color (mode 2 and 3) can be transparent, i.e. not copied. If no transparency is needed, specify -1.

[xflip] [yflip]: the copied block can be reversed(flipped) in x and/or y. Specify 1 instead of 0 for each to do so.

[transform]: The block operation allows per-character search and replace functionality. A transform string follows the format 1233=1233,... and the characters used are 0-f, ?=any, +=add 1, -=minus 1. To take all blank spaces (hex 20) with color 5 and bgcolor 1, and replace with A(hex 41) with color 9 and 0, the transform string would look like: 2051=4190. To also change all B's(42) to C's(43), regardless of color, ? would be used to disregard color(s), and get the string: 2051=4190,42??=43??. Finally, to take all characters from 40-4f(@ and A-O) and keep it, BUT increase the color and decrease the bgcolor, the string would be: 2051=4190,42??=43??,4???=??+-. Note that characters that do not fit any rules are left as-is, and that rules are checked from left to right only until the FIRST match is made. To do a catch-all at the end and transform all remaining characters to black spaces(20), use: 2051=4190,42??=43??,4???=??+-,????=2000. Note that + and - can also be used for characters (++ or --), and that ? can be used for color AND/OR bgcolor.

[colExpr]: The block operation allows using mathematical expressions on a per-character basis to change color/bgcolor. One would typically want to produce output in the range 0-15 (for color 0-15 and bgcolor 0), or 0-255 (color 0-15 in low byte, bgcolor 0-15 in high byte). A colExpr can also be combined with a transform, which is applied after the expression. Apart from regular math operations, expressions can also use standard math functions such as: sin, cos, abs, asin, pow, pi, tan, atan, log, floor, etc, plus added functions random() to make random number 0..1, eq(n,n2) return 1 if n=n2 otherwise 0, neq(n,n2) return 1 if NOT n=n2 otherwise 0, gtr(n,n2) return 1 if n>n2, lss(n,n1) return 1 if n<n2, char(xp,yp) return character value at xp,yp, col(xp,yp) return color value at xp,yp, fgcol(xp,yp) return fgcol 0-15, bgcol(xp,yp) return bgcol 0-15, store(expr, [0-4]) returns 0 and stores the math expression expr in one of 5 variables called s0-s4 for later reuse, and finally bitwise logic functions or(n,n2), and(n,n2), xor(n,n2), neg(n), shl(n,n2), shr(n,n2). In addition, the variables x and y are available inside the expression and represent the position of the character currently being processed (note that the top-left position of the block is always 0,0). A simple example of a colExpr where each row has a different color (starting with 1) would be just y+1. An example to create a plasma-like color variation could be: sin(y/13)*15*cos(x/16*y/34)*15+15.

[xExpr yExpr]: Must be provided as a pair. The first determines the x position, the second the y position. By default, it determines the position this character is going *to*, but can be changed to mean where the character should be taken *from* (see next parameter). Variables and functions for xExpr and yExpr are the same as colExpr above. Note that colExpr evaluates before xExpr and yExpr, so it can be used to provide data to move. A simple example to first fill with blue and then move the lines vertically: fbox 9 0 A 0,0,80,50 & block 1 0,0,81,51 0,0 -1 0 0 - - x y*y/4

[from|to]: As mentioned above, to is default for xExpr and yExpr.

[mvx,mvy,mvw,mvh]: Optimization setting for xExpr and yExpr, which can be used to limit the rectangular area (inside the entire block) for which the expressions are evaluated.

### 3d

3d - draw a 3d object file

Syntax: 3d objectfile drawmode,drawoption[,tex_offset,tey_offset,tex_scale,tey_scale] rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]

[objectfile] These file formats are supported: ply, plg, and obj. Only the obj file format supports texture mapping, and all normals are discarded. The obj format has a number of non-default extensions added for cmdgfx (while ignoring all other info than v, vt, and f). The extensions are all for 'usemtl': 1. Usemtl does not support mtl files, instead it supports pcx,gxy and txt files. It is possible to follow the file name with a (hex value) color (for pcx files) or character (for gxy and txt) that is used for transparency. 2. cmdblock extension, to use a rectangular block of the current buffer as texture. Syntax usemtl cmdblock x y w h [transpchar]  3. cmdpalette extension, use this to change the palette used to draw the object from this point on. The syntax is: usemtl cmdpalette followed by a palette of the same format as used at the end of the 3d operation (see below)

drawmode: 0=affine texture mapping if texture available, else flat shading, 1=flat shaded with z-sourced lighting, 3=goraud shaded z-sourced lighting, 3=wireframe lines, 4=forced flat shading, 5=perspective correct texture mapping if texture available, else flat shading, 6=affine char/perspective color texture

drawoption: For mode 0,5,6 with texture, drawoption is transpchar(for gxy/txt) and transpcol(for pcx); set to -1 if no transparency wanted. For mode 0,5,6 without texture and mode 4, drawoption is bitwise operator (see ipoly for values). For mode 1 and 2, set to 0 for static and 1 for even light distribution (L flag to set light range). For mode 1, a bitwise operator can also be set in the high byte of drawoption.

[,tex_offset,tey_offset,tex_scale,tey_scale]: optional parameters used to set/scroll texture offset. Since calculating floating point in Batch is hard, the values are integers, where 0 is 0 and 100000 is 1. The scale is used to determine how much of the texture is seen at once, e.g a value of 33000 would show 1/3 of the texture in the given dimension, and 200000 would show it double.

rx[:rx2],ry[:ry2],rz[:rz2]: rotation of 3d object in 3 axis, specified as Euler angles. If specifying a second rotation (for all axis), it is performed *after* the first translation. Keep in mind that angles are integers, and by default multiplied by 4 (can be changed with R flag), so a full circle is 1440 degrees.

tx[:tx2],ty[:ty2],tz[:tz2]: floating point translation (move) of 3d object in 3 dimensions. The translation is done after the rotation. If specifying a second translation (for all dimensions), it is performed after the second rotation.

scalex,scaley,scalez,xmod,ymod,zmod: Floating point initial moving (mod) and scaling of the object done before any translations or rotations. Note that mod is done before scaling, and thus uses the initial object size.

cull,z_near_cull,z_far_cull,z_levels: Set cull to 1 to use backface culling, otherwise 0. Z_near_cull sets the close-to-camera cutoff z distance where the object is no longer visible (set 0 for no cutoff). Z_far_cull sets the far-away camera cutoff z distance where the object is no longer visible (set 0 for no cutoff). Z_levels is used to sort faces within a single object, where a higher value gives better precision (a default of 10  will be used if 0 is set)

xpos,ypos,distance,aspect: Xpos,ypos is the screen center point (column and row) around which the object is drawn. Distance is the distance of the object from the camera. Negative values produce an 'inverted' object. Aspect (floating point value) is used for correction when fonts are not the same width as height, and thus make objects appear distorted (not true for pixel fonts, where aspect is 1). To get the correct aspect for a font, divide its width in pixels by its height, e.g. raster font 1 is 6/8=0.75.

fgcol1 bgcol1 char1...: Faces are drawn using at mimimum 1 set of fgcol/bgcol/char, and at most 32. If only 1 is provided, the same set is used for all faces. If 2 are provided, set 1 is used for face 1, set 2 for face 2, set 1 for face 3, etc. Use '?' for fgcol or bgcol to keep the current foreground AND background colors in the buffer. Use '?' for char to keep the current characters in the buffer. If drawing with a texture, fgcol and bgcol are not ignored but instead *added* to the texture's foreground and background colors. Char is ignored for textures unless it is a pcx file. Cols are 0-15 in hex or decimal (u and U for current console fg/bg colors), and chars are 0-255 in hex or written as an actual character.

Note that faces with less than 3 vertices are treated differently when drawing, since they cannot form a polygon. For single vertex faces, a single character (dot) is drawn (except in drawmode 2). However, for mode 0,1,5 and 6, if a texture has been set, the texture is drawn (as unscaled image) instead of a dot, with the vertex as center point. For faces with 2 vertices, a line is drawn between the points (except in drawmode 2).

Also note that the Z-buffer (if enabled) only works for textured graphics in drawmode 5 by default. Set the s flag too to support Z-buffer for flat shade in 3d modes 0,1,4 as well.

### insert

Insert - use the content of a file as operation input for cmdgfx

Syntax: insert filename

The file content replaces the insert operation, but not remaining operations after that.

### skip 

Skip - ignore the following operation

Syntax: skip anyoperation

Use skip to ignore the operation following skip.

### rem

Rem - ignore all following operations given

Syntax: rem anyoperations

Use rem to ignore all operations on the line following rem.


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
block    mode[:1233] x,y,w,h x2,y2[,w2,h2[,rz]] [transpchar] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from]
3d       objectfile drawmode,drawoption[,tex_x_offset,tex_y_offset,tex_x_scale,tex_y_scale]
         rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod
         face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]
insert   file
skip
rem

Arguments within brackets are optional, but if used they must be written in the given order from left to right. For example, to set [xflip] for the block operation, [transpchar] must be specified first.

'cmdgfx /? operation' to see operation info, e.g. 'cmdgfx /? fbox'

'cmdgfx /? flags' for information about flags.

'cmdgfx /? server' for info on running as server.

'cmdgfx /? palette' for info on setting the color palette.

'cmdgfx /? compare' for a comparison of cmdgfx and cmdgfx_gdi.

```
Syntax above is exactly the same as cmdgfx.exe, but listed again for clarity.

Below are help sections where cmdgfx_gdi differs from cmdgfx:

## General

Cmdgfx_gdi does not care which font is currently set in the cmd window, but always uses raster font 6 by default. The font can be changed with the f flag.

Similarly, cmdgfx_gdi does not care which codepage is set, it always uses code page 437 since the font data is embedded in the program.

## Flags

Same as for cmdgfx, plus the following:

Output:
- \- a  Absolute (pixel) output positioning (used by f flag)
-  fFont:x,y,w,h,outW,outH  Set buffer font(0-9,a-c), position, and size. 1-7 params. Force outW and outH to screen width/height for better performance
- \- U  Draw straight on top of Windows desktop instead of current window

Other:
-  P  Save buffer to 'GDIbuf.dat' at end of run, read back when start again

## Palette

Set new RGB values for the 16 color palette

The foreground palette is set as parameter 3, always following flags (use - to set no flags). The background palette can be set as parameter 4, but if omitted, background palette is the same as foreground.

All 16 colors can potentially be set, but does not have to be.

The palette follows the format RRGGBB,RRGGBB,... up to 16 colors, where RR is the red component 0-255 in hexadecimal, GG is the green component, and BB is the blue component. As an example, to keep index 0 black but set color 1 to orange and color 2 to lime green, use 000000,ff9900,99ff00 as palette.

If running as server, default palette can be restored by using - as palette.



cmdgfx_RGB.exe
--------------
```
CmdGfx_RGB v1.0 : Mikael Sollenborn 2016-2019

Usage: cmdgfx_rgb [operations] [flags] [fgpalette] [bgpalette]

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
block    mode[[:1233],fgblend[,bgblend]] x,y,w,h x2,y2[,w2,h2[,rz]] [transpchar] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from]
3d       objectfile drawmode,drawoption[,tex_x_offset,tex_y_offset,tex_x_scale,tex_y_scale]
         rx[:rx2],ry[:ry2],rz[:rz2] tx[:tx2],ty[:ty2],tz[:tz2] scalex,scaley,scalez,xmod,ymod,zmod
         face_cull,z_near_cull,z_far_cull,z_levels xpos,ypos,distance,aspect fgcol1 bgcol1 char1 [...fgc32 bgc32 ch32]
insert   file
skip
rem

Arguments within brackets are optional, but if used they must be written in the given order from left to right. For example, to set [xflip] for the block operation, [transpchar] must be specified first.

'cmdgfx /? operation' to see operation info, e.g. 'cmdgfx /? fbox'

'cmdgfx /? flags' for information about flags.

'cmdgfx /? server' for info on running as server.

'cmdgfx /? palette' for info on setting the color palette.

'cmdgfx /? compare' for a comparison of cmdgfx and cmdgfx_gdi.

```
Syntax above is almost exactly the same as cmdgfx.exe (there is a difference in block, where fgblend and bgblend can be set to RGB alpha blend the block. There are also more bitops for ipoly.

Below are help sections where cmdgfx_RGB differs from cmdgfx_gdi:

## Bugs and issues

Only use cmdgfx_RGB if RGB output is actually needed. The program reads/writes about 8 times as much data as cmdgfx/cmdgfx_gdi, and is therefore significantly slower.

Since cmdgfx_RGB is still in its early stages, it may have issues, some known, some not. One example is the block transform parameteter, which will give strange results for color changes.


## General

For all fgcol/bgcol settings, it is possible to BOTH specify a color index (as usual, using either hex or decimal), OR to specify a hexadecimal 24 bit RGB color of the form RRGGBB, where each pair is a hex value 0-ff(0-255). To set an RGB color, use at least 3 characters. E.g. to use a red-light-bluish color, write ff0080. To set an only blue color, use an extra preceding 0 to make 3 characters, such as 0ff.

For all operations using an image as input (image, tpoly, 3d), cmdgfx_RGB also allows using an uncompressed 24-bit BMP file, or 48-bit color/8-bit char bxy file (can only be produced with the c flag).

Cmdgfx_RGB, like cmdgfx_gdi, does not care which font is currently set in the cmd window, but always uses raster font 6 by default. The font can be changed with the f flag.

Similarly, cmdgfx_RGB, does not care which codepage is set, it always uses code page 437 since the font data is embedded in the program.

### Ipoly

Ipoly is the only operation (except for block) that allows drawing with alpha blending. While this may seem restrictive, keep in mind that ipoly can (with some extra work) be used to draw everything from pixels to filled boxes to lines to filled circles. Also remember that the 3d operation allows setting a bitop for flat shading, which means it too can make use of these blending modes.

There are 6 extra bitop operators when using cmdgfx_RGB, dealing with various forms of color blending: 

16=Add_RGB_Fg, 17=Add_RGB, 18=Sub_RGB_Fg, 19=Sub_RGB, 20=Blend_RGB_Fg, 21=Blend_RGB

The Fg versions deal only with changing the Fg color but does not blend the Bg color. This can be faster.

Mode 16 and 17 adds the given 24 bit RGB color of the form RRGGBB to the current color in the buffer. Mode 18 and 19 subtracts in the same manner.

For mode 20 and 21, the colors given must be 32 bit. This means that they follow the form AARRGGBB, where AA specifies the opacity of the drawn color, 0-255.


### Block

Syntax: block mode[[:1233],fgblend[,bgblend]] x,y,w,h x2,y2[,w2,h2[,rz]] [transpchar] [xflip] [yflip] [transform] [colExpr] [xExpr yExpr] [to|from]

For cmdgfx_RGB, the block operation can set an opacity for the final block output between 0-255. This is always added to the end of the mode setting, preceded with a ',' character. If only fgblend is set, bgblend is automatically set to the same value. Alternatively, bgblend can be set separately.

E.g. to copy with alpha blend 128 for both fgcol and bgcol: "block 0,128 5,5,40,40 20,20". To move (and set specific move char) and use separate blend for fgcol and bgcol: "block 1:a021,128,64 5,5,40,40 20,20"

There are several new helper functions for colExpr to deal with 24 bit color values. Please note that currently, due to lack of precision, ONLY fgcol values can be changed and even *preserved* in colExpr for cmdgfx_RGB! The bgcol for values set in colExpr will ALWAYS be (re)set to 0. 

New functions: 1. shade(col,r,g,b) to add (or decrease if negative) the values r,g,b to the color col (typically col would be replaced by e.g. fgcol(x,y)).  2. blend(col, a,r,g,b) to alpha blend col with color r,g,b using opacity a (all values in range 0-255).  3. makecol(r,g,b) to construct a color from r,g,b values in range 0-255.  4. fgr(col),fgg(col),fgb(col) to get a color's red,green or blue value (0-255).


## Flags

Same as for cmdgfx_gdi, exept:

Output:
-  c:x,y,w,h,format,i  Capture buffer to file, as capture-i.bxy (i starts at 0 and increases). 0-6 params. Format=0 for txt, 1 for bxy(default), 2 for bmp. Last param can force i



cmdgfx_input.exe
----------
Used to process and forward input (key/mouse/resizing). Can be used as standalone program but in this context typically used in a pipe chain looking like:

cmdgfx_input | script.bat | cmdgfx

There are many example scripts in the archive which shows this usage, as it is the recommended way to handle input for scripts using cmdgfx.

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
