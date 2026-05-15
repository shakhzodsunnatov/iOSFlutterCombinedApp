//
//  UsersStore.swift
//  NativeFlutter
//
//  Single source of truth for users. Swift owns the database;
//  Flutter reads/writes through the MethodChannel and observes
//  changes through the EventChannel. Never let Flutter touch
//  storage directly.
//

import Foundation
import Combine

@MainActor
final class UsersStore: ObservableObject {
    static let shared = UsersStore()

    @Published private(set) var users: [User] = []

    private let storageURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.storageURL = docs.appendingPathComponent("users.json")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        load()
    }

    // MARK: - Public API

    func add(name: String, email: String, source: User.Source) -> User {
        let user = User(name: name, email: email, source: source)
        users.append(user)
        save()
        return user
    }

    func delete(id: String) {
        users.removeAll { $0.id == id }
        save()
    }

    func bridgeDictionaries() -> [[String: Any]] {
        users.map { $0.toBridgeDictionary() }
    }

    // MARK: - Persistence

    private func load() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            users = try decoder.decode([User].self, from: data)
        } catch {
            print("[UsersStore] load failed:", error)
        }
    }

    private func save() {
        do {
            let data = try encoder.encode(users)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("[UsersStore] save failed:", error)
        }
    }
}
