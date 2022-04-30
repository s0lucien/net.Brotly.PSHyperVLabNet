param (
    $scheduledTaskName="SHElevate"
    )
Write-Host "Checking for elevated permissions..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Insufficient permissions to run this script. Running the PowerShell script as an administrator ..."
    # Invoke the script via -Command rather than -File, so that 
    # a redirection can be specified.
    $passThruArgs = '-command', '&',`
        'SCHTASKS', '/DELETE', '/F', '/TN', "`"$scheduledTaskName`"",`
        '*>', "`"$PSScriptRoot\shell\SHElevate_out.txt`""

    Start-Process pwsh -Wait -Verb RunAs -ArgumentList $passThruArgs

    # Retrieve the captured output streams here:
    Get-Content "$PSScriptRoot\shell\SHElevate_out.txt"
    Remove-Item "$PSScriptRoot\shell\SHElevate_out.txt"
}
else {
    Write-Host "Code is running as administrator - deleting the scheduled task..." -ForegroundColor Green
    SCHTASKS /DELETE /F /TN $scheduledTaskName
}

Write-Host "Done."