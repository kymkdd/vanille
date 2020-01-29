<# : open.bat
@echo off
@chcp 65001>nul
for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
    set src=%%~I
)
goto :eof
#>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.Title = "vanille"
$f.InitialDirectory = %UserProfiles%
$f.Filter = "all files (*.*)|*.*"
$f.ShowHelp = $true
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }