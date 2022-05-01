function Get-MACAddressFromString ($inputString){
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($inputString)
    $writer.Flush()
    $stringAsStream.Position = 0
    $h = (Get-FileHash -InputStream $stringAsStream).Hash
    $MAC10 = $h.substring($h.length - 10) # return 10 bits from the md5 hash
    "00$MAC10" # and 00 prefix to make it valid
}

# Get-MACAddressFromString "BrotlyNet_host"