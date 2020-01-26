<# : vanille.bat
@echo off
setlocal
title vanille
color 9f

rem simple gif tool by janssson eri @lazuleri on git hub
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
set "file=vanille"
set "errn=0"
set "axis=0"
set "loops=infinite"
set "xscale=source"
set "yscale=source"
set "fps=source"
set "vsync=-vsync vfr"
set "try=1"
set "loss=25"
set target=15728640
set "startset=from the start"
set "lengthset=entire video"

rem -------------------------------
rem ask for the file that you need to convert and checking that it does exist
rem -------------------------------

:in
set "errn=1"
echo please provide a path to source (drag and drop is ok)
for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
    set src=%%~I
)
if "%src%"=="" call :err_%errn% 2>nul
cls
call :name
goto in

:name
set "errn=2"
echo please enter a name for the file (it cant be edited without restarting the script!)
set /p "file="
if exist "%file%.gif" call :err_%errn% 2>nul
cls
call :pro
goto name

rem -------------------------------
rem ask which profile to use
rem -------------------------------

:pro
set mode=0
set "axs=0"
set "popsicle=0"
set "errn=3"
echo what profile do you want to use? (i advise people to run 4 first)
echo  0 ^| same as source (highest quality)
echo  1 ^| discord
echo  2 ^| twitter
echo  3 ^| custom
echo  4 ^| explain the profiles
set /p mode=""
call :profile_%mode% 2> nul
cls
call :err_%errn%
goto pro

rem -------------------------------
rem send the results to the command builder
rem -------------------------------

:profile_0
call :valid

:profile_1
set target=8388608
set popsicle=1
if "%axs%"=="0" goto ax1
if "%axis%"=="0" set xscale=400
if "%axis%"=="1" set yscale=300
call :timeset


:profile_2
set popsicle=1
if "%axs%"=="0" goto ax1
if "%axis%"=="0" set yscale=600
if "%axis%"=="1" set xscale=600
call :timeset

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
call :timeset

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
set "errn=3"
cls
echo is the source horizontal or vertical? (if square or unsure leave horizontal)
echo  0 ^| horizontal (default)
echo  1 ^| vertical
set /p axis=""
call :axis_%axis% 2> nul
call :err_%errn%
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
rem ask if user wants a specific length
rem -------------------------------

:timeset
set "errn=3"
set "tm=y"
cls
echo do you want to make a gif of a specific length? (from timestamp) (y/n, y default)
echo beware experimental feature please read instructions carefuly thanks
set /p tm=""
call :tm_%tm% 2>nul
call :err_%err%
goto timeset

:tm_y
cls
echo where do you want the gif to start from?
echo timestamp in hh:mm:ss ex 9h3min7s = 09:03:07
set /p startset=""
echo how long should the gif be? (from the timestamp)
echo timestamp in hh:mm:ss ex 9h3min7s = 09:03:07
set /p lengthset=""
call :valid

:tm_n
cls
call :valid

rem -------------------------------
rem lil helper to confirm the settings
rem -------------------------------

:valid
set "errn=3"
set "vl=y"
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
echo start         ^| %startset%
echo length        ^| %lengthset% 
echo is this ok? (y/n, y default)
set /p vl=""
call :valid_%vl% 2> nul
call :err_%errn%
goto valid

:valid_y
cls
call :ffb

:valid_n
cls
goto pro

rem -------------------------------
rem builder that assembles the ffmpeg command and verifies if the file was created
rem -------------------------------

:ffb
set "errn=4"
echo writing %file%.gif....
if "%startset%"=="from the start" (
    set "startset="
) else (
    set "startset=-ss %startset% "
)
if "%lengthset%"=="entire video" (
    set "lengthset="
) else (
    set "lengthset=-t %lengthset% "
)
if "%fps%"=="source" (
    set "fps="
) else (
    call :vs
)
if "%xscale%"=="source" set xscale=-1
if "%yscale%"=="source" set yscale=-1
if "%loops%"=="infinite" set loops=0
ffmpeg %startset% %lengthset% -i "%src%" %vsync% -vf "%fps%scale=%xscale%:%yscale%:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop %loops% %file%.gif
if exist "%file%.gif" call :opti
call :err_%errn%
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
if %size% gtr %target% call :optimise
call end

:optimise
set "errn=3"
set "opm=y"
cls
call :maths
echo the file has been made but is over %targetv% %unit% (%perc%%% bigger) do you want to try optimise it? (y/n, y default)
echo  y ^| yes (default, can take some ^time due to iterations)
echo  n ^| no, save as is
set /p opm=""
set fileout=%file%o
call :opm_%opm% 2> nul
call :err_%errn%
goto optimise

rem -------------------------------
rem convert bytes to mb visually
rem -------------------------------

:maths
set unit=mib
set conv=1048576
if %target% leq 1048576‬ set conv=1024
set /a "targetv=%target%/%conv%"
set /a "perc=%size%*100/%target%"
if %conv% leq 1024 set unit=kib
goto :eof

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
for %%A IN ("%fileout%.gif") do set sizeout=%%~zA
if %sizeout% gtr %target% (
    goto opm_%opm%
) else (
    call :end
)

:opm_n
call:end

:end
set "errn=5"
cls
echo the gif has successfully been made
if %try% gtr 8 call :err_%errn%
pause
cls
goto hajime

rem -------------------------------
rem error handling
rem -------------------------------

:err_1
cls
echo error %errn%, file not found or nothing was selected please retry%NL%
goto in

:err_2
cls
echo error %errn%, theres already a file with that name please use another one%NL%
goto name

:err_3
cls
echo error %errn%, sorry this value is invalid please retry%NL%
goto :eof 

:err_4
cls
echo error %errn%, an error has%NL%
goto :eof 

:err_5
cls
echo but the target file size has not been met
echo you may want to retry making the gif with another profile
goto :eof

echo you shouldnt have landed here!
pause
exit

rem -------------------------------
rem behold the powershell file picker
rem -------------------------------

#>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.Title = "vanille"
$f.InitialDirectory = pwd
$f.Filter = "All Files (*.*)|*.*|Text Files (*.txt)|*.txt"
$f.ShowHelp = $true
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }


