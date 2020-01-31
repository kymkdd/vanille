<# : vanille.bat
@echo off
@chcp 65001 >nul
setlocal
title vanille
color f9

::simple gif tool by janssson eri @lazuleri on github

::prevent script from running if ffmpeg and/or gifsicle arent found  
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

::setup of a few global values
:hajime
set "axis=h"
set "loops=0"
set "try=1"
set "loss=25"
set "s=00:00:00.000"
set target=15728640

::skip asking for a source if drag and dropped
set src=%~1
if exist "%src%" call :probe

::ask if you wanna use vanille or chocolat
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
call :dl

:branch_e
cls
call chocolat.bat
goto branch

::ask between local or online source
:dl
set "errn=3"
set "_dl=n"
echo do you want to use a local source or something from a link?
echo  0 ^| local (default)
echo  1 ^| ^url
set /p _dl=""
call :dl_%_dl% 2> nul
call :err_%errn%
goto dl

:dl_0
cls
call :in

:dl_1
cls
echo please input an url
echo note that this is not a video dowloader, videos will be deleted after the procress
set /p $dl=""
md _buffer
youtube-dl %$dl% -q --no-warnings --recode-video webm -o _buffer\buffer
if exist "_buffer\buffer.*" set "src=_buffer\buffer.webm"
call :save


::ask for source
:in
set "errn=1"
echo please provide a path to source (drag and drop is ok)
call open.bat
if "%src%"=="" call :err_%errn% 2>nul
cls
call :save
goto in

::ask where to save and how to name the file
:save
cls
echo select where to save the gif
call save.bat
call :probe
goto save

::analyse the source to get its framerate length height and weight
:probe
cls
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
title vanille - editing "%file%"
call :pro

::switch profiles
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

::ask if users want a specific length
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

::ask if everything is ok
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

::encoder selection
:ffb
set "errn=4"
echo which encoder do you want to use
echo  0 ^| ffmpeg (default, fastest, decent quality)
echo  1 ^| gifski (slower and heavy proxy files, much better qual, infinite loop only
set /p _enc=""
call encoder.bat
if exist "%file%" rd /s /q _buffer
if exist "%file%" call :opti
call :err_%errn%
goto hajime

::check that file is under target to know if it needs optimisations
:opti
for %%A IN ("%file%") do set size=%%~zA
if %size% geq %target% set ratio=1
set /a "_optimise=%ratio%+%popsicle%"
if %_optimise% equ 2 call :optimise
call :end

::ask if the user wants said optimisations
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

::append a o to the filename to differenciate it and know it has been optimised
:string
set file1="%file%"
for %%A IN (%file1%) do set p=%%~dpA
for %%A IN (%file1%) do set n=%%~nA
set fileout=%p%%n%o.gif
goto :eof

::convert target to more human readable values and calculates difference in % between file and target
:maths
set unit=mib
set conv=1048576
if %target% leq 1048576 set conv=1024
set /a "targetv=%target%/%conv%"
set /a "_perc=(%size%*100)/%target%"
set /a "perc=%_perc%-100"
if %conv% leq 1024 set unit=kib
goto :eof

::optimisation loop built around gifsicle -O3 that gradually increments the lossiness to try make the file hit the target
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

::after 5 tries ask if the user wants to keep going since the more tries the more noise is added due to the optimisations
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

::complete the task and go back to start
:end
set "errn=5"
cls
echo the gif has successfully been made
if %try% gtr 8 call :err_%errn%
pause
cls
goto hajime

::error handling
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

:err_4
cls
echo error %errn%, an error has occured%NL%
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
endlocal
#>



