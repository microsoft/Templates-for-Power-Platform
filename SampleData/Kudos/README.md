# Kudos Sample Data Installation Instructions
## Overview
There are two data files
1. LocalizationData.zip - Install this to get all the english strings that can be localized into other languages. This data will be uploaded to the Employee Experience Localization table that supports localization of strings for multiple Power Platform templates, including Kudos.
2. BadgeData.zip - Install this to get sample badge data 

## Sample Data Installation Instructions
1. Install the Microsoft Power Platform Command Line Interface (CLI). Follow the instructions here: [Microsoft CLI Introduction and Install Instructions](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction)
2. Once installed, type the following into the command line interface and hit ENTER.
    ```
    pac tool cmt
    ```
3. This will bring up the following window. Select "Import data" and hit "Continue".
![alt text](\Media\CMT1.png "Configuration Migration Tool")
4. On the next screen, Select how you want to sign in.
    4.1 Most Deployment Types will be "Office 365".
    4.2 Select to Sign in as current user if you don't use different credentials to access Power Apps
![alt text](\Media\CMT2.png "Configuration Migration Tool")
5. Select the environment that has the solutions installed
6. Select the sampled data zip file and Import the data
7. Exit and repeat from Step #3 if you have additional data files to install

## Additional Related Resources
- [Move configuration data across environments and organizations with the Configuration Migration tool](https://learn.microsoft.com/en-us/power-platform/admin/manage-configuration-data)
