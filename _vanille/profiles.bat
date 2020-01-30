<# : profiles.bat
@echo off
@chcp 65001 >nul
goto %mode%%axis%
goto :eof

::you can add your own profiles to this file as well
::they must start with an integer >3 and have h and v after like the other ones (you can overwrite existing ones if you want)
::even if you have only one horizontal profile just duplicate it to have a vertical one as well
::they must end with :
::set go=1
::goto :eof
::--parameters
::h = height
::w = height
::f = framerate
::s = start of the gif
::loops = enable looping 0=yes 1=no
::target = max filesize
::popsicle = call optimiser note that if u set a target but not popsicle 
::it wont do anything but calling popsicle alone will optimise it with a target of 15mib

::twitter horizontal
:0h
set popsicle=1
set h=600
set w=-1
set go=1
goto :eof

::twitter vertical
:0v
set popsicle=1
set h=-1
set w=600
set go=1
goto :eof

::discord horizontal
:1h
set popsicle=1
set target=8388608
set h=-1
set w=400
set go=1
goto :eof

::discord vertical
:1v
set popsicle=1
set target=8388608
set h=300
set w=-1
set go=1
goto :eof

::discord emoji horizontal
:2h
set popsicle=1
set target=262144
set h=-1
set w=48
set go=1
goto :eof

::discord emoji vertical
:2v
set popsicle=1
set target=262144
set h=48
set w=-1
set go=1
goto :eof

::raw
:3h
set h=-1
set w=-1
set go=1
goto :eof

::raw
:3v
goto 3h

::custom
:4h
set popsicle=1
echo enter the desired width (default is same as source)
set /p w=""
echo enter the desired height (default is same as source)
set /p h=""
echo enter the desired framerate (default is same as source)
set /p f=""
echo enable looping (0 = yes, 1 = no)
set /p loops=""
echo enter the maximum filesize (default is 15728640 bytes)
set /p target=""
set go=1
goto :eof

:4v
goto 4h

::help
:?
type profiles.txt
pause
cls
goto :eof
#>