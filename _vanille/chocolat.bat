<# : chocolat.bat
@echo off
@chcp 65001>nul
title chocolat
color f4
cd %~dp0
set PATH=%PATH%;%~dp0
set src=%~1
if exist "%src%" call :save

:in
set "errn=1"
echo please provide a path to source
call open.bat
if "%src%"=="" call :err_%errn% 2>nul
cls
call :save
goto in

:save
echo select where to save the file
call save.bat
title chocolat - editing "%file%"
call :compute
goto save

:compute
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -show_entries stream^=height -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set "height=%%I"
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -show_entries stream^=width -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set "width=%%I"
call :choco

:choco
set "errn=3"
type chocolat.txt
set /p _choco=""
call :cc_%_choco% 2> nul
call :err_%errn%
goto choco

:cc_0
cls
call vanille.bat

:cc_1
set "errn=3"
set "_cc1=0"
if %width% geq %height% (
    set "ax=h"
) else (
    set "ax=v"
)
echo which cropping method do you want to use?
echo  0 ^| centered square (default)
echo  1 ^| square 
echo  2 ^| ^free form (hard to use)
set /p _cc1=""
call :cc1_%_cc1%%ax% 2> nul
call :err_%errn%
goto cc_%_choco%

:cc1_0h
set "errn=2"
echo writing %file%....
set /a "x1=(%width%-%height%)/2"
set /a "x2=%width%%%2^%height%%%2"
set /a "x1=%x1%+%x2%"
gifsicle --crop %x1%,0+-%x1%x-%x2% -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc1_0v
set "errn=2"
echo writing %file%....
set /a "x1=(%height%-%width%)/2"
set /a "x2=%width%%%2^%height%%%2"
set /a "x1=%x1%+%x2%"
gifsicle --crop 0,%x1%+-%x2%x-%x1% -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc1_1h
set "errn=2"
echo where do you want to start cropping? (from left to right)
echo value is a single integer
echo ex. 95 means it will start cropping 95 pixels from the left
set /p x1=""
set /a "x2=%x1%+%heigth%"
gifsicle --crop %x1%,0-%x2%,%height% -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc1_1v
set "errn=2"
echo where do you want to start cropping? (from top to bottom)
echo value is a single integer
echo ex. 95 means it will start cropping 95 pixels from the top
set /p x1=""
set /a "x2=%x1%+%width%"
gifsicle --crop 0,%x1%-%width%,%x2% -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc1_2h
set "errn=2"
echo where do you want to start cropping? (top left corner)
echo comma separated coordinates
echo ex. 95,39 means it will start cropping 95 pixels from the left and 39 from the top
set /p x1=""
echo where do you want to stop cropping? (bottom right corner)
set /p y1=""
gifsicle --crop %x1%-%y1% -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc1_2v
goto cc1_2h

:cc2
set "errn=2"
set w1=_
set h1=_
echo set the width (default is source)
set /p w1=""
echo set the height (default is source)
set /p h1=""
gifsicle --no-logical-screen --resize %w1%x%h1% -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc3
set "errn=3"
echo how do you want to rotate the gif?
echo 0 ^| rotate right (90°)
echo 1 ^| rotate upside down (180°)
echo 2 ^| rotate left (-90°)
set /p _cc3=""
call :cc3_%_cc3% 2> nul
call :err_%errn%
goto cc_%_choco%

:cc3_0
set "errn=2"
gifsicle --rotate-90 -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc3_1
set "errn=2"
gifsicle --rotate-180 -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc3_2
set "errn=2"
gifsicle --rotate-270 -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:cc4
set "errn=3"
echo how do you want to flip the gif?
echo 0 ^| horizontally (upside-down)
echo 1 ^| vertically (left side-right)
set /p _cc=""
call :cc%_choco%_%_cc% 2> nul
call :err_%errn%
goto cc_%_choco%

:cc4_0
set "errn=2"
gifsicle --rotate-270 -i "%src%" -o "%file%"
if exist "%file%" call :end
call :err_%errn%
goto choco

:end
cls
echo the gif has successfully been made
pause
cls
goto choco

:err_0
cls
echo critical error %errn%, ffmpeg and/or gifsicle have not been located
echo please make sure that ffmpeg and gifsicle are properly added to your PATH (.bat version only)%NL%
pause
exit

:err_1
cls
echo error %errn%, file not found or nothing was selected please retry%NL%
goto in

:err_3
cls
echo error %errn%, sorry this value is invalid please retry%NL%
goto :eof 
#>

ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 .\e.gif
