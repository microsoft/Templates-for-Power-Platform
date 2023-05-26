# Sequence of events

# 0) Checks

$solutionName = $args[0]

$deployerPackagePath = ".\Accelerators\${solutionName}.DeployerPackage\"
$appSourcePackagePath = ".\Accelerators\${solutionName}.AppSourcePackage\"

# 0) Checks
Write-Host "This script assumes you already have your local Solutions synced and the Deployment & AppSource folders initialized and updated with your own terms of service & logos."

# Make sure msbuild is not already running.
if(Get-Process -Name msbuild -ErrorAction SilentlyContinue) {
    throw "The msbuild process is currently running. Cannot run script."
}

# Make sure 

# 1) Build the managed and unmanaged solutions.

Set-Location -Path ..\
msbuild /p:configuration=Release .\Accelerators\solutions.proj

# 2) Run `dotnet publish` in the .DeployerPackage

Set-Location -Path $deployerPackagePath

dotnet publish

# 3) Take the output from the .DeployerPackage and place them into the .AppSourcePackage

$deployerPackagePath = ".\Accelerators\${solutionName}.DeployerPackage\"

# 4) Package up the App Source Package.

