## **项目开发规则与技术指南 (V1.0)**

### **1. 项目概述与核心理念**

#### **1.1 项目目标**
本项目旨在以最小可行产品（MVP）的形式，快速开发并验证一个核心功能完备的视频平台。核心流程包括：**视频上传 -> 后台转码 -> 客户端播放**。

#### **1.2 核心理念：MVP 优先**
1.  **极简主义**: 只实现核心功能，避免过度设计。
2.  **依赖最小化**: 优先使用语言内置功能和轻量级库，避免引入复杂的中间件（如 Redis, RabbitMQ）。
3.  **本地化优先**: 优先使用本地服务器资源（磁盘存储、本地进程），在验证模式成功前，不依赖昂贵的云服务。
4.  **快速迭代**: 以此为基础，快速验证市场，为后续扩展（参考第 6 节）奠定坚实基础。

---

### **2. 后端开发规则 (Go)**

#### **2.1 技术栈**
*   **语言/框架**: Go / Gin
*   **数据库**: SQLite (通过 GORM 操作)
*   **视频处理**: 本地安装的 FFmpeg
*   **部署**: 单个二进制可执行文件

#### **2.2 API 设计**
*   **风格**: 必须遵循 RESTful 设计原则。
*   **数据格式**: 所有请求体和响应体必须使用 JSON 格式。
*   **端点**: 核心 API 端点应遵循 `/api/<resource>` 格式（例如 `/api/videos`）。
*   **响应码**: 必须使用标准的 HTTP 状态码（200, 201, 202, 400, 404, 500等）来清晰地表示请求结果。

#### **2.3 视频处理**
*   **异步执行**: 视频上传成功后，**必须**启动一个独立的 Goroutine (`go func()`) 来执行耗时的 FFmpeg 转码任务，并立即向客户端返回 `202 Accepted` 响应。
*   **转码格式**: 所有视频**必须**被转码为 HLS (HTTP Live Streaming) 格式（`.m3u8` 播放列表和 `.ts` 片段文件）。
*   **原子操作**: 应同时生成视频缩略图。

#### **2.4 存储**
*   **路径**: 原始上传文件和转码后的媒体文件**必须**存储在本地服务器磁盘的指定目录中（例如 `./data/uploads` 和 `./data/media`）。
*   **命名**: 文件和目录**必须**使用 UUID 进行唯一命名，以避免冲突。

#### **2.5 数据库**
*   **ORM**: **必须**使用 GORM 来操作 SQLite 数据库，以保证代码的简洁性和安全性。
*   **模型**: GORM 模型（struct）应定义在独立的 `models` 包中。
*   **迁移**: **必须**在程序启动时使用 GORM 的 `AutoMigrate` 功能来确保数据库表结构与模型同步。

---

### **3. 前端开发规则 (Flutter)**

#### **3.1 核心架构**
*   **强制遵循**: **必须**遵循以下定义的分层架构（清洁架构）。所有代码的组织和依赖关系都不能违反此规则。

#### **3.2 目录结构**
```
lib/
├── config/             # 应用配置
├── data/               # 数据层
│   ├── model/          # 数据传输对象 (DTOs)
│   ├── repositories/   # 数据仓库
│   └── services/       # API服务
├── domain/             # 领域层
│   └── models/         # 业务模型
├── routing/            # 路由管理
├── ui/                 # UI层
│   ├── core/           # 共享UI
│   └── <feature_name>/ # 按功能划分的模块
│       ├── view_model/
│       └── widgets/
└── main.dart           # 应用入口与依赖注入
```

#### **3.3 各层职责与规则**

1.  **Data Layer (`/data`)**:
    *   **`services`**: 直接调用 `http` 库与后端 API 通信，方法**必须**返回 `Future<DataModel>`。
    *   **`model`**: 类名以 `ApiModel` 结尾，字段**必须**与 API JSON 结构完全匹配，**必须**提供 `fromJson` 和 `toDomainModel()` 方法。
    *   **`repositories`**: UI 层访问数据的**唯一**入口。它依赖 `services`，但其公共方法**必须**返回 `Future<DomainModel>`。

2.  **Domain Layer (`/domain`)**:
    *   **完全独立**: **严禁**导入 `data` 或 `ui` 层的任何文件。
    *   **`models`**: 纯粹的 Dart 业务对象，**禁止**包含任何序列化/反序列化逻辑。

3.  **UI Layer (`/ui`)**:
    *   **依赖方向**: **只能**依赖 `domain` 层和 `view_model`。
    *   **`view_model`**: 使用 `ChangeNotifier`，通过构造函数注入 `Repository`。负责所有业务逻辑和状态管理。
    *   **`widgets`**: 只负责 UI 渲染。通过 `Provider` (`context.watch` 或 `Consumer`) 获取状态，通过 `context.read` 调用 `ViewModel` 的方法。

#### **3.4 状态管理与依赖注入**
*   **工具**: **必须**使用 `provider` 包。
*   **注入点**: `main.dart` 是配置所有依赖注入的**唯一**位置，**必须**使用 `MultiProvider` 和 `ProxyProvider` 来构建依赖链。

---

### **4. 通用开发规则**

#### **4.1 版本控制**
*   **工具**: **必须**使用 Git。
*   **分支模型**: 推荐使用简化的 Git Flow：
    *   `main`: 稳定的、可发布的代码。
    *   `develop`: 开发主分支。
    *   `feature/<feature-name>`: 开发新功能的分支，完成后合并到 `develop`。

#### **4.2 代码风格**
*   **Go**: **必须**在提交前使用 `gofmt` 或 `goimports` 格式化代码。
*   **Flutter**: **必须**遵循 Flutter Linter 规则，解决所有 analyzer 警告。

#### **4.3 配置管理**
*   **硬编码**: **严禁**在代码中硬编码敏感信息或可变配置（如 API 地址）。**必须**将它们统一存放在 `config` 目录中。

#### **4.4 错误处理**
*   **后端**: API 必须对错误进行捕获，并返回明确的错误信息和对应的 HTTP 状态码。
*   **前端**: UI 必须优雅地处理错误状态（如显示错误提示信息），不能直接崩溃。`ViewModel` 负责捕获来自 `Repository` 的异常。

---

### **4.5 Monorepo 目录结构与规范**

本项目采用 Monorepo（单一代码仓库）方式组织代码，将前后端代码放在同一个仓库中管理。

#### **根目录结构**
```
video_platform_mvp/
├── .github/                # GitHub 相关配置，如 CI/CD 工作流
│   └── workflows/
│       └── ci.yml
├── .gitignore              # 全局 Git 忽略文件
├── backend/                # Go 后端项目根目录
│   ├── go.mod
│   ├── go.sum
│   ├── main.go
│   ├── config.go
│   ├── database.go
│   ├── handlers/
│   ├── models/
│   └── processing/
├── frontend/               # Flutter 前端项目根目录
│   ├── lib/
│   │   ├── config/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── routing/
│   │   ├── ui/
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── pubspec.lock
├── scripts/                # 项目通用脚本
│   ├── build.sh           # 一键构建前后端
│   └── run_dev.sh         # 一键启动开发环境
└── README.md              # 项目说明文档
```

#### **后端目录结构**
```
backend/
├── go.mod                  # Go 模块依赖文件
├── go.sum                  # 依赖校验和
├── main.go                 # 程序主入口
├── config.go               # 应用配置
├── database.go             # 数据库相关
├── handlers/               # HTTP 请求处理器
│   └── video_handler.go    # 视频相关 API
├── models/                 # 数据库模型
│   └── video.go           # Video 表结构
└── processing/             # 视频处理逻辑
    └── processor.go        # FFmpeg 转码与截图
```

#### **前端目录结构**
```
frontend/lib/
├── config/
│   └── app_config.dart     # 应用配置
├── data/                   # 数据层
│   ├── model/
│   │   └── video_api_model.dart
│   ├── repositories/
│   │   └── video_repository.dart
│   └── services/
│       └── api_service.dart
├── domain/                 # 领域层
│   └── models/
│       └── video.dart
├── routing/                # 路由管理
│   └── app_router.dart
├── ui/                     # UI 层
│   ├── core/              # 共享 UI
│   │   └── shared_video_player.dart
│   └── video/             # 视频功能模块
│       ├── view_model/
│       │   └── video_view_model.dart
│       └── widgets/
│           ├── home_screen.dart
│           ├── player_screen.dart
│           └── video_list_widget.dart
└── main.dart              # App 入口与依赖注入
```

#### **工作流程规范**

1. **克隆与开发**:
   * 开发者通过克隆单一仓库即可获得完整项目代码。
   * 前后端开发者需遵循各自的目录规范进行开发。

2. **本地开发环境**:
   * 后端: `cd backend && go run .`
   * 前端: `cd frontend && flutter run`
   * 可使用 `scripts/run_dev.sh` 一键启动完整环境。

3. **API 联调**:
   * 前端 `config/app_config.dart` 中配置开发环境 API 地址。
   * 建议使用本机局域网 IP（如 `http://192.168.1.100:8080`）便于移动设备访问。

4. **代码提交规范**:
   * 提交信息必须清晰标识修改范围，如：
     * `feat(backend): add video like endpoint`
     * `fix(frontend): player controls not showing`
   * 提交前必须完成各自的代码格式化与 lint 检查。

5. **CI/CD 规范**:
   * GitHub Actions 配置必须包含：
     * 后端: 运行单元测试、`gofmt` 检查。
     * 前端: Flutter lint 与静态分析。
   * 所有检查通过后才允许合并到主分支。

---

### **5. 工作流程：添加新功能**

所有新功能的开发**必须**遵循以下自下而上的流程：

1.  **定义模型**: 在 `domain/models` 中定义新的业务模型。
2.  **实现数据层**:
    *   在 `data/model` 中创建对应的 `ApiModel`。
    *   在 `data/services` 中添加新的 API 调用方法。
    *   在 `data/repositories` 中实现新的方法，完成数据获取和模型转换。
3.  **实现UI逻辑**:
    *   在 `ui/<feature>/view_model` 中创建或更新 `ViewModel`，注入 `Repository`，并实现状态管理逻辑。
4.  **实现UI界面**:
    *   在 `ui/<feature>/widgets` 中创建新的屏幕（Screen）和组件（Widget）。
    *   使用 `Provider` 连接 `ViewModel` 和 UI。
5.  **配置依赖注入**: 在 `main.dart` 中为新的 `Repository` 和 `ViewModel` 添加注入规则。

---

### **6. MVP 之后的演进方向**

本套规则的设计旨在简化当前开发，并为未来的扩展提供便利。当项目验证成功后，可按以下方向平滑升级：
*   **数据库**: `SQLite` -> `PostgreSQL` / `MySQL` (如 AWS RDS)
*   **存储**: `本地磁盘` -> `云对象存储` (如 AWS S3)
*   **视频处理**: `本地 Goroutine` -> `分布式消息队列 + Serverless 函数` (如 AWS SQS + Lambda)
*   **内容分发**: `本地静态服务` -> `CDN` (如 AWS CloudFront)
