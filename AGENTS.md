# AGENTS.md — NatureClipboard 项目工作规范

> 任何 coding agent 在此仓库执行任务前必须完整阅读本文件。

## 1. 项目基本

- 名称：NatureClipboard
- 定位：macOS 原生 Raycast 风格剪贴板管理器 + Nature 视觉主题
- 语言 / 框架：Swift 5.9、SwiftUI、AppKit（NSPanel）、CGEventTap
- 最低系统：macOS 14
- 构建：Swift Package Manager（`swift build`、`swift run`、`swift test`）
- 依赖策略：v3 起允许合理第三方（swift-snapshot-testing、Keychain wrapper、OpenAI 兼容 SDK）；引入前 PR 说明必要性

## 2. 文件结构

```
NatureClipboard/
├─ Package.swift
├─ prd.md                        # 产品需求（v3.1）
├─ tasks.md                      # 可执行任务清单
├─ process.md                    # 更新日志
├─ AGENTS.md                     # ← 本文件
├─ LICENSE                       # AGPL-3.0 + 非商用附加条款
├─ ClipboardManager/             # 主 target 源码（当前扁平结构，后续按 Sources/ 分层重构）
│   ├─ App.swift                 SwiftUI @main
│   ├─ AppDelegate.swift         NSPanel + 全局热键 (CGEventTap) + 键盘路由
│   ├─ ClipboardMonitor.swift    Pasteboard 轮询 + 类型识别
│   ├─ ClipboardStore.swift      单例数据源
│   ├─ Models.swift              ClipboardItem / Snippet / Category
│   ├─ MainView.swift            根视图 + NatureBackground + SplitterHandle
│   ├─ SearchBarView.swift       搜索栏 + WindowDragView + ThemeSwitcher
│   ├─ CategoryBarView*.swift    Category 胶囊条
│   ├─ ItemListView.swift        列表 + 行 + 拖动 + 右键菜单
│   ├─ PreviewPanelView.swift    右侧预览（含 Raycast Information 区块）
│   ├─ BottomBarView.swift       底栏
│   ├─ QuickActionsView.swift    命令面板
│   ├─ SnippetsView.swift        Snippets 管理
│   ├─ SettingsView.swift        设置多 Tab
│   ├─ SettingsManager.swift     UserDefaults 封装
│   ├─ ThemeManager.swift        Nature / Liquid Glass 主题
│   └─ TextTransformations.swift 22 种文本变换
└─ Tests/                        # 计划新增；分层：AITests / SearchTests / CoreTests / SnapshotTests / IntegrationTests
```

## 3. 外部文件索引

| 文件 | 用途 |
|------|------|
| `prd.md` | 产品需求文档（v3.1）—— 唯一真相源 |
| `tasks.md` | 拆分的可执行任务清单 |
| `process.md` | 每完成一个 task 追加一条 changelog |
| `LICENSE` | AGPL-3.0 + 非商用附加条款 |

## 4. 工作规则（红线）

### 4.1 每次开始任务前必须

1. 读 `prd.md`（至少扫相关章节）+ `tasks.md`（找到当前 task 编号）
2. 用 `/plan` 或思考步骤提出方案，等用户确认后再动代码
3. 单个 task 只做一个小功能，不要顺手改无关代码

### 4.2 编码期间必须

1. **新功能先写测试**（TDD 红→绿→重构）；UI-only 变更走 Snapshot Test
2. 测试命名：`test_<method>_<scenario>_<expected>()`，结构 Given-When-Then
3. 严禁在测试文件之外硬编码 API Key / Base URL 等敏感信息
4. 保持代码风格：不加冗余注释；命名清晰；避免过度抽象

### 4.3 完成任务后必须

1. 运行 `swift test`，全绿再往下走
2. `git diff --staged` 自检；或用另一个 agent（Codex/Cursor）review 一遍
3. **一个小功能 = 一个 commit + 一次 push**，commit message 简洁描述做了什么
4. 更新 `process.md` 追加一行 changelog：`YYYY-MM-DD [T-xxx] 简述`
5. 更新 `tasks.md` 里对应 task 的状态标记为 `[x]`
6. 如新增/移动/删除文件，同步更新本 AGENTS.md 的文件结构

### 4.4 Commit 前 Review（不可跳过）

- 个人项目最低要求：`git diff --staged` 亲自过一遍
- 更佳：起一个新 agent 实例做 uncommitted changes review
- **禁止 "写完直接 push"**

### 4.5 分支与推送

- 目前使用 main 直接推（个人项目）；引入协作后切换 PR + review + branch protection
- push 前必须构建通过 (`swift build`)

## 5. 领域约定

### 5.1 数据流

`ClipboardMonitor` (轮询) → `ClipboardStore.addItem(item)` (去重 + 持久化 JSON) → SwiftUI `@Published items` → 视图订阅

### 5.2 焦点交接

面板呼出前 `previousApp = NSWorkspace.shared.frontmostApplication`；粘贴时先 `panel.orderOut(nil)` → `previousApp.activate(options: [])` → 延时 0.05s → 模拟 `⌘V` (`CGEvent .cghidEventTap`)

### 5.3 全局键盘

- 全局热键：`CGEventTap` @ `.cgSessionEventTap` 拦截 `⌘E`
- 面板内键盘：`NSEvent.addLocalMonitorForEvents` 拦截 up/down/return/esc，直接读写 `ClipboardStore.shared.currentSelection`（不依赖 View 闭包）

### 5.4 隐私红线（v3）

- AI 总开关关闭时 App 绝不发起任何网络请求（Charles/Little Snitch 可验证）
- API Key 只落 macOS Keychain
- **不做 secret 脱敏承诺**（v3 已下架该功能）；首次开启 AI 用强确认弹窗把边界给用户
- OCR 默认走本地 Vision，图片不外发；LLM Vision Fallback 需用户显式开启

### 5.5 主题

- Nature 主题：`TimelineView(.animation)` 时间驱动，主题切换/面板重开动画不重播（`startTime` 用 `static`）
- 主题色暴露在 `ThemeColors`：`accent` / `textPrimary` / `pillSelectedBackground` 等

## 6. 常用命令

```bash
# 构建 + 运行
cd ~/Desktop/ClipboardManager && swift build && .build/debug/ClipboardManager

# 测试
swift test

# 强制重启
kill $(ps aux | grep "[C]lipboardManager" | awk '{print $2}') 2>/dev/null; .build/debug/ClipboardManager &

# 清空 onboarding 状态（测试用）
defaults delete com.bytedance.ClipboardManager hasCompletedOnboarding

# 查看 changelog
tail -20 process.md
```

## 7. 依赖新增流程

1. 在 tasks.md 对应 task 里说明必要性、许可证（要求兼容 AGPL）、维护活跃度（近半年有提交）
2. 修改 `Package.swift`
3. 执行 `swift package resolve` 后 push `Package.resolved`
4. 更新本 AGENTS.md 依赖列表段

## 8. 未来结构调整

当前源码扁平，后续按 v3 PRD §5.2 重构为 `Sources/{App,AI,Search,Core,UI,Settings}/`。重构本身是独立 task（不与功能开发混）。

## 9. AI 助手互动约定

- 可直接执行：读文件、写测试、写实现、构建、运行 `swift test`、`git diff`
- 需用户确认：`git push`、修改 `LICENSE`、修改 `prd.md`、新增第三方依赖、重构目录结构、卸载已发布的功能
- 遇到系统权限相关问题（辅助功能、Keychain）先告知用户，不自行破坏其配置
