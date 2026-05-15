//
//  FlutterHostView.swift
//  NativeFlutter
//
//  SwiftUI wrapper around a FlutterViewController bound to the
//  shared FlutterEngine. Push it from a NavigationLink — Flutter
//  takes over the whole content area.
//
//  When the Flutter SDK isn't integrated yet, this view renders a
//  helpful placeholder instead, so the rest of the app still works.
//

import SwiftUI

#if canImport(Flutter)
import Flutter

struct FlutterHostView: UIViewControllerRepresentable {
    let route: String

    init(route: String = "users") {
        self.route = route
    }

    func makeUIViewController(context: Context) -> FlutterViewController {
        let engine = FlutterEngineManager.shared.engine
        let vc = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        // Tell Flutter which screen to show. Sent right after the VC
        // attaches so the Navigator updates before the first frame
        // is on-screen — no visible flash of the wrong route.
        FlutterEngineManager.presentRoute(route)
        return vc
    }

    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {}
}

#else

// Placeholder shown until the Flutter dev integrates the module.
struct FlutterHostView: View {
    let route: String

    init(route: String = "users") {
        self.route = route
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.dashed")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Flutter module not integrated yet")
                .font(.headline)
            Text("Run `pod install` after the Flutter dev adds the\nflutter_module — see README.md for the steps.")
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

#endif
