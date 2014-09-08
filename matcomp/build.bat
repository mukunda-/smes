@REM Videogame material building script.

@REM --------------------------------------------------------------------------
@REM Set your GAMEDIR
@REM If not set, the material will not be compiled or copied to the game.
@REM --------------------------------------------------------------------------
@REM SET GAMEDIR=C:\Steam\steamapps\common\Counter-Strike Global Offensive\csgo

@REM --------------------------------------------------------------------------
@REM Set to your videogame ID:
@REM --------------------------------------------------------------------------
@SET VGNAME=vgname

@REM --------------------------------------------------------------------------
@REM Create working directories:
@REM --------------------------------------------------------------------------
mkdir produce
@REM mkdir mymaterial

 
@REM --------------------------------------------------------------------------
@REM Cleanup last build:
@REM --------------------------------------------------------------------------
del produce\* /Q
@REM del mymaterial\* /Q

@REM --------------------------------------------------------------------------
@REM Cut up the image with ImageMagick, and then pass the result to process
@REM Results are stored in produce and copied to the game directory.
@REM --------------------------------------------------------------------------

@REM For example, to turn an image into 16x16 sprites:
@REM convert font.png -crop 16x16 -transparent #000000 font/sprite_0_%%03d.png 
@REM call process font 16 16
 
@pause
