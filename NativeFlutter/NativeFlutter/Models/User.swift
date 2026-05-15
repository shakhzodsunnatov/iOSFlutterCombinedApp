//
//  User.swift
//  NativeFlutter
//
//  Shared user record. Same shape on both sides of the bridge —
//  Swift encodes/decodes via Codable, Flutter receives/sends the
//  matching JSON map over the MethodChannel.
//

import Foundation

struct User: Codable, Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var email: String
    let source: Source
    let createdAt: Date

    enum Source: String, Codable, CaseIterable {
        case ios
        case flutter

        var displayName: String {
            switch self {
            case .ios: "iOS"
            case .flutter: "Flutter"
            }
        }
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        source: Source,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.source = source
        self.createdAt = createdAt
    }
}

// Bridge payload: Flutter sees ISO-8601 strings and plain types.
extension User {
    func toBridgeDictionary() -> [String: Any] {
        [
            "id": id,
            "name": name,
            "email": email,
            "source": source.rawValue,
            "createdAt": ISO8601DateFormatter.bridge.string(from: createdAt),
        ]
    }
}

extension ISO8601DateFormatter {
    static let bridge: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
}
