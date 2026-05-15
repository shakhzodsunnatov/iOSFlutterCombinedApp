//
//  UsersListView.swift
//  NativeFlutter
//
//  Main screen. Shows every user the store knows about, with a
//  badge telling you who created it (iOS vs Flutter), a + button
//  to add a new one natively, and a "Open Flutter" button that
//  pushes the embedded Flutter UI.
//

import SwiftUI

struct UsersListView: View {
    @EnvironmentObject private var store: UsersStore
    @State private var isCreatingUser = false
    @State private var flutterRoute: String?  // nil → not pushed; "users"/"create" → pushed at that route

    var body: some View {
        NavigationStack {
            Group {
                if store.users.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreatingUser = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add user")
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(.bar)
            }
            .sheet(isPresented: $isCreatingUser) {
                CreateUserSheet()
                    .environmentObject(store)
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { flutterRoute != nil },
                    set: { if !$0 { flutterRoute = nil } }
                )
            ) {
                // Flutter takes the whole screen — iOS nav bar and
                // back button are hidden; the only way back is via
                // Flutter's own close button (which calls closeFlutter
                // on the bridge → NotificationCenter → flutterRoute = nil).
                FlutterHostView(route: flutterRoute ?? "users")
                    .ignoresSafeArea()
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationBarBackButtonHidden(true)
            }
            .onReceive(NotificationCenter.default.publisher(for: .flutterRequestedClose)) { _ in
                flutterRoute = nil
            }
        }
    }

    // MARK: - Pieces

    private var list: some View {
        List {
            ForEach(store.users) { user in
                UserRow(user: user)
            }
            .onDelete { offsets in
                for index in offsets {
                    let id = store.users[index].id
                    store.delete(id: id)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No users yet")
                .font(.headline)
            Text("Tap + to add one from iOS, or open the Flutter screen to add one from there.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            Button {
                flutterRoute = "users"
            } label: {
                Label("Open Flutter Screen", systemImage: "arrow.up.right.square")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                flutterRoute = "create"
            } label: {
                Label("Add User via Flutter", systemImage: "plus.rectangle.on.rectangle")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.cyan)
        }
    }
}

// MARK: - Row

private struct UserRow: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            avatar
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(user.email)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(user.createdAt, format: .relative(presentation: .named))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            sourceBadge
        }
        .padding(.vertical, 4)
    }

    private var avatar: some View {
        Circle()
            .fill(user.source == .ios ? Color.blue.opacity(0.15) : Color.cyan.opacity(0.18))
            .frame(width: 40, height: 40)
            .overlay(
                Text(initials)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(user.source == .ios ? Color.blue : Color.cyan)
            )
    }

    private var initials: String {
        let parts = user.name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }

    private var sourceBadge: some View {
        let isIOS = user.source == .ios
        return HStack(spacing: 4) {
            Image(systemName: isIOS ? "apple.logo" : "bolt.fill")
                .font(.caption2)
            Text(user.source.displayName)
                .font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isIOS ? Color.blue.opacity(0.12) : Color.cyan.opacity(0.18))
        )
        .foregroundStyle(isIOS ? Color.blue : Color.cyan)
    }
}

#Preview {
    UsersListView()
        .environmentObject(UsersStore.shared)
}
