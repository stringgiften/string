# vendor to scan for
#$vendor = "*Adobe*"

# if all 
$vendor = "*"


function uploadFile($_outfilename){
    # Upload list to known FTP location
    # FTP Server information
    

    $username = "test"
    $password = "test@123"
    $ftpserver = "172.16.5.169"

    $remotefile = "ftp://$ftpserver/$_outfilename"
    $ftprequest = [System.Net.FtpWebRequest]::Create("$remotefile")
    $ftprequest = [System.Net.FtpWebRequest]$FTPRequest
    $ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftprequest.Credentials = new-object System.Net.NetworkCredential($username, $password)
    $ftprequest.UseBinary = $True
    $ftprequest.UsePassive = $True

    # Read the File for Upload
    $content = gc -en byte $_outfilename

    if($content.Length -eq 0) {
        Write-Host "File appears to be empty"
        return
    }

    $ftprequest.ContentLength = $content.Length

    # Get Stream Request by bytes
    $stream = $FTPRequest.GetRequestStream()
    $stream.Write($content, 0, $content.Length)

    # Cleanup
    $stream.Close()
    $stream.Dispose()
}


Write-Host ""
Write-Host " ____  _  _  __ _   ___  ____  _  _  ____  __  __   __ _ "
Write-Host "/ ___)( \/ )(  ( \ / __)(  __)/ )( \/ ___)(  )/  \ (  ( \"
Write-Host "\___ \ )  / /    /( (__  ) _) ) \/ (\___ \ )((  O )/    /"
Write-Host "(____/(__/  \_)__) \___)(__)  \____/(____/(__)\__/ \_)__)"
Write-Host ""
Write-Host "Syncfusion Asset Management Tool"
Write-Host "Version 1.0.0.1, 2015"


# Gather local machine/user/date information
$name = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.replace("\", "-")
$machine = [Environment]::MachineName
$now = Get-Date -format "dd-MMM-yyyy-HH-mm-ss"

$outfilename = $now + "-" + $machine + "-" + $name + "-32.csv"

$osname = Get-CimInstance Win32_OperatingSystem | Select-Object Caption 

Write-Host "Gathering information. This may take a minute..."

If (Test-Path $outfilename){
	Remove-Item $outfilename
}

$software = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Sort-Object DisplayName | Where-Object {$_.Publisher -like $vendor} `
	|Select-Object @{Name='Scan Time';Expression={$now}}, @{Name='Operating System';Expression={$osname.Caption}}, @{Name='User Name';Expression={$name}}, @{Name='Machine Name';Expression={$machine}},`
		DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation  `
	| Export-Csv C:\$outfilename -NoTypeInformation

$outfilename64 = $now + "-" + $machine + "-" + $name + "-64.csv"

If (Test-Path $outfilename64){
	Remove-Item $outfilename64
}

$64software = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Sort-Object DisplayName | Where-Object {$_.Publisher -like $vendor} `
	|Select-Object @{Name='Scan Time';Expression={$now}}, @{Name='Operating System';Expression={$osname.Caption}}, @{Name='User Name';Expression={$name}}, @{Name='Machine Name';Expression={$machine}},`
		DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation `
	| Export-Csv C:\$outfilename64 -NoTypeInformation

uploadFile($outfilename)
uploadFile($outfilename64)

Write-Host "Task has been completed successfully"
Read-Host "Press any key to close"
