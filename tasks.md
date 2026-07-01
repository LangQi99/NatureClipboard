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

### T-002 首次运行 Onboarding + 辅助功能权限引导 · feat · integration+snapshot

- **背景**：v3 PRD §8 P0 第 2 条 + §9 P0
- **测试**：
  - `Tests/CoreTests/OnboardingStateTests.swift` 断言 `SettingsManager.hasCompletedOnboarding` 默认 false、`completeOnboarding()` 后为 true 并持久化
  - `Tests/SnapshotTests/OnboardingSnapshotTests.swift`（引入 swift-snapshot-testing 时补，本 task 只搭结构）
- **实现**：
  - `SettingsManager` 增加 `hasCompletedOnboarding` UserDefaults 项
  - 新增 `OnboardingView.swift`：3 步引导（欢迎 → 授权辅助功能 → 完成）
  - App 启动时若未完成，展示 modal onboarding；用户点击 "Open System Settings" 打开辅助功能面板
  - AI 首次开启弹窗（PRD §4.10）在 Settings AI Tab 内做（P0 的 AI Tab task 里再补）
- **验证**：`defaults delete com.bytedance.ClipboardManager hasCompletedOnboarding` 后重启会看到引导

## P0 — AI 基础设施（多 sub-task，逐个 TDD）

### T-010 数据模型扩展 · feat · unit · TDD

- 在 `Models.swift` 的 `ClipboardItem` 追加：`aiTags: [String]`、`aiSummary: String?`、`aiModel: String?`、`aiStatus: AIStatus`、`ocrText: String?`、`ocrLines: [OCRLine]?`、`urlTitle: String?`、`urlSiteName: String?`（默认值确保旧 JSON 反序列化兼容）
- 新增 enum `AIStatus { case none, queued, running, done, failed }` + `struct OCRLine { rect: CGRect, text: String }`
- **测试**：`Tests/CoreTests/ModelsCompatibilityTests.swift` 加载 v1 JSON（不含 AI 字段）应成功、字段回填默认值

### T-011 HeuristicTagger · feat · unit · TDD  ✅ 完成 (2026-07-01)

- 纯函数 `HeuristicTagger.tags(forText:)`，覆盖 URL / hex / rgb-hsl / email / error / SQL / JSON / HTML / Swift / Python / 长文本
- 17 个 swift-testing 用例全绿
- 未接入 pipeline（等 T-010 数据模型扩展后再写回 item）

### T-012 搜索命中高亮（文本） · feat · unit · TDD

- 新增 `Sources/Search/Highlighter.swift`：`func highlight(text: String, query: String) -> AttributedString`
- 规则：大小写不敏感、多关键词空格分隔、命中处添加 `.backgroundColor = theme.accent.opacity(0.35)` + `.underlineStyle = .single`
- **测试**：`Tests/SearchTests/HighlighterTests.swift`
- 在 `ItemRowView.displayTitle` 和 `PreviewPanelView` 文本渲染处替换为 `AttributedString`

### T-013 ClipboardMonitor 智能降频 · feat · unit · TDD

- §4.1 v3 追加：app 失焦 1.5s / low power 2s / 电量 <20% 2s / 前台+插电 0.5s
- 新增 `Sources/Core/MonitorFrequency.swift`：纯函数 `func recommendedInterval(...) -> TimeInterval`
- **测试**：`Tests/CoreTests/MonitorFrequencyTests.swift` 4 种场景
- 在 `ClipboardMonitor` 里订阅 workspace/battery/lowpower 通知重设 Timer

### T-014 AI Tab 设置页（骨架） · feat · integration

- 新增 `Sources/Settings/AISettingsView.swift`
- 字段：总开关、Provider 下拉、Base URL、API Key（脱敏）、Model、Timeout、Feature 开关、Trigger、Rate limit、Test connection 按钮
- 存储：非敏感项 UserDefaults；`apiKey` → Keychain（用 `Sources/Core/Keychain.swift` 简单封装）
- 首次开启弹强确认弹窗
- **测试**：`Tests/AITests/AISettingsPersistenceTests.swift` 读写往返

### T-015 启发式 AI 打标接入 pipeline · feat · integration · TDD

- 新增 `Sources/AI/AIPipeline.swift`：`func process(_ item: ClipboardItem) async`
- 目前只跑 HeuristicTagger → 写回 store
- **测试**：`Tests/AITests/AIPipelineTests.swift` 端到端 (mock LLMClient)

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
