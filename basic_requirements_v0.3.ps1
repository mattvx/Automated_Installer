#msavini v0.5

# Check for if user is admin
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
	Write-Host "Please run this script with admin priviliges." -foregroundcolor Yellow
	Write-Host
	exit
	}	
#

Write-Host "Requirements install v0.5" -ForegroundColor Green
Start-Sleep 4

# Defining Functions

function alreadyInstalled {

    $programlist = get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object Displayname

    foreach ($i in $programlist) {
        
        $currentLine = $i.Displayname

        if ($currentLine -like "*7-Zip*") {

            $global:install7Zip = $false

        }

        if ($currentLine -like "*Notepad++*") {

            $global:installnotepad = $false

        }

    }

    $programlist2 = get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName

    foreach ($i in $programlist2) {
        
        $currentLine = $i.Displayname

        if ($currentLine -like "*Google Chrome") {

            $global:installchrome = $false

        }

        if ($currentLine -like "*WinSCP*") {

            $global:installWinSCP = $false

        }

    }

    if ($(test-path "C:\Users\$env:UserName\Desktop\Baretail.exe") -eq $true) {

        $global:BTInstall = $false

    }

}

function LinksCheck {

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
    clear-host
}

function ChromeInstall {

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
    
        Write-Progress -Activity "Installing Chrome..." -Status "Requirements 1/5"
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

}

function 7zipInstall {

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

        Write-Progress -Activity "Installing 7zip..." -Status "Requirements 2/5"
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
    
}

function WinSCPinstall {

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

    Start-Job -name winscpInstall -ScriptBlock $scriptblock | Out-Null

    $job = Get-Job -name winscpInstall

    while( $job.State -ne "Completed") {

        Write-Progress -Activity "Installing WinSCP..." -Status "Requirements 3/5"
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

}

function notepadInstall {

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

    Start-Job -name notepadInstall -ScriptBlock $scriptblock | Out-Null

    $job = Get-Job -name notepadInstall

    while( $job.State -ne "Completed") {

        Write-Progress -Activity "Installing Notepad++..." -Status "Requirements 4/5"
        Start-Sleep -m 300	
    }

    if ( $job.State -eq "Completed" ) {
        Clear-Host
        Write-Host "Notepad++ Installation complete!" -ForegroundColor Green
        Start-Sleep 3    
	}
}

function baretailInstall {

    Write-Host "Installing Baretail..." -ForegroundColor Green
    Start-Sleep 2
    Write-Host

    $scriptblock = {
        $Path = $env:TEMP
        $Installer = "baretail.exe"
        $url = "https://www.baremetalsoft.com/baretail/download.php?p=m"
        Invoke-WebRequest -Uri $url -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -OutFile $Path\$Installer
        Move-Item -Path "$env:TEMP\baretail.exe" -Destination "C:\Users\$env:UserName\Desktop\Baretail.exe"
        Start-Sleep 3
    }

    Start-Job -name baretailInstall -ScriptBlock $scriptblock | Out-Null

    $job = Get-Job -name baretailInstall

    while( $job.State -ne "Completed") {

        Write-Progress -Activity "Copying BareTail..." -Status "Requirements 5/5"
        Start-Sleep -m 300	
    }

    if ( $job.State -eq "Completed" ) {
        Clear-Host
        Write-Host "BareTail Installation complete!" -ForegroundColor Green
        Start-Sleep 3

    }

    Write-Host
    Write-Host
    Clear-Host

}

Write-Host "Installing requirements: Chrome, 7zip, WinSCP, Notepad++, BareTail"
Write-Host

# Checking if links are working
Write-Host "Checking if links are working..." -ForegroundColor Green
LinksCheck

# Checking if programs are already installed
alreadyInstalled

# Installing Chrome if is not already installed
if ($installchrome -eq $false) {

    Write-Host "Chrome already installed. Skipping..."
    Start-Sleep 2

} else {

    ChromeInstall

}

# Installing 7zip if is not already installed
if ($install7Zip -eq $false) {

    Write-Host "7zip already installed. Skipping..."
    Start-Sleep 2

} else {

    7zipInstall

}

# Installing WinSCP if is not already installed
if ($installWinSCP -eq $false) {

    Write-Host "WinSCP already installed. Skipping..."
    Start-Sleep 2

} else {

     WinSCPinstall

}

# Installing Notepad++ if is not already installed
if ($installnotepad -eq $false) {

    Write-Host "Notepad++ already installed. Skipping..."
    Start-Sleep 2

} else {

    notepadInstall

}

# Installing Baretail if is not already installed
if ($BTInstall -eq $false) {

    Write-Host "Baretail already installed. Skipping..."
    Start-Sleep 2

} else {

    baretailInstall

}

Write-Host
Write-Host
Clear-Host
Write-Host "All the standard requirements are installed!" -ForegroundColor Green -BackgroundColor Blue
