# PBRT Render Helper - Automatically organize EXR and PNG outputs
# Usage: Render-PBRTScene "scenes/killeroo-simple.pbrt"
# Usage: Render-PBRTScene "scenes/killeroo-simple.pbrt" -OutputName "killeroo-test" -Quick

function Render-PBRTScene {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScenePath,
        
        [Parameter(Mandatory=$false)]
        [string]$OutputName,
        
        [Parameter(Mandatory=$false)]
        [switch]$Quick,
        
        [Parameter(Mandatory=$false)]
        [switch]$NoConvert
        ,
        [Parameter(Mandatory=$false)]
        [switch]$My
    )
    
    # Resolve scene path
    $scene = Get-Item $ScenePath -ErrorAction Stop
    
    # Derive output name if not specified
    if (-not $OutputName) {
        $OutputName = $scene.BaseName
    }
    
    # Define output paths
    $exrDir = Join-Path -Path (Get-Location) -ChildPath "exr_results"
    $imgDir = Join-Path -Path (Get-Location) -ChildPath "img_results"
    $exrOutput = Join-Path -Path $exrDir -ChildPath "$OutputName.exr"
    $pngOutput = Join-Path -Path $imgDir -ChildPath "$OutputName.png"
    
    # If requested, write a temporary scene file that forces our integrator
    $sceneFileToRender = $scene.FullName
    $tmpScene = $null
    if ($My) {
        $sceneDir = Split-Path -Parent $scene.FullName
        $tmpScene = Join-Path -Path $sceneDir -ChildPath ("tmp_my_scene_{0}.pbrt" -f ([guid]::NewGuid().ToString()))
        $sceneBody = Get-Content -Path $scene.FullName -Raw
        $sceneBody = [regex]::Replace($sceneBody, '^[ \t]*Integrator[ \t]+"[^"]+".*$', '', [System.Text.RegularExpressions.RegexOptions]::Multiline)
        $sceneBody = $sceneBody.TrimStart("`r", "`n")
        $scenePrefix = 'Integrator "my_path_tracing" "integer maxdepth" [ 5 ]' + [Environment]::NewLine
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($tmpScene, $scenePrefix + $sceneBody, $utf8NoBom)
        $sceneFileToRender = $tmpScene
        Write-Host "Using temporary scene forcing 'my_path_tracing': $tmpScene" -ForegroundColor Cyan
    }

    # Build render command
    $pbrtExe = ".\build-vs2019\Release\pbrt.exe"
    $pbrtArgs = @()
    
    if ($Quick) {
        $pbrtArgs += "--quick"
        Write-Host "Rendering (quick mode)..." -ForegroundColor Cyan
    } else {
        Write-Host "Rendering (full quality)..." -ForegroundColor Cyan
    }
    
    $pbrtArgs += "--outfile"
    $pbrtArgs += "`"$exrOutput`""
    $pbrtArgs += "`"$sceneFileToRender`""
    
    # Run renderer
    & $pbrtExe @pbrtArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Render failed with exit code $LASTEXITCODE" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✅ Render complete. EXR saved: $exrOutput" -ForegroundColor Green
    
    # Convert to PNG unless skipped
    if (-not $NoConvert) {
        Write-Host "Converting to PNG..." -ForegroundColor Cyan
        $imgtoolExe = ".\build-vs2019\Release\imgtool.exe"
        & $imgtoolExe convert --tonemap "`"$exrOutput`"" "`"$pngOutput`""
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "PNG conversion failed" -ForegroundColor Yellow
            return $false
        }
        
        Write-Host "PNG saved: $pngOutput" -ForegroundColor Green
    }

    # Cleanup temporary scene file if created
    if ($tmpScene) {
        Remove-Item -Path $tmpScene -Force -ErrorAction SilentlyContinue
        Write-Host "Removed temporary scene $tmpScene" -ForegroundColor DarkGray
    }
    
    return $true
}

# Alias for convenience
Set-Alias -Name render -Value Render-PBRTScene -Scope Global
