Write-Output "Loading the PsHyperVLabNet module" -ForegroundColor DarkGreen

Get-ChildItem *.ps1 -Exclude execute-NoUAC-shell.ps1,remove-NoUAC-shell.ps1 | foreach {. "$($_.FullName)"}

Export-ModuleMember -Function *

$LoadSHElevate_codeToInject = {
    Write-Host "Loading up the SHElevate scheduled task. `
    Will be used to bypass UAC while this module is imported."
}

& $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $LoadSHElevate_codeToInject.ToString()

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    & "$PSScriptRoot\remove-NoUAC-shell.ps1"
}

Write-Output "Finished Importing"

# Import-module .\PSHyperVLabNet.psd1
# Remove-Module PSHyperVLabNet

