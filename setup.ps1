# template-aidd セットアップ: アプリ形態(と任意で PM)を選び、テンプレを確定する。
# 使い方:
#   pwsh ./setup.ps1 -Form web            # Web、PM なし
#   pwsh ./setup.ps1 -Form maui -PM       # MAUI + PM(プロジェクト管理)を有効化
#
#  - 採用しない形態の docs/architecture/*.md を削除。
#  - PM: `<!-- pm:xxx -->` マーカーへ pm/inserts/xxx.md を挿入(-PM)、または除去(既定)。
#  - LINT/ビルド設定は全形態の superset。触らない(実プロジェクトのテンプレで置換してよい)。
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('maui', 'web')]
    [string]$Form,
    [switch]$PM
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$arch = Join-Path $root 'docs/architecture'

# --- 1. アプリ形態: 非採用の architecture doc を削除 ---
switch ($Form) {
    'maui' {
        Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $arch 'api.md'), (Join-Path $arch 'blazor.md')
        Write-Host "[form=maui] api.md / blazor.md を削除。maui.md を採用。"
    }
    'web' {
        Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $arch 'maui.md')
        Write-Host "[form=web] maui.md を削除。api.md / blazor.md を採用。"
    }
}

# --- 2. PM: マーカーへ差分を挿入(-PM) / 除去(既定) ---
$markers = @{
    'pm:readme-lifespan'    = 'docs/README.md'
    'pm:guide-claude'       = 'README.md'
    'pm:workflow-iteration' = 'docs/guides/workflow.md'
    'pm:agents'             = 'AGENTS.md'
}
$pmCopy = @('docs/pm', '.claude/commands/pm-plan.md', '.claude/commands/pm-status.md', '.claude/agents/pm.md')
$insertDir = Join-Path $root 'pm/inserts'

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

# --- 3. ステージング(pm/inserts)を削除 ---
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $root 'pm')

Write-Host ""
Write-Host "次の手順:"
Write-Host " 1. AGENTS.md の『スタック』節を $Form 用に記入。"
Write-Host " 2. LINT/ビルド設定は superset(Settings.XamlStyler は MAUI 用)。実プロジェクトのテンプレで置換してよい。"
Write-Host " 3. docs/architecture/README.md 等の未採用形態の記述は削ってよい。"
Write-Host " 4. 始め方・使い方は README.md(入口。導入後は自プロジェクトの README に置換/削除可)。回し方の正は docs/guides/workflow.md、契約は docs/README.md。"
