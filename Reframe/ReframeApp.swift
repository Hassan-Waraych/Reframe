//
//  ReframeApp.swift
//  Reframe
//
//  Created by Hassan Waraych on 2025-05-30.
//

import SwiftUI

@main
struct ReframeApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
    }
}
