import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDark: Bool = false
    
    var colors: ThemeColors {
        isDark ? .dark : .light
    }
    
    var typography: Typography {
        Typography()
    }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDark.toggle()
        }
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