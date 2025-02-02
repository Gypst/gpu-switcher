# Run PowerShell as Administrator

# Function to check if the script is running with administrative privileges
function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If the script is not running as Administrator, restart it with elevated privileges
if (-not (Test-IsAdmin)) {
    # Get the path of the current script
    $scriptPath = $MyInvocation.MyCommand.Path

    # Restart the script with Administrator privileges
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    exit
}

# Main script logic below...
Write-Output "The script is running with Administrator privileges."

# Function to display the selection menu
function Show-Menu {
    Clear-Host
    Write-Output "================ GPU Management Menu ================`n"
    Write-Output "1. Disable NVIDIA GeForce RTX 3070 Laptop GPU`n"
    Write-Output "2. Enable NVIDIA GeForce RTX 3070 Laptop GPU`n"
    Write-Output "3. Exit`n"
}

# Function to find the target device
function Get-TargetDevice {
    param (
        [string]$DeviceName = "*NVIDIA GeForce RTX 3070 Laptop GPU*"
    )
    # Search for the device by its friendly name
    return Get-PnpDevice | Where-Object { $_.FriendlyName -like $DeviceName }
}

# Function to toggle the device (enable/disable)
function Toggle-Device {
    param (
        [string]$InstanceId,
        [bool]$Disable
    )
    try {
        if ($Disable) {
            Disable-PnpDevice -InstanceId $InstanceId -Confirm:$false
            Write-Output "Device has been successfully disabled.`n"
        } else {
            Enable-PnpDevice -InstanceId $InstanceId -Confirm:$false
            Write-Output "Device has been successfully enabled.`n"
        }
    } catch {
        Write-Output "Error: Unable to perform the operation. Please run the script as Administrator.`n"
    }
}

# Main script loop
do {
    Show-Menu
    $choice = Read-Host "Select an action"

    switch ($choice) {
        '1' {
            # Check if the script is running with admin privileges
            if (-not (Test-IsAdmin)) {
                Write-Output "Error: This operation requires administrative privileges. Please run the script as Administrator.`n"
                continue
            }

            # Disable the device
            $device = Get-TargetDevice
            if ($device) {
                Toggle-Device -InstanceId $device.InstanceId -Disable $true
            } else {
                Write-Output "NVIDIA GeForce RTX 3070 Laptop GPU not found.`n"
            }
        }
        '2' {
            # Check if the script is running with admin privileges
            if (-not (Test-IsAdmin)) {
                Write-Output "Error: This operation requires administrative privileges. Please run the script as Administrator.`n"
                continue
            }

            # Enable the device
            $device = Get-TargetDevice
            if ($device -and $device.Status -eq "Error") {
                Toggle-Device -InstanceId $device.InstanceId -Disable $false
            } else {
                Write-Output "NVIDIA GeForce RTX 3070 Laptop GPU not found or already enabled.`n"
            }
        }
        '3' {
            Write-Output "Exiting the script.`n"
        }
        default {
            Write-Output "Invalid choice. Please select 1, 2, or 3.`n"
        }
    }
    Start-Sleep -Seconds 3 # Pause for easier reading of messages
} until ($choice -eq '3')