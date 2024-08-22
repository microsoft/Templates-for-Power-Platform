<#
.SYNOPSIS
    Checks for on-premises data gateway installation.
.DESCRIPTION
    This script attempts to
    1. Check if the on-premises data gateway is installed and validates the
    if the version is greater than the minimum version requirement
    2. CheckSapConnector
    3. CheckVisualCPlusPlus
#>

$minimumVersion = "3000.150.11" # November 2022
$serviceName = "PBIEgwService"
$service = Get-Service $serviceName -ErrorAction SilentlyContinue

if ($service) {
    $servicePath = (Get-WmiObject Win32_Service | Where-Object { $_.Name -eq $serviceName }).PathName
    $exePath = $servicePath.Trim('"')
    $versionInfo = (Get-Command $exePath).FileVersionInfo
    $versionNumber = $versionInfo.ProductVersion

    if ([version]$versionNumber -ge [version]$minimumVersion) {
        Write-Host -NoNewLine "{'step': 'CheckGatewayVersion', 'status': 'Success', 'message': 'The on-premises data gateway is installed and version ($versionNumber) is greater than or equal to ($minimumVersion).'},"
    }
    else {
        Write-Host -NoNewLine "{'step': 'CheckGatewayVersion', 'status': 'Error', 'message': 'Your on-premises data gateway doesn't meet the minimum version, please upgrade by downloading the latest version here: https://go.microsoft.com/fwlink/?linkid=2240537.'},"
    }
    }
else {
    Write-Host -NoNewLine "{'step': 'CheckGatewayVersion', 'status': 'Error', 'message': 'The on-premises data gateway is not installed. Download it here: https://go.microsoft.com/fwlink/?linkid=2240537.'},"
}

    # .NET SDK for SAP
    $currentLocation = Get-Location
    $location = "C:\Windows\Microsoft.NET\assembly"
    $ncoAssemblies = Get-ChildItem -Path $location -Filter sapnco.dll -Recurse | Select-Object -ExpandProperty VersionInfo
    $location = "C:\Program Files\SAP\SAP_DotNetConnector3_Net40_x64"
    $ncoAssemblies += Get-ChildItem -Path $location -Filter sapnco.dll -Recurse | Select-Object -ExpandProperty VersionInfo
    $counter = 0
    Write-Host "value is $ncoAssemblies"
    foreach ($assembly in $ncoAssemblies) {
        $fileName = $assembly.FileName

        if ($assembly.FileVersion.StartsWith("3.1.")) {
            Write-Host -NoNewLine "{'step': 'CheckSapConnector', 'status': 'Error', 'message': 'SAP NetWeaver Connector version 3.1 was found. You need to uninstall $fileName. Visit this link for more information: https://go.microsoft.com/fwlink/?linkid=2240708.'},"
        }

        if ($fileName -like "*GAC_32*") {
            Write-Host -NoNewLine "{'step': 'CheckSapConnector', 'status': 'Error', 'message': 'A 32-bit version of the SAP NetWeaver Connector was found. You need to uninstall $fileName. Visit this link for more information: https://go.microsoft.com/fwlink/?linkid=2240708.'},"
        }

        if (($fileName -like "*GAC_64*" -or $fileName -like "*x64*") -and $assembly.FileVersion.StartsWith("3.0.")) {
            $counter++
            Write-Host -NoNewLine "{'step': 'CheckSapConnector', 'status': 'Success', 'message': 'SAP NetWeaver Connector 3.0 64-bit was successfully found.'},"
        }
    }

    if ($counter -eq 0) {
        Write-Host -NoNewLine "{'step': 'CheckSapConnector', 'status': 'Error', 'message': 'SAP NetWeaver Connector 3.0 64-bit was not found. Visit this link for more information: https://go.microsoft.com/fwlink/?linkid=2240708.'},"
    }

    Set-Location $currentLocation

$installedSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$name = "Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219"
$obj = $installedSoftware | Where-Object { $_.GetValue("DisplayName") -eq $name }

if ($obj) {
    Write-Host -NoNewLine "{'step': 'CheckVisualCPlusPlus', 'status': 'Success', 'message': '$name is installed.'}"
}
else {
    Write-Host -NoNewLine "{'step': 'CheckVisualCPlusPlus', 'status': 'Error', 'message': '$name is not installed.'}"
}