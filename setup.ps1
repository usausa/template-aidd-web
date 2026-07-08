# template-aidd セットアップ: アプリ形態・SDD モード(と任意で PM)を選び、テンプレを確定する。
# 使い方:
#   pwsh ./setup.ps1 -Form web                # Web(API + Blazor)、SDD full、PM なし
#   pwsh ./setup.ps1 -Form desktop -Sdd lite  # デスクトップ(WPF)、SDD lite(仕様は work/ の一時物)
#   pwsh ./setup.ps1 -Form maui -PM           # MAUI + PM(PM は -Sdd full 専用)
#
#  - Form: 系(maui / web / desktop)を選ぶ。非採用系の docs/architecture/*.md と形態固有 skill を削除。
#          系内の doc(web=web/api/blazor、desktop=mvvm/desktop/wpf[将来 winui])は全部残す(未使用分は手で削ってよい)。
#  - Sdd:  full=要求(REQ)を恒久化し蒸留 / lite=仕様は work/ の一時物(クローズ蒸留して削除)。
#          `<!-- sdd:xxx -->` マーカーへ `.setup/sdd/xxx-<full|lite>.md` を挿入し、lite は差分ファイルを配置。
#  - PM:   `<!-- pm:xxx -->` マーカーへ `.setup/pm/xxx.md` を挿入(-PM)、または除去(既定)。
#  - LINT/ビルド設定は全形態の superset。触らない(実プロジェクトのテンプレで置換してよい)。
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('maui', 'web', 'desktop')]
    [string]$Form,
    [ValidateSet('full', 'lite')]
    [string]$Sdd = 'full',
    [switch]$PM
)

$ErrorActionPreference = 'Stop'
if ($PM -and ($Sdd -eq 'lite')) {
    throw "-PM は -Sdd full 専用です(lite は要求を恒久化しないため、feature 単位(1 feature ≒ 1 REQ)の PM が成立しません)。"
}
$root = $PSScriptRoot
$arch = Join-Path $root 'docs/architecture'

# --- 1. アプリ形態: 非採用系の architecture doc と形態固有 skill を削除 ---
$formDocs = @{
    maui    = @('mvvm.md', 'maui.md')
    web     = @('web.md', 'api.md', 'blazor.md')
    desktop = @('mvvm.md', 'desktop.md', 'wpf.md', 'winui.md')   # winui.md は将来追加(ファイルを置くだけで採用される)
}
$allFormDocs = $formDocs.Values | ForEach-Object { $_ } | Sort-Object -Unique
foreach ($doc in ($allFormDocs | Where-Object { $_ -notin $formDocs[$Form] })) {
    Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $arch $doc)
}
if ($Form -ne 'web') {
    # Web 固有 skill は Web 系以外で削除
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $root '.claude/skills/blazor-playwright')
}
$adopted = $formDocs[$Form] | Where-Object { Test-Path (Join-Path $arch $_) }
Write-Host "[form=$Form] 採用 doc: $($adopted -join ' / ')。非採用系の doc$(if ($Form -ne 'web') { ' と blazor-playwright skill' }) を削除。"

# --- 2. SDD: マーカーへ full|lite の差分を挿入し、lite は差分ファイルを配置 ---
$sddMarkers = @{
    'sdd:agents-intent'    = 'AGENTS.md'
    'sdd:agents-dod'       = 'AGENTS.md'
    'sdd:lifespan-spec'    = 'docs/README.md'
    'sdd:principle-retire' = 'docs/README.md'
    'sdd:principle-id'     = 'docs/README.md'
    'sdd:readme-start'     = 'README.md'
    'sdd:readme-loop'      = 'README.md'
    'sdd:review-intent'    = 'docs/review-checklist.md'
    'sdd:skill-flow'       = '.claude/skills/csharp-layered-feature/SKILL.md'
}
$sddDir = Join-Path $root '.setup/sdd'

foreach ($m in $sddMarkers.Keys) {
    $file = Join-Path $root $sddMarkers[$m]
    if (-not (Test-Path $file)) { continue }
    $token = "<!-- $m -->"
    $text = Get-Content -Raw $file
    if (-not $text.Contains($token)) { continue }
    $snippet = (Get-Content -Raw (Join-Path $sddDir (($m -replace '^sdd:', '') + "-$Sdd.md"))).TrimEnd("`r", "`n")
    Set-Content -NoNewline -Path $file -Value $text.Replace($token, $snippet)
}

if ($Sdd -eq 'lite') {
    # full 専用(REQ 恒久化・蒸留・トレーサビリティ)を削除
    $fullOnly = @(
        'docs/requirements', 'docs/traceability',
        '.claude/commands/requirements.md', '.claude/commands/trace.md',
        '.claude/skills/distill-req', '.claude/agents/requirements.md'
    )
    foreach ($p in $fullOnly) { Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $root $p) }

    # lite 差分ファイルを配置(workflow.md / done.md は上書き)
    $liteDir = Join-Path $sddDir 'lite'
    Get-ChildItem -Path $liteDir -Recurse -File -Force | ForEach-Object {
        $rel = $_.FullName.Substring($liteDir.Length + 1)
        $dest = Join-Path $root $rel
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item -Force $_.FullName $dest
    }

    # 一時 spec / plan を git 管理外に(README のみ残す)
    Add-Content -Path (Join-Path $root '.gitignore') -Value "`n# SDD lite: 一時 spec / plan(クローズ蒸留して削除)`nwork/*`n!work/README.md"

    Write-Host "[sdd=lite] 仕様は work/ の一時物。requirements / traceability / trace / distill-req を削除し、spec / plan / spec-close を配置。"
}
else {
    Write-Host "[sdd=full] 要求(REQ)を恒久化(実装後に蒸留)。"
}

# --- 3. PM: マーカーへ差分を挿入(-PM) / 除去(既定) ---
$markers = @{
    'pm:readme-lifespan'    = 'docs/README.md'
    'pm:guide-claude'       = 'README.md'
    'pm:workflow-iteration' = 'docs/guides/workflow.md'
    'pm:agents'             = 'AGENTS.md'
}
$pmCopy = @('docs/pm', '.claude/commands/pm-plan.md', '.claude/commands/pm-status.md', '.claude/agents/pm.md')
$insertDir = Join-Path $root '.setup/pm'

foreach ($m in $markers.Keys) {
    $file = Join-Path $root $markers[$m]
    if (-not (Test-Path $file)) { continue }
    $token = "<!-- $m -->"
    $text = Get-Content -Raw $file
    if ($PM) {
        $snippet = (Get-Content -Raw (Join-Path $insertDir (($m -replace '^pm:', '') + '.md'))).TrimEnd("`r", "`n")
        $text = $text.Replace($token, $snippet)
    }
    else {
        $text = $text -replace "(\r?\n)?[ \t]*$([regex]::Escape($token))", ''
    }
    Set-Content -NoNewline -Path $file -Value $text
}

if ($PM) {
    Write-Host "[PM=on] pm-plan / pm-status / pm エージェント / docs/pm を採用。差分を挿入。"
}
else {
    foreach ($p in $pmCopy) { Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $root $p) }
    Write-Host "[PM=off] PM 関連ファイルとマーカーを削除。"
}

# --- 4. セットアップ用ステージング(.setup)を削除 ---
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $root '.setup')

Write-Host ""
Write-Host "次の手順:"
Write-Host " 1. AGENTS.md の『スタック』節を $Form 用に記入。"
Write-Host " 2. LINT/ビルド設定は superset(Settings.XamlStyler は XAML 系 = MAUI/Desktop 用)。実プロジェクトのテンプレで置換してよい。"
Write-Host " 3. docs/architecture/README.md 等の未採用形態の記述は削ってよい。web で Blazor を使わない(API のみ)場合は docs/architecture/blazor.md と .claude/skills/blazor-playwright/ も削除。"
Write-Host " 4. 始め方・使い方は README.md(入口。導入後は自プロジェクトの README に置換/削除可)。回し方の正は docs/guides/workflow.md、契約は docs/README.md。"
