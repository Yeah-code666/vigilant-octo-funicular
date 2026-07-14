# CampusCare

CampusCare 是一款使用 SwiftUI 构建的校园健康管理示例应用，提供每日健康打卡、健康评分、趋势分析、个性化建议和本地 AI 助手。

## 运行要求

- macOS
- Xcode 16 或更高版本
- iOS 16 或更高版本的模拟器或设备

项目不依赖第三方包、API Key 或后端服务。用户数据保存在设备本地的 `UserDefaults` 中。

## 开始运行

```bash
git clone https://github.com/Yeah-code666/CampusCare.git
cd CampusCare
open CampusCare.xcodeproj
```

在 Xcode 中：

1. 选择 `CampusCare` scheme。
2. 选择一台已安装的 iPhone 模拟器。
3. 按 `Command + R` 运行。

使用模拟器运行不需要配置开发者签名。如果需要在真机运行，请在 Xcode 的 `Signing & Capabilities` 中选择自己的 Apple Developer Team。

## 命令行构建

确保已经在 `Xcode > Settings > Components` 中安装 iOS 平台，然后执行：

```bash
xcodebuild \
  -project CampusCare.xcodeproj \
  -scheme CampusCare \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 项目结构

```text
CampusCare.xcodeproj     Xcode 工程
CampusCare/              应用源码和资源
CampusCareTests/         单元测试
CampusCareUITests/       UI 测试
```

## 数据更新设计

`AnalysisService` 是应用内统一的健康数据源。快速打卡会同时更新运行时状态和本地存储，首页、分析页、趋势页与 AI 助手会读取同一份数据。

## License

本项目当前未声明开源许可证。未经仓库所有者许可，请勿将代码用于再分发。
