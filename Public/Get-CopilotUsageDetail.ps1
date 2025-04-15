function Get-CopilotUsageDetail {
    <#
    .SYNOPSIS
    Get the most recent activity data for enabled users of Microsoft 365 Copilot apps.
    
    .DESCRIPTION
    Get the most recent activity data for enabled users of Microsoft 365 Copilot app, output as a CSV or PowerShell object.
    
    .PARAMETER Period
    Specifies the time period for which to retrieve data.
    Accepted values: D7 (7 days), D30 (30 days), D90 (90 days), D180 (180 days), or ALL.
    
    .PARAMETER Format
    Specifies the format of the returned data.
    Accepted values: object or csv.
    
    .PARAMETER OutPath
    Specifies the file path where the CSV data should be saved. 
    This parameter can only be used when Format is set to 'csv'.
    
    .EXAMPLE
    Get-CopilotUsageDetail -Period D30 -Format object
    
    Returns the Copilot usage details for the past 30 days in JSON format.
    
    .EXAMPLE
    Get-CopilotUsageDetail -Period D90 -Format csv -OutPath "C:\Reports\CopilotUsage.csv"
    
    Retrieves Copilot usage details for the past 90 days and saves them to the specified CSV file.
    
    .LINK
    https://learn.microsoft.com/en-us/graph/api/reportroot-getmicrosoft365copilotusageuserdetail
    
    .OUTPUTS
    PSCustomObject or csv file
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'OBJECT')]
    [OutputType([PSCustomObject], [String])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'OBJECT')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CSV')]
        [ValidateSet("D7", "D30", "D90", "D180", "ALL")]
        [string]$Period,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'OBJECT')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CSV')]
        [ValidateSet("object", "csv")]
        [string]$Format = "object",
        
        [Parameter(Mandatory = $true, ParameterSetName = 'CSV')]
        [ValidateScript({
            # Check if the directory exists
            $directory = Split-Path -Path $_ -Parent
            if (-not (Test-Path -Path $directory -PathType Container)) {
                throw "Directory '$directory' does not exist."
            }
            
            # Check if file has .csv extension
            if (-not $_.EndsWith('.csv', [StringComparison]::OrdinalIgnoreCase)) {
                throw "The OutPath parameter must specify a file with a .csv extension."
            }
            
            return $true
        })]
        [string]$OutPath
    )

    # Parameter set validation
    if ($Format -eq "csv" -and -not $PSBoundParameters.ContainsKey('OutPath')) {
        throw "When Format is set to 'csv', the OutPath parameter is required."
    }

    Write-Verbose "Attempting to get Copilot usage details for period: $Period in $Format format"

    try {

        if ($Format -eq "object") { 

            $usageDetails = Invoke-MgGraphRequest -Uri "beta/reports/getMicrosoft365CopilotUsageUserDetail(period='$Period')?`$format=application/json" -OutputType PSObject | Select -Expand Value
            return $usageDetails

        } elseif ($Format -eq "csv") {
            
            Try {

                $usageDetails = Invoke-MgGraphRequest -Uri "beta/reports/getMicrosoft365CopilotUsageUserDetail(period='$Period')?`$format=text/csv" -OutputFilePath $OutPath
                Write-Progress -Completed     
                Write-Host "Copilot usage details saved to: $OutPath" -foregroundcolor yellow

            } Catch {
                if ($_.Exception.Message -match "403" -or 
                $_.Exception.Message -match "Forbidden") {
                
                    Write-Error "Access Forbidden: The Graph API permission Reports.Read.All is required. Make sure you have the appropriate administrator role and permissions. Error: $($_.Exception.Message)"
                }
                else {
                    Write-Error "Failed to retrieve Copilot usage detail report $($_.Exception.Message)"
                }
                return $null
            }
        }

        return $usageDetails
    }
    catch {
        if ($_.Exception.Message -match "403" -or 
            $_.Exception.Message -match "Forbidden") {
            
            Write-Error "Access Forbidden: The Graph API permission Reports.Read.All is required. Make sure you have the appropriate administrator role and permissions. Error: $($_.Exception.Message)"
            }
            else {
            Write-Error "Failed to retrieve Copilot usage detail report $($_.Exception.Message)"
        }
        return $null
    }
}