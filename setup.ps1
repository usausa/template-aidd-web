# template-aidd セットアップ: アプリ形態と SDD レベルを選び、テンプレを確定する。
# 使い方:
#   pwsh ./setup.ps1 -Form web                 # Web、SDD full(既定)
#   pwsh ./setup.ps1 -Form desktop -Sdd lite   # デスクトップ、lite(SPEC は work/ の一時物)
#   pwsh ./setup.ps1 -Form maui -Sdd full-pm   # MAUI、full + PM
#
#  - Form: 系(maui / web / desktop / worker)。非採用系の docs/architecture/*.md と形態固有 skill を削除。
#  - Sdd:  SDD レベル(単一の排他選択。lite ⊂ full ⊂ full-pm の加算)。
#          base(このリポジトリの素の状態)= lite。full は `.setup/sdd/full/` のファイル加算
#          (恒久 SPEC・spec-close 残す版・/trace・traceability)と `<!-- sdd:xxx:start/end -->`
#          ブロックの full 版置換。full-pm はさらに PM 層(`.setup/pm/`)を加算する。
#  - LINT/ビルド設定は全形態の superset。触らない(実プロジェクトのテンプレで置換してよい)。
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('maui', 'web', 'desktop', 'worker')]
    [string]$Form,
    [ValidateSet('lite', 'full', 'full-pm')]
    [string]$Sdd = 'full'
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$arch = Join-Path $root 'docs/architecture'
$isFull = $Sdd -ne 'lite'
$isPm = $Sdd -eq 'full-pm'

# --- 1. アプリ形態: 非採用系の architecture doc と形態固有 skill を削除 ---
$formDocs = @{
    maui    = @('mvvm.md', 'maui.md')
    web     = @('web.md', 'api.md', 'blazor.md')
    desktop = @('mvvm.md', 'desktop.md', 'wpf.md', 'winui.md')   # winui.md は将来追加(ファイルを置くだけで採用される)
    worker  = @('worker.md')
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

# --- 2. SDD: base(lite)に full 層を加算、または lite のまま確定 ---
$sddDir = Join-Path $root '.setup/sdd'
$sddFiles = @('AGENTS.md', 'README.md', 'docs/README.md', 'docs/review-checklist.md', '.claude/skills/csharp-layered-feature/SKILL.md')

if ($isFull) {
    # ブロックを full 版へ置換
    foreach ($f in $sddFiles) {
        $file = Join-Path $root $f
        if (-not (Test-Path $file)) { continue }
        $text = Get-Content -Raw $file
        $blockMatches = [regex]::Matches($text, '<!-- sdd:([a-z-]+):start -->')
        foreach ($m in $blockMatches) {
            $name = $m.Groups[1].Value
            $snippet = (Get-Content -Raw (Join-Path $sddDir "$name-full.md")).TrimEnd("`r", "`n")
            $pattern = "(?s)<!-- sdd:$name`:start -->.*?<!-- sdd:$name`:end -->"
            $text = [regex]::Replace($text, $pattern, $snippet.Replace('$', '$$'))
        }
        Set-Content -NoNewline -Path $file -Value $text
    }

    # full 層のファイルを加算(spec / spec-close / done / workflow / work は上書き、trace / docs/spec / traceability は追加)
    $fullDir = Join-Path $sddDir 'full'
    Get-ChildItem -Path $fullDir -Recurse -File -Force | ForEach-Object {
        $rel = $_.FullName.Substring($fullDir.Length + 1)
        $dest = Join-Path $root $rel
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item -Force $_.FullName $dest
    }
    Write-Host "[sdd=$Sdd] full 層を加算: SPEC 恒久化(docs/spec)・spec-close(残す版)・/trace・traceability。"
}
else {
    # lite: ブロックマーカー行のみ除去(lite 本文はインラインのまま残る)
    foreach ($f in $sddFiles) {
        $file = Join-Path $root $f
        if (-not (Test-Path $file)) { continue }
        $text = Get-Content -Raw $file
        $new = $text -replace '(?m)^[ \t]*<!-- sdd:[a-z-]+:(start|end) -->\r?\n?', ''
        if ($new -ne $text) { Set-Content -NoNewline -Path $file -Value $new }
    }
    Write-Host "[sdd=lite] 基層のまま確定: SPEC は work/ の一時物(クローズ蒸留して削除)。"
}

# --- 3. PM 層(full-pm のみ): マーカーへ差分を挿入 / 除去 ---
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
    if ($isPm) {
        $snippet = (Get-Content -Raw (Join-Path $insertDir (($m -replace '^pm:', '') + '.md'))).TrimEnd("`r", "`n")
        $text = $text.Replace($token, $snippet)
    }
    else {
        $text = $text -replace "(\r?\n)?[ \t]*$([regex]::Escape($token))", ''
    }
    Set-Content -NoNewline -Path $file -Value $text
}

if ($isPm) {
    Write-Host "[pm=on] pm-plan / pm-status / pm エージェント / docs/pm を採用。差分を挿入。"
}
else {
    foreach ($p in $pmCopy) { Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $root $p) }
    Write-Host "[pm=off] PM 関連ファイルとマーカーを削除。"
}

# --- 4. テンプレ保守ブロック(原本専用)とセットアップ用ステージング(.setup)を削除 ---
foreach ($f in @('AGENTS.md', 'README.md')) {
    $file = Join-Path $root $f
    if (-not (Test-Path $file)) { continue }
    $text = Get-Content -Raw $file
    $new = $text -replace '(?s)(\r?\n){0,2}<!-- template-dev:start -->.*?<!-- template-dev:end -->', ''
    if ($new -ne $text) { Set-Content -NoNewline -Path $file -Value $new }
}
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $root '.setup')

Write-Host ""
Write-Host "次の手順:"
Write-Host " 1. AGENTS.md の『スタック』節を $Form 用に記入。"
Write-Host " 2. LINT/ビルド設定は superset(Settings.XamlStyler は XAML 系 = MAUI/Desktop 用)。実プロジェクトのテンプレで置換してよい。"
Write-Host " 3. docs/architecture/README.md 等の未採用形態の記述は削ってよい。web で Blazor を使わない(API のみ)場合は docs/architecture/blazor.md と .claude/skills/blazor-playwright/ も削除。"
Write-Host " 4. 始め方・使い方は README.md(入口。導入後は自プロジェクトの README に置換/削除可)。回し方の正は docs/guides/workflow.md、契約は docs/README.md。"
