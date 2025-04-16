# Update-CopilotPersonalizationSetting

## Synopsis
Updates the Microsoft 365 Copilot personalization setting.

## Syntax 

```powershell
Update-CopilotPersonalizationSetting
 -isEnabled <Bool>
 -DisabledForGroup <String>
```

## Description

If this setting is enabled, multiple features contributing to deeper personalization are enabled. 
## Examples

### Example 1: Enable the Copilot personalization setting
```powershell
Update-CopilotPersonalizationSetting -isEnabled $true
```

### Example 2: Enable the Copilot personalization setting and disable for a target group
```powershell
Update-CopilotPersonalizationSetting -isEnabled $true -DisabledForGroup "$groupid"
```

### Example 3: Disable the Copilot personalization setting
```powershell
Update-CopilotPersonalizationSetting -isEnabled $false
```

## Graph API reference link
https://learn.microsoft.com/en-us/graph/api/enhancedpersonalizationsetting-update?view=graph-rest-beta

## Parameters

### -isEnabled

Specifies if you want to enable or disable this setting.

```yaml
Type: System.Boolean
Required: False
Default value: None
```

### -DisabledForGroup
Specified the group Id which this setting applies to. Only a single group can be specified.

```yaml
Type: System.String
Required: False
Default value: None
```