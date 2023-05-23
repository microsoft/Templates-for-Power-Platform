## High Level Steps

1) Generate managed version of the solution & it's depenency solutions.

2) Generate a Deployment Package.

3) Generate an App Source Package.

4) Submit App Source Package to Microsoft Partner Marketplace Offers.

## Key Things To Note:

`.DeploymentPackage` -> [Dynamics 365 package](https://learn.microsoft.com/en-us/power-platform/alm/package-deployer-tool?tabs=cli)
`.AppSourcePackage` -> [AppSource Package](https://learn.microsoft.com/en-us/power-platform/developer/appsource/create-package-app#create-content_typesxml)

## Process:

#### Get and build solutions
```
pac solution init --publisher-name PowerAccelerator --publisher-prefix mpa --outputDirectory .\mpa_KudosAccelerator

pac solution sync --processCanvasApps

```
Open the .csproj file that was created when you performed the sync and uncomment or add the following.
```
<PropertyGroup>
    <SolutionPackageType>Both</SolutionPackageType>
</PropertyGroup>
```

Test out the build. Should have both unmanaged and managed .zip files.
```
msbuild *.csproj
```

#### Generate Release Solutions

```
msbuild /p:configuration=Release .\solutions.proj
```

### Deployment Package


#### Create Deployment Solution

```
pac package init --outputDirectory mpa_KudosAccelerator.DeploymentPackage
```

#### Add solution

```
pac package add-solution --path ..\mpa_EmployeeExperienceBaseAccelerator\bin\Release\mpa_EmployeeExperienceBaseAccelerator.zip
pac package add-solution --path ..\mpa_KudosAccelerator\bin\Release\mpa_KudosAccelerator.zip
```

#### Build

```
dotnet publish
```

## Deployment Package to AppSource Package

Navigate into the `*.DeploymentPackage/bin/Debug/net472/pdpublish` folder and copy the `PkgAssets` and `*.dll` files into the `*.AppSourcePackage` folder.

## App Source Package


#### To Deploy a Package Deployer Package.

```
pac package deploy --package .\bin\Debug\mpa_SAPProcurementAccelerator.DeploymentPackage.1.0.0.pdpkg.zip --logConsole
```

#### Helpful links:

https://github.com/WaelHamze/dyn365-ce-vsts-tasks/issues/90
