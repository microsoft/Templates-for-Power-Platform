# Deployment Packages

The packages in this folder are DeploymentPackages built by the PAC-CLI.

## Requirements & Constraints

- PAC CLI installed and authenticated with your dev environment.
- MSBuild
- Power Platform Environment(s) with Premium License(s)

## Add A New Deployment Solution

```
pac package init --outputDirectory mpa_Kudos
```

## Add Solutions To Your Deployment Solution

```
cd .\mpa_Kudos
pac package add-solution --path ..\..\Solutions\mpa_EmployeeExperienceBase\bin\Release\mpa_EmployeeExperienceBase_managed.zip
pac package add-solution --path ..\..\Solutions\mpa_Kudos\bin\Release\mpa_Kudos_managed.zip
```

## Build Deployment Solution

```
dotnet publish
```
