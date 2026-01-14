# DESCRIPTION: Automates Docker Desktop installation (WSL2, Hyper-V, WinGet).
# USAGE: Run as Administrator.

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator privileges required. Relaunching..."
    Start-Process powershell.exe "-File", ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
}

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
$ProgressPreference = 'SilentlyContinue'

function Install-WinGet {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "WinGet not found. Installing..."
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope CurrentUser
        Repair-WinGetPackageManager
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw "Failed to install WinGet." }
    }
}

function Enable-Feature {
    param([string]$Name, [string]$Display)
    if ((Get-WindowsOptionalFeature -FeatureName $Name -Online).State -ne "Enabled") {
        Write-Host "Enabling $Display..."
        Enable-WindowsOptionalFeature -Online -FeatureName $Name -All -NoRestart
        if ($LASTEXITCODE -eq 3010) { return $true } # Reboot required
        elseif ($LASTEXITCODE -ne 0) { throw "Failed to enable $Display." }
    }
    return $false
}

function Update-WSL {
    Write-Host "Updating WSL..."
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        wsl.exe --update
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "'wsl --update' failed. Trying manual..."
            $msi = "$env:TEMP\wsl_update_x64.msi"
            if (-not (Test-Path $msi)) { Invoke-WebRequest "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile $msi }
            Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msi`" /quiet"
        }
        wsl.exe --set-default-version 2
    }
}

function Install-Docker {
    if (Get-Command docker.exe -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Green "Docker is already installed."
        return
    }
    Write-Host "Installing Docker Desktop..."
    winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "Docker installation failed." }
    
    Write-Host -ForegroundColor Yellow "Reboot required. Restarting in 5s..."
    shutdown /r /t 5
}

Write-Host "Starting Docker setup..."

$reboot = $false
$features = @(
    @{N="Microsoft-Hyper-V-All"; D="Hyper-V"},
    @{N="Microsoft-Windows-Subsystem-Linux"; D="WSL"},
    @{N="Containers"; D="Containers"},
    @{N="VirtualMachinePlatform"; D="VM Platform"}
)
foreach ($f in $features) { if (Enable-Feature -Name $f.N -Display $f.D) { $reboot = $true } }

if ($reboot) {
    Write-Host -ForegroundColor Yellow "Reboot required for features. Restarting in 5s..."
    shutdown /r /t 5
    exit
}

Update-WSL
Install-WinGet
Install-Docker

Write-Host -ForegroundColor Green "Docker setup finished. Reboot if you haven't recently."