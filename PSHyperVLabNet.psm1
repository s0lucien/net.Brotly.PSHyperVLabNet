Write-Output "Loading the PsHyperVLabNet module" -ForegroundColor DarkGreen

Get-ChildItem *.ps1 -Exclude execute-NoUAC-shell.ps1,remove-NoUAC-shell.ps1 | foreach {. "$($_.FullName)"}

Export-ModuleMember -Function *


$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    & $PSScriptRoot\remove-NoUAC-shell.ps1
}

Write-Output "Finished Importing"

# Import-Module PSHyperVLabNet
# Remove-Module PSHyperVLabNet

