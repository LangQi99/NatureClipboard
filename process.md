# process.md — NatureClipboard Changelog

> 每完成一个 task 追加一行：`YYYY-MM-DD [T-xxx] 简述`

## 2026-07-01

- [docs] 引入 v3.1 PRD 覆盖旧 prd.md；新增 tasks.md、AGENTS.md、process.md，建立工程纪律
- [fix] T-001 修复搜索框聚焦时上下键失效：拆出 `KeyRouting` 纯函数 + swift-testing 8 用例；`AppDelegate` local monitor 直接改写 `store.currentSelection`
- [feat] T-011 HeuristicTagger 纯函数落地：URL/hex/color/email/error/SQL/JSON/HTML/Swift/Python/长文本 17 个用例 TDD 绿
- [feat] T-012 搜索命中高亮：`Highlighter.matches` 纯函数 + 9 用例 TDD；`ItemRowView` 标题 & `PreviewPanel` 正文接入 AttributedString 背景色+下划线
- [feat] T-013 ClipboardMonitor 智能降频：`MonitorFrequency.recommendedInterval` 纯静态函数（lowPower/低电量 2.0s > 后台 1.5s > 前台 0.5s，0.20 电量边界视为正常），7 个 swift-testing 用例 TDD 绿
- [feat] T-010 数据模型扩展：Kit 侧新增 AIStatus / OCRLine / AIFieldsSnapshot + 4 用例 TDD；`ClipboardItem` 添加 AI 字段并自写 decoder 保证旧 JSON 兼容
- [perf] T-013 MonitorFrequency 纯函数 + 7 用例：前台 0.5s / 后台 1.5s / lowPower 或电量<20% 2s
