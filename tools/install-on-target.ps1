<#
.SYNOPSIS
  Installe (ou met a jour) le Game Area TRIBALL sur le PC dedie a la TV arcade.

.DESCRIPTION
  Installation "portable" volontaire : aucun installateur systeme, aucun registre,
  aucun droit administrateur. Le jeu est copie dans un dossier editable, parce qu'il
  y ecrit les photos du top 10 (sous-dossier avatars\).

  Par defaut l'installation se fait dans :
      %LOCALAPPDATA%\Programs\Triball\GameArea
  (jamais dans Program Files : l'ecriture y est refusee sans elevation).

  Lors d'une mise a jour, le dossier avatars\ existant est conserve : ce sont les
  photos des joueurs classes.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File install-on-target.ps1
  Installe depuis le dossier du paquet dezippe (le script y est fourni).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File install-on-target.ps1 -Destination "D:\Triball\GameArea" -AutoStart
  Installe ailleurs et lance le jeu a l'ouverture de session (kiosque).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File install-on-target.ps1 -Remove
  Retire les raccourcis et arrete le jeu (ne supprime pas les photos).
#>
[CmdletBinding()]
param(
  [string] $Source = '',
  [string] $Destination = '',
  [switch] $AutoStart,
  [switch] $NoAutoStart,
  [switch] $NoShortcut,
  [switch] $Remove
)

$ErrorActionPreference = 'Stop'
$exeName = 'triball_game_area.exe'
$appLabel = 'TRIBALL - Ecran de jeu'

function Write-Step2([string] $m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Write-Ok([string] $m)   { Write-Host "  [ok] $m" -ForegroundColor Green }
function Write-Note([string] $m) { Write-Host "  ..   $m" -ForegroundColor DarkGray }

$root = if ([string]::IsNullOrWhiteSpace($Destination)) {
  Join-Path $env:LOCALAPPDATA 'Programs\Triball\GameArea'
} else { $Destination }
$desktop = [Environment]::GetFolderPath('Desktop')
$startup = [Environment]::GetFolderPath('Startup')
$lnkDesk = Join-Path $desktop "$appLabel.lnk"
$lnkStart = Join-Path $startup "$appLabel.lnk"

# --- desinstallation douce : raccourcis + processus ---------------------------
if ($Remove) {
  Write-Step2 'Retrait des raccourcis et arret du jeu'
  foreach ($lnk in @($lnkDesk, $lnkStart)) {
    if (Test-Path $lnk) { Remove-Item $lnk -Force; Write-Ok "supprime : $lnk" }
  }
  $proc = Get-Process -Name 'triball_game_area' -ErrorAction SilentlyContinue
  if ($proc) {
    $proc | Stop-Process -Force
    Write-Ok 'jeu arrete'
  } else { Write-Note 'aucun processus du jeu en cours' }
  Write-Host ''
  Write-Host "  les photos restent dans : $root\avatars" -ForegroundColor Yellow
  Write-Host '  (supprimer ce dossier manuellement pour tout effacer)'
  return
}

# --- localisation du paquet ----------------------------------------------------
if ([string]::IsNullOrWhiteSpace($Source)) {
  $candidate = $PSScriptRoot
  if (Test-Path (Join-Path $candidate $exeName)) { $Source = $candidate }
}
if ([string]::IsNullOrWhiteSpace($Source)) {
  $Source = Join-Path $PSScriptRoot '..'
}
$Source = (Resolve-Path $Source).Path
if (-not (Test-Path (Join-Path $Source $exeName))) {
  throw "paquet invalide : $exeName est absent de $Source. Utilisation : install-on-target.ps1 -Source <dossier dezippe>"
}

Write-Step2 "Source      : $Source"
Write-Step2 "Destination : $root"

# --- preparation ---------------------------------------------------------------
$targetExe = Join-Path $root $exeName
$running = Get-Process -Name 'triball_game_area' -ErrorAction SilentlyContinue
if ($running) {
  Write-Note 'le jeu tourne : arret avant mise a jour'
  $running | Stop-Process -Force
  Start-Sleep -Milliseconds 800
}

$keepAvatars = $null
if (Test-Path (Join-Path $root 'avatars')) {
  $keepAvatars = Join-Path $env:TEMP ("triball_avatars_" + (Get-Date -Format 'yyyyMMddHHmmss'))
  Write-Note 'avatars existants deplaces temporairement (preservation des photos du top 10)'
  Move-Item (Join-Path $root 'avatars') $keepAvatars -Force
}

New-Item -ItemType Directory -Force -Path $root | Out-Null

# --- copie ---------------------------------------------------------------------
Write-Step2 'Copie des fichiers'
Copy-Item -Path (Join-Path $Source '*') -Destination $root -Recurse -Force
Write-Ok "exe, dll, data\ et docs copies"

if ($keepAvatars) {
  $back = Join-Path $root 'avatars'
  if (Test-Path $back) { Remove-Item $back -Recurse -Force -ErrorAction SilentlyContinue }
  Move-Item $keepAvatars $back -Force
  Write-Ok 'photos du top 10 restaurees'
}

# le zip recu par mail/WhatsApp porte la mention "bloque" : on la leve
Write-Step2 'Deblocage des fichiers (Mark-of-the-Web)'
try {
  Get-ChildItem $root -Recurse | Unblock-File
  Write-Ok 'fichiers debloques'
} catch { Write-Note 'unblock impossible (ignore si tout se lance)' }

# --- raccourcis ----------------------------------------------------------------
function New-TriballShortcut([string] $path) {
  $shell = New-Object -ComObject WScript.Shell
  $sc = $shell.CreateShortcut($path)
  $sc.TargetPath = $targetExe
  $sc.WorkingDirectory = $root
  $sc.IconLocation = "$targetExe,0"
  $sc.Description = 'TRIBALL Arcade Pro - ecran de jeu (TV)'
  $sc.Save()
}

if (-not $NoShortcut) {
  Write-Step2 'Raccourci sur le Bureau'
  New-TriballShortcut $lnkDesk
  Write-Ok $lnkDesk
}

if ($AutoStart) {
  Write-Step2 'Lance le jeu a chaque ouverture de session'
  New-TriballShortcut $lnkStart
  Write-Ok $lnkStart
} elseif ($NoAutoStart) {
  if (Test-Path $lnkStart) { Remove-Item $lnkStart -Force; Write-Ok 'demarrage auto retire' }
}

# --- controle ------------------------------------------------------------------
Write-Step2 'Verification'
if (Test-Path $targetExe) { Write-Ok "executable : $targetExe" } else { throw " copie echouee : $targetExe introuvable" }
if (Test-Path (Join-Path $root 'flutter_windows.dll')) { Write-Ok 'flutter_windows.dll present' }
else { Write-Note 'flutter_windows.dll absent : la copie est incomplete, ne pas lancer' }
if (Test-Path (Join-Path $root 'data\flutter_assets')) { Write-Ok 'data\flutter_assets present' }
else { Write-Note 'data\ absent : le jeu refusera de demarrer (assets manquants)' }

Write-Host ''
Write-Host '  Installe. Premier lancement :' -ForegroundColor Cyan
Write-Host "   1. double-clic sur le raccourci « $appLabel » (ou sur $exeName)"
Write-Host '   2. attendre "Version 1.0.0 · BETA 1" sur le splash, puis ecran en attente'
Write-Host '   3. connecter le PC au wifi amz_triball (cle 12345678) : le badge devient vert'
Write-Host '   4. test complet : docs TEST-AVATARS-TV.md (dans ce dossier)'
Write-Host ''
Write-Host '  Pour quitter le plein ecran : 5 appuis en haut a droite du lobby -> code 1234.' -ForegroundColor Yellow
Write-Host "  Emplacement des photos du top 10 : $root\avatars" -ForegroundColor Yellow
Write-Host ''
Write-Host '  Si le jeu ne demarre pas : installer le runtime Visual C++ x64 (https://aka.ms/vs/17/release/vc_redist.x64.exe)'
Write-Host '  puis relancer. Un SmartScreen peut apparaitre au premier lancement (exe non signe) :'
Write-Host '  "Plus d''informations" puis "Executer quand meme".'
