# Check if script is running as administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Please run this script as an administrator."
    Exit
}

# Step 1: Install Windows Terminal
Write-Output "Installing Windows Terminal..."
winget install --id Microsoft.WindowsTerminal -e --source msstore --accept-package-agreements --accept-source-agreements

# Step 2: Enable Windows Subsystem for Linux (WSL) and Virtual Machine Platform
Write-Output "Enabling WSL and Virtual Machine Platform..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Step 4: Install Ubuntu 22.04.05 LTS via WSL
Write-Output "Installing Ubuntu 22.04.05 LTS..."
wsl --install -d Ubuntu-22.04

# Step 5: Set WSL2 as the default version (optional, recommended for newer functionality)
Write-Output "Setting WSL2 as the default version..."
wsl --set-default-version 2

Write-Output "Installation of Windows Terminal, WSL, and Ubuntu 22.04.05 LTS complete."

# Install and configure WinRM for Ansible from WSL
Write-Output "Starting WinRM setup for Ansible..."

# Ensure WinRM is installed and configured to start
Write-Output "Enabling and starting WinRM service..."
winrm quickconfig -force
Enable-PSRemoting -Force

# Get the computer's name
$computerName = $env:COMPUTERNAME

# Generate a self-signed certificate with the computer's DNS name and store it in the LocalMachine store
$cert = New-SelfSignedCertificate -DnsName $computerName -CertStoreLocation Cert:\LocalMachine\My

# Output the thumbprint of the generated certificate
Write-Output "Certificate Thumbprint: $($cert.Thumbprint)"
Write-Output "Certificate generated for computer: $computerName"

# Set up listener for HTTP on all IP addresses (0.0.0.0)
Write-Output "Setting up WinRM listener for HTTP..."
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
winrm create winrm/config/Listener?Address=IP:127.0.0.1+Transport=HTTPS

# Allow unencrypted traffic (for HTTP)
Write-Output "Configuring WinRM to allow unencrypted traffic..."
winrm set winrm/config/service @{AllowUnencrypted="true"}

# Allow NTLM authentication
Write-Output "Enabling NTLM authentication..."
winrm set winrm/config/service/auth @{Basic="true"}

# Set a high timeout for idle connections (default is 60 seconds)
Write-Output "Setting WinRM timeout to avoid timeouts..."
winrm set winrm/config @{MaxTimeoutms="180000"}

# Open the firewall
New-NetFirewallRule -Name "WinRM HTTPS" -DisplayName "WinRM HTTPS" -Protocol TCP -LocalPort 5986 -Action Allow

Write-Output "WinRM setup complete. Ready for Ansible communication from WSL over HTTP using NTLM."
