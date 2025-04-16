# Update-CopilotLicense

## Synopsis
Updates the Microsoft 365 Copilot limited mode settings.

## Syntax 

```powershell
Update-CopilotLimitedMode
 -isEnabledForGroup <Bool>
 -GroupId <String>
```

## Description

If this setting is enabled, Copilot in Teams meetings doesn't respond to sentiment-related prompts and questions asked by the user. If the setting is disabled, Copilot in Teams meetings responds to sentiment-related prompts and questions asked by the user.

## Examples

### Example 1: Enable the Copilot limited mode settings
```powershell
Update-CopilotLimitedMode -isEnabledForGroup $true
```

### Example 1: Enable the Copilot limited mode settings and assign a target group
```powershell
Update-CopilotLimitedMode -isEnabledForGroup $true -GroupId "$groupid"
```

### Example 2: Disable the Copilot limited mode settings
```powershell
Update-CopilotLimitedMode -isEnabledForGroup $false
```

## Graph API reference link
https://learn.microsoft.com/en-us/graph/api/copilotadminlimitedmode-update?view=graph-rest-beta&tabs=http

## Parameters

### -isEnabledForGroup

Specifies if you want to enable or disable this setting.

```yaml
Type: System.Boolean
Required: False
Default value: None
```

### -GroupId
Specified the group Id which this setting applies to. Only a single group can be specified.

```yaml
Type: System.String
Required: False
Default value: None
```