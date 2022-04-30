$OutputLogPath="$PSScriptRoot\admin-shell-output.log"
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Remove-item $OutputLogPath #remove old execution and start new transcript
Start-Transcript -path $OutputLogPath -append

#{START_ARBITRARY_ELEVATED_SECTION}#
    Write-Host "This is a no-op executed in an elevated shell"
#{END_ARBITRARY_ELEVATED_SECTION}#

Stop-Transcript
