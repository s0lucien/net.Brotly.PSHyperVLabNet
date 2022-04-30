$ScriptBlock = {
	$Registry_Key_Client = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client"
	$ClientValue = ((Get-ItemProperty -Path $Registry_Key_Client -Name Enabled).Enabled)
	
	
	
	If ($ClientValue -eq 0) {
		Write-Host "TLS 1.0 IS NOT Enabled on client"
		$TLS_Client_Enable_Check = 0
	} ELSE {
		Write-Host "TLS 1.0 iS  Enabled on client"
		$TLS_Client_Enable_Check = 1
	}
	
	If ($ClientValue -eq 0) {
		Write-Host "TLS 1.0 IS NOT Enabled on Server"
		$TLS_Server_Enable_Check = 0
	} ELSE {
		Write-Host "TLS 1.0 IS  Enabled on Server need immediate action"
		$TLS_Server_Enable_Check = 1
	}
	$TLS_Server_Enable_Check, $TLS_Client_Enable_Check
}

$TLS_Server_Enable_Check,$TLS_Client_Enable_Check = Invoke-Command -ComputerName MyServer -ScriptBlock $ScriptBlock

$TLS_Client_Enable_Check
$TLS_Server_Enable_Check