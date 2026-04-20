# 对 Flutter 快速开发框架的思考

如果要打造一个 Flutter 快速开发框架，第一步不是马上开始写代码，而是先想清楚：一个“快速开发框架”到底应该覆盖哪些基础能力。

我花了两天时间梳理这件事，最终把它归纳为下面几个核心模块。

## 快速开始

如果你想先把这个模板跑起来，再理解它的分层和选型，可以按下面的步骤开始。

### 环境要求

- Flutter 3.x
- Dart 3.x
- 已完成 iOS / Android / macOS 等平台开发环境配置

### 1. 获取项目

```bash
git clone <your-repository-url>
cd fdflutter
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 生成代码

当前项目使用了 Hive Adapter 和 Riverpod 代码生成，因此在首次运行前，建议先执行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. 运行项目

```bash
flutter run
```

## 启动时会做什么

应用入口位于 `lib/main.dart`，启动时会依次完成以下初始化：

- 初始化 Flutter 运行环境。
- 读取并恢复主题配置。
- 初始化依赖注入容器。
- 初始化 Hive 本地存储并注册数据适配器。
- 挂载 Riverpod 根作用域。
- 配置路由、国际化和主题系统。

这意味着项目在启动后，已经具备了状态管理、路由、本地存储、依赖注入、国际化和主题切换这些基础能力。

### 当前默认结构

这个模板当前已经接入了以下基础设施：

- `Riverpod`：负责状态管理。
- `Routemaster`：负责页面路由。
- `GetIt`：负责依赖注入。
- `Hive`：负责本地数据存储。
- `Flutter Localization`：负责多语言支持。
- `Adaptive Theme`：负责亮色 / 暗色主题切换。

如果你只是想基于它开始业务开发，那么通常只需要做三件事：

1. 在 `presentation/` 中新增页面和状态提供者。
2. 在 `domain/` 中补充实体和用例。
3. 在 `data/` 中接入远程或本地数据源。

## 框架需要具备的能力

- `状态管理`：应用中的全局状态、页面状态、异步状态都需要有统一方案，否则项目一大就容易失控。
- `网络请求管理`：需要支持请求拦截、响应拦截、错误处理、重试、统一配置等能力。
- `路由管理`：需要解决页面跳转混乱的问题，最好支持参数传递、嵌套路由和路由守卫。
- `UI 组件库`：Flutter 自身已经很强，但企业项目中通常仍需要统一风格的业务组件库。
- `数据持久化`：用户设置、缓存数据、离线数据都需要可靠的本地存储方案。
- `依赖注入`：当项目逐渐复杂后，服务注册和依赖获取需要标准化，这一项偏进阶，但很有价值。
- `国际化`：如果有多语言或出海需求，最好在项目启动阶段就纳入设计。
- `测试框架`：至少要支持单元测试、组件测试和集成测试，保障迭代质量。
- `调试工具`：帮助开发者快速定位问题、分析性能和排查异常。
- `CI/CD 集成`：自动化构建、测试和发布，是提升团队效率的重要一环。

## 技术选型

基于上面的需求，我优先参考了官方推荐和社区成熟方案，尽量选择 Flutter 生态里稳定、流行、维护活跃的库。下面是当前这套框架的选型。

### 1. 状态管理：Riverpod

- `库名`：`flutter_riverpod`
- `描述`：提供编译期安全、测试友好、可组合能力强的状态管理方案。
- `选择理由`：Riverpod 在灵活性和可维护性上表现很好，适合中大型项目使用。

```dart
@riverpod
Future<String> boredSuggestion(BoredSuggestionRef ref) async {
  final response = await http.get(
    Uri.https('boredapi.com', '/api/activity'),
  );
  final json = jsonDecode(response.body);
  return json['activity']! as String;
}

class Home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boredSuggestion = ref.watch(boredSuggestionProvider);

    return boredSuggestion.when(
      loading: () => const Text('loading'),
      error: (error, stackTrace) => Text('error: $error'),
      data: (data) => Text(data),
    );
  }
}
```

### 2. 网络请求管理：Dio

- `库名`：`dio`
- `描述`：功能完整的 Dart HTTP 客户端，支持拦截器、超时、取消请求、表单和流式传输等。
- `选择理由`：Dio 在 Flutter 社区已经非常成熟，扩展性强，适合统一封装 API 层。

```dart
final rs = await dio.get(
  url,
  options: Options(responseType: ResponseType.stream),
);

print(rs.data.stream);
```

### 3. 路由管理：Routemaster

- `库名`：`routemaster`
- `描述`：声明式路由方案，支持参数传递和路由守卫。
- `选择理由`：用 URL 驱动路由，结构直观，适合中大型应用管理复杂页面关系。

```dart
'/protected-route': (route) =>
    canUserAccessPage()
        ? MaterialPage(child: ProtectedPage())
        : const Redirect('/no-access'),
```

### 4. UI 组件库：TDesign Flutter

- `库名`：`tdesign_flutter`
- `描述`：腾讯 TDesign 的 Flutter 组件库。
- `选择理由`：组件风格统一，适合快速搭建企业级应用界面。

### 5. 数据持久化：Hive

- `库名`：`hive`
- `描述`：轻量且高性能的本地键值数据库。
- `选择理由`：读写效率高，使用简单，适合缓存和轻量数据存储。

```dart
final box = Hive.box('myBox');

box.put('name', 'David');

final name = box.get('name');

print('Name: $name');
```

### 6. 依赖注入：GetIt

- `库名`：`get_it`
- `描述`：简单直接的服务定位与依赖注入工具。
- `选择理由`：学习成本低，性能稳定，适合作为项目中的依赖注册中心。

```dart
final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<AppModel>(AppModel());
}

MaterialButton(
  child: const Text('Update'),
  onPressed: getIt<AppModel>().update,
),
```

### 7. 国际化：Flutter Localization

- `库名`：`flutter_localization`
- `描述`：Flutter 官方提供的国际化与本地化支持。
- `选择理由`：官方方案，集成成本低，适合项目早期统一接入。

### 8. 测试：flutter_test + mockito

- `库名`：`flutter_test`、`mockito`
- `描述`：`flutter_test` 负责基础测试能力，`mockito` 用于模拟依赖。
- `选择理由`：这是 Flutter 项目中最常见、也最稳妥的测试组合。

### 9. 日志系统：logger

- `库名`：`logger`
- `描述`：提供结构清晰、易读的日志输出能力。
- `选择理由`：支持多级别日志，适合开发和调试阶段快速定位问题。

### 10. CI/CD 集成

CI/CD 一般不依赖某个 Flutter 库，而是结合外部平台来完成，例如：GitHub Actions、Codemagic 等。

## 目录规划

在完成技术选型后，就可以进一步确定项目目录结构。

这个框架被命名为 `fdflutter`，也就是 `fast development flutter`，目录结构如下：

```text
fdflutter/
├── lib/
│   ├── core/
│   │   ├── api/
│   │   │   └── api_service.dart
│   │   ├── di/
│   │   │   └── injection_container.dart
│   │   ├── localization/
│   │   │   └── localization_service.dart
│   │   ├── routing/
│   │   │   └── router.dart
│   │   └── utils/
│   │       └── logger.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local_datasource.dart
│   │   │   └── remote_datasource.dart
│   │   └── repositories/
│   │       └── example_repository.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── example_entity.dart
│   │   └── usecases/
│   │       └── get_example_data.dart
│   ├── presentation/
│   │   ├── pages/
│   │   │   └── example_page.dart
│   │   └── providers/
│   │       └── example_provider.dart
│   └── main.dart
├── test/
│   ├── data/
│   ├── domain/
│   └── presentation/
├── pubspec.yaml
└── README.md
```

## 分层说明

这个结构的核心思想，是把框架拆分为核心层、数据层、领域层和表现层，降低耦合，提升可维护性。

- `core/api/`：基于 `Dio` 封装 `ApiService`，统一处理所有网络请求。
- `core/di/`：基于 `GetIt` 管理依赖注册与获取。
- `core/localization/`：封装国际化能力。
- `core/routing/`：统一管理路由定义和跳转逻辑。
- `core/utils/`：放置日志、工具函数等通用能力。
- `data/`：负责数据获取、缓存、数据源和仓库实现。
- `domain/`：负责实体定义和业务用例。
- `presentation/`：负责页面展示、交互逻辑和状态消费。
- `test/`：用于补充各层测试，保障框架稳定性。

后续我会继续完善这个 Flutter 快速开发框架，并在 GitHub 上公开对应的 template。
