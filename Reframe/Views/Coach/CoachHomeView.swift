import SwiftUI

struct CoachHomeView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var selectedTab: Int
    @StateObject private var viewModel = CoachHomeViewModel()
    @StateObject private var authService = AuthService.shared
    @State private var showInputSheet = false
    @State private var showCoachDetails = false
    @State private var showHistoryView = false
    @State private var showEmotionalFraming = false
    @State private var showSwitchCoachModal = false
    @State private var showPaywall = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(themeManager.colors.primary)
                            .frame(width: 48, height: 48)
                            .background(themeManager.colors.surface)
                            .clipShape(Circle())
                            .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    Text("Coach")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Coach Info Section
                if let coach = viewModel.currentCoach {
                    coachInfoSection(coach: coach)
                    
                    // Switch Coach Button
                    Button(action: {
                        if authService.isPremiumUser() {
                            showSwitchCoachModal = true
                        } else {
                            showPaywall = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Switch Coach")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(themeManager.colors.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(themeManager.colors.surface)
                        .cornerRadius(12)
                        .overlay(
                            Group {
                                if !authService.isPremiumUser() {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.yellow)
                                        .rotationEffect(.degrees(-15))
                                        .offset(x: 74, y: -16)
                                }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Talk to Your Coach Section
                    talkToCoachSection
                    
                    // Usage Limit Section
                    if !authService.isPremiumUser() {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Coach Sessions Used (This Week)")
                                    .font(.custom("Quicksand-SemiBold", size: 16))
                                    .foregroundColor(themeManager.colors.text)
                                Spacer()
                                let maxCount = 3
                                let displayCount = min(viewModel.coachUsageCount, maxCount)
                                Text("\(displayCount)/\(maxCount)")
                                    .font(.custom("Nunito-Medium", size: 16))
                                    .foregroundColor(themeManager.colors.textLight)
                            }
                            GeometryReader { geometry in
                                let maxCount = 3
                                let displayCount = min(viewModel.coachUsageCount, maxCount)
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeManager.colors.surface)
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    themeManager.colors.primary,
                                                    themeManager.colors.primaryDark
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * CGFloat(displayCount) / CGFloat(maxCount), height: 12)
                                }
                            }
                            .frame(height: 12)
                            
                            Button(action: {
                                showPaywall = true
                            }) {
                                Text("Upgrade for 25 coach sessions per day")
                                    .font(.custom("Nunito-SemiBold", size: 14))
                                    .foregroundColor(themeManager.colors.primary)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Coach Sessions Used (Today)")
                                    .font(.custom("Quicksand-SemiBold", size: 16))
                                    .foregroundColor(themeManager.colors.text)
                                Spacer()
                                let maxCount = 25
                                let displayCount = min(viewModel.coachUsageCount, maxCount)
                                Text("\(displayCount)/\(maxCount)")
                                    .font(.custom("Nunito-Medium", size: 16))
                                    .foregroundColor(themeManager.colors.textLight)
                            }
                            GeometryReader { geometry in
                                let maxCount = 25
                                let displayCount = min(viewModel.coachUsageCount, maxCount)
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeManager.colors.surface)
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    themeManager.colors.primary,
                                                    themeManager.colors.primaryDark
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * CGFloat(displayCount) / CGFloat(maxCount), height: 12)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Past Conversations Section
                    pastConversationsSection
                } else {
                    // No Coach Assigned
                    VStack(spacing: 24) {
                        Text("Find Your Perfect Coach")
                            .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text("Let's match you with a coach who understands your needs")
                            .font(.system(size: themeManager.typography.fontSize.body))
                            .foregroundColor(themeManager.colors.textLight)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showEmotionalFraming = true
                        }) {
                            Text("Choose Your Coach")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(themeManager.colors.primary)
                                .cornerRadius(16)
                        }
                    }
                    .padding(24)
                    .background(themeManager.colors.surface)
                    .cornerRadius(16)
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
        }
        .background(themeManager.colors.background)
        .navigationBarHidden(true)
        .sheet(isPresented: $showInputSheet) {
            CoachInputSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showCoachDetails) {
            if let coach = viewModel.currentCoach {
                coachDetailsModal(coach: coach)
            }
        }
        .sheet(isPresented: $showHistoryView) {
            CoachHistoryView(viewModel: viewModel)
        }
        .sheet(isPresented: $showEmotionalFraming) {
            CoachEmotionalFramingView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSwitchCoachModal) {
            CoachSwitchingModal(viewModel: viewModel)
        }
        .sheet(isPresented: $showPaywall) {
            PremiumModalScreen()
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .onChange(of: showSwitchCoachModal) { isShowing in
            if !isShowing {
                // Refresh coach data when the modal is dismissed
                Task {
                    await viewModel.loadData()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.resetState()
            }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
    
    private func coachInfoSection(coach: Coach) -> some View {
        Button(action: { showCoachDetails = true }) {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 16) {
                    Text(coach.emoji)
                        .font(.system(size: 48))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(coach.name)
                            .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text(coach.description)
                            .font(.system(size: themeManager.typography.fontSize.body))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                }
                
                // Quote
                Text(coach.quote)
                    .font(.system(size: themeManager.typography.fontSize.body, weight: .medium))
                    .foregroundColor(themeManager.colors.text)
                    .italic()
                    .padding(.vertical, 8)
                
                // View More Indicator
                HStack {
                    Text("View full profile")
                        .font(.system(size: themeManager.typography.fontSize.body, weight: .medium))
                        .foregroundColor(themeManager.colors.primary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.colors.primary)
                }
            }
            .padding(24)
            .background(themeManager.colors.surface)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func coachDetailsModal(coach: Coach) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack(spacing: 16) {
                        Text(coach.emoji)
                            .font(.system(size: 48))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(coach.name)
                                .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                                .foregroundColor(themeManager.colors.text)
                            
                            Text(coach.description)
                                .font(.system(size: themeManager.typography.fontSize.body))
                                .foregroundColor(themeManager.colors.textLight)
                        }
                    }
                    
                    // Quote
                    Text(coach.quote)
                        .font(.system(size: themeManager.typography.fontSize.body, weight: .medium))
                        .foregroundColor(themeManager.colors.text)
                        .italic()
                        .padding(.vertical, 8)
                    
                    // Background
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Background")
                            .font(.system(size: themeManager.typography.fontSize.h3, weight: .semibold))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text(coach.background)
                            .font(.system(size: themeManager.typography.fontSize.body))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    // Approach
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Their Approach")
                            .font(.system(size: themeManager.typography.fontSize.h3, weight: .semibold))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text(coach.approach)
                            .font(.system(size: themeManager.typography.fontSize.body))
                            .foregroundColor(themeManager.colors.textLight)
                    }
                    
                    // Specialties
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Specialties")
                            .font(.system(size: themeManager.typography.fontSize.h3, weight: .semibold))
                            .foregroundColor(themeManager.colors.text)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(coach.specialties, id: \.self) { specialty in
                                Text(specialty)
                                    .font(.system(size: themeManager.typography.fontSize.small))
                                    .foregroundColor(themeManager.colors.text)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(themeManager.colors.surface)
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(themeManager.colors.background)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Coach Profile")
                        .font(.custom("Quicksand-Bold", size: 20))
                        .foregroundColor(themeManager.colors.text)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showCoachDetails = false
                    }
                    .foregroundColor(themeManager.colors.text)
                }
            }
        }
    }
    
    private var talkToCoachSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Talk to Your Coach")
                .font(.system(size: themeManager.typography.fontSize.h2, weight: .bold))
                .foregroundColor(themeManager.colors.text)
            
            Button(action: { showInputSheet = true }) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 20))
                    Text("Share your thoughts")
                        .font(.system(size: themeManager.typography.fontSize.body, weight: .medium))
                }
                .foregroundColor(themeManager.colors.text)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(themeManager.colors.primary)
                .cornerRadius(16)
            }
        }
    }
    
    private var pastConversationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Past Conversations")
                    .font(.system(size: themeManager.typography.fontSize.h3, weight: .semibold))
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
                
                Button(action: {
                    showHistoryView = true
                }) {
                    Text("View All")
                        .font(.system(size: themeManager.typography.fontSize.body, weight: .medium))
                        .foregroundColor(themeManager.colors.primary)
                }
            }
            
            if viewModel.historyItems.isEmpty {
                Text("No past conversations yet")
                    .font(.system(size: themeManager.typography.fontSize.body))
                    .foregroundColor(themeManager.colors.text.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(viewModel.historyItems.prefix(3))) { item in
                        NavigationLink(destination: CoachConversationDetailView(item: item)) {
                            ConversationCard(item: item)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, proposal: proposal).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, proposal: proposal).offsets
        
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }
    
    private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> (offsets: [CGPoint], size: CGSize) {
        guard let containerWidth = proposal.width else {
            return (sizes.map { _ in .zero }, .zero)
        }
        
        var offsets: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for size in sizes {
            if currentX + size.width > containerWidth {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            offsets.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            maxY = max(maxY, currentY + rowHeight)
        }
        
        return (offsets, CGSize(width: containerWidth, height: maxY))
    }
}

#Preview {
    CoachHomeView(selectedTab: .constant(0))
        .environmentObject(ThemeManager())
} 