//
//  CreateUserSheet.swift
//  NativeFlutter
//
//  Modal form for creating a user from the iOS side. The new user
//  is tagged with .ios so the table row badge shows it was born on
//  this side of the bridge. Flutter still sees the same row through
//  the EventChannel.
//

import SwiftUI

struct CreateUserSheet: View {
    @EnvironmentObject private var store: UsersStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Full name", text: $name)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section {
                    Label("Created from iOS", systemImage: "apple.logo")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            .navigationTitle("New user")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        _ = store.add(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                            source: .ios
                        )
                        dismiss()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var isValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && trimmedEmail.contains("@") && trimmedEmail.contains(".")
    }
}

#Preview {
    CreateUserSheet()
        .environmentObject(UsersStore.shared)
}
