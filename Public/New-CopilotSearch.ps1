function New-CopilotSearch {
    <#
    .SYNOPSIS
    Perform hybrid search across OneDrive for work or school content using natural language queries.
    
    .DESCRIPTION
    The Microsoft 365 Copilot Search API performs hybrid (semantic and lexical) search across 
    OneDrive for work or school content by using natural language queries with contextual understanding.
    Discover relevant documents and files that you have access to, while respecting the defined access 
    controls within the organization. The Search API supports up to 20 batch requests per call.
    
    .PARAMETER Query
    Natural language query to search for relevant files. This parameter has a limit of 1,500 characters.
    Your query should use natural language with contextual understanding for best results.
    
    .PARAMETER PageSize
    Number of results to return per page. Must be between 1 and 100. Default: 25.
    
    .PARAMETER FilterExpression
    Keyword Query Language (KQL) expression to filter OneDrive content. Use path expressions to scope 
    the search to specific locations. Supported properties include: Author, FileExtension, Filename, 
    FileType, LastModifiedTime, ModifiedBy, Path, and Title.
    
    .PARAMETER ResourceMetadata
    A list of metadata field names to be returned for each search result in the response. 
    Common values include: 'title', 'author'.
    
    .PARAMETER BatchQueries
    Array of query strings to execute as a batch request. Allows up to 20 queries in a single batch.
    When using batch queries, other parameters (PageSize, FilterExpression, ResourceMetadata) will 
    apply to all queries in the batch.
    
    .EXAMPLE
    New-CopilotSearch -Query "How to setup corporate VPN?"
    
    Performs a basic hybrid search for VPN setup information across OneDrive content.
    
    .EXAMPLE
    New-CopilotSearch -Query "quarterly budget analysis" -PageSize 10
    
    Searches for budget analysis documents and returns up to 10 results.
    
    .EXAMPLE
    New-CopilotSearch -Query "quarterly budget analysis" -FilterExpression 'path:"https://contoso-my.sharepoint.com/personal/megan_contoso_com/Documents/Finance/"' -ResourceMetadata @("title", "author")
    
    Searches within a specific OneDrive path and includes title and author metadata in results.
    
    .EXAMPLE
    New-CopilotSearch -Query "project timeline milestones" -FilterExpression 'path:"https://contoso-my.sharepoint.com/personal/john_contoso_com/Documents/Projects/"' -ResourceMetadata @("title", "author") -PageSize 5
    
    Searches for project documents within a specific path with metadata, limiting to 5 results.
    
    .EXAMPLE
    New-CopilotSearch -Query "quarterly budget analysis" -FilterExpression 'path:"https://contoso-my.sharepoint.com/personal/megan_contoso_com/Documents/Finance/" OR path:"https://contoso-my.sharepoint.com/personal/megan_contoso_com/Documents/Budget"' -ResourceMetadata @("title", "author")
    
    Searches across multiple OneDrive paths using OR logic in the filter expression.
    
    .EXAMPLE
    New-CopilotSearch -BatchQueries @("quarterly budget reports", "project planning documents") -PageSize 10
    
    Executes multiple search queries simultaneously using batch requests.
    
    .LINK
    https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/api/ai-services/search/copilotroot-search
    
    .OUTPUTS
    PSCustomObject
    #>
    [CmdletBinding(DefaultParameterSetName = 'SingleQuery')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'SingleQuery')]
        [ValidateLength(1, 1500)]
        [string]$Query,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 100)]
        [int]$PageSize = 25,
        
        [Parameter(Mandatory = $false)]
        [string]$FilterExpression,
        
        [Parameter(Mandatory = $false)]
        [string[]]$ResourceMetadata,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'BatchQuery')]
        [ValidateCount(1, 20)]
        [string[]]$BatchQueries
    )

    # Validate batch request limit (max 20 requests per batch)
    if ($PSCmdlet.ParameterSetName -eq 'BatchQuery' -and $BatchQueries.Count -gt 20) {
        throw "Cannot execute more than 20 queries at once. You specified $($BatchQueries.Count) queries."
    }

    try {
        # Check if batching is needed (multiple queries)
        if ($PSCmdlet.ParameterSetName -eq 'BatchQuery') {
            Write-Verbose "Creating batch search request for $($BatchQueries.Count) queries"
            
            $batchRequests = @()
            $requestId = 1
            
            foreach ($batchQuery in $BatchQueries) {
                # Build individual request body
                $requestBody = @{
                    query = $batchQuery
                    pageSize = $PageSize
                }
                
                # Add dataSources configuration if filter or metadata specified
                if ($PSBoundParameters.ContainsKey('FilterExpression') -or $PSBoundParameters.ContainsKey('ResourceMetadata')) {
                    $oneDriveConfig = @{}
                    
                    if ($PSBoundParameters.ContainsKey('FilterExpression')) {
                        $oneDriveConfig['filterExpression'] = $FilterExpression
                    }
                    
                    if ($PSBoundParameters.ContainsKey('ResourceMetadata')) {
                        $oneDriveConfig['resourceMetadataNames'] = $ResourceMetadata
                    }
                    
                    $requestBody['dataSources'] = @{
                        oneDrive = $oneDriveConfig
                    }
                }
                
                # Add to batch requests array
                $batchRequests += @{
                    id = $requestId.ToString()
                    method = "POST"
                    url = "/copilot/search"
                    headers = @{
                        "Content-Type" = "application/json"
                    }
                    body = $requestBody
                }
                
                $requestId++
            }
            
            # Create batch request payload
            $batchPayload = @{
                requests = $batchRequests
            }
            
            $uri = "beta/`$batch"
            Write-Verbose "Sending batch search request to: $uri"
            
            $batchResponse = Invoke-MgGraphRequest -Method POST -Uri $uri -Body ($batchPayload | ConvertTo-Json -Depth 10) -OutputType PSObject
            
            # Process batch responses
            $allResults = @()
            
            foreach ($response in $batchResponse.responses) {
                $queryText = $BatchQueries[$([int]$response.id - 1)]
                
                if ($response.status -eq 200) {
                    if ($response.body.searchHits) {
                        Write-Verbose "Query '$queryText': Found $($response.body.totalCount) total results, returned $($response.body.searchHits.Count) in this page"
                        
                        # Add query information to each search hit and add to results
                        foreach ($hit in $response.body.searchHits) {
                            $hit | Add-Member -MemberType NoteProperty -Name "query" -Value $queryText -Force
                            $hit | Add-Member -MemberType NoteProperty -Name "totalCount" -Value $response.body.totalCount -Force
                            if ($response.body.'@odata.nextLink') {
                                $hit | Add-Member -MemberType NoteProperty -Name "nextLink" -Value $response.body.'@odata.nextLink' -Force
                            }
                            $allResults += $hit
                        }
                    }
                    else {
                        Write-Verbose "Query '$queryText': No results found"
                    }
                }
                else {
                    Write-Warning "Query '$queryText': Request failed with status $($response.status)"
                    if ($response.body.error) {
                        Write-Warning "Error: $($response.body.error.message)"
                    }
                }
            }
            
            if ($allResults.Count -gt 0) {
                Write-Verbose "Batch search completed with $($allResults.Count) total search hits"
                return $allResults
            }
            else {
                Write-Verbose "No results found from any query"
                return $null
            }
        }
        else {
            # Single query - use standard request
            Write-Verbose "Performing Copilot search for query: $Query"
            
            # Build the request body
            $requestBody = @{
                query = $Query
                pageSize = $PageSize
            }

            # Add dataSources configuration if filter or metadata specified
            if ($PSBoundParameters.ContainsKey('FilterExpression') -or $PSBoundParameters.ContainsKey('ResourceMetadata')) {
                $oneDriveConfig = @{}
                
                if ($PSBoundParameters.ContainsKey('FilterExpression')) {
                    $oneDriveConfig['filterExpression'] = $FilterExpression
                    Write-Verbose "Filter expression: $FilterExpression"
                }
                
                if ($PSBoundParameters.ContainsKey('ResourceMetadata')) {
                    $oneDriveConfig['resourceMetadataNames'] = $ResourceMetadata
                    Write-Verbose "Resource metadata: $($ResourceMetadata -join ', ')"
                }
                
                $requestBody['dataSources'] = @{
                    oneDrive = $oneDriveConfig
                }
            }

            $uri = "beta/copilot/search"
            
            # Convert to JSON for debugging
            $jsonBody = $requestBody | ConvertTo-Json -Depth 10
            Write-Verbose "Request body JSON: $jsonBody"
            
            Write-Verbose "Sending search request to: $uri"
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $jsonBody -OutputType PSObject
            
            # Return the response with search hits
            if ($response.searchHits) {
                Write-Verbose "Found $($response.totalCount) total results, returned $($response.searchHits.Count) in this page"
                
                # Add query metadata to each search hit
                foreach ($hit in $response.searchHits) {
                    $hit | Add-Member -MemberType NoteProperty -Name "query" -Value $Query -Force
                    $hit | Add-Member -MemberType NoteProperty -Name "totalCount" -Value $response.totalCount -Force
                    if ($response.'@odata.nextLink') {
                        $hit | Add-Member -MemberType NoteProperty -Name "nextLink" -Value $response.'@odata.nextLink' -Force
                    }
                }
                
                # Display next link information if available
                if ($response.'@odata.nextLink') {
                    Write-Verbose "More results available. Use the NextLink property to retrieve additional pages."
                }
                
                return $response.searchHits
            }
            else {
                Write-Verbose "No results found for the query"
                return $null
            }
        }
    }
    catch {
        if ($_.Exception.Message -match "403" -or 
            $_.Exception.Message -match "Forbidden") {
            
            Write-Error "Access Forbidden: The Graph API permissions Files.Read.All and Sites.Read.All are required for OneDrive search. Make sure you have the appropriate permissions. Error: $($_.Exception.Message)"
        }
        elseif ($_.Exception.Message -match "400" -or 
                $_.Exception.Message -match "Bad Request") {
            
            Write-Error "Bad Request: The query string or parameters may be invalid. Ensure your query is properly formatted with correct spelling. Error: $($_.Exception.Message)"
        }
        else {
            Write-Error "Failed to perform Copilot search: $($_.Exception.Message)"
        }
        return $null
    }
}
