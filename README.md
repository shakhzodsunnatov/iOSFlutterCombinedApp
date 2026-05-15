# NativeFlutter — iOS (SwiftUI) + Flutter add-to-app example

A SwiftUI host app that owns a shared `users` database and embeds a
Flutter screen. Either side can create / read / delete users, and
both sides see the same data in real time.

```
┌─────────────────────────────────────────────────────┐
│                  iOS SwiftUI app                    │
│                                                     │
│   ┌───────────────────┐    ┌───────────────────┐    │
│   │  UsersListView    │    │   UsersStore      │    │
│   │  (table + "+")    │◄──►│   (JSON on disk,  │    │
│   │                   │    │    @Published)    │    │
│   └─────────┬─────────┘    └────────┬──────────┘    │
│             │                       │               │
│             │                       ▼               │
│             │              ┌───────────────────┐    │
│             │              │ FlutterEngine     │    │
│             ▼              │ (singleton)       │    │
│   ┌───────────────────┐    │                   │    │
│   │ FlutterHostView   │◄───┤  MethodChannel    │    │
│   │                   │    │  EventChannel     │    │
│   └─────────┬─────────┘    └────────┬──────────┘    │
└─────────────┼───────────────────────┼───────────────┘
              │                       │
              ▼                       ▼
          (Flutter UI)            (data stream)
```

## What's in this repo right now

| Path                                           | Purpose |
| ---------------------------------------------- | ------- |
| `NativeFlutter/NativeFlutter.xcodeproj`        | The SwiftUI app project |
| `NativeFlutter/NativeFlutter/Models/User.swift`| Shared user model |
| `NativeFlutter/NativeFlutter/Store/UsersStore.swift` | JSON-Codable persistence, single source of truth |
| `NativeFlutter/NativeFlutter/Flutter/*.swift`  | Engine manager + bridges, all gated behind `#if canImport(Flutter)` |
| `NativeFlutter/NativeFlutter/Screens/*.swift`  | `UsersListView`, `CreateUserSheet` |
| `NativeFlutter/Podfile`                        | Add-to-app integration; pointed at `../flutter_module` |
| `README.md` (this file)                        | Channel contract + Flutter stub |

The app **builds and runs today** with the Flutter screen showing a
placeholder. The Flutter side activates the moment a Flutter dev
runs the steps below.

---

## Cloning fresh

`flutter_module/.ios/`, `flutter_module/.dart_tool/`, and
`NativeFlutter/Pods/` are git-ignored — they're regenerated locally.
After cloning, run:

```bash
cd flutter_module && flutter pub get && cd ..
cd NativeFlutter && pod install && cd ..
open NativeFlutter/NativeFlutter.xcworkspace
```

---

## For the Flutter developer — setup

> Run these from the project root (`Desktop/NativeFlutter/`).

### 1. Create the Flutter module

```bash
flutter create --template=module flutter_module
```

This produces a sibling `flutter_module/` next to the existing
`NativeFlutter/` Xcode project.

### 2. Install the Flutter pods

```bash
cd NativeFlutter
pod install
```

This generates `NativeFlutter.xcworkspace`. **From now on always open
the `.xcworkspace`, never the `.xcodeproj`.**

> If you're starting from a brand-new Xcode project, also set
> `ENABLE_USER_SCRIPT_SANDBOXING = NO` on the host app target
> (project.pbxproj). Xcode 16+ enables script sandboxing by default
> and Flutter's "Run Flutter Build" script needs to write outside
> the sandbox. The Podfile's `post_install` hook already turns it
> off for the Pods project; the host target you have to flip
> yourself.

### 3. Wire up the Dart side

Replace `flutter_module/lib/main.dart` with the file below, and add
a couple of dependencies to `flutter_module/pubspec.yaml`.

`flutter_module/pubspec.yaml` (under `dependencies:`):

```yaml
dependencies:
  flutter:
    sdk: flutter
  intl: ^0.20.0  # optional, only for the date formatter in the demo
```

`flutter_module/lib/main.dart` — minimal bridge demo:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const FlutterModuleApp());

const _users = MethodChannel('com.huh.nativeflutter/users');
const _usersStream = EventChannel('com.huh.nativeflutter/users/stream');

class FlutterModuleApp extends StatelessWidget {
  const FlutterModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF06B6D4),
        useMaterial3: true,
      ),
      home: const UsersScreen(),
    );
  }
}

class UserDTO {
  final String id;
  final String name;
  final String email;
  final String source;   // 'ios' | 'flutter'
  final DateTime createdAt;

  UserDTO.fromMap(Map<dynamic, dynamic> m)
      : id = m['id'] as String,
        name = m['name'] as String,
        email = m['email'] as String,
        source = m['source'] as String,
        createdAt = DateTime.parse(m['createdAt'] as String);
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserDTO> _users = [];
  late final Stream<List<UserDTO>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _usersStream.receiveBroadcastStream().map(
      (e) => (e as List).map((m) => UserDTO.fromMap(m as Map)).toList(),
    );
    _stream.listen((u) => setState(() => _users = u));
  }

  Future<void> _add() async {
    final result = await showDialog<({String name, String email})>(
      context: context,
      builder: (_) => const _AddDialog(),
    );
    if (result == null) return;
    await _users.invokeMethod('createUser', {
      'name': result.name,
      'email': result.email,
    });
    // The EventChannel will push the new list — no manual reload.
  }

  Future<void> _closeFlutter() => _users.invokeMethod('closeFlutter');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter side'),
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: _closeFlutter),
        ],
      ),
      body: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final u = _users[i];
          return ListTile(
            leading: CircleAvatar(child: Text(u.name.isEmpty ? '?' : u.name[0])),
            title: Text(u.name),
            subtitle: Text(u.email),
            trailing: Chip(
              label: Text(u.source == 'ios' ? 'iOS' : 'Flutter'),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddDialog extends StatefulWidget {
  const _AddDialog();
  @override
  State<_AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<_AddDialog> {
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New user (from Flutter)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _name,  decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            (name: _name.text.trim(), email: _email.text.trim()),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
```

### 4. Build and run

Open `NativeFlutter/NativeFlutter.xcworkspace` in Xcode, hit Run.
The placeholder in the Flutter tab is replaced by the live Flutter
screen, and the two sides share the user list.

---

## Channel contract (authoritative)

### MethodChannel — `com.huh.nativeflutter/users`

Request/response. Flutter calls Swift.

| Method        | Arguments                            | Returns                          | Notes |
| ------------- | ------------------------------------ | -------------------------------- | ----- |
| `getUsers`    | none                                 | `List<Map<String,dynamic>>`      | Full snapshot, useful for one-shot reads. Most clients should rely on the EventChannel instead. |
| `createUser`  | `{ name: String, email: String }`    | `Map<String,dynamic>` (new user) | Source is set to `"flutter"` automatically. Validates non-empty fields. |
| `deleteUser`  | `{ id: String }`                     | `true`                           | No-op if id not found. |
| `closeFlutter`| none                                 | `null`                           | Posts `flutterRequestedClose` on the SwiftUI side; the host pops the Flutter screen. |

### EventChannel — `com.huh.nativeflutter/users/stream`

Server-pushed. Each event is the full users array. Flutter just
replaces its local state.

Event payload shape:

```jsonc
[
  {
    "id": "1F2E…",
    "name": "Ali Karimov",
    "email": "ali@example.com",
    "source": "ios",          // or "flutter"
    "createdAt": "2026-05-15T11:03:00.000Z"
  },
  ...
]
```

The first event sent immediately on `onListen` is the current
snapshot. Every subsequent event is a snapshot taken when something
changed (add/delete from either side).

### User payload (canonical)

```ts
type User = {
  id: string;             // UUID
  name: string;
  email: string;
  source: "ios" | "flutter";
  createdAt: string;      // ISO-8601 with milliseconds, UTC
};
```

---

## How the Swift side is wired

- **`FlutterEngineManager.shared`** — one `FlutterEngine` for the whole
  app, started in `App.init` via `FlutterEngineManager.warmUp()`.
  Channels attach to its `binaryMessenger` exactly once.
- **`UsersStore.shared`** — `ObservableObject` with `@Published var users`.
  Persists to `Documents/users.json` via Codable. All mutations go
  through `add(...)` / `delete(...)` — Flutter doesn't see the file.
- **`UsersBridgeChannel`** — `FlutterMethodChannel`. Hands `getUsers`,
  `createUser`, `deleteUser`, `closeFlutter`.
- **`UsersEventChannel`** — `FlutterEventChannel`. On `onListen`,
  subscribes to `store.$users` via Combine and pushes every change
  to the Flutter sink.
- **`FlutterHostView`** — `UIViewControllerRepresentable` that hosts
  `FlutterViewController` bound to the singleton engine. Push it
  from a `NavigationLink`.

Everything under `Flutter/` is wrapped in
`#if canImport(Flutter)` so the app keeps building before the
module is integrated — `FlutterHostView` falls back to a
placeholder view, and `FlutterEngineManager.warmUp()` is a no-op.

---

## Adding new bridge methods later

1. Add a `case` in `UsersBridgeChannel.handle(call:result:)`.
2. Document it in this README's contract table.
3. Implement the matching call on the Dart side.

For one-off data the host wants to push (auth token, theme change,
session expired), call `channel.invokeMethod(...)` from Swift and
register a `setMethodCallHandler` on Dart.

For continuous streams (balance, notifications, presence), add
another `FlutterEventChannel` rather than chatty polling on the
MethodChannel.
