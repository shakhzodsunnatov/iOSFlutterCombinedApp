//
//  NativeFlutterApp.swift
//  NativeFlutter
//
//  App entry point. Warms up the Flutter engine at launch so the
//  first push of the Flutter screen is instant, and injects the
//  shared UsersStore into the SwiftUI environment.
//

import SwiftUI

@main
struct NativeFlutterApp: App {
    init() {
        FlutterEngineManager.warmUp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UsersStore.shared)
        }
    }
}
