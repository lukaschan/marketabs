# MarketTabs — 三站聚合浏览器 App（iOS 16+） By 千问办公

一个 SwiftUI + WKWebView 的 iOS App，将三个网站整合为底部标签栏中的独立页面：

| Tab | 网站 | 图标 |
|----|------|------|
| 行情 | https://lite.marketgrep.com | chart.line.uptrend.xyaxis |
| 美元流动性 | https://dollarliquidity.com | dollarsign.circle |
| 市场历史 | https://historyofmarket.com | book.closed |

## 功能特性

- **自适应双布局**：iPhone 使用底部标签栏；iPad（含横屏、分屏大窗）自动切换为左侧边栏布局，边栏含应用标题、图标导航项（选中高亮）与当前来源提示，所有页面常驻内存、切换零重载
- 页面内链接点击自由跳转（WKNavigationDelegate 统一放行）
- 顶部导航栏提供「返回上一级 / 前进 / 刷新 / 分享」按钮
- **下拉刷新**：网页滚动到顶部后继续下拉即可重新加载（iOS 原生 UIRefreshControl 观感，加载完成自动收起）
- 支持系统边缘右滑手势返回上一页（allowsBackForwardNavigationGestures）
- 顶部 3pt 渐长式加载进度条（Safari 同款观感）
- 加载中点击刷新按钮可停止加载（图标切换为 ×）
- 现代视觉：半透明毛玻璃导航栏与标签栏、系统深浅色自适应、accent 蓝主色

## 文件清单

```
MarketTabs/
├── .github/workflows/build-ipa.yml  # GitHub Actions 云端编译工作流
├── project.yml            # XcodeGen 工程定义（CI 自动生成 .xcodeproj）
├── MarketTabsApp.swift    # App 入口 + 全局外观配置
├── ContentView.swift      # 双布局路由（iPhone TabView / iPad 侧边栏）与 Tab 定义
├── BrowserPageView.swift  # 单页面容器（导航栏、进度条、分享）
└── WebView.swift          # WKWebView 封装、浏览器状态模型与下拉刷新
```

## GitHub Actions 云端编译 IPA（推荐，无需本地 Xcode）

1. 将整个 `MarketTabs` 目录推送到 GitHub 仓库（注意 `.github/` 是隐藏目录，勿遗漏）
2. 仓库 → Actions → **Build iOS IPA** → Run workflow 手动触发；或推送 `v*` 标签（`git tag v1.0.0 && git push --tags`）自动触发并创建 Release
3. 构建约 5–10 分钟，完成后在运行页面底部 **Artifacts** 下载 `MarketTabs-unsigned-ipa`

CI 流程：XcodeGen 从 `project.yml` 生成工程 → xcodebuild 免签名 Release archive → 打包 Payload → 上传 Artifact（打标签时同时附到 Release）。

### 未签名 IPA 如何安装到设备

| 方式 | 说明 |
|------|------|
| Sideloadly（推荐） | Windows/Mac 客户端，拖入 IPA + 免费 Apple ID 自动重签并安装 |
| AltStore | 免费 Apple ID，证书 7 天需连电脑续签 |
| Xcode | Mac 上把 IPA 解压出的 `.app` 拖到 Devices 窗口的设备上 |
| 付费开发者账号 | 修改 workflow 去掉免签名参数，改用证书 secrets 签名 |

## 如何在 Xcode 中本地创建工程（可选）

本地有 Mac + Xcode 时，也可以不走 Actions：

```bash
brew install xcodegen
xcodegen generate
open MarketTabs.xcodeproj   # Cmd+R 直接跑模拟器
```

## 常见扩展方向
