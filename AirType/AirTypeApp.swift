//
//  AirTypeApp.swift
//  Controlla
//
//  Main app entry point
//

import SwiftUI

@main
struct AirTypeApp: App {
    @StateObject private var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeManager)
        }
    }
}
