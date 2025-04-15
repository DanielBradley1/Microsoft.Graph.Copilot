@{
    RootModule = 'Microsoft.Graph.Copilot.psm1'
    ModuleVersion = '0.0.1'
    GUID = 'eca6392f-3bc5-4031-b054-77f57b6c8758'
    Author = 'Daniel Bradley'
    CompanyName = 'ourcloudnetwork.com'
    Copyright = '(c) ourcloudnetwork. All rights reserved.'
    Description = 'A PowerShell module to to managed Microsoft Copilot related settings with the Graph API.'
    FunctionsToExport = @(
        'Get-CopilotInteractionHistory',
        'Get-CopilotLicense',
        'Get-CopilotLimitedMode',
        'Get-CopilotUsageDetail',
        'Get-CopilotPersonalizationSetting',
        'Update-CopilotLimitedMode',
        'Update-CopilotPersonalizationSetting'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
            PSData = @{
                Tags = @('Microsoft Graph', 'Copilot', 'Microsoft Copilot')
                LicenseUri = 'https://github.com/DanielBradley1/Microsoft.Graph.Copilot/blob/main/LICENSE'
                ProjectUri = 'https://github.com/DanielBradley1/Microsoft.Graph.Copilot'
                # IconUri = ''
                # ReleaseNotes = ''
            ExternalModuleDependencies = @('Microsoft.Graph.Authentication')
            }
        }
    }