@{
    RootModule = 'Microsoft.Graph.Copilot.psm1'
    ModuleVersion = '0.1.0'
    GUID = 'eca6392f-3bc5-4031-b054-77f57b6c8758'
    Author = 'Daniel Bradley'
    CompanyName = 'ourcloudnetwork.com'
    Copyright = '(c) ourcloudnetwork. All rights reserved.'
    Description = 'A PowerShell module to manage Microsoft Copilot related settings with the Graph API. This module is in early development and is only compatible with the available Microsoft Graph Beta APIs. It is not developed or supported by Microsoft.'
    FunctionsToExport = @(
        'Get-CopilotInteractionHistory',
        'Get-CopilotLicense',
        'Get-CopilotLimitedMode',
        'Get-CopilotUsageDetail',
        'Get-CopilotPersonalizationSetting',
        'Update-CopilotLimitedMode',
        'Update-CopilotPersonalizationSetting',
        'New-CopilotSearch',
        'New-CopilotRetrieval'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
            PSData = @{
                Tags = @('Microsoft', 'Copilot', 'MicrosoftCopilot')
                LicenseUri = 'https://github.com/DanielBradley1/Microsoft.Graph.Copilot/blob/main/LICENSE'
                ProjectUri = 'https://github.com/DanielBradley1/Microsoft.Graph.Copilot'
                # IconUri = ''
                # ReleaseNotes = ''
            ExternalModuleDependencies = @('Microsoft.Graph.Authentication')
            }
        }
    }
