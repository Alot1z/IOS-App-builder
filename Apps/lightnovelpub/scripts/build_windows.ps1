# PowerShell build script optimized for Windows
param(
    [string]$IosVersion,
    [string]$AppVersion,
    [string]$MinIosVersion,
    [string]$MaxIosVersion,
    [int]$OptimizationLevel = 3,
    [bool]$EnableBitcode = $false,
    [bool]$EnableArc = $true,
    [string]$DeploymentTarget,
    [string]$BuildType = "release"
)

# Error handling
$ErrorActionPreference = "Stop"

# Configuration
$BuildDir = Join-Path $PSScriptRoot ".." "build"
$CacheDir = Join-Path $BuildDir "cache"
$AssetsDir = Join-Path $PSScriptRoot ".." "assets"
$SourceDir = Join-Path $PSScriptRoot ".." "src"

# Create directories
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null

# Validate tools
$Tools = @{
    "Swift" = "C:\Program Files\Swift\bin\swiftc.exe"
    "ImageMagick" = "C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe"
}

foreach ($tool in $Tools.GetEnumerator()) {
    if (-not (Test-Path $tool.Value)) {
        Write-Error "Required tool not found: $($tool.Key) at $($tool.Value)"
        exit 1
    }
}

# Parallel build functions
function Start-ParallelBuild {
    param(
        [string[]]$SwiftFiles,
        [string]$OutputDir,
        [int]$MaxThreads = [Environment]::ProcessorCount
    )
    
    # Split files into chunks for parallel processing
    $ChunkSize = [Math]::Ceiling($SwiftFiles.Count / $MaxThreads)
    $Chunks = for ($i = 0; $i -lt $SwiftFiles.Count; $i += $ChunkSize) {
        ,($SwiftFiles[$i..([Math]::Min($i + $ChunkSize - 1, $SwiftFiles.Count - 1))])
    }
    
    # Create compilation jobs
    $Jobs = @()
    foreach ($Chunk in $Chunks) {
        $Jobs += Start-Job -ScriptBlock {
            param($Files, $Output, $Tools)
            
            foreach ($File in $Files) {
                & $Tools.Swift -O -emit-object -o "$Output\$(Split-Path $File -Leaf).o" $File
            }
        } -ArgumentList $Chunk, $OutputDir, $Tools
    }
    
    # Wait for all jobs and get results
    $Jobs | Wait-Job | Receive-Job
    $Jobs | Remove-Job
}

# Build process
try {
    Write-Host "Starting optimized Windows build process..."
    
    # Clean build directory
    if (Test-Path $BuildDir) {
        Get-ChildItem -Path $BuildDir -Exclude "cache" | Remove-Item -Recurse -Force
    }
    
    # Generate icons in parallel
    Write-Host "Generating icons..."
    $IconScript = Join-Path $PSScriptRoot "generate_icons.sh"
    Start-Process -FilePath "C:\Program Files\Git\bin\bash.exe" -ArgumentList $IconScript -NoNewWindow -Wait
    
    # Find Swift files
    $SwiftFiles = Get-ChildItem -Path $SourceDir -Filter "*.swift" -Recurse | Select-Object -ExpandProperty FullName
    
    if ($SwiftFiles.Count -eq 0) {
        Write-Error "No Swift source files found"
        exit 1
    }
    
    Write-Host "Found $($SwiftFiles.Count) Swift files"
    
    # Create intermediate directories
    $ObjDir = Join-Path $BuildDir "obj"
    New-Item -ItemType Directory -Force -Path $ObjDir | Out-Null
    
    # Compile in parallel
    Write-Host "Compiling Swift files in parallel..."
    Start-ParallelBuild -SwiftFiles $SwiftFiles -OutputDir $ObjDir
    
    # Link objects
    Write-Host "Linking..."
    $Objects = Get-ChildItem -Path $ObjDir -Filter "*.o" | Select-Object -ExpandProperty FullName
    $OutputExe = Join-Path $BuildDir "release" "LightNovelPub.exe"
    
    & $Tools.Swift -O -o $OutputExe $Objects
    
    # Create IPA structure
    Write-Host "Creating IPA structure..."
    $PayloadDir = Join-Path $BuildDir "Payload" "LightNovelPub.app"
    New-Item -ItemType Directory -Force -Path $PayloadDir | Out-Null
    
    # Copy files to IPA structure
    Copy-Item $OutputExe $PayloadDir
    Copy-Item (Join-Path $BuildDir "Info.plist") $PayloadDir
    Copy-Item -Recurse (Join-Path $BuildDir "Assets.xcassets") $PayloadDir
    
    # Create IPA
    Write-Host "Creating IPA..."
    Compress-Archive -Path (Join-Path $BuildDir "Payload") -DestinationPath (Join-Path $BuildDir "LightNovelPub.ipa") -Force
    
    # Clean up
    Remove-Item -Recurse -Force (Join-Path $BuildDir "Payload")
    Remove-Item -Recurse -Force $ObjDir
    
    Write-Host "Build complete! IPA created at: $BuildDir\LightNovelPub.ipa"
    
} catch {
    Write-Error "Build failed: $_"
    exit 1
}
