function Get-CopilotInteractionHistory {
    <#
    .SYNOPSIS
    Get a users ineraction history with Microsoft 365 Copilot.
    
    .DESCRIPTION
    Get all Microsoft 365 Copilot interaction data, including user prompts to Copilot 
    and Copilot responses.
    
    .PARAMETER UserId
    Specifies the ID of the user whose interaction history you want to retrieve.
    
    .PARAMETER Source
    Get the interaction history from a specific source. 
    Valid values include: Word, Excel, Loop, M365App, Bing, Forms, OneNote, Outlook, PowerPoint, 
    TeamsAiNotes, Channel, Chat, Meeting, WebChat, or Whiteboard.
    
    .PARAMETER StartDate
    Specifies the start date for the interaction history.
    Must be in ISO 8601 format: "YYYY-MM-DDThh:mm:ssZ" (e.g., "2024-09-09T16:48:35Z")

    .PARAMETER EndDate
    Specifies the end date for the interaction history.
    Must be in ISO 8601 format: "YYYY-MM-DDThh:mm:ssZ" (e.g., "2024-09-09T16:48:35Z")
    
    .EXAMPLE
    Get-aiInteractionHistory -UserId "user@contoso.com" -source Word -StartDate "2025-01-01" -EndDate "2025-01-31"
    
    Returns the Copilot interaction history for the specified user, filtered by the specified source and date range.
    
    .LINK
    https://learn.microsoft.com/en-us/graph/api/aiinteractionhistory-getallenterpriseinteractions?view=graph-rest-beta&tabs=http
    
    .OUTPUTS
    PSCustomObject
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserId,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Word", "Excel", "Loop", "M365App", "Bing", "Forms", "OneNote", 
                    "Outlook", "PowerPoint", "TeamsAiNotes", "Channel", "Chat", 
                    "Meeting", "WebChat", "Whiteboard")]
        [string]$Source,
        
        [Parameter(Mandatory = $false)]
        [ValidatePattern("^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")]
        [string]$StartDate,
        
        [Parameter(Mandatory = $false)]
        [ValidatePattern("^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")]
        [string]$EndDate
    )

    # Validate date parameters must be used together
    if (($PSBoundParameters.ContainsKey('StartDate') -and -not $PSBoundParameters.ContainsKey('EndDate')) -or
        ($PSBoundParameters.ContainsKey('EndDate') -and -not $PSBoundParameters.ContainsKey('StartDate'))) {
        throw "StartDate and EndDate parameters must be used together."
    }

    # Validate StartDate is before EndDate
    if ($PSBoundParameters.ContainsKey('StartDate') -and $PSBoundParameters.ContainsKey('EndDate')) {
        $startDateObj = [DateTime]::Parse($StartDate)
        $endDateObj = [DateTime]::Parse($EndDate)
        
        if ($startDateObj -ge $endDateObj) {
            throw "StartDate must be earlier than EndDate."
        }
    }

    # Define the mapping of source names to their corresponding values
    $sources = @{
        Word = "IPM.SkypeTeams.Message.Copilot.Word"
        Excel = "IPM.SkypeTeams.Message.Copilot.Excel"
        Loop = "IPM.SkypeTeams.Message.Copilot.Loop"
        M365App = "IPM.SkypeTeams.Message.Copilot.M365App"
        Bing = "IPM.SkypeTeams.Message.Copilot.BizChat"
        Forms = "IPM.SkypeTeams.Message.Copilot.Forms"
        OneNote = "IPM.SkypeTeams.Message.Copilot.OneNote"
        Outlook = "IPM.SkypeTeams.Message.Copilot.Outlook"
        PowerPoint = "IPM.SkypeTeams.Message.Copilot.PowerPoint"
        TeamsAiNotes = "IPM.SkypeTeams.Message.TeamsCopilot.AiNotes.Teams"
        Channel = "IPM.SkypeTeams.Message.Copilot.Teams"
        Chat = "IPM.SkypeTeams.Message.Copilot.Teams"
        Meeting = "IPM.SkypeTeams.Message.Copilot.Teams"
        WebChat = "IPM.SkypeTeams.Message.Copilot.WebChat"
        Whiteboard = "IPM.SkypeTeams.Message.Copilot.Whiteboard"
    }

    # Only try to convert the source if it was provided
    if ($PSBoundParameters.ContainsKey('Source')) {
        try {
            $sourceValue = $sources[$Source]
            Write-Verbose "Source '$Source' mapped to value: $sourceValue"
        } catch {
            Write-Error "Invalid source specified. Valid sources are: $($sources.Keys -join ', ')"
            return
        }
    }
    
    # Check if none of the filter parameters are used
    if (-not $PSBoundParameters.ContainsKey('Source') -and 
        -not $PSBoundParameters.ContainsKey('StartDate') -and 
        -not $PSBoundParameters.ContainsKey('EndDate')) {
        
    } else {
        # create the filter string
        $filterParts = @()
        
        if ($PSBoundParameters.ContainsKey('Source')) {
            $filterParts += "appClass eq '$sourceValue'"
        }
        
        if ($PSBoundParameters.ContainsKey('StartDate')) {
            $filterParts += "createdDateTime gt $StartDate"
        }
        
        if ($PSBoundParameters.ContainsKey('EndDate')) {
            $filterParts += "createdDateTime lt $EndDate"
        }
        
        # Join all filter parts with 'and' operator
        $filterString = "?`$filter = " + ($filterParts -join " and ")
        
        Write-Verbose "Filter string: $filterString"
    }

    try {

        Write-Verbose "Retrieving Microsoft Copilot interaction history for user $UserId..."
        $uri = "/beta/copilot/users/$UserId/interactionHistory/getAllEnterpriseInteractions$filterString"
        $response = Invoke-MgGraphRequest -Method GET -uri $uri -OutputType PSObject | Select -ExpandProperty Value

        return $response 

    }
    catch {
        if ($_.Exception.Message -match "403" -or 
            $_.Exception.Message -match "Forbidden") {
            Write-Error "Access Forbidden: The Graph API permission Organization.Read.All is required. Make sure you have the appropriate administrator role and permissions. Error: $($_.Exception.Message)"
            }
        else {
            Write-Error $_
            }
        return $null
    }
}