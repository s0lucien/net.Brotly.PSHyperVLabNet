$scheduledTaskName = "SHElevate"
$timeout = 60 ##  seconds
$codeToExecute =
{
    Write-Host "starting scheduled task in folder $PSScriptRoot..."
    $VMs2 = Get-VM
    $VMs2 |  Export-Csv "$PSScriptRoot\VMs.csv"
    Write-Host "finished scheduled task"
}

if (-NOT (Get-ScheduledTask | Where-Object -Property TaskName -Match $scheduledTaskName)){
    Write-Host "No $scheduledTaskName found. Checking for elevated permissions..."
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "Insufficient permissions to add a scheduled task. Running the PowerShell script as an administrator ..."
        
        $xml_template = Get-Content "$PSScriptRoot\shell\admin-shell-task-template.xml"
        $xml_content = $xml_template `
            -replace "#\{username\}#","$env:UserDomain\$env:UserName" `
            -replace "#\{PSScriptRoot\}#","$PSScriptRoot"
        $xml_content | Out-File "$PSScriptRoot\shell\admin-shell-task.xml"
        
        # Invoke the script via -Command rather than -File, so that 
        # a redirection can be specified.
        $passThruArgs = '-command', '&',`
            'SCHTASKS', '/CREATE', '/XML',"`"$PSScriptRoot\shell\admin-shell-task.xml`"", '/TN', "`"$scheduledTaskName`"",`
            '*>', "`"$PSScriptRoot\SHElevate_out.txt`""

        Start-Process pwsh -Wait -Verb RunAs -ArgumentList $passThruArgs

        # Retrieve the captured output streams here:
        Get-Content "$PSScriptRoot\SHElevate_out.txt"
        Remove-Item "$PSScriptRoot\SHElevate_out.txt"
    }
    else {
        Write-Host "Code is running as administrator - executing the script..." -ForegroundColor Green
        SCHTASKS /CREATE /XML "$PSScriptRoot\shell\admin-shell-task.xml" /tn $scheduledTaskName
    }
}else{
    $scriptBlockString = $codeToExecute.ToString()
    $content = Get-Content -path .\shell\admin-shell.ps1 -Raw
    $new_content = $content -replace '#\{START_ARBITRARY_ELEVATED_SECTION\}#((.|\n)*)#\{END_ARBITRARY_ELEVATED_SECTION\}#',`
                        "#{START_ARBITRARY_ELEVATED_SECTION}#$scriptBlockString#{END_ARBITRARY_ELEVATED_SECTION}#"

    $new_content | Out-File "$PSScriptRoot\shell\admin-shell.ps1" -Force -NoNewline
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

    $log = Get-Content "$PSScriptRoot\shell\admin-shell-output.log" -Raw
    Write-Host @"
===========Log from task===========
$log
"@

    Write-Host "Done."
}
