# iOS App 上架指南 — HabitArcFlow

> **⚠️ 通用 SOP 已迁移至 workspace 根目录**
>
> **完整通用上架流程（适用所有 iOS App）：**
> 📄 `/root/.openclaw/workspace/SOP-iOS-AppStore-Launch.md`
>
> 本文件仅包含 **HabitArcFlow 项目特定**的操作步骤。

---

## 本项目的关键信息

| 字段 | 值 |
|------|-----|
| App Store 名称 | HabitArcFlow |
| Bundle ID | `com.ggsheng.HabitGo`（策略一只改显示名，Bundle ID 不变）|
| Display Name | HabitArcFlow |
| 隐私政策 URL | `https://lauer3912.github.io/ios-HabitGo/docs/PrivacyPolicy.html` |
| 隐私答案 | 全部"否" |
| Simulator UDID | `59030A31-1FAA-43F2-96AC-B36521085127` |
| App Group | `group.com.ggsheng.HabitGo` |
| Team | ZhiFeng Sun (9L6N2ZF26B) |

---

## 项目特定步骤

### 1. 修改显示名后的 Archive（策略一）

HabitArcFlow 已完成此步骤。记录以备后续参考：

```bash
# 修改的文件：
# - project.yml: name / target 名 / PRODUCT_NAME / scheme → HabitArcFlow
# - Info.plist: CFBundleDisplayName → HabitArcFlow
# - Bundle ID: com.ggsheng.HabitGo（未变）

# XcodeGen 生成后会创建：
#   HabitArcFlow.xcodeproj  ← 用这个打开，不是旧的 HabitGo.xcodeproj
```

### 2. 本次上传的 Build

- Archive 成功，Build 已上传 App Store Connect
- App Store Connect App ID：`com.ggsheng.HabitGo` 对应的 Record

---

## 通用 SOP 索引

| 主题 | 在通用 SOP 中的位置 |
|------|---------------------|
| AppIcon HIG 规范 | SOP-iOS-AppStore-Launch.md → 第二阶段 |
| project.yml 完整模板 | SOP-iOS-AppStore-Launch.md → 第三阶段 |
| Signing 配置详解 | SOP-iOS-AppStore-Launch.md → 3.2 节 |
| 名字被占用三策略 | SOP-iOS-AppStore-Launch.md → 附录 A |
| 截图方法 | SOP-iOS-AppStore-Launch.md → 第五阶段 |
| Archive 上传步骤 | SOP-iOS-AppStore-Launch.md → 第七阶段 |
