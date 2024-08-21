<#
.SYNOPSIS
    Validates Kerberos Configuration.
.DESCRIPTION
    This script validates Kerberos configuration.
.PARAMETER sapCclDllPath
    The path to the SAP Common Crypto Library Dll.
.PARAMETER sapCclIniPath
    The path to the sapcrypto.ini file
.PARAMETER sapServicePrincipalName
    The SAP Service Principal Name
.PARAMETER servicePrincipal
    The Service Principal
.PARAMETER opdgServicePrincipal
    The OPDG Service Principal
#>

param (
    [string]$sapCclDllPath,
    [string]$sapCclIniPath,
    [string]$sapServicePrincipalName,
    [string]$servicePrincipal,
    [string]$opdgServicePrincipal
)

# Required for Kerberos checks
$module = Get-Module -ListAvailable -Name ActiveDirectory

if ($module) {
    Write-Host -NoNewLine "{'step': 'CheckActiveDirectoryPowerShellModule', 'status': 'Success', 'message': 'The ActiveDirectory PowerShell module is installed.'},"
}
else {
    Write-Host -NoNewLine  "{'step': 'CheckActiveDirectoryPowerShellModule', 'status': 'Error', 'message': 'The ActiveDirectory PowerShell module is not installed. Kerberos checks can not be performed. Install it by following this link: https://go.microsoft.com/fwlink/?linkid=2240709.'},"
}

#CheckCommonCryptoLibVersion
$path = $sapCclDllPath
$minimumVersion = "8.5.25.0"

try {
    $actualVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path).FileVersion
}
catch {
    Write-Host -NoNewLine "{'step': 'CheckCommonCryptoLibVersion', 'status': 'Error', 'message': 'CommonCryptoLibVersion error occurred: $_. Did you specify the correct path to the SAP CommonCryptoLib DLL?'},"
    return
}

if ([version]$actualVersion -ge [version]$minimumVersion) {
    Write-Host -NoNewLine "{'step': 'CheckCommonCryptoLibVersion', 'status': 'Success', 'message': 'SAP Common Crypto Library is running version $actualVersion.'},"
}
else {
    Write-Host -NoNewLine "{'step': 'CheckCommonCryptoLibVersion', 'status': 'Error', 'message': 'SAP Common Crypto Library is running an old version $actualVersion. Download the latest version of the SAP Common Crypto Library from SAP.'},"
}

#CheckSapCryptoIniFile
$path = $sapCclIniPath

if (-not $path) {
    Write-Host -NoNewLine "{'step': 'CheckSapCryptoIniFile', 'status': 'Warning', 'message': 'Skipping SapCryptoIniFile check because no file path was provided.'},"
    return
}

$clientRole = "ccl/snc/enable_kerberos_in_client_role=1"

try {
    $iniContent = Get-Content -Path $path -ErrorAction Stop
}
catch {
    Write-Host -NoNewLine "{'step': 'CheckSapCryptoIniFile', 'status': 'Error', 'message': 'SapCryptoIniFile error occurred: $_. Did you specify the correct path to the sapcrypto.ini file?'},"
    return
}

if ($iniContent -match [regex]::Escape($clientRole).Replace('=', '\s*=\s*')) {
    Write-Host -NoNewLine "{'step': 'CheckSapCryptoIniFile', 'status': 'Success', 'message': 'sapcrypto.ini has the correct parameters: $clientRole.'},"
}
else {
    Write-Host -NoNewLine "{'step': 'CheckSapCryptoIniFile', 'status': 'Error', 'message': 'sapcrypto.ini is missing the correct parameters. Modify sapcrypto.ini and add $clientRole.'},"
}

#checkSystemEnvVariable -variableName "CCL_PROFILE"

if ($env:CCL_PROFILE) {
    Write-Host -NoNewLine "{'step': 'CheckSapCryptoIniFile', 'status': 'Success', 'message': 'System Environment variable 'CCL_PROFILE' exists'},"
}
else {
Write-Host -NoNewLine "{'step': 'CheckSapCryptoIniFile', 'status': 'Error', 'message': 'Need to create a CCL_PROFILE system environment variable and set its value to the path to sapcrypto.ini.'},"
}

#CheckServicePrincipalName
$sapServicePrincipalName = $sapServicePrincipalName

if (-not $sapServicePrincipalName) {
    Write-Host -NoNewLine "{'step': 'CheckServicePrincipalName', 'status': 'Warning', 'message': 'Skipping ServicePrincipalName check because no service principal name was provided.'},"
    return
}
try {
    $servicePrincipal = Get-ADUser -Filter { ServicePrincipalNames -like $sapServicePrincipalName } -Properties ServicePrincipalNames -ErrorAction Stop
}
catch {
    Write-Host -NoNewLine "{'step': 'CheckServicePrincipalName', 'status': 'Error', 'message': 'ServicePrincipalName error occurred: $_.'},"
    return
}

if ($servicePrincipal) {
    Write-Host -NoNewLine "{'step': 'CheckServicePrincipalName', 'status': 'Success', 'message': 'Service Principal Name $sapServicePrincipalName exists on $servicePrincipal'},"
}
else {
    Write-Host -NoNewLine "{'step': 'CheckServicePrincipalName', 'status': 'Error', 'message': 'Service Principal Name $sapServicePrincipalName does not exist in Active Directory.'},"
}

#CheckServicePrincipalSupportedEncryptionTypes
$servicePrincipal = $servicePrincipal
    if (-not $servicePrincipal) {
        Write-Host -NoNewLine "{'step': 'CheckServicePrincipalSupportedEncryptionTypes', 'status': 'Warning', 'message': 'Skipping ServicePrincipalSupportedEncryptionTypes check because no service principal was provided.'},"
        return
    }
   # All the decimal values that contain AES encryption types
    # https://go.microsoft.com/fwlink/?linkid=2240296
    $aesEncryptionTypes = @(8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31)

    try {
        $supportedEncryptionTypes = Get-ADUser $servicePrincipal -Properties msDS-SupportedEncryptionTypes -ErrorAction Stop
        $value = $supportedEncryptionTypes."msDS-SupportedEncryptionTypes"
    }
    catch {
        Write-Host -NoNewLine "{'step': 'CheckServicePrincipalSupportedEncryptionTypes', 'status': 'Error', 'message': 'ServicePrincipalSupportedEncryptionTypes error occurred: $_.'},"
        return
    }

    if ($aesEncryptionTypes.Contains($value)) {
        Write-Host -NoNewLine "{'step': 'CheckServicePrincipalSupportedEncryptionTypes', 'status': 'Success', 'message': 'AES is enabled (msDS-SupportedEncryptionTypes => $value) for $servicePrincipal.'},"
    }
    else {
        Write-Host -NoNewLine "{'step': 'CheckServicePrincipalSupportedEncryptionTypes', 'status': 'Error', 'message': 'AES is missing (msDS-SupportedEncryptionTypes) for $servicePrincipal.'},"
    }

#CheckAllowedToDelegateTo
$servicePrincipal = $opdgServicePrincipal
$servicePrincipalName = $sapServicePrincipalName

    # Checks if OPDG servicePrincipal is allowed to delegate to the SAP service principal name
    if (-not $servicePrincipal -or -not $servicePrincipalName) {
        Write-Host -NoNewLine "{'step': 'CheckAllowedToDelegateTo', 'status': 'Warning', 'message': 'Skipping AllowedToDelegate check because no service principal name was provided.'},"
        return
    }

    try {
        $allowedToDelegateTo = Get-ADUser $servicePrincipal -Properties msDS-AllowedToDelegateTo -ErrorAction Stop
        $value = $allowedToDelegateTo."msDS-AllowedToDelegateTo"
    }
    catch {
        Write-Host -NoNewLine "{'step': 'CheckAllowedToDelegateTo', 'status': 'Error', 'message': 'AllowedToDelegateTo error occurred: $_.'},"
        return
    }

    if ($null -ne $value -and $value.Contains($servicePrincipalName)) {
        Write-Host -NoNewLine "{'step': 'CheckAllowedToDelegateTo', 'status': 'Success', 'message': 'Delegation is enabled (msDS-AllowedToDelegateTo => $value) for $servicePrincipal.'},"
    }
    else {
        Write-Host -NoNewLine "{'step': 'CheckAllowedToDelegateTo', 'status': 'Error', 'message': 'Delegation is disabled (msDS-AllowedToDelegateTo) for $servicePrincipal. Check the $servicePrincipal account in Active Directory and add $servicePrincipalName on the Delegation tab.'},"
    }

#CheckTrustedToAuthForDelegation
$servicePrincipal = $opdgServicePrincipal
    # Checks if OPDG service principal in Active Directory has "Use any authentication protocol" enabled on Delegation tab
    if (-not $servicePrincipal) {
        Write-Host -NoNewLine "{'step': 'CheckTrustedToAuthForDelegation', 'status': 'Warning', 'message': 'Skipping TrustedToAuthForDelegation check because no service principal name was provided.'},"
        return
    }

    try {
        $trustedToAuthForDelegation = Get-ADUser -Identity $servicePrincipal -Properties TrustedToAuthForDelegation -ErrorAction Stop | Select-Object TrustedToAuthForDelegation
        $value = $trustedToAuthForDelegation."trustedToAuthForDelegation"
    }
    catch {
        Write-Host -NoNewLine "{'step': 'CheckTrustedToAuthForDelegation', 'status': 'Error', 'message': 'TrustedToAuthForDelegation error occurred: $_.'},"
        return
    }

    if ($value) {
        Write-Host -NoNewLine "{'step': 'CheckTrustedToAuthForDelegation', 'status': 'Success', 'message': 'TrustedToAuthForDelegation enabled ($value) for $servicePrincipal.'},"
    }
    else {
        Write-Host -NoNewLine "{'step': 'CheckTrustedToAuthForDelegation', 'status': 'Error', 'message': 'TrustedToAuthForDelegation disabled for $servicePrincipal. Check the $servicePrincipal account in AD and enable 'Use any authentication protocol' on Delegation the tab.'},"
    }

#CheckActAsPartOfOperatingSystem
$servicePrincipal = $opdgServicePrincipal
    # Checks OPDG operating system that service servicePrincipal has "Act as part of the operating system" privilege
    if (-not $servicePrincipal) {
        Write-Host -NoNewLine "{'step': 'CheckActAsPartOfOperatingSystem', 'status': 'Warning', 'message': 'Skipping ActAsPartOfOperatingSystem check because no service principal name was provided.'},"
        return
    }

    try {
        $accountSid = Get-ADUser -Identity $servicePrincipal -Properties ObjectGUID | Select-Object SID | Out-Null
    }
    catch {
        Write-Host -NoNewLine "{'step': 'CheckActAsPartOfOperatingSystem', 'status': 'Error', 'message': 'ActAsPartOfOperatingSystem error occurred: $_.'},"
        return
    }

    # This is not a PowerShell cmdlet, so we need to use the old command line tool
    secedit /export /cfg $env:TEMP\secpol.cfg | Out-Null

    # Checks if the secedit command was successful or not
    if ($LASTEXITCODE -ne 0) {
        Write-Host -NoNewLine "{'step': 'CheckActAsPartOfOperatingSystem', 'status': 'Error', 'message': 'ActAsPartOfOperatingSystem failed. Try running with an elevated PowerShell prompt.'},"
        return
    }

    $value = (Get-Content $env:TEMP\secpol.cfg | Select-String "SeTcbPrivilege").ToString()
    Remove-Item $env:TEMP\secpol.cfg
    $servicePrincipal = $servicePrincipal.replace("\", "\\")
    if ($value.Contains($accountSid.SID.Value)) {
        Write-Host -NoNewLine "{'step': 'CheckActAsPartOfOperatingSystem', 'status': 'Success', 'message': 'ActAsPartOfOperatingSystem enabled ($value) for $servicePrincipal.'},"
    }
    else {
        Write-Host -NoNewLine "{'step': 'CheckActAsPartOfOperatingSystem', 'status': 'Error', 'message': 'ActAsPartOfOperatingSystem disabled ($value) for $servicePrincipal. Check the 'Act as part of the operating system' property of the $servicePrincipal in the Local Security Policy console.'},"
    }

#CheckImpersonateAClientAfterAuthentication
$servicePrincipal = $opdgServicePrincipal
    # Checks OPDG operating system that service principal has "Impersonate a client after authentication" privilege
    if (-not $servicePrincipal) {
        Write-Host -NoNewLine "{'step': 'CheckImpersonateAClientAfterAuthentication', 'status': 'Warning', 'message': 'Skipping ImpersonateAClientAfterAuthentication check because no service principal name was provided.'},"
        return
    }

    try {
        $accountSid = Get-ADUser -Identity $servicePrincipal -Properties ObjectGUID -ErrorAction Stop | Select-Object SID
    }
    catch {
        Write-Host -NoNewLine "{'step': 'CheckImpersonateAClientAfterAuthentication', 'status': 'Error', 'message': 'ImpersonateAClientAfterAuthentication error occurred: $_.'},"
        return
    }

    # This is not a PowerShell cmdlet, so we need to use the old command line tool
    secedit /export /cfg $env:TEMP\secpol.cfg | Out-Null

    # Checks if the secedit command was successful or not
    if ($LASTEXITCODE -ne 0) {
        Write-Host -NoNewLine "{'step': 'CheckImpersonateAClientAfterAuthentication', 'status': 'Error', 'message': 'ImpersonateAClientAfterAuthentication failed. Try running with an elevated PowerShell prompt.'},"
        return
    }

    $value = (Get-Content $env:TEMP\secpol.cfg | Select-String "SeImpersonatePrivilege").ToString()
    Remove-Item $env:TEMP\secpol.cfg

    if ($value.Contains($accountSid.SID.Value)) {
        Write-Host -NoNewLine "{'step': 'CheckImpersonateAClientAfterAuthentication', 'status': 'Success', 'message': 'ImpersonateAClientAfterAuthentication enabled ($value).'},"
    }
    else {
        Write-Host -NoNewLine "{'step': 'CheckImpersonateAClientAfterAuthentication', 'status': 'Error', 'message': 'ImpersonateAClientAfterAuthentication disabled ($value). Check the 'Impersonate a client after authentication' property in the Local Security Policy console.'},"
    }

#CheckGatewayServiceRunsAs
$servicePrincipal = $opdgServicePrincipal
    # Check what servicePrincipal the OPDG service is running as
    if (-not $servicePrincipal) {
        Write-Host -NoNewLine "{'step': 'CheckGatewayServiceRunsAs', 'status': 'Warning', 'message': 'Skipping GatewayServiceRunsAs check because no service principal name was provided.'}]"
        return
    }

    $service = Get-WmiObject -Class Win32_Service -Filter "Name='PBIEgwService'"

    if ($null -ne $service -and $service.StartName -ilike "*$servicePrincipal*") {
        $servicePrincipal = $servicePrincipal.replace("\", "\\")
        Write-Host -NoNewLine "{'step': 'CheckGatewayServiceRunsAs', 'status': 'Success', 'message': 'GatewayServiceRunsAs is running as $servicePrincipal.'}]"
    }
    else {
        $servicePrincipal = $servicePrincipal.replace("\", "\\")
        Write-Host -NoNewLine "{'step': 'CheckGatewayServiceRunsAs', 'status': 'Error', 'message': 'GatewayServiceRunsAs is not running as $servicePrincipal. Check the 'Log On As' property of the 'On-premises data gateway service' in the Windows Services console. It should be running as $servicePrincipal.'}]"
    }

