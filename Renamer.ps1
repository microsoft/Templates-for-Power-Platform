# Rename an entity across solutions.

# $sourceName = "mpa_SAPPackAdministration"
# $destinationName = "mpa_SAPAcceleratorAdministrator"
# $sourceName = $args[0]
# $destinationName = $args[1]

# Write-Host "Renaming $sourceName to $destinationPath"

if(Get-Process -Name msbuild -ErrorAction SilentlyContinue) {
    throw "The msbuild process is currently running. Cannot run script."
}

Set-Location -Path .\Accelerators\mpa_SAPProcurementAccelerator\

$replacementDict = @{
    # mpa_SAPAcceleratorAdministrator = "mpa_SAPAdministrator";
    mpa_SAPAcceleratorDataverse = "mpa_SAPDataverse";
    mpa_SAPAcceleratorERP = "mpa_SAPERP";
    mpa_SAPAcceleratorError = "mpa_SAPError";
    # mpa_SAPAcceleratorErrorId = "mpa_SAPErrorId";
    mpa_SAPAcceleratorListofValue = "mpa_SAPListofValue";
    # mpa_SAPAcceleratorListofValueId = "mpa_SAPListofValueId";
    mpa_SAPAcceleratorLocalization = "mpa_SAPLocalization";
    # mpa_SAPAcceleratorLocalizationId = "mpa_SAPLocalizationId";
    mpa_SAPAcceleratorMenuItem = "mpa_SAPMenuItem";
    # mpa_SAPAcceleratorMenuItemId = "mpa_SAPMenuItemId";
    mpa_SAPAcceleratorOffice365Users = "mpa_SAPOffice365Users";
    mpa_SAPAcceleratorSearchHistory = "mpa_SAPSearchHistory";
    # mpa_SAPAcceleratorSearchHistoryId = "mpa_SAPSearchHistoryId";
    mpa_SAPBaseAccelerator = "mpa_SAPBase"; 
    mpa_SAPProcurementAccelerator = "mpa_SAPProcurement";
    # mpa_sapvendormanagement_42919 = "mpa_sapvendormanagement_42919";
}

# Unpack all .msapp files.
$msappFiles = Get-ChildItem -Path $rootDir -Recurse -Filter "*.msapp"
# Iterate through the .msapp files unpack them.
foreach ($file in $msappFiles) {
    $fileName = $file.FullName
    $destinationFolder = $file.Name.Replace(".msapp", "") + "Unpacked"
    $destinationPath = $file.DirectoryName + "\${destinationFolder}\"
    # Write-Host "Found .msapp file at: $($file.FullName). Unpacking into ${destinationPath}"
    pac canvas unpack --msapp $fileName --sources $destinationPath
}

# Rename files & Folders.
foreach($key in $replacementDict.Keys) {
    $value = $replacementDict[$key]
    Write-Host "Replacing File Names $key with $value."

    $lowerKey = $key.ToLower()
    $lowerValue = $value.ToLower()

    # Finally rename files and folders.
    (Get-ChildItem .\ -Recurse -Exclude *.log,*.zip) |
    Sort-Object @{Expression = {$_.FullName.Split('\').Count}; Descending = $true} |
    ForEach-Object {
        if ($_.Name -clike "*${key}*") {
            # Regular case
            $newName = $_.Name -creplace $key, $value
            $_ | Rename-Item -NewName $newName -Verbose
        } elseif ($_.Name -clike "*${lowerKey}*") {
            # Lowercase check
            $newName = $_.Name -creplace $lowerKey, $lowerValue
            $_ | Rename-Item -NewName $newName -Verbose
        }
    }
}

foreach($key in $replacementDict.Keys) {
    $value = $replacementDict[$key]
    Write-Host "Replacing File Content $key with $value."
    
    Get-ChildItem . -Recurse -File -Exclude *.log,*.zip |
    Foreach-Object {
        $reader = New-Object System.IO.StreamReader($_.FullName)
        $content = $reader.ReadToEnd()
        $reader.Close()
        $newContent = $content -creplace $key, $value
        $writer = New-Object System.IO.StreamWriter($_.FullName, $false)
        $writer.Write($newContent)
        $writer.Close()
    }

    if ($key -cne $key.ToLower()) {
        # Replace lowercase items.
        $lowerKey = $key.ToLower()
        $lowerValue = $value.ToLower()
        Write-Host "Lower Case Replace"
        Get-ChildItem . -Recurse -File -Exclude *.log,*.zip |
        Foreach-Object {
            $reader = New-Object System.IO.StreamReader($_.FullName)
            $content = $reader.ReadToEnd()
            $reader.Close()
            $newContent = $content -creplace $lowerKey, $lowerValue
            $writer = New-Object System.IO.StreamWriter($_.FullName, $false)
            $writer.Write($newContent)
            $writer.Close()
        }
    }
}

Repack the canvas apps.
$msappFolders = Get-ChildItem -Path $rootDir -Recurse -Filter "*Unpacked"
foreach ($folder in $msappFolders) {
    $fileName = $folder.FullName.Replace("Unpacked", ".msapp")
    $destinationPath = $folder.FullName
    pac canvas pack --msapp $fileName --sources $destinationPath
    rm -r $destinationPath
}

Set-Location -Path ..\..\

Write-Host "I think we did it :)!"
Write-Host "Canvas apps have been packed back up. Please try building the solutions before assuming this script worked."
