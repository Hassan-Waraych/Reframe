import SwiftUI

struct UserAvatar: View {
    let size: CGFloat
    let email: String?
    @EnvironmentObject var themeManager: ThemeManager
    
    init(size: CGFloat = 70, email: String? = nil) {
        self.size = size
        self.email = email
    }
    
    private var userInitials: String {
        guard let email = email, !email.isEmpty else {
            return "U"
        }
        
        // Extract initials from email (before @ symbol)
        let namePart = email.components(separatedBy: "@").first ?? ""
        let components = namePart.components(separatedBy: CharacterSet.alphanumerics.inverted)
        let filteredComponents = components.filter { !$0.isEmpty }
        
        if filteredComponents.count >= 2 {
            // Use first letter of first and last name
            let first = String(filteredComponents[0].prefix(1)).uppercased()
            let last = String(filteredComponents[filteredComponents.count - 1].prefix(1)).uppercased()
            return "\(first)\(last)"
        } else if filteredComponents.count == 1 {
            // Use first two letters of single name
            let name = filteredComponents[0]
            if name.count >= 2 {
                return String(name.prefix(2)).uppercased()
            } else {
                return String(name.prefix(1)).uppercased()
            }
        } else {
            // Fallback to first letter of email
            return String(email.prefix(1)).uppercased()
        }
    }
    
    private var avatarGradient: LinearGradient {
        // Create a consistent gradient based on the user's email
        let colors: [Color] = [
            themeManager.colors.primary,
            themeManager.colors.primaryDark,
            themeManager.colors.secondary,
            themeManager.colors.accent
        ]
        
        // Use email hash to determine gradient colors
        let hash = email?.hashValue ?? 0
        let colorIndex1 = abs(hash) % colors.count
        let colorIndex2 = (colorIndex1 + 1) % colors.count
        
        return LinearGradient(
            gradient: Gradient(colors: [colors[colorIndex1], colors[colorIndex2]]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            avatarGradient
                .frame(width: size, height: size)
                .clipShape(Circle())
            
            // User initials
            Text(userInitials)
                .font(.custom("Quicksand-Bold", size: size * 0.4))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // Border
            Circle()
                .stroke(themeManager.colors.primary.opacity(0.3), lineWidth: 2)
                .frame(width: size, height: size)
        }
        .shadow(color: themeManager.colors.primary.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        UserAvatar(size: 80, email: "john.doe@example.com")
        UserAvatar(size: 60, email: "jane@example.com")
        UserAvatar(size: 50, email: "user@test.com")
        UserAvatar(size: 40, email: nil)
    }
    .padding()
    .environmentObject(ThemeManager())
} 