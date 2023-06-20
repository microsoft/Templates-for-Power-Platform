# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
# Rename an entity across solutions.

# $sourceName = "mpa_SAPPackAdministration"
# $destinationName = "mpa_SAPAcceleratorAdministrator"
# $sourceName = $args[0]
# $destinationName = $args[1]

# Write-Host "Renaming $sourceName to $destinationPath"

if(Get-Process -Name msbuild -ErrorAction SilentlyContinue) {
    throw "The msbuild process is currently running. Cannot run script."
}

# throw "Remove me before running. Set-Location and replaceDict need updated."

Set-Location -Path .\Solutions\mpa_CoffeeConnect\

$replacementDict = @{
    # Tables:
    cr771_MatchHistory = "mpa_CoffeeConnectMatch";
    cr771_MatchHistories = "mpa_CoffeeConnectMatches";
    cr771_Suggestion = "mpa_CoffeeConnectSuggestion";
    cr771_Location = "mpa_CoffeeConnectLocation";
    cr771_PowerCoffeeRing = "mpa_CoffeeConnectRing";
    # cr771_PowerCoffeeSignUp = "mpa_CoffeeConnectSignUp";

    # Choices
    cr771_meetingfrequencypreference = "mpa_coffeeconnect_meetingfrequencypreference"
    cr771_ringtype = "mpa_coffeeconnect_ringtype";
    cr771_suggestionstatus = "mpa_coffeeconnect_suggestionstatus";
    cr771_suggestiontype = "mpa_coffeeconnect_suggestiontype";

    # # *****Solution Specific Entities*****

    # Canvas App
    cr771_powercoffee_0a1d0 = "mpa_CoffeeConnectApp";

    # Model App + Sitemaps
    cr771_PowerCoffeeAdmin = "mpa_CoffeeConnectAdminApp";

    # Connection References
    cr771_sharedcommaondataserviceforapps_6a295 = "mpa_CoffeeConnectDataverse";
    new_sharedteams_8c88b = "mpa_CoffeeConnectTeams";
    new_sharedoffice365_f2661 = "mpa_CoffeeConnectOfficeOutlook";

    # Solution
    PowerCoffeeTest = "mpa_CoffeeConnect";

    # Coffee Connect - Admin = "Coffee Connect - Admin";
    # Coffee Connect - User = "Coffee Connect - User";
    # Power Coffee Matching Flow = "Power Coffee Matching Flow";
    # Schedule Outlook Meeting = "Schedule Outlook Meeting";
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

# Repack the canvas apps.
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
