@echo off
title vanille
color 9f

rem simple gif tool by janssson eri @kymkdd on git hub
rem -------------------------------
rem newline variable from 
rem https://stackoverflow.com/questions/132799/how-can-i-echo-a-newline-in-a-batch-file
rem -------------------------------
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%

rem -------------------------------
rem setup of the default values
rem -------------------------------

:hajime
set "axis=0"
set "loops=infinite"
set "xscale=source"
set "yscale=source"
set "fps=source"
set "yn=y"
set "vsync=-vsync vfr"
set "file=vanille"
set "opm=y"
set "try=1"
set "loss=25"
set target=15728640

rem -------------------------------
rem ask for the file that you need to convert and checking that it does exist
rem -------------------------------

:in
echo please provide a path to source (drag and drop is ok)
set /p src=""
if not exist "%src%" call :empt 2> nul
cls

:name
echo please enter a name for the file (it cant be edited without restarting the script!)
set /p "file="
if exist "%file%.gif" call :exist 2>nul
cls
call :pro

:empt
cls
echo file not found please retry%NL%
goto in

:exist
cls
echo theres already a file with that name please use another one%NL%
goto name

rem -------------------------------
rem ask which profile to use
rem -------------------------------

:pro
set mode=0
set "axs=0"
set "popsicle=0"
echo what profile do you want to use? (i advise people to run 4 first)
echo  0 ^| same as source (highest quality)
echo  1 ^| discord
echo  2 ^| twitter
echo  3 ^| custom
echo  4 ^| explain the profiles
set /p mode=""
call :profile_%mode% 2> nul
call :err
goto pro

rem -------------------------------
rem send the results to the command builder
rem -------------------------------

:profile_0
call :valid
call :ffb

:profile_1
set target=8388608
if "%axs%"=="0" goto ax1
if "%axis%"=="0" set xscale=400
if "%axis%"=="1" set yscale=300
call :valid
set popsicle=1
call :ffb

:profile_2
if "%axs%"=="0" goto ax1
if "%axis%"=="0" set yscale=600
if "%axis%"=="1" set xscale=600
call :valid
set popsicle=1
call :ffb

:profile_3
echo enter the desired width (default is same as source)
set /p xscale=""
echo enter the desired height (default is same as source)
set /p yscale=""
echo enter the desired framerate (default is same as source)
set /p fps=""
echo enter the desired number of loops (default is infinite)
set /p loops=""
echo enter the maximum filesize (default is 15728640‬ bytes)
set /p target=""
call :valid
call :ffb

:profile_4
type profiles.txt
pause
goto pro

rem -------------------------------
rem ask what is the orientation of the file
rem i think this could be done automatically but im not skilled
rem with ffmpeg so manual is better
rem -------------------------------

:ax1
cls
echo is the source horizontal or vertical? (if square or unsure leave horizontal)
echo  0 ^| horizontal (default)
echo  1 ^| vertical
set /p axis=""
call :axis_%axis% 2> nul
call :err
set axis=0
goto ax1

:axis_0
cls
set axis=0
call :jmp

:axis_1
cls
set axis=1
call :jmp

rem -------------------------------
rem "jumper" label that escapes ax1 back to profile_# 
rem -------------------------------

:jmp
set axs=1
goto profile_%mode%

rem -------------------------------
rem lil helper to confirm the settings
rem -------------------------------

:valid
cls
if "%axis%"=="0" (
    set "or=horizontal"
) else (
    set "or=vertical"
)
echo here are the settings you set
echo width         ^| %xscale% px
echo height        ^| %yscale% px
echo framerate     ^| %fps% fps
echo orientation   ^| %or% 
echo loops         ^| %loops% 
echo max size      ^| %target% bytes
echo is this ok? (y/n, y default)
set /p yn=""
if not "%yn%"=="y" goto profile_%mode%
goto :eof

rem -------------------------------
rem builder that assembles the ffmpeg command and verifies if the file was created
rem -------------------------------

:ffb
echo writing %file%.gif....
if "%fps%"=="source" (
    set "fps="
) else (
    call :vs
)
if "%xscale%"=="source" set xscale=-1
if "%yscale%"=="source" set yscale=-1
if "%loops%"=="infinite" set loops=0
ffmpeg -i %src% %vsync% -vf "%fps%scale=%xscale%:%yscale%:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop %loops% %file%.gif
if exist "%file%.gif" call :opti
echo there was an error && pause
goto hajime

rem -------------------------------
rem toggle between source fps or target fps
rem -------------------------------

:vs
set "vsync="
set "fps=fps=%fps%,"
goto :eof

rem -------------------------------
rem check if file is under 15mb and try to optimise it (preset 1 and 2 only)
rem -------------------------------

:opti
if "%popsicle%"=="1" for %%A IN ("%file%.gif") do set size=%%~zA
if %size% gtr %target% call :optimise && pause
call end

:optimise
cls
echo the file has been made but is over %target% bytes (%size% bytes) do you want to try optimise it? (y/n, y default)
echo  y ^| yes (default, can take some ^time due to iterations)
echo  n ^| no, save as is
set /p opm=""
set fileout=%file%o
call :opm_%opm% 2> nul
call :err
set opm=y
goto :optimise

rem -------------------------------
rem "automatic" optimiser, simply just check if the file is under the set target filesize and run it until it hits
rem -------------------------------

:opm_y
cls
echo attempt number %try%... (compression %loss%)
if %try% gtr 5 echo the file might not look great
gifsicle -O3 --lossy=%loss% %file%.gif -o %fileout%.gif
set /a "try=try+1"
if %try% gtr 8 goto end
set /a "loss=loss+25"
FOR %%A IN ("%fileout%.gif") do set sizeout=%%~zA
if %sizeout% gtr %target% (
    goto opm_%opm%
) else (
    call :end
)


:end
cls
if %try% gtr 8 (
    echo sorry but the target file size has not been met (file is %sizeout% bytes) 
    echo you may want to retry making the gif with another profile
) else (
    echo the gif has successfully been made
)
pause
cls
goto hajime

:err
cls
echo sorry this value is invalid please retry%NL%
goto :eof 

echo you shouldnt have landed here!
pause
exit