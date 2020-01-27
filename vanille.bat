<# : vanille.bat
@echo off
setlocal
title vanille
color f9

rem simple gif tool by janssson eri @lazuleri on git hub

rem -------------------------------
rem prevent script from running if ffmpeg and/or gifsicle arent found  
rem -------------------------------

set "errn=0"
cd _vanille
set PATH=%PATH%;%~0
where ffmpeg >nul 2>nul 
where gifsicle >nul 2>nul
if not %errorlevel% geq 0 call :err_%errn% 2>nul

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
set "xscale=source"
set "yscale=source"
set "loops=infinite"
set "fps=source"
set "vsync=-vsync vfr"
set "try=1"
set "loss=25"
set target=15728640
set "startset=from the start"
set "lengthset=entire video"
set src=%~1
if exist "%src%" call :save

rem -------------------------------
rem ask for the file that you need to convert and checking that it does exist
rem -------------------------------

:in
set "errn=1"
echo please provide a path to source (drag and drop is ok)
call open.bat
if "%src%"=="" call :err_%errn% 2>nul
cls
call :save
goto in

:save
set "errn=2"
echo select where to save the file
call save.bat
if exist "%file%" call :err_%errn% 2>nul
title vanille - editing "%file%"
call :pro
goto save

rem -------------------------------
rem ask which profile to use
rem -------------------------------

:pro
set mode=0
set popsicle=0
set "errn=3"
type table.txt
set /p mode=""
call :profile_%mode% 2> nul
cls
call :err_%errn%
goto pro

rem -------------------------------
rem send the results to the command builder
rem -------------------------------

:profile_0
set popsicle=1
call :probe
if "%axis%"=="0" set yscale=600
if "%axis%"=="1" set xscale=600
call :timeset

:profile_1
set target=8388608
set popsicle=1
call :probe
if "%axis%"=="0" set xscale=400
if "%axis%"=="1" set yscale=300
call :timeset

:profile_2
set target=262144
set popsicle=1
call :probe
if "%axis%"=="0" set xscale=48
if "%axis%"=="1" set yscale=48
call :timeset

:profile_3
call :timeset

:profile_4
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

:profile_?
type profiles.txt
pause
cls
goto pro

rem -------------------------------
rem find the orientation of the file, bulky but its safer as videos may not specify their orientation natively
rem -------------------------------

:probe
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -show_entries stream^=height -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set "height=%%I"
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -show_entries stream^=width -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set "width=%%I"
if %width% geq %height% (
    set axis=0
) else (
    set axis=1
)
goto :eof

rem -------------------------------
rem ask if user wants a specific length
rem -------------------------------

:timeset
set "errn=3"
set "tm=n"
cls
echo do you want to make a gif of a specific length? (from timestamp) (y/n, n default)
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
set "errn=6"
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -show_entries stream^=r_frame_rate -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set /a "framerate=%%I+1"
if %framerate% geq 50 call :err_%errn% 2>nul
if "%fps%"=="source" (
    set "fps="
) else (
    call :vs
)
if "%xscale%"=="source" set xscale=-1
if "%yscale%"=="source" set yscale=-1
if "%loops%"=="infinite" set loops=0
echo writing %file%....
ffmpeg %startset% %lengthset% -i "%src%" %vsync% -vf "%fps%scale=%xscale%:%yscale%:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop %loops% "%file%"
if exist "%file%" call :opti
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
for %%A IN ("%file%") do set size=%%~zA
if %size% geq %target% set ratio=1
set /a "_optimise=%ratio%+%popsicle%"
if %_optimise% equ 2 call :optimise
call :end

:optimise
set "errn=3"
set "opm=y"
cls
call :maths
echo the file has been made but is over %targetv% %unit% (%perc%%% bigger) do you want to try optimise it? (y/n, y default)
echo  y ^| yes (default, can take some ^time due to iterations)
echo  n ^| no, save as is
set /p opm=""
call :string
call :opm_%opm% 2> nul
call :err_%errn%
goto optimise

:string
set file1="%file%"
for %%A IN (%file1%) do set p=%%~dpA
for %%A IN (%file1%) do set n=%%~nA
set fileout=%p%%n%o.gif
goto :eof
rem -------------------------------
rem convert bytes to mb visually
rem -------------------------------

:maths
set unit=mib
set conv=1048576
if %target% leq 1048576‬ set conv=1024
set /a "targetv=%target%/%conv%"
set /a "_perc=(%size%*100)/%target%"
set /a "perc=%_perc%-100"
if %conv% leq 1024 set unit=kib
goto :eof

rem -------------------------------
rem "automatic" optimiser, simply just check if the file is under the set target filesize and run it until it hits
rem -------------------------------

:opm_y
cls
echo attempt number %try%... (compression %loss%)
if %try% gtr 5 echo the file might not look great
gifsicle -O3 --lossy=%loss% "%file%" -o "%fileout%"
set /a "try+=1"
if %try% gtr 8 goto end
set /a "loss+=25"
for %%A IN ("%fileout%") do set sizeout=%%~zA
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

:err_2
cls
echo error %errn%, theres already a file with that name please use another name%NL%
goto name

:err_3
cls
echo error %errn%, sorry this value is invalid please retry%NL%
goto :eof 

:err_4
cls
echo error %errn%, an error has occured%NL%
goto :eof 

:err_5
cls
echo but the target file size has not been met
echo you may want to retry making the gif with another profile
goto :eof

:err_6
cls
echo error %errn%, warning the video you want to use is above 50fps (%framerate%fps) which is the maximum gifs can handle
echo vanille will set the gif to 50fps%NL%
set fps=50
goto :eof

echo you shouldnt have landed here!
pause
exit

rem -------------------------------
rem behold the powershell file picker
rem -------------------------------
endlocal
#>



