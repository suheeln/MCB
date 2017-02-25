function DownloadFile($url, $targetFile) {
   $uri = New-Object "System.Uri" "$url"
   $request = [System.Net.HttpWebRequest]::Create($uri)
   $request.set_Timeout(15000) #15 second timeout
   $response = $request.GetResponse()
   $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
   $responseStream = $response.GetResponseStream()
   $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
   $buffer = new-object byte[] 10KB
   $count = $responseStream.Read($buffer,0,$buffer.length)
   $downloadedBytes = $count

   while ($count -gt 0) {
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
   }

   Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"
   $targetStream.Flush()
   $targetStream.Close()
   $targetStream.Dispose()
   $responseStream.Dispose()
}

### Stating this on the command line for portability between the various pipelines
#$RemotePath='http://artifacts.build.tyfone.net/MCB-Nightly/Android-SSFCU-Debug/'
#$LocalBuildPath='C:\TyfoneDev\mcb-starone-automation\apps\MCB\'
#$Customer='sone'
#$LocalConfigPath='C:\TyfoneDev\mcb-starone-automation\src\test\resources\'

$HTML=Invoke-WebRequest -URI $RemotePath
$Latest_Build_Number=($HTML.ParsedHtml.getElementsByTagName('a') | Select -Last 1).innerText
'Latest_Build_Number = ' + $Latest_Build_Number
$HTML2=Invoke-WebRequest -URI ($RemotePath + $Latest_Build_Number)
$VersionArray=$HTML2.ParsedHtml.getElementsByTagName('a')
Foreach($i in $VersionArray) { if ($i.innerText.Contains('.apk')) { $Version = $i.innerText } }
'Version = ' + $Version
'Target = ' + $RemotePath + $Latest_Build_Number + $Version

If ((Test-Path ($LocalBuildPath + $Version)) -eq $False) {
    downloadFile ($RemotePath + $Latest_Build_Number + $Version) ($LocalBuildPath + $Version)
}

### Update it.properties with the new filename for the apk that was just downloaded
$Content = cat ($LocalConfigPath + "it.properties") | % {$_ -replace "(?<=apk.name=$Customer)(.*)(?=$)",$Version.substring($Customer.length)}

$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
[System.IO.File]::WriteAllLines(($LocalConfigPath + "it.properties"), $Content, $Utf8NoBomEncoding)
