function Update-CopilotLimitedMode {
    <#
    .SYNOPSIS
    Updates the Microsoft 365 Copilot ability to respond to sentiment-related prompts
    
    .DESCRIPTION
    If this setting is enabled, Copilot in Teams meetings doesn't respond to sentiment-related 
    prompts and questions asked by the user. If the setting is disabled, Copilot in Teams 
    meetings responds to sentiment-related prompts and questions asked by the user.
    
    .EXAMPLE
    Update-CopilotLimitedMode -isEnabledForGroup $true -GroupId "ce86fe93-d42b-4e25-9f8b-55c108267f99"
    
    Updates the limited mode settings tenant wide and targets the specified group.
    
    .LINK
    https://learn.microsoft.com/en-us/graph/api/copilotadminlimitedmode-update?view=graph-rest-beta&tabs=http
    
    .OUTPUTS
    PSCustomObject containing the updated personalization settings.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [bool]$isEnabledForGroup,
        
        [Parameter(Mandatory = $false)]
        [ValidateCount(0, 1)]
        [string[]]$GroupId
    )

    Write-Verbose "Attempting to update Copilot limited mode settings..."
    Write-Verbose "Setting isEnabledForGroup to: $isEnabledForGroup"
    if ($GroupId) {
        Write-Verbose "Assigning group: $GroupId"
    }

    try {
        $body = @{
            isEnabledForGroup = $isEnabledForGroup
        }
        
        if ($GroupId) {
            $body.Add('GroupId', $GroupId)
        }

        $limitedModeSetting = Invoke-MgGraphRequest -Method GET -Uri "/beta/copilot/admin/settings/limitedMode" -Body $body -OutputType PSObject

        return $limitedModeSetting

    }
    catch {
        # Check if the error is a 403 Forbidden response
        if ($_.Exception.Message -match "403" -or 
            $_.Exception.Message -match "Forbidden") {
            
            Write-Error "Access Forbidden: The Graph API permission CopilotSettings-LimitedMode.ReadWrite is required. Make sure you have the appropriate administrator role and permissions. Error: $($_.Exception.Message)"
        }
        else {
            Write-Error "Failed to update Copilot personalization settings: $($_.Exception.Message)"
        }
        return $null
    }
}