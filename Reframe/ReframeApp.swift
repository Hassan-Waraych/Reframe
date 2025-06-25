//
//  ReframeApp.swift
//  Reframe
//
//  Created by Hassan Waraych on 2025-05-30.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct ReframeApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authService = AuthService.shared
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(authService)
                .onOpenURL { url in
                    // Handle Google Sign-In URL callback
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
