<# : vanille.bat
@echo off
@chcp 65001 >nul
setlocal
title vanille
color f9

rem simple gif tool by janssson eri @lazuleri on git hub

rem -------------------------------
rem prevent script from running if ffmpeg and/or gifsicle arent found  
rem -------------------------------

set "errn=0"
cd %~dp0\_vanille
set PATH=%PATH%;%~dp0
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
set "axis=h"
set "loops=0"
set "try=1"
set "loss=25"
set "s=00:00:00.000"
set target=15
set conv=1048576
set src=%~1
if exist "%src%" call :probe

:branch
set "errn=3"
set "_branch=n"
echo do you want to make a gif from scratch or edit an existing one?
echo  n ^| new gif (default)
echo  e ^| ^edit an existing gif
set /p _branch=""
call :branch_%_branch% 2> nul
call :err_%errn%
goto branch

:branch_n
cls
call :in

:branch_e
cls
call chocolat.bat
goto branch

:in
set "errn=1"
echo please provide a path to source (drag and drop is ok)
call open.bat
if "%src%"=="" call :err_%errn% 2>nul
cls
call :probe
goto in

:probe
title vanille - analysing "%src%"
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -show_entries stream^=r_frame_rate -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set "f=%%I"
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -sexagesimal -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set "t=%%I"
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -show_entries stream^=height -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set "h=%%I"
for /F "delims=" %%I in ('ffprobe -v error -select_streams v:0 -show_entries stream^=width -of default^=noprint_wrappers^=1:nokey^=1 "%src%" 2^>^&1') do set "w=%%I"
if %h% geq %w% set axis=v
set /a "f=%f%+%f%%%2"
if %f% geq 50 set f=50
set $w=%w%
set $h=%h%
call :save

:save
echo select where to save the file
title vanille - editing "%file%"
call save.bat
title vanille - editing "%file%"
call :pro
goto save

:pro
set mode=0
set popsicle=0
set "errn=3"
type table.txt
set /p mode=""
call profiles.bat
if %go% equ 1 call :timeset
cls
call :err_%errn%
goto pro

:timeset
set "errn=3"
set "tm=y"
cls
echo do you want to make a gif of a specific length? (from timestamp) (y/n, y default)
set /p tm=""
call :tm_%tm% 2>nul
call :err_%err%
goto timeset

:tm_y
cls
echo where do you want the gif to start from?
echo timestamp in hh:mm:ss ex 9h3min7s = 09:03:07
set /p s=""
echo how long should the gif be? (from the timestamp)
echo timestamp in hh:mm:ss ex 9h3min7s = 09:03:07
set /p t=""
call :valid

:tm_n
cls
call :valid

:valid
set "errn=3"
set "vl=y"
cls
echo here are the settings you set
echo width         ^| %w% px
echo height        ^| %h% px
echo framerate     ^| %f% f
echo loops         ^| %loops% 
echo max size      ^| %target% bytes
echo start         ^| %s%
echo length        ^| %t% 
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
set "errn=6"
echo which encoder do you want to use
echo  0 ^| ffmpeg (default, fastest, decent quality)
echo  1 ^| gifski (experimental, slower and heavy proxy files, better quality and filesizes)
set /p _enc=""
call encoder.bat
if exist "%file%" call :opti
call :err_%errn%
goto hajime

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
echo %opm%
pause
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
if %target% leq 1048576 set conv=1024
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
if %try% gtr 5 call :retry
gifsicle -O3 --lossy=%loss% "%file%" -o "%fileout%"
set /a "try+=1"
if %try% gtr 8 call :end
set /a "loss+=25"
for %%A IN ("%fileout%") do set sizeout=%%~zA
if %sizeout% gtr %target% (
    goto opm_%opm%
) else (
    call :end
)

:opm_n
call:end

:retry
if %_retry% geq 1 goto:eof
cls
set "errn=3"
set "opm=y"
echo the gif may not look that good after too many optimisations
echo do you want to try make the gif again with a lower framerate?
echo  y ^| yes (default)
echo  n ^| no, continue optimising
set /p opm=""
call :retry_%rtr% 2> nul
call :err_%errn%
goto retry

:retry_y
cls
echo enter the desired framerate (default is same as source)
set /p f=""
call :ffb

:retry_n
set _retry=1
goto opm_%opm%

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
echo error %errn%, warning the video you want to use is above 50f (%framerate%f) which is the maximum gifs can handle
echo vanille will set the gif to 50f%NL%
set f=50
goto :eof

echo you shouldnt have landed here!
pause
exit

rem -------------------------------
rem behold the powershell file picker
rem -------------------------------
endlocal
#>



