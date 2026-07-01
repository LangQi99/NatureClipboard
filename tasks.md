# NatureClipboard Tasks

> 每完成一个 task 就 commit + push。commit 前必须 review（`git diff --staged`）。新功能先写单元测试（TDD 红→绿→重构）。

## 状态说明

- `[ ]` 未开始
- `[~]` 进行中
- `[x]` 完成
- 每个 task 标注：类型（feat/fix/refactor/test/docs）· 分层（unit/integration/snapshot） · 是否需 TDD

## P0 — 阻塞用户的问题

### T-001 修复搜索框聚焦时上下键无法切换列表 · fix · unit+integration · TDD  ✅ 完成 (2026-07-01)

- 拆出 `Sources/ClipboardManagerKit/KeyRouting.swift`（纯函数 `nextIndex(direction:currentIndex:count:)`）
- 8 个 swift-testing 单元测试全部通过（`swift test`）
- `AppDelegate` 的 `NSEvent.addLocalMonitorForEvents` 走该函数直接读写 `ClipboardStore.shared.currentSelection`，绕开 TextField 焦点吞噬

### T-002 首次运行 Onboarding + 辅助功能权限引导 · feat · integration+unit  ✅ 完成 (2026-07-01)

- Kit 新增 `OnboardingState` + `OnboardingStorage` 协议（依赖注入，可测）
- 3 个 swift-testing 用例：默认未完成、complete 持久化、从 store 恢复
- 新增 `OnboardingView.swift` 3 步：欢迎 → 辅助功能引导（可打开系统设置） → 完成
- `AppDelegate.applicationDidFinishLaunching`：`hasCompleted == false` 时弹 modal 引导；完成后再 setupHotkey + 展示面板
- 验证：`defaults delete com.bytedance.ClipboardManager hasCompletedOnboarding` 后重启触发引导

## P0 — AI 基础设施（多 sub-task，逐个 TDD）

### T-010 数据模型扩展 · feat · unit · TDD  ✅ 完成 (2026-07-01)

- Kit 新增 `AIStatus` enum、`OCRLine` struct、`AIFieldsSnapshot` 向后兼容骨架
- 4 个 swift-testing 用例：默认值 / roundtrip / 未知 aiStatus 回落 none / 空 JSON 缺失字段
- `ClipboardItem` 追加 aiTags / aiSummary / aiModel / aiStatus / ocrText / ocrLines / urlTitle / urlSiteName 字段
- 手写 `init(from decoder:)` 用 `decodeIfPresent`，旧 JSON（无 AI 字段）可正常加载

### T-011 HeuristicTagger · feat · unit · TDD  ✅ 完成 (2026-07-01)

- 纯函数 `HeuristicTagger.tags(forText:)`，覆盖 URL / hex / rgb-hsl / email / error / SQL / JSON / HTML / Swift / Python / 长文本
- 17 个 swift-testing 用例全绿
- 未接入 pipeline（等 T-010 数据模型扩展后再写回 item）

### T-012 搜索命中高亮（文本） · feat · unit · TDD  ✅ 完成 (2026-07-01)

- 纯函数 `Highlighter.matches(text:query:)` 返回大小写不敏感、多关键词、非重叠的 `Range<String.Index>` 数组
- 9 个 swift-testing 用例（emoji/中文/多term/边界）全绿
- App 层 helper `highlighted(_:query:color:)` 用 ranges 构造 `AttributedString`（背景色 + 下划线）
- 接入 `ItemRowView` 标题 + `PreviewPanelView` 文本正文

### T-013 ClipboardMonitor 智能降频 · feat · unit · TDD  ✅ 完成 (2026-07-01)

- 新增 `Sources/ClipboardManagerKit/MonitorFrequency.swift`：`public enum MonitorFrequency` + 纯静态函数 `recommendedInterval(foreground:lowPowerMode:batteryLevel:)`
- 规则：lowPower 或电量 <0.2 → 2.0s；后台 → 1.5s；前台 → 0.5s；优先级 lowPower/lowBattery > 后台 > 前台
- 7 个 swift-testing 用例全绿（前台插电 / 前台无电量 / 后台 / lowPower / 电量 0.15 / 电量 0.20 边界 / 后台+lowPower 优先级）
- 尚未接入 `ClipboardMonitor` 的 workspace/battery/lowpower 通知（Kit 层先落地，App 层订阅后续 task）

### T-014 AI Tab 设置页（骨架） · feat · integration

- 新增 `Sources/Settings/AISettingsView.swift`
- 字段：总开关、Provider 下拉、Base URL、API Key（脱敏）、Model、Timeout、Feature 开关、Trigger、Rate limit、Test connection 按钮
- 存储：非敏感项 UserDefaults；`apiKey` → Keychain（用 `Sources/Core/Keychain.swift` 简单封装）
- 首次开启弹强确认弹窗
- **测试**：`Tests/AITests/AISettingsPersistenceTests.swift` 读写往返

### T-015 启发式 AI 打标接入 pipeline · feat · integration · TDD  ✅ 完成 (2026-07-01)

- 新增 `Sources/ClipboardManagerKit/AIPipeline.swift`：`AIPipeline.heuristicTag(text:) -> (tags, status)` 纯函数，非空 tags 时 status=.done，空则 .none
- 3 个 swift-testing 用例（URL / 普通短单词 / SQL）全绿
- `ClipboardStore.addItem` 只在新增分支（非命中去重）里，对 text/html/rtf/url 且 textContent 非空的 item 调用 pipeline 并写回 aiTags/aiStatus 后再插入
- 目前只跑 HeuristicTagger；LLM/异步 pipeline 留给后续 task

## P1 — LLM 打标 + Ask AI + FTS5

### T-020 LLMClient + Provider 抽象 · feat · unit · TDD
### T-021 结构化 JSON 输出解析 · feat · unit · TDD
### T-022 Rate limit 令牌桶 + 队列持久化 · feat · unit · TDD
### T-023 SQLite FTS5 索引 · feat · integration · TDD
### T-024 意图抽取器 IntentExtractor · feat · unit · TDD
### T-025 Ask AI QuickAction UI + 流式渲染 · feat · integration
### T-026 兜底 UI badge（3 种路径） · feat · integration

## P1 — 无障碍 & 快捷键设置

### T-030 自定义快捷键设置 UI + KeyRecorder · feat
### T-031 VoiceOver labels 全面覆盖 · feat · unit（label 断言）
### T-032 Reduce Motion / Increase Contrast 支持 · feat

## P2

### T-040 收藏夹分组 / Tag 管理 UI
### T-041 MCP Server（参考 Paste）

## P3

### T-050 打包 .app + notarize
### T-051 多语言支持
### T-052 上下键鼠标光标消失评估
