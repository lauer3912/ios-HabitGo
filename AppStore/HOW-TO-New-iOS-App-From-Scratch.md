# 从零创建 iOS App 项目完整指南

## 第一阶段：概念与命名

### 1.1 提前核查 App Store 名称

```bash
curl -s "https://itunes.apple.com/search?term=你的名字&entity=software&limit=5" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); [print(r['trackName'], r['artistName']) for r in d['results']]"
```

### 1.2 三层命名

| 层级 | 示例占位符 | 位置 | 能否改 |
|------|-----------|------|--------|
| App Store 名称 | `{DesiredAppStoreName}` | App Store Connect | ✅ |
| Bundle ID | `com.ggsheng.{AppName}` | 打包进二进制 | ❌ |
| Display Name | `{AppName}` 或 `{DesiredAppStoreName}` | Info.plist | ✅ |

**规则：Bundle ID 一旦上传不能改，App Store 名称随时可换。**

---

## 第二阶段：创建项目目录结构

```bash
mkdir -p ios-{AppName}/{AppName,AppNameWidget,AppNameTests,AppNameUITests,AppStore}
mkdir -p ios-{AppName}/AppName/{App,Models,Views,ViewModels}
mkdir -p ios-{AppName}/AppName/Assets.xcassets/{AppIcon.appiconset,AccentColor.colorset}
mkdir -p ios-{AppName}/AppNameWidget/Assets.xcassets
mkdir -p ios-{AppName}/AppStore/Screenshots
```

**文件夹名** = 项目中文档和代码引用的实际路径，**必须与 project.yml 的 `path:` 一致**。

---

## 第三阶段：project.yml 完整配置

### 3.1 完整模板

```yaml
# ══════════════════════════════════════════════════════════════
# 项目级别配置
# ══════════════════════════════════════════════════════════════

name: {AppName}                          # ← Xcode 项目名 = xcodeproj 文件名
options:
  bundleIdPrefix: com.ggsheng            # Bundle ID 前缀
  deploymentTarget:
    iOS: "17.0"                          # 最低 iOS 版本（Widget 用 containerBackground 需 17.0+）
  xcodeVersion: "15.0"
  generateEmptyDirectories: true

# ══════════════════════════════════════════════════════════════
# 全局构建设置（所有 target 继承）
# ══════════════════════════════════════════════════════════════

settings:
  base:
    SWIFT_VERSION: "5.9"
    MARKETING_VERSION: "1.0.0"            # App Store 显示的版本号
    CURRENT_PROJECT_VERSION: "1"          # 每次 archive 递增
    CODE_SIGN_STYLE: Automatic            # ← 关键：自动签名
    DEVELOPMENT_TEAM: 9L6N2ZF26B          # ← 关键：团队 ID
    ENABLE_USER_SCRIPT_SANDBOXING: NO     # 禁止，否则有脚本签名问题

# ══════════════════════════════════════════════════════════════
# Target 1: 主 App
# ══════════════════════════════════════════════════════════════

targets:
  {AppName}:                             # ← Target 名称（Xcode 里看到的）
    type: application
    platform: iOS
    sources:
      - path: {AppName}                  # ← 源码文件夹（必须和 target 名一致）
        excludes:
          - "**/.DS_Store"
    settings:
      base:
        # ← Info.plist 路径（相对项目根目录）
        INFOPLIST_FILE: {AppName}/Info.plist
        # ← Bundle ID（com.ggsheng.后面跟 AppStore 确认的名称）
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{AppName}
        # ← App Store 显示名（可以不是 target 名）
        PRODUCT_NAME: {AppName}
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor
        GENERATE_INFOPLIST_FILE: NO       # ← 必须 NO，用自己写的 Info.plist
        SWIFT_EMIT_LOC_STRINGS: YES
        CODE_SIGN_ENTITLEMENTS: {AppName}/{AppName}.entitlements
        CODE_SIGN_STYLE: Automatic        # 继承全局
        # ← simulator 构建跳过签名（节省时间）
        CODE_SIGNING_ALLOWED: NO
        DEVELOPMENT_TEAM: 9L6N2ZF26B     # 继承全局，但明确写出
      # ════════════════════════════════════════
      # per-config 覆盖（关键！）
      # ════════════════════════════════════════
      configs:
        Debug:                           # Simulator 构建
          CODE_SIGNING_ALLOWED: NO       # ← Debug 跳过签名
        Release:                         # Archive 构建
          CODE_SIGNING_ALLOWED: YES       # ← Release 开启签名（必须！）
    entitlements:
      path: {AppName}/{AppName}.entitlements
    dependencies:
      - target: {AppName}Widget          # ← Widget extension
        embed: true                       # ← 自动嵌入主 App

# ══════════════════════════════════════════════════════════════
# Target 2: Widget Extension
# ══════════════════════════════════════════════════════════════

  {AppName}Widget:
    type: app-extension
    platform: iOS
    sources:
      - path: {AppName}Widget
        excludes:
          - "**/.DS_Store"
    settings:
      base:
        INFOPLIST_FILE: {AppName}Widget/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{AppName}.widget
        PRODUCT_NAME: {AppName}Widget
        GENERATE_INFOPLIST_FILE: NO
        SWIFT_EMIT_LOC_STRINGS: YES
        CODE_SIGN_ENTITLEMENTS: {AppName}Widget/{AppName}Widget.entitlements
        CODE_SIGNING_ALLOWED: NO
        DEVELOPMENT_TEAM: 9L6N2ZF26B
        SKIP_INSTALL: YES                 # ← Widget 必须 YES
        LD_RUNPATH_SEARCH_PATHS:
          - "$(inherited)"
          - "@executable_path/Frameworks"
          - "@executable_path/../../Frameworks"
      configs:
        Debug:
          CODE_SIGNING_ALLOWED: NO
        Release:
          CODE_SIGNING_ALLOWED: YES       # ← Widget Release 也必须 YES！

    entitlements:
      path: {AppName}Widget/{AppName}Widget.entitlements

# ══════════════════════════════════════════════════════════════
# Target 3: Unit Tests
# ══════════════════════════════════════════════════════════════

  {AppName}Tests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: {AppName}Tests
        excludes:
          - "**/.DS_Store"
    dependencies:
      - target: {AppName}
    settings:
      base:
        INFOPLIST_FILE: {AppName}Tests/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{AppName}Tests
        PRODUCT_NAME: {AppName}Tests
        GENERATE_INFOPLIST_FILE: NO
        TEST_HOST: "$(BUILT_PRODUCTS_DIR)/{AppName}.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/{AppName}"
        BUNDLE_LOADER: "$(TEST_HOST)"
        CODE_SIGN_STYLE: Automatic
        DEVELOPMENT_TEAM: 9L6N2ZF26B

# ══════════════════════════════════════════════════════════════
# Target 4: UI Tests
# ══════════════════════════════════════════════════════════════

  {AppName}UITests:
    type: bundle.ui-testing
    platform: iOS
    sources:
      - path: {AppName}UITests
        excludes:
          - "**/.DS_Store"
    dependencies:
      - target: {AppName}
    settings:
      base:
        INFOPLIST_FILE: {AppName}UITests/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{AppName}UITests
        PRODUCT_NAME: {AppName}UITests
        GENERATE_INFOPLIST_FILE: NO
        TEST_TARGET: "$(BUILT_PRODUCTS_DIR)/{AppName}.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/{AppName}"
        CODE_SIGN_ENTITLEMENTS: ""        # UI Test target 不需要 entitlements
        CODE_SIGN_STYLE: Automatic
        DEVELOPMENT_TEAM: 9L6N2ZF26B

# ══════════════════════════════════════════════════════════════
# Schemes
# ══════════════════════════════════════════════════════════════

schemes:
  {AppName}:                             # ← Scheme 名（和 target 名一致）
    build:
      targets:
        {AppName}: all                   # 主 App
        {AppName}Widget: all             # Widget
        {AppName}UITests: [test]         # UI Test
    run:
      config: Debug
    test:
      config: Debug
      targets:
        - {AppName}UITests
    archive:
      config: Release                     # ← Archive 必须用 Release
```

### 3.2 signing 配置逐行解析

**为什么需要 `configs: Debug / Release` 两层？**

因为 Xcode 的 Archive 操作默认使用 **Release 配置**，但本地调试用 **Debug 配置**：

| 场景 | 配置 | CODE_SIGNING_ALLOWED |
|------|------|----------------------|
| 本地 Simulator 调试 | Debug | NO（跳过签名，simulator 不检查）|
| Archive 打包上传 | Release | YES（必须签名）|

**如果 base level 写 `CODE_SIGNING_ALLOWED: NO`** → Release 构建也被禁止 → Archive 失败

**如果只有 Release 写 YES，Debug 写 NO** → Archive 失败，因为 base 的 NO 会覆盖

**正确做法：base 留空或写 YES，per-config Debug 覆盖为 NO，Release 保持 YES**

```yaml
# 错误 ❌
settings:
  base:
    CODE_SIGNING_ALLOWED: NO             # base 这样写 = Release 也被禁止

# 正确 ✅
settings:
  base:
    CODE_SIGNING_ALLOWED: NO             # 只对 Debug 生效
  configs:
    Debug:
      CODE_SIGNING_ALLOWED: NO          # 显式确认
    Release:
      CODE_SIGNING_ALLOWED: YES         # 覆盖 base，Release 允许签名
```

---

## 第四阶段：必需的文件

### 4.1 主 App Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>AppStoreName</string>         <!-- App Store 显示名 -->
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>appname</string>   <!-- 小写，用于 URL scheme -->
            </array>
        </dict>
    </array>
</dict>
</plist>
```

### 4.2 主 App Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.ggsheng.AppName</string>  <!-- Widget 共享数据用 -->
    </array>
</dict>
</plist>
```

### 4.3 Widget Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>AppName Widget</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
```

### 4.4 Widget Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.ggsheng.AppName</string>  <!-- 必须和主 App 一致 -->
    </array>
</dict>
</plist>
```

### 4.5 AppIcon Contents.json

```json
{
  "images" : [
    { "idiom" : "iphone", "scale" : "2x", "size" : "20x20" },
    { "idiom" : "iphone", "scale" : "3x", "size" : "20x20" },
    { "idiom" : "iphone", "scale" : "2x", "size" : "29x29" },
    { "idiom" : "iphone", "scale" : "3x", "size" : "29x29" },
    { "idiom" : "iphone", "scale" : "2x", "size" : "40x40" },
    { "idiom" : "iphone", "scale" : "3x", "size" : "40x40" },
    { "idiom" : "iphone", "scale" : "2x", "size" : "60x60" },
    { "idiom" : "iphone", "scale" : "3x", "size" : "60x60" },
    { "idiom" : "ipad", "scale" : "1x", "size" : "20x20" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "20x20" },
    { "idiom" : "ipad", "scale" : "1x", "size" : "29x29" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "29x29" },
    { "idiom" : "ipad", "scale" : "1x", "size" : "40x40" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "40x40" },
    { "idiom" : "ipad", "scale" : "1x", "size" : "76x76" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "76x76" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "83.5x83.5" },
    { "idiom" : "ios-marketing", "scale" : "1x", "size" : "1024x1024" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

**⚠️ Contents.json 的 `size` 字段含义：**
- `"size"` 是 **point size**，不是像素！
- `"20x20"` @2x = 实际 40×40 像素
- `"1024x1024"` @1x = 实际 1024×1024 像素（App Store 用）

### 4.6 AccentColor Contents.json

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.345",
          "green" : "0.780",
          "red" : "0.204"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

---

## 第五阶段：XcodeGen 生成项目

### 5.1 生成命令

```bash
cd ~/Desktop/ios-{AppName}
~/tools/xcodegen/bin/xcodegen generate
```

**成功输出：**
```
⚙️  Writing project...
Created project at /Volumes/.../ios-{AppName}/{AppName}.xcodeproj
```

**⚠️ 注意：**
- XcodeGen 每次运行会**完全重写** .xcodeproj 文件
- 不要手动编辑 .xcodeproj 里的任何内容，所有改动都改 project.yml 再重新 XcodeGen
- 如果有旧的 .xcodeproj，XcodeGen 会覆盖它

### 5.2 验证生成结果

```bash
# 确认 target 名称
grep -E 'name = [A-Z][A-Za-z]+;' {AppName}.xcodeproj/project.pbxproj \
  | grep -v 'PRODUCT_BUNDLE\|PRODUCT_NAME\|CODE_SIGN' \
  | head -10

# 确认 signing 配置
grep -B2 -A5 'buildConfiguration.*Release' {AppName}.xcodeproj/project.pbxproj \
  | grep CODE_SIGNING_ALLOWED

# 确认 Bundle ID
grep 'PRODUCT_BUNDLE_IDENTIFIER' {AppName}.xcodeproj/project.pbxproj
```

### 5.3 完整变更流程（必须遵守）

```
┌─────────────────────────────────────────────────────┐
│  本地修改 project.yml / 源码 / 资源文件              │
└─────────────────┬───────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────┐
│  git add → git commit → git push origin main       │
└─────────────────┬───────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────┐
│  MacinCloud: git pull origin main                   │
│  ~/tools/xcodegen/bin/xcodegen generate             │
│  rm -rf ~/Library/Developer/Xcode/DerivedData/*    │
│  xcodebuild build -project {AppName}.xcodeproj      │
│    -target {AppName} -configuration Debug           │
│    -destination 'platform=iOS Simulator,id={UDID}'  │
└─────────────────┬───────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────┐
│  ✅ BUILD SUCCEEDED → 打开 Xcode → Archive         │
└─────────────────────────────────────────────────────┘
```

---

## 第六阶段：Widget 数据共享

### 6.1 App Groups 配置

**主 App 写入：**
```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.ggsheng.AppName")
sharedDefaults?.set(encodedData, forKey: "habits")
sharedDefaults?.synchronize()
```

**Widget 读取：**
```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.ggsheng.AppName")
let data = sharedDefaults?.data(forKey: "habits")
```

**⚠️ entitlements 必须包含 App Group：**
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.ggsheng.AppName</string>
</array>
```

---

## 第七阶段：App Store Connect 上传

### 7.1 Archive 操作（VNC 桌面）

1. Xcode 打开 `{AppName}.xcodeproj`
2. 顶部 scheme 选择 `{AppName}`
3. **Product → Archive**（快捷键 ⌘⇧B）
4. Archive 完成 → **Window → Organizer** 打开
5. 选中 archive → **Distribute → App Store Connect → Sign and Upload**
6. Team 选择 **ZhiFeng Sun (9L6N2ZF26B)**
7. 等待上传完成 → **Validate App** 验证

### 7.2 App Store Connect 填写

| 字段 | 填写内容 |
|------|---------|
| App Name | `{AppStoreName}`（App Store 确认名称）|
| Bundle ID | `com.ggsheng.{AppName}` |
| Category | Productivity |
| Price | Free |
| Privacy Policy URL | `https://lauer3912.github.io/ios-{AppName}/docs/PrivacyPolicy.html` |

### 7.3 App 隐私（全部"否"）

- 健康/健身 ❌ | 位置 ❌ | 联系信息 ❌ | 标识用户 ❌
- 浏览历史 ❌ | 购买行为 ❌ | 崩溃日志 ❌ | 性能数据 ❌ | 广告 ❌

---

## 常见错误速查

| 错误信息 | 原因 | 解决 |
|---------|------|------|
| `Use the Signing & Capabilities editor` | signing 配置错误 | 确认 Release CODE_SIGNING_ALLOWED=YES |
| `Assign a team to the targets` | base level 没有 TEAM | 加 `DEVELOPMENT_TEAM: 9L6N2ZF26B` |
| `Invalid large app icon...alpha` | 1024 图标有透明 | PIL 转为 RGB 模式保存 |
| `Embedded binary not signed` | Widget Release 没开签名 | Widget configs Release 加 YES |
| `App Record Creation failed: name in use` | App Store 名称被占 | 换名称或删旧 Record 重建 |
| `errSecInternalComponent` | keychain 访问被拒 | 用 VNC 桌面操作 Sign and Upload |

---

## 附录：名字被占用 — 三种策略及完整 Xcode 项目修改步骤

> **⚠️ 本附录使用通用占位符，适用于任何 App。占位符含义：**
> - `{AppName}` = 当前本地项目使用的业务名（如 "FocusTimer"）
> - `{DesiredAppStoreName}` = 你想在 App Store 填的新名称（如 "FocusFlow"）
> - `{NewBundleIdAppName}` = 新 Bundle ID 的业务名（如 "FocusFlow" 换了Bundle ID后叫这个）
> - `{RepoFolder}` = 本地代码仓库文件夹名（通常等于 `{AppName}`）

---

### A.1 三层名称体系

| 层级 | 示例占位符 | 位置 | 能否改 |
|------|-----------|------|--------|
| App Store 名称 | `{DesiredAppStoreName}` | App Store Connect 填写 | ✅ 随时改 |
| Bundle ID | `com.ggsheng.{AppName}` | 打包进二进制 | ❌ 上传后不能改 |
| Display Name | `{AppName}` | Info.plist / PRODUCT_NAME | ✅ 可以改 |

---

### A.2 策略一（推荐）：只改 App Store 显示名，Bundle ID 不变

**触发条件：** App Store 名称被占，但 Bundle ID 没人用

**原理：** Bundle ID 是 App 的唯一标识，同一个 Bundle ID 可以对应不同的 App Store 名称（即同一个 App Record 可以改名）

**场景举例：** `{AppName}=FocusTimer`，App Store 名称 "FocusTimer" 被占 → 想改成 "FocusFlow"，Bundle ID `com.ggsheng.FocusTimer` 没被占

**需要修改的文件：**

#### 文件 1：`project.yml`

```yaml
# name = Xcode 项目文件名（改成和 App Store 名称一致更好）
name: {DesiredAppStoreName}                  # 例如：FocusFlow

targets:
  # target 名称（Xcode 左侧项目树显示的名字）
  {DesiredAppStoreName}:                     # 例如：FocusFlow
    settings:
      base:
        # PRODUCT_NAME = 用户手机上 App 图标下方显示的名字
        PRODUCT_NAME: {DesiredAppStoreName}  # 例如：FocusFlow（改了！）
        # Bundle ID 保持不变（同一个 App Record）
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{AppName}   # 例如：com.ggsheng.FocusTimer
        INFOPLIST_FILE: {AppName}/Info.plist  # 源码文件夹没改名，路径不变
        CODE_SIGN_ENTITLEMENTS: {AppName}/{AppName}.entitlements
    dependencies:
      - target: {DesiredAppStoreName}Widget   # 例如：FocusFlowWidget

  {DesiredAppStoreName}Widget:               # 例如：FocusFlowWidget
    settings:
      base:
        PRODUCT_NAME: {DesiredAppStoreName}Widget
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{AppName}.widget
        INFOPLIST_FILE: {AppName}Widget/Info.plist
        CODE_SIGN_ENTITLEMENTS: {AppName}Widget/{AppName}Widget.entitlements

  {DesiredAppStoreName}Tests:
    settings:
      base:
        PRODUCT_NAME: {DesiredAppStoreName}Tests

  {DesiredAppStoreName}UITests:
    settings:
      base:
        PRODUCT_NAME: {DesiredAppStoreName}UITests

schemes:
  {DesiredAppStoreName}:
    build:
      targets:
        {DesiredAppStoreName}: all
        {DesiredAppStoreName}Widget: all
        {DesiredAppStoreName}UITests: [test]
```

**project.yml 修改对照表（策略一）：**

| 字段 | 原值 | 新值 | 是否修改 |
|------|------|------|---------|
| `name:` | `{AppName}` | `{DesiredAppStoreName}` | ✅ 改 |
| Target 名称 | `{AppName}` | `{DesiredAppStoreName}` | ✅ 改 |
| Target `PRODUCT_NAME:` | `{AppName}` | `{DesiredAppStoreName}` | ✅ 改 |
| Target `PRODUCT_BUNDLE_IDENTIFIER:` | `com.ggsheng.{AppName}` | **`com.ggsheng.{AppName}`（不变）`** | ❌ |
| Target `INFOPLIST_FILE:` | `{AppName}/...` | **`{AppName}/...`（不变）`** | ❌ |
| Target `CODE_SIGN_ENTITLEMENTS:` | `{AppName}/...` | **`{AppName}/...`（不变）`** | ❌ |
| Widget target 名称 | `{AppName}Widget` | `{DesiredAppStoreName}Widget` | ✅ 改 |
| Widget Bundle ID | `com.ggsheng.{AppName}.widget` | **`com.ggsheng.{AppName}.widget`（不变）`** | ❌ |
| Scheme 名称 | `{AppName}` | `{DesiredAppStoreName}` | ✅ 改 |

#### 文件 2：`Info.plist`

```xml
<!-- 只改这一行 -->
<key>CFBundleDisplayName</key>
<string>{DesiredAppStoreName}</string>
```

#### 文件 3：`AppIcon.appiconset/Contents.json`

**无需修改**（`size` 字段是 point size，和 App 名称无关）

#### 文件 4：所有 `.swift` 源码

**通常无需修改**（除非代码里有硬编码的 App 名称字符串做特殊用途）

#### 文件 5：`AppStore/Listing.md`

```markdown
**App Name:** {DesiredAppStoreName}
**Bundle ID:** com.ggsheng.{AppName}    <!-- 不变 -->
```

**执行步骤：**

```bash
# 1. 本地修改 project.yml 的 name / target 名 / PRODUCT_NAME / scheme
# 2. 本地修改 Info.plist 的 CFBundleDisplayName
# 3. 提交推送
git add -A && git commit -m "Rename to {DesiredAppStoreName}: App Store name change only" && git push

# 4. MacinCloud
cd ~/Desktop/ios-{RepoFolder}
git pull origin main
~/tools/xcodegen/bin/xcodegen generate
# 注意：会生成新的 {DesiredAppStoreName}.xcodeproj
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild build -project {DesiredAppStoreName}.xcodeproj \
  -target {DesiredAppStoreName} -configuration Debug \
  -destination 'platform=iOS Simulator,id={UDID}'

# 5. VNC 桌面打开新的 {DesiredAppStoreName}.xcodeproj
# 6. Archive → Distribute → Sign and Upload
# 7. App Store Connect 填新名称 {DesiredAppStoreName}
```

---

### A.3 策略二：Bundle ID 被占，换 Bundle ID + 全新 App Record

**触发条件：** Bundle ID 被人抢先注册了，必须换 Bundle ID 才能上架

**原理：** Bundle ID 是全局唯一标识，一旦被他人注册无法使用。必须换新的 Bundle ID，因此也必须创建新的 App Record

**场景举例：** `{AppName}=FocusTimer`，Bundle ID `com.ggsheng.FocusTimer` 被人注册了 → 必须换新的 Bundle ID `com.ggsheng.FocusFlow`

**需要修改的文件：**

#### 文件 1：`project.yml`（全面修改）

```yaml
name: {NewBundleIdAppName}                  # 例如：FocusFlow

targets:
  {NewBundleIdAppName}:                     # 例如：FocusFlow
    settings:
      base:
        # ← Bundle ID 换了！
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{NewBundleIdAppName}
        PRODUCT_NAME: {NewBundleIdAppName}   # ← 显示名也改了
        INFOPLIST_FILE: {NewBundleIdAppName}/Info.plist  # ← 路径随文件夹改
        CODE_SIGN_ENTITLEMENTS: {NewBundleIdAppName}/{NewBundleIdAppName}.entitlements
    dependencies:
      - target: {NewBundleIdAppName}Widget   # ← 改了

  {NewBundleIdAppName}Widget:               # 例如：FocusFlowWidget
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{NewBundleIdAppName}.widget
        PRODUCT_NAME: {NewBundleIdAppName}Widget
        INFOPLIST_FILE: {NewBundleIdAppName}Widget/Info.plist
        CODE_SIGN_ENTITLEMENTS: {NewBundleIdAppName}Widget/{NewBundleIdAppName}Widget.entitlements

  {NewBundleIdAppName}Tests:
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{NewBundleIdAppName}Tests
        PRODUCT_NAME: {NewBundleIdAppName}Tests

  {NewBundleIdAppName}UITests:
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{NewBundleIdAppName}UITests
        PRODUCT_NAME: {NewBundleIdAppName}UITests

schemes:
  {NewBundleIdAppName}:
    build:
      targets:
        {NewBundleIdAppName}: all
        {NewBundleIdAppName}Widget: all
        {NewBundleIdAppName}UITests: [test]
```

**project.yml 修改对照表（策略二）：**

| 字段 | 原值 | 新值 | 是否修改 |
|------|------|------|---------|
| `name:` | `{AppName}` | `{NewBundleIdAppName}` | ✅ 改 |
| Target 名称 | `{AppName}` | `{NewBundleIdAppName}` | ✅ 改 |
| Target `PRODUCT_BUNDLE_IDENTIFIER:` | `com.ggsheng.{AppName}` | **`com.ggsheng.{NewBundleIdAppName}`** | ✅ 改 |
| Target `PRODUCT_NAME:` | `{AppName}` | `{NewBundleIdAppName}` | ✅ 改 |
| Target `INFOPLIST_FILE:` | `{AppName}/Info.plist` | **`{NewBundleIdAppName}/Info.plist`** | ✅ 改 |
| Target `CODE_SIGN_ENTITLEMENTS:` | `{AppName}/{AppName}.entitlements` | **`{NewBundleIdAppName}/{NewBundleIdAppName}.entitlements`** | ✅ 改 |
| Widget Bundle ID | `com.ggsheng.{AppName}.widget` | **`com.ggsheng.{NewBundleIdAppName}.widget`** | ✅ 改 |
| App Group ID | `group.com.ggsheng.{AppName}` | **`group.com.ggsheng.{NewBundleIdAppName}`**（可选）| ⚠️ 可选 |
| Folder 路径（source `path:`）| `{AppName}/` | **`{NewBundleIdAppName}/`** | ✅ 需配合文件夹改名 |

#### 文件 2：`Info.plist`

```xml
<key>CFBundleDisplayName</key>
<string>{NewBundleIdAppName}</string>
```

#### 文件 3：`Entitlements`

```xml
<!-- App Group ID：如果要换就改，否则不变 -->
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.ggsheng.{NewBundleIdAppName}</string>
</array>
```

#### 文件 4：源码文件夹重命名

```bash
# 必须把所有源码文件夹改名，且和 project.yml 的 path: 一致
mv {AppName}        {NewBundleIdAppName}
mv {AppName}Widget  {NewBundleIdAppName}Widget
mv {AppName}Tests   {NewBundleIdAppName}Tests
mv {AppName}UITests {NewBundleIdAppName}UITests
```

**⚠️ 注意：** 如果 App Group ID 也换了，`UserDefaults(suiteName:)` 里的字符串必须同步改：

```swift
// 主 App 和 Widget 都要改
UserDefaults(suiteName: "group.com.ggsheng.{NewBundleIdAppName}")
```

#### 文件 5：`AppStore/Listing.md`

```markdown
**App Name:** {NewBundleIdAppName}
**Bundle ID:** com.ggsheng.{NewBundleIdAppName}
```

**执行步骤：**

```bash
# 1. App Store Connect 删除旧的 App Record（如果属于你）
#    或放弃旧的，直接用新 Bundle ID 创建新 App Record

# 2. 本地重命名所有源码文件夹
mv {AppName}        {NewBundleIdAppName}
mv {AppName}Widget  {NewBundleIdAppName}Widget
mv {AppName}Tests   {NewBundleIdAppName}Tests
mv {AppName}UITests {NewBundleIdAppName}UITests

# 3. 修改 project.yml（所有 target name / PRODUCT_NAME / Bundle ID / paths）

# 4. 修改所有 Info.plist 的 CFBundleDisplayName

# 5. 如果 App Group 改了，同步改 entitlements 和所有 suiteName

# 6. 提交推送
git add -A && git commit -m "Full rename: Bundle ID to com.ggsheng.{NewBundleIdAppName}" && git push

# 7. MacinCloud
cd ~/Desktop/ios-{RepoFolder}
git pull origin main
~/tools/xcodegen/bin/xcodegen generate
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild build -project {NewBundleIdAppName}.xcodeproj \
  -target {NewBundleIdAppName} -configuration Debug \
  -destination 'platform=iOS Simulator,id={UDID}'

# 8. Archive → App Store Connect 新建 App Record（填 {NewBundleIdAppName}）
```

---

### A.4 策略三：App Store 名称保持，Display Name 换成另一个名字

**触发条件：** App Store 名称没人用，但想给本地显示取另一个名字（不在 App Store 卖）

**原理：** Display Name 只是用户手机上的显示名，App Store Connect 里的名称是独立的

**场景举例：** `{AppName}=FocusTimer`，App Store 没被占，但想在手机桌面上显示 "FocusFlow"

**需要修改的文件：**

#### 文件 1：`project.yml`

```yaml
name: {AppName}                            # Xcode 项目名不变

targets:
  {AppName}:
    settings:
      base:
        # 手机上显示的名字改了，但 App Store 还是叫 {AppName}
        PRODUCT_NAME: {DesiredDisplayName} # ← 改了！
        PRODUCT_BUNDLE_IDENTIFIER: com.ggsheng.{AppName}  # 不变
```

#### 文件 2：`Info.plist`

```xml
<key>CFBundleDisplayName</key>
<string>{DesiredDisplayName}</string>    <!-- 用户手机上显示这个名字 -->
```

**App Store Connect 里的 App Name 仍然填 `{AppName}`**

---

### A.5 三种策略对比

| | 策略一（推荐）| 策略二 | 策略三 |
|---|---|---|---|
| **触发条件** | App Store 名被占 | Bundle ID 被占 | Display Name 想另取 |
| **Bundle ID 变？** | ❌ 不变 | ✅ 换新的 | ❌ 不变 |
| **Display Name 变？** | ✅ 改 | ✅ 改 | ✅ 改 |
| **App Store 名变？** | ✅ 填新名 | ✅ 填新名 | ❌ 不变 |
| **旧 App Record** | 继续用 | 删除重建 | 继续用 |
| **修改文件数** | 2个 | 4-5个 | 2个 |
| **App Group 要改？** | ❌ 不变 | ⚠️ 可选 | ❌ 不变 |
| **需要换 xcodeproj？** | ✅ 会生成新的 | ✅ | ❌ |

### A.6 判断用哪个策略

| 情况 | 策略 |
|------|------|
| App Store 名称被占，Bundle ID 没被占 | **策略一** |
| Bundle ID 被占（被人抢先注册）| **策略二** |
| App Store 名称没被占，想手机上显示另一个名字 | **策略三** |
| 想彻底换一个开始 | **策略二（删除旧 App Record）** |

---

### A.7 占位符汇总

| 占位符 | 含义 | 举例 |
|--------|------|------|
| `{AppName}` | 当前本地项目的业务名 | FocusTimer |
| `{DesiredAppStoreName}` | 想在 App Store 填的新名称 | FocusFlow |
| `{NewBundleIdAppName}` | 换了 Bundle ID 后的业务名 | FocusFlow |
| `{DesiredDisplayName}` | 想在手机桌面显示的名字 | FocusFlow |
| `{RepoFolder}` | 本地仓库文件夹名 | ios-FocusTimer |
| `{UDID}` | 模拟器 UDID | 59030A31-... |
