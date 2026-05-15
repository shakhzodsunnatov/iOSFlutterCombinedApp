//
//  FlutterEngineManager.swift
//  NativeFlutter
//
//  One long-lived FlutterEngine for the whole app. Warm it up at
//  launch so the first Flutter screen opens instantly. All channel
//  handlers are attached here, against this single engine.
//
//  Everything is gated behind `canImport(Flutter)` so the app still
//  builds before the Flutter dev runs `pod install`. When the pods
//  are wired up, this file activates automatically — no further
//  Swift-side changes needed.
//

import Foundation

#if canImport(Flutter)
import Flutter

@MainActor
final class FlutterEngineManager {
    static let shared = FlutterEngineManager()

    let engine: FlutterEngine

    private let methodBridge: UsersBridgeChannel
    private let eventBridge: UsersEventChannel

    private init() {
        let engine = FlutterEngine(name: "main_flutter_engine")
        engine.run(withEntrypoint: nil)
        self.engine = engine

        self.methodBridge = UsersBridgeChannel(engine: engine, store: UsersStore.shared)
        self.eventBridge = UsersEventChannel(engine: engine, store: UsersStore.shared)
    }

    /// Call from `App.init` to warm up the engine before the user
    /// taps "Open Flutter".
    static func warmUp() {
        _ = FlutterEngineManager.shared
    }
}

#else

// Flutter SDK not yet integrated. Calling warmUp() is a no-op so
// the rest of the app keeps building.
@MainActor
enum FlutterEngineManager {
    static func warmUp() {}
}

#endif
