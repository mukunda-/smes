@REM Videogame material building script.

PATH=%PATH%;../../matcomp

@REM --------------------------------------------------------------------------
@REM Set your GAMEDIR
@REM If not set, the material will not be compiled or copied to the game.
@REM --------------------------------------------------------------------------
@REM SET GAMEDIR=C:\Steam\steamapps\common\Counter-Strike Global Offensive\csgo

@REM --------------------------------------------------------------------------
@REM Set to your videogame ID:
@REM --------------------------------------------------------------------------
@SET VGNAME=bios

@REM --------------------------------------------------------------------------
@REM Create working directories:
@REM --------------------------------------------------------------------------
mkdir produce
mkdir font
 
@REM --------------------------------------------------------------------------
@REM Cleanup last build:
@REM --------------------------------------------------------------------------
del produce\* /Q
del font\* /Q

@REM --------------------------------------------------------------------------
@REM Cut up the image with ImageMagick, and then pass the result to process
@REM Results are stored in produce and copied to the game directory.
@REM --------------------------------------------------------------------------

@REM For example, to turn an image into 16x16 sprites:
convert font.png -crop 16x16 -transparent #000000 font/sprite_0_%%03d.png 
call process font 16 16
 
@pause
