# HOW-TO: Submit HabitGo to App Store Connect

## Prerequisites

- Apple Developer Account ($99/year)
- Xcode 15+ installed on your Mac
- App Store Connect account set up
- macOS Sonoma/Ventura on your Mac

---

## Step 1: Update Project Settings

Before building, verify these settings in Xcode:

1. Open `ios-HabitGo/HabitGo.xcodeproj` in Xcode
2. Select the HabitGo target → Signing & Capabilities
3. Check **Automatically manage signing**
4. Select your **Team** (Apple Developer account)
5. Bundle Identifier: `com.ggsheng.HabitGo`
6. Version: `1.0.0`
7. Build: `1`

---

## Step 2: Create App Store Connect Record

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platforms:** iOS
   - **Name:** HabitGo
   - **Primary Language:** English
   - **Bundle ID:** com.ggsheng.HabitGo
   - **SKU:** HabitGo-001
4. Click **Create**

---

## Step 3: Build and Archive

In Xcode:

```bash
# Open the project
open ios-HabitGo/HabitGo.xcodeproj

# Or build from command line:
cd ios-HabitGo
xcodebuild -project HabitGo.xcodeproj \
  -scheme HabitGo \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

For **Archive** (for App Store submission):
1. Select **Generic iOS Device** (or any physical device, not simulator)
2. Product → Archive
3. Wait for archive to complete
4. Window → Organizer → Archives
5. Select the archive → **Distribute App**
6. Choose **App Store Connect** → **Sign and Upload**
7. Follow the prompts

---

## Step 4: Fill App Store Information

In App Store Connect, go to your app's page and fill in:

### 1. App Information
- **Category 1:** Productivity
- **Category 2:** (optional)
- **Content Rights:** No

### 2. Pricing and Availability
- **Price:** Free
- **Availability:** All countries

### 3. App Privacy
Answer all questions **honestly** based on your app's data collection:

| Question | Answer |
|----------|--------|
| Health / Fitness | No |
| Location | No |
| Contact Info | No |
| Identifiers | No |
| Browsing History | No |
| Purchases | No |
| Crash Logs | No |
| Performance Data | No |
| Advertising | No |

- **Data Types:** Do not collect any data
- **Privacy Policy URL:** `https://lauer3912.github.io/ios-HabitGo/docs/PrivacyPolicy.html`

### 4. Prepare for Submission

#### Screenshots (required)
All screenshots must be in English. Provide these sizes:

| Device | Size (px) | Orientation |
|--------|-----------|-------------|
| iPhone 6.7" | 1290×2796 | Portrait |
| iPhone 6.5" | 1242×2688 | Portrait |
| iPad 12.9" | 2048×2732 | Landscape |

**HabitGo has 4 tabs:** Habits / History / Stats / Settings. Required screenshots:

1. `01_Habits.png` — Main habits list
2. `02_History.png` — Calendar history view
3. `03_Stats.png` — Statistics dashboard
4. `04_Settings.png` — Settings page
5. `05_AddHabit_Sheet.png` — Add habit modal sheet

**To capture screenshots using XCUITest (on MacinCloud VNC):**

```bash
cd ~/Desktop/ios-HabitGo
git pull origin main

# Generate Xcode project
~/tools/xcodegen/bin/xcodegen generate

# Open in Xcode
open HabitGo.xcodeproj

# Or build from command line (iPhone 16 Pro Max 6.7"):
xcodebuild -project HabitGo.xcodeproj \
  -scheme HabitGo \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  -test-target HabitGoUITests \
  -only-testing:HabitGoUITests/HabitGoUITests/testAllTabs \
  build

# Screenshots will be saved to: /tmp/HabitGoScreenshots/
ls /tmp/HabitGoScreenshots/

# Copy to project:
cp /tmp/HabitGoScreenshots/*.png AppStore/Screenshots/
```

Screenshot script: `AppStore/screenshot_script.sh`

#### App Description
See `Listing.md` in this folder for full description text.

#### Keywords
See `Listing.md` in this folder for keywords.

#### Promotional Text
Optional — can be updated anytime without a new version.

#### What's New in This Version
```
1.0.0 — Initial release
- Track unlimited daily habits
- Streak tracking keeps you motivated
- Beautiful, simple design
- Fully private — all data stays on your device
```

#### Support URL
`https://lauer3912.github.io/ios-HabitGo/docs/PrivacyPolicy.html`

#### Marketing URL
(optional)

---

## Step 5: Submit for Review

1. In App Store Connect, go to your app → **Submit for Review**
2. Verify all information is complete
3. Click **Submit to App Review**

**Review Time:** Typically 24-48 hours

---

## Common Rejection Reasons

1. **Incomplete App Privacy answers** — Answer all 9 questions
2. **Screenshots not in English** — Use English-only simulator screenshots
3. **Missing App Icon** — Ensure all 15 AppIcon sizes are present
4. **Crash on launch** — Test on physical device before submitting
5. **Login required** — HabitGo has no login, but if you add one, make it optional

---

## Post-Approval

Once approved:
1. Set **Release Date** to automatic or choose a date
2. Enable **Automatic** updates for faster adoption
3. Monitor sales and reviews in App Store Connect

---

## 附录：App 名字被占用的解决方案

### 三层名称体系

| 层级 | 示例 | 能否改 |
|------|------|--------|
| App Store 名称 | HabitArcFlow | ✅ 随时改 |
| Bundle ID | com.ggsheng.HabitGo | ❌ 上传后不能改 |
| Display Name | HabitArcFlow | ✅ 可以改 |

### 策略一：只改 App Store 名称（推荐）

**适用：** 名称被占但 Bundle ID 没人用

1. App Store Connect 填一个可用名称
2. 本地 PRODUCT_NAME 保持原名
3. 打包上传后 App Store 显示你填的名称

**HabitGo → HabitArcFlow 就是这个策略：**
- Bundle ID `com.ggsheng.HabitGo` 不变
- App Store Connect 新建时填 `HabitArcFlow`
- 本地 Display Name 同步改为 `HabitArcFlow`

### 策略二：彻底换名重建

**适用：** 非常想换名字

1. App Store Connect 删除旧 App Record
2. 本地 project.yml 全部改名（name + PRODUCT_NAME）
3. Info.plist 的 CFBundleDisplayName 改名
4. 重新 Archive → App Store Connect 新建 App Record

### 判断

| 情况 | 策略 |
|------|------|
| 名称被占，Bundle ID 没被占 | 策略一 |
| 名称和 Bundle ID 都被占 | 换产品方向 |
| 想彻底换新名字 | 策略三 |
