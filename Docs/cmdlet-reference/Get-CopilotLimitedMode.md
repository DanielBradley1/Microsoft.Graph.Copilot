# Get-CopilotLimitedMode

## Synopsis
Gets the Microsoft 365 Copilot limited mode settings.

## Syntax 

```powershell
Get-CopilotLimitedMode
```

## Description

Gets the tenant level Microsoft 365 Copilot limit mode settings. Outputs as an object. No parameters are needed.

## Examples

### Example 1: Get the Copilot limited mode settings
```powershell
Get-CopilotLimitedMode

@odata.context                                                                        isEnabledForGroup groupId
--------------                                                                        ----------------- -------
https://graph.microsoft.com/beta/$metadata#copilot/admin/settings/limitedMode/$entity              True ce86fe93-d42b-4e25-9f8b-55c108267f99
```

## Graph API reference link
https://learn.microsoft.com/en-us/graph/api/copilotadminlimitedmode-get?view=graph-rest-beta&tabs=http