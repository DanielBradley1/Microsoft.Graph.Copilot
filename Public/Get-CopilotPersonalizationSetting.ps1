function Get-CopilotPersonalizationSetting {
    <#
    .SYNOPSIS
    Gets the Microsoft 365 Copilot personalization settings.
    
    .DESCRIPTION
    Represents a setting that controls whether Microsoft 365 Copilot can use features that
    enhance its personalization capabilities. If enabled multiple features contributing to 
    deeper personalization are enabled.
    
    .EXAMPLE
    Get-PersonalizationSetting
    
    Returns the tennt level personalization settings for Microsoft 365 Copilot.
    
    .LINK
    https://learn.microsoft.com/en-us/graph/api/resources/enhancedpersonalizationsetting?view=graph-rest-beta
    
    .OUTPUTS
    PSCustomObject - An object representing the personalization settings for Microsoft 365 Copilot.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Write-Verbose "Attempting to get Copilot personalization settings..."

    try {

        $personalizationSetting = Invoke-MgGraphRequest -Uri "/beta/copilot/settings/people/enhancedpersonalization" -OutputType PSObject

        return $personalizationSetting

    }
    catch {
        # Check if the error is a 403 Forbidden response
        if ($_.Exception.Message -match "403" -or 
            $_.Exception.Message -match "Forbidden") {
            
            Write-Error "Access Forbidden: The Graph API permission PeopleSettings.Read.All is required. Make sure you have the appropriate administrator role and permissions. Error: $($_.Exception.Message)"
        }
        else {
            Write-Error "Failed to retrieve Copilot personalization settings: $($_.Exception.Message)"
        }
        return $null
    }
}