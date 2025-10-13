# 来易卦 (LaiYiGua) - 周易占卜应用

<div align="center">
  <img src="LaiYiGua/Assets.xcassets/AppIcon.appiconset/bagua.png" alt="来易卦" width="120" height="120">
  
  ![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
  ![Language](https://img.shields.io/badge/language-Swift-orange.svg)
  ![Framework](https://img.shields.io/badge/framework-SwiftUI-green.svg)
  ![iOS Version](https://img.shields.io/badge/iOS-15.0+-blue.svg)
</div>

## 📖 项目简介

来易卦是一个专业的周易占卜应用，采用传统的蓍草分卦法，结合现代AI技术，为用户提供完整的占卜体验。应用以传统易经文化为核心，通过互动式的蓍草动画和智能化的解卦分析，让古老的占卜艺术在移动设备上焕发新的活力。

## ✨ 核心功能

### 🎋 交互式蓍草占卜
- **真实蓍草模拟**：49根蓍草的完整分卦过程
- **拖拽分堆操作**：用户可通过拖拽手势分割蓍草堆
- **物理动画效果**：采用弹簧物理动画，模拟真实蓍草运动
- **实时卦象预览**：占卜过程中显示当前已生成的爻位

### 🤖 AI智能功能
- **问题精炼**：集成Firebase AI，智能优化占卜问题
- **重复检测**：自动检测近期3个月内的重复问题
- **智能解卦**：AI分析卦象含义，提供结构化解读

### 📊 卦象系统
- **完整六十四卦**：支持所有64卦的识别和解释
- **变爻标记**：红点标记变爻位置，动态闪烁效果
- **内外卦显示**：清晰展示内卦、外卦组合
- **卦象链接**：连接到专业周易网站获取详细解释

### 📱 用户体验
- **分页导航**：占卜、历史记录分页管理
- **完整流程导航**：从问题输入到结果保存的完整用户旅程

### 💾 数据管理
- **本地存储**：使用UserDefaults保存占卜记录
- **历史记录**：完整保存占卜问题、卦象、时间
- **一键保存退出**：占卜完成后可直接保存并返回历史页面

## 🏗️ 技术架构

### 开发框架
- **SwiftUI**：现代化的UI框架
- **Core Data**：数据持久化（预留）
- **Combine**：响应式编程
- **AVFoundation**：音频处理（可选）

### AI集成
- **Firebase AI**：问题精炼和重复检测
- **Web Scraping**：获取传统易经解释内容
- **智能分析**：结构化的占卜结果分析

### 动画系统
- **弹簧物理**：所有动画都采用弹簧物理效果
- **粒子系统**：30个动态粒子营造神秘氛围
- **手势识别**：拖拽、点击手势的精确响应

## 📁 项目结构

```
LaiYiGua/
├── LaiYiGuaApp.swift              # 应用入口
├── GoogleService-Info.plist       # Firebase配置
├── View/                          # SwiftUI视图层
│   ├── ContentView.swift         # 主界面（Tab导航）
│   ├── DivinationView.swift      # 占卜问题输入页
│   ├── SticksLayoutView.swift    # 蓍草动画交互页
│   ├── GuaResultView.swift       # 卦象结果展示页
│   ├── GuaDetailView.swift       # 详细解卦页面
│   └── HistoryView.swift         # 历史记录页面
├── Model/                         # 数据模型层
│   ├── DivinationRecord.swift    # 占卜记录数据模型
│   ├── InterpretationStrategy.swift # 解卦策略
│   └── HTMLContentExtractor.swift   # 网页内容提取
└── Assets.xcassets/              # 应用资源
    └── AppIcon.appiconset/       # 应用图标
```

## 🚀 安装与运行

### 环境要求
- **Xcode**: 15.0+
- **iOS**: 15.0+
- **Swift**: 5.9+

### 安装步骤

1. **克隆项目**
   ```bash
   git clone [repository-url]
   cd LaiYiGua
   ```

2. **配置Firebase**
   - 在Firebase Console创建新项目
   - 下载`GoogleService-Info.plist`文件
   - 将文件添加到项目根目录

3. **打开项目**
   ```bash
   open LaiYiGua.xcodeproj
   ```

4. **运行应用**
   - 选择目标设备或模拟器
   - 按 `Cmd + R` 运行

## 🎯 使用指南

### 基本占卜流程

1. **提出问题**
   - 在占卜页面输入你的问题
   - AI会自动精炼问题并检测重复

2. **蓍草分卦**
   - 通过拖拽手势分割49根蓍草
   - 点击操作完成三轮分卦过程
   - 重复6次生成完整六爻

3. **查看结果**
   - 查看生成的卦象和变爻信息
   - 点击"解卦"获取详细解释

4. **保存记录**
   - 可选择保存占卜记录
   - 在历史页面查看所有记录

### 界面导航

- **占卜页面**：主要的占卜功能入口
- **历史页面**：查看和管理历史占卜记录
- **设置选项**：应用配置和偏好设置

## 🛠️ 自定义配置

### 修改卦象数据
编辑`GuaResultView.swift`中的映射数据：
```swift
let guaFullMap: [String: [String]] = [
    // 修改八卦组合映射
]

let guaLinks: [String: String] = [
    // 修改卦象链接映射
]
```

### 调整动画效果
在`SticksLayoutView.swift`中修改弹簧动画参数：
```swift
.animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0), value: someValue)
```

### 自定义粒子效果
在`GuaResultView.swift`的`MysticalParticleView`中调整：
```swift
particles = (0..<30).map { _ in  // 修改粒子数量
    MysticalParticle(
        size: Double.random(in: 2...8),  // 修改粒子大小范围
        // 其他参数...
    )
}
```

## 🔧 技术特色

### 1. 传统算法现代化
- 严格按照传统蓍草分卦法实现
- 保持占卜结果的传统准确性
- 用户交互替代随机数生成

### 2. 物理动画系统
- 所有动画都采用弹簧物理效果
- 真实模拟蓍草的物理运动
- 提供沉浸式的操作体验

### 3. AI智能增强
- 问题质量优化
- 重复占卜检测
- 智能解卦分析

### 4. 响应式设计
- 支持不同屏幕尺寸
- 适配横竖屏切换
- 流畅的界面过渡

## 📝 更新日志

### v1.0.0 (当前版本)
- ✅ 完整的蓍草分卦动画系统
- ✅ AI问题精炼和重复检测
- ✅ 六十四卦完整支持
- ✅ 完整的历史记录系统
- ✅ 智能解卦分析功能

### 计划中的功能
- 🔄 社交分享功能
- 🔄 加入祷告词

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 🙏 致谢

- 感谢传统易经文化的传承者们
- 感谢开源社区的技术支持
- 感谢所有测试用户的宝贵反馈

---

<div align="center">
  <p>🌟 如果这个项目对你有帮助，请给一个星标支持！</p>
  <p>Made with ❤️ for traditional Chinese culture</p>
</div>
