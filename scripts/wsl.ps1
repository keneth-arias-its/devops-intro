# PowerShell script to setup and run MQTT Explorer in WSL (Ubuntu-24.04)

$Distro = "Ubuntu-24.04"

# 1. Check if the distribution is installed
Write-Host "Checking if $Distro is installed..."
$installed = $false
try {
    # If the distro exists, this command will succeed (exit code 0)
    wsl -d $Distro -- true 2>$null
    if ($LASTEXITCODE -eq 0) {
        $installed = $true
    }
} catch {
    $installed = $false
}

if (-not $installed) {
    Write-Host "$Distro not found. Installing..."
    wsl --install -d $Distro
    Write-Host "----------------------------------------------------------------"
    Write-Host "IMPORTANT: A new window has opened to install Ubuntu."
    Write-Host "Please complete the username/password setup in that window."
    Write-Host "Once finished, close that window and RERUN this script."
    Write-Host "----------------------------------------------------------------"
    exit
} else {
    Write-Host "$Distro is already installed."
}

# 2. Enable Systemd (Required for Snap)
Write-Host "Ensuring Systemd is enabled for Snap support..."
# Check if systemd is already enabled in /etc/wsl.conf
$checkSystemd = wsl -d $Distro -u root -- bash -c "grep -q 'systemd=true' /etc/wsl.conf && echo 'enabled' || echo 'disabled'"

if ($checkSystemd -eq "disabled") {
    Write-Host "Enabling systemd in /etc/wsl.conf..."
    wsl -d $Distro -u root -- bash -c "echo -e '[boot]\nsystemd=true' >> /etc/wsl.conf"
    
    Write-Host "Restarting $Distro to apply changes..."
    wsl --terminate $Distro
    Start-Sleep -Seconds 2
}

# 3. Install MQTT Explorer via Snap
Write-Host "Checking/Installing MQTT Explorer..."
# We run as root to avoid sudo password prompts for the installation
# We also ensure snapd is installed
wsl -d $Distro -u root -- bash -c "if ! snap list | grep -q mqtt-explorer; then echo 'Installing prerequisites...'; apt-get update && apt-get install -y snapd; echo 'Installing mqtt-explorer...'; snap install mqtt-explorer; else echo 'MQTT Explorer is already installed.'; fi"

# 4. Execute MQTT Explorer
Write-Host "Launching MQTT Explorer..."
# Launch as the default user (not root) to ensure correct GUI permissions if configured
wsl -d $Distro -- bash -c "/snap/bin/mqtt-explorer"
