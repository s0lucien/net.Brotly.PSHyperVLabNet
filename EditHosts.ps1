# https://github.com/TomChantler/EditHosts

. .\Encode-Text-b64.ps1
# Writes to the \system32\Drivers\etc\hosts through SHElevate
$AddContent_scriptBlockToInject = {
    $hostsFilePath = $hosts_file_path
    $hostsEntryToAdd = $hosts_entry_to_add
    Add-Content -Encoding UTF8  $hostsFilePath $hostsEntryToAdd
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Add-Content.PSSerialized"
    Write-Host "Done."
}

function PSHyperVLabNet\AddToHosts{
    # By Tom Chantler - https://tomssl.com/2019/04/30/a-better-way-to-add-and-remove-windows-hosts-file-entries/
    param([string]$DesiredIP
        ,[string]$Hostname
        ,[bool]$CheckHostnameOnly = $false)
    # Adds entry to the hosts file.
    $hostsFilePath = "$($Env:WinDir)\system32\Drivers\etc\hosts" #use hosts_bak when testing
    $hostsFile = Get-Content $hostsFilePath

    Write-Host "About to add $desiredIP for $Hostname to hosts file" -ForegroundColor Gray

    $escapedHostname = [Regex]::Escape($Hostname)
    $patternToMatch = If ($CheckHostnameOnly) { ".*\s+$escapedHostname.*" } Else { ".*$DesiredIP\s+$escapedHostname.*" }
    If (($hostsFile) -match $patternToMatch)  {
        Write-Host $desiredIP.PadRight(20," ") "$Hostname - not adding; already in hosts file" -ForegroundColor DarkYellow
    } 
    Else {
        $hostsEntryToAdd = ("$DesiredIP".PadRight(20, " ") + "$Hostname")
        Write-Host "$hostsEntryToAdd - adding to hosts file... " -ForegroundColor Yellow -NoNewline
        $scriptBlockToInject = $AddContent_scriptBlockToInject.ToString() `
            -replace '\$hosts_file_path', "`"$hostsFilePath`"" `
            -replace '\$hosts_entry_to_add', "`"$hostsEntryToAdd`""
        $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
        & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
        $AddContent_out = Get-Content "$PSScriptRoot\shell\Add-Content.PSSerialized"
        $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($AddContent_out)
        $SHElevate?
    }
}


$OutFile_scriptBlockToInject = {
    $hostsContent = $hosts_content
    $hostsFilePath = $hosts_file_path
    $hostsContent | Out-File $hostsFilePath -NoNewline
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Out-File.PSSerialized"
    Write-Host "Done."
}

function PSHyperVLabNet\RemoveFromHosts{
    # By Tom Chantler - https://tomssl.com/2019/04/30/a-better-way-to-add-and-remove-windows-hosts-file-entries/
    param([string]$Hostname)
    # Remove entry from hosts file. Removes all entries that match the hostname (i.e. both IPv4 and IPv6).
    $hostsFilePath = "$($Env:WinDir)\system32\Drivers\etc\hosts"  #use hosts_bak when testing
    $hostsFile = Get-Content $hostsFilePath
    Write-Host "About to remove $Hostname from hosts file" -ForegroundColor Gray
    $escapedHostname = [Regex]::Escape($Hostname)
    If (($hostsFile) -match ".*\s+$escapedHostname.*")  {
        Write-Host "$Hostname - removing from hosts file... " -ForegroundColor Yellow -NoNewline
        $hostsContent = $hostsFile -notmatch ".*\s+$escapedHostname.*" | Out-String 
        $scriptBlockToInject = $OutFile_scriptBlockToInject.ToString() `
            -replace '\$hosts_file_path', "`"$hostsFilePath`"" `
            -replace '\$hosts_content', "`"$hostsContent`""
        $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
        & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
        $OutFile_out = Get-Content "$PSScriptRoot\shell\Out-File.PSSerialized"
        $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($OutFile_out)
        $SHElevate?
    } 
    Else {
        Write-Host "$Hostname - not in hosts file (perhaps already removed); nothing to do" -ForegroundColor DarkYellow
    }
}

# PSHyperVLabNet\AddToHosts -DesiredIP 10.10.80.54 -Hostname book.surf
# Get-Content "$($Env:WinDir)\system32\Drivers\etc\hosts_bak"
# Start-Sleep -Seconds 2
# PSHyperVLabNet\RemoveFromHosts -Hostname book.surf
# Get-Content "$($Env:WinDir)\system32\Drivers\etc\hosts_bak"