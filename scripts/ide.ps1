# DESCRIPTION: Automates installation of dev tools (VS Code, Git, Terminal, Python, Node.js, uv) on Windows.
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
    } else { Write-Host "WinGet is ready." }
}

function Install-App {
    param([string]$Id, [string]$Name, [string]$Cmd, [switch]$CheckList)
    
    if ($Cmd -and (Get-Command $Cmd -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor Green "$Name is already installed."
        return
    }
    if ($CheckList) {
        winget list --id $Id -e 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host -ForegroundColor Green "$Name is already installed (detected via WinGet)."
            return
        }
    }

    Write-Host "Installing $Name..."
    winget install -e --id $Id --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335175) { Write-Host "$Name installed." }
    else { Write-Error "$Name installation failed." }
}

function Install-Python {
    $Id = "Python.Python.3.13"
    $isInstalled = (Get-Command python -ErrorAction SilentlyContinue) -and (python --version 2>$null)
    
    if ($isInstalled) {
        Write-Host -ForegroundColor Green "Python 3.13 is already installed."
        return
    }

    # Check via WinGet if not in PATH
    winget list --id $Id -e 2>$null | Out-Null
    $detected = ($LASTEXITCODE -eq 0)

    if (-not $detected) {
        Write-Host "Installing Python 3.13..."
        winget install -e --id $Id --accept-package-agreements --accept-source-agreements
    }

    # Fix PATH if installed (newly or previously) but not working
    if ($detected -or $LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335175) {
        $regPath = "Software\Python\PythonCore\3.13\InstallPath"
        $installPath = try { (Get-ItemProperty "HKCU:\$regPath" -ErrorAction Stop).'(default)' } catch { try { (Get-ItemProperty "HKLM:\$regPath" -ErrorAction Stop).'(default)' } catch { $null } }
        
        if ($installPath -and (Test-Path $installPath)) {
            $scriptsPath = Join-Path $installPath "Scripts"
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            
            # Prepend to User PATH
            $pathParts = @($installPath, $scriptsPath) + ($userPath -split ';' | Where-Object { $_ -ne "" -and $_ -ne $installPath -and $_ -ne $scriptsPath })
            $newUserPath = $pathParts -join ';'
            
            if ($newUserPath -ne $userPath) {
                [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
                Write-Host -ForegroundColor Green "Fixed User PATH: Python prepended."
            }

            # Update Session PATH
            $env:Path = "$installPath;$scriptsPath;" + $env:Path
            Write-Host -ForegroundColor Green "Session PATH updated."
            python --version
        } else {
            Write-Warning "Python installed but path not found in Registry."
        }
    }
}

Write-Host "Starting installation..."

Install-WinGet
Install-App -Id "Microsoft.WindowsTerminal" -Name "Windows Terminal" -Cmd "wt" -CheckList
Install-App -Id "Git.Git" -Name "Git" -Cmd "git"
Install-App -Id "Microsoft.VisualStudioCode" -Name "VS Code" -Cmd "code"
Install-App -Id "OpenJS.NodeJS" -Name "Node.js" -Cmd "node"
Install-Python
Install-App -Id "astral-sh.uv" -Name "uv" -Cmd "uv"

Write-Host "`n--------------------------------------------------------"
Write-Host -ForegroundColor Green "Installation finished."
Write-Host "Restart your terminal and check all tools are available."
