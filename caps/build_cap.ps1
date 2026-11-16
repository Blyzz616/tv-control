# Build one cap: SVG -> layers -> STLs (cap + every piece), in one go.
#   .\build_cap.ps1 youtube        (or jellyfin / netflix / prime)
# Needs: caps\svg\<name>.svg, Python with svgelements + shapely, OpenSCAD.
# Jellyfin and Netflix need shape numbers: run once with -List, then put them in $Layers below.
param(
    [Parameter(Mandatory=$true)][ValidateSet("youtube","jellyfin","netflix","prime")][string]$Name,
    [switch]$List,
    [string]$Scad   # optional: full path to openscad.exe
)
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# converter layer arguments per cap (must match the variable names in <name>.scad)
$Layers = @{
    youtube  = @("--layer","tv:fill=#fff:solid","--layer","play:fill=#fff:holes")
    jellyfin = @("--layer","outer:index=2","--layer","inner:index=3")                          # CHECK with -List
    netflix  = @("--layer","left:index=2","--layer","right:index=3","--layer","diag:index=4")  # CHECK with -List
    prime    = @("--layer","main:all")
}
$Pieces = @{ youtube = 2; jellyfin = 2; netflix = 3; prime = 1 }

$svg = Join-Path $here "svg\$Name.svg"
if (-not (Test-Path $svg)) { throw "Missing $svg - save the SVG there first." }

# find python
$py = (Get-Command python -ErrorAction SilentlyContinue).Source
if (-not $py) { $py = (Get-Command py -ErrorAction SilentlyContinue).Source }
if (-not $py) { throw "Python not found on PATH." }

# find OpenSCAD: -Scad, then PATH, then the usual install folders (incl. Nightly builds)
$scad = $Scad
if (-not $scad) { $scad = (Get-Command openscad -ErrorAction SilentlyContinue).Source }
if (-not $scad) {
    $scad = Get-ChildItem "C:\Program Files*", "$env:LOCALAPPDATA\Programs", "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" `
              -Recurse -Depth 3 -Filter "openscad*.exe" -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^openscad(\.com|\.exe)?$' -or $_.Name -eq 'openscad.exe' } |
            Select-Object -First 1 -ExpandProperty FullName
}
if (-not $scad) { throw "OpenSCAD not found. Install it (winget install OpenSCAD.OpenSCAD) and rerun." }
Write-Host "OpenSCAD: $scad"

$tool = Join-Path $here "tools\svg2scad.py"
$gen  = Join-Path $here "gen\$Name.scad"
if ($List) { & $py $tool $svg $gen --prefix $Name --list; exit }

& $py $tool $svg $gen --prefix $Name @($Layers[$Name])
if ($LASTEXITCODE) { throw "svg2scad failed" }

$out = Join-Path $here "stl"
New-Item -ItemType Directory -Force $out | Out-Null
$file = Join-Path $here "$Name.scad"
# export_piece: -1 = cap, n = piece n (numbers avoid PowerShell quote mangling)
& $scad -o (Join-Path $out "${Name}_cap.stl") -D "export_piece=-1" $file
if ($LASTEXITCODE) { throw "OpenSCAD failed on the cap" }
for ($i = 0; $i -lt $Pieces[$Name]; $i++) {
    & $scad -o (Join-Path $out "${Name}_piece$i.stl") -D "export_piece=$i" $file
    if ($LASTEXITCODE) { throw "OpenSCAD failed on piece $i" }
}
Write-Host "Done: $out"
Get-ChildItem $out -Filter "$Name*.stl" | Select-Object Name, Length
