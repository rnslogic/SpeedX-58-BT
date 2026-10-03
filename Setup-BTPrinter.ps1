<#
.SYNOPSIS
    RNSRetail Bluetooth Printer Auto-Setup Script
#>

# 1. Administrator rights check
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator rights required. Restarting script in admin mode..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  RNSRetail Bluetooth Printer Auto-Setup  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 2. Path to the driver executable
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DriverExe = Join-Path -Path $ScriptDir -ChildPath "POS-58-Series.exe"

# 3. Search for Bluetooth COM Port
Write-Host "`n[1/3] Searching for Bluetooth Printer COM Port..." -ForegroundColor Yellow
$btDevice = Get-WmiObject Win32_PnPEntity | Where-Object { $_.Name -match "Standard Serial over Bluetooth link \(COM(\d+)\)" }

if (-not $btDevice) {
    Write-Host "Error: No Bluetooth Printer found!" -ForegroundColor Red
    Write-Host "Please pair the printer in Windows Bluetooth Settings first (Password: 1234)." -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit
}

# Extract COM Port Name
$portName = [regex]::Match($btDevice.Name, 'COM\d+').Value
Write-Host "Success: Bluetooth Printer found on $portName" -ForegroundColor Green

# 4. Install Driver Silently
if (Test-Path $DriverExe) {
    Write-Host "`n[2/3] Installing Printer Driver (Please wait)..." -ForegroundColor Yellow
    $installProcess = Start-Process -FilePath $DriverExe -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait -PassThru
    Write-Host "Driver Installation process finished." -ForegroundColor Green
} else {
    Write-Host "Error: $DriverExe not found!" -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit
}

# 5. Configure Printer to use Bluetooth COM Port
Write-Host "`n[3/3] Configuring Printer Port to $portName..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Add port if not exists
$portExists = Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue
if (-not $portExists) {
    Add-PrinterPort -Name $portName
}

# Link printer to port
$printerName = "POS-58-Series" 
$printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue

if ($printer) {
    Set-Printer -Name $printerName -PortName $portName
    Write-Host "Success: Printer ($printerName) is now linked to Bluetooth ($portName)!" -ForegroundColor Green
} else {
    Write-Host "Warning: Printer '$printerName' not found. You may need to select $portName manually." -ForegroundColor Yellow
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "       Setup Completed Successfully!      " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Start-Sleep -Seconds 5
