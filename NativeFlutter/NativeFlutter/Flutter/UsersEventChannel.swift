//
//  UsersEventChannel.swift
//  NativeFlutter
//
//  EventChannel — streams the users list to Flutter whenever it
//  changes on the Swift side (or whenever Flutter itself mutates it
//  through the MethodChannel, since the store updates the same way).
//
//  Channel name: "com.huh.nativeflutter/users/stream"
//
//  Each event delivered to Flutter is a `List<Map<String,dynamic>>`
//  — the full users array. Flutter just replaces its local state.
//

import Foundation
import Combine

#if canImport(Flutter)
import Flutter

@MainActor
final class UsersEventChannel: NSObject {
    static let channelName = "com.huh.nativeflutter/users/stream"

    private let channel: FlutterEventChannel
    private let store: UsersStore
    private let handler: StreamHandler

    init(engine: FlutterEngine, store: UsersStore) {
        let handler = StreamHandler(store: store)
        self.handler = handler
        self.channel = FlutterEventChannel(
            name: Self.channelName,
            binaryMessenger: engine.binaryMessenger
        )
        self.store = store
        super.init()
        channel.setStreamHandler(handler)
    }

    // FlutterStreamHandler must be NSObject-conformant, and Combine
    // subscriptions are easier to manage on a dedicated object.
    final class StreamHandler: NSObject, FlutterStreamHandler {
        private let store: UsersStore
        private var sink: FlutterEventSink?
        private var cancellable: AnyCancellable?

        init(store: UsersStore) {
            self.store = store
        }

        func onListen(
            withArguments arguments: Any?,
            eventSink events: @escaping FlutterEventSink
        ) -> FlutterError? {
            // Capture sink, push current snapshot immediately, then
            // forward every subsequent change.
            self.sink = events
            Task { @MainActor [weak self] in
                guard let self else { return }
                events(self.store.bridgeDictionaries())
                self.cancellable = self.store.$users
                    .dropFirst() // skip the initial value, already sent above
                    .sink { [weak self] _ in
                        guard let self else { return }
                        self.sink?(self.store.bridgeDictionaries())
                    }
            }
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            cancellable?.cancel()
            cancellable = nil
            sink = nil
            return nil
        }
    }
}

#endif
