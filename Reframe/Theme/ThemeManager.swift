import SwiftUI

enum ThemeType: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case midnightGold = "Midnight Gold"
    case sunsetSerenity = "Sunset Serenity"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .midnightGold:
            return "sparkles"
        case .sunsetSerenity:
            return "sunset.fill"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .light, .dark:
            return false
        case .midnightGold, .sunsetSerenity:
            return true
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var selectedTheme: ThemeType {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        // Load the saved theme preference, default to light if not set
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "Light"
        self.selectedTheme = ThemeType(rawValue: savedTheme) ?? .light
    }
    
    var colors: ThemeColors {
        switch selectedTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .midnightGold:
            return .midnightGold
        case .sunsetSerenity:
            return .sunsetSerenity
        }
    }
    
    var typography: Typography {
        Typography()
    }
    
    func setTheme(_ theme: ThemeType) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedTheme = theme
        }
    }
    
    func canSelectTheme(_ theme: ThemeType, isPremiumUser: Bool) -> Bool {
        if theme.isPremium {
            return isPremiumUser
        }
        return true
    }
    
    // Special theme-specific methods
    var backgroundGradient: LinearGradient? {
        switch selectedTheme {
        case .sunsetSerenity:
            return LinearGradient.sunsetBackground()
        default:
            return nil
        }
    }
    
    var primaryGradient: LinearGradient? {
        switch selectedTheme {
        case .sunsetSerenity:
            return LinearGradient.sunsetGradient()
        default:
            return nil
        }
    }
    
    var hasSpecialEffects: Bool {
        return selectedTheme == .sunsetSerenity
    }
    
    // Special floating particles for Sunset Serenity theme
    @ViewBuilder
    func sunsetParticles() -> some View {
        if selectedTheme == .sunsetSerenity {
            ZStack {
                // Large floating orbs
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF6B35").opacity(0.4),
                                    Color(hex: "FF8A65").opacity(0.2),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .position(
                            x: CGFloat.random(in: 100...300),
                            y: CGFloat.random(in: 200...700)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 4...8))
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
                
                // Small sparkles
                ForEach(0..<12, id: \.self) { index in
                    Image(systemName: "sparkle")
                        .font(.system(size: CGFloat.random(in: 8...16)))
                        .foregroundColor(Color(hex: "FFD700"))
                        .position(
                            x: CGFloat.random(in: 50...350),
                            y: CGFloat.random(in: 100...800)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...5))
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
            }
            .allowsHitTesting(false)
        }
    }
    
    // Custom background modifier for special themes
    func customBackground() -> some View {
        Group {
            if selectedTheme == .sunsetSerenity {
                ZStack {
                    // Base gradient
                    LinearGradient.sunsetBackground()
                    
                    // Sunset rays effect
                    VStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { index in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "FF6B35").opacity(0.1),
                                            Color.clear
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 60)
                                .rotationEffect(.degrees(Double(index) * 45))
                                .offset(x: CGFloat(index) * 50 - 200)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                }
                .ignoresSafeArea()
            } else {
                colors.background
                    .ignoresSafeArea()
            }
        }
    }
    
    // Custom surface modifier for special themes
    func customSurface() -> some View {
        Group {
            if selectedTheme == .sunsetSerenity {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.95),
                                Color(hex: "FFF0E6").opacity(0.9),
                                Color(hex: "FFE8D6").opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "FF6B35").opacity(0.3),
                                        Color(hex: "9B5DE5").opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color(hex: "FF6B35").opacity(0.2), radius: 15, x: 0, y: 8)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    // Legacy support for isDark property
    var isDark: Bool {
        return selectedTheme == .dark
    }
    
    func toggleTheme() {
        // Legacy method - cycles through themes
        let currentIndex = ThemeType.allCases.firstIndex(of: selectedTheme) ?? 0
        let nextIndex = (currentIndex + 1) % ThemeType.allCases.count
        setTheme(ThemeType.allCases[nextIndex])
    }
}

struct ThemeColors {
    let background: Color
    let surface: Color
    let primary: Color
    let primaryLight: Color
    let primaryDark: Color
    let secondary: Color
    let text: Color
    let textLight: Color
    let border: Color
    let accent: Color
    let success: Color
    let error: Color
    
    static let light = ThemeColors(
        background: Color(hex: "FFF9F5"), // Warm off-white
        surface: Color(hex: "FFFFFF"),
        primary: Color(hex: "FF7F6B"), // Warm coral
        primaryLight: Color(hex: "FF9D8D"),
        primaryDark: Color(hex: "E66B57"),
        secondary: Color(hex: "9B6B9E"), // Warm purple
        text: Color(hex: "2C3E50"), // Deep charcoal
        textLight: Color(hex: "607C8A"),
        border: Color(hex: "E0E0E0"),
        accent: Color(hex: "7FD1C7"), // Soft mint
        success: Color(hex: "4CAF50"),
        error: Color(hex: "FF5252")
    )
    
    static let dark = ThemeColors(
        background: Color(hex: "1A1A1A"),
        surface: Color(hex: "2D2D2D"),
        primary: Color(hex: "FF7F6B"), // Keep the warm coral
        primaryLight: Color(hex: "FF9D8D"),
        primaryDark: Color(hex: "E66B57"),
        secondary: Color(hex: "9B6B9E"), // Keep the warm purple
        text: Color(hex: "FFFFFF"),
        textLight: Color(hex: "B0B0B0"),
        border: Color(hex: "404040"),
        accent: Color(hex: "7FD1C7"), // Keep the soft mint
        success: Color(hex: "4CAF50"),
        error: Color(hex: "FF5252")
    )
    
    static let midnightGold = ThemeColors(
        background: Color(hex: "0A0A0F"), // Deep midnight blue-black
        surface: Color(hex: "1A1A2E"), // Dark navy surface
        primary: Color(hex: "FFD700"), // Rich gold
        primaryLight: Color(hex: "FFE55C"),
        primaryDark: Color(hex: "D4AF37"),
        secondary: Color(hex: "B8860B"), // Dark goldenrod
        text: Color(hex: "F5F5DC"), // Beige white
        textLight: Color(hex: "D2B48C"), // Tan
        border: Color(hex: "2A2A3E"), // Dark navy border
        accent: Color(hex: "FFA500"), // Orange accent
        success: Color(hex: "32CD32"), // Lime green
        error: Color(hex: "FF6B6B") // Soft red
    )
    
    static let sunsetSerenity = ThemeColors(
        background: Color(hex: "FFF8F0"), // Warm cream background
        surface: Color(hex: "FFFFFF"), // Pure white surface
        primary: Color(hex: "FF6B35"), // Vibrant sunset orange
        primaryLight: Color(hex: "FF8A65"),
        primaryDark: Color(hex: "E55A2B"),
        secondary: Color(hex: "9B5DE5"), // Soft lavender purple
        text: Color(hex: "2D3748"), // Deep charcoal
        textLight: Color(hex: "718096"), // Muted gray
        border: Color(hex: "E2E8F0"), // Soft gray border
        accent: Color(hex: "F7FAFC"), // Very light blue-gray
        success: Color(hex: "48BB78"), // Soft green
        error: Color(hex: "F56565") // Soft coral red
    )
}

struct Typography {
    let fontFamily = FontFamily()
    let fontSize = FontSize()
    
    struct FontFamily {
        let primary = "Quicksand"
        let secondary = "Nunito"
    }
    
    struct FontSize {
        let h1: CGFloat = 34
        let h2: CGFloat = 28
        let h3: CGFloat = 22
        let body: CGFloat = 17
        let small: CGFloat = 14
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Custom gradients for special themes
extension LinearGradient {
    static func sunsetGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FF6B35"), // Sunset orange
                Color(hex: "FF8A65"), // Light orange
                Color(hex: "9B5DE5"), // Lavender
                Color(hex: "FF6B35")  // Back to orange
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func sunsetBackground() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FFF8F0"), // Warm cream
                Color(hex: "FFF0E6"), // Lighter cream
                Color(hex: "FFE8D6"), // Peach tint
                Color(hex: "FFF8F0")  // Back to cream
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
} 