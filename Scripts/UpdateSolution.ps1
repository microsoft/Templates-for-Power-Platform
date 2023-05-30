<#

Solution Updater

This script provides a way to update local Solutions with their updates from their Dev Environment.

#>

# Gather Input Parameters
$solutionName = $args[0]
param (
    [string]$solutionName,
    [string]$solutionVersion
)

# Validation Steps
if(Get-Process -Name msbuild -ErrorAction SilentlyContinue) {
    throw "The msbuild process is currently running. Cannot run script."
}

Write-Host "Moving into solution folder."
Set-Location -Path .\Accelerators\${solutionName}\

Write-Host "Updating Version"
pac solution online-version --solution-name $solutionName --solution-version $solutionVersion

Write-Host "Pulling Solution Changes"
pac solution sync --processCanvasApps

Write-Host "Done"
