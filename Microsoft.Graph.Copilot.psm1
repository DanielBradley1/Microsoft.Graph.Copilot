# Microsoft.Graph.Copilot
# Main module file

# Import private functions
$PrivateFunctions = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the private functions
foreach ($Private in $PrivateFunctions) {
    try {
        . $Private.FullName
        Write-Verbose "Imported private function $($Private.BaseName)"
    }
    catch {
        Write-Error "Failed to import private function $($Private.FullName): $_"
    }
}

# Import public functions
$PublicFunctions = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the public functions
foreach ($Public in $PublicFunctions) {
    try {
        . $Public.FullName
        Write-Verbose "Imported public function $($Public.BaseName)"
    }
    catch {
        Write-Error "Failed to import public function $($Public.FullName): $_"
    }
}

# Get the module root path
$PSModuleRoot = $PSScriptRoot

# Export only the public functions
Export-ModuleMember -Function $PublicFunctions.BaseName