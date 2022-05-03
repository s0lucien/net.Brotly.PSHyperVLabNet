
function Encode-Text-b64($Text) {
    Write-Host "Encoded Text is $Text"
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
    $EncodedText =[Convert]::ToBase64String($Bytes)
    $EncodedText
}
