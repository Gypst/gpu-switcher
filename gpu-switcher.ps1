# Run PowerShell as Administrator
param (
    [switch]$silenceEnable, # Argument to enable the GPU silently
    [switch]$silenceDisable, # Argument to disable the GPU silently
    [string]$deviceName = "*NVIDIA GeForce RTX 3070 Laptop GPU*", # Device name (configurable)
    [switch]$debug # Debug mode for additional logging
)

# Function to check if the script is running with administrative privileges
function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to find the target device
function Get-TargetDevice {
    param (
        [string]$DeviceName
    )
    # Search for the device by its friendly name
    if ($debug) {
        Write-Output "DEBUG: Searching for device with name '$DeviceName'."
        Start-Sleep -Seconds 2
    }
    return Get-PnpDevice | Where-Object { $_.FriendlyName -like $DeviceName }
}

# Function to toggle the device (enable/disable)
function Toggle-Device {
    param (
        [string]$InstanceId,
        [bool]$Disable
    )
    try {
        if ($debug) {
            Write-Output "DEBUG: Toggling device with InstanceId '$InstanceId'. Disable: $Disable"
            Start-Sleep -Seconds 2
        }
        if ($Disable) {
            Disable-PnpDevice -InstanceId $InstanceId -Confirm:$false
            Write-Output "Device has been successfully disabled.`n"
        }
        else {
            Enable-PnpDevice -InstanceId $InstanceId -Confirm:$false
            Write-Output "Device has been successfully enabled.`n"
        }
    }
    catch {
        # Handle errors (e.g., insufficient permissions)
        Write-Output "Error: Unable to perform the operation. Please ensure the script is running as Administrator.`nReason: $_"
    }
}

# Function to display the selection menu
function Show-Menu {
    Clear-Host
    $device = Get-TargetDevice -DeviceName $deviceName
    if ($device) {
        Write-Output "================ GPU Management Menu ================`n"
        Write-Output "Current state of '$($device.FriendlyName)': $($device.Status)`n"
        Write-Output "1. Disable $($device.FriendlyName)"
        Write-Output "2. Enable $($device.FriendlyName)"
        Write-Output "3. Exit"
    }
    else {
        Write-Output "Device '$deviceName' not found.`n"
        Write-Output "1. Retry"
        Write-Output "2. Exit"
    }
}

# ================ Main script logic ================

# If the script is not running as Administrator, restart it with elevated privileges
if (-not (Test-IsAdmin)) {
    if ($debug) {
        Write-Output "DEBUG: Script is not running as Administrator. Restarting with elevated privileges."
        Start-Sleep -Seconds 2
    }
    # Get the path of the current script and arguments
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = @()

    # Rebuild arguments to include switch parameters
    if ($silenceEnable) { $arguments += "-silenceEnable" }
    if ($silenceDisable) { $arguments += "-silenceDisable" }
    if (![string]::IsNullOrWhiteSpace($deviceName)) { $arguments += "-deviceName", "`"$deviceName`"" }
    if ($debug) { $arguments += "-debug" } # Add debug flag if enabled

    if ($debug) {
        Write-Output "DEBUG: Arguments passed: $arguments"
        Start-Sleep -Seconds 2
    }
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $arguments"
    exit
}

# Handle silent mode arguments
if ($debug) {
    Write-Output "DEBUG: Checking silent mode arguments."
    Start-Sleep -Seconds 2
}
if ($silenceEnable -or $silenceDisable) {
    if ($debug) {
        Write-Output "DEBUG: Entering silent mode."
        Start-Sleep -Seconds 2
    }
    $device = Get-TargetDevice -DeviceName $deviceName
    if (-not $device) {
        Write-Output "Device '$deviceName' not found.`n"
        Start-Sleep -Seconds 2
        exit
    }

    if ($debug) {
        Write-Output "DEBUG: Device found: $($device.FriendlyName)"
        Start-Sleep -Seconds 2
    }
    # Check if the device is already in the desired state
    if ($device.Status -eq "OK" -and $silenceEnable) {
        Write-Output "Device '$($device.FriendlyName)' is already enabled.`n"
        Start-Sleep -Seconds 2
        exit
    }
    if ($device.Status -eq "Error" -and $silenceDisable) {
        Write-Output "Device '$($device.FriendlyName)' is already disabled.`n"
        Start-Sleep -Seconds 2
        exit
    }

    if ($debug) {
        Write-Output "DEBUG: Performing toggle operation."
        Start-Sleep -Seconds 2
    }
    # Perform the toggle operation
    if ($silenceEnable) {
        Toggle-Device -InstanceId $device.InstanceId -Disable $false
    }
    elseif ($silenceDisable) {
        Toggle-Device -InstanceId $device.InstanceId -Disable $true
    }
    exit
}

# Interactive mode (menu-based)
if ($debug) {
    Write-Output "DEBUG: Entering interactive mode."
    Start-Sleep -Seconds 2
}
do {
    Show-Menu
    $choice = Read-Host "`nSelect an action"
    
    switch ($choice) {
        '1' {
            # Disable the device
            if ($debug) {
                Write-Output "DEBUG: User selected option 1 (Disable)."
                Start-Sleep -Seconds 2
            }
            $device = Get-TargetDevice -DeviceName $deviceName
            if (-not $device) {
                Write-Output "Device '$deviceName' not found.`n"
                continue
            }
            if ($device.Status -eq "Error") {
                Write-Output "Device '$($device.FriendlyName)' is already disabled.`n"
                continue
            }
            Toggle-Device -InstanceId $device.InstanceId -Disable $true
        }
        '2' {
            # Enable the device
            if ($debug) {
                Write-Output "DEBUG: User selected option 2 (Enable)."
                Start-Sleep -Seconds 2
            }
            $device = Get-TargetDevice -DeviceName $deviceName
            if (-not $device) {
                Write-Output "Device '$deviceName' not found.`n"
                continue
            }
            if ($device.Status -eq "OK") {
                Write-Output "Device '$($device.FriendlyName)' is already enabled.`n"
                continue
            }
            Toggle-Device -InstanceId $device.InstanceId -Disable $false
        }
        '3' {
            Write-Output "Exiting the script.`n"
        }
        default {
            Write-Output "Invalid choice. Please select 1, 2, or 3.`n"
        }
    }
    Start-Sleep -Seconds 1 # Pause for easier reading of messages
} until ($choice -eq '3')