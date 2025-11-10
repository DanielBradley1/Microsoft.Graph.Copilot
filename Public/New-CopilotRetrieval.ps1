function New-CopilotRetrieval {
    <#
    .SYNOPSIS
    Retrieve grounding data from Microsoft 365 Copilot data sources.
    
    .DESCRIPTION
    The Microsoft 365 Copilot Retrieval API allows for the retrieval of relevant text extracts 
    from SharePoint, OneDrive, and Copilot connectors content that the calling user has access to, 
    while respecting the defined access controls within the tenant. Use the Retrieval API to ground 
    your generative AI solutions with Microsoft 365 data while optimizing for context recall.
    
    .PARAMETER QueryString
    Natural language query string used to retrieve relevant text extracts. This parameter has a 
    limit of 1,500 characters. Your queryString should be a single sentence, and you should avoid 
    spelling errors in context-rich keywords.
    
    .PARAMETER DataSource
    Indicates whether extracts should be retrieved from SharePoint, OneDrive, or Copilot connectors.
    Valid values: 'sharePoint', 'oneDriveBusiness', 'externalItem'.
    Can specify multiple data sources to query them simultaneously using batch requests.
    
    .PARAMETER FilterExpression
    Keyword Query Language (KQL) expression with queryable SharePoint, OneDrive, or Copilot connectors 
    properties and attributes to scope the retrieval before the query runs. Supported SharePoint and 
    OneDrive properties: Author, FileExtension, Filename, FileType, InformationProtectionLabelId, 
    LastModifiedTime, ModifiedBy, Path, SiteID, and Title.
    
    .PARAMETER ResourceMetadata
    A list of metadata fields to be returned for each item in the response. 
    Common values include: 'title', 'author'.
    
    .PARAMETER MaximumNumberOfResults
    The number of results that are returned in the response. Must be between 1 and 25. 
    Default: 25.
    
    .PARAMETER ConnectionIds
    Array of Copilot connector connection IDs to restrict retrieval to specific connections.
    Only used when DataSource is 'externalItem'.
    
    .EXAMPLE
    New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource "sharePoint"
    
    Retrieves relevant text extracts about VPN setup from SharePoint.
    
    .EXAMPLE
    New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource "sharePoint" -ResourceMetadata @("title", "author") -MaximumNumberOfResults 10
    
    Retrieves up to 10 text extracts with title and author metadata.
    
    .EXAMPLE
    New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource "sharePoint" -FilterExpression 'path:"https://contoso.sharepoint.com/sites/HR1/"' -ResourceMetadata @("title", "author")
    
    Retrieves text extracts from a specific SharePoint site with metadata.
    
    .EXAMPLE
    New-CopilotRetrieval -QueryString "quarterly budget analysis" -DataSource "sharePoint" -FilterExpression 'Author:"Megan Bowen"' -MaximumNumberOfResults 5
    
    Retrieves budget analysis documents authored by Megan Bowen.
    
    .EXAMPLE
    New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource "externalItem" -ConnectionIds @("ContosoITServiceNowKB", "ContosoHRServiceNowKB") -ResourceMetadata @("title", "author")
    
    Retrieves text extracts from specific Copilot connector connections.
    
    .EXAMPLE
    New-CopilotRetrieval -QueryString "How to setup corporate VPN?" -DataSource @("sharePoint", "externalItem") -ResourceMetadata @("title", "author")
    
    Retrieves text extracts from both SharePoint and Copilot connectors simultaneously using batch requests.
    
    .LINK
    https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/api/ai-services/retrieval/copilotroot-retrieval
    
    .OUTPUTS
    PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 1500)]
        [string]$QueryString,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("sharePoint", "oneDriveBusiness", "externalItem")]
        [string[]]$DataSource,
        
        [Parameter(Mandatory = $false)]
        [string]$FilterExpression,
        
        [Parameter(Mandatory = $false)]
        [string[]]$ResourceMetadata,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 25)]
        [int]$MaximumNumberOfResults = 25,
        
        [Parameter(Mandatory = $false)]
        [string[]]$ConnectionIds
    )

    # Validate ConnectionIds is only used with externalItem
    if ($PSBoundParameters.ContainsKey('ConnectionIds')) {
        if ($DataSource.Count -gt 1) {
            throw "ConnectionIds parameter cannot be used when multiple data sources are specified."
        }
        if ($DataSource[0] -ne 'externalItem') {
            throw "ConnectionIds parameter can only be used when DataSource is set to 'externalItem'."
        }
    }

    # Validate batch request limit (max 20 requests per batch)
    if ($DataSource.Count -gt 20) {
        throw "Cannot query more than 20 data sources at once. You specified $($DataSource.Count) data sources."
    }

    Write-Verbose "Performing Copilot retrieval for query: $QueryString from data source(s): $($DataSource -join ', ')"

    try {
        # Check if batching is needed (multiple data sources)
        if ($DataSource.Count -gt 1) {
            # Build batch request
            Write-Verbose "Creating batch request for $($DataSource.Count) data sources"
            
            $batchRequests = @()
            $requestId = 1
            
            foreach ($source in $DataSource) {
                # Build individual request body
                $requestBody = @{
                    queryString = $QueryString
                    dataSource = $source
                    maximumNumberOfResults = $MaximumNumberOfResults.ToString()
                }
                
                # Add filterExpression if specified
                if ($PSBoundParameters.ContainsKey('FilterExpression')) {
                    $requestBody['filterExpression'] = $FilterExpression
                }
                
                # Add resourceMetadata if specified
                if ($PSBoundParameters.ContainsKey('ResourceMetadata')) {
                    $requestBody['resourceMetadata'] = $ResourceMetadata
                }
                
                # Add dataSourceConfiguration for external items with connectionIds
                if ($PSBoundParameters.ContainsKey('ConnectionIds') -and $source -eq 'externalItem') {
                    $connections = @()
                    foreach ($connectionId in $ConnectionIds) {
                        $connections += @{ connectionId = $connectionId }
                    }
                    
                    $requestBody['dataSourceConfiguration'] = @{
                        externalItem = @{
                            connections = $connections
                        }
                    }
                }
                
                # Add to batch requests array
                $batchRequests += @{
                    id = $requestId.ToString()
                    method = "POST"
                    url = "/copilot/retrieval"
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
            Write-Verbose "Sending batch request to: $uri"
            
            $batchResponse = Invoke-MgGraphRequest -Method POST -Uri $uri -Body ($batchPayload | ConvertTo-Json -Depth 10) -OutputType PSObject
            
            # Process batch responses
            $allResults = @()
            
            foreach ($response in $batchResponse.responses) {
                $dataSourceName = $DataSource[$([int]$response.id - 1)]
                
                if ($response.status -eq 200) {
                    if ($response.body.retrievalHits) {
                        Write-Verbose "Data source '$dataSourceName': Retrieved $($response.body.retrievalHits.Count) results"
                        
                        # Add data source information to each hit
                        foreach ($hit in $response.body.retrievalHits) {
                            $hit | Add-Member -MemberType NoteProperty -Name "dataSource" -Value $dataSourceName -Force
                            $allResults += $hit
                        }
                    }
                    else {
                        Write-Verbose "Data source '$dataSourceName': No results found"
                    }
                }
                else {
                    Write-Warning "Data source '$dataSourceName': Request failed with status $($response.status)"
                    if ($response.body.error) {
                        Write-Warning "Error: $($response.body.error.message)"
                    }
                }
            }
            
            if ($allResults.Count -gt 0) {
                Write-Verbose "Total results from all data sources: $($allResults.Count)"
                return $allResults
            }
            else {
                Write-Verbose "No results found from any data source"
                return $null
            }
        }
        else {
            # Single data source - use standard request
            $source = $DataSource[0]
            
            # Build the request body
            $requestBody = @{
                queryString = $QueryString
                dataSource = $source
                maximumNumberOfResults = $MaximumNumberOfResults.ToString()
            }

            # Add filterExpression if specified
            if ($PSBoundParameters.ContainsKey('FilterExpression')) {
                $requestBody['filterExpression'] = $FilterExpression
                Write-Verbose "Filter expression: $FilterExpression"
            }

            # Add resourceMetadata if specified
            if ($PSBoundParameters.ContainsKey('ResourceMetadata')) {
                $requestBody['resourceMetadata'] = $ResourceMetadata
                Write-Verbose "Resource metadata: $($ResourceMetadata -join ', ')"
            }

            # Add dataSourceConfiguration for external items with connectionIds
            if ($PSBoundParameters.ContainsKey('ConnectionIds')) {
                $connections = @()
                foreach ($connectionId in $ConnectionIds) {
                    $connections += @{ connectionId = $connectionId }
                }
                
                $requestBody['dataSourceConfiguration'] = @{
                    externalItem = @{
                        connections = $connections
                    }
                }
                Write-Verbose "Connection IDs: $($ConnectionIds -join ', ')"
            }

            $uri = "beta/copilot/retrieval"
            
            # Convert to JSON for debugging
            $jsonBody = $requestBody | ConvertTo-Json -Depth 10
            Write-Verbose "Request body JSON: $jsonBody"
            
            Write-Verbose "Sending retrieval request to: $uri"
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $jsonBody -OutputType PSObject
            
            # Return the response with retrieval hits
            if ($response.retrievalHits) {
                Write-Verbose "Retrieved $($response.retrievalHits.Count) results"
                
                # Add data source information to each hit
                foreach ($hit in $response.retrievalHits) {
                    $hit | Add-Member -MemberType NoteProperty -Name "dataSource" -Value $source -Force
                }
                
                return $response.retrievalHits
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
            
            if ($DataSource -contains "externalItem") {
                Write-Error "Access Forbidden: The Graph API permission ExternalItem.Read.All is required for Copilot connectors. For SharePoint/OneDrive, Files.Read.All and Sites.Read.All are required. Make sure you have the appropriate permissions. Error: $($_.Exception.Message)"
            }
            else {
                Write-Error "Access Forbidden: The Graph API permissions Files.Read.All and Sites.Read.All are required for SharePoint/OneDrive retrieval. Make sure you have the appropriate permissions. Error: $($_.Exception.Message)"
            }
        }
        elseif ($_.Exception.Message -match "400" -or 
                $_.Exception.Message -match "Bad Request") {
            
            Write-Error "Bad Request: The query string or parameters may be invalid. Ensure your queryString is a single sentence with correct spelling. Error: $($_.Exception.Message)"
        }
        else {
            Write-Error "Failed to perform Copilot retrieval: $($_.Exception.Message)"
        }
        return $null
    }
}
