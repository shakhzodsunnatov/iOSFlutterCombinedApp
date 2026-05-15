//
//  ContentView.swift
//  NativeFlutter
//
//  Root container — thin wrapper around UsersListView so the
//  default Xcode SwiftUI scaffolding stays intact while the real
//  screen lives next to its peers in Screens/.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        UsersListView()
    }
}

#Preview {
    ContentView()
        .environmentObject(UsersStore.shared)
}
