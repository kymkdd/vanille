<# : open.bat
for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
    set src=%%~I
)
goto :eof
#>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.Title = "vanille"
$f.InitialDirectory = pwd
$f.Filter = "All Files (*.*)|*.*"
$f.ShowHelp = $true
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }