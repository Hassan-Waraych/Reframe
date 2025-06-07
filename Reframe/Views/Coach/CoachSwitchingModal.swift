import SwiftUI
import FirebaseFirestore

struct CoachSwitchingModal: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: CoachHomeViewModel
    @State private var selectedCoach: Coach?
    @State private var showCoachDetails = false
    @State private var animateContent = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        Text("Choose Your Coach")
                            .font(.custom("Quicksand-Bold", size: 24))
                            .foregroundColor(themeManager.colors.text)
                            .padding(.top)
                        
                        // Coach Grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.availableCoaches) { coach in
                                CoachTile(coach: coach)
                                    .onTapGesture {
                                        selectedCoach = coach
                                        showCoachDetails = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.colors.text)
                }
            }
        }
        .sheet(isPresented: $showCoachDetails) {
            if let coach = selectedCoach {
                CoachDetailsView(coach: coach)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }
}

struct CoachTile: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let coach: Coach
    
    var body: some View {
        VStack(spacing: 12) {
            // Emoji
            Text(coach.emoji)
                .font(.system(size: 40))
            
            // Name
            Text(coach.name)
                .font(.custom("Quicksand-SemiBold", size: 16))
                .foregroundColor(themeManager.colors.text)
                .multilineTextAlignment(.center)
            
            // Description
            Text(coach.description)
                .font(.custom("Nunito-Regular", size: 12))
                .foregroundColor(themeManager.colors.textLight)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Premium Badge
            if coach.isPremium {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text("Premium")
                        .font(.custom("Nunito-SemiBold", size: 12))
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(themeManager.colors.surface)
        .cornerRadius(16)
        .shadow(color: themeManager.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct CoachDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var authService = AuthService.shared
    @State private var isUpdatingCoach = false
    @State private var showError = false
    @State private var errorMessage: String?
    let coach: Coach
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text(coach.emoji)
                        .font(.system(size: 64))
                    
                    Text(coach.name)
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    if coach.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("Premium Coach")
                                .font(.custom("Nunito-SemiBold", size: 14))
                                .foregroundColor(themeManager.colors.textLight)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "FFD700").opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.top)
                
                // Background
                VStack(alignment: .leading, spacing: 16) {
                    Text("Background")
                        .font(.custom("Quicksand-SemiBold", size: 18))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(coach.background)
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                
                // Approach
                VStack(alignment: .leading, spacing: 16) {
                    Text("Approach")
                        .font(.custom("Quicksand-SemiBold", size: 18))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(coach.approach)
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                
                // Specialties
                VStack(alignment: .leading, spacing: 16) {
                    Text("Specialties")
                        .font(.custom("Quicksand-SemiBold", size: 18))
                        .foregroundColor(themeManager.colors.text)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(coach.specialties, id: \.self) { specialty in
                            Text(specialty)
                                .font(.custom("Nunito-SemiBold", size: 14))
                                .foregroundColor(themeManager.colors.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(themeManager.colors.primary.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Quote
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quote")
                        .font(.custom("Quicksand-SemiBold", size: 18))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(coach.quote)
                        .font(.custom("Nunito-Italic", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                        .lineSpacing(4)
                        .padding(16)
                        .background(themeManager.colors.surface)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Select Coach Button
                Button(action: {
                    Task {
                        await selectCoach()
                    }
                }) {
                    HStack {
                        if isUpdatingCoach {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Select Coach")
                                .font(.custom("Quicksand-Bold", size: 18))
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeManager.colors.primary,
                                themeManager.colors.primaryDark
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: themeManager.colors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 32)
                .disabled(isUpdatingCoach)
            }
        }
        .background(themeManager.colors.background)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func selectCoach() async {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "You must be signed in to select a coach"
            showError = true
            return
        }
        
        isUpdatingCoach = true
        
        do {
            let db = Firestore.firestore()
            try await db.collection("users").document(userId).updateData([
                "coachId": coach.id,
                "coachAssignedAt": FieldValue.serverTimestamp()
            ])
            
            // Dismiss both the details view and the switching modal
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isUpdatingCoach = false
    }
}

#Preview {
    CoachSwitchingModal(viewModel: CoachHomeViewModel())
        .environmentObject(ThemeManager())
} 