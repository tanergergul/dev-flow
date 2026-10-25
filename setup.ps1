<#
.SYNOPSIS
  Dev flow agent'larını, komutlarını ve kişisel skill'lerini kurar veya günceller.
  Installs or updates the dev flow agents, commands and personal skills.

.DESCRIPTION
  - <lang>\agents\*.agent.md ve <lang>\prompts\*.prompt.md dosyalarını VS Code kullanıcı profilinin
    prompts klasörüne kopyalar. Farklı içerikli bir dosya varsa önce .bak olarak yedekler.
  - <lang>\skills\ altındaki skill'leri ~\.copilot\skills\ altına kopyalar. Var olan bir skill'in
    üzerine yazmaz.
  Türkçe ve İngilizce sürümler aynı bilgisayara birlikte kurulabilir; agent ve komut adları farklıdır.

  - Copies <lang>\agents\*.agent.md and <lang>\prompts\*.prompt.md to the VS Code user profile's
    prompts folder. Existing files with different content are backed up as .bak first.
  - Copies the skills under <lang>\skills\ to ~\.copilot\skills\. Existing skills are never overwritten.
  The Turkish and English versions can be installed side by side; agent and command names differ.

.PARAMETER Lang
  en (varsayılan / default) veya / or tr. Alias: -Dil

.PARAMETER Target
  Agent ve prompt dosyalarının kopyalanacağı klasör / Target folder for agent and prompt files.
  Varsayılan / Default: %APPDATA%\Code\User\prompts. Alias: -Hedef

.PARAMETER Insiders
  VS Code Insiders.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\setup.ps1
  powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Lang tr
#>
param(
    [Alias('Dil')]
    [ValidateSet('en', 'tr')]
    [string]$Lang = 'en',
    [Alias('Hedef')]
    [string]$Target,
    [switch]$Insiders
)

$ErrorActionPreference = 'Stop'

$m = @{
    tr = @{
        Guncel   = 'Güncel:     '
        Yedek    = 'Yedeklendi: '
        Kuruldu  = 'Kuruldu:    '
        Korundu  = 'Korundu:    '
        KorNot   = ' (zaten var, üzerine yazılmadı)'
        Bitti    = 'Tamam. VS Code''u yeniden başlatın ve Chat''teki agent listesinde dev flow agent''larını kontrol edin.'
        Gorunmez = 'Görünmüyorlarsa tr\README.md içindeki "Agent''lar görünmüyorsa" bölümüne bakın.'
    }
    en = @{
        Guncel   = 'Up to date: '
        Yedek    = 'Backed up:  '
        Kuruldu  = 'Installed:  '
        Korundu  = 'Kept:       '
        KorNot   = ' (already exists, not overwritten)'
        Bitti    = 'Done. Restart VS Code and check that the dev flow agents appear in the Chat agent list.'
        Gorunmez = 'If they do not, see the "If the agents do not appear" section in en\README.md.'
    }
}[$Lang]

$kaynak = Join-Path $PSScriptRoot $Lang

if (-not $Target) {
    $kod = if ($Insiders) { 'Code - Insiders' } else { 'Code' }
    $Target = Join-Path $env:APPDATA "$kod\User\prompts"
}
New-Item -ItemType Directory -Force -Path $Target | Out-Null

$dosyalar = @(Get-ChildItem (Join-Path $kaynak 'agents') -Filter '*.agent.md') +
            @(Get-ChildItem (Join-Path $kaynak 'prompts') -Filter '*.prompt.md')

foreach ($d in $dosyalar) {
    $hedefDosya = Join-Path $Target $d.Name
    if (Test-Path $hedefDosya) {
        if ((Get-FileHash $hedefDosya).Hash -eq (Get-FileHash $d.FullName).Hash) {
            Write-Host "$($m.Guncel)$($d.Name)"
            continue
        }
        Copy-Item $hedefDosya "$hedefDosya.bak" -Force
        Write-Host "$($m.Yedek)$hedefDosya.bak"
    }
    Copy-Item $d.FullName $hedefDosya -Force
    Write-Host "$($m.Kuruldu)$hedefDosya"
}

$skillHedef = Join-Path $HOME '.copilot\skills'
foreach ($s in Get-ChildItem (Join-Path $kaynak 'skills') -Directory) {
    $h = Join-Path $skillHedef $s.Name
    if (Test-Path $h) {
        Write-Host "$($m.Korundu)$h$($m.KorNot)"
        continue
    }
    New-Item -ItemType Directory -Force -Path $h | Out-Null
    Copy-Item (Join-Path $s.FullName '*') $h -Recurse
    Write-Host "$($m.Kuruldu)$h"
}

Write-Host ''
Write-Host $m.Bitti
Write-Host $m.Gorunmez
