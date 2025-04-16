# Get-CopilotInteractionHistory

## Synopsis
 Get a users ineraction history with Microsoft 365 Copilot.

## Syntax 

```powershell
Get-CopilotInteractionHistory
 -UserId <String>
 -Source <String> ValidateSet("Word", "Excel", "Loop", "M365App", "Bing", "Forms", "OneNote", 
                    "Outlook", "PowerPoint", "TeamsAiNotes", "Channel", "Chat", 
                    "Meeting", "WebChat", "Whiteboard")
 -StartDate <String> ValidatePattern("^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
 -EndDate <String> ValidatePattern("^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
```

## Description

Get all Microsoft 365 Copilot interaction data, including user prompts to Copilot and Copilot responses.

## Examples

### Example 1: Get all Copilot interactions by a single user
```powershell
Get-CopilotInteractionHistory -UserId "dbradley@ourcloudnetwork.co.uk"

id               : 1732953515805
sessionId        : 19:Z2dtNdqH2q3CoOQlnAFKSg_7xNx31x9k6gwFobbqAqM1@thread.v2
requestId        : TaJnV4jTlTMub1uDThGg+R.2.4.1.1.1.1
appClass         : IPM.SkypeTeams.Message.Copilot.PowerPoint
interactionType  : aiResponse
conversationType : appchat
etag             : 1732953515805
createdDateTime  : 30/11/2024 07:58:35
locale           : en-us
contexts         : {@{contextReference=https://$tenant$-my.sharepoint.com/personal/$userId$/_layouts
                   /15/Doc.aspx?sourcedoc=%7B3F1EBD1F-A33D-462A-9EEE-F6C3D97EB750%7D&file=Presentation.pptx&action=edit
                   &mobileredirect=true; displayName=Presentation.pptx; contextType=pptx}}
from             : @{@odata.type=#microsoft.graph.chatMessageFromIdentitySet; device=; user=; application=}
body             : @{contentType=html; content=<attachment id="21661e6f877949ba8372d686149c3c9d"></attachment>}
attachments      : {}
links            : {}
mentions         : {}
```

### Example 2: Get all Copilot interactions by a single user filtered by source
```powershell
Get-CopilotInteractionHistory -UserId "dbradley@ourcloudnetwork.co.uk" -Source Word
```

### Example 3: Get all Copilot interactions by a single user filtered by source and date range
```powershell
Get-CopilotInteractionHistory -UserId "dbradley@ourcloudnetwork.co.4uk" -Source Word `
-StartDate "2025-05-01T00:00:00Z" -EndDate "2025-04-10T00:00:00Z"
```
## Graph API reference link
https://learn.microsoft.com/en-us/graph/api/aiinteractionhistory-getallenterpriseinteractions?view=graph-rest-beta&tabs=http

## Parameters

### -UserId

Specifies the user from which you want to get Copilot interactions.

```yaml
Type: System.String
Required: True
Default value: None
```
### -Source

Specifies the source appClass you which to filter the interactions by.

```yaml
Type: System.String
ValidateSet: ("Word", "Excel", "Loop", "M365App", "Bing", "Forms", "OneNote", 
                    "Outlook", "PowerPoint", "TeamsAiNotes", "Channel", "Chat", 
                    "Meeting", "WebChat", "Whiteboard")
Required: False
Default value: All
```

### -StartDate

Specifies the start date for which you want to filter the interactions by.

```yaml
Type: System.String
Required: False
ValidatePattern: ("^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
Default value: All
```

### -EndDate

Specifies the end date for which you want to filter the interactions by.

```yaml
Type: System.String
Required: False
ValidatePattern: ("^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
Default value: All
```