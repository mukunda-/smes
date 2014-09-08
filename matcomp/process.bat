
@echo Processing: %1 ......

@set valid=true
@if "%1" == "" set valid=false
@if "%2" == "" set valid=false
@if "%3" == "" set valid=false

@if "%valid%" == "false" (
	@echo "Usage: process.bat <directory> <width> <height> [-x]"
	@echo   directory - path to directory containing list of sprite files to compile.
	@echo   width,height - dimensions of the images, in pixels.
	@echo   -x - sets translucent flag for material
	@goto skipcompile
)

@echo -----------------------------------
@echo creating vtf...
@echo -----------------------------------
vtfcmd2 -multi -silent -folder %1 -output produce/%1.vtf -nomipmaps -format "RGBA8888" -flag "POINTSAMPLE" -flag "CLAMPS" -flag "CLAMPT" -flag "NOMIP" -flag "NOLOD"
@echo -----------------------------------
@echo generating QC...
@echo -----------------------------------
genqc.py -g %VGNAME% -m %1 -s compile.smd -o compile.qc
@echo -----------------------------------
@echo generating SMD...
@echo -----------------------------------
gensmd.py --width=%2 --height=%3 --texture=%1 --output=compile.smd
@echo -----------------------------------
@echo generating material...
@echo -----------------------------------
genvmt.py -g %VGNAME% -t %1 -o produce\%1.vmt %4

@if "%GAMEDIR%" == "" (
	@echo Please specify a GAMEDIR to compile the graphic.
	@goto skipcompile
) 

@echo -----------------------------------
@echo compiling...
@echo -----------------------------------
"%GAMEDIR%\..\bin\studiomdl" -game "%GAMEDIR%" compile.qc

@echo -----------------------------------
@echo copying material...
@echo -----------------------------------
copy produce\%1.vtf "%GAMEDIR%\materials\videogames\%VGNAME%\" /Y
copy produce\%1.vmt "%GAMEDIR%\materials\videogames\%VGNAME%\" /Y
@echo -----------------------------------
@echo done.
@echo -----------------------------------
skipcompile: