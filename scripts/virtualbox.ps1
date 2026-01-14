# DESCRIPTION: Automates VirtualBox, Vagrant, and Syncthing installation.
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

function Install-App {
    param([string]$Id, [string]$Name, [string]$Cmd)
    
    if ($Cmd -and (Get-Command $Cmd -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor Green "$Name is already installed."
        return
    }
    
    winget list --id $Id -e 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host -ForegroundColor Green "$Name is already installed (detected via WinGet)."
        return
    }

    Write-Host "Installing $Name..."
    winget install -e --id $Id --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335175) { Write-Host "$Name installed." }
    else { Write-Error "$Name installation failed." }
}

Write-Host "Starting VirtualBox env setup..."

Install-WinGet

Write-Host "Checking Windows Hypervisor Platform..."
$hv = Get-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform
if ($hv.State -ne 'Enabled') {
    Write-Host "Enabling Windows Hypervisor Platform..."
    Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All -NoRestart | Out-Null
    Write-Warning "Windows Hypervisor Platform enabled. Reboot will be required."
} else {
    Write-Host -ForegroundColor Green "Windows Hypervisor Platform is already enabled."
}

Install-App -Id "Oracle.VirtualBox" -Name "VirtualBox" -Cmd "VirtualBox"
Install-App -Id "Hashicorp.Vagrant" -Name "Vagrant" -Cmd "vagrant"
Install-App -Id "Syncthing.Syncthing" -Name "Syncthing" -Cmd "syncthing"

Write-Host -ForegroundColor Green "Installation finished. Reboot recommended for VirtualBox drivers."
