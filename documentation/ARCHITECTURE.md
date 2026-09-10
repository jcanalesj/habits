# Feature-Based Modular Clean Architecture for Flutter

**Last updated:** December 30, 2025

---

> **Note:** This document contains the technical specification and architecture rules. For a shorter project overview and getting-started guide, see `documentation/README.md`.

---

## Table of Contents

### Part I: Architecture Foundations

1. [Document Purpose](#1-document-purpose)
2. [Design Principles](#2-design-principles)
3. [Overall Project Structure](#3-overall-project-structure)
4. [Feature Contract](#4-feature-contract)
5. [Layers in Detail](#5-layers-in-detail)
   - [Layer 0: Entity](#51-layer-0-entity)
   - [Layer 1: Domain](#52-layer-1-domain)
   - [Layer 2: Presentation](#53-layer-2-presentation)
   - [Layer 3: Data](#54-layer-3-data)

### Part II: Technical Implementation

6. [Navigation and Routing with GoRouter](#6-navigation-and-routing-with-gorouter)
7. [Dependency and Import Rules](#7-dependency-and-import-rules)
   - [Barrel files and exports](#73-barrels)
8. [Dependency Injection with Riverpod 3](#8-dependency-injection-with-riverpod-3)
   - [Anti-patterns and Common Mistakes](#81-anti-patterns-and-common-mistakes-critical-for-claude-code)
9. [Networking and Authentication](#9-networking-and-authentication)
   - [Environment Configuration](#91-environment-configuration-libenvdart)
10. [Logging and Errors](#10-logging-and-errors)
11. [Testing](#11-testing)

### Part III: Quality and Best Practices

12. [Lifecycle of a New Feature](#12-lifecycle-of-a-new-feature)
13. [Extensibility and Modularity](#13-extensibility-and-modularity)
14. [Error and Exception Handling](#14-error-and-exception-handling)
15. [Performance and Optimization](#15-performance-and-optimization)
16. [Accessibility (A11y)](#16-accessibility-a11y)
17. [Security](#17-security)
18. [Naming Conventions](#18-naming-conventions)
19. [Riverpod 3.0 - Critical Best Practices](#19-riverpod-30---critical-best-practices)

### Part IV: Workflows and Checklists

20. [PR Checklist (Minimum Required)](#20-pr-checklist-minimum-required)
21. [Complete Workflow for Claude Code](#21-complete-workflow-for-claude-code-create-a-feature-from-scratch)
22. [Reference Prompts](#22-reference-prompts)
23. [References and Final Notes](#23-references-and-final-notes)

---

## 1. Document Purpose

This document defines how code is structured in this Flutter project:

- Which layers exist and what each one does
- How a feature must be organized
- Which dependencies are allowed and which are forbidden
- How use cases, results, repositories, state, and UI are modeled
- What is expected for testing and maintainability

> **This document is considered an architecture contract** that new features must follow.

---

## 2. Design Principles

The architecture is based on:

- **Feature-based modularization**: Each feature has its own mini-module with the same layers.
- **Clean Architecture**: Clear separation between:
  - Domain entities
  - Business logic
  - UI
  - Infrastructure (APIs, repositories, storage)
- **Unidirectional dependencies**: A layer may only depend "downward" (`infrastructure -> domain -> entities`).
- **SOLID**:
  - One class = one responsibility
  - Depend on abstractions, not implementations
  - Classes should be open for extension and closed for modification when possible
- **Testability as a requirement**: Anything that cannot be tested easily is suspicious.
- **Predictability**: Any developer should be able to open `lib/features/<feature>` and understand what exists and where to make changes.

---

## 3. Overall Project Structure

```text
lib/
  features/
    <feature>/
      0_entity/         # Domain entities (freezed, immutable, no external dependencies)
      1_domain/         # Business logic, use cases, abstract repositories
        usecases/       # One file per use case, *_usecase.dart
        repositories/   # Repository interfaces
        services/       # Domain services, if needed
        domain.dart     # Domain layer barrel
      2_presentation/   # UI, state, controllers
        pages/          # Main screens
        widgets/        # Reusable widgets
        controllers/    # UI notifiers / controllers
        providers/      # Riverpod 3 providers
        presentation.dart  # Presentation barrel
      3_data/           # Infrastructure: APIs, mappers, concrete repositories
        api/            # API classes (Dio), DTOs
        mappers/        # DTO <-> Entity converters
        repositories/   # Domain repository implementations
        data.dart       # Data barrel
  http_client.dart       # Global Dio configuration + interceptors
  navigation.dart        # go_router configuration
  logger.dart            # Centralized logging
  setup.dart             # Global dependency initialization
  theme/                 # Shared theme and styles
  localization/          # Internationalization (.arb)
  main.dart              # Real entry point
  main.mocked.dart       # Entry point with mocked providers / test scenario
```

> **General rule:** inside a feature, the `0_entity`, `1_domain`, `2_presentation`, and `3_data` folders are mandatory, even if they are almost empty at first.

### 3.1. Generated Code with OpenAPI 3.0

The `generated/` directory contains API client implementations generated automatically from OpenAPI 3.0 specifications:

```text
generated/
  navarra_empleo_api/     # API client generated with openapi_generator
    lib/
      api/                # API classes (endpoints)
      model/              # Generated DTOs/models
    doc/                  # Auto-generated documentation
```

**Generated code characteristics:**
- **Generated with `openapi_generator`**: Ensures synchronization with the backend contract.
- **Complete DTOs**: All request/response models with JSON serialization.
- **Typed endpoints**: Methods for each API operation with type safety.
- **Included documentation**: Each model and endpoint has documentation in `doc/`.

**Usage rules:**
- Features **must NOT import directly** from `generated/`.
- Each feature's `3_data/api/` layer acts as a **wrapper** around the generated client.
- Generated DTOs are mapped to domain entities through `3_data/mappers/`.
- To regenerate code:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

**Correct usage example:**
```dart
// INCORRECT: Importing directly from generated in presentation
import 'package:generated/navarra_empleo_api/api.dart';

// CORRECT: The 3_data layer wraps the generated client
class InscripcionesApi {
  final navarra_empleo_api.InscripcionesApi _generatedApi;

  InscripcionesApi(Dio dio)
    : _generatedApi = navarra_empleo_api.InscripcionesApi(dio);

  Future<List<InscripcionDto>> getInscripciones() async {
    final response = await _generatedApi.obtenerInscripciones();
    return response.data?.inscripciones ?? [];
  }
}
```

---

## 4. Feature Contract

A feature is a complete functional module, for example `presence`, `auth`, or `profile`, that:

- Has its own entities, use cases, UI, and data layer
- Can ideally be extracted into a package without breaking the rest of the app
- Exposes only what is necessary through its barrels (`domain.dart`, `presentation.dart`, `data.dart`)

### 4.1. Feature Naming

- Directory: `lib/features/<feature_name>/`
- `<feature_name>` uses snake_case: `presence`, `user_profile`, `session_history`, etc.

---

## 5. Layers in Detail

### 5.1. Layer 0 - Entity (`0_entity/`)

**Responsibility:**
- Represent the feature's domain model
- Remain independent from any technology (no Flutter, no Dio, no JSON)

**Rules:**
- Entities are defined with `freezed` + `json_serializable` when it makes sense.
- **Nothing may be imported from:**
  - `dart:io`
  - `package:flutter/*`
  - Dio, Riverpod, UI, or infrastructure concerns
- Entities may contain:
  - Simple validation logic
  - Utility methods that do not depend on IO

**Example:**
```dart
@freezed
abstract class StandPresence with _$StandPresence {
  const factory StandPresence({
    required String id,
    required String standName,
    required DateTime checkinTime,
    DateTime? checkoutTime,
  }) = _StandPresence;

  factory StandPresence.empty() => StandPresence(
    id: '',
    standName: '',
    checkinTime: DateTime.fromMillisecondsSinceEpoch(0),
  );
}
```

---

### 5.2. Layer 1 - Domain (`1_domain/`)

**Responsibility:**
- Contain business logic and system rules
- Define what the app "knows how to do" without caring about technical implementation

**Components:**
- Use cases (`usecases/`)
- Abstract repositories (`repositories/`)
- Domain services (`services/`, optional)

#### 5.2.1. Use Cases

**Rules:**
- File: `<action>_usecase.dart`
- Class: `<Action>Usecase`
- Output must be a sealed result: `<Action>Result` with `Success` and `Failed` subclasses.
- **Nothing may be imported from:**
  - `2_presentation`
  - `3_data`
  - `package:flutter/*`
  - Dio, Riverpod

**Example:**
```dart
sealed class FetchCheckinsResult {}

class FetchCheckinsSuccess extends FetchCheckinsResult {
  final List<Checkin> checkins;
  FetchCheckinsSuccess(this.checkins);
}

class FetchCheckinsFailed extends FetchCheckinsResult {
  final String message;
  FetchCheckinsFailed(this.message);
}

class FetchCheckinsUsecase {
  final PresenceRepository _repository;

  FetchCheckinsUsecase(this._repository);

  Future<FetchCheckinsResult> execute() async {
    try {
      return FetchCheckinsSuccess(await _repository.fetchCheckins());
    } catch (e, s) {
      // Logging is done outside; here we only package the error
      return FetchCheckinsFailed(e.toString());
    }
  }
}
```

#### 5.2.2. Abstract Repositories

Repositories define what the domain needs, not how it is implemented.
Their methods use domain entities, not API DTOs.

```dart
abstract class PresenceRepository {
  Future<List<Checkin>> fetchCheckins();
  Future<Checkin> sendCheckin(Checkin checkin);
}
```

---

### 5.3. Layer 2 - Presentation (`2_presentation/`)

**Responsibility:**
- Put information on screen
- Manage UI state
- Orchestrate use cases -> state -> rendering

**Subfolders:**
- `pages/` -> main screens
- `widgets/` -> reusable widgets
- `controllers/` -> UI logic (Notifiers, controllers)
- `providers/` -> Riverpod 3 provider definitions

**Rules:**
- No direct API calls are allowed here.
- No class from `3_data` may be imported.
- Use cases and repositories are consumed only through providers.

**Provider + controller example:**
```dart
final fetchCheckinsUsecaseProvider = Provider<FetchCheckinsUsecase>((ref) {
  final repo = ref.read(presenceRepositoryProvider);
  return FetchCheckinsUsecase(repo);
});

class CheckinsController extends AsyncNotifier<List<Checkin>> {
  @override
  Future<List<Checkin>> build() async {
    final usecase = ref.read(fetchCheckinsUsecaseProvider);
    final result = await usecase.execute();

    return switch (result) {
      FetchCheckinsSuccess s => s.checkins,
      FetchCheckinsFailed f => throw Exception(f.message),
    };
  }
}

final checkinsControllerProvider =
    AsyncNotifierProvider<CheckinsController, List<Checkin>>(CheckinsController.new);
```

> Navigation (`go_router`) is defined outside the feature, but the feature screens are imported from `presentation.dart`.

---

### 5.4. Layer 3 - Data (`3_data/`)

**Responsibility:**
- Access external resources:
  - HTTP APIs
  - Local storage
  - Third-party services
- Convert external data (DTOs) to domain entities and back

**Subfolders:**
- `api/` -> generated client wrappers, custom endpoints, additional DTOs
- `mappers/` -> DTO <-> Entity mappers
- `repositories/` -> implementations of `PresenceRepository`, etc.

**Rules:**
- This layer **may import:**
  - `lib/http_client.dart`
  - `lib/logger.dart`
  - `package:generated/navarra_empleo_api/api.dart` (generated API client)
  - Dio and other infrastructure libraries
- It may not import anything from `2_presentation`.
- It must expose implementations that satisfy domain contracts.
- DTOs from generated code are mapped to domain entities and **must never be exposed outside `3_data/`**.

**API example (generated client wrapper):**
```dart
import 'package:generated/navarra_empleo_api/api.dart' as navarra_api;

class InscripcionesApi {
  final navarra_api.InscripcionesApi _generatedApi;

  InscripcionesApi(Dio dio)
    : _generatedApi = navarra_api.InscripcionesApi(dio);

  Future<List<InscripcionDto>> getInscripciones() async {
    try {
      final response = await _generatedApi.obtenerInscripciones();
      // Convert from generated model to our internal DTO if needed
      return response.data?.inscripciones ?? [];
    } catch (e) {
      // The error is propagated to the repository
      rethrow;
    }
  }
}
```

**Alternative example (custom non-generated endpoint):**
```dart
class CustomPresenceApi {
  final Dio _dio;

  CustomPresenceApi(this._dio);

  Future<List<CheckinDto>> getCheckins() async {
    final response = await _dio.get('/checkins');
    final data = response.data as List<dynamic>;
    return data.map((json) => CheckinDto.fromJson(json as Map<String, dynamic>)).toList();
  }
}
```

**Repository example:**
```dart
class PresenceRepositoryImpl implements PresenceRepository {
  final PresenceApi _api;
  final CheckinMapper _mapper;

  PresenceRepositoryImpl(this._api, this._mapper);

  @override
  Future<List<Checkin>> fetchCheckins() async {
    final dtos = await _api.getCheckins();
    return dtos.map(_mapper.dtoToEntity).toList();
  }
}
```

---

## 6. Navigation and Routing with GoRouter

### 6.1. Feature Route Architecture

Each feature defines its own routes in a dedicated file following this pattern:

```text
features/
  <feature>/
    2_presentation/
      routes/
        routes.dart     # Defines appointmentsRoutesProvider
      pages/            # Pages referenced by the routes
      providers/
      controllers/
```

### 6.2. Defining Routes in a Feature

**File:** `lib/features/appointments/2_presentation/routes/routes.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hiberus_scaffold/features/appointments/2_presentation/pages/appointments_home_page.dart';
import 'package:hiberus_scaffold/features/appointments/2_presentation/pages/my_appointments_page.dart';

/// Provider for the Cita Previa feature routes
final appointmentsRoutesProvider = Provider<List<GoRoute>>((final ref) {
  return [
    GoRoute(
      path: '/appointments',
      builder: (final context, final state) => const AppointmentsHomePage(),
      routes: [
        // Nested routes
        GoRoute(
          path: 'new',
          builder: (final context, final state) => const SelectAgencyPage(),
          routes: [
            GoRoute(
              path: 'select-service',
              builder: (final context, final state) => const SelectServicePage(),
            ),
          ],
        ),
        GoRoute(
          path: 'my-appointments',
          builder: (final context, final state) => const MyAppointmentsPage(),
        ),
      ],
    ),
  ];
});
```

**CRITICAL - Mandatory route pattern:**

- **CORRECT**: Use a **Riverpod Provider** that returns `List<GoRoute>`.
- **INCORRECT**: Define routes as a static list, for example `final certificatesRoutes = [GoRoute(...)]`.

**Reason for this pattern:**
- **Architecture consistency**: All features use the same pattern.
- **Reactivity**: Routes may depend on other providers if needed.
- **Testability**: Providers can be mocked easily.
- **Dependency injection**: Keeps Riverpod's philosophy across the app.

**Important characteristics:**
- Named as `<feature>RoutesProvider` with the `Provider` suffix.
- All feature routes are contained inside the provider.
- Nested routes are defined with GoRoute's `routes: []` parameter.
- Nested paths are **relative** (`'new'` under `/appointments` = `/appointments/new`).

### 6.3. Registration in the Global Router

**File:** `lib/navigation/navigation.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hiberus_scaffold/features/appointments/2_presentation/routes/routes.dart' as appointments_routes;
import 'package:hiberus_scaffold/features/inscripciones/2_presentation/routes.dart' as inscripciones_routes;
import 'package:hiberus_scaffold/features/login/2_presentation/routes.dart' as login_routes;

final allRoutesProvider = Provider<List<GoRoute>>((final ref) {
  return [
    ...ref.watch(login_routes.loginRoutesProvider),
    ...ref.watch(appointments_routes.appointmentsRoutesProvider),
    ...ref.watch(inscripciones_routes.inscripcionesRoutesProvider),
    // More features...
  ];
});

final goRouterProvider = Provider<GoRouter>((final ref) {
  final routes = ref.watch(allRoutesProvider);
  return GoRouter(
    routes: routes,
    redirect: (final context, final state) {
      final isRoot = state.uri.path == '/' && state.uri.query.isEmpty;
      if (isRoot) {
        return '/login';
      }
      return null;
    },
  );
});
```

**Steps to add a new feature:**
1. Import the routes file with an alias: `as <feature>_routes`
2. Add the spread operator in `allRoutesProvider`: `...ref.watch(<feature>_routes.<feature>RoutesProvider)`

### 6.4. Migrating Placeholder Routes

When a feature is migrated from a placeholder to a full implementation:

**Before** (in `main_home/routes.dart`):
```dart
GoRoute(path: '/cita_previa', builder: (final c, final s) => placeholder('Cita Previa')),
```

**After** (commented):
```dart
// GoRoute(path: '/cita_previa', builder: (final c, final s) => placeholder('Cita Previa')), // Migrated to appointments feature
```

This makes it clear that the route was moved and avoids duplicates.

### 6.5. Navigation in Code

**Simple navigation:**
```dart
// In a widget or controller
context.go('/appointments');
context.push('/appointments/new');
context.pop();
```

**Navigation with path parameters:**
```dart
// Route definition
GoRoute(
  path: 'details/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return DetailsPage(id: id);
  },
),

// Navigation
context.go('/appointments/details/123');
```

**Navigation with query parameters:**
```dart
// Navigation
context.go('/appointments?filter=active');

// Reading on the page
final state = GoRouterState.of(context);
final filter = state.uri.queryParameters['filter'];
```

### 6.6. Checklist for Adding Routes to a New Feature

- [ ] Create `features/<feature>/2_presentation/routes/routes.dart`
- [ ] Define `<feature>RoutesProvider` returning `List<GoRoute>`
- [ ] Import the necessary pages from `2_presentation/pages/`
- [ ] Define the route structure (main route + nested routes)
- [ ] Import the provider in `lib/navigation/navigation.dart` with an alias
- [ ] Add the provider spread in `allRoutesProvider`
- [ ] If migrating an existing route, comment the old route in `main_home/routes.dart`
- [ ] Test navigation with `context.go()` or `context.push()`

---

## 7. Dependency and Import Rules

### 7.1. Allowed Flow

```text
3_data -> 1_domain -> 0_entity
2_presentation -> 1_domain -> 0_entity
```

### 7.2. Forbidden

- `2_presentation` importing `3_data`
- `1_domain` importing `2_presentation` or `3_data`
- Widgets importing APIs or concrete repositories directly
- Dio calls outside `3_data/api`

### 7.3. Barrels

Each layer may have a barrel:
- `1_domain/domain.dart`
- `2_presentation/presentation.dart`
- `3_data/data.dart`

**Recommended rule:**
- From outside the feature, import the barrel:
  ```dart
  import 'package:app/features/presence/2_presentation/presentation.dart';
  ```
- Inside the feature, internal files may be imported directly when it makes sense, but barrel usage is preferred.

#### 7.3.1. Barrel File Pattern (CRITICAL)

**File:** `lib/features/<feature>/1_domain/domain.dart`
```dart
// Export ONLY interfaces and use cases, NOT implementations
export 'repositories/user_repository.dart';
export 'usecases/fetch_user_usecase.dart';
export 'usecases/update_profile_usecase.dart';

// Do NOT export anything from 3_data here
```

**File:** `lib/features/<feature>/2_presentation/presentation.dart`
```dart
// Export providers, pages, and reusable widgets
export 'providers/providers.dart';
export 'pages/user_profile_page.dart';
export 'pages/edit_profile_page.dart';
export 'widgets/user_card.dart';

// Do NOT export internal controllers unless other features need them
```

**File:** `lib/features/<feature>/3_data/data.dart`
```dart
// Export ONLY the repository implementation
export 'repositories/user_repository_impl.dart';

// Do NOT export APIs, DTOs, or mappers; they are internal to the layer
```

**File:** `lib/features/<feature>/<feature>.dart` (optional root barrel)
```dart
// Re-export layer barrels
export '1_domain/domain.dart';
export '2_presentation/presentation.dart';
// Do NOT export 3_data; implementations are injected through providers
```

---

### 7.4. Complete Example: "User Profile" Feature Step by Step

> **Detailed Guide:** For a complete step-by-step example of creating a feature, see [generation_create_complete_feature.md](prompts/generation_create_complete_feature.md)

---

## 8. Dependency Injection with Riverpod 3

**Principles:**
- Every dependency is resolved through providers.
- No manual global singletons.
- Tests use `ProviderContainer` and overrides.

**Examples:**
```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  // Configure interceptors...
  return dio;
});

final presenceApiProvider = Provider<PresenceApi>((ref) {
  final dio = ref.read(dioProvider);
  return PresenceApi(dio);
});

final presenceRepositoryProvider = Provider<PresenceRepository>((ref) {
  return PresenceRepositoryImpl(
    ref.read(presenceApiProvider),
    CheckinMapper(),
  );
});
```

In tests:
```dart
final container = ProviderContainer(
  overrides: [
    presenceRepositoryProvider.overrideWithValue(MockPresenceRepository()),
  ],
);
```

---

## 8.1. Anti-patterns and Common Mistakes (CRITICAL for Claude Code)

> **Detailed Guide:** For anti-patterns with corrections, see [review_anti_patterns_clean_arch.md](prompts/review_anti_patterns_clean_arch.md)

### Common Anti-Patterns Summary

1. **Presentation importing Data** - `2_presentation` NEVER imports `3_data` *(except provider files; see below)*.
2. **DTOs exposed outside 3_data** - DTOs are implementation details.
3. **Business logic in controllers** - Logic goes in `1_domain/usecases`.
4. **Not using sealed results** - Use cases return sealed Result classes.
5. **Missing `ref.mounted` checks** - Always check after `await`.
6. **Using StateNotifier** - Use `@riverpod` with `Notifier`/`AsyncNotifier`.

---

### IMPORTANT EXCEPTION: Provider Files and Dependency Injection

**Provider files (`2_presentation/providers/*.dart`) are allowed to import `3_data`** because they act as the **Dependency Injection** layer.

#### Why This Exception Exists

Provider files are responsible for:
1. Wiring concrete implementations (`3_data`) to abstractions (`1_domain`)
2. Creating the dependency graph for the feature
3. Providing dependency injection for the entire feature

This follows the **Dependency Inversion Principle**: the DI layer knows about both abstractions and implementations, but the rest of presentation only knows abstractions.

#### CORRECT Pattern: Provider File

```dart
// File: lib/features/appointments/2_presentation/providers/appointments_providers.dart

// ALLOWED: Provider files can import 3_data for DI
import 'package:hiberus_scaffold/features/appointments/1_domain/repositories/appointments_repository.dart';
import 'package:hiberus_scaffold/features/appointments/1_domain/usecases/crear_cita_usecase.dart';
import 'package:hiberus_scaffold/features/appointments/3_data/api/appointments_api_wrapper.dart';
import 'package:hiberus_scaffold/features/appointments/3_data/repositories/appointments_repository_impl.dart';

/// Provider for the API wrapper
final appointmentsApiWrapperProvider = Provider<AppointmentsApiWrapper>((ref) {
  final api = ref.read(navarraEmpleoApiProvider);
  final dio = ref.read(dioProvider);
  return AppointmentsApiWrapper(api.getCitaPreviaApi(), dio);
});

/// Provider for the repository (wiring concrete to interface)
final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  final apiWrapper = ref.read(appointmentsApiWrapperProvider);
  return AppointmentsRepositoryImpl(apiWrapper); // Concrete implementation
});

/// Provider for the use case
final crearCitaUsecaseProvider = Provider<CrearCitaUsecase>((ref) {
  final repository = ref.read(appointmentsRepositoryProvider);
  return CrearCitaUsecase(repository);
});
```

#### CORRECT: Controllers Use Providers Only

```dart
// File: lib/features/appointments/2_presentation/controllers/appointment_controller.dart

// ONLY imports from 1_domain and 2_presentation
import 'package:hiberus_scaffold/features/appointments/1_domain/usecases/crear_cita_usecase.dart';
import 'package:hiberus_scaffold/features/appointments/2_presentation/providers/appointments_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class AppointmentController extends _$AppointmentController {
  @override
  AppointmentState build() => const AppointmentState();

  Future<void> createAppointment() async {
    // Controller only knows about providers and domain
    final usecase = ref.read(crearCitaUsecaseProvider);
    final result = await usecase.execute(...);

    // NO imports from 3_data!
  }
}
```

#### INCORRECT: Page/Widget Importing 3_data

```dart
// PROHIBITED: Pages/widgets must NEVER import 3_data
import 'package:hiberus_scaffold/features/appointments/3_data/repositories/appointments_repository_impl.dart';

class AppointmentPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WRONG: Direct instantiation of concrete implementation
    final repo = AppointmentsRepositoryImpl(...);
  }
}
```

#### Summary: The Rule

| File Type | Can Import 3_data? | Reason |
|-----------|-------------------|--------|
| **Provider files** (`2_presentation/providers/*.dart`) | **YES** | Dependency Injection layer |
| **Controllers** (`2_presentation/controllers/*.dart`) | **NO** | Only use providers |
| **Pages** (`2_presentation/pages/*.dart`) | **NO** | Only use providers |
| **Widgets** (`2_presentation/widgets/*.dart`) | **NO** | Only use providers |
| **Domain** (`1_domain/**/*.dart`) | **NO** | Domain is framework-agnostic |

**Key Principle:** The provider file is the **single point** where `2_presentation` meets `3_data`. Everything else in `2_presentation` only knows about providers and domain abstractions.

**Rule:** `StateNotifier` is **PROHIBITED**. Use `@riverpod` with code generation.

---

### Anti-pattern 7: Duplicating Models with Freezed When They Already Exist in built_value

```dart
// INCORRECT - Duplicating a model that already exists in navarra_empleo_api
@freezed
abstract class Agencia with _$Agencia {
  const factory Agencia({
    required int id,
    required String nombre,
  }) = _Agencia;
}
```

```dart
// CORRECT - Use the generated model directly
import 'package:generated/navarra_empleo_api/model/agencia.dart';

// Use Agencia directly from the generated package
Future<List<Agencia>> getAgencias() async {
  final api = AgenciasApi();
  final response = await api.obtenerAgencias();
  return response.data ?? [];
}
```

**Rule:** If the model exists in `navarra_empleo_api` (built_value), **do NOT** create a duplicate with freezed.

---

### Anti-pattern 8: `ref.read()` for Reactive State

```dart
// INCORRECT - The UI is not updated when the locale changes
@override
Widget build(BuildContext context, WidgetRef ref) {
  final locale = ref.read(currentLocaleProvider); // WRONG: read()

  return MaterialApp(
    locale: locale,
    // ...
  );
}
```

```dart
// CORRECT - The UI rebuilds when the locale changes
@override
Widget build(BuildContext context, WidgetRef ref) {
  final locale = ref.watch(currentLocaleProvider); // RIGHT: watch()

  return MaterialApp(
    locale: locale,
    // ...
  );
}
```

**Rule:**
- `ref.watch()` -> For reactive state; the UI updates when it changes.
- `ref.read()` -> For calling methods/actions; non-reactive.

---

### Anti-pattern 9: Expensive Operations in `build()`

```dart
// INCORRECT - Sorting on every rebuild
@override
Widget build(BuildContext context) {
  final items = [3, 1, 4, 1, 5, 9];
  final sortedItems = items.toList()..sort(); // Runs on every rebuild!

  return ListView(
    children: sortedItems.map((item) => Text('$item')).toList(),
  );
}
```

```dart
// CORRECT - Calculate in the provider/controller
@riverpod
class ItemsController extends _$ItemsController {
  @override
  List<int> build() {
    final items = [3, 1, 4, 1, 5, 9];
    return items.toList()..sort(); // Only runs when it changes
  }
}

@override
Widget build(BuildContext context, WidgetRef ref) {
  final sortedItems = ref.watch(itemsControllerProvider);

  return ListView(
    children: sortedItems.map((item) => Text('$item')).toList(),
  );
}
```

**Rule:** `build()` must be **idempotent and fast**. Expensive calculations belong in providers/controllers.

---

### Anti-pattern 10: Navigating Before Checking for Errors

```dart
// INCORRECT - Navigates even when there is an error
Future<void> onSubmit() async {
  final result = await usecase.execute(data);

  // WRONG: Always navigates, even on error
  if (!ref.mounted) return;
  context.go('/success');
}
```

```dart
// CORRECT - Navigate only on Success
Future<void> onSubmit() async {
  state = state.copyWith(isLoading: true, error: null);

  final result = await usecase.execute(data);

  if (!ref.mounted) return;

  switch (result) {
    case SubmitSuccess():
      state = state.copyWith(isLoading: false);
      context.go('/success'); // Navigate only on success
    case SubmitFailed(:final message):
      state = state.copyWith(
        isLoading: false,
        error: message, // Show the error on the current UI
      );
  }
}
```

**Rule:** Validate the result before navigating. Show errors on the current screen.

---

## 9. Networking and Authentication

In `lib/http_client.dart`:
- Common Dio configuration
- Interceptors:
  - Logging (`PrettyDioLogger`, `CurlLoggerDioInterceptor`)
  - Authentication (`AuthInterceptor` with token from provider)
  - Common headers (`CommonHeadersInterceptor`)
  - Refresh-token handling (`QueuedInterceptorsWrapper`)

**Rule:**
- Features do not create Dio instances on their own; they always use the `dioProvider` defined in `lib/setup.dart`.

### 9.1. Environment Configuration (`lib/env.dart`)

Environment variables are managed through `lib/env.dart` using `--dart-define-from-file` at build time, loading JSON configuration files:

**Available configuration files:**
- `config_development.json` - Development/validation environment
- `config_preproduction.json` - Preproduction environment
- `config_production.json` - Production environment

**Configuration file example (`config_development.json`):**
```json
{
  "URL_API_SERVICE": "https://val-frontend.admon-cfnavarra.es:8844/EmpleoMovilService/",
  "API_MID_NAME": "api/v2",
  "TIMEOUT_CALL": "10",
  "TIMEOUT_READ": "10",
  "URL_FORMACION": "https://val-frontend.admon-cfnavarra.es/EmpleoFormate.Internet/",
  "TIMEOUT_TOKEN": "30",
  "URL_OFERTAS": "https://administracionelectronica.navarra.es/EmpleoIntermediacion/empleo/",
  "EMAIL_CONTACTO": "portal.empleo@navarra.es",
  "FORZAR_LOG_EN_RELEASE": "true",
  "DEBUG_MODE": "true"
}
```

**Env class (`lib/env.dart`):**
```dart
class Env {
  static const apiServiceUrl = String.fromEnvironment('URL_API_SERVICE');
  static const timeoutCallSeconds = int.fromEnvironment('TIMEOUT_CALL', defaultValue: 10);
  static const timeoutReadSeconds = int.fromEnvironment('TIMEOUT_READ', defaultValue: 10);
  static const urlFormacion = String.fromEnvironment('URL_FORMACION');
  static const timeoutToken = int.fromEnvironment('TIMEOUT_TOKEN', defaultValue: 30);
  static const urlOfertas = String.fromEnvironment('URL_OFERTAS');
  static const emailContacto = String.fromEnvironment('EMAIL_CONTACTO');
  static const forzarLogEnRelease = bool.fromEnvironment('FORZAR_LOG_EN_RELEASE', defaultValue: false);
  static const debugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: false);
}
```

**Build-time usage:**
```bash
# Development
flutter run --dart-define-from-file=config_development.json

# Preproduction
flutter run --dart-define-from-file=config_preproduction.json

# Production
flutter build apk --release --dart-define-from-file=config_production.json
flutter build appbundle --release --dart-define-from-file=config_production.json
```

**Usage in code:**
```dart
// In lib/http_client.dart or setup.dart
final dio = Dio(BaseOptions(
  baseUrl: Env.apiServiceUrl,
  connectTimeout: Duration(seconds: Env.timeoutCallSeconds),
  receiveTimeout: Duration(seconds: Env.timeoutReadSeconds),
));

// Conditional logging
if (Env.forzarLogEnRelease || Env.debugMode) {
  logger.d('Debug info...');
}
```

**Advantages:**
- Clear separation between environments (dev/pre/prod) through JSON files
- No hardcoded URLs or sensitive configuration in code
- Defaults for local development
- CI/CD compatible by selecting the environment file
- More readable than multiple individual `--dart-define` arguments
- Configuration can be versioned in Git when it does not contain secrets

**Differences between environments:**
| Variable | Development | Preproduction | Production |
|----------|-------------|---------------|------------|
| `URL_API_SERVICE` | val-frontend:8844 | preadministracionelectronica | administracionelectronica |
| `TIMEOUT_CALL` | 10s | 30s | 30s |
| `TIMEOUT_TOKEN` | 30s | 600s (10min) | 600s (10min) |
| `DEBUG_MODE` | true | false | false |

---

## 10. Logging and Errors

- Logging is centralized in `lib/logger.dart`.
- Repositories may:
  - Log technical errors using the shared logger
  - Throw exceptions or return domain-mapped `Failed` results

**Golden rule:**
- The domain layer does not log infrastructure details such as HTTP.
- In presentation, errors are transformed into:
  - UI messages
  - Error states in providers

---

## 11. Testing

### Domain
- Unit tests per use case
- Repository mocks
- Checks for:
  - Happy path (`Success`)
  - Error path (`Failed`)

### Data
- Tests for:
  - Mappers
  - Repositories, with mocked API or DioAdapter

### Presentation
- Tests for:
  - Controllers / notifiers (`AsyncNotifier`)
  - Important widgets, main screens, and critical flows

### BDD and Integration Testing

The project supports BDD (Behavior-Driven Development) tests through `bdd_widget_test` and shared steps in `shared_test_steps/`.

**Test initialization (`shared_test_steps/the_app_is_running.dart`):**

```dart
Future<void> theAppIsRunning(WidgetTester tester) async {
  // Detects the test type (Integration vs BDD)
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final isIntegration = binding is IntegrationTestWidgetsFlutterBinding;
  final isAutomatic = binding is AutomatedTestWidgetsFlutterBinding;

  Widget appWidget;
  if (isIntegration) {
    // E2E: uses real SharedPreferences
    sharedPrefs = await SharedPreferences.getInstance();
    appWidget = const ProviderScope(child: MainApp());
  } else if (isAutomatic) {
    // BDD: uses mocks
    final mockPrefs = MockAppPreferences();
    appWidget = ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(mockPrefs)],
      child: const MainApp(),
    );
  }

  // Necessary MethodChannel mocks
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(smsAutofillChannel, (call) async {
      if (call.method == 'listenForCode') return null;
      return null;
    });

  await tester.pumpWidget(appWidget);
}
```

**Key characteristics:**
- **Automatic detection** of the test type (BDD vs E2E)
- **MethodChannel mocks**: SMS autofill, App Links, Package Info
- **Provider overrides**: To inject mocked dependencies
- **Reusable shared steps**: `i_see_text.dart`, `i_tap_button.dart`, etc.

**BDD test structure:**
```text
shared_test_steps/
  the_app_is_running.dart      # Initial setup
  i_see_text.dart              # Verify text on screen
  i_tap_button_with_text.dart  # Button interactions
  i_wait_seconds.dart          # Controlled waits
  mocks/                       # Shared mocks
integration_test/
  features/
    login.feature              # Gherkin scenarios
    login_test.dart            # Generated tests
```

**Advantages of this approach:**
- Readable tests in Gherkin format (Given/When/Then)
- Step reuse across features
- Clear separation between unit, BDD, and integration tests
- Automatic platform mocks (SMS, deep links)

---

## 12. Lifecycle of a New Feature

> **Detailed Checklist:** See [validation_feature_lifecycle_checklist.md](prompts/validation_feature_lifecycle_checklist.md)

---

## 13. Extensibility and Modularity

A feature must be able to:
- Be extracted into a package
- Be reused in another app with minimal effort

To support this:
- Avoid cross-feature references except in very clear cases.
- Business logic must not depend on assets or concrete UI.

---

## 14. Error and Exception Handling

> **Detailed Guide:** See [generation_error_handling_pattern.md](prompts/generation_error_handling_pattern.md)

### Error Handling Summary

- **1_domain/usecases**: Return sealed Result classes (Success/Failed)
- **3_data**: Convert exceptions to domain-specific errors
- **2_presentation**: Handle results with pattern matching
- Log errors with context and stack traces

---

## 15. Performance and Optimization

> **Detailed Guide:** See [review_performance_optimization.md](prompts/review_performance_optimization.md)

### Performance Best Practices Summary

- Use `const` constructors wherever possible.
- Provide keys for lists that change.
- Avoid expensive operations in `build()`.
- Use builder patterns for large widgets.

---

## 16. Accessibility (A11y)

> **Detailed Guide:** See [review_accessibility_compliance.md](prompts/review_accessibility_compliance.md)

### Accessibility Requirements Summary

- Add Semantics for screen readers.
- Minimum touch target: 48x48 dp.
- Color contrast: WCAG AA (4.5:1 for text).
- Logical focus traversal order.

---

## 17. Security

> **Detailed Guide:** See [review_security_vulnerabilities.md](prompts/review_security_vulnerabilities.md)

### Security Best Practices Summary

- Store tokens in `flutter_secure_storage`.
- Validate all user inputs.
- Sanitize URLs before opening.
- Never log sensitive data.

---

## 18. Naming Conventions

### 18.1. Files

**snake_case for all files:**
```text
user_profile_page.dart
fetch_user_usecase.dart
user_repository_impl.dart
```

### 18.2. Classes and Types

**PascalCase:**
```dart
class UserProfile {}
class FetchUserUsecase {}
sealed class FetchUserResult {}
```

### 18.3. Variables and Functions

**camelCase:**
```dart
final userName = 'John';
void fetchUserData() {}
```

### 18.4. Constants

**lowerCamelCase, not SCREAMING_SNAKE:**
```dart
// CORRECT (Dart style)
const defaultTimeout = Duration(seconds: 30);
const maxRetries = 3;

// INCORRECT (Java/Kotlin style)
const DEFAULT_TIMEOUT = Duration(seconds: 30);
const MAX_RETRIES = 3;
```

### 18.5. Providers

**End with `Provider`:**
```dart
final userRepositoryProvider = Provider<UserRepository>(...);
final fetchUserUsecaseProvider = Provider<FetchUserUsecase>(...);
final userControllerProvider = NotifierProvider<UserController, UserState>(...);
```

### 18.6. Sealed Results

**Pattern:** `<Action>Result` with `<Action>Success` and `<Action>Failed`
```dart
sealed class FetchUserResult {}
class FetchUserSuccess extends FetchUserResult {
  final User user;
  FetchUserSuccess(this.user);
}
class FetchUserFailed extends FetchUserResult {
  final String message;
  FetchUserFailed(this.message);
}
```

### 18.7. Pages and Widgets

**Descriptive suffixes:**
```dart
// Pages
class UserProfilePage extends StatelessWidget {}
class LoginPage extends StatelessWidget {}

// Reusable widgets
class UserCard extends StatelessWidget {}
class CustomButton extends StatelessWidget {}

// Dialogs
class ConfirmationDialog extends StatelessWidget {}
```

---

### 18.8. Decision Trees (Quick Guides for Claude Code)

> **Quick Reference:** See [decision_architecture_quick_reference.md](prompts/decision_architecture_quick_reference.md)

---

## 19. Riverpod 3.0 - Critical Best Practices

> **Detailed Guide:** See [validation_riverpod3_patterns.md](prompts/validation_riverpod3_patterns.md)

### Riverpod 3.0 Critical Rules

**MANDATORY: `ref.mounted` after `await`**

```dart
Future<void> loadData() async {
  final result = await usecase.execute();
  if (!ref.mounted) return;  // CRITICAL
  state = result;
}
```

- Use `@riverpod` annotation (NO StateNotifier).
- Use `ref.watch()` for reactive state in `build()`.
- Use `ref.read()` for methods in callbacks.

---

## 20. PR Checklist (Minimum Required)

> **Complete Checklist:** See [review_pr_checklist_complete.md](prompts/review_pr_checklist_complete.md)

### PR Review Summary

- [ ] Architecture rules respected
- [ ] Riverpod 3.0 patterns followed (`ref.mounted` checks)
- [ ] Error handling with sealed results
- [ ] Performance optimizations (`const`, keys)
- [ ] Accessibility compliance
- [ ] Security checks passed
- [ ] Tests written and passing

---

## 21. Complete Workflow for Claude Code: Create a Feature from Scratch

> **Complete Workflow:** See [workflow_create_feature_step_by_step.md](prompts/workflow_create_feature_step_by_step.md)

### Workflow Summary

1. **Planning** - Do not code yet; understand requirements.
2. **Structure** - Create folder structure.
3. **Layers** - Implement in order: `0_entity` -> `1_domain` -> `3_data` -> `2_presentation`.
4. **Integration** - Register routes, run build_runner.
5. **Validation** - Verify architecture, test, review.

---

## 22. Reference Prompts

This section links to specialized prompts extracted from this document for use with Claude AI.

### Migration Prompts
- [Analyze Android Code](prompts/migration_analyze_android_code.md) - Deep analysis before migration
- [Create Migration Plan](prompts/migration_create_migration_plan.md) - Comprehensive migration planning
- [Generate Flutter Code](prompts/migration_generate_flutter_code.md) - Phase-by-phase code generation
- [Complete Feature Migration](prompts/migration_complete_feature_android_to_flutter.md) - End-to-end feature migration
- [UI-Only Migration](prompts/migration_ui_only_xml_to_widgets.md) - XML to Flutter widgets
- [Business Logic Migration](prompts/migration_business_logic_viewmodel_to_usecase.md) - ViewModel to UseCase
- [UI Resources Extraction](prompts/migration_ui_resources_extraction.md) - Colors, dimensions, strings

### Validation Prompts
- [Feature Architecture Audit](prompts/validation_feature_architecture_audit.md) - Complete architecture review
- [Riverpod 3.0 Patterns](prompts/validation_riverpod3_patterns.md) - Riverpod best practices validation
- [Riverpod 3.0 Enforcement](prompts/validation_riverpod3_enforcement.md) - Code-level enforcement
- [Dependency Flow Analysis](prompts/validation_dependency_flow_analysis.md) - Layer dependency validation
- [Feature Lifecycle Checklist](prompts/validation_feature_lifecycle_checklist.md) - Completeness checklist
- [Migration Final Checklist](prompts/validation_migration_final_checklist.md) - Pre-delivery validation

### Review Prompts
- [Pre-Commit Review](prompts/review_pre_commit_complete.md) - Comprehensive PR review
- [PR Checklist Complete](prompts/review_pr_checklist_complete.md) - Minimum PR requirements
- [Anti-Patterns Review](prompts/review_anti_patterns_clean_arch.md) - Identify and fix anti-patterns
- [Performance Analysis](prompts/review_performance_analysis.md) - Performance optimization review
- [Performance Optimization](prompts/review_performance_optimization.md) - Best practices
- [Accessibility Compliance](prompts/review_accessibility_compliance.md) - A11y review
- [Security Audit](prompts/review_security_audit.md) - Security vulnerabilities
- [Security Vulnerabilities](prompts/review_security_vulnerabilities.md) - Common security issues

### Generation Prompts
- [Create Complete Feature](prompts/generation_create_complete_feature.md) - Step-by-step feature creation
- [Error Handling Pattern](prompts/generation_error_handling_pattern.md) - Error handling code
- [Test Templates](prompts/generation_test_templates.md) - Unit and widget test generation
- [Feature README](prompts/generation_feature_readme.md) - Documentation generation
- [API Integration Docs](prompts/generation_api_integration_docs.md) - API documentation
- [Architecture Decision Record](prompts/generation_architecture_decision_record.md) - ADR template

### Workflow Prompts
- [Create Feature Step-by-Step](prompts/workflow_create_feature_step_by_step.md) - Complete workflow guide

### Decision Prompts
- [Architecture Quick Reference](prompts/decision_architecture_quick_reference.md) - Decision trees
- [When to Ask User](prompts/decision_when_to_ask_user.md) - Clarification guidelines

> **Tip:** Use these prompts with Claude AI for guided implementation, reviews, and migrations following project standards.

---

## 23. References and Final Notes

### 23.1. Source of Truth

This document is the **source of truth** for the repository architecture.

**Change process:**
- Any adjustment to the rules must be made through a Pull Request.
- Document the reason for the change in the commit.
- Update the "Last updated" date.
- Review impact on existing features.

### 23.2. Contributing to This Document

**If you find:**
- Ambiguities or contradictions
- Outdated examples
- Missing sections
- Organizational improvements

**Please:**
1. Open an issue describing the problem/improvement.
2. Or create a PR with the proposed solution.
3. Mention the specific section where the problem exists.
4. If you add new content, update the table of contents.

**Document philosophy:**
- Clarity over brevity
- Concrete examples over abstract theory
- Explicit decisions over flexibility
- Copy-paste-ready code over pseudocode

---

[Back to top](#table-of-contents)
