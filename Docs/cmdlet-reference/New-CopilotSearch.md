# New-CopilotSearch

## Synopsis
Perform hybrid search across OneDrive for work or school content using natural language queries.

## Syntax 

### SingleQuery (Default)
```powershell
New-CopilotSearch
 -Query <String>
 [-PageSize <Int32>]
 [-FilterExpression <String>]
 [-ResourceMetadata <String[]>]
```

### BatchQuery
```powershell
New-CopilotSearch
 -BatchQueries <String[]>
 [-PageSize <Int32>]
 [-FilterExpression <String>]
 [-ResourceMetadata <String[]>]
```

## Description

The Microsoft 365 Copilot Search API performs hybrid (semantic and lexical) search across OneDrive for work or school content by using natural language queries with contextual understanding. Discover relevant documents and files that you have access to, while respecting the defined access controls within the organization. The Search API supports up to 20 batch requests per call.

## Examples

### Example 1: Perform a basic search
```powershell
New-CopilotSearch -Query "How to setup corporate VPN?"
```

Performs a basic hybrid search for VPN setup information across OneDrive content.

### Example 2: Search with limited results
```powershell
New-CopilotSearch -Query "quarterly budget analysis" -PageSize 10
```

Searches for budget analysis documents and returns up to 10 results per page.

### Example 3: Search within a specific path with metadata
```powershell
New-CopilotSearch -Query "quarterly budget analysis" -FilterExpression 'path:"https://contoso-my.sharepoint.com/personal/megan_contoso_com/Documents/Finance/"' -ResourceMetadata @("title", "author")
```

Searches within a specific OneDrive path and includes title and author metadata in results.

### Example 4: Search with multiple path filters
```powershell
New-CopilotSearch -Query "quarterly budget analysis" -FilterExpression 'path:"https://contoso-my.sharepoint.com/personal/megan_contoso_com/Documents/Finance/" OR path:"https://contoso-my.sharepoint.com/personal/megan_contoso_com/Documents/Budget"' -ResourceMetadata @("title", "author") -PageSize 5
```

Searches across multiple OneDrive paths using OR logic in the filter expression, limiting to 5 results.

### Example 5: Search for project documents
```powershell
New-CopilotSearch -Query "project timeline milestones" -FilterExpression 'path:"https://contoso-my.sharepoint.com/personal/john_contoso_com/Documents/Projects/"' -ResourceMetadata @("title", "author")
```

Searches for project documents within a specific path with metadata.

### Example 6: Batch search with multiple queries
```powershell
New-CopilotSearch -BatchQueries @("quarterly budget reports", "project planning documents", "annual financial review") -PageSize 10
```

Executes multiple search queries simultaneously using batch requests. Results from all queries are returned with a `query` property identifying the source query.

### Example 7: Batch search with filtering and metadata
```powershell
New-CopilotSearch -BatchQueries @("budget analysis", "financial reports") -FilterExpression 'path:"https://contoso-my.sharepoint.com/personal/megan_contoso_com/Documents/"' -ResourceMetadata @("title", "author") -PageSize 5
```

Executes multiple queries in batch mode with filtering and metadata applied to all queries.

## Graph API reference link
https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/api/ai-services/search/copilotroot-search

## Parameters

### -Query

Natural language query to search for relevant files. This parameter has a limit of 1,500 characters. Your query should use natural language with contextual understanding for best results.

```yaml
Type: System.String
Parameter Set: SingleQuery
ValidateLength: 1-1500 characters
Required: True
Default value: None
```

### -PageSize

Number of results to return per page. Must be between 1 and 100.

```yaml
Type: System.Int32
ValidateRange: 1-100
Required: False
Default value: 25
```

### -FilterExpression

Keyword Query Language (KQL) expression to filter OneDrive content. Use path expressions to scope the search to specific locations. 

Supported properties include: `Author`, `FileExtension`, `Filename`, `FileType`, `LastModifiedTime`, `ModifiedBy`, `Path`, and `Title`.

```yaml
Type: System.String
Required: False
Default value: None
```

### -ResourceMetadata

A list of metadata field names to be returned for each search result in the response. Common values include: `title`, `author`.

```yaml
Type: System.String[]
Required: False
Default value: None
```

### -BatchQueries

Array of query strings to execute as a batch request. Allows up to 20 queries in a single batch. When using batch queries, other parameters (PageSize, FilterExpression, ResourceMetadata) will apply to all queries in the batch.

```yaml
Type: System.String[]
Parameter Set: BatchQuery
ValidateCount: 1-20
Required: True
Default value: None
```

## Required Permissions

### For OneDrive for Work or School
- `Files.Read.All` or `Files.ReadWrite.All`
- `Sites.Read.All` or `Sites.ReadWrite.All`

**Note:** If you receive a 403 (Forbidden) error, verify that you have the appropriate permissions granted for your application or delegated user context.

## Output

The cmdlet returns an array of search hit objects. Each search hit includes:

- **webUrl** - The URL to access the document
- **preview** - A text preview/snippet from the document
- **resourceType** - The type of resource (typically "driveItem")
- **resourceMetadata** - Metadata fields (if requested via ResourceMetadata parameter)
- **query** - The query that returned this result (added by the cmdlet)
- **totalCount** - Total number of results for this query (added by the cmdlet)
- **nextLink** - URL for retrieving the next page of results if pagination is available (added by the cmdlet)

## Notes

- The cmdlet performs hybrid search combining semantic and lexical search capabilities.
- The search respects tenant access controls and only returns content the calling user has access to.
- Query strings should use natural language for optimal results.
- The cmdlet supports batch requests for executing up to 20 queries simultaneously.
- When using batch mode, all search hits from all queries are returned in a single array, with each hit tagged with the originating query.
- Use the `nextLink` property to retrieve additional pages of results when available.
- Results are returned as an expanded array of search hits rather than nested objects for easier processing.
