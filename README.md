# 美食菜谱应用

基于 Flutter 的跨平台美食菜谱应用，支持远程数据加载、分类筛选、收藏等功能。

## 功能特性

- 📱 **跨平台支持**: Web、Android、iOS
- 🌐 **远程数据加载**: 从 Gitee/GitHub 获取菜谱数据
- 🏷️ **分类筛选**: 按菜系分类浏览菜谱
- ❤️ **收藏功能**: 收藏喜欢的菜谱
- 🔍 **搜索功能**: 按菜名搜索
- 📋 **菜谱详情**: 查看食材、做法、营养信息

## 技术栈

- Flutter 3.44+
- Dart 3.12+
- Provider (状态管理)
- Dio (网络请求)
- SharedPreferences (本地持久化)

## 快速开始

### 环境要求

- Flutter SDK 3.44+
- Dart SDK 3.12+

### 安装依赖

```bash
flutter pub get
```

### 运行项目

```bash
# Web
flutter run -d chrome

# Android
flutter run -d <device_id>

# iOS
flutter run -d <device_id>
```

## 数据来源

应用采用**远程加载为主，本地后备为辅**的策略：

### 远程数据源

- **Web 平台**: GitHub Raw
  ```
  https://raw.githubusercontent.com/yitingw159/final_groupwork_recipes/main/data/meals.json
  ```

- **移动端**: Gitee Raw
  ```
  https://gitee.com/Yiting_world/recipes_data/raw/master/data/meals.json
  ```

### 本地后备数据

当远程加载失败时，应用会自动使用本地资源文件 `data/meals.json`。

## 项目结构

```
├── lib/
│   ├── main.dart              # 入口文件
│   ├── models/                # 数据模型
│   │   └── meal.dart          # 菜谱模型
│   ├── pages/                 # 页面组件
│   │   ├── home_page.dart     # 首页
│   │   ├── search_page.dart   # 搜索页
│   │   ├── favorites_page.dart # 收藏页
│   │   ├── meal_detail_page.dart # 菜谱详情页
│   │   └── about_page.dart    # 关于页
│   ├── providers/             # 状态管理
│   │   └── meal_provider.dart # 菜谱状态管理
│   └── services/              # 服务层
│       └── data_service.dart  # 数据加载服务
├── data/
│   └── meals.json             # 本地数据文件
├── android/                   # Android 原生配置
├── ios/                       # iOS 原生配置
├── web/                       # Web 配置
└── pubspec.yaml               # 项目依赖配置
```

## 运行截图

应用包含以下页面：

1. **首页**: 菜谱列表 + 分类筛选标签栏
2. **搜索页**: 按菜名搜索菜谱
3. **收藏页**: 查看已收藏的菜谱
4. **关于页**: 项目介绍信息

## 小组分工

| 组员 | 姓名 | 任务 |
|------|------|------|
| 组长 | 王怡婷 | 项目搭建 + 远程数据加载 + 状态管理 |
| 组员A | 廖春花 | 完善首页UI |
| 组员B | 周伟佳 | 完善详情页 + 烹饪计时器 |
| 组员C | 陈嘉玲 | 收藏功能 + 本地持久化 |
| 组员D | 岳沛珂 | 完善搜索页：新增热门食材标签栏（食材反搜）、搜索历史记录（SharedPreferences本地持久化）、卡片式搜索结果列表（含菜名/分类/地区/烹饪时间/食材预览）、空结果友好提示及默认状态引导界面 |
| 组员E | 杨美媛 | 暗色模式 + 关于/合规页 |
| 组员F | 杨顺粉 | 扩充数据 + 真机运行测试 |

## 开发说明

### 远程数据验证

在浏览器开发者工具 Console 中查看日志：
- 远程加载成功: `远程数据加载成功，共 N 条菜谱`
- 本地后备加载: `远程数据加载失败: xxx，尝试使用本地数据` → `本地数据加载成功，共 N 条菜谱`

### 构建发布版本

```bash
# Web
flutter build web

# Android APK
flutter build apk

# iOS
flutter build ios
```

## 许可证

MIT License
