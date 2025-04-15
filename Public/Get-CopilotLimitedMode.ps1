function Get-CopilotLimitedMode {
    <#
    .SYNOPSIS
    Gets the Microsoft 365 Copilot limited mode settings.
    
    .DESCRIPTION
    Represents a setting that controls whether Microsoft 365 Copilot in Teams meetings 
    users can receive responses to sentiment-related prompts. If this setting is enabled, 
    Copilot in Teams meetings doesn't respond to sentiment-related prompts and questions 
    asked by the user. If the setting is disabled, Copilot in Teams meetings responds to 
    sentiment-related prompts and questions asked by the user. Copilot in Teams meetings 
    currently honors this setting. By default, the setting is disabled.
    
    .EXAMPLE
    Get-CopilotLimitedMode
    
    Returns the current Copilot limited mode settings.
    
    .LINK
    https://learn.microsoft.com/en-us/graph/api/copilotadminlimitedmode-get?view=graph-rest-beta&tabs=http
    
    .OUTPUTS
    PSCustomObject - An object representing the Copilot limited mode settings.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Write-Verbose "Attempting to get Copilot limited mode settings."

    try {
       
        # Get the Copilot limited mode settings using the Microsoft Graph API
        $limitedMode = Invoke-MgGraphRequest -Uri "beta/copilot/admin/settings/limitedMode" -OutputType PSObject

        return $limitedMode

    }
    catch {
        if ($_.Exception.Message -match "403" -or 
            $_.Exception.Message -match "Forbidden") {
            
            Write-Error "Access Forbidden: The Graph API permission CopilotSettings-LimitedMode.Read is required. Make sure you have the appropriate administrator role and permissions. Error: $($_.Exception.Message)"
            }
            else {
            Write-Error "Failed to retrieve Copilot limited mode settings $($_.Exception.Message)"
        }
        return $null
    }
}

