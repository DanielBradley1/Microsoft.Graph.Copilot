# Get-CopilotInteractionHistory

## Synopsis
Get the most recent activity data for enabled users of Microsoft 365 Copilot apps.

## Syntax 

```powershell
Get-CopilotUsageDetail
 -Period <String> ValidateSet("D7", "D30", "D90", "D180", "ALL")
 -Format <String> ValidateSet("object", "csv")
 -Outpath <String>
```

## Description

Get the most recent activity data for enabled users of Microsoft 365 Copilot app, output as a CSV or PowerShell object and within the defined period.

## Examples

### Example 1: Get all activity data for all time and output to the console session as an object
```powershell
Get-CopilotUsageDetail -Period All

reportRefreshDate                     : 2025-04-13
userPrincipalName                     : # username
displayName                           : # displayname
lastActivityDate                      : 2025-02-20
copilotChatLastActivityDate           : 2024-12-22
microsoftTeamsCopilotLastActivityDate : 2025-02-20
wordCopilotLastActivityDate           : 2024-12-01
excelCopilotLastActivityDate          :
powerPointCopilotLastActivityDate     : 2024-11-30
outlookCopilotLastActivityDate        :
oneNoteCopilotLastActivityDate        :
loopCopilotLastActivityDate           :
copilotActivityUserDetailsByPeriod    : {@{reportPeriod=7}, @{reportPeriod=30}, @{reportPeriod=90}, @{reportPeriod=180}}
```

### Example 1: Get all activity data for all time and output to a CSV file
```powershell
Get-CopilotUsageDetail -Period All -Format csv -Outpath C:\reports\CopilotUsageReport.csv

Copilot usage details saved to: C:\reports\CopilotUsageReport.csv
```

## Parameters

### -Period

Specifies the priod of data to be included within the report. You must choose an option from the set.

```yaml
Type: System.String
ValidateSet: ("D7", "D30", "D90", "D180", "ALL")
Required: True
Default value: ALL
```
### -Format

Specifies the format of the output. `object` will output the report to the PowerShell session, or `csv` will output the report to a file.

```yaml
Type: System.String
ValidateSet: ("object", "csv")
Required: False
Default value: Object
```

### -Outpath

Specifies the output file path for the CSV report. This parameter must be specified when `-Format` is set to `csv`

```yaml
Type: System.String
Required: False
Default value: None
```