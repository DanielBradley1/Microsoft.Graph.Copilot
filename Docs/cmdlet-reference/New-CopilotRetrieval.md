# New-CopilotRetrieval

## Synopsis
Retrieve grounding data from Microsoft 365 Copilot data sources.

## Syntax 

```powershell
New-CopilotRetrieval
 -QueryString <String>
 -DataSource <String[]> ValidateSet("sharePoint", "oneDriveBusiness", "externalItem")
 [-FilterExpression <String>]
 [-ResourceMetadata <String[]>]
 [-MaximumNumberOfResults <Int32>]
 [-ConnectionIds <String[]>]
```

## Description

The Microsoft 365 Copilot Retrieval API allows for the retrieval of relevant text extracts from SharePoint, OneDrive, and Copilot connectors content that the calling user has access to, while respecting the defined access controls within the tenant. Use the Retrieval API to ground your generative AI solutions with Microsoft 365 data while optimizing for context recall.

## Examples

### Example 1: Retrieve text extracts from SharePoint
```powershell
New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource "sharePoint"
```

Retrieves relevant text extracts about VPN setup from SharePoint.

### Example 2: Retrieve text extracts with metadata and limit results
```powershell
New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource "sharePoint" -ResourceMetadata @("title", "author") -MaximumNumberOfResults 10
```

Retrieves up to 10 text extracts with title and author metadata.

### Example 3: Retrieve text extracts from a specific SharePoint site
```powershell
New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource "sharePoint" -FilterExpression 'path:"https://contoso.sharepoint.com/sites/HR1/"' -ResourceMetadata @("title", "author")
```

Retrieves text extracts from a specific SharePoint site with metadata.

### Example 4: Retrieve documents by author
```powershell
New-CopilotRetrieval -QueryString "quarterly budget analysis" -DataSource "sharePoint" -FilterExpression 'Author:"Megan Bowen"' -MaximumNumberOfResults 5
```

Retrieves budget analysis documents authored by Megan Bowen.

### Example 5: Retrieve from Copilot connectors
```powershell
New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource "externalItem" -ConnectionIds @("ContosoITServiceNowKB", "ContosoHRServiceNowKB") -ResourceMetadata @("title", "author")
```

Retrieves text extracts from specific Copilot connector connections.

### Example 6: Retrieve from multiple data sources using batch requests
```powershell
New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource @("sharePoint", "oneDriveBusiness") -ResourceMetadata @("title", "author")
```

Retrieves text extracts from both SharePoint and OneDrive simultaneously using batch requests.

## Graph API reference link
https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/api/ai-services/retrieval/copilotroot-retrieval

## Parameters

### -QueryString

Natural language query string used to retrieve relevant text extracts. This parameter has a limit of 1,500 characters. Your queryString should be a single sentence, and you should avoid spelling errors in context-rich keywords.

```yaml
Type: System.String
ValidateLength: 1-1500 characters
Required: True
Default value: None
```

### -DataSource

Indicates whether extracts should be retrieved from SharePoint, OneDrive, or Copilot connectors. You can specify multiple data sources to query them simultaneously using batch requests (up to 20 data sources).

```yaml
Type: System.String[]
ValidateSet: ("sharePoint", "oneDriveBusiness", "externalItem")
Required: True
Default value: None
```

### -FilterExpression

Keyword Query Language (KQL) expression with queryable SharePoint, OneDrive, or Copilot connectors properties and attributes to scope the retrieval before the query runs. 

Supported SharePoint and OneDrive properties: `Author`, `FileExtension`, `Filename`, `FileType`, `InformationProtectionLabelId`, `LastModifiedTime`, `ModifiedBy`, `Path`, `SiteID`, and `Title`.

```yaml
Type: System.String
Required: False
Default value: None
```

### -ResourceMetadata

A list of metadata fields to be returned for each item in the response. Common values include: `title`, `author`.

```yaml
Type: System.String[]
Required: False
Default value: None
```

### -MaximumNumberOfResults

The number of results that are returned in the response. Must be between 1 and 25.

```yaml
Type: System.Int32
ValidateRange: 1-25
Required: False
Default value: 25
```

### -ConnectionIds

Array of Copilot connector connection IDs to restrict retrieval to specific connections. Only used when DataSource is 'externalItem'. Cannot be used when multiple data sources are specified.

```yaml
Type: System.String[]
Required: False
Default value: None
```

## Required Permissions

### For SharePoint and OneDrive
- `Files.Read.All`
- `Sites.Read.All`

### For Copilot Connectors (externalItem)
- `ExternalItem.Read.All`

**Note:** If you receive a 403 (Forbidden) error, verify that you have the appropriate permissions granted for your application or delegated user context.

## Notes

- The cmdlet supports batch requests when querying multiple data sources (up to 20 data sources per request).
- Query strings should be a single sentence for optimal results.
- Avoid spelling errors in context-rich keywords.
- The retrieval respects tenant access controls and only returns content the calling user has access to.
- When using multiple data sources, each result will include a `dataSource` property indicating its origin.
