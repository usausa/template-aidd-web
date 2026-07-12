# setup.ps1 の回帰テスト(テンプレ保守用・原本専用)
# 使い方: pwsh .setup/maintenance/test-setup.ps1
# リポジトリを一時ディレクトリへコピーし、form × SDD レベル(lite|full|full-pm)の各シナリオで
# マーカー解決・ファイル配置/削除・保守痕跡ゼロ・旧名称残存ゼロを検証する。ALL PASS が保守の完了条件。

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
    # setup 後に残ってはいけない痕跡: 未解決マーカー(sdd ブロック・pm)+ 保守ブロック
    (Get-ChildItem $dir -Recurse -File -Include *.md -Force | Select-String -Pattern '<!-- (sdd|pm|template-dev)' | Measure-Object).Count
}
function OldNameCount($dir) {
    # 旧名称の残存(リファクタで全廃したもの)
    (Get-ChildItem $dir -Recurse -File -Include *.md, *.ps1 -Force |
        Select-String -Pattern 'distill-req|write-adr|spec-sync|cross-review|/requirements|docs/requirements|REQ-' |
        Measure-Object).Count
}

# --- T1: web + full-pm(全部載せ)---
Write-Host "== T1: -Form web -Sdd full-pm =="
$t = Fresh 't1-web-full-pm'
& (Join-Path $t 'setup.ps1') -Form web -Sdd full-pm | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T1 マーカー/保守ブロック残存 0'
Check ((OldNameCount $t) -eq 0) 'T1 旧名称残存 0'
Check (Test-Path "$t\docs\architecture\web.md") 'T1 web.md 残存'
Check ((Get-Content -Raw "$t\.claude\commands\spec.md").Contains('docs/spec/')) 'T1 spec command=恒久版'
Check ((Get-Content -Raw "$t\.claude\skills\spec-close\SKILL.md").Contains('蒸留して残す')) 'T1 spec-close=残す版'
Check (Test-Path "$t\.claude\commands\plan.md") 'T1 plan command'
Check (Test-Path "$t\.claude\commands\impl.md") 'T1 impl command'
Check (Test-Path "$t\.claude\commands\reference.md") 'T1 reference command'
Check (Test-Path "$t\.claude\commands\review-cross.md") 'T1 review-cross command'
Check (Test-Path "$t\.claude\commands\trace.md") 'T1 trace command (full)'
Check (Test-Path "$t\.claude\skills\adr-guide\SKILL.md") 'T1 adr-guide skill'
Check (Test-Path "$t\docs\spec\_template.md") 'T1 docs/spec 追加'
Check (Test-Path "$t\docs\traceability\index.md") 'T1 traceability 追加'
Check ((Get-Content -Raw "$t\work\README.md").Contains('PLAN')) 'T1 work/ 残存 (full 版)'
Check (-not ((Get-Content -Raw "$t\work\README.md").Contains('SPEC-'))) 'T1 work/README に SPEC なし (full 版)'
Check ((Get-Content -Raw "$t\docs\guides\workflow.md").Contains('/trace')) 'T1 workflow=full 版'
Check ((Get-Content -Raw "$t\.claude\commands\done.md").Contains('/trace')) 'T1 done=full 版'
Check ((Get-Content -Raw "$t\AGENTS.md").Contains('SPEC は蒸留して残す')) 'T1 AGENTS=full 規律'
Check (Test-Path "$t\docs\pm\README.md") 'T1 PM 採用'
Check ((Get-Content -Raw "$t\docs\guides\workflow.md").Contains('イテレーション運用')) 'T1 workflow に PM 挿入'
Check (-not (Test-Path "$t\.setup")) 'T1 .setup 削除 (maintenance 含む)'
Check (-not ((Get-Content -Raw "$t\README.md").Contains('MAINTENANCE'))) 'T1 README に保守節なし'
Check ((Get-Content -Raw "$t\.gitignore").Contains('work/*')) 'T1 gitignore に work/'

# --- T2: web + lite(基層のまま)---
Write-Host "== T2: -Form web -Sdd lite =="
$t = Fresh 't2-web-lite'
& (Join-Path $t 'setup.ps1') -Form web -Sdd lite | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T2 マーカー/保守ブロック残存 0'
Check ((OldNameCount $t) -eq 0) 'T2 旧名称残存 0'
Check ((Get-Content -Raw "$t\.claude\commands\spec.md").Contains('work/SPEC')) 'T2 spec command=一時版'
Check ((Get-Content -Raw "$t\.claude\skills\spec-close\SKILL.md").Contains('削除する手順')) 'T2 spec-close=削除版'
Check (Test-Path "$t\.claude\commands\plan.md") 'T2 plan command'
Check (Test-Path "$t\.claude\commands\impl.md") 'T2 impl command'
Check ((Get-Content -Raw "$t\work\README.md").Contains('SPEC-')) 'T2 work/README=lite 版'
Check (-not (Test-Path "$t\docs\spec")) 'T2 docs/spec 無し'
Check (-not (Test-Path "$t\docs\traceability")) 'T2 traceability 無し'
Check (-not (Test-Path "$t\.claude\commands\trace.md")) 'T2 trace command 無し'
Check ((Get-Content -Raw "$t\AGENTS.md").Contains('クローズ蒸留')) 'T2 AGENTS=lite 規律'
Check ((Get-Content -Raw "$t\.claude\commands\done.md").Contains('クローズ蒸留')) 'T2 done=lite 版'
Check ((Get-Content -Raw "$t\docs\guides\workflow.md").Contains('SDD lite')) 'T2 workflow=lite 版'
Check (-not (Test-Path "$t\docs\pm")) 'T2 PM 無し'
Check ((Get-Content -Raw "$t\.gitignore").Contains('work/*')) 'T2 gitignore に work/'

# --- T3: maui + full(既定 = -Sdd 省略)---
Write-Host "== T3: -Form maui (既定 full) =="
$t = Fresh 't3-maui-default'
& (Join-Path $t 'setup.ps1') -Form maui | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T3 マーカー/保守ブロック残存 0'
Check ((OldNameCount $t) -eq 0) 'T3 旧名称残存 0'
Check (Test-Path "$t\docs\architecture\mvvm.md") 'T3 mvvm.md 残存'
Check (Test-Path "$t\docs\architecture\maui.md") 'T3 maui.md 残存'
Check (-not (Test-Path "$t\docs\architecture\web.md")) 'T3 web.md 削除'
Check (-not (Test-Path "$t\.claude\skills\blazor-playwright")) 'T3 blazor-playwright 削除'
Check (Test-Path "$t\docs\spec\_template.md") 'T3 既定=full (docs/spec あり)'
Check (-not (Test-Path "$t\docs\pm")) 'T3 既定=full (PM なし)'

# --- T4: desktop + lite ---
Write-Host "== T4: -Form desktop -Sdd lite =="
$t = Fresh 't4-desktop-lite'
& (Join-Path $t 'setup.ps1') -Form desktop -Sdd lite | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T4 マーカー/保守ブロック残存 0'
Check ((OldNameCount $t) -eq 0) 'T4 旧名称残存 0'
Check (Test-Path "$t\docs\architecture\mvvm.md") 'T4 mvvm.md 残存'
Check (Test-Path "$t\docs\architecture\wpf.md") 'T4 wpf.md 残存'
Check (-not (Test-Path "$t\docs\architecture\maui.md")) 'T4 maui.md 削除'
Check (-not (Test-Path "$t\docs\spec")) 'T4 docs/spec 無し (lite)'
Check (-not (Test-Path "$t\.claude\skills\blazor-playwright")) 'T4 blazor-playwright 削除'

# --- T5: worker + full ---
Write-Host "== T5: -Form worker -Sdd full =="
$t = Fresh 't5-worker-full'
& (Join-Path $t 'setup.ps1') -Form worker -Sdd full | Out-Null
Check ((LeftoverCount $t) -eq 0) 'T5 マーカー/保守ブロック残存 0'
Check ((OldNameCount $t) -eq 0) 'T5 旧名称残存 0'
Check (Test-Path "$t\docs\architecture\worker.md") 'T5 worker.md 残存'
Check (-not (Test-Path "$t\docs\architecture\mvvm.md")) 'T5 mvvm.md 削除'
Check (Test-Path "$t\docs\spec\_template.md") 'T5 docs/spec 追加 (full)'
Check (-not (Test-Path "$t\docs\pm")) 'T5 PM 無し (full)'

# --- T6: 旧 -PM スイッチは存在しない ---
Write-Host "== T6: -PM => パラメータエラー =="
$t = Fresh 't6-no-pm-switch'
$threw = $false
try { & (Join-Path $t 'setup.ps1') -Form web -PM 2>$null | Out-Null } catch { $threw = $true }
Check $threw 'T6 -PM は受け付けない'

# --- T7: -Sdd の無効値は構文的に弾かれる ---
Write-Host "== T7: -Sdd lite-pm => ValidateSet エラー =="
$t = Fresh 't7-invalid-sdd'
$threw = $false
try { & (Join-Path $t 'setup.ps1') -Form web -Sdd lite-pm 2>$null | Out-Null } catch { $threw = $true }
Check $threw 'T7 無効な -Sdd 値は弾かれる'

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
