
$codeToExecute =
{
    Write-Host "starting scheduled task in folder $PSScriptRoot..."
    $VMs = Get-VM
    $VMs |  Export-Csv "$PSScriptRoot\VMs.csv" 
    Write-Host "finished scheduled task"
}

$scriptBlockString = $codeToExecute.ToString()
$content = Get-Content -path .\shell\admin-shell.ps1 -Raw
$new_content = $content -replace '#\{START_ARBITRARY_ELEVATED_SECTION\}#((.|\n)*)#\{END_ARBITRARY_ELEVATED_SECTION\}#',`
                    "#{START_ARBITRARY_ELEVATED_SECTION}#$scriptBlockString#{END_ARBITRARY_ELEVATED_SECTION}#"

Write-Verbose -Message $scriptBlock2.GetType().FullName -Verbose

# Execute
& $scriptBlock2