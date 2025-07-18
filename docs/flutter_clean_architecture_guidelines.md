## **Flutter 项目前端编码规则与架构指南 (V1.0)**

### **1. 核心原则**

本项目遵循**分层架构（清洁架构）**，旨在实现以下目标：
*   **关注点分离 (SoC)**: UI、业务逻辑和数据源严格分开。
*   **高可测性**: 每一层都可以被独立测试。
*   **可维护性与可扩展性**: 修改一层不应影响其他层，添加新功能有清晰的模式可循。
*   **依赖倒置原则**: 依赖关系总是指向核心的 `domain` 层，即 **UI -> Domain <- Data**。

### **2. 目录结构**

所有新文件**必须**放置在以下指定的目录结构中。

```
lib/
├── config/             # 应用配置 (API基地址, Key等)
├── data/               # 数据层: 负责获取和存储数据
│   ├── model/          # 数据传输对象 (DTOs), 与API JSON结构完全匹配
│   ├── repositories/   # 数据仓库: UI层获取数据的唯一入口
│   └── services/       # 服务: 直接与外部数据源(如REST API)通信
├── domain/             # 领域层: 包含核心业务逻辑和业务对象
│   └── models/         # 业务模型: 纯粹的Dart对象，代表应用的核心概念
├── routing/            # 路由管理
├── ui/                 # UI层: 用户界面和用户交互
│   ├── core/           # 跨功能的共享UI元素
│   │   └── ui/         # (如共享的播放器、自定义按钮等)
│   └── <feature_name>/ # 按功能划分模块 (例如: video, auth)
│       ├── view_model/ # 状态管理与UI逻辑
│       ├── widgets/    # 该功能下的所有UI组件 (包括屏幕和子组件)
└── main.dart           # 应用入口和依赖注入 (组合根)
```

### **3. 各层职责与规则**

#### **3.1 Data Layer (`/data`)**
*   **职责**: 与外部世界（网络、数据库、设备存储）进行数据交换。
*   **规则**:
    1.  **`services`**:
        *   直接调用 `http` 或 `dio` 等库与 API 进行通信。
        *   方法**必须**返回 `Future<DataModel>` 或原始类型（如 `Future<bool>`）。**禁止**返回 `DomainModel`。
    2.  **`model` (Data Transfer Objects - DTOs)**:
        *   类名**必须**以 `ApiModel` 或 `Dto` 结尾 (如 `VideoApiModel`)。
        *   字段**必须**与 API 返回的 JSON 结构和 key 完全匹配。
        *   **必须**提供一个 `fromJson` 工厂构造函数。
        *   **必须**提供一个 `toDomainModel()` 方法，用于将数据模型转换为领域模型。
    3.  **`repositories`**:
        *   这是 `domain` 层和 `ui` 层访问数据的**唯一**入口。
        *   它依赖于 `services` 层。
        *   其公共方法**必须**返回 `Future<DomainModel>`。它负责调用 `service` 并通过 `toDomainModel()` 方法进行转换。
        *   未来如需添加缓存逻辑，**只能**在此层实现。

#### **3.2 Domain Layer (`/domain`)**
*   **职责**: 代表应用的核心业务规则和对象。
*   **规则**:
    1.  **完全独立**: 这一层**绝对不能**导入任何来自 `data` 或 `ui` 层的文件。它只能依赖 Dart 和 Flutter SDK。
    2.  **`models`**:
        *   是纯粹的 Dart 对象 (POCO/POJO)。
        *   **禁止**包含任何 `fromJson`, `toJson` 或转换逻辑。
        *   **禁止**依赖任何外部包（`http`, `provider` 等）。

#### **3.3 UI Layer (`/ui`)**
*   **职责**: 展示数据给用户，并处理用户的输入事件。
*   **规则**:
    1.  **依赖关系**: UI 层**只能**依赖 `domain` 层和自身的 `view_model`。**严禁**直接访问 `data` 层的任何部分（`repository` 除外，但通过 ViewModel 注入）。
    2.  **`view_model`**:
        *   是 UI 的“大脑”，负责管理 UI 状态和处理业务逻辑。
        *   **必须**使用 `ChangeNotifier`。
        *   通过构造函数注入 `Repository` 依赖。
        *   向外暴露状态（如 `List<Video> videos`）和公共方法（如 `fetchVideos()`）。
        *   所有异步操作、逻辑判断**必须**在此层完成。
    3.  **`widgets` (Screens & Widgets)**:
        *   应尽可能“笨拙”，只负责渲染。
        *   通过 `Provider` (`context.watch`, `Consumer`) 获取 `ViewModel` 的状态来构建 UI。
        *   当用户触发事件时（如点击按钮），**必须**调用 `ViewModel` 的相应方法 (`context.read<MyViewModel>().doSomething()`)，而不是自己处理逻辑。
        *   导航跳转应通过集中的 `AppRouter` 类进行。

### **4. 状态管理**

*   **官方指定**: 使用 `provider` 包。
*   **核心类**: `ChangeNotifier` 用于 `ViewModel`。
*   **状态获取**:
    *   在 `build` 方法中，使用 `context.watch<T>()` 或 `Consumer<T>` 来监听状态变化并重建UI。
    *   对于只调用方法而不监听变化的场景（如在 `onPressed` 回调中），**必须**使用 `context.read<T>()`。

### **5. 依赖注入**

*   **组合根 (Composition Root)**: `main.dart` 是配置所有依赖注入的唯一地方。
*   **注入方式**: 使用 `MultiProvider`。
*   **注入规则**:
    *   对于无依赖的服务（如 `ApiService`），使用 `Provider<T>`。
    *   对于依赖其他 Provider 的服务（如 `VideoRepository` 依赖 `ApiService`），使用 `ProxyProvider<A, T>`。
    *   对于 `ViewModel`（依赖 `Repository`），使用 `ChangeNotifierProxyProvider<A, T>`。

### **6. 命名约定**

*   **文件**: `snake_case.dart` (e.g., `video_repository.dart`)。
*   **类**: `PascalCase` (e.g., `VideoViewModel`)。
*   **方法/变量**: `camelCase` (e.g., `fetchVideos`)。
*   **UI 组件**: 如果是全屏页面，以 `Screen` 结尾 (e.g., `HomeScreen.dart`)。如果是可复用组件，以 `Widget` 结尾 (e.g., `VideoListWidget.dart`)。

### **7. 工作流程示例：添加“获取视频详情”功能**

当接到新需求时，AI **必须**遵循以下自下而上的流程：

1.  **Data Layer**:
    *   如果 API 有变动，更新 `data/model/video_detail_api_model.dart`。
    *   在 `data/services/api_service.dart` 中添加 `Future<VideoDetailApiModel> fetchVideoDetail(String uuid)` 方法。
2.  **Domain Layer**:
    *   创建或更新 `domain/models/video_detail.dart` 业务模型。
3.  **Data Layer (Repository)**:
    *   在 `data/repositories/video_repository.dart` 中添加 `Future<VideoDetail> getVideoDetail(String uuid)` 方法。此方法内部调用 `apiService` 并将 `ApiModel` 转换为 `DomainModel`。
4.  **UI Layer (ViewModel)**:
    *   在 `ui/video/view_model/video_view_model.dart` 中，添加状态变量（如 `VideoDetail? currentVideo`）和 `Future<void> fetchVideoDetail(String uuid)` 方法。该方法调用 `repository` 并更新状态，最后调用 `notifyListeners()`。
5.  **UI Layer (Widget)**:
    *   在需要展示详情的屏幕（如 `PlayerScreen`）中，通过 `context.read` 或 `initState` 调用 `viewModel.fetchVideoDetail()`。
    *   使用 `Consumer` 或 `context.watch` 监听 `viewModel.currentVideo` 的变化，并据此构建 UI。
