//
//  UsersBridgeChannel.swift
//  NativeFlutter
//
//  MethodChannel — request/response between Flutter and Swift.
//
//  Channel name: "com.huh.nativeflutter/users"
//
//  Methods Flutter can call:
//    - getUsers()                              -> [Map<String,dynamic>]
//    - createUser({name, email})               -> Map<String,dynamic>
//    - deleteUser({id})                        -> bool
//    - closeFlutter()                          -> null   (asks iOS to pop the Flutter screen)
//
//  Methods Swift calls on Flutter:
//    - presentRoute(String)                    // "users" | "create"
//

import Foundation

extension Notification.Name {
    /// Posted when Flutter asks the host (via `closeFlutter`) to
    /// dismiss the embedded Flutter screen. SwiftUI listens for it
    /// and pops the navigation destination.
    static let flutterRequestedClose = Notification.Name("com.huh.nativeflutter.flutterRequestedClose")
}

#if canImport(Flutter)
import Flutter

@MainActor
final class UsersBridgeChannel {
    static let channelName = "com.huh.nativeflutter/users"

    private let channel: FlutterMethodChannel
    private let store: UsersStore

    init(engine: FlutterEngine, store: UsersStore) {
        self.channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: engine.binaryMessenger
        )
        self.store = store

        channel.setMethodCallHandler { [weak self] call, result in
            Task { @MainActor in
                self?.handle(call: call, result: result)
            }
        }
    }

    /// Swift → Flutter. Used by `FlutterEngineManager.presentRoute(_:)`
    /// to tell the Flutter side which screen to land on.
    func invoke(method: String, arguments: Any?) {
        channel.invokeMethod(method, arguments: arguments)
    }

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getUsers":
            result(store.bridgeDictionaries())

        case "createUser":
            guard
                let args = call.arguments as? [String: Any],
                let name = (args["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
                let email = (args["email"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
                !name.isEmpty, !email.isEmpty
            else {
                result(FlutterError(
                    code: "invalid_arguments",
                    message: "createUser expects { name: String, email: String }",
                    details: nil
                ))
                return
            }
            let user = store.add(name: name, email: email, source: .flutter)
            result(user.toBridgeDictionary())

        case "deleteUser":
            guard
                let args = call.arguments as? [String: Any],
                let id = args["id"] as? String
            else {
                result(FlutterError(
                    code: "invalid_arguments",
                    message: "deleteUser expects { id: String }",
                    details: nil
                ))
                return
            }
            store.delete(id: id)
            result(true)

        case "closeFlutter":
            NotificationCenter.default.post(name: .flutterRequestedClose, object: nil)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

#endif
