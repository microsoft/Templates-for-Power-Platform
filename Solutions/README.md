# Solutions

The solutions in this folder are built for the Power Platform.

## Requirements & Constraints

- PAC CLI installed and authenticated with your dev environment.
- MSBuild
- Power Platform Environment(s) with Premium License(s)

## Add A New Solution

Initalize the solution via the PAC CLI tool.

```
pac solution init --publisher-name PowerAccelerator --publisher-prefix mpa --outputDirectory .\YOURNAMEHERE
```

Then navigate into your new solution folder and run the following command to sync the changes in your Dev environment down to the local repo.

```
pac solution sync --processCanvasApps
```

Next we need to make a single change inside of the new .cdsproj file that was created when you performed the sync and add the following PropertyGroup.
```
<PropertyGroup>
    <SolutionPackageType>Both</SolutionPackageType>
</PropertyGroup>
```

And now open the `solutions.proj` file within this folder and add a new item to the `Project > ItemGroup` node.

```
<SolutionsToBuild Include="mpa_Kudos/mpa_Kudos.cdsproj" />
```

## Build A Single Solution

Navigate into your solutions folder.

```
cd .\mpa_Kudos
msbuild /p:configuration=Release .\mpa_Kudos.cdsproj
```

## Build All Solutions Within This folder.

```
msbuild /p:configuration=Release /t:clean .\solutions.proj
```

## Clean Up

Clean your Debug folders.
```
msbuild /t:clean .\solutions.proj
```

Clean up your Release folders.

```
msbuild /p:configuration=Release /t:clean .\solutions.proj
```

