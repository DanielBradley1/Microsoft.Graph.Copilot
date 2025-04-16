# Get-CopilotLicense

## Synopsis
List all Microsoft 365 Copilot SKUs.

## Syntax 

```powershell
Get-CopilotLicense
```

## Description

List all Microsoft 365 licenses in your tenant relating to Copilot. Outputs as an array of objects. No parameters are needed.

## Examples

### Example 1: List all Microsoft 365 Copilot licenses
```PowerShell
Get-CopilotLicense

accountName      : #tenant name
accountId        : #tenantid
appliesTo        : User
capabilityStatus : Enabled
consumedUnits    : 1
id               : #license id
skuId            : 639dec6b-bb19-468b-871c-c5c441c4b0cb
skuPartNumber    : Microsoft_365_Copilot
subscriptionIds  : {e9b7f687-6e89-4aef-9769-e41fd5f708de}
prepaidUnits     : @{enabled=25; suspended=0; warning=0; lockedOut=0}
servicePlans     : {@{servicePlanId=ff7b261f-d98b-415b-827c-42a3fdf015af; servicePlanName=WORKPLACE_ANALYTICS_INSIGHTS_BACKEND; provisioningStatus=Success;
                   appliesTo=Company}, @{servicePlanId=b622badb-1b45-48d5-920f-4b27a2c0996c; servicePlanName=WORKPLACE_ANALYTICS_INSIGHTS_USER; provisioningStatus=Success;
                   appliesTo=User}, @{servicePlanId=fe6c28b3-d468-44ea-bbd0-a10a5167435c; servicePlanName=COPILOT_STUDIO_IN_COPILOT_FOR_M365; provisioningStatus=Success;
                   appliesTo=User}, @{servicePlanId=0aedf20c-091d-420b-aadf-30c042609612; servicePlanName=M365_COPILOT_SHAREPOINT; provisioningStatus=Success;
                   appliesTo=User}…}
```

## Graph API reference link
https://learn.microsoft.com/en-us/graph/api/directory-list-subscriptions?view=graph-rest-beta&tabs=http
