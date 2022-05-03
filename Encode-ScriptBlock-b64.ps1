
function Encode-ScriptBlock-b64($ScriptBlockToEncode) {
    $Text = $ScriptBlockToEncode.ToString()
    Write-Host "Encoded ScriptBlock is $Text"
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
    $EncodedText =[Convert]::ToBase64String($Bytes)
    $EncodedText
}
