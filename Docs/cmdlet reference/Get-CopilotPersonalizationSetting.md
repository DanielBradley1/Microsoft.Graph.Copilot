# Get-CopilotPersonalizationSetting

## Synopsis
Gets the Microsoft 365 Copilot personalization settings.

## Syntax 

```powershell
Get-CopilotPersonalizationSetting
```

## Description

Gets the tenant level Microsoft 365 Copilot personalization settings. Outputs as an object. No parameters are needed.

## Examples

### Example 1: Get the Copilot personalization settings
```powershell
Get-CopilotPersonalizationSetting

@odata.context                                                                                     isEnabledInOrganization disabledForGroup
--------------                                                                                     ----------------------- ----------------
https://graph.microsoft.com/beta/$metadata#copilot/settings/people/enhancedPersonalization/$entity                    True ce86fe93-d42b-4e25-9f8b-55c108267f99
```
## Graph API reference link
https://learn.microsoft.com/en-us/graph/api/enhancedpersonalizationsetting-get?view=graph-rest-beta