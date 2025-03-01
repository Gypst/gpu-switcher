param (
    [switch]$Quiet
)

function Get-TargetProcesses {
    Get-Process | Where-Object { $_.Name -like "nvcontainer*" -or $_.Name -like "NVDisplay.Container*" -or $_.Name -like "NvOAWrapperCache.exe" }
}

function Terminate-Process {
    param (
        $process
    )
    try {
        Stop-Process -Id $process.Id -Force -ErrorAction Stop
        if (-not $Quiet) {
            Write-Output "Process $($process.Name) with ID $($process.Id) has been terminated."
        }
    }
    catch {
        if (-not $Quiet) {
            Write-Warning "Failed to terminate process $($process.Name) with ID $($process.Id). Error: $_"
        }
    }
}

function Handle-InteractiveMode {
    param (
        $targetProcesses
    )
    if ($targetProcesses) {
        Write-Output "The following processes will be terminated:"
        $targetProcesses | Format-Table Name, Id

        $confirmation = Read-Host "Are you sure you want to terminate these processes? (Y/n)"

        if ($confirmation -eq 'y' -or $confirmation -eq '') {
            foreach ($process in $targetProcesses) {
                Terminate-Process -process $process
            }
        }
        else {
            Write-Output "Operation canceled."
        }
    }
    else {
        Write-Output "No target processes were found."
    }
}

function Handle-QuietMode {
    param (
        $targetProcesses
    )
    foreach ($process in $targetProcesses) {
        Terminate-Process -process $process
    }
}

function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$targetProcesses = Get-TargetProcesses

if (-not (Test-IsAdmin)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = @()

    if ($Quiet) { $arguments += "-Quiet" }
    
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $arguments"
    exit
}


if ($Quiet) {
    Handle-QuietMode -targetProcesses $targetProcesses
}
else {
    Handle-InteractiveMode -targetProcesses $targetProcesses
}