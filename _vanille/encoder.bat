<# : encoder.bat
@echo off
@chcp 65001>nul

::convert values to valid ffmpeg arguments
set "s=-ss %s%"
set "t=-t %t%"
if %f% geq 50 set f=50
if %w% equ %$w% set w=-1
if %h% equ %$h% set h=-1
goto enc_%_enc%
pause
goto :eof

::encoder 0 ffmpeg method good quality and speed overall
:enc_0
cls
echo writing %file%....
ffmpeg %s% %t% -i "%src%" -vsync vfr -r %f% -vf "scale=%w%:%h%:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop %loops% -y "%file%"
goto :eof

::encoder 1 gifski method better quality and slightly smaller filesizes but requires huge temporary raw png frames which is a bit slower
:enc_1
if %loops% equ 0 (
    set loops=""
) else (
    set loops="--once"
)
cls
echo writing %file%....
md _temp
ffmpeg %s% %t% -i "%src%" -vsync vfr -r %f% -vf "scale=%w%:%h%:flags=lanczos" "_temp\frames%%04d.png"
gifski --fps %f% -o "%file%" _temp\frames*.png
if exist "%file%" rd /s /q _temp
goto :eof
#>