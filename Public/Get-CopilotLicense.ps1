function Get-CopilotLicense {
    <#
    .SYNOPSIS
    Gets the available Copilot licenses for the tenant.
    
    .DESCRIPTION
    This function retrieves the available Copilot licenses for the tenant from Microsoft Graph API.
    It filters the licenses to include only those related to Copilot and returns them as a list of PSCustomObjects.
    
    .EXAMPLE
    Get-CopilotLicense
    
    Returns all Copilot licenses available in the tenant.

    .OUTPUTS
    PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$IncludeNextDate
    )

    Write-Verbose "Attempting to retrieve subscribed SKUs from Microsoft Graph API."

    try {

        # Get the list of subscribed SKUs from Microsoft Graph API
        $Skus = Invoke-MgGraphRequest -Uri "/beta/subscribedSkus" -OutputType PSObject -ErrorAction Stop | Select-Object -ExpandProperty Value
        
        Write-Verbose "Successfully retrieved $($Skus.Count) subscribed SKUs."
        
        # Filter the SKUs to include only those related to Copilot
        $CopilotSkus = $Skus | Where-Object { $_.SkuPartNumber -match "Copilot" }
        
        Write-Verbose "Found $($CopilotSkus.Count) Copilot related SKUs."

        # If IncludeNextDate switch is provided, enhance the output with next date information
        if ($IncludeNextDate) {
            Write-Verbose "Including next date information as requested."

            # Get subscription details for date information
            $subscriptionDetails = Invoke-MgGraphRequest -Uri "beta/directory/subscriptions?" -OutputType PSObject -ErrorAction Stop | Select-Object -ExpandProperty Value

            # Enhance the CopilotSkus with next date information
            $enhancedCopilotSkus = $CopilotSkus | ForEach-Object {
                $sku = $_
                
                $matchingSub = $subscriptionDetails | Where-Object { 
                    $_.SkuPartNumber -eq $sku.SkuPartNumber 
                } | Select-Object -First 1
                
                if ($matchingSub) {
                    # Add next billing date or renewal date if available
                    $sku | Add-Member -NotePropertyName 'nextLifecycleDateTime' -NotePropertyValue $matchingSub.nextLifecycleDateTime -Force
                    $sku | Add-Member -NotePropertyName 'LifecycleStatus' -NotePropertyValue $matchingSub.Status -Force
                }
                
                return $sku
            }
            
            Write-Verbose "Enhanced $($enhancedCopilotSkus.Count) Copilot SKUs with next date information."
            return $enhancedCopilotSkus
        }
        else {
            return $CopilotSkus
        }
    }
    catch {
        if ($_.Exception.Message -match "403" -or 
            $_.Exception.Message -match "Forbidden") {
            
            Write-Error "Access Forbidden: The Graph API permission Organization.Read.All is required. Make sure you have the appropriate administrator role and permissions. Error: $($_.Exception.Message)"
            }
            else {
            Write-Error "Failed to retrieve Copilot limited mode settings $($_.Exception.Message)"
        }
        return $null
    }
}

