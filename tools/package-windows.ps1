<#
.SYNOPSIS
  Construit puis emballe le Game Area TRIBALL en version portable Windows (x64).

.DESCRIPTION
  1. (optionnel) flutter pub get + flutter test + flutter build windows --release
  2. assemble un dossier autonome : exe + DLL + data\ + avatars\ + VERSION.txt + docs
  3. produit un .zip et son empreinte SHA-256 dans <repo>\dist

  Le livrable est un dossier PORTABLE : aucune installation systeme, aucun registre,
  aucun droit administrateur. On le copie tel quel sur le PC de la TV.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\package-windows.ps1
  Construit et emballe (necessite Flutter sur la machine).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\package-windows.ps1 -SkipBuild -Offline
  Emballe un build deja present dans build\windows\x64\Release.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\package-windows.ps1 -Label beta2 -SkipTests
#>
[CmdletBinding()]
param(
  [string] $Label     = 'beta1',
  [string] $OutDir    = '',
  [switch] $SkipBuild,
  [switch] $SkipTests,
  [switch] $Offline,   # ne pas toucher au resolveur de paquets (--no-pub)
  [switch] $NoZip
)

$ErrorActionPreference = 'Stop'

function Write-Step([string] $msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Warn2([string] $msg) { Write-Host "!!  $msg" -ForegroundColor Yellow }

$tools   = (Resolve-Path $PSScriptRoot).Path
$repo    = (Resolve-Path (Join-Path $tools '..')).Path
$appDir  = Join-Path $repo 'triball_game_area'
$pubspec = Join-Path $appDir 'pubspec.yaml'

if (-not (Test-Path $pubspec)) { throw "pubspec introuvable : $pubspec" }

# --- version lue dans pubspec.yaml (1.0.0+1 -> 1.0.0) -------------------------
$raw = Get-Content $pubspec -Raw
$version = '0.0.0'
if ($raw -match '(?m)^version:\s*([0-9][^\s+]*)') { $version = $Matches[1] }

if ([string]::IsNullOrWhiteSpace($OutDir)) { $OutDir = Join-Path $repo 'dist' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Push-Location $appDir
try {
  if (-not $SkipBuild) {
    if (-not $Offline) {
      Write-Step 'flutter pub get'
      flutter pub get
      if ($LASTEXITCODE -ne 0) { throw 'flutter pub get a echoue' }
    }
    if (-not $SkipTests) {
      Write-Step 'flutter test (non bloquant : un beta doit rester producible)'
      flutter test
      if ($LASTEXITCODE -ne 0) { Write-Warn2 'des tests echouent — le build continue, corriger avant diffusion' }
    }
    Write-Step 'flutter build windows --release'
    $buildArgs = @('build', 'windows', '--release')
    if ($Offline) { $buildArgs += '--no-pub' }
    & flutter @buildArgs
    if ($LASTEXITCODE -ne 0) { throw 'flutter build windows --release a echoue' }
  }
}
finally {
  Pop-Location
}

$release = Join-Path $appDir 'build\windows\x64\Release'
if (-not (Test-Path (Join-Path $release 'triball_game_area.exe'))) {
  throw "build introuvable : $release (lancer sans -SkipBuild)"
}

$stamp  = Get-Date -Format 'yyyyMMdd-HHmm'
$name   = "TriballGameArea-v$version-$Label-$stamp"
$stage  = Join-Path $OutDir $name

Write-Step "Assemblage du paquet : $name"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# 1) exe + DLL (le lanceur Flutter charge flutter_windows.dll a cote de l'exe)
Get-ChildItem $release -File | Copy-Item -Destination $stage -Force

# 2) data\ (flutter_assets : polices, audio, lottie, images) — indispensable
Copy-Item (Join-Path $release 'data') -Destination $stage -Recurse -Force

# 3) avatars\ : cree a l'avance pour que l'operateur voie ou tombent les photos.
#    Le code le recree / le deplace ailleurs si ce chemin est protege.
$avatars = Join-Path $stage 'avatars'
New-Item -ItemType Directory -Force -Path $avatars | Out-Null
@'
Ce dossier contient les photos des joueurs entrees au top 10 (un .jpg par entree,
nomme <mode>_<uuid>.jpg). Il est ecrit a cote de triball_game_area.exe.

- Il est recree automatiquement s'il est supprime.
- Conserver ce dossier lors d'une mise a jour : ce sont les avatars du classement.
- Si le programme est installe dans un endroit non editable (Program Files),
  le jeu bascule tout seul dans Documents\TriballGame\avatars. Le chemin reel est
  affiche dans le menu admin : lobby -> 5 appuis en haut a droite -> code 1234 ->
  "Diagnostic des avatars".
'@ | Set-Content -Path (Join-Path $avatars 'README.txt') -Encoding UTF8

# 4) docs + script d'installation : le paquet doit etre autonome
foreach ($d in @('INSTALL-WINDOWS-BETA.md', 'TEST-AVATARS-TV.md')) {
  $src = Join-Path (Join-Path $repo 'docs') $d
  if (Test-Path $src) { Copy-Item $src -Destination $stage -Force }
}
$installer = Join-Path $tools 'install-on-target.ps1'
if (Test-Path $installer) { Copy-Item $installer -Destination $stage -Force }

# 5) VERSION.txt (tracabilite du build)
$sha = ''
try {
  $sha = (Get-FileHash -Algorithm SHA256 -Path (Join-Path $release 'triball_game_area.exe')).Hash
} catch { $sha = 'inconnu' }
$git = 'n/a'
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'   # une sortie stderr d'un exe natif ne doit pas interrompre le script
try {
  Push-Location $repo
  $git = (& git rev-parse --short HEAD 2>$null)
  if (-not $git) { $git = 'n/a' }
  Pop-Location
} catch { $git = 'n/a' }
$ErrorActionPreference = $prevEap
@(
  "produit        : TRIBALL Arcade Pro — Game Area",
  "version        : $version",
  "label          : $Label",
  "build          : $stamp",
  "commit         : $git",
  "machine        : $env:COMPUTERNAME / $env:USERNAME",
  "sha256(exe)    : $sha",
  "",
  "Dossier portable : lancer triball_game_area.exe depuis n'importe quel emplacement",
  "executable       : triball_game_area.exe",
  "ecran            : 1920x1080 paysage, plein écran automatique",
  "reseau           : wifi de la plateforme arcade (amz_triball / 12345678)"
) | Set-Content -Path (Join-Path $stage 'VERSION.txt') -Encoding UTF8

Write-Host ''
Write-Host '  contenu :' -ForegroundColor DarkGray
Get-ChildItem $stage | ForEach-Object { Write-Host ("   - " + $_.Name) -ForegroundColor DarkGray }

# 6) zip + empreinte
if (-not $NoZip) {
  $zip = Join-Path $OutDir "$name.zip"
  Write-Step "Compression : $(Split-Path $zip -Leaf)"
  if (Test-Path $zip) { Remove-Item $zip -Force }
  Compress-Archive -Path $stage -DestinationPath $zip -CompressionLevel Optimal
  $zipSha = (Get-FileHash -Algorithm SHA256 -Path $zip).Hash
  "$zipSha  $(Split-Path $zip -Leaf)" | Set-Content -Path "$zip.sha256" -Encoding ASCII
  Write-Host ''
  Write-Host "  zip      : $zip" -ForegroundColor Green
  Write-Host "  sha256   : $zipSha" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Pret. Sur le PC de la TV :' -ForegroundColor Cyan
Write-Host "  1. copier le zip (ou le dossier $name) puis dezipper"
Write-Host '  2. powershell -ExecutionPolicy Bypass -File install-on-target.ps1'
Write-Host "     (script fourni dans tools\, ou double-clic sur $name\triball_game_area.exe)"
Write-Host '  3. verifier : splash "BETA 1", connection plateforme, puis Diagnostic des avatars'
