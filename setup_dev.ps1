# Install Scoop if not already installed
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Add required buckets
scoop bucket add main
scoop bucket add extras
scoop bucket add versions

# Install Windows development tools
$windows_tools = @(
    "git",              # For version control
    "vscode",           # Code editor
    "python",           # For scripts
    "imagemagick",      # For icon generation
    "nodejs",           # For web tools
    "gh"               # GitHub CLI for workflow management
)

foreach ($tool in $windows_tools) {
    Write-Host "Installing $tool..."
    scoop install $tool
}

# Setup GitHub CLI
Write-Host "Setting up GitHub CLI..."
gh auth login

# Create helper function for building apps
$buildScript = @'
function Build-IOSApp {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AppName
    )
    
    Write-Host "Triggering GitHub Actions workflow for $AppName..."
    gh workflow run "$AppName.yml" --ref main
    
    Write-Host "Opening workflow status in browser..."
    gh run list --workflow="$AppName.yml" --limit 1 | Select-Object -First 1 | ForEach-Object {
        $runId = ($_ -split '\s+')[0]
        gh run view $runId --web
    }
}
'@

# Add the function to PowerShell profile
$profilePath = $PROFILE.CurrentUserAllHosts
if (!(Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force
}
Add-Content -Path $profilePath -Value $buildScript

# Create convenient aliases
$aliases = @'

# iOS App Builder aliases
Set-Alias -Name build-lnp -Value { Build-IOSApp -AppName "lightnovelpub" }
Set-Alias -Name build-ts -Value { Build-IOSApp -AppName "trollstore" }
'@
Add-Content -Path $profilePath -Value $aliases

Write-Host "Development environment setup complete!"
Write-Host "You can now use these commands:"
Write-Host "  build-lnp : Build LightNovel Pub app"
Write-Host "  build-ts  : Build TrollStore app"
Write-Host ""
Write-Host "The builds will run on GitHub Actions and use macOS runners."
