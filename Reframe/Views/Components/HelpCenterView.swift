import SwiftUI

struct HelpCenterView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: HelpCategory = .gettingStarted
    
    enum HelpCategory: String, CaseIterable {
        case gettingStarted = "Getting Started"
        case reframe = "Reframe"
        case reflect = "Reflect"
        case coach = "Coach"
        case journal = "Journal"
        case features = "Features"
        case premium = "Premium"
        case troubleshooting = "Troubleshooting"
        
        var icon: String {
            switch self {
            case .gettingStarted: return "play.circle.fill"
            case .reframe: return "arrow.triangle.2.circlepath"
            case .reflect: return "brain.head.profile"
            case .coach: return "bubble.left.and.bubble.right.fill"
            case .journal: return "book.fill"
            case .features: return "star.fill"
            case .premium: return "crown.fill"
            case .troubleshooting: return "wrench.and.screwdriver.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .gettingStarted: return .blue
            case .reframe: return .orange
            case .reflect: return .purple
            case .coach: return .green
            case .journal: return .indigo
            case .features: return .pink
            case .premium: return .yellow
            case .troubleshooting: return .red
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(themeManager.colors.primary)
                    
                    Text("Help Center")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("Everything you need to know about Reframe")
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Category Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(HelpCategory.allCases, id: \.self) { category in
                            CategoryTab(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedCategory {
                        case .gettingStarted:
                            GettingStartedContent()
                        case .reframe:
                            ReframeContent()
                        case .reflect:
                            ReflectContent()
                        case .coach:
                            CoachContent()
                        case .journal:
                            JournalContent()
                        case .features:
                            FeaturesContent()
                        case .premium:
                            PremiumContent()
                        case .troubleshooting:
                            TroubleshootingContent()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .background(themeManager.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Nunito-Medium", size: 16))
                    .foregroundColor(themeManager.colors.primary)
                }
            }
        }
    }
}

// MARK: - Category Tab
struct CategoryTab: View {
    let category: HelpCenterView.HelpCategory
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(category.rawValue)
                    .font(.custom("Nunito-Medium", size: 14))
            }
            .foregroundColor(isSelected ? .white : themeManager.colors.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? category.color : themeManager.colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? category.color : themeManager.colors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Content Views
struct GettingStartedContent: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(
                title: "Welcome to Reframe",
                icon: "heart.fill",
                color: .red
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reframe is your AI-powered mental wellness companion designed to help you transform negative thoughts into positive perspectives.")
                    
                    Text("The app combines cognitive behavioral therapy techniques with AI to help you:")
                    
                    BulletPoint("Reframe negative thoughts")
                    BulletPoint("Reflect on positive moments")
                    BulletPoint("Connect with personalized AI coaches")
                    BulletPoint("Build healthy journaling habits")
                    BulletPoint("Track your emotional growth")
                }
            }
            
            HelpSection(
                title: "Your First Steps",
                icon: "figure.walk",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. **Complete Onboarding**: Share your emotional needs to get matched with a personalized coach")
                    Text("2. **Try Reframing**: Share a negative thought and see how AI can help you see it differently")
                    Text("3. **Explore Features**: Check out the journal, coach, and calming tools")
                    Text("4. **Build Habits**: Use the app regularly to see the most benefits")
                }
            }
            
            HelpSection(
                title: "Daily Limits",
                icon: "clock.fill",
                color: .orange
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Free users get 2 reframes per day to encourage mindful usage. Premium users get unlimited reframes.")
                    
                    Text("**Why limits?** We believe in quality over quantity. Taking time to reflect on each reframe helps you get more value from the experience.")
                }
            }
        }
    }
}

struct ReframeContent: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(
                title: "What is Reframing?",
                icon: "arrow.triangle.2.circlepath",
                color: .orange
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reframing is a cognitive behavioral therapy technique that helps you see situations from a different, more positive perspective.")
                    
                    Text("Instead of getting stuck in negative thinking patterns, reframing helps you:")
                    
                    BulletPoint("Challenge automatic negative thoughts")
                    BulletPoint("Find alternative perspectives")
                    BulletPoint("Reduce anxiety and stress")
                    BulletPoint("Build emotional resilience")
                }
            }
            
            HelpSection(
                title: "How to Use Reframe",
                icon: "pencil.circle.fill",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. **Select Reframe Mode**: Tap the 'Reframe' button on the home screen")
                    Text("2. **Share Your Thought**: Write down a negative thought or situation you're struggling with")
                    Text("3. **Get Your Reframe**: AI will provide a positive, alternative perspective")
                    Text("4. **Save & Reflect**: Save helpful reframes to your journal for later reference")
                }
            }
            
            HelpSection(
                title: "Types of Reframes",
                icon: "list.bullet.circle.fill",
                color: .green
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Cognitive Reframe**: Challenges negative thinking patterns")
                    Text("**Perspective Shift**: Offers a different viewpoint on the situation")
                    Text("**Growth Mindset**: Focuses on learning and improvement opportunities")
                    Text("**Self-Compassion**: Encourages kinder self-talk")
                    Text("**Action-Oriented**: Suggests practical steps forward")
                }
            }
            
            HelpSection(
                title: "Tips for Better Results",
                icon: "lightbulb.fill",
                color: .yellow
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("• **Be Specific**: Include details about your situation")
                    Text("• **Be Honest**: Share your genuine feelings and thoughts")
                    Text("• **Stay Open**: Be willing to consider new perspectives")
                    Text("• **Practice Regularly**: Use reframing daily for best results")
                    Text("• **Save Helpful Ones**: Keep reframes that resonate with you")
                }
            }
        }
    }
}

struct ReflectContent: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(
                title: "What is Reflection?",
                icon: "brain.head.profile",
                color: .purple
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reflection mode is designed for positive thoughts, achievements, and moments of gratitude. It helps you celebrate and deepen your understanding of positive experiences.")
                    
                    Text("Unlike reframing (which transforms negative thoughts), reflection helps you:")
                    
                    BulletPoint("Celebrate your wins and achievements")
                    BulletPoint("Deepen positive experiences")
                    BulletPoint("Build gratitude and appreciation")
                    BulletPoint("Strengthen positive thinking patterns")
                    BulletPoint("Create lasting positive memories")
                }
            }
            
            HelpSection(
                title: "When to Use Reflect",
                icon: "calendar.circle.fill",
                color: .green
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Perfect for moments like:**")
                    Text("• A successful presentation at work")
                    Text("• A kind gesture you received")
                    Text("• A personal achievement or milestone")
                    Text("• A beautiful moment in nature")
                    Text("• A meaningful conversation")
                    Text("• Progress toward a goal")
                }
            }
            
            HelpSection(
                title: "How Reflection Works",
                icon: "arrow.up.circle.fill",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. **Select Reflect Mode**: Tap the 'Reflect' button on the home screen")
                    Text("2. **Share Your Moment**: Describe the positive experience or thought")
                    Text("3. **Get Insights**: AI will help you explore and appreciate the moment deeper")
                    Text("4. **Save to Journal**: Keep your reflections for future inspiration")
                }
            }
            
            HelpSection(
                title: "Benefits of Reflection",
                icon: "heart.circle.fill",
                color: .pink
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Research shows that regular reflection can:**")
                    Text("• Increase happiness and life satisfaction")
                    Text("• Improve emotional well-being")
                    Text("• Strengthen positive neural pathways")
                    Text("• Build resilience during difficult times")
                    Text("• Enhance self-awareness and growth")
                }
            }
        }
    }
}

struct CoachContent: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(
                title: "Your AI Coach",
                icon: "bubble.left.and.bubble.right.fill",
                color: .green
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your personalized AI coach is designed to provide emotional support, guidance, and practical advice tailored to your specific needs.")
                    
                    Text("**How it works:**")
                    Text("• Share what's on your mind")
                    Text("• Get thoughtful, empathetic responses")
                    Text("• Receive practical strategies and insights")
                    Text("• Build a supportive relationship over time")
                }
            }
            
            HelpSection(
                title: "Coach Specialties",
                icon: "star.circle.fill",
                color: .yellow
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Available Coaches:**")
                    Text("🍃 **Theo**: Anxiety, perfectionism, stress management")
                    Text("🌷 **Maya**: Self-worth, confidence, personal growth")
                    Text("🧭 **Jordan**: Relationships, life transitions, boundaries")
                    Text("🧠 **Alex**: Overthinking, problem-solving, mental clarity")
                    Text("🦉 **Rhea**: Deep emotional processing, grief, identity (Premium)")
                    Text("🔥 **Leo**: Motivation, procrastination, goal achievement (Premium)")
                    Text("🌌 **Nova**: Life purpose, existential questions, meaning (Premium)")
                }
            }
            
            HelpSection(
                title: "How to Use Your Coach",
                icon: "message.circle.fill",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. **Navigate to Coach Tab**: Tap the coach icon in the bottom navigation")
                    Text("2. **Start a Conversation**: Tap the message button to begin")
                    Text("3. **Share Your Feelings**: Be open about what you're experiencing")
                    Text("4. **Get Support**: Receive personalized guidance and strategies")
                    Text("5. **Review History**: Access past conversations in your coach history")
                }
            }
            
            HelpSection(
                title: "Coach Sessions",
                icon: "clock.circle.fill",
                color: .orange
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Free Users**: 3 coach sessions per week")
                    Text("**Premium Users**: 25 coach sessions per day")
                    
                    Text("**What counts as a session:**")
                    Text("• Each message you send to your coach")
                    Text("• Each response you receive from your coach")
                    
                    Text("**Tips for meaningful sessions:**")
                    Text("• Be specific about your situation")
                    Text("• Ask follow-up questions")
                    Text("• Share how strategies are working")
                    Text("• Be patient with the conversation flow")
                }
            }
        }
    }
}

struct JournalContent: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(
                title: "Your Digital Journal",
                icon: "book.fill",
                color: .indigo
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your journal is a private space to capture your thoughts, reframes, coach conversations, and guided reflections. It's your personal record of growth and self-discovery.")
                    
                    Text("**What gets saved automatically:**")
                    Text("• All your reframes and reflections")
                    Text("• Coach conversations")
                    Text("• Guided journal entries")
                    Text("• Daily wisdom practices")
                }
            }
            
            HelpSection(
                title: "Journal Entry Types",
                icon: "list.bullet.circle.fill",
                color: .purple
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Reframe Entries**: Your negative thoughts and their positive reframes")
                    Text("**Reflection Entries**: Positive moments and achievements")
                    Text("**Coach Entries**: Conversations with your AI coach")
                    Text("**Guided Entries**: Responses to journal prompts")
                    
                    Text("Each entry type is color-coded for easy identification:")
                    Text("🟠 Orange: Reframes")
                    Text("🟣 Purple: Reflections")
                    Text("🟢 Green: Coach conversations")
                    Text("🔵 Blue: Guided prompts")
                }
            }
            
            HelpSection(
                title: "Guided Journaling",
                icon: "text.bubble.fill",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Access guided journal prompts from the home screen's feature grid. These prompts help you explore different aspects of your life and emotions.")
                    
                    Text("**Prompt Categories:**")
                    Text("• **Self-Reflection**: Personal growth and self-awareness")
                    Text("• **Growth**: Learning and development")
                    Text("• **Relationships**: Connections with others")
                    Text("• **Well-being**: Health and happiness")
                    Text("• **Future**: Goals and aspirations")
                    Text("• **Gratitude**: Appreciation and thankfulness")
                }
            }
            
            HelpSection(
                title: "Journal Privacy",
                icon: "lock.shield.fill",
                color: .green
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Your journal is completely private:**")
                    Text("• Only you can see your entries")
                    Text("• Data is encrypted and secure")
                    Text("• No one else has access to your thoughts")
                    Text("• You can delete entries anytime")
                    
                    Text("**Data storage:**")
                    Text("• Entries are stored securely in the cloud")
                    Text("• Available across all your devices")
                    Text("• Backed up automatically")
                }
            }
        }
    }
}

struct FeaturesContent: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(
                title: "Milestones & Achievements",
                icon: "trophy.fill",
                color: .yellow
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Track your progress and celebrate your growth with milestones. These achievements recognize your consistent use of the app and personal development.")
                    
                    Text("**Types of milestones:**")
                    Text("• First reframe completed")
                    Text("• Streak achievements (3, 7, 30 days)")
                    Text("• Feature exploration (first coach session, guided journal)")
                    Text("• Consistency rewards")
                }
            }
            
            HelpSection(
                title: "Quick Calm Tools",
                icon: "heart.fill",
                color: .red
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Access immediate calming techniques when you need them most. These tools help you find peace in stressful moments.")
                    
                    Text("**Available tools:**")
                    Text("• **Box Breathing**: 4-4-4-4 pattern for focus")
                    Text("• **Calming Breath**: 4-7-8 pattern for relaxation")
                    Text("• **Deep Breathing**: 5-2-7 pattern for stress relief")
                    Text("• **5-4-3-2-1 Grounding**: Sensory awareness")
                    Text("• **Body Scan**: Progressive relaxation")
                    Text("• **Guided Meditation**: Mindfulness practice")
                }
            }
            
            HelpSection(
                title: "Daily Wisdom",
                icon: "leaf.fill",
                color: .green
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Get daily strategies and insights to support your mental wellness journey. Each day brings a new perspective or practice to try.")
                    
                    Text("**What you'll find:**")
                    Text("• Mindfulness techniques")
                    Text("• Self-care strategies")
                    Text("• Growth mindset practices")
                    Text("• Stress management tips")
                    Text("• Relationship advice")
                    Text("• Personal development insights")
                }
            }
            
            HelpSection(
                title: "Streak Tracking",
                icon: "flame.fill",
                color: .orange
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Build momentum with streak tracking. See how many consecutive days you've used the app and celebrate your consistency.")
                    
                    Text("**How streaks work:**")
                    Text("• Complete at least one reframe or reflection per day")
                    Text("• Streaks reset if you miss a day")
                    Text("• Longer streaks unlock special achievements")
                    Text("• Visual progress indicators motivate continued use")
                }
            }
            // PLANNED FEATURES & ROADMAP
            HelpSection(
                title: "Planned Features & Roadmap",
                icon: "calendar.badge.plus",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("We're always working to make Reframe better! Here's a sneak peek at what's coming soon:")
                    Text("• **Insights & Analytics:** Track your mood, progress, and emotional trends over time with beautiful charts and personalized insights.")
                    Text("• More guided journaling prompts and categories.")
                    Text("• Deeper coach personalization and new AI coach personalities.")
                    Text("• More calming tools and meditations.")
                    Text("• And much more!")
                }
            }
        }
    }
}

struct PremiumContent: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(
                title: "Premium Benefits",
                icon: "crown.fill",
                color: .yellow
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Upgrade to Premium to unlock the full potential of Reframe and accelerate your mental wellness journey.")
                    
                    Text("**What's included:**")
                    Text("♾️ **Unlimited Reframes**: No daily limits")
                    Text("🧠 **All Coaches**: Access to premium coaches (Rhea, Leo, Nova)")
                    Text("💬 **25 Coach Sessions**: More daily conversations")
                }
            }
            
            HelpSection(
                title: "Premium Coaches",
                icon: "star.circle.fill",
                color: .purple
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**🦉 Rhea**: Deep emotional processing, grief, identity exploration")
                    Text("**🔥 Leo**: Motivation, overcoming procrastination, goal achievement")
                    Text("**🌌 Nova**: Life purpose, existential questions, meaning creation")
                    
                    Text("These coaches specialize in deeper, more complex emotional work and life challenges.")
                }
            }
            
            HelpSection(
                title: "Upgrade Options",
                icon: "creditcard.fill",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Monthly Plan**: $9.99/month")
                    Text("**Annual Plan**: $79.99/year (33% savings)")
                    
                    Text("**Cancel Anytime**: No commitment required")
                }
            }
            
            HelpSection(
                title: "Premium Features Explained",
                icon: "info.circle.fill",
                color: .green
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Unlimited Reframes**: Create as many reframes as you need without worrying about daily limits")
                    Text("**Coach Switching**: Change coaches anytime to match your current needs")
                    Text("**Extended Sessions**: Have longer, more in-depth conversations with your coach")
                }
            }
        }
    }
}

struct TroubleshootingContent: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSection(
                title: "Common Issues",
                icon: "exclamationmark.triangle.fill",
                color: .red
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**App won't open**")
                    Text("• Restart your device")
                    Text("• Check for app updates")
                    Text("• Reinstall the app if needed")
                    
                    Text("**Reframes not working**")
                    Text("• Check your internet connection")
                    Text("• Ensure you haven't reached your daily limit")
                    Text("• Try a different thought or situation")
                    
                    Text("**Coach not responding**")
                    Text("• Check your session limit")
                    Text("• Try a clearer, more specific message")
                    Text("• Restart the conversation")
                }
            }
            
            HelpSection(
                title: "Account Issues",
                icon: "person.circle.fill",
                color: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Can't sign in**")
                    Text("• Check your email and password")
                    Text("• Use 'Forgot Password' if needed")
                    Text("• Try signing in with Google/Apple")
                    
                    Text("**Data not syncing**")
                    Text("• Check your internet connection")
                    Text("• Sign out and sign back in")
                    Text("• Contact support if issues persist")
                    
                    Text("**Premium not working**")
                    Text("• Check your subscription status")
                    Text("• Restore purchases if needed")
                    Text("• Contact support for billing issues")
                }
            }
            
            HelpSection(
                title: "Performance Tips",
                icon: "speedometer",
                color: .green
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**For better performance:**")
                    Text("• Keep the app updated")
                    Text("• Close other apps when using Reframe")
                    Text("• Restart your device regularly")
                    Text("• Clear app cache if needed")
                    Text("• Use stable internet connection")
                }
            }
            
            HelpSection(
                title: "Getting Help",
                icon: "questionmark.circle.fill",
                color: .orange
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("**Still need help?**")
                    Text("• Use the 'Send Feedback' feature in Settings")
                    Text("• Include specific details about your issue")
                    Text("• Mention your device and iOS version")
                    Text("• We'll respond within 24 hours")
                }
            }
        }
    }
}

// MARK: - Helper Components
struct HelpSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    @EnvironmentObject var themeManager: ThemeManager
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                Text(title)
                    .font(.custom("Quicksand-SemiBold", size: 20))
                    .foregroundColor(themeManager.colors.text)
            }
            
            content
                .font(.custom("Nunito-Regular", size: 16))
                .foregroundColor(themeManager.colors.text)
        }
        .padding(20)
        .background(themeManager.colors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct BulletPoint: View {
    let text: String
    @EnvironmentObject var themeManager: ThemeManager
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.custom("Nunito-Regular", size: 16))
                .foregroundColor(themeManager.colors.primary)
            
            Text(text)
                .font(.custom("Nunito-Regular", size: 16))
                .foregroundColor(themeManager.colors.text)
        }
    }
}

#Preview {
    HelpCenterView()
        .environmentObject(ThemeManager())
} 