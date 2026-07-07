@AGENTS.md

# Claude Code 固有メモ

- ルールの正は `AGENTS.md`(上で import 済み。Codex 等とも共有できる seam)。
- 詳細な手順は `.claude/skills/` にスキルとして分離。**必要時に自動ロード**されるので常時読み込まない(コンテキスト節約)。
- 文書の“正”は `docs/README.md` の寿命クラス表(まずそこを見る)。
- 迷ったら `docs/architecture/` の原則に従う。**決定を伴うなら `/adr`、完了前に `/done`**。
- `docs/reference/**` は生成物。**手編集しない**(`.claude/settings.json` の deny で禁止済み)。
