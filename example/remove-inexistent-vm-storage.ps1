
Write-Host "Checking for elevated permissions..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Insufficient permissions to run this script. Running the PowerShell script as an administrator ..."
    Start-Process pwsh -ArgumentList '-noprofile -file remove-inexistent-vm-storage.ps1' -verb RunAs
}
else {
    Write-Host "Code is running as administrator - executing the script..." -ForegroundColor Green
    $VMs=(Get-VM -ErrorAction Stop).Name
    Write-Host "Found VMs $VMs"
    $VMs_storage=Get-ChildItem -Directory -Path "C:\Hyper-V"
    
    Write-Host "Removing storage that is not linked to an existing VM ..."
    $VMs_storage.Name | ForEach-Object {
        Write-Host "Found storage $_ .."
        if ($VMs -notcontains $_){
            Write-Host "VMs list [$VMs] does not contain [$_]. Deleting $($_.FullPath) ..."
            Remove-Item "C:\Hyper-V\$_" -Recurse -Verbose
        }else{
            Write-Host "VMs list [$VMs] contains [$_]. Nothing to delete"
        }
    }
}
Read-Host "Done."




