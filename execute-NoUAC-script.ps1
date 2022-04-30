
$scheduledTaskName = "NoUAC exec scriptBlock"
$timeout = 60 ##  seconds
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

$new_content | Out-File "$PSScriptRoot\shell\admin-shell.ps1" -Force
$task = Get-ScheduledTask | Where-Object -Property TaskName -Match $scheduledTaskName
$task | Start-ScheduledTask          

$timer =  [Diagnostics.Stopwatch]::StartNew()

while (((Get-ScheduledTask -TaskName $scheduledTaskName).State -ne  'Ready') -and  ($timer.Elapsed.TotalSeconds -lt $timeout)) {    

Write-Verbose  -Message "Waiting on scheduled task..."

Start-Sleep -Seconds 1

}

$timer.Stop()
Write-Verbose  -Message "We waited [$($timer.Elapsed.TotalSeconds)] seconds on the task '$scheduledTaskName'."

if ($timer.Elapsed.TotalSeconds -ge $timeout){
    Write-Host "Timed out after $timeout seconds, forcefully terminating ..." 
    $task | Stop-ScheduledTask
}

$log = Get-Content "$PSScriptRoot\shell\admin-shell-output.log"
Write-Host @"
===========Log from task===========
$log
"@

Write-Host "Done."