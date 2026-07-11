# setup.ps1 の回帰テスト(テンプレ保守用・原本専用)
# 使い方: pwsh .setup/maintenance/test-setup.ps1
# リポジトリを一時ディレクトリへコピーし、form × SDD × PM の各シナリオで
# マーカー解決・ファイル配置/削除・保守痕跡ゼロを検証する。ALL PASS が保守の完了条件。

$ErrorActionPreference = 'Stop'
$src = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$pad = Join-Path ([System.IO.Path]::GetTempPath()) 'template-aidd-tests'
New-Item -ItemType Directory -Force -Path $pad | Out-Null
$fails = @()

function Check($cond, $msg) {
    if ($cond) { Write-Host "  PASS: $msg" } else { Write-Host "  FAIL: $msg" -ForegroundColor Red; $script:fails += $msg }
}
function Fresh($name) {
    $dst = Join-Path $pad $name
    if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
    Copy-Item -Recurse $src $dst
    Remove-Item -Recurse -Force (Join-Path $dst '.git') -ErrorAction SilentlyContinue
    return $dst
}
function LeftoverCount($dir) {
    # setup 後に残ってはいけない痕跡: 未解決マーカー + 保守ブロック
    (Get-ChildItem $dir -Recurse -File -Include *.md -Force | Select-String -Pattern '<!-- (sdd|pm|template-dev)' | Measure-Object).Count
}

# --- T1: web + full + PM ---
Write-Host "== T1: -Form web -Sdd full -PM =="
$t = Fresh 't1-web-full-pm'
& (Join-Path $t 'setup.ps1') -Form web -PM | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T1 マーカー/保守ブロック残存 0'
Check (Test-Path "$t\docs\architecture\web.md") 'T1 web.md 残存'
Check (Test-Path "$t\docs\architecture\api.md") 'T1 api.md 残存'
Check (Test-Path "$t\docs\architecture\blazor.md") 'T1 blazor.md 残存'
Check (-not (Test-Path "$t\docs\architecture\mvvm.md")) 'T1 mvvm.md 削除'
Check (-not (Test-Path "$t\docs\architecture\maui.md")) 'T1 maui.md 削除'
Check (-not (Test-Path "$t\docs\architecture\desktop.md")) 'T1 desktop.md 削除'
Check (-not (Test-Path "$t\docs\architecture\wpf.md")) 'T1 wpf.md 削除'
Check (Test-Path "$t\.claude\skills\blazor-playwright\SKILL.md") 'T1 blazor-playwright 残存'
Check (Test-Path "$t\docs\requirements\_template.md") 'T1 requirements 残存'
Check (Test-Path "$t\docs\pm\README.md") 'T1 PM 採用'
Check (-not (Test-Path "$t\.setup")) 'T1 .setup 削除 (maintenance 含む)'
Check ((Get-Content -Raw "$t\AGENTS.md").Contains('REQ は蒸留して残す')) 'T1 AGENTS=full 規律'
Check (-not ((Get-Content -Raw "$t\README.md").Contains('MAINTENANCE'))) 'T1 README に保守節なし'

# --- T2: web + lite ---
Write-Host "== T2: -Form web -Sdd lite =="
$t = Fresh 't2-web-lite'
& (Join-Path $t 'setup.ps1') -Form web -Sdd lite | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T2 マーカー/保守ブロック残存 0'
Check (Test-Path "$t\work\README.md") 'T2 work/README 配置'
Check (Test-Path "$t\.claude\commands\spec.md") 'T2 spec command 配置'
Check (Test-Path "$t\.claude\commands\plan.md") 'T2 plan command 配置'
Check (Test-Path "$t\.claude\skills\spec-close\SKILL.md") 'T2 spec-close 配置'
Check (-not (Test-Path "$t\docs\requirements")) 'T2 requirements 削除'
Check (-not (Test-Path "$t\docs\traceability")) 'T2 traceability 削除'
Check (-not (Test-Path "$t\.claude\skills\distill-req")) 'T2 distill-req 削除'
Check ((Get-Content -Raw "$t\AGENTS.md").Contains('クローズ蒸留')) 'T2 AGENTS=lite 規律'
Check ((Get-Content -Raw "$t\.claude\commands\done.md").Contains('クローズ蒸留')) 'T2 done=lite'
Check ((Get-Content -Raw "$t\docs\guides\workflow.md").Contains('SDD lite')) 'T2 workflow=lite'
Check ((Get-Content -Raw "$t\.gitignore").Contains('work/*')) 'T2 gitignore に work/'

# --- T3: maui + full ---
Write-Host "== T3: -Form maui =="
$t = Fresh 't3-maui-full'
& (Join-Path $t 'setup.ps1') -Form maui | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T3 マーカー/保守ブロック残存 0'
Check (Test-Path "$t\docs\architecture\mvvm.md") 'T3 mvvm.md 残存'
Check (Test-Path "$t\docs\architecture\maui.md") 'T3 maui.md 残存'
Check (-not (Test-Path "$t\docs\architecture\web.md")) 'T3 web.md 削除'
Check (-not (Test-Path "$t\docs\architecture\desktop.md")) 'T3 desktop.md 削除'
Check (-not (Test-Path "$t\.claude\skills\blazor-playwright")) 'T3 blazor-playwright 削除'

# --- T4: desktop + full ---
Write-Host "== T4: -Form desktop =="
$t = Fresh 't4-desktop-full'
& (Join-Path $t 'setup.ps1') -Form desktop | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T4 マーカー/保守ブロック残存 0'
Check (Test-Path "$t\docs\architecture\mvvm.md") 'T4 mvvm.md 残存'
Check (Test-Path "$t\docs\architecture\desktop.md") 'T4 desktop.md 残存'
Check (Test-Path "$t\docs\architecture\wpf.md") 'T4 wpf.md 残存'
Check (-not (Test-Path "$t\docs\architecture\maui.md")) 'T4 maui.md 削除'
Check (-not (Test-Path "$t\docs\architecture\api.md")) 'T4 api.md 削除'
Check (-not (Test-Path "$t\.claude\skills\blazor-playwright")) 'T4 blazor-playwright 削除'
Check (Test-Path "$t\docs\requirements\_template.md") 'T4 requirements 残存 (full)'

# --- T6: worker + full ---
Write-Host "== T6: -Form worker =="
$t = Fresh 't6-worker-full'
& (Join-Path $t 'setup.ps1') -Form worker | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T6 マーカー/保守ブロック残存 0'
Check (Test-Path "$t\docs\architecture\worker.md") 'T6 worker.md 残存'
Check (-not (Test-Path "$t\docs\architecture\mvvm.md")) 'T6 mvvm.md 削除'
Check (-not (Test-Path "$t\docs\architecture\web.md")) 'T6 web.md 削除'
Check (-not (Test-Path "$t\docs\architecture\api.md")) 'T6 api.md 削除'
Check (-not (Test-Path "$t\docs\architecture\desktop.md")) 'T6 desktop.md 削除'
Check (-not (Test-Path "$t\.claude\skills\blazor-playwright")) 'T6 blazor-playwright 削除'
Check (Test-Path "$t\docs\requirements\_template.md") 'T6 requirements 残存 (full)'

# --- T5: lite + PM はエラー ---
Write-Host "== T5: -Sdd lite -PM => error =="
$t = Fresh 't5-lite-pm'
$threw = $false
try { & (Join-Path $t 'setup.ps1') -Form web -Sdd lite -PM | Out-Null } catch { $threw = $true }
Check $threw 'T5 lite+PM でエラー'

Write-Host ""
if ($fails.Count -eq 0) {
    Write-Host "ALL PASS"
    Remove-Item -Recurse -Force $pad -ErrorAction SilentlyContinue   # 成功時は一時ディレクトリを掃除
} else {
    Write-Host "FAILURES: $($fails.Count)" -ForegroundColor Red
    $fails | ForEach-Object { Write-Host " - $_" }
    Write-Host "検証コピーは $pad に残置 (調査用)"
    exit 1
}
