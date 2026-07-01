# NatureClipboard — Product Requirements Document (v3.1 · Battle-Reviewed)

> 项目仓库：https://github.com/LangQi99/NatureClipboard
> 当前状态：MVP 已完成；v2 引入 AI 智能标签 / OCR 索引 / 搜索高亮；v3 经 Battle Review 修订；**v3.1 进一步收敛 Ask AI 架构（全 LLM 意图抽取路径，兜底必须提示）**

---

## 1. 产品定位

NatureClipboard 是一款 macOS 原生剪贴板管理器，Raycast 风格的浮层交互 + 独有的「清新自然」视觉主题。目标用户是需要频繁复制粘贴、注重效率与视觉舒适感的开发者与知识工作者。

**核心差异化：**

- **两套视觉主题**：默认 Nature（米白底 + 中央树 + 飘落叶子 + 上浮 O₂ 泡）、可选 Liquid Glass（毛玻璃暗色）——情感化差异，市面独一份
- 🔄 **AI 索引默认开箱即用**：默认接入云端 LLM（OpenAI / Anthropic 兼容端点），也支持用户自选本地端点（Ollama / MLX）。首次开启 AI 时**强确认弹窗**，明确告知内容会发送至用户配置的 Provider
- 🔄 **依赖策略务实**：使用成熟第三方库（如 SSE 解析、Keychain 封装、OpenAI SDK）以换取工程效率与稳定性；不把"零依赖"当作差异化承诺

---

## 2. 竞品分析

### 2.1 主要竞品概览

| 竞品 | 定价 | AI 能力 | 核心优势 | 劣势 |
|------|------|---------|----------|------|
| 🔄 **Raycast Clipboard History**（内置） | 免费 + Pro AI 订阅 | ✅ Raycast AI 集成（GPT / Claude 全家桶） | 生态完整、快捷键系统成熟、跨平台扩展 store、月装百万级 | 需要装整个 Raycast；主题固定；剪贴板只是众多功能之一，无深度优化 |
| **Paste** | 订阅制（$3.99/月，含 Setapp） | ✅ Apple Intelligence 集成；✅ MCP Server（2026.06） | iCloud 同步、ML 智能分类、200+ 格式、Pinboard、成熟商业化 | 闭源、订阅、无法自定义 AI Provider |
| **Maccy** | 免费开源（MIT） | ❌ 无 AI | 极致轻量（<20MB）、开源免费、隐私优先（不记录密码管理器）、原生极简 | 无图片预览、无 AI、无同步、功能单一 |
| **Alfred**（Clipboard 模块） | Powerpack £34 买断 | ❌ 无 AI | 老牌、一次买断、workflow 生态强 | UI 陈旧、需搭配主程序 |
| **Pastebot**（Tapbots） | $9.99 买断 | ❌ 无 AI | 精致的原生 UI、Sequential Paste | Mac 单平台、更新缓慢 |
| **CopyClip** | 免费 | ❌ 无 AI | 零配置、菜单栏驻留 | 不支持图片、无高亮、字符串匹配搜索 |
| **CleanClip** | 付费 | ⚠️ 基础分类 | 国产化、中文友好、Paste Queue | 无 LLM、生态较小 |
| **PasteNow.io** | 免费 + Pro | ⚠️ 有基础 AI 总结 | 国产、免费门槛低 | 早期产品、稳定性未验证 |

### 2.2 竞品优势总结

1. **Raycast 的生态碾压**：装机量最大、AI 与 workflow 深度绑定、开发者社区强。**是我们最直接的对手**，不是 Paste。
2. **Paste 的 MCP 生态优势**：率先实现 MCP Server，让剪贴板变成 AI 工具（Claude Desktop / Cursor / Codex）的"记忆层"。当前最前沿的 AI 集成方式。
3. **Paste 的 Apple Intelligence 集成**：直接调用 Writing Tools API，零配置。
4. **Maccy 的开源社区信任**：MIT + 代码透明，在隐私敏感群体中口碑极高。

### 2.3 NatureClipboard 的差异化机会

| 维度 | Paste / Raycast | NatureClipboard | 我们的优势 |
|------|-----------------|-----------------|-----------|
| AI Provider | 绑定官方 AI / Apple Intelligence | 用户自选（OpenAI / Claude / Ollama / MLX / 任意 OpenAI 兼容端点） | 可离线、可切换、避免厂商锁定 |
| 🔄 数据流向 | 走厂商服务器（Paste iCloud / Raycast Cloud） | **明确告知并可选**：默认云端 Provider（强确认 + 可切换本地 Ollama），无中间层代理 | 出口透明、可审计、走用户自己的 API Key |
| 定价 | Paste 订阅 / Raycast 内购 | 免费 + 源码可用（AGPL-3.0） | 零成本使用 |
| OCR | Paste 依赖 AI；Raycast 无 | 系统 Vision（离线）+ 可选 LLM 视觉模型 fallback | macOS 14 即可用，无需 M 芯片强制 |
| 视觉体验 | 标准 macOS 风格 | 独创 Nature 主题（动画树 / 叶子 / 气泡） | **市面唯一情感化剪贴板** |

---

## 3. 目标用户与场景

| 用户类型 | 核心场景 |
|---------|---------|
| 程序员 | 跨终端 / 编辑器复制代码片段、URL、错误信息，快速回粘；AI 自动打 `code` / `error` / `sql` 等标签，一键筛选 |
| 设计师 | 收集颜色 (hex)、图片、参考链接；图片 OCR 后可用文字关键词直接搜到设计截图 |
| 写作者 | 跨文档整理长文本片段，保留富文本格式；长文自动打 `text` / `note` / `draft` 类标签 |
| 通用用户 | 找回历史剪贴板、避免误覆盖；搜索命中处高亮显示 |

---

## 4. 功能需求

### 4.1 剪贴板监听与捕获

- 每 0.5s 轮询 `NSPasteboard.changeCount`
- 支持类型：文本、图片、文件、URL、颜色、HTML、RTF
- RTF 优先级高于 HTML；含 plain text 的 HTML 归类为 rtf
- 自动记录来源 App（名称 + bundleId）
- 相同内容自动去重合并使用次数
- 最多保留 5000 条（可配置）
- 新条目入库后触发 **AI 后处理管线**（异步、可关闭）：文本→打标 / 摘要；图片→OCR→打标；URL→抽站点/标题→打标

🔄 **技术决策：为什么必须轮询？**

macOS 从 10.0 至今**没有**提供 push-style 的 NSPasteboard 变更通知（无 delegate、无 KVO、无 NSNotification）。这不是我们的选择，是系统能力边界。业内所有 macOS 剪贴板管理器（Maccy、Paste、Alfred、CleanShot、Awesome Copy）以及 GitHub 上的 `.onPasteboardChange` SwiftUI modifier 内部**统一采用 `Timer` 轮询 `changeCount`**。

理论替代方案及其否决理由：
- **CGEventTap 拦截 ⌘C**：抓不到程序化 copy（浏览器右键"复制链接"、模拟器同步、其他 App 通过 API `writeObjects:`），会漏检；且需要 Accessibility 权限
- **动态注入 hook 目标 App 的 `writeObjects:`**：违反 SIP、无法通过 notarize、更无法上架
- **IOHIDEvent / Accessibility API**：只能监听输入事件，感知不到剪贴板本身变化

🔄 **轮询频率的智能降级**（v3 追加）：
- 应用失焦（`NSWorkspace.didDeactivateApplicationNotification`）→ 轮询降频到 1.5s
- 系统进入 Low Power Mode（`ProcessInfo.processInfo.isLowPowerModeEnabled`）→ 降频到 2s
- 电池水平 < 20% → 降频到 2s
- 前台且插电 → 保持 0.5s

### 4.2 全局呼出

- 默认快捷键 `⌘E`（改用 CGEventTap 在系统层拦截，避免被 Edit 菜单占用）
- 也可通过菜单栏图标点击
- 呼出时：
  - 动画：从下方 20px 淡入 + 弹性缩放（0.25s）
  - 记录呼出前的前台 App（`previousApp`）
  - 自动清空搜索、重置 Category、选中第一条

### 4.3 浮层界面

- 尺寸：750×500 圆角 14px
- 五段结构：搜索栏 / Category 胶囊条 / QuickActions / 列表 + 预览 / 底栏
- 中间可拖动分隔线（默认列表宽 500，范围 240–560）
- 失焦（`didResignKey`）自动隐藏
- 关闭：立即 orderOut + `previousApp.activate()` 恢复焦点
- 列表行右侧的类型胶囊（Text / Image / Rtf ...）与 **AI 标签胶囊**（`code` / `url` / `text` / `hex` / `error` / `ocr` 等）并列展示，标签可点击直接过滤

### 4.4 搜索与筛选

- 搜索栏支持内容 / 来源 App / 标签 / URL / title / OCR 文本 / AI 摘要 模糊匹配
- Category：All / Text / Images / Files / URLs / Colors / Pinned / Favorites / Tags（动态子菜单，展示当前库中出现过的 AI 标签，Top-N + 全部…）
- QuickActions：搜索时若匹配到指令关键词，显示 Clear All / Export / `Ask AI` / `Re-tag Selected` 等命令
- **搜索命中高亮**
  - 在列表标题行、副标题行、AI 标签、以及右侧预览面板正文中，将命中的关键词/子串以主题色（Nature：`#4A7C4A` 底 + 深色字；Liquid Glass：主题绿荧光描边）背景高亮
  - 高亮基于 `NSAttributedString.Key.backgroundColor`
  - 🔄 OCR 命中在图上叠加矩形：使用**行级 bbox**（不是字符级）；命中文本较短时按行 bbox 内的字符比例插值出子矩形
  - 大小写不敏感；支持中文、Emoji；多关键词以空格分隔时逐个高亮
  - 单条命中片段最长 240 字符，前后各截 60 字符窗口，超长省略
- 🔄 **索引方式**：**P1 直接落地 SQLite FTS5 全文索引**（aiTags / ocrText / aiSummary / urlTitle 一并入索引）；不再走"先线性、后 FTS5"两阶段

### 4.5 列表交互

- 单击选中，双击粘贴到前台 App
- 右键菜单：Paste / Pin / Favorite / Copy / Open in Browser / Text Transform / Delete / `Re-run AI Tagging` / `Copy OCR Text`（仅图片）
- 拖动整行：文本→字符串、图片→PNG data + NSImage、文件→NSItemProvider(URL)
- 键盘：上下切换选中（含搜索框聚焦时）、Return 粘贴、Esc 关闭
- 图片类文件在列表左侧显示缩略图，其他文件显示系统图标

### 4.6 预览面板（Raycast 风格）

- 顶部：标题、类型、来源、操作按钮（Pin / Favorite / Copy）
- 中部：按类型渲染内容
  - 文本 / HTML / RTF：等宽字体可选中，命中关键词高亮
  - 图片：完整渲染，命中 OCR 关键词时在图上叠加高亮框
  - 文件：图片格式直接预览，其他显示图标 + 路径
  - URL：可点击链接
  - 颜色：色块 + hex
- 底部 Information 区块（关键字段）：
  - Source（带 App 图标）
  - Content type
  - Dimensions / Image size（图片）
  - Characters / Words / Lines（文本）
  - Path / File size（文件，路径自动缩为 `~/`）
  - Host（URL）
  - Copied 时间（Today at / Yesterday at / 完整日期）
  - **AI 区块**（可折叠）
    - `Tags`：多个胶囊，主 tag（`code` / `text` / `url` / ...）加粗
    - `Summary`：≤ 60 字的 AI 摘要（可选，设置里开关）
    - `OCR`：OCR 抽取的完整文本，可选中复制
    - `Model`：使用的模型名 + 生成时间；失败时显示错误码 + `Retry` 按钮

### 4.7 粘贴机制

- `pasteboard.clearContents()` → 按类型写入多格式：
  - RTF 类型同时写 plain text + rtf + html
- 关闭面板 → 恢复前台 App 焦点 → 延时 0.05s → 模拟 `⌘V`
- CGEventPost 使用 `.cghidEventTap`

### 4.8 主题系统

- Nature 主题（默认）：
  - 米白背景 + 树干树枝 + 5 层重叠深绿树冠 + 底部草地条
  - 8 片飘落叶子（右侧 x=0.81–0.96 均匀分布）
  - 10 个 O₂ 泡泡（从树冠 10 个发射点向上飘）
  - TimelineView 时间驱动，主题切换/面板重开动画连续不重播
- Liquid Glass 主题：NSVisualEffectView `.hudWindow` + 暗色叠加
- 搜索栏右侧图标可切换（水滴 / 树叶）
- 选择持久化到 UserDefaults

### 4.9 Snippets（片段库）

- 可创建 / 编辑 / 删除 / 搜索
- 每条：name / keyword / category / content / 使用次数
- 独立弹窗管理，双击粘贴

### 4.10 设置

- General：登录启动、菜单栏、声音、通知、退出清空、最大条数
- Appearance：主题模式、预览面板开关、窗口尺寸
- Storage：统计、清空、导入 / 导出 JSON（导出可选是否包含 AI 标签 / OCR / 摘要）
- Exclusions：忽略的 App 列表
- **AI**（新 Tab，全部本地存储在 Keychain / UserDefaults）
  - Enable AI features（总开关，默认关闭）
  - 🔄 **首次开启强确认弹窗**：明确告知"启用后，剪贴板文本内容将发送至你配置的 Provider（默认 OpenAI）。图片 OCR 默认走本地 Vision，不外发。可随时在此 Tab 关闭。"
  - Provider 预设：`OpenAI`（默认）/ `Anthropic` / `Azure OpenAI` / `Ollama`（本地）/ `Custom (OpenAI-compatible)`
  - `Base URL`（例：`https://api.openai.com/v1`、`http://localhost:11434/v1`）
  - `API Key`（写入 macOS Keychain，UI 输入框自动脱敏显示）
  - `Model`（下拉 + 手填，例：`gpt-4o-mini` / `claude-3-5-sonnet-latest` / `qwen2.5:7b`）
  - `Timeout`（默认 15s）、`Max tokens`（默认 128）
  - Feature 开关（细粒度）：
    - Tagging（默认 ✔，走云端 LLM）
    - Summary（默认 ✘）
    - OCR（默认 ✔，**走本地 Vision**，不外发；可选开启 LLM Vision Fallback，开启时会外发图片）
    - URL Enrichment（默认 ✔，直接向 URL 发起 HTTP，不经 LLM）
  - Trigger 策略：`On new item`（默认，异步）/ `Manual only`（右键触发）
  - Rate limit：`每分钟最多 N 次`（默认 30，防止刷 quota）
  - 🔄 ~~Redaction 规则~~ **已删除**：v2 曾承诺基于正则黑名单拦截 secret，但覆盖不全（漏 AWS/GitHub/JWT/Stripe 等常见 key 格式）会给用户错误的安全感，比不做更危险。v3 起**不提供任何脱敏承诺**，改为在首次开启弹窗中明确警告"请勿在启用 AI 时复制密钥、密码等敏感信息"，把边界还给用户
  - `Test connection` 按钮 + 最近调用日志（成功 / 失败 / 耗时 / token 用量）

### 4.11 文本变换

对文本条目提供 22 种变换：大小写、camelCase、snake_case、kebab-case、去空白、排序行、Base64、URL 编码、JSON 美化 / 压缩、去 HTML 等。

### 4.12 AI 智能标签与索引

#### 4.12.1 目标

在不打断用户体验的前提下，对每条剪贴板内容自动产出：**≤5 个标签 + 1 句摘要 + （图片场景）OCR 全文**，作为搜索的补充索引。

#### 4.12.2 内容分类与打标规则

系统先做**本地启发式判定**（零成本、零延迟），再对不确定或长内容送 LLM。启发式规则示例：

| 特征 | 主标签 | 说明 |
|------|--------|------|
| 匹配 URL 正则、单行、以 `http(s)://` 开头 | `url` + host（如 `github.com`）| 附带 `link` |
| `#RRGGBB` / `rgb(...)` / `hsl(...)` | `hex` / `color` | |
| 单 token、长度 8–256、Base64/十六进制字符集为主、熵高、无空格 | `code`（gibberish）→ 映射为 `code` | 例："aGVsbG8gd29ybGQ=" |
| 匹配代码关键字（`function` `class` `def` `SELECT` `import` 等）或以 `{` `<` 开头 | `code` + 语言子标签（`swift` / `python` / `sql` / `json` / `html` ...）| |
| 匹配错误堆栈（`Traceback` / `at .+ (.+:\d+)` / `panic:`）| `error` | |
| 邮箱正则 | `email` | |
| 长度 > 200 且含中英文标点 | `text` + LLM 生成的领域标签 | 例：`note` / `draft` / `article` |
| 图片 | `image` + OCR 后再走文本管线得到的子标签 | 若 OCR 抽出 URL，则同时打 `url` |
| 文件 | `file` + 扩展名（`pdf` / `png` ...）| |

未命中启发式或需要更细语义时，构造以下 Prompt 送 LLM：

🔄 **v3 修订**：删除"secret 分支"（因为已不做脱敏、不再劫持）、显式指定 `temperature: 0`、追加 few-shot 提升小模型稳定性、要求**结构化输出**（OpenAI `response_format: json_schema` / Anthropic `tool_use` / Ollama `format: json`，由适配层统一封装）。

```
System: 你是剪贴板内容分类助手。给出 1-5 个英文小写短标签（每个 ≤12 字符），
一句 ≤40 字的摘要（与输入内容相同语言）。严格返回以下 JSON：
{"tags": ["..."], "summary": "..."}

Examples:
Input: "SELECT * FROM users WHERE age > 18;"
Output: {"tags": ["sql", "query", "code"], "summary": "查询成年用户的 SQL 语句"}

Input: "https://github.com/openai/openai-python"
Output: {"tags": ["url", "github", "python"], "summary": "OpenAI Python SDK 仓库地址"}

Input: "Traceback (most recent call last): ..."
Output: {"tags": ["error", "python", "traceback"], "summary": "Python 异常堆栈信息"}

User: <content-truncated-to-2000-chars>
```

- 参数：`temperature: 0`、`max_tokens: 128`、`response_format: json_schema`
- 解析失败则回退启发式结果，`aiStatus = .done`
- 提示：v3 起 **User 复制的原始内容会作为 prompt 明文发送到用户配置的 Provider**，请在首次开启的强确认弹窗中明确告知

#### 4.12.3 图片 OCR

- 首选 **Apple Vision `VNRecognizeTextRequest`**（离线、免费），语言列表跟随系统语言 + 自动追加中英文
- 🔄 输出：`ocrText` (String) + `ocrLines`（**行级**归一化 bbox，用于高亮叠加；不再存字符级）
  - 高亮命中子串时，按行 bbox 内的字符宽度比例做插值近似（性能与精度权衡）
  - 若需要精确的字符级 bbox，可**从原图即时重跑** Vision，不落盘
- 若用户在设置中开启 `LLM Vision Fallback` 且 Vision 结果为空 / 置信度低，则再调用多模态模型（如 `gpt-4o-mini` / `claude-3-5-sonnet` 的 vision 接口，图片 base64 上传，同样限制大小 ≤2MB）——**注意：开启此项将把图片外发到 Provider**
- OCR 完成后其文本再走 §4.12.2 的文本管线获得语义标签
- 性能 SLA：M 系列 <500ms（1920×1080）；Intel Mac 慢，若严重不达标可让用户开启 LLM Vision Fallback 兜底

#### 4.12.4 URL 富化

- 对 `url` 类型异步 `HEAD` + `GET`（限 512KB）取 `<title>`、`og:site_name`、`og:description`
- 打入 `titleGuess` / `siteName` 字段并纳入搜索
- 失败静默，不影响主流程

#### 4.12.5 Ask AI（QuickAction）— v3.1 重写

**定位**：将剪贴板历史作为个人上下文的 **mini-RAG**，允许用户对自己复制过的内容进行自然语言提问。

**触发方式**：
- 搜索框输入 `? <question>`（问号 + 空格开头触发）
- QuickActions 面板中选择 `Ask AI`
- 快捷键 `⌘⇧A`（可自定义）

🔄 **检索架构（v3.1：全 LLM 意图抽取路径）**：

不再使用 NLEmbedding / query rewrite / 关键词加权融合。**主路径统一走 LLM 结构化意图抽取 → 结构化过滤 → 生成回答**，简单、精确、可解释。

```
用户问："我昨天复制的那段 Swift 代码是做什么的"
    │
    ▼
① 意图抽取（LLM tool_call，~200 token，temperature: 0）
   → {
       "time_range": {"from": "2026-06-30T00:00", "to": "2026-06-30T23:59"},
       "tags_include": ["swift", "code"],
       "tags_exclude": [],
       "content_types": ["text"],
       "source_apps": [],          // 例：用户说"从 VSCode 复制的"
       "keywords": ["swift"],
       "intent": "explain"          // explain / find / summarize / compare / other
     }
    │
    ▼
② 结构化过滤（走 §4.4 的 FTS5 + 二级索引，全部本地，~10ms）
   → 命中集合 candidates[]
    │
    ▼
③ 分支：
   - candidates 数 ∈ [1, N]：直接作为 context 送 ④
   - candidates 数 > N（默认 20）：按时间倒序截断到 N 条
   - candidates 数 = 0：进入 §兜底流程（下文单列，UI 必须提示）
   - 意图抽取失败（LLM 返回非法 JSON / 超时）：进入 §兜底流程
    │
    ▼
④ 生成回答（LLM 流式）
```

**Prompt 模板（意图抽取，步骤 ①）**：

```
System: 你是查询意图抽取器。把用户对剪贴板的自然语言问题解析为结构化 JSON。
- time_range: 相对时间转绝对时间（当前时间：{{now}}）；未提及则为 null
- tags_include / tags_exclude: 从下列已存在标签中选择：{{available_tags}}；未提及则为空数组
- content_types: 从 text / image / url / file / color 中选择；未提及则为空数组
- source_apps: 从下列来源中选择：{{available_apps}}；未提及则为空数组
- keywords: 关键实词，用于全文搜索；不含虚词
- intent: explain / find / summarize / compare / other

严格返回 JSON，禁止其他文本。使用 tool_call / response_format: json_schema。

User: <question>
```

**Prompt 模板（生成回答，步骤 ④）**：

```
System: 你是用户的剪贴板助手。以下是根据用户意图从其剪贴板历史中过滤出的条目。
基于这些条目回答问题。若条目无法支撑答案，如实说明。
回答简洁（≤200字），使用与用户问题相同的语言。

User Intent: {{intent}}
Filtered Context ({{n}} items):
---
[1] (2026-06-30 14:30, from: VSCode, tags: swift/code)
<content snippet, ≤500 chars>
---
[2] ...

User: <question>
```

🔄 **兜底策略（必须给 UI 提示）**：

| 触发条件 | 兜底动作 | UI 提示（必须） |
|---------|---------|----------------|
| 意图抽取返回非法 JSON | 直接把 question 当 keyword 走 FTS5 → 拿 Top-10 | 卡片顶部黄色 badge：**"⚠️ 未能识别时间/标签等条件，已回退为纯关键词搜索"** |
| 意图抽取超时 | 同上 | **"⚠️ 意图识别超时，已回退为纯关键词搜索"** |
| 结构化过滤命中 = 0 | 取最近 10 条作为 context | 卡片顶部黄色 badge：**"⚠️ 在你要求的范围内没找到相关条目，以下答案基于最近 10 条内容"** |
| 剪贴板历史整体为空 | 不调用 LLM | 直接文案："剪贴板历史还没有内容，先复制一些东西再来问吧" |
| AI 总开关关闭 | 入口隐藏 | — |

**结果展示（流式）**：
- 浮层底部弹出答案卡片（**固定高度 300px**，内容溢出滚动，杜绝浮层频繁 resize 的老借口）
- **流式渲染**：token 到达即渲染，参照 ChatGPT / Cursor 的体验；首 token 目标 <1s（含意图抽取的 500ms 网络往返），全文 <5s
- 答案中引用的条目编号可点击跳转到对应列表行
- 显示 token 用量（意图抽取 + 生成两次调用合并显示）+ 总耗时
- 提供 `Copy Answer` / `Close` / `Stop` 按钮
- **兜底 badge 与答案一同展示，不会被 Stop / Retry 清除**（除非用户主动关闭卡片）

**延迟预算**（v3.1 明确接受"每次多 500ms"换准确率）：
- 意图抽取：~500ms（云端 LLM 一次小调用；本地小模型可能 200-800ms）
- 结构化过滤：<50ms（FTS5 本地）
- 生成回答首 token：~500ms-1s
- **总首 token 时间目标 ≤ 1.5s**

**已知边界（v3.1 明记，避免未来踩坑）**：
- 若用户配置的是**本地 7B 及以下模型**（如 `qwen2.5:7b`、`llama3.2:3b`），意图抽取的结构化输出稳定性会下降；此时**大概率走兜底**，UI 提示会更频繁——这是可接受的降级，不视为 bug
- 若用户短时间连续 Ask AI（<3s），复用上次的意图抽取结果做增量刷新，避免重复消耗

### 4.13 数据模型扩展

`ClipboardItem` 结构追加以下字段（全部可选，向后兼容旧 JSON）：

```swift
struct ClipboardItem: Codable, Identifiable {
    // ...原有字段
    var aiTags: [String] = []           // 已归一化的小写英文短标签
    var aiSummary: String? = nil        // ≤40 字摘要
    var ocrText: String? = nil          // 图片 OCR 文本
    var ocrLines: [OCRLine]? = nil      // 🔄 v3：行级 bbox（不再存字符级）
    var urlTitle: String? = nil         // URL 富化标题
    var urlSiteName: String? = nil
    var aiModel: String? = nil          // 生成时使用的模型
    var aiUpdatedAt: Date? = nil
    var aiStatus: AIStatus = .none      // .none / .queued / .running / .done / .failed
    var aiError: String? = nil
}

struct OCRLine: Codable {
    let text: String
    let x, y, w, h: Double              // 归一化坐标 0.0-1.0
    let confidence: Double
}
enum AIStatus: String, Codable { case none, queued, running, done, failed }
```

搜索用的 `matchable` 拼接串在原有字段基础上追加：`aiTags.joined(" ") + " " + (aiSummary ?? "") + " " + (ocrText ?? "") + " " + (urlTitle ?? "") + " " + (urlSiteName ?? "")`。

🔄 **v3.1 变更**：删除 v3 曾规划的 `embedding: [Float]?` 字段（Ask AI 已改为全 LLM 意图抽取路径，不再需要本地向量索引）。

### 4.14 数据导出互操作性

导出 JSON 格式遵循以下结构（可选开启，Settings → Storage → Export Options）：

```json
{
  "version": 3,
  "exportedAt": "ISO8601",
  "items": [
    {
      "content": "...",
      "type": "text|image|url|...",
      "sourceApp": "...",
      "createdAt": "ISO8601",
      "ai": {
        "tags": ["code", "swift"],
        "summary": "...",
        "ocrText": "..."
      }
    }
  ]
}
```

格式自描述、版本化，方便其他工具二次导入或脚本处理。

---

## 5. 工程纪律

### 🔄 5.1 两条哲学（v3 新增，覆盖所有开发活动）

1. **Commit 前必须 Review**：任何提交（包括本地 branch merge、cherry-pick、AI 生成的代码）在合入主分支前必须有至少一次 self-review 或 pair-review。个人项目也不例外——用 `git diff --staged` 走一遍，或者用 Cursor / Copilot 的 review 模式先自审。禁止"写完直接 push"。
2. **新 feature 先写单元测试**：任何新功能（含 bug fix 中引入的新分支）必须先写测试再写实现。测试红→实现绿→重构。UI-only 变更除外（走 Snapshot Test，见 §5.3）。

以上两条不是建议，是**红线**。CI 会强制：
- 无对应测试的新增业务代码 → CI 报警（通过 diff 覆盖率工具，例如 `diff-cover`）
- 未经 review 的直接 push 到主分支 → 分支保护规则禁止（GitHub Branch Protection：Require pull request + Require review from Codeowners，个人项目至少 Require pull request）

### 5.2 目录结构

```
NatureClipboard/
├─ Sources/                    # 产品源码
│   ├─ App/
│   ├─ AI/
│   ├─ Search/
│   └─ ...
├─ Tests/                      # 所有测试代码
│   ├─ AITests/
│   │   ├─ HeuristicTaggerTests.swift
│   │   ├─ LLMClientTests.swift
│   │   ├─ AIPipelineTests.swift
│   │   ├─ OCRServiceTests.swift
│   │   └─ URLEnricherTests.swift
│   ├─ SearchTests/
│   │   ├─ HighlighterTests.swift
│   │   ├─ MatchableBuilderTests.swift
│   │   └─ IntentExtractorTests.swift     # 🔄 v3.1：意图抽取器（替代 EmbeddingRetrieverTests）
│   ├─ CoreTests/
│   │   ├─ ClipboardMonitorTests.swift
│   │   ├─ ClipboardStoreTests.swift
│   │   └─ TextTransformationsTests.swift
│   ├─ SnapshotTests/            # 🔄 v3 新增：UI 回归
│   │   ├─ NatureThemeSnapshotTests.swift
│   │   └─ LiquidGlassSnapshotTests.swift
│   └─ IntegrationTests/
│       ├─ AskAIIntegrationTests.swift
│       └─ PasteFlowTests.swift
└─ Package.swift
```

### 🔄 5.3 分层测试策略（v3 修订）

替代 v2 的"一刀切 TDD"，按代码性质分层：

| 层 | 代码类型 | 策略 | 工具 | 覆盖率目标 |
|----|---------|------|------|-----------|
| 单元 | 启发式 tagger、LLM response parser、IntentExtractor、Highlighter、TextTransformations | **严格 TDD**（红→绿→重构） | XCTest | 行覆盖 ≥ 85% |
| 集成 | AIPipeline、AskAI 流程、PasteFlow | 关键路径覆盖，网络用 mock | XCTest + Protocol mock | 场景覆盖 |
| 快照 | Nature/Liquid Glass 主题、列表行、预览面板 | 无法先写测试的 UI → 用 snapshot test 做**回归防护** | swift-snapshot-testing（可依赖） | 关键界面全覆盖 |
| 端到端 | 呼出 → 搜索 → 粘贴 | 手动 + Xcode UI Test | XCUITest | 核心流程 |

- **单元测试命名**：`test_<被测方法>_<场景>_<期望结果>()`，例：`test_heuristicTag_urlContent_returnsUrlTag()`
- **结构**：Given-When-Then
- **覆盖率测量**：`swift test --enable-code-coverage` + `xcov` 报表；CI 上传到 Codecov
- **Mock 策略**：LLM 网络调用使用 Protocol + Mock 替换，不依赖真实网络
- **运行要求**：`swift test` 全量通过，单次 < 30s

### 5.4 工作流

```
需求确认 → 分层判定测试策略 → (单元层) 写测试 → 实现 → 测试绿 → 重构
                              → (快照层) 写实现 → 生成基准快照 → 后续变更走 diff review
                              ↓
                        本地 self-review （git diff --staged）
                              ↓
                    push 到 branch → open PR → CI 全绿 + review → merge
```

---

## 6. 非功能需求

| 项目 | 要求 | 测量方式 |
|------|------|------------|
| 平台 | macOS 14+（依赖 SwiftUI onKeyPress、TimelineView） | CI 矩阵覆盖 macOS 14/15 |
| 语言 | Swift 5.9 | — |
| 🔄 依赖 | **允许合理的第三方依赖**（如 swift-snapshot-testing、Keychain wrapper、OpenAI 兼容 SDK）；引入前需 PR review 说明必要性、许可证兼容性、维护活跃度 | `swift package show-dependencies` 定期审计 |
| 性能 | 剪贴板轮询 0.5s（可降频） / 面板呼出 <100ms / 粘贴延迟 <100ms | Instruments → Time Profiler，连续 10 次呼出取 P95 |
| AI 性能 | AI 打标异步，主线程零阻塞；OCR 单张 <500ms（M 系列基准 1920×1080）；高亮渲染增量 <16ms/帧 | Instruments + `XCTest.measure {}` |
| 权限 | 需要「辅助功能」权限；网络出站权限（沙盒 entitlement `com.apple.security.network.client`）；图片读取（Vision 无需额外权限） | — |
| 🔄 隐私 | 所有数据仅本地 `~/Library/Application Support/ClipboardManager/*.json`；AI 关闭时**绝不发起任何网络请求**；API Key 仅存 macOS Keychain；启用 AI 时**通过强确认弹窗告知用户内容会外发**；设置内提供「一键清除全部 AI 字段」；**不做 secret 脱敏承诺**（详见 §4.10 说明） | Charles / Little Snitch 抓包验证 AI 关闭状态零出站 |
| 无障碍 | 对齐 Apple Accessibility 官方指南（详见 §6.1） | Xcode Accessibility Inspector 全面审计 |
| 🔄 协议 | **AGPL-3.0**（GNU Affero General Public License v3.0） | — |
| 可观测 | 内置 AI 调用日志（本地环形 buffer，200 条），Settings → AI → View Log | — |
| 兼容 | 加载旧版本 JSON 时缺失 AI 字段按默认值回填，不阻断启动 | 单元测试覆盖 v1/v2 JSON 加载 |

### 6.1 无障碍（Accessibility）— 对齐 Apple 官方指南

参考 Apple 官方文档：[Accessibility | Apple Developer Documentation](https://developer.apple.com/documentation/accessibility)、[WWDC25 Session 229: Make your Mac app more accessible](https://developer.apple.com/videos/play/wwdc2025/229/)、[SwiftUI Accessibility Modifiers](https://developer.apple.com/documentation/swiftui/view-accessibility)

#### 6.1.1 VoiceOver 支持

- 所有交互元素（列表行、胶囊按钮、搜索栏、预览面板）必须提供 `.accessibilityLabel()` 和 `.accessibilityHint()`
- 列表行的 VoiceOver 朗读顺序：内容摘要 → 类型 → AI 标签 → 来源 App → 时间
- Category 胶囊需提供 `.accessibilityValue()` 标示当前选中状态
- AI 状态变化（标签生成完成、失败）通过 `AccessibilityNotification.Announcement` 通知
- 搜索结果数量变化时通过 `.accessibilityLabel` 动态更新

#### 6.1.2 键盘完整导航

- 完整 Tab 循环：搜索栏 → Category 条 → 列表 → 预览面板 → 底栏
- 所有右键菜单操作均可通过键盘快捷键触发
- Focus ring 在两套主题下均清晰可见

#### 🔄 6.1.3 视觉无障碍

- 搜索高亮不仅使用颜色，同时添加**下划线**（确保色盲用户可感知）
- 支持 macOS「增加对比度」（`NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast`）：启用时加深所有边框、去除半透明效果
- 支持「减少动画」（`AccessibilityReduceMotion`）：启用时禁用叶子飘落、气泡上浮、弹性缩放动画
- 🔄 ~~文本大小跟随 macOS Dynamic Type~~ **移除**（macOS 无 iOS 意义的 Dynamic Type API；本项目暂不承诺文本大小跟随系统偏好）

#### 6.1.4 测试验证

- 使用 Xcode **Accessibility Inspector** 扫描所有页面，确保零警告
- VoiceOver 手动验证清单（覆盖核心流程：呼出 → 搜索 → 选中 → 粘贴）
- 对应单元测试：验证 `.accessibilityLabel` 正确赋值（在 `Tests/AccessibilityTests/` 目录）

---

## 7. 错误处理与边界场景

### 7.1 LLM 调用错误处理

| 场景 | 处理策略 |
|------|----------|
| LLM 返回非法 JSON | 尝试宽松解析（允许尾逗号/单引号）→ 仍失败则回退启发式标签，`aiStatus = .done`（不视为失败），日志记录原始响应 |
| 网络超时 | 重试 1 次（间隔 3s），仍超时则 `aiStatus = .failed`，记录错误，不自动重试（用户可手动 Retry） |
| HTTP 4xx（认证失败/额度耗尽） | 不重试，`aiStatus = .failed`，弹出系统通知（仅首次）提示用户检查 API Key / 额度 |
| HTTP 5xx（服务端错误） | 指数退避重试 2 次（3s → 9s），仍失败则放弃 |
| 模型返回空 tags | 使用启发式结果补充，`aiStatus = .done` |
| 🔄 结构化输出被 Provider 拒绝（老模型） | 降级为自由文本 + 正则抽 JSON |

### 7.2 OCR 边界场景

| 场景 | 处理策略 |
|------|----------|
| 空白/纯色图片 | Vision 返回空结果 → `ocrText = nil`，正常标记 `aiStatus = .done`，不触发 LLM Vision fallback |
| 超大图片（>20MB / >8000px 单边） | 先等比缩放到 4096px 单边再送 Vision，避免内存峰值 |
| Vision 返回置信度 < 0.3 | 若开启 LLM Vision Fallback 则触发二次识别，否则保留低置信度结果并标注 `[low confidence]` |
| 图片格式不支持（如 HEIC raw） | 尝试 CIImage 转换为 PNG → 重新识别；仍失败则跳过 OCR |
| 🔄 Intel Mac 明显超时（>2s） | 首次触发时提示用户「Vision 在本机较慢，是否开启 LLM Vision Fallback？」 |

### 7.3 队列管理

| 场景 | 处理策略 |
|------|----------|
| 队列堆积（>100 待处理） | 新条目仍入队（FIFO），但显示"AI 处理中…剩余 N 条"状态提示 |
| App 退出时队列未完成 | 持久化当前队列到磁盘（`pending_queue.json`），下次启动恢复 |
| 批量导入老数据 | 老数据入队优先级低于新条目（双优先级队列：realtime > backfill） |
| Rate limit 触发 | 令牌桶耗尽后排队等待，不丢弃；UI 显示"已达限速，稍后自动继续" |

---

## 8. 当前已知问题（待修）

🔄 **v3 重新排序**：

1. **P0** — 搜索框聚焦时上下键无法切换列表
2. 🔄 **P0** — **首次运行的辅助功能权限提示流程未完成引导页**（v2 曾排 P2/P3，新用户走不下去等于所有 v2 功能白搭）
3. 按上下键鼠标光标消失（系统默认行为，需评估是否覆盖，P2）
4. 大批量老数据一次性触发 AI 打标可能击穿 rate limit（v2 引入队列 + 令牌桶，已在 P1）

---

## 9. 后续路线

| 优先级 | 项目 |
|-------|------|
| P0 | 修复上下键在 TextField 聚焦时的转发 |
| 🔄 P0 | **首次运行 Onboarding**（辅助功能授权引导 + 首次开启 AI 强确认弹窗） |
| P0 | AI Tab 设置页 + 启发式打标 + Vision OCR + 搜索命中高亮 |
| P1 | LLM Provider 打标（OpenAI 兼容 / Ollama）+ 结构化 JSON 解析 + 队列 & 令牌桶 |
| 🔄 P1 | Ask AI QuickAction（**LLM 意图抽取 → 结构化过滤 → 流式生成**，兜底必提示，详见 §4.12.5） |
| 🔄 P1 | **SQLite FTS5 全文索引**（v2 排 P2，v3 提前）|
| P1 | 自定义快捷键设置界面（当前硬编码 ⌘E） |
| P1 | iCloud 同步（可选） |
| P1 | 无障碍完整支持（VoiceOver + 减少动画 + 高对比度，详见 §6.1） |
| P2 | 收藏夹分组、标签管理 UI（与 AI Tags 打通：手动置顶 / 别名 / 隐藏） |
| P2 | MCP Server 支持（参考 Paste MCP 模式，让外部 AI 工具可查询剪贴板历史） |
| P3 | 打包 .app + 签名 + notarize |
| P3 | 多语言支持 |
| P3 | 多模态视觉模型 fallback（对 Vision 抽不到字的截图再送 LLM Vision） |

---

## 10. 核心用户流程

### 10.1 新条目 → AI 打标流程

```
用户复制内容
    │
    ▼
ClipboardMonitor 检测到 changeCount 变化（0.5s 轮询）
    │
    ▼
去重判定 → 重复则合并计数 → 结束
    │ (新条目)
    ▼
写入 ClipboardStore + 持久化 JSON
    │
    ▼
AI 总开关开启？ ──否──▶ 结束（无 AI 字段）
    │ 是
    ▼
┌─────────────────────────────────────────────────┐
│  AIPipeline.enqueue(item)                        │
│                                                   │
│  ① HeuristicTagger（同步 <1ms）                  │
│       │                                           │
│       ├─ 确定结果 → 写入 aiTags → aiStatus=done  │
│       │                                           │
│       └─ 不确定/长文本 → 加入 LLM 队列            │
│                                                   │
│  ② [图片] OCRService（异步，Vision 本地 <500ms）  │
│       │                                           │
│       └─ ocrText → 再走 ① 的文本管线              │
│                                                   │
│  ③ [URL] URLEnricher（异步，HTTP）                │
│       │                                           │
│       └─ 标题/站点 → 写入字段                     │
│                                                   │
│  ④ LLMClient（异步，受令牌桶限速）                │
│       │                                           │
│       └─ 结构化 JSON parse → 归一化 tag           │
│           失败 → 回退启发式 / aiStatus=failed      │
│                                                   │
│  ⑤ 更新 item → @Published 触发列表刷新            │
└─────────────────────────────────────────────────┘
```

🔄 v3.1 相对 v2：删除 Redactor 前置步骤；v3 曾规划的"NLEmbedding 本地向量生成"步骤已移除（Ask AI 改走 LLM 意图抽取路径）。

### 10.2 搜索 → 高亮 → 粘贴流程

```
用户输入搜索关键词
    │
    ▼
FTS5 全文索引查询（含 aiTags/ocrText/aiSummary/urlTitle）
    │
    ▼
匹配结果列表渲染
    │ 同时
    ▼
Highlighter 计算命中区间
    │
    ├─▶ 列表行：标题/副标题命中字符以主题色背景高亮 + 下划线
    │
    └─▶ 预览面板：正文命中高亮 + [图片] OCR 行级 bbox 内插值叠加矩形
    │
    ▼
用户选中条目 → 双击/回车
    │
    ▼
面板关闭 → previousApp.activate() → 0.05s → 模拟 ⌘V
```

### 10.3 Ask AI 流程

```
用户输入 "? 我昨天复制的那段 Swift 代码是做什么的"
    │
    ▼
识别 Ask AI 触发（"?" 前缀）
    │
    ▼
🔄 ① LLM 意图抽取（tool_call，~500ms）
     → {time_range, tags_include, content_types, keywords, intent}
    │
    ▼
② 结构化过滤（FTS5 + 二级索引，本地 <50ms）
    │
    ├─ 命中 1..N 条 → 直接进 ④
    ├─ 命中 > N 条 → 按时间倒序截断到 N 条 → 进 ④
    ├─ 命中 = 0 条 → 兜底：取最近 10 条 + UI 提示黄色 badge
    └─ 意图抽取失败/超时 → 兜底：question 当 keyword 走 FTS5 + UI 提示 badge
    │
    ▼
③ 构造 Prompt + 调用 LLM（流式）
    │
    ▼
🔄 流式渲染答案卡片（固定 300px，超出滚动）
    │
    ├─ 顶部（若兜底）黄色 badge 提示"已回退到 XX 模式"
    ├─ 引用编号可点击跳转
    ├─ 显示总 token 用量（意图 + 生成合并）+ 总耗时
    └─ Copy Answer / Close / Stop
```

---

## 11. 交付定义

MVP 已完成的验收标准：

- [x] `⌘E` 全局呼出面板
- [x] 剪贴板自动记录并去重
- [x] 双击 / 回车粘贴到前台 App
- [x] Nature / Liquid Glass 双主题切换
- [x] 拖动条目到其他 App（文本 / 图片 / 文件）
- [x] Raycast 风格 Information 预览
- [x] 中间分隔线可调节
- [x] 已推送到 GitHub

🔄 **v3 (Battle-Reviewed) 验收标准：**

- [ ] 🔄 LICENSE 更新为 **AGPL-3.0**，README + `LICENSE` 文件同步
- [ ] 🔄 首次开启 AI 时展示**强确认弹窗**，明确告知内容外发
- [ ] Settings → AI Tab：可配置 Provider / Base URL / API Key / Model / Timeout / 各 Feature 开关，`Test connection` 通过
- [ ] API Key 仅落 Keychain，UI 显示为脱敏形式；卸载/清除后 Keychain 同步删除
- [ ] AI 总开关关闭时，App 无任何网络出站流量（Charles/Little Snitch 抓包验证）
- [ ] 新剪贴板条目在 3s 内出现启发式标签（`url` / `hex` / `code` / `error` / `email`）
- [ ] 长文本条目在 30s 内出现 LLM 生成的 `tags` + `summary`（网络正常）
- [ ] 图片条目在 1s 内完成 Vision OCR（M 系列），OCR 文本可搜索、可复制
- [ ] 搜索时列表 & 预览面板中命中关键词以主题色背景高亮 + 下划线，图片 OCR 命中处叠加半透明矩形
- [ ] Category 胶囊条追加 `Tags` 入口，可按 AI 标签筛选
- [ ] 🔄 **删除**"命中脱敏正则的内容不出网"这条验收（已下架该能力）
- [ ] 老 JSON 数据（v1/v2）可无损加载，缺失 AI 字段自动补默认值
- [ ] 队列 + 令牌桶生效：连续导入 500 条老数据不会瞬时打爆 Provider rate limit
- [ ] `Tests/` 目录下单元测试全部通过（`swift test` 零失败），行覆盖率 ≥ 85%（单元层）
- [ ] 🔄 Snapshot 测试基准建立，主题回归可自动检测
- [ ] Accessibility Inspector 扫描零严重警告
- [ ] VoiceOver 可完成核心流程（呼出 → 搜索 → 选中 → 粘贴）
- [ ] 🔄 **Ask AI 全链路可跑通**：LLM 意图抽取 → 结构化过滤 → 流式生成；三种兜底路径（意图抽取失败 / 意图抽取超时 / 过滤命中 0）**必须触发对应 UI badge 提示**；总首 token 时间 ≤ 1.5s（云端 Provider）
- [ ] 🔄 **首次运行 Onboarding** 覆盖辅助功能授权 + AI 强确认
- [ ] 🔄 CI 强制"新增业务代码必须有对应测试"、"push 需经过 PR review"

**当前工作**：
1. P0 修复搜索框聚焦时的键盘导航
2. 🔄 P0 首次运行 Onboarding + AI 强确认弹窗
3. P0 落地 §4.4 搜索命中高亮 + §4.10 AI Tab 设置页 + §4.12.3 Vision OCR + §4.12.2 启发式打标
4. 🔄 P1 接入 LLM Provider 打标 + Ask AI QuickAction（**LLM 意图抽取 → 结构化过滤 → 流式生成，兜底必提示 UI badge**）+ SQLite FTS5

---

## 🔄 12. 成功指标 / 北极星指标（v3 新增）

### 12.1 北极星指标

**每周活跃用户中，"AI 增强搜索命中率" ≥ 30%**

定义：AI 增强搜索命中 = 用户输入搜索关键词 → 命中的条目至少有一个字段来自 AI（`aiTags` / `ocrText` / `aiSummary` / `urlTitle`）。若为 0，说明用户根本不需要 AI，v3 白做。

### 12.2 支撑指标（v3 上线 30/60/90 天分别评估）

| 分类 | 指标 | 目标（30d / 60d / 90d） |
|------|------|-------------------------|
| 装机 | GitHub Star | 200 / 500 / 1000 |
| 装机 | 独立下载装机数（通过匿名 launch ping，可关闭） | 100 / 500 / 2000 |
| 留存 | D7 留存（启用后第 7 天仍启动） | 30% / 40% / 50% |
| 留存 | D30 留存 | 15% / 25% / 35% |
| AI 采纳 | 装机用户中开启 AI 总开关的比例 | 25% / 35% / 45% |
| AI 采纳 | 开启 AI 的用户中，30 天内至少用过一次 Ask AI 的比例 | 40% / 55% / 65% |
| 质量 | AI 打标准确率（人工抽样 100 条评估，主 tag 正确) | 80% / 85% / 90% |
| 质量 | OCR 命中搜索次数 / 图片总条目数 | 0.1 / 0.2 / 0.3 |
| 稳定 | Crash-free session rate（若集成 crash reporter） | 99.5% / 99.7% / 99.9% |
| 稳定 | GitHub 未 close bug issue 数 | ≤10 / ≤8 / ≤5 |

### 12.3 度量方式

- 匿名 launch ping：一个可关闭的 GET 请求，只上报「版本号 + 平台 + 是否开 AI」，不含用户身份、内容、IP
- 打标准确率：每月抽样 100 条，人工评估主 tag 是否合理
- Snapshot & 覆盖率通过 CI 自动上报到 GitHub Actions Summary

---

## 附录 A：协议说明

🔄 v3 起本项目采用 **AGPL-3.0**（GNU Affero General Public License version 3.0）协议。

**为什么从 CC BY-NC-SA 4.0 改为 AGPL-3.0**：
- Creative Commons 官方 FAQ 明确不推荐将 CC 协议用于软件（"We recommend against using Creative Commons licenses for software"），原因包括：未覆盖专利授权、未区分源码/二进制、与 GPL/Apache 生态不兼容、"非商业"边界在司法实践中模糊
- AGPL-3.0 是 FSF 起草、专为软件设计的许可协议，同时解决了 GPL 在"网络服务"场景下的漏洞（若你把本软件改造为 SaaS 提供，也必须开源）
- AGPL 的强 copyleft 语义清晰，对希望"防止闭源商用"的初衷保护更强
- AGPL 与 GNU/开源生态兼容，反而降低了社区贡献门槛

**AGPL-3.0 核心条款**：
- ✅ **允许**：任何用途（含商用）、修改、分发、fork
- 📋 **要求**：任何分发（含通过网络提供服务）必须附带完整源码（含你的修改）；衍生作品必须以相同 AGPL-3.0 协议发布
- ⚠️ **注意**：AGPL 是**强 copyleft**，公司若在内网部署修改版，理论上需要向所有使用该服务的员工提供源码（内部使用是否豁免存争议，见 [FSF FAQ](https://www.gnu.org/licenses/gpl-faq.html#InternalDistribution)）

协议全文：https://www.gnu.org/licenses/agpl-3.0.html
