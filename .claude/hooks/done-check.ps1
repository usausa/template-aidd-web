# Stop フック(応答完了時)
# DoD を軽くリマインドするだけの非ブロッキングフック。フルな判定は `/done` コマンドが行う。
# うるさければ .claude/settings.json の Stop フックを外してよい。

try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
Write-Output "―― DoD リマインド ――"
Write-Output "コード変更を伴ったなら: (1) /verify で build+test 緑  (2) 影響 docs 更新・REQ 蒸留  (3) 決定は /adr  (4) /trace 整合(退役漏れ含む)  → 仕上げに /done"
exit 0
