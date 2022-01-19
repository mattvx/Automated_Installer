#msavini v0.3

# Check for if user is admin
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
	Write-Host "Please run this script with admin priviliges." -foregroundcolor Yellow
	Write-Host
	exit
	}	
#

##################
# links checking #
##################

Write-Host "Checking if links are working..." -ForegroundColor Green

$7zipurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} | Select-Object -First 1 | Select-Object -ExpandProperty href) 

$linksArray = @(
    'http://dl.google.com/chrome/install/375.126/chrome_installer.exe',
    $7zipurl,
    "https://sourceforge.net/projects/winscp/files/WinSCP/5.19.5/WinSCP-5.19.5-Setup.exe",
    "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.2/npp.8.2.Installer.x64.exe"
    )

foreach ($i in $linksArray) {

    # invoking web request
    $HTTP_Request = [System.Net.WebRequest]::Create($i)

    # We then get a response from the site.
    $HTTP_Response = $HTTP_Request.GetResponse()

    # We then get the HTTP code as an integer.
    $HTTP_Status = [int]$HTTP_Response.StatusCode

    If ($HTTP_Status -ne 200) {
        Write-Host $i
        Write-Host "May be down, please check the link!" -ForegroundColor Red
        exit
    }

}

Write-Host "All links are OK! Proceeding..." -ForegroundColor Green
Start-Sleep 2
Clear-Host

###############

Write-Host "Installing requirements: Chrome, 7zip, WinSCP, Notepad++"
Write-Host

##################
# Chrome Install #
##################
Write-Host "Installing Google Chrome..." -ForegroundColor Green
Start-Sleep 2
Write-Host

# Actual commands in a block
$scriptblock = {
    $Path = $env:TEMP
    $Installer = "chrome_installer.exe"
    Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Path\$Installer
    Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait
    Remove-Item $Path\$Installer
}

# Starting the job to later use a progress bar
Start-Job -name ChromeInstall -ScriptBlock $scriptblock | Out-Null

$job = Get-Job -name ChromeInstall

# while job status is not "Completed". write progres...
while( $job.State -ne "Completed") {

	Write-Progress -Activity "Installing Chrome..." -Status "Requirements 1/4"
	Start-Sleep -m 300	
}

if ( $job.State -eq "Completed" ) {
    Clear-Host
    Write-Host "Chrome Installation complete!" -ForegroundColor Green
    Start-Sleep 3

}

#Screen Cleaning
Write-Host
Write-Host
Clear-Host

##################
# 7zip Install   #
##################

Write-Host "Installing 7zip..." -ForegroundColor Green
Start-Sleep 2
Write-Host

$scriptblock = {
$dlurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} | Select-Object -First 1 | Select-Object -ExpandProperty href)
$installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
Invoke-WebRequest $dlurl -OutFile $installerPath
Start-Process -FilePath $installerPath -Args "/S" -Verb RunAs -Wait
Remove-Item $installerPath
}

Start-Job -name SevenZipInstall -ScriptBlock $scriptblock | Out-Null

$job = Get-Job -name SevenZipInstall

while( $job.State -ne "Completed") {

	Write-Progress -Activity "Installing 7zip..." -Status "Requirements 2/4"
	Start-Sleep -m 300	
}

if ( $job.State -eq "Completed" ) {
    Clear-Host
    Write-Host "7zip Installation complete!" -ForegroundColor Green
    Start-Sleep 3

}

#Screen Cleaning
Write-Host
Write-Host
Clear-Host

##################
# WinSCP Install #
##################

Write-Host "Installing WinSCP..." -ForegroundColor Green
Start-Sleep 2
Write-Host

$scriptblock = {
    $Path = $env:TEMP
    $Installer = "WinSCP.exe"
    $url = "https://sourceforge.net/projects/winscp/files/WinSCP/5.19.5/WinSCP-5.19.5-Setup.exe"
    Invoke-WebRequest -Uri $url -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -OutFile $Path\$Installer
    Start-Process -FilePath $Path\$Installer -Args "/VERYSILENT /ALLUSERS" -Verb RunAs -Wait
    Remove-Item $Path\$Installer
}

Start-Job -name ChromeInstall -ScriptBlock $scriptblock | Out-Null

$job = Get-Job -name ChromeInstall

while( $job.State -ne "Completed") {

	Write-Progress -Activity "Installing WinSCP..." -Status "Requirements 3/4"
	Start-Sleep -m 300	
}

if ( $job.State -eq "Completed" ) {
    Clear-Host
    Write-Host "WinSCP Installation complete!" -ForegroundColor Green
    Start-Sleep 3

}

Write-Host
Write-Host
Clear-Host

#####################
# Notepad++ Install #
#####################

Write-Host "Installing Notepad++..." -ForegroundColor Green
Start-Sleep 2
Write-Host

$scriptblock = {
    $Path = $env:TEMP
    $Installer = "notepad.exe"
    Invoke-WebRequest "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.2/npp.8.2.Installer.x64.exe" -OutFile $Path\$Installer
    Start-Process -FilePath $Path\$Installer -Args "/S" -Verb RunAs -Wait
    Remove-Item $Path\$Installer
}

Start-Job -name ChromeInstall -ScriptBlock $scriptblock | Out-Null

$job = Get-Job -name ChromeInstall

while( $job.State -ne "Completed") {

	Write-Progress -Activity "Installing Notepad++..." -Status "Requirements 4/4"
	Start-Sleep -m 300	
}

if ( $job.State -eq "Completed" ) {
    Clear-Host
    Write-Host "Notepad++ Installation complete!" -ForegroundColor Green
    Start-Sleep 3

}

Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Clear-Host
Clear-Host
Clear-Host
Write-Host "All the standard requirements are installed!" -ForegroundColor Green -BackgroundColor Blue
