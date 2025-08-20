import SwiftUI

struct CourseViewerScreen: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentPageIndex = 0
    @State private var showPaywall = false
    @StateObject private var favoritesService = CourseFavoritesService.shared
    
    private var courseContent: CourseContent? {
        getCourseContent(for: course.id)
    }
    
    private var currentPage: CoursePage? {
        guard let content = courseContent else { return nil }
        guard currentPageIndex < content.pages.count else { return nil }
        return content.pages[currentPageIndex]
    }
    
    private var isLastPage: Bool {
        guard let content = courseContent else { return false }
        return currentPageIndex == content.pages.count - 1
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                themeManager.colors.background
                    .ignoresSafeArea()
                
                mainContent
            }
            .navigationTitle(courseContent?.title ?? "Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(themeManager.selectedTheme == .dark || themeManager.selectedTheme == .midnightGold ? .dark : .light, for: .navigationBar)
            .toolbarBackground(themeManager.colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeManager.colors.text.opacity(0.7))
                            .font(.system(size: 24))
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PremiumModalScreen()
        }
        .onAppear {
            // Reset to first page when course changes
            currentPageIndex = 0
        }
        .id(course.id) // Force view recreation when course changes
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if let content = courseContent {
            if let page = currentPage {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Progress indicator
                            ProgressView(value: Double(currentPageIndex + 1), total: Double(content.pages.count))
                                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.colors.primary))
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            // Page content
                            VStack(spacing: 20) {
                                // Course icon (first page only)
                                if currentPageIndex == 0 {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [themeManager.colors.primary.opacity(0.2), themeManager.colors.primary.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: content.icon)
                                            .font(.system(size: 36, weight: .medium))
                                            .foregroundColor(themeManager.colors.primary)
                                    }
                                    .padding(.top, 20)
                                }
                                
                                // Page title
                                Text(page.title)
                                    .font(.system(size: 24, weight: .semibold, design: .default))
                                    .foregroundColor(themeManager.colors.text)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                // Visual element
                                if let visualElement = page.visualElement {
                                    VisualElementView(element: visualElement)
                                        .padding(.horizontal)
                                }
                                
                                // Main content
                                Text(page.content)
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(themeManager.colors.text)
                                    .lineSpacing(4)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                                
                                // Tips section
                                if let tips = page.tips {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Key Takeaways")
                                            .font(.system(size: 18, weight: .semibold, design: .default))
                                            .foregroundColor(themeManager.colors.text)
                                        
                                        ForEach(tips, id: \.self) { tip in
                                            HStack(alignment: .top, spacing: 12) {
                                                Image(systemName: "lightbulb.fill")
                                                    .foregroundColor(themeManager.colors.primary)
                                                    .font(.system(size: 16))
                                                
                                                Text(tip)
                                                    .font(.system(size: 15, weight: .regular, design: .default))
                                                    .foregroundColor(themeManager.colors.text)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(themeManager.colors.surface)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                
                                // Examples section
                                if let examples = page.examples {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Examples")
                                            .font(.system(size: 18, weight: .semibold, design: .default))
                                            .foregroundColor(themeManager.colors.text)
                                        
                                        ForEach(examples, id: \.self) { example in
                                            HStack(alignment: .top, spacing: 12) {
                                                Image(systemName: "circle.fill")
                                                    .foregroundColor(themeManager.colors.primary)
                                                    .font(.system(size: 8))
                                                    .padding(.top, 6)
                                                
                                                Text(example)
                                                    .font(.system(size: 15, weight: .regular, design: .default))
                                                    .foregroundColor(themeManager.colors.text)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(themeManager.colors.surface)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                
                                // Last page feedback
                                if page.isLastPage {
                                    VStack(spacing: 20) {
                                        // Course icon
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [themeManager.colors.primary.opacity(0.2), themeManager.colors.primary.opacity(0.1)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 80, height: 80)
                                            
                                            Image(systemName: content.icon)
                                                .font(.system(size: 36, weight: .medium))
                                                .foregroundColor(themeManager.colors.primary)
                                        }
                                        
                                        Text("Was this helpful?")
                                            .font(.system(size: 20, weight: .semibold, design: .default))
                                            .foregroundColor(themeManager.colors.text)
                                        
                                        HStack(spacing: 16) {
                                            Button(action: {
                                                dismiss()
                                            }) {
                                                Text("Yes")
                                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(themeManager.colors.primary)
                                                    .cornerRadius(8)
                                            }
                                            
                                            Button(action: {
                                                dismiss()
                                            }) {
                                                Text("No")
                                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                                    .foregroundColor(themeManager.colors.text)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(themeManager.colors.surface)
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .padding(.horizontal)
                                        
                                        // Favorite button
                                        Button(action: {
                                            favoritesService.toggleFavorite(courseId: course.id)
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: favoritesService.isFavorite(courseId: course.id) ? "heart.fill" : "heart")
                                                    .foregroundColor(favoritesService.isFavorite(courseId: course.id) ? .red : themeManager.colors.textLight)
                                                    .font(.system(size: 18))
                                                
                                                Text(favoritesService.isFavorite(courseId: course.id) ? "Favorited" : "Add to Favorites")
                                                    .font(.system(size: 16, weight: .medium, design: .default))
                                                    .foregroundColor(themeManager.colors.text)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(themeManager.colors.surface)
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.vertical, 20)
                                }
                                
                                Spacer(minLength: 100)
                            }
                        }
                    }
                    
                    // Navigation buttons
                    VStack {
                        Spacer()
                        
                        HStack {
                            // Previous button
                            if currentPageIndex > 0 {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPageIndex -= 1
                                    }
                                }) {
                                    Text("Previous")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(themeManager.colors.textLight)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 20)
                                        .background(themeManager.colors.surface)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Spacer()
                            
                            // Next/Complete button
                            if !isLastPage {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPageIndex += 1
                                    }
                                }) {
                                    Text("Next")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 24)
                                        .background(themeManager.colors.primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .background(
                            LinearGradient(
                                colors: [themeManager.colors.background.opacity(0), themeManager.colors.background],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    }
                } else {
                    // Course not found or loading state
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.colors.textLight)
                        
                        Text("Course Coming Soon")
                            .font(.system(size: 24, weight: .semibold, design: .default))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text("This course is being prepared and will be available soon. Check back later!")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.textLight)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { dismiss() }) {
                            Text("Go Back")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(themeManager.colors.primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
}

struct VisualElementView: View {
    let element: VisualElement
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        switch element {
        case .icon(let iconName, let color):
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: iconName)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(color)
            }
            
        case .image(let imageName):
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .cornerRadius(12)
            
        case .progressBar(let progress, let color):
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(themeManager.colors.textLight)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(themeManager.colors.textLight)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
            }
            .padding()
            .background(themeManager.colors.surface)
            .cornerRadius(12)
            
        case .quote(let text, let author):
            VStack(spacing: 12) {
                Text("\"\(text)\"")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(themeManager.colors.text)
                    .italic()
                    .multilineTextAlignment(.center)
                
                Text("— \(author)")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(themeManager.colors.textLight)
            }
            .padding()
            .background(themeManager.colors.surface)
            .cornerRadius(12)
            
        case .stepList(let steps):
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(themeManager.colors.primary)
                                .frame(width: 24, height: 24)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                        
                        Text(step)
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(themeManager.colors.text)
                    }
                }
            }
            .padding()
            .background(themeManager.colors.surface)
            .cornerRadius(12)
            
        case .comparison(let before, let after):
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Before")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.red)
                    
                    Text(before)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(themeManager.colors.text)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("After")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.green)
                    
                    Text(after)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(themeManager.colors.text)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
        case .tipBox(let tip, let color):
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(color)
                    .font(.system(size: 20))
                
                Text(tip)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundColor(themeManager.colors.text)
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    CourseViewerScreen(course: Course(id: "understanding_stress", title: "Understanding Stress", duration: "3 min", icon: "brain.head.profile"))
        .environmentObject(ThemeManager())
} 