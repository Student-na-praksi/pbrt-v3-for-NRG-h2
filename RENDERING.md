# PBRT Rendering Workflow

This project is configured with a clean render output structure.

## Directory Organization

- **exr_results/** — High dynamic range EXR outputs from renders
- **img_results/** — Tone-mapped PNG previews (automatically converted from EXR)
- **build-vs2019/** — CMake build artifacts and intermediate files
- **scenes/** — PBRT scene files (.pbrt)

## Usage: Render-PBRTScene Helper

Load the helper function:
```powershell
. .\render-helper.ps1
```

### Quick render + convert to PNG (default):
```powershell
Render-PBRTScene ".\scenes\killeroo-simple.pbrt"
```

### Quick render with custom output name:
```powershell
Render-PBRTScene ".\scenes\killeroo-simple.pbrt" -OutputName "my-quick-test" -Quick
```

### Full quality render (may take several seconds):
```powershell
Render-PBRTScene ".\scenes\killeroo-simple.pbrt" -OutputName "killeroo-full-quality"
```

### Render without PNG conversion (EXR only):
```powershell
Render-PBRTScene ".\scenes\killeroo-simple.pbrt" -NoConvert
```

### Alias shortcut (after loading helper):
```powershell
render ".\scenes\killeroo-simple.pbrt" -Quick
```

## Output Examples

After running the helper, you'll see:
- `exr_results/killeroo-simple.exr` — Original render (high dynamic range)
- `img_results/killeroo-simple.png` — Tone-mapped preview (ready to view in any image viewer)

## Setup Instructions

1. The directories and helper are already created. To use in future PowerShell sessions, add this to your PowerShell profile:
   ```powershell
   . "$PSScriptRoot\render-helper.ps1"
   ```

2. Or source it manually each time:
   ```powershell
   . .\render-helper.ps1
   ```

## Manual Rendering (without helper)

If you prefer direct control:

```powershell
# Render with custom output
.\build-vs2019\Release\pbrt.exe .\scenes\killeroo-simple.pbrt --outfile .\exr_results\my-render.exr

# Convert EXR to PNG
.\build-vs2019\Release\imgtool.exe convert --tonemap .\exr_results\my-render.exr .\img_results\my-render.png
```

## Notes

- EXR files are ignored by git (see .gitignore) to keep the repo clean
- PNG files are also ignored (preferred for version control — use EXR for archiving)
- All output directories have .gitkeep to preserve structure in git
