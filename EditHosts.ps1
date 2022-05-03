# https://github.com/TomChantler/EditHosts
function PSHyperVLabNet\AddToHosts{
    # By Tom Chantler - https://tomssl.com/2019/04/30/a-better-way-to-add-and-remove-windows-hosts-file-entries/
    param([string]$DesiredIP = "127.0.0.1"
        ,[string]$Hostname = "tomssl.local"
        ,[bool]$CheckHostnameOnly = $false)
    # Adds entry to the hosts file.
    $hostsFilePath = "$($Env:WinDir)\system32\Drivers\etc\hosts"
    $hostsFile = Get-Content $hostsFilePath

    Write-Host "About to add $desiredIP for $Hostname to hosts file" -ForegroundColor Gray

    $escapedHostname = [Regex]::Escape($Hostname)
    $patternToMatch = If ($CheckHostnameOnly) { ".*\s+$escapedHostname.*" } Else { ".*$DesiredIP\s+$escapedHostname.*" }
    If (($hostsFile) -match $patternToMatch)  {
        Write-Host $desiredIP.PadRight(20," ") "$Hostname - not adding; already in hosts file" -ForegroundColor DarkYellow
    } 
    Else {
        Write-Host $desiredIP.PadRight(20," ") "$Hostname - adding to hosts file... " -ForegroundColor Yellow -NoNewline
        Add-Content -Encoding UTF8  $hostsFilePath ("$DesiredIP".PadRight(20, " ") + "$Hostname")
        Write-Host " done"
    }
}

function PSHyperVLabNet\RemoveFromHosts{
    # By Tom Chantler - https://tomssl.com/2019/04/30/a-better-way-to-add-and-remove-windows-hosts-file-entries/
    param([string]$Hostname = "tomssl.local")
    # Remove entry from hosts file. Removes all entries that match the hostname (i.e. both IPv4 and IPv6).
    $hostsFilePath = "$($Env:WinDir)\system32\Drivers\etc\hosts"
    $hostsFile = Get-Content $hostsFilePath
    Write-Host "About to remove $Hostname from hosts file" -ForegroundColor Gray
    $escapedHostname = [Regex]::Escape($Hostname)
    If (($hostsFile) -match ".*\s+$escapedHostname.*")  {
        Write-Host "$Hostname - removing from hosts file... " -ForegroundColor Yellow -NoNewline
        $hostsFile -notmatch ".*\s+$escapedHostname.*" | Out-File $hostsFilePath 
        Write-Host " done"
    } 
    Else {
        Write-Host "$Hostname - not in hosts file (perhaps already removed); nothing to do" -ForegroundColor DarkYellow
    }
}

function PSHyperVLabNet\UpdateMultipleHostsFiles{
    # By Tom Chantler - https://tomssl.com/2019/04/30/a-better-way-to-add-and-remove-windows-hosts-file-entries/
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string[]]$ServerList,
    [int]$TimeOut=5)
    # Copy local hosts files to multiple computers, overwriting the existing hosts files. Backs up existing hosts file to hosts.bak
    $numberOfServers = $ServerList.Length

    If ($PSCmdlet.ShouldProcess($null)){
        # Only read the local hosts file if we're actually going to do anything
        $newHostsFileContent = Get-Content "$($Env:WinDir)\system32\Drivers\etc\hosts"
        Write-Host "I'm going to copy the local hosts file to $numberOfServers servers"
    }

    ForEach ($server in $ServerList){
        $path = "\\$server\C$\Windows\System32\drivers\etc\hosts" # Make sure to point to the correct drive for your windows directory or change this to use a proper UNC share.
        $remoteEtcDirectory = Split-Path $path
        If ($PSCmdlet.ShouldProcess($path, "Copy local hosts file to target location")) {
            $destination = @{Object = $path; ForegroundColor = 'Yellow';}
            $canGetHostsFileResult = $path | Start-Job { Get-Item } | Wait-Job -Timeout $TimeOut
            If ($canGetHostsFileResult) {
                # Make a backup of the remote hosts file
                Copy-Item $path -Destination $remoteEtcDirectory\hosts.bak
                # Write the local host file to the remote server
                $newHostsFileContent | Out-File $path #Note that Out-File respects the -WhatIf parameter.
                Write-Host "New hosts file written to " -NoNewLine 
                Write-Host @destination
            } 
            Else {
                Write-Host "Couldn't access file at " -NoNewLine -ForegroundColor Red 
                Write-Host @destination
            }
        }
    }

    Write-Host "Done!"
}