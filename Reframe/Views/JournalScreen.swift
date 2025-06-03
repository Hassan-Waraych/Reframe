import SwiftUI

struct JournalScreen: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.colors.primary)
            
            Text("Journal Coming Soon")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(themeManager.colors.text)
            
            Text("We're working on bringing you a beautiful journaling experience. Stay tuned!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.colors.textLight)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.colors.background)
        .navigationTitle("Journal")
    }
}

#Preview {
    JournalScreen(selectedTab: .constant(1))
        .environmentObject(ThemeManager())
} 