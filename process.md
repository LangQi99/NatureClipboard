# process.md — NatureClipboard Changelog

> 每完成一个 task 追加一行：`YYYY-MM-DD [T-xxx] 简述`

## 2026-07-01

- [docs] 引入 v3.1 PRD 覆盖旧 prd.md；新增 tasks.md、AGENTS.md、process.md，建立工程纪律
- [fix] T-001 修复搜索框聚焦时上下键失效：拆出 `KeyRouting` 纯函数 + swift-testing 8 用例；`AppDelegate` local monitor 直接改写 `store.currentSelection`
- [feat] T-011 HeuristicTagger 纯函数落地：URL/hex/color/email/error/SQL/JSON/HTML/Swift/Python/长文本 17 个用例 TDD 绿
