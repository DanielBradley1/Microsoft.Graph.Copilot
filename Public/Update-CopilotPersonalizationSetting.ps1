function Update-CopilotPersonalizationSetting {
    <#
    .SYNOPSIS
    Updates the Microsoft 365 Copilot personalization settings.
    
    .DESCRIPTION
    Updates the Microsoft 365 Copilot personalization settings for the tenant. 
    
    .EXAMPLE
    Update-PersonalizationSetting -isEnabled $true -DisabledForGroups "ce86fe93-d42b-4e25-9f8b-55c108267f99"
    
    Updates the personalization settings tenant wide and disables it for the specified group.
    
    .LINK
    https://learn.microsoft.com/en-us/graph/api/enhancedpersonalizationsetting-update?view=graph-rest-beta
    
    .OUTPUTS
    PSCustomObject containing the updated personalization settings.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [bool]$isEnabled,
        
        [Parameter(Mandatory = $false)]
        [ValidateCount(0, 1)]
        [string[]]$DisabledForGroup
    )

    Write-Verbose "Attempting to update Copilot personalization settings..."
    Write-Verbose "Setting isEnabled to: $isEnabled"
    if ($DisabledForGroup) {
        Write-Verbose "Disabling for group: $DisabledForGroup"
    }

    try {
        $body = @{
            isEnabled = $isEnabled
        }
        
        if ($DisabledForGroup) {
            $body.Add('disabledForGroups', $DisabledForGroup)
        }

        $personalizationSetting = Invoke-MgGraphRequest -Method PATCH -Uri "/beta/copilot/settings/people/enhancedpersonalization" -Body $body -OutputType PSObject

        return $personalizationSetting

    }
    catch {
        # Check if the error is a 403 Forbidden response
        if ($_.Exception.Message -match "403" -or 
            $_.Exception.Message -match "Forbidden") {
            
            Write-Error "Access Forbidden: The Graph API permission PeopleSettings.ReadWrite.All is required. Make sure you have the appropriate administrator role and permissions. Error: $($_.Exception.Message)"
        }
        else {
            Write-Error "Failed to update Copilot personalization settings: $($_.Exception.Message)"
        }
        return $null
    }
}