$command_to_encode = {
    Write-Host "This was encoded"
    Read-Host "Done"
}

$Text = $command_to_encode.ToString()
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText


pwsh -EncodedCommand $EncodedText

$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($EncodedText))
$DecodedText