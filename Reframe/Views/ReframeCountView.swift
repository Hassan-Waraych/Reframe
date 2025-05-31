import SwiftUI

struct ReframeCountView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: ReframeViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Daily Reframes")
                .font(.custom("Nunito-Regular", size: 14))
                .foregroundColor(themeManager.colors.textLight)
            
            HStack(spacing: 4) {
                Text("\(viewModel.remainingReframes)")
                    .font(.custom("Quicksand-Bold", size: 24))
                    .foregroundColor(themeManager.colors.primary)
                
                Text("/ 5")
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(themeManager.colors.textLight)
            }
            
            if !viewModel.canCreateReframe {
                Text("Daily limit reached")
                    .font(.custom("Nunito-Regular", size: 12))
                    .foregroundColor(themeManager.colors.error)
            }
        }
        .padding(16)
        .background(themeManager.colors.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ReframeCountView(viewModel: ReframeViewModel())
        .environmentObject(ThemeManager())
} 