import SwiftUI

// MARK: - Course Content Models

struct CoursePage: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let visualElement: VisualElement?
    let tips: [String]?
    let examples: [String]?
    let isLastPage: Bool
    
    init(title: String, content: String, visualElement: VisualElement? = nil, tips: [String]? = nil, examples: [String]? = nil, isLastPage: Bool = false) {
        self.title = title
        self.content = content
        self.visualElement = visualElement
        self.tips = tips
        self.examples = examples
        self.isLastPage = isLastPage
    }
}

enum VisualElement {
    case icon(String, Color)
    case image(String)
    case progressBar(Double, Color)
    case quote(String, String) // text, author
    case stepList([String])
    case comparison(String, String) // before, after
    case tipBox(String, Color)
}

struct CourseContent: Identifiable {
    let id = UUID()
    let courseId: String
    let title: String
    let icon: String
    let duration: String
    let pages: [CoursePage]
    let category: String
    let isPremium: Bool
    var isFavorite: Bool = false
}

// MARK: - Course Content Data

let courseContentData: [CourseContent] = [
    // Understanding Stress Course
    CourseContent(
        courseId: "understanding_stress",
        title: "Understanding Stress",
        icon: "brain.head.profile",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "What is Stress?",
                content: "Stress is your body's natural response to challenges and demands. Think of it as your internal alarm system that helps you stay alert and focused when you need to be. When you encounter a difficult situation, your body releases hormones like cortisol and adrenaline, preparing you to either face the challenge or step back safely.\n\nThis response evolved to help our ancestors survive dangerous situations. Today, while we're not usually running from predators, our bodies still react the same way to modern stressors like work deadlines, relationship issues, or financial concerns.",
                visualElement: .icon("brain.head.profile", .orange),
                tips: [
                    "Stress is normal and can be helpful in small doses",
                    "Your body's stress response is designed to protect you",
                    "Everyone experiences stress differently"
                ]
            ),
            CoursePage(
                title: "The Stress Response",
                content: "When you feel stressed, your body goes through several changes. Your heart rate increases, your breathing becomes faster, and your muscles tense up. Your brain becomes more focused, and you might feel more alert or even anxious.\n\nThis is your body's way of preparing you for action. However, when stress becomes chronic or overwhelming, these same helpful responses can start to cause problems. You might have trouble sleeping, feel irritable, or experience physical symptoms like headaches or stomach issues.",
                visualElement: .stepList([
                    "Brain detects a threat",
                    "Hormones are released",
                    "Heart rate increases",
                    "Muscles tense up",
                    "Focus sharpens"
                ]),
                examples: [
                    "Feeling your heart race before a presentation",
                    "Getting butterflies in your stomach before a date",
                    "Feeling tense when stuck in traffic"
                ]
            ),
            CoursePage(
                title: "Managing Your Stress",
                content: "The good news is that you have more control over stress than you might think. Simple techniques like deep breathing, taking short breaks, and talking to someone you trust can make a big difference.\n\nStart by recognizing when you're feeling stressed. Notice the physical signs like tension in your shoulders or a racing heart. Then, try taking a few slow, deep breaths. Even just 30 seconds of focused breathing can help calm your nervous system and give you a moment to think more clearly.",
                visualElement: .tipBox("Remember: It's okay to take breaks and ask for help when you need it.", .green),
                tips: [
                    "Take deep breaths when you feel overwhelmed",
                    "Break big tasks into smaller, manageable steps",
                    "Talk to someone you trust about your feelings"
                ],
                isLastPage: true
            )
        ],
        category: "Understanding Stress",
        isPremium: false
    ),
    
    // Stress Response Course
    CourseContent(
        courseId: "stress_response",
        title: "Stress Response",
        icon: "heart.fill",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "Your Body's Alarm System",
                content: "Your stress response is like having a sophisticated alarm system built into your body. When your brain perceives a threat or challenge, it instantly sends signals throughout your body to prepare you for action. This happens so quickly that you might not even realize it's happening until you notice your heart pounding or your palms sweating.\n\nThe amazing thing is that this system works automatically to keep you safe. It's the same system that helped your ancestors survive dangerous situations, and it's still working hard to protect you today.",
                visualElement: .icon("heart.fill", .red)
            ),
            CoursePage(
                title: "Recognizing Your Signals",
                content: "Everyone's body sends different signals when they're stressed. Some people feel it in their chest with a racing heart, others feel it in their stomach with butterflies or nausea. You might notice your hands shaking, your voice getting higher, or your thoughts racing.\n\nLearning to recognize your personal stress signals is the first step in managing them effectively. Once you know what to look for, you can catch stress early and take steps to calm yourself before it becomes overwhelming.",
                visualElement: .comparison("Before: Unaware of stress signals", "After: Recognizing and responding to stress"),
                isLastPage: true
            )
        ],
        category: "Understanding Stress",
        isPremium: false
    ),
    
    // Healthy Boundaries Course
    CourseContent(
        courseId: "healthy_boundaries",
        title: "Healthy Boundaries",
        icon: "person.2.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "What Are Boundaries?",
                content: "Boundaries are like invisible lines that define what you're comfortable with and what you're not. They help you protect your time, energy, and emotional well-being while still being caring and connected to others. Think of boundaries as the rules you set for how others can treat you and how you'll respond when those rules are crossed.\n\nHealthy boundaries aren't about building walls or being selfish. They're about creating respectful, balanced relationships where everyone's needs are considered. When you have clear boundaries, you can be more present and giving in your relationships because you're not constantly feeling drained or resentful.",
                visualElement: .icon("person.2.fill", .pink),
                tips: [
                    "Boundaries protect your well-being",
                    "They help create balanced relationships",
                    "Setting boundaries is an act of self-care"
                ]
            ),
            CoursePage(
                title: "Types of Boundaries",
                content: "There are several types of boundaries you might need in different areas of your life. Physical boundaries involve your personal space and touch preferences. Emotional boundaries protect your feelings and mental energy. Time boundaries help you manage your schedule and commitments. Digital boundaries involve how you interact online and through technology.\n\nEach type of boundary serves a different purpose, but they all work together to create a healthy, balanced life. You might be strong in some areas and need to work on others, which is completely normal.",
                visualElement: .stepList([
                    "Physical boundaries",
                    "Emotional boundaries", 
                    "Time boundaries",
                    "Digital boundaries"
                ])
            ),
            CoursePage(
                title: "Setting Your Boundaries",
                content: "Setting boundaries starts with knowing what you need and what you're comfortable with. Take time to reflect on situations where you've felt drained, resentful, or uncomfortable. These are clues about where you might need stronger boundaries.\n\nWhen setting boundaries, be clear, direct, and kind. You don't need to apologize or explain extensively. A simple 'I need some time to think about this' or 'I'm not comfortable with that' is often enough. Remember, you have the right to set boundaries, and others have the right to respect them.",
                visualElement: .tipBox("Practice saying 'no' to small things first. It gets easier with time.", .blue)
            ),
            CoursePage(
                title: "Maintaining Your Boundaries",
                content: "Setting boundaries is just the first step. Maintaining them requires consistency and self-compassion. You might feel guilty at first, especially if you're used to putting others first. This guilt is normal and will fade as you see the positive impact boundaries have on your relationships and well-being.\n\nWhen someone crosses your boundaries, respond calmly and firmly. You don't need to be aggressive or defensive. Simply restate your boundary and, if necessary, explain the consequences of crossing it. Most people will respect your boundaries when they understand them clearly.",
                visualElement: .quote("Boundaries are a sign of self-respect and self-care.", "Unknown"),
                isLastPage: true
            )
        ],
        category: "Relationships",
        isPremium: false
    ),
    
    // Cognitive Distortions Course (Premium)
    CourseContent(
        courseId: "cognitive_distortions",
        title: "Cognitive Distortions",
        icon: "brain",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "What Are Cognitive Distortions?",
                content: "Cognitive distortions are patterns of thinking that can make you see reality inaccurately. They're like mental filters that can make situations seem worse than they actually are. These thinking patterns often develop as ways to protect ourselves, but they can end up causing unnecessary stress and negative emotions.\n\nThe good news is that once you learn to recognize these patterns, you can start to challenge them and develop more balanced ways of thinking. This doesn't mean you'll never have negative thoughts again, but you'll be better equipped to handle them when they arise.",
                visualElement: .icon("brain", .purple),
                tips: [
                    "Everyone experiences cognitive distortions",
                    "Recognizing them is the first step to change",
                    "Be patient with yourself as you learn"
                ]
            ),
            CoursePage(
                title: "Common Distortion Patterns",
                content: "There are several common types of cognitive distortions. All-or-nothing thinking sees things as completely good or bad, with no middle ground. Catastrophizing assumes the worst possible outcome will happen. Mind reading assumes you know what others are thinking. Emotional reasoning believes that because you feel something, it must be true.\n\nThese patterns can be sneaky because they often feel true in the moment. But when you step back and look at them more objectively, you can usually see that they're not giving you the full picture of what's really happening.",
                visualElement: .comparison("Distorted: 'I failed this test, so I'm a complete failure'", "Balanced: 'I didn't do well on this test, but I can learn from it'")
            ),
            CoursePage(
                title: "Challenging Distorted Thoughts",
                content: "Challenging cognitive distortions starts with awareness. When you notice yourself feeling particularly upset or anxious, pause and ask yourself what thoughts are running through your mind. Look for the common distortion patterns you've learned about.\n\nOnce you identify a distorted thought, try to find evidence that supports and contradicts it. Ask yourself questions like 'Is this thought 100% true?' or 'What would I tell a friend who had this thought?' This process helps you develop more balanced, realistic perspectives.",
                visualElement: .stepList([
                    "Notice your thoughts",
                    "Identify the distortion",
                    "Look for evidence",
                    "Consider alternatives",
                    "Practice balanced thinking"
                ])
            ),
            CoursePage(
                title: "Building Healthier Thinking",
                content: "Developing healthier thinking patterns takes time and practice. Start by being kind to yourself when you notice distorted thoughts. Remember that these patterns developed for a reason, and changing them is a process, not an overnight transformation.\n\nPractice regularly by checking in with your thoughts throughout the day. Celebrate small victories when you successfully challenge a distorted thought. Over time, you'll find that balanced thinking becomes more natural and automatic.",
                visualElement: .tipBox("Progress, not perfection. Every step toward balanced thinking is valuable.", .green),
                isLastPage: true
            )
        ],
        category: "Cognitive Patterns",
        isPremium: true
    ),
    
    // Present Moment Course (Premium)
    CourseContent(
        courseId: "present_moment",
        title: "Present Moment",
        icon: "clock.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "The Power of Now",
                content: "The present moment is the only place where life actually happens. While your mind might be busy thinking about the past or worrying about the future, your body is always here, right now. Learning to bring your attention to the present moment can help you feel more grounded, calm, and connected to your experience.\n\nMindfulness isn't about stopping your thoughts or achieving a perfect state of calm. It's about learning to observe your thoughts and feelings without getting caught up in them. This creates space between you and your thoughts, giving you more choice in how you respond to life's challenges.",
                visualElement: .icon("clock.fill", .green)
            ),
            CoursePage(
                title: "Anchoring in the Present",
                content: "Your breath is one of the most reliable anchors to the present moment. It's always happening, right here and now. When you focus on your breath, you're automatically bringing your attention to the present. You can also use other anchors like the feeling of your feet on the ground, the sounds around you, or the sensations in your body.\n\nStart with just a few moments of focused attention. You don't need to change your breathing or try to achieve any particular state. Simply notice the natural rhythm of your breath as it comes and goes.",
                visualElement: .stepList([
                    "Find a comfortable position",
                    "Notice your natural breath",
                    "When your mind wanders, gently return to your breath",
                    "Be patient and kind with yourself"
                ])
            ),
            CoursePage(
                title: "Bringing Mindfulness to Daily Life",
                content: "You can practice being present throughout your day, not just during formal meditation. Try bringing mindful attention to everyday activities like washing dishes, walking, or eating. Notice the sensations, sounds, and sights that you might normally miss.\n\nWhen you find yourself caught up in thoughts about the past or future, gently remind yourself to come back to the present moment. You can use a simple phrase like 'I'm here now' or just take a moment to notice your breath. Remember, every moment is a new opportunity to be present.",
                visualElement: .tipBox("Start with just one mindful moment each day. Small steps lead to big changes.", .blue),
                isLastPage: true
            )
        ],
        category: "Mindfulness",
        isPremium: true
    ),
    
    // Managing Anxiety Course (Free)
    CourseContent(
        courseId: "managing_anxiety",
        title: "Managing Anxiety",
        icon: "lungs.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Understanding Anxiety",
                content: "Anxiety is your body's way of preparing for potential threats, but sometimes it can become overwhelming and interfere with daily life. It's like having an overactive alarm system that goes off even when there's no real danger.\n\nAnxiety can manifest in many ways - racing thoughts, physical symptoms like rapid heartbeat or sweating, or feeling constantly on edge. The good news is that anxiety is treatable, and there are many effective strategies to manage it.",
                visualElement: .icon("lungs.fill", .blue),
                tips: [
                    "Anxiety is a normal human response",
                    "It can be managed with practice",
                    "You're not alone in feeling this way"
                ]
            ),
            CoursePage(
                title: "Grounding Techniques",
                content: "When anxiety feels overwhelming, grounding techniques can help bring you back to the present moment. These simple exercises help you focus on your immediate surroundings rather than getting lost in anxious thoughts.\n\nTry the 5-4-3-2-1 technique: Name 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste. This helps activate your senses and brings your attention to the here and now.",
                visualElement: .stepList([
                    "5 things you can see",
                    "4 things you can touch", 
                    "3 things you can hear",
                    "2 things you can smell",
                    "1 thing you can taste"
                ])
            ),
            CoursePage(
                title: "Building Your Toolkit",
                content: "Managing anxiety is about building a toolkit of strategies that work for you. Different techniques work for different people, so it's important to experiment and find what helps you feel calmer.\n\nRemember that managing anxiety is a skill that takes practice. Be patient with yourself and celebrate small victories. Over time, these techniques will become more natural and effective.",
                visualElement: .tipBox("Practice makes progress. Every time you use these techniques, you're strengthening your ability to manage anxiety.", .green),
                isLastPage: true
            )
        ],
        category: "Understanding Stress",
        isPremium: false
    ),
    
    // Calm Your Mind Course (Free)
    CourseContent(
        courseId: "calm_your_mind",
        title: "Calm Your Mind",
        icon: "leaf.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Finding Your Calm",
                content: "In our busy world, finding moments of calm can feel challenging. But calm isn't about eliminating all stress or achieving perfect peace - it's about creating small moments of stillness and connection with yourself.\n\nThink of calm as a skill you can develop, like learning to ride a bike. It takes practice, but over time it becomes easier and more natural.",
                visualElement: .icon("leaf.fill", .green)
            ),
            CoursePage(
                title: "Simple Calming Practices",
                content: "You don't need hours of meditation to find calm. Simple practices like taking three deep breaths, noticing the feeling of your feet on the ground, or spending a few minutes in nature can make a big difference.\n\nStart with just one minute of focused breathing each day. Find a comfortable position, close your eyes, and simply notice your breath as it comes and goes. When your mind wanders, gently bring it back to your breath.",
                visualElement: .stepList([
                    "Find a comfortable position",
                    "Take three deep breaths",
                    "Notice your surroundings",
                    "Be kind to yourself"
                ])
            ),
            CoursePage(
                title: "Creating Calm Spaces",
                content: "You can create calm in your environment too. This might mean decluttering a small space, adding a plant to your room, or creating a simple ritual like lighting a candle or playing soft music.\n\nRemember that calm is always available to you, even in the midst of chaos. It's like having a quiet room inside yourself that you can visit whenever you need it.",
                visualElement: .quote("Peace comes from within. Do not seek it without.", "Buddha"),
                isLastPage: true
            )
        ],
        category: "Understanding Stress",
        isPremium: false
    ),
    
    // Stress Relief Course (Free)
    CourseContent(
        courseId: "stress_relief",
        title: "Stress Relief",
        icon: "wind",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "Quick Stress Relief",
                content: "When stress hits, you need tools that work fast. These quick stress relief techniques can help you feel calmer in just a few minutes. The key is to interrupt the stress response and give your body a chance to reset.\n\nThink of these techniques as your emergency toolkit - simple, effective, and always available when you need them most.",
                visualElement: .icon("wind", .cyan),
                tips: [
                    "Quick techniques work in minutes",
                    "Practice makes them more effective",
                    "Use them before stress builds up"
                ]
            ),
            CoursePage(
                title: "Breathing for Relief",
                content: "Your breath is one of the most powerful tools for stress relief. When you're stressed, your breathing becomes shallow and rapid. By consciously slowing and deepening your breath, you can activate your body's natural relaxation response.\n\nTry the 4-7-8 technique: Inhale for 4 counts, hold for 7, exhale for 8. This simple pattern can help calm your nervous system and reduce stress hormones.",
                visualElement: .stepList([
                    "Inhale slowly for 4 counts",
                    "Hold your breath for 7 counts",
                    "Exhale slowly for 8 counts",
                    "Repeat 3-5 times"
                ]),
                isLastPage: true
            )
        ],
        category: "Understanding Stress",
        isPremium: false
    ),
    
    // Communication Skills Course (Free)
    CourseContent(
        courseId: "communication_skills",
        title: "Communication Skills",
        icon: "bubble.left.and.bubble.right.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "The Power of Communication",
                content: "Good communication is the foundation of healthy relationships. It's not just about what you say, but how you say it and how well you listen. When communication breaks down, misunderstandings and conflicts often follow.\n\nEffective communication involves both speaking clearly and listening actively. It's a skill that can be learned and improved with practice.",
                visualElement: .icon("bubble.left.and.bubble.right.fill", .blue),
                tips: [
                    "Communication is a two-way street",
                    "Listening is as important as speaking",
                    "Practice makes communication easier"
                ]
            ),
            CoursePage(
                title: "Active Listening",
                content: "Active listening means fully focusing on what the other person is saying, both with your ears and your body. It's about being present and showing that you care about what they're sharing.\n\nWhen you listen actively, you give the speaker your full attention, avoid interrupting, and reflect back what you've heard. This helps build trust and understanding in your relationships.",
                visualElement: .stepList([
                    "Give your full attention",
                    "Avoid interrupting",
                    "Show you're listening",
                    "Reflect back what you heard",
                    "Ask clarifying questions"
                ])
            ),
            CoursePage(
                title: "Speaking Clearly",
                content: "Clear communication starts with knowing what you want to say and saying it in a way that others can understand. Use 'I' statements to express your feelings and needs without blaming others.\n\nRemember that your tone, body language, and timing all contribute to how your message is received. Choose your words carefully and speak from the heart.",
                visualElement: .tipBox("Use 'I' statements to express your feelings without blaming others.", .green),
                isLastPage: true
            )
        ],
        category: "Relationships",
        isPremium: false
    ),
    
    // Conflict Resolution Course (Free)
    CourseContent(
        courseId: "conflict_resolution",
        title: "Conflict Resolution",
        icon: "hand.raised.fill",
        duration: "5 min",
        pages: [
            CoursePage(
                title: "Understanding Conflict",
                content: "Conflict is a natural part of relationships and doesn't have to be destructive. When handled well, conflict can actually strengthen relationships by helping people understand each other better and find solutions that work for everyone.\n\nThe key is to approach conflict as an opportunity for growth rather than a battle to be won. When both people feel heard and respected, conflict can lead to deeper understanding and stronger connections.",
                visualElement: .icon("hand.raised.fill", .orange),
                tips: [
                    "Conflict is normal and natural",
                    "It can strengthen relationships",
                    "Focus on understanding, not winning"
                ]
            ),
            CoursePage(
                title: "Staying Calm in Conflict",
                content: "When emotions run high, it's easy to say things you'll regret later. Learning to stay calm during conflict is crucial for effective resolution. Take deep breaths, pause before responding, and remember that you're working together to find a solution.\n\nIf you feel yourself getting too upset, it's okay to take a break. Say something like, 'I need a few minutes to think about this. Can we continue in 10 minutes?' This gives both people time to cool down and think more clearly.",
                visualElement: .stepList([
                    "Take deep breaths",
                    "Pause before responding",
                    "Focus on the issue, not the person",
                    "Take a break if needed",
                    "Come back with fresh perspective"
                ])
            ),
            CoursePage(
                title: "Finding Common Ground",
                content: "Most conflicts have areas where both people can agree. Start by identifying these points of agreement, then work together to find solutions that address everyone's needs. Look for win-win solutions rather than compromises that leave everyone unsatisfied.\n\nRemember that you're on the same team, working toward the same goal of a healthy relationship. When you approach conflict with this mindset, solutions become much easier to find.",
                visualElement: .comparison("Win-Lose: One person gets their way", "Win-Win: Both people's needs are met"),
                isLastPage: true
            )
        ],
        category: "Relationships",
        isPremium: false
    ),
    
    // Building Trust Course (Free)
    CourseContent(
        courseId: "building_trust",
        title: "Building Trust",
        icon: "heart.circle.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "The Foundation of Trust",
                content: "Trust is the foundation of all healthy relationships. It's built through consistent actions over time - keeping promises, being honest, and showing that you care about the other person's well-being.\n\nTrust isn't something that happens overnight. It's earned through small, consistent actions that show you're reliable, honest, and caring. Every interaction is an opportunity to build or strengthen trust.",
                visualElement: .icon("heart.circle.fill", .pink),
                tips: [
                    "Trust is built through consistent actions",
                    "Small actions add up over time",
                    "Be patient with the process"
                ]
            ),
            CoursePage(
                title: "Trust-Building Actions",
                content: "Building trust happens through everyday actions. Keep your promises, even the small ones. Be honest about your feelings and needs. Show up when you say you will. Listen when someone shares something important with you.\n\nRemember that trust can be fragile. One broken promise or lie can damage trust that took months or years to build. Treat trust as the precious gift that it is.",
                visualElement: .stepList([
                    "Keep your promises",
                    "Be honest and transparent",
                    "Show up consistently",
                    "Listen actively",
                    "Admit when you're wrong"
                ])
            ),
            CoursePage(
                title: "Rebuilding Trust",
                content: "If trust has been broken, it can be rebuilt, but it takes time and consistent effort. Start by acknowledging what happened and taking responsibility for your actions. Be patient and understand that rebuilding trust may take longer than building it the first time.\n\nFocus on being reliable and honest in all your interactions. Over time, your consistent actions will help restore the trust that was lost.",
                visualElement: .tipBox("Rebuilding trust takes time and consistent effort. Be patient with yourself and others.", .blue),
                isLastPage: true
            )
        ],
        category: "Relationships",
        isPremium: false
    ),
    
    // Emotional Support Course (Free)
    CourseContent(
        courseId: "emotional_support",
        title: "Emotional Support",
        icon: "person.fill.checkmark",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "Being There for Others",
                content: "Emotional support is about being present for someone when they're going through a difficult time. It's not about fixing their problems or giving advice - it's about listening, validating their feelings, and showing that you care.\n\nSometimes the best support is simply being there and letting someone know they're not alone. Your presence and willingness to listen can make a huge difference in someone's life.",
                visualElement: .icon("person.fill.checkmark", .green)
            ),
            CoursePage(
                title: "Supportive Responses",
                content: "When someone shares their struggles with you, respond with empathy and validation. Say things like 'That sounds really difficult' or 'I can see why you'd feel that way.' Avoid trying to solve their problems unless they specifically ask for advice.\n\nRemember that everyone's experience is different, and what works for you might not work for them. Focus on understanding their perspective rather than imposing your own solutions.",
                visualElement: .comparison("Unhelpful: 'Just get over it'", "Helpful: 'That sounds really difficult'"),
                isLastPage: true
            )
        ],
        category: "Relationships",
        isPremium: false
    ),
    
    // Sleep Hygiene Course (Free)
    CourseContent(
        courseId: "sleep_hygiene",
        title: "Sleep Hygiene",
        icon: "bed.double.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "The Importance of Sleep",
                content: "Quality sleep is essential for your physical and mental health. It helps your body repair itself, consolidates memories, and regulates your mood. When you don't get enough sleep, everything from your concentration to your emotional regulation suffers.\n\nGood sleep hygiene is about creating habits and an environment that promote restful sleep. Small changes can make a big difference in how well you sleep and how you feel during the day.",
                visualElement: .icon("bed.double.fill", .indigo),
                tips: [
                    "Sleep affects every aspect of health",
                    "Consistency is key",
                    "Small changes make big differences"
                ]
            ),
            CoursePage(
                title: "Creating a Sleep Routine",
                content: "Your body loves routine. Going to bed and waking up at the same time every day helps regulate your internal clock. Create a relaxing bedtime routine that signals to your body that it's time to wind down.\n\nThis might include reading a book, taking a warm bath, or practicing gentle stretching. Avoid screens for at least an hour before bed, as the blue light can interfere with your natural sleep hormones.",
                visualElement: .stepList([
                    "Set consistent bed and wake times",
                    "Create a relaxing bedtime routine",
                    "Avoid screens before bed",
                    "Keep your bedroom cool and dark",
                    "Limit caffeine and alcohol"
                ])
            ),
            CoursePage(
                title: "Optimizing Your Sleep Environment",
                content: "Your bedroom should be a sanctuary for sleep. Keep it cool, dark, and quiet. Invest in a comfortable mattress and pillows. Remove distractions like phones and TVs from your bedroom.\n\nIf you have trouble falling asleep, try relaxation techniques like deep breathing or progressive muscle relaxation. Remember that it's normal to take 15-20 minutes to fall asleep.",
                visualElement: .tipBox("Your bedroom should be a sanctuary for sleep - cool, dark, and free from distractions.", .purple),
                isLastPage: true
            )
        ],
        category: "Sleep & Rest",
        isPremium: false
    ),
    
    // Relaxation Techniques Course (Free)
    CourseContent(
        courseId: "relaxation_techniques",
        title: "Relaxation Techniques",
        icon: "moon.stars.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "The Art of Relaxation",
                content: "Relaxation is a skill that can be learned and practiced. In our busy world, many people have forgotten how to truly relax. These techniques help activate your body's natural relaxation response, reducing stress hormones and promoting calm.\n\nDifferent techniques work for different people, so it's worth trying several to find what works best for you. The key is regular practice - even just a few minutes each day can make a significant difference.",
                visualElement: .icon("moon.stars.fill", .purple),
                tips: [
                    "Relaxation is a learnable skill",
                    "Different techniques work for different people",
                    "Regular practice is key"
                ]
            ),
            CoursePage(
                title: "Progressive Muscle Relaxation",
                content: "Progressive muscle relaxation involves tensing and then releasing different muscle groups. This helps you become more aware of tension in your body and learn how to release it. Start with your toes and work your way up to your head.\n\nAs you practice, you'll become better at recognizing when you're holding tension and how to let it go. This technique is especially helpful for people who carry stress in their muscles.",
                visualElement: .stepList([
                    "Find a comfortable position",
                    "Tense your toes for 5 seconds",
                    "Release and feel the relaxation",
                    "Move up to your calves",
                    "Continue through your body"
                ])
            ),
            CoursePage(
                title: "Visualization and Guided Imagery",
                content: "Your mind is powerful, and visualization can help you relax deeply. Imagine yourself in a peaceful place - maybe a beach, forest, or mountain meadow. Use all your senses to make the image as vivid as possible.\n\nYou can also use guided imagery recordings or apps that walk you through relaxing scenarios. The key is to fully immerse yourself in the peaceful image and let your mind and body relax.",
                visualElement: .quote("Peace comes from within. Do not seek it without.", "Buddha"),
                isLastPage: true
            )
        ],
        category: "Sleep & Rest",
        isPremium: false
    ),
    
    // Mindful Sleep Course (Free)
    CourseContent(
        courseId: "mindful_sleep",
        title: "Mindful Sleep",
        icon: "zzz",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "Mindfulness for Better Sleep",
                content: "Mindfulness can be a powerful tool for improving sleep. When you're mindful, you're fully present in the moment, which can help quiet racing thoughts and calm your mind before bed.\n\nInstead of lying in bed worrying about tomorrow or replaying today's events, mindfulness helps you focus on the present moment - the feeling of your breath, the comfort of your bed, the peace of the night.",
                visualElement: .icon("zzz", .blue)
            ),
            CoursePage(
                title: "A Mindful Bedtime Routine",
                content: "Create a mindful bedtime routine that helps you transition from the busyness of the day to the peace of sleep. Take a few minutes to reflect on your day with gratitude, practice gentle stretching, or do a short meditation.\n\nWhen you get into bed, take a few mindful breaths and let go of the day's concerns. Remember that sleep is a natural process - you don't need to force it. Simply rest and let sleep come to you.",
                visualElement: .tipBox("Sleep is a natural process. Let it come to you rather than trying to force it.", .green),
                isLastPage: true
            )
        ],
        category: "Sleep & Rest",
        isPremium: false
    ),
    
    // All-or-Nothing Thinking Course (Premium)
    CourseContent(
        courseId: "all_or_nothing_thinking",
        title: "All-or-Nothing Thinking",
        icon: "arrow.left.and.right",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding All-or-Nothing Thinking",
                content: "All-or-nothing thinking, also called black-and-white thinking, is when you see things as completely good or bad, with no middle ground. It's like having only two options: perfect or failure. This thinking pattern can make you feel like you're either succeeding completely or failing completely.\n\nThis type of thinking often leads to unnecessary stress and disappointment because life rarely works in absolutes. Most situations have shades of gray and multiple possible outcomes.",
                visualElement: .icon("arrow.left.and.right", .purple),
                tips: [
                    "Life rarely works in absolutes",
                    "There's usually a middle ground",
                    "Progress is more important than perfection"
                ]
            ),
            CoursePage(
                title: "Recognizing the Pattern",
                content: "All-or-nothing thinking often shows up in words like 'always,' 'never,' 'perfect,' 'failure,' 'success,' or 'disaster.' When you catch yourself using these extreme words, it's a sign that you might be thinking in black and white.\n\nNotice when you're setting unrealistic standards for yourself or others. If you find yourself thinking 'I have to do this perfectly or it's not worth doing,' that's all-or-nothing thinking.",
                visualElement: .comparison("All-or-Nothing: 'I failed this test, so I'm a complete failure'", "Balanced: 'I didn't do well on this test, but I can learn from it'")
            ),
            CoursePage(
                title: "Finding the Middle Ground",
                content: "Instead of seeing only two extremes, try to identify the middle ground. Ask yourself: 'What's between perfect and failure?' or 'What would be good enough?'\n\nPractice using more flexible language. Instead of 'I always mess up,' try 'Sometimes I make mistakes, and that's okay.' Remember that most things in life exist on a spectrum, not as absolutes.",
                visualElement: .tipBox("Progress, not perfection. Every step forward is valuable, no matter how small.", .green),
                isLastPage: true
            )
        ],
        category: "Cognitive Patterns",
        isPremium: true
    ),
    
    // Challenging Your Thoughts Course (Premium)
    CourseContent(
        courseId: "challenging_thoughts",
        title: "Challenging Your Thoughts",
        icon: "lightbulb.fill",
        duration: "5 min",
        pages: [
            CoursePage(
                title: "The Power of Thought Challenging",
                content: "Your thoughts influence your emotions and actions more than you might realize. When you have negative or distorted thoughts, they can create unnecessary stress and anxiety. Learning to challenge these thoughts can help you develop more balanced, realistic perspectives.\n\nThought challenging isn't about forcing yourself to think positively. It's about examining your thoughts more objectively and considering alternative viewpoints.",
                visualElement: .icon("lightbulb.fill", .yellow),
                tips: [
                    "Thoughts are not facts",
                    "You can choose how to respond to your thoughts",
                    "Practice makes this skill easier"
                ]
            ),
            CoursePage(
                title: "The Thought Challenging Process",
                content: "When you notice a negative thought, pause and ask yourself these questions: Is this thought 100% true? What evidence supports this thought? What evidence contradicts it? What would I tell a friend who had this thought?\n\nThis process helps you step back from your thoughts and examine them more objectively. You might find that your initial thought was exaggerated or not entirely accurate.",
                visualElement: .stepList([
                    "Notice the negative thought",
                    "Ask if it's 100% true",
                    "Look for supporting evidence",
                    "Look for contradicting evidence",
                    "Consider alternative perspectives"
                ])
            ),
            CoursePage(
                title: "Developing Balanced Thoughts",
                content: "After challenging a thought, try to develop a more balanced perspective. This might mean acknowledging both the challenges and the positive aspects of a situation.\n\nRemember that developing balanced thinking is a skill that takes practice. Be patient with yourself and celebrate small improvements. Over time, this process will become more natural and automatic.",
                visualElement: .comparison("Unbalanced: 'This is a disaster'", "Balanced: 'This is challenging, but I can handle it'"),
                isLastPage: true
            )
        ],
        category: "Cognitive Patterns",
        isPremium: true
    ),
    
    // Mental Filters Course (Premium)
    CourseContent(
        courseId: "mental_filters",
        title: "Mental Filters",
        icon: "camera.filters",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding Mental Filters",
                content: "Mental filters are like wearing tinted glasses that only let you see certain colors. They cause you to focus on negative aspects while ignoring or minimizing positive ones. This can make you feel like everything is going wrong, even when good things are happening.\n\nMental filters often develop as a way to protect yourself from disappointment, but they can end up making you feel worse by distorting your view of reality.",
                visualElement: .icon("camera.filters", .purple),
                tips: [
                    "Mental filters distort your view of reality",
                    "They often focus on the negative",
                    "You can learn to see the full picture"
                ]
            ),
            CoursePage(
                title: "Recognizing Your Filters",
                content: "Mental filters often show up when you dismiss compliments, focus only on mistakes, or ignore positive feedback. You might find yourself saying things like 'That doesn't count' or 'It was just luck' when good things happen.\n\nNotice when you're only seeing part of a situation. Are you focusing on what went wrong while ignoring what went right? This is a sign that mental filters might be at work.",
                visualElement: .comparison("Filtered: 'I only got 8 out of 10 right'", "Balanced: 'I got 8 out of 10 right, that's pretty good'")
            ),
            CoursePage(
                title: "Removing the Filters",
                content: "To counteract mental filters, make a conscious effort to notice positive aspects of situations. When something good happens, take a moment to acknowledge it. When you receive a compliment, try to accept it graciously.\n\nPractice looking for evidence that contradicts your negative thoughts. Ask yourself: 'What positive aspects am I ignoring?' or 'What would someone else see in this situation?'",
                visualElement: .tipBox("Make a habit of noticing and acknowledging the positive aspects of your experiences.", .blue),
                isLastPage: true
            )
        ],
        category: "Cognitive Patterns",
        isPremium: true
    ),
    
    // Overgeneralization Course (Premium)
    CourseContent(
        courseId: "overgeneralization",
        title: "Overgeneralization",
        icon: "arrow.triangle.branch",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "What is Overgeneralization?",
                content: "Overgeneralization happens when you take one negative experience and apply it to everything. It's like saying 'I failed this test, so I'm bad at all tests' or 'This relationship didn't work, so all relationships will fail.'\n\nThis thinking pattern can make you feel hopeless and prevent you from trying new things. It's based on the false belief that one negative experience means all similar experiences will be negative.",
                visualElement: .icon("arrow.triangle.branch", .orange)
            ),
            CoursePage(
                title: "Breaking the Pattern",
                content: "To overcome overgeneralization, look for exceptions to your negative beliefs. Ask yourself: 'Is this really true in all cases?' or 'What evidence contradicts this belief?'\n\nPractice being more specific about your experiences. Instead of 'I always mess up,' try 'I made a mistake this time, but I've succeeded before.'",
                visualElement: .tipBox("One negative experience doesn't predict all future experiences. Look for exceptions to your negative beliefs.", .green),
                isLastPage: true
            )
        ],
        category: "Cognitive Patterns",
        isPremium: true
    ),
    
    // Body Awareness Course (Premium)
    CourseContent(
        courseId: "body_awareness",
        title: "Body Awareness",
        icon: "figure.mind.and.body",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Connecting with Your Body",
                content: "Your body is constantly sending you signals about how you're feeling, but many of us have learned to ignore these signals. Body awareness is about learning to listen to and understand what your body is telling you.\n\nWhen you're more aware of your body, you can better understand your emotions, recognize stress early, and take care of yourself more effectively. Your body often knows what you need before your mind does.",
                visualElement: .icon("figure.mind.and.body", .green),
                tips: [
                    "Your body sends important signals",
                    "Body awareness helps with emotional regulation",
                    "Practice listening to your body regularly"
                ]
            ),
            CoursePage(
                title: "Body Scanning Practice",
                content: "Body scanning is a simple technique to increase your body awareness. Start by finding a comfortable position and taking a few deep breaths. Then, slowly bring your attention to different parts of your body, from your toes to your head.\n\nNotice any sensations you feel - tension, warmth, tingling, or relaxation. Don't try to change anything, just observe. This practice helps you become more familiar with your body's signals.",
                visualElement: .stepList([
                    "Find a comfortable position",
                    "Take three deep breaths",
                    "Start with your toes",
                    "Move attention up your body",
                    "Notice sensations without judgment"
                ])
            ),
            CoursePage(
                title: "Understanding Body Signals",
                content: "Different emotions often show up in different parts of your body. Anxiety might feel like butterflies in your stomach or tension in your shoulders. Anger might feel like heat in your chest. Sadness might feel like heaviness in your heart area.\n\nLearning to recognize these signals can help you understand your emotions better and respond to them more skillfully. Your body is a valuable source of information about your emotional state.",
                visualElement: .tipBox("Your body is wise. Learning to listen to it can help you understand yourself better.", .blue),
                isLastPage: true
            )
        ],
        category: "Mindfulness",
        isPremium: true
    ),
    
    // Breathing Techniques Course (Premium)
    CourseContent(
        courseId: "breathing_techniques",
        title: "Breathing Techniques",
        icon: "wind",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "The Power of Breath",
                content: "Your breath is one of the most powerful tools you have for managing stress and emotions. It's always with you, and you can use it anywhere, anytime. Different breathing techniques can help you calm down, energize yourself, or find focus.\n\nWhen you're stressed, your breathing becomes shallow and rapid. By consciously changing your breathing pattern, you can activate your body's natural relaxation response.",
                visualElement: .icon("wind", .cyan)
            ),
            CoursePage(
                title: "Simple Breathing Techniques",
                content: "Try the 4-7-8 technique: Inhale for 4 counts, hold for 7, exhale for 8. This simple pattern can help calm your nervous system and reduce stress.\n\nOr try box breathing: Inhale for 4, hold for 4, exhale for 4, hold for 4. This creates a balanced, calming rhythm that can help you feel more centered.",
                visualElement: .stepList([
                    "Find a comfortable position",
                    "Place one hand on your belly",
                    "Inhale slowly through your nose",
                    "Feel your belly expand",
                    "Exhale slowly through your mouth"
                ]),
                isLastPage: true
            )
        ],
        category: "Mindfulness",
        isPremium: true
    ),
    
    // Mindful Walking Course (Premium)
    CourseContent(
        courseId: "mindful_walking",
        title: "Mindful Walking",
        icon: "figure.walk",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Walking with Awareness",
                content: "Mindful walking is a simple way to bring mindfulness into your daily life. Instead of walking on autopilot, you bring your full attention to the experience of walking. This can be done anywhere - in your home, at work, or outside.\n\nMindful walking helps you slow down, connect with your body, and become more present in the moment. It's a great way to take a mental break and reset your mind.",
                visualElement: .icon("figure.walk", .green)
            ),
            CoursePage(
                title: "How to Walk Mindfully",
                content: "Start by walking slowly and deliberately. Notice the feeling of your feet touching the ground, the movement of your legs, and the rhythm of your steps. Pay attention to your surroundings - the sights, sounds, and sensations around you.\n\nIf your mind wanders, gently bring it back to the experience of walking. You don't need to walk for long - even just a few minutes of mindful walking can make a difference.",
                visualElement: .stepList([
                    "Walk slowly and deliberately",
                    "Notice your feet touching the ground",
                    "Feel the movement of your body",
                    "Pay attention to your surroundings",
                    "Bring your mind back when it wanders"
                ])
            ),
            CoursePage(
                title: "Making Walking a Practice",
                content: "You can practice mindful walking during any walk - to your car, around your neighborhood, or even just around your home. Start with short periods and gradually increase the time.\n\nRemember that mindful walking isn't about achieving a particular state. It's about being present and aware of your experience, whatever that experience is.",
                visualElement: .tipBox("Every step can be an opportunity for mindfulness. Start with just a few mindful steps each day.", .blue),
                isLastPage: true
            )
        ],
        category: "Mindfulness",
        isPremium: true
    ),
    
    // Meditation Basics Course (Premium)
    CourseContent(
        courseId: "meditation_basics",
        title: "Meditation Basics",
        icon: "sparkles",
        duration: "5 min",
        pages: [
            CoursePage(
                title: "What is Meditation?",
                content: "Meditation is a practice of training your mind to focus and redirect your thoughts. It's not about stopping your thoughts or achieving a perfect state of calm. Instead, it's about learning to observe your thoughts without getting caught up in them.\n\nMeditation can help reduce stress, improve concentration, and increase self-awareness. It's a skill that anyone can learn, regardless of their background or beliefs.",
                visualElement: .icon("sparkles", .purple),
                tips: [
                    "Meditation is a skill that can be learned",
                    "It's not about stopping your thoughts",
                    "Regular practice is more important than perfect sessions"
                ]
            ),
            CoursePage(
                title: "Getting Started with Meditation",
                content: "Find a quiet, comfortable place where you won't be interrupted. Sit in a comfortable position with your back straight but relaxed. Close your eyes or keep them slightly open, whatever feels more comfortable.\n\nStart with just a few minutes each day. You can gradually increase the time as you become more comfortable with the practice. Remember that it's normal for your mind to wander - that's what minds do.",
                visualElement: .stepList([
                    "Find a quiet, comfortable place",
                    "Sit with your back straight",
                    "Close your eyes gently",
                    "Focus on your breath",
                    "When your mind wanders, gently return to your breath"
                ])
            ),
            CoursePage(
                title: "Common Challenges and Solutions",
                content: "Many people worry that they're not meditating 'correctly' because their mind wanders. This is completely normal and expected. The practice is not about having a perfectly quiet mind, but about noticing when your mind wanders and gently bringing it back.\n\nOther common challenges include feeling restless or bored. If this happens, try to observe these feelings without judgment. They will pass, just like all thoughts and feelings do.",
                visualElement: .comparison("Myth: 'I need a perfectly quiet mind'", "Reality: 'It's normal for the mind to wander'")
            ),
            CoursePage(
                title: "Building a Regular Practice",
                content: "Consistency is more important than duration when it comes to meditation. Even just 5 minutes a day can make a difference. Try to meditate at the same time each day to build a habit.\n\nBe patient with yourself and your practice. Meditation is a skill that develops over time. Celebrate small victories, like noticing when your mind wanders or completing a session, no matter how short.",
                visualElement: .tipBox("Start small and be consistent. Five minutes of daily meditation is better than an hour once a week.", .green),
                isLastPage: true
            )
        ],
        category: "Mindfulness",
        isPremium: true
    ),
    
    // Self-Compassion Course (Premium)
    CourseContent(
        courseId: "self_compassion",
        title: "Self-Compassion",
        icon: "heart.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "What is Self-Compassion?",
                content: "Self-compassion is treating yourself with the same kindness, care, and understanding that you would offer to a good friend. It involves recognizing that everyone makes mistakes, experiences difficulties, and has flaws - including you.\n\nSelf-compassion is not about feeling sorry for yourself or making excuses. It's about acknowledging your humanity and responding to your struggles with warmth and understanding rather than harsh self-criticism.",
                visualElement: .icon("heart.fill", .pink),
                tips: [
                    "Self-compassion is a skill you can develop",
                    "It's not about making excuses",
                    "Everyone deserves kindness, including you"
                ]
            ),
            CoursePage(
                title: "The Three Elements of Self-Compassion",
                content: "Self-compassion has three main components: self-kindness, common humanity, and mindfulness. Self-kindness means being warm and understanding toward yourself. Common humanity recognizes that suffering is part of the human experience. Mindfulness involves observing your thoughts and feelings without judgment.\n\nThese three elements work together to help you respond to difficulties with compassion rather than criticism.",
                visualElement: .stepList([
                    "Self-kindness: Be warm toward yourself",
                    "Common humanity: Recognize we all struggle",
                    "Mindfulness: Observe without judgment"
                ])
            ),
            CoursePage(
                title: "Practicing Self-Compassion",
                content: "When you're struggling, try talking to yourself as you would talk to a friend. Instead of 'I'm such an idiot,' try 'I made a mistake, but that's okay. Everyone makes mistakes.'\n\nPractice placing your hand on your heart or giving yourself a gentle hug when you're feeling down. These physical gestures can help activate your body's natural caregiving system.",
                visualElement: .comparison("Self-criticism: 'I'm such an idiot'", "Self-compassion: 'I made a mistake, but that's okay'")
            ),
            CoursePage(
                title: "Building Self-Compassion Habits",
                content: "Make self-compassion a daily practice. Start each day by setting an intention to be kind to yourself. When you notice self-critical thoughts, gently redirect them toward compassion.\n\nRemember that developing self-compassion takes time and practice. Be patient with yourself as you learn this new way of relating to yourself.",
                visualElement: .tipBox("Self-compassion is a practice, not a destination. Every moment of kindness toward yourself matters.", .green),
                isLastPage: true
            )
        ],
        category: "Personal Growth",
        isPremium: true
    ),
    
    // Goal Setting Course (Premium)
    CourseContent(
        courseId: "goal_setting",
        title: "Goal Setting",
        icon: "target",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "The Power of Clear Goals",
                content: "Setting clear, meaningful goals gives your life direction and purpose. Goals help you focus your energy and make decisions that align with what's important to you. They provide motivation and a sense of progress as you work toward them.\n\nGood goals are specific, achievable, and aligned with your values. They should challenge you enough to grow, but not so much that they feel overwhelming.",
                visualElement: .icon("target", .blue)
            ),
            CoursePage(
                title: "Setting SMART Goals",
                content: "SMART goals are Specific, Measurable, Achievable, Relevant, and Time-bound. Instead of 'I want to be healthier,' try 'I will walk for 30 minutes three times a week for the next month.'\n\nBreak big goals into smaller, manageable steps. This makes them less overwhelming and helps you track your progress more easily.",
                visualElement: .stepList([
                    "Specific: What exactly do you want to achieve?",
                    "Measurable: How will you know you've succeeded?",
                    "Achievable: Is this realistic for you?",
                    "Relevant: Does this align with your values?",
                    "Time-bound: When will you complete this?"
                ])
            ),
            CoursePage(
                title: "Staying Motivated",
                content: "Keep your goals visible and review them regularly. Celebrate small wins along the way. If you encounter obstacles, adjust your approach rather than giving up.\n\nRemember that setbacks are normal and don't mean you've failed. They're opportunities to learn and adjust your strategy.",
                visualElement: .tipBox("Progress, not perfection. Every step toward your goal is a victory worth celebrating.", .green),
                isLastPage: true
            )
        ],
        category: "Personal Growth",
        isPremium: true
    ),
    
    // Building Confidence Course (Premium)
    CourseContent(
        courseId: "building_confidence",
        title: "Building Confidence",
        icon: "star.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Understanding Confidence",
                content: "Confidence is believing in your ability to handle challenges and achieve your goals. It's not about being perfect or never feeling afraid. It's about trusting yourself to figure things out and bounce back from setbacks.\n\nConfidence is built through experience and practice. Every time you face a challenge and get through it, you're building confidence for the next challenge.",
                visualElement: .icon("star.fill", .yellow),
                tips: [
                    "Confidence is built through experience",
                    "It's okay to feel afraid and still act",
                    "Small wins build confidence over time"
                ]
            ),
            CoursePage(
                title: "Building Confidence Through Action",
                content: "The best way to build confidence is to take action, even when you're not sure you can succeed. Start with small challenges and gradually work up to bigger ones. Each success, no matter how small, builds your confidence.\n\nFocus on your effort and progress rather than just the outcome. Celebrate the courage it takes to try, regardless of the result.",
                visualElement: .stepList([
                    "Start with small challenges",
                    "Take action despite fear",
                    "Focus on effort, not just outcome",
                    "Celebrate your courage",
                    "Learn from setbacks"
                ])
            ),
            CoursePage(
                title: "Overcoming Self-Doubt",
                content: "Self-doubt is normal and doesn't mean you can't succeed. When you hear that inner critic, ask yourself: 'What would I tell a friend who was feeling this way?'\n\nRemember your past successes and the challenges you've already overcome. You have more strength and capability than you might realize.",
                visualElement: .comparison("Self-doubt: 'I can't do this'", "Confidence: 'I can figure this out'")
            ),
            CoursePage(
                title: "Maintaining Confidence",
                content: "Confidence is like a muscle - it needs regular exercise to stay strong. Continue challenging yourself and stepping outside your comfort zone. Surround yourself with supportive people who believe in you.\n\nPractice self-compassion when you face setbacks. Remember that everyone experiences failures and doubts. What matters is how you respond to them.",
                visualElement: .tipBox("Confidence is a journey, not a destination. Keep challenging yourself and celebrating your growth.", .blue),
                isLastPage: true
            )
        ],
        category: "Personal Growth",
        isPremium: true
    ),
    
    // Overcoming Fear Course (Premium)
    CourseContent(
        courseId: "overcoming_fear",
        title: "Overcoming Fear",
        icon: "shield.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding Fear",
                content: "Fear is a natural response designed to protect you from danger. However, sometimes fear can hold you back from things that would actually be good for you. Learning to distinguish between helpful and unhelpful fear is an important skill.\n\nFear often feels bigger than it actually is. When you face your fears, you usually find that they're not as scary as you imagined.",
                visualElement: .icon("shield.fill", .orange)
            ),
            CoursePage(
                title: "Facing Your Fears",
                content: "The best way to overcome fear is to face it gradually. Start with small steps that feel manageable. As you become more comfortable, you can take bigger steps.\n\nRemember that feeling afraid doesn't mean you shouldn't do something. Courage is feeling afraid and doing it anyway.",
                visualElement: .stepList([
                    "Identify what you're afraid of",
                    "Start with small, manageable steps",
                    "Practice regularly",
                    "Celebrate your progress",
                    "Be patient with yourself"
                ])
            ),
            CoursePage(
                title: "Building Courage",
                content: "Courage is a skill that you can develop through practice. Every time you face a fear, you're building your courage muscle. Remember that everyone feels afraid sometimes - what matters is how you respond to that fear.",
                visualElement: .tipBox("Courage is not the absence of fear, but the willingness to act despite it.", .green),
                isLastPage: true
            )
        ],
        category: "Personal Growth",
        isPremium: true
    ),
    
    // Personal Values Course (Premium)
    CourseContent(
        courseId: "personal_values",
        title: "Personal Values",
        icon: "diamond.fill",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "What Are Personal Values?",
                content: "Personal values are the principles and beliefs that are most important to you. They guide your decisions, shape your behavior, and give your life meaning and direction. When you live according to your values, you feel more authentic and fulfilled.\n\nValues are different from goals - they're ongoing principles rather than specific achievements. Examples include honesty, creativity, family, learning, or helping others.",
                visualElement: .icon("diamond.fill", .purple)
            ),
            CoursePage(
                title: "Living Your Values",
                content: "Take time to reflect on what's truly important to you. What principles do you want to guide your life? Once you identify your values, look for ways to express them in your daily actions and decisions.\n\nRemember that living your values is a practice, not a perfect state. Every day offers new opportunities to align your actions with what matters most to you.",
                visualElement: .tipBox("Your values are your compass. Let them guide your decisions and actions.", .blue),
                isLastPage: true
            )
        ],
        category: "Personal Growth",
        isPremium: true
    ),
    
    // Sleep Anxiety Course (Premium)
    CourseContent(
        courseId: "sleep_anxiety",
        title: "Sleep Anxiety",
        icon: "brain.head.profile",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding Sleep Anxiety",
                content: "Sleep anxiety is when you worry about not being able to sleep, which ironically makes it harder to fall asleep. This creates a cycle where anxiety about sleep leads to more sleep problems, which leads to more anxiety.\n\nSleep anxiety is common and treatable. The key is to break the cycle by changing your relationship with sleep and developing healthier sleep habits.",
                visualElement: .icon("brain.head.profile", .blue),
                tips: [
                    "Sleep anxiety is common and treatable",
                    "Worrying about sleep makes it harder to sleep",
                    "Breaking the cycle is possible"
                ]
            ),
            CoursePage(
                title: "Breaking the Anxiety Cycle",
                content: "When you can't sleep, try to accept it rather than fighting it. The more you worry about not sleeping, the harder it becomes. Instead, focus on resting your body and mind, even if you're not sleeping.\n\nPractice relaxation techniques like deep breathing or progressive muscle relaxation. These can help calm your mind and body, making sleep more likely.",
                visualElement: .stepList([
                    "Accept that you're awake",
                    "Focus on resting, not sleeping",
                    "Practice relaxation techniques",
                    "Get up if you're frustrated",
                    "Return to bed when sleepy"
                ])
            ),
            CoursePage(
                title: "Creating a Calm Mindset",
                content: "Develop a positive relationship with your bed and sleep. Your bed should be associated with rest and relaxation, not anxiety and frustration.\n\nRemember that occasional poor sleep is normal and doesn't mean you have a sleep disorder. Your body is resilient and can handle occasional sleep disturbances.",
                visualElement: .tipBox("Your bed should be a sanctuary for rest, not a battleground for sleep anxiety.", .green),
                isLastPage: true
            )
        ],
        category: "Sleep & Rest",
        isPremium: true
    ),
    
    // Evening Routine Course (Premium)
    CourseContent(
        courseId: "evening_routine",
        title: "Evening Routine",
        icon: "sunset.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "The Power of Evening Routines",
                content: "A consistent evening routine helps signal to your body and mind that it's time to wind down and prepare for sleep. It creates a smooth transition from the busyness of the day to the peace of the night.\n\nEvening routines don't need to be complicated or time-consuming. Simple, consistent actions can make a big difference in how well you sleep and how you feel the next day.",
                visualElement: .icon("sunset.fill", .orange),
                tips: [
                    "Evening routines signal time to wind down",
                    "Consistency is more important than complexity",
                    "Start with small, manageable changes"
                ]
            ),
            CoursePage(
                title: "Building Your Evening Routine",
                content: "Start your evening routine about an hour before bed. Include activities that help you relax, such as reading, gentle stretching, or listening to calming music. Avoid stimulating activities like work, intense exercise, or screen time.\n\nCreate a routine that feels good to you. It might include journaling, meditation, or simply sitting quietly for a few minutes.",
                visualElement: .stepList([
                    "Start 1 hour before bed",
                    "Avoid screens and work",
                    "Include relaxing activities",
                    "Create a consistent schedule",
                    "Be patient with the process"
                ])
            ),
            CoursePage(
                title: "Making It Stick",
                content: "Start with just one or two elements and gradually build your routine. Be consistent, even on weekends. Remember that it takes time to establish new habits.\n\nIf you miss a night or your routine doesn't go as planned, don't give up. Simply return to it the next night. Progress, not perfection, is the goal.",
                visualElement: .tipBox("Consistency beats perfection. A simple routine done regularly is better than a complex one done occasionally.", .blue),
                isLastPage: true
            )
        ],
        category: "Sleep & Rest",
        isPremium: true
    ),
    
    // Emotional Awareness Course (Premium)
    CourseContent(
        courseId: "emotional_awareness",
        title: "Emotional Awareness",
        icon: "heart.circle.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding Your Emotions",
                content: "Emotional awareness is the ability to recognize, understand, and accept your emotions as they arise. It's about being in touch with how you're feeling and understanding what those feelings are telling you.\n\nEmotions are valuable sources of information about your needs, values, and experiences. When you're more aware of your emotions, you can respond to them more skillfully and make better decisions.",
                visualElement: .icon("heart.circle.fill", .pink),
                tips: [
                    "Emotions are valuable information",
                    "All emotions are valid",
                    "Awareness is the first step to change"
                ]
            ),
            CoursePage(
                title: "Developing Emotional Awareness",
                content: "Start by regularly checking in with yourself throughout the day. Ask yourself: 'How am I feeling right now?' Notice physical sensations, thoughts, and behaviors that might indicate your emotional state.\n\nPractice naming your emotions. Instead of just feeling 'bad,' try to identify specific emotions like sadness, frustration, anxiety, or disappointment.",
                visualElement: .stepList([
                    "Check in with yourself regularly",
                    "Notice physical sensations",
                    "Name your emotions specifically",
                    "Accept your emotions without judgment",
                    "Understand what your emotions are telling you"
                ])
            ),
            CoursePage(
                title: "Using Emotional Information",
                content: "Once you're aware of your emotions, you can use that information to make better decisions and take care of yourself. If you're feeling anxious, you might need to take a break or talk to someone. If you're feeling sad, you might need comfort or support.\n\nRemember that emotions are temporary and will pass. You don't need to act on every emotion, but understanding them helps you respond more skillfully.",
                visualElement: .tipBox("Your emotions are your inner guidance system. Learning to listen to them helps you take better care of yourself.", .green),
                isLastPage: true
            )
        ],
        category: "Emotional Health",
        isPremium: true
    ),
    
    // Managing Anger Course (Premium)
    CourseContent(
        courseId: "managing_anger",
        title: "Managing Anger",
        icon: "flame.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Understanding Anger",
                content: "Anger is a natural emotion that signals when something is wrong or unfair. It can motivate you to make changes and stand up for yourself. However, when anger becomes overwhelming or is expressed in harmful ways, it can cause problems in relationships and your well-being.\n\nLearning to manage anger doesn't mean never feeling angry. It means learning to recognize anger early and respond to it in healthy, constructive ways.",
                visualElement: .icon("flame.fill", .red),
                tips: [
                    "Anger is a natural emotion",
                    "It's okay to feel angry",
                    "How you express anger matters"
                ]
            ),
            CoursePage(
                title: "Recognizing Anger Early",
                content: "Anger often builds gradually. Learn to recognize the early warning signs, such as increased heart rate, muscle tension, or racing thoughts. The earlier you notice anger, the easier it is to manage.\n\nPay attention to your triggers - situations, people, or thoughts that tend to make you angry. Understanding your triggers helps you prepare for and manage them better.",
                visualElement: .stepList([
                    "Notice physical signs of anger",
                    "Identify your anger triggers",
                    "Recognize early warning signs",
                    "Take a pause before reacting",
                    "Choose how to respond"
                ])
            ),
            CoursePage(
                title: "Healthy Ways to Express Anger",
                content: "When you're angry, take time to calm down before responding. Try deep breathing, counting to ten, or taking a short walk. Once you're calmer, you can express your feelings more constructively.\n\nUse 'I' statements to express your feelings without blaming others. For example, say 'I feel frustrated when...' instead of 'You always...'",
                visualElement: .comparison("Unhealthy: 'You're so stupid!'", "Healthy: 'I feel frustrated when this happens'")
            ),
            CoursePage(
                title: "Preventing Anger Build-up",
                content: "Regular stress management and self-care can help prevent anger from building up. Make time for activities that help you relax and recharge.\n\nPractice communication skills to address issues before they become major problems. Learning to express your needs and concerns early can prevent anger from escalating.",
                visualElement: .tipBox("Prevention is better than cure. Regular self-care and good communication can prevent many anger issues.", .blue),
                isLastPage: true
            )
        ],
        category: "Emotional Health",
        isPremium: true
    ),
    
    // Dealing with Sadness Course (Premium)
    CourseContent(
        courseId: "dealing_with_sadness",
        title: "Dealing with Sadness",
        icon: "cloud.rain.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding Sadness",
                content: "Sadness is a natural response to loss, disappointment, or difficult circumstances. It's a normal part of the human experience and serves an important purpose in helping you process difficult emotions and experiences.\n\nSadness is different from depression, which is a more persistent and severe condition. Normal sadness comes and goes, while depression tends to be more constant and overwhelming.",
                visualElement: .icon("cloud.rain.fill", .blue)
            ),
            CoursePage(
                title: "Allowing Yourself to Feel Sad",
                content: "It's okay to feel sad. Trying to suppress or ignore sadness often makes it worse. Instead, allow yourself to feel your emotions and give yourself permission to grieve or process what you're going through.\n\nPractice self-compassion when you're sad. Treat yourself with the same kindness you would offer to a friend who was struggling.",
                visualElement: .stepList([
                    "Allow yourself to feel sad",
                    "Practice self-compassion",
                    "Express your feelings",
                    "Take care of yourself",
                    "Seek support when needed"
                ])
            ),
            CoursePage(
                title: "Moving Through Sadness",
                content: "While it's important to allow yourself to feel sad, you can also take steps to help yourself feel better. Engage in activities that bring you comfort or joy, even if you don't feel like it initially.\n\nRemember that sadness is temporary and will pass. Be patient with yourself and trust that you have the strength to get through difficult times.",
                visualElement: .tipBox("Sadness is like a wave - it rises, peaks, and then recedes. You have the strength to ride it out.", .green),
                isLastPage: true
            )
        ],
        category: "Emotional Health",
        isPremium: true
    ),
    
    // Joy & Happiness Course (Premium)
    CourseContent(
        courseId: "joy_happiness",
        title: "Joy & Happiness",
        icon: "sun.max.fill",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "Cultivating Joy",
                content: "Joy and happiness are not just emotions that happen to you - they're also skills you can develop. While you can't control everything that happens to you, you can influence how you respond to life's experiences.\n\nHappiness often comes from simple things: meaningful connections, engaging activities, and a sense of purpose. It's about finding joy in the everyday moments of life.",
                visualElement: .icon("sun.max.fill", .yellow)
            ),
            CoursePage(
                title: "Finding Joy in Daily Life",
                content: "Look for opportunities to experience joy in your daily routine. This might be savoring a good meal, appreciating nature, or connecting with loved ones. Practice gratitude for the good things in your life.\n\nRemember that happiness doesn't mean being happy all the time. It's about having more positive than negative experiences and being able to bounce back from difficulties.",
                visualElement: .tipBox("Happiness is not a destination, but a way of traveling through life.", .orange),
                isLastPage: true
            )
        ],
        category: "Emotional Health",
        isPremium: true
    ),
    
    // Emotional Balance Course (Premium)
    CourseContent(
        courseId: "emotional_balance",
        title: "Emotional Balance",
        icon: "scalemass.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "What is Emotional Balance?",
                content: "Emotional balance is the ability to experience and express emotions appropriately without being overwhelmed by them. It's about having emotional flexibility - being able to feel your emotions while still making thoughtful decisions.\n\nEmotional balance doesn't mean being calm all the time. It means being able to experience the full range of human emotions while maintaining your ability to function and make good choices.",
                visualElement: .icon("scalemass.fill", .green),
                tips: [
                    "Emotional balance is a skill you can develop",
                    "It's not about suppressing emotions",
                    "Balance allows for emotional flexibility"
                ]
            ),
            CoursePage(
                title: "Developing Emotional Balance",
                content: "Practice mindfulness to become more aware of your emotions without being controlled by them. Learn to observe your emotions as they arise, peak, and pass, like waves in the ocean.\n\nDevelop emotional regulation skills, such as deep breathing, self-soothing techniques, and cognitive reframing. These tools help you respond to emotions more skillfully.",
                visualElement: .stepList([
                    "Practice mindfulness",
                    "Observe emotions without judgment",
                    "Develop regulation skills",
                    "Maintain perspective",
                    "Practice self-compassion"
                ])
            ),
            CoursePage(
                title: "Maintaining Balance in Difficult Times",
                content: "During challenging periods, it's especially important to practice self-care and maintain routines that support your emotional well-being. Don't be afraid to seek support from others when you need it.\n\nRemember that emotional balance is a journey, not a destination. You'll have ups and downs, and that's normal. What matters is your overall ability to navigate life's challenges with resilience.",
                visualElement: .tipBox("Emotional balance is like riding a bike - you may wobble, but you can always find your center again.", .blue),
                isLastPage: true
            )
        ],
        category: "Emotional Health",
        isPremium: true
    ),
    
    // Work-Life Balance Course (Premium)
    CourseContent(
        courseId: "work_life_balance",
        title: "Work-Life Balance",
        icon: "briefcase.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Understanding Work-Life Balance",
                content: "Work-life balance is about creating harmony between your professional responsibilities and your personal life. It's not about spending equal time on work and life, but about feeling satisfied and fulfilled in both areas.\n\nGood work-life balance helps prevent burnout, improves your relationships, and allows you to pursue activities that bring you joy and meaning outside of work.",
                visualElement: .icon("briefcase.fill", .teal),
                tips: [
                    "Balance is personal - what works for you may differ",
                    "It's about quality, not just quantity of time",
                    "Regular check-ins help maintain balance"
                ]
            ),
            CoursePage(
                title: "Setting Boundaries",
                content: "Clear boundaries are essential for work-life balance. This might mean setting specific work hours, not checking email after a certain time, or learning to say no to additional responsibilities when you're already stretched thin.\n\nCommunicate your boundaries clearly to colleagues and family members. Remember that setting boundaries is not selfish - it's necessary for your well-being and effectiveness.",
                visualElement: .stepList([
                    "Define your work hours",
                    "Set technology boundaries",
                    "Learn to say no",
                    "Communicate your boundaries",
                    "Stick to your limits"
                ])
            ),
            CoursePage(
                title: "Making Time for What Matters",
                content: "Identify what's most important to you outside of work - relationships, hobbies, health, or personal growth. Schedule time for these activities and treat them as non-negotiable appointments.\n\nRemember that taking care of yourself is not a luxury - it's essential for your long-term success and happiness.",
                visualElement: .comparison("Imbalanced: 'I'll exercise when I have time'", "Balanced: 'I exercise three times a week'")
            ),
            CoursePage(
                title: "Maintaining Your Balance",
                content: "Work-life balance requires ongoing attention and adjustment. Regularly assess how you're feeling and make changes as needed. Be flexible - some weeks may require more work focus, while others may allow more personal time.\n\nRemember that perfect balance is a myth. Aim for a sustainable rhythm that works for you and your circumstances.",
                visualElement: .tipBox("Work-life balance is a journey, not a destination. Regular check-ins and adjustments keep you on track.", .green),
                isLastPage: true
            )
        ],
        category: "Work & Career",
        isPremium: true
    ),
    
    // Dealing with Burnout Course (Premium)
    CourseContent(
        courseId: "dealing_with_burnout",
        title: "Dealing with Burnout",
        icon: "exclamationmark.triangle.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding Burnout",
                content: "Burnout is a state of emotional, physical, and mental exhaustion caused by prolonged stress. It's more than just feeling tired - it's a feeling of being overwhelmed, emotionally drained, and unable to meet constant demands.\n\nBurnout can affect anyone, regardless of their job or lifestyle. Recognizing the signs early is crucial for preventing it from becoming severe.",
                visualElement: .icon("exclamationmark.triangle.fill", .orange)
            ),
            CoursePage(
                title: "Recognizing Burnout Signs",
                content: "Common signs of burnout include feeling exhausted all the time, becoming cynical or detached from your work, feeling ineffective or like you're not accomplishing anything, and experiencing physical symptoms like headaches or stomach problems.\n\nIf you're experiencing these symptoms, it's important to take them seriously and take steps to address them.",
                visualElement: .stepList([
                    "Constant exhaustion",
                    "Cynicism or detachment",
                    "Feeling ineffective",
                    "Physical symptoms",
                    "Difficulty concentrating"
                ])
            ),
            CoursePage(
                title: "Recovering from Burnout",
                content: "Recovery from burnout starts with acknowledging the problem and giving yourself permission to rest. Take time off if possible, and focus on activities that help you recharge.\n\nSeek support from friends, family, or a mental health professional. Remember that recovery takes time - be patient with yourself.",
                visualElement: .tipBox("Recovery from burnout is not a sign of weakness - it's a necessary step toward sustainable well-being.", .green),
                isLastPage: true
            )
        ],
        category: "Work & Career",
        isPremium: true
    ),
    
    // Productivity Tips Course (Premium)
    CourseContent(
        courseId: "productivity_tips",
        title: "Productivity Tips",
        icon: "bolt.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Working Smarter, Not Harder",
                content: "Productivity is not about working longer hours - it's about working more effectively. By understanding how you work best and using proven strategies, you can accomplish more in less time while feeling less stressed.\n\nGood productivity habits can help you feel more in control of your time and reduce the feeling of being constantly behind.",
                visualElement: .icon("bolt.fill", .yellow)
            ),
            CoursePage(
                title: "Key Productivity Strategies",
                content: "Start with the most important tasks first, when your energy is highest. Break large projects into smaller, manageable steps. Eliminate distractions and create a focused work environment.\n\nTake regular breaks to maintain your energy and focus. Remember that productivity is about sustainable performance, not pushing yourself to exhaustion.",
                visualElement: .stepList([
                    "Prioritize important tasks",
                    "Break projects into steps",
                    "Eliminate distractions",
                    "Take regular breaks",
                    "Review and adjust regularly"
                ])
            ),
            CoursePage(
                title: "Building Productive Habits",
                content: "Consistency is key to productivity. Start with one or two strategies and practice them regularly until they become habits. Be patient with yourself - building new habits takes time.\n\nRemember that productivity is personal. What works for one person may not work for another. Experiment to find what works best for you.",
                visualElement: .tipBox("Productivity is about progress, not perfection. Small improvements add up over time.", .blue),
                isLastPage: true
            )
        ],
        category: "Work & Career",
        isPremium: true
    ),
    
    // Workplace Stress Course (Premium)
    CourseContent(
        courseId: "workplace_stress",
        title: "Workplace Stress",
        icon: "building.2.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Understanding Workplace Stress",
                content: "Workplace stress is a common experience that can come from high demands, lack of control, poor relationships, or unclear expectations. While some stress can be motivating, chronic workplace stress can harm your health and well-being.\n\nRecognizing the sources of your workplace stress is the first step in managing it effectively.",
                visualElement: .icon("building.2.fill", .gray),
                tips: [
                    "Some stress is normal and motivating",
                    "Chronic stress needs attention",
                    "You have more control than you think"
                ]
            ),
            CoursePage(
                title: "Identifying Stress Sources",
                content: "Common sources of workplace stress include unrealistic deadlines, unclear expectations, poor communication, lack of support, and feeling undervalued. Take time to identify what's causing your stress.\n\nOnce you understand the sources, you can develop strategies to address them or cope with them more effectively.",
                visualElement: .stepList([
                    "Unrealistic deadlines",
                    "Unclear expectations",
                    "Poor communication",
                    "Lack of support",
                    "Feeling undervalued"
                ])
            ),
            CoursePage(
                title: "Managing Workplace Stress",
                content: "Develop healthy coping strategies like taking regular breaks, practicing stress management techniques, and maintaining clear boundaries between work and personal life.\n\nDon't be afraid to communicate with your supervisor about workload or other concerns. Many workplace stress issues can be resolved through open communication.",
                visualElement: .comparison("Unhealthy: Working through lunch every day", "Healthy: Taking regular breaks and setting boundaries")
            ),
            CoursePage(
                title: "Creating a Healthier Work Environment",
                content: "While you can't control everything about your workplace, you can influence your own experience. Focus on what you can control, such as your attitude, work habits, and stress management strategies.\n\nBuild supportive relationships with colleagues and seek out opportunities for growth and development that align with your interests and strengths.",
                visualElement: .tipBox("You have more influence over your workplace experience than you might think. Focus on what you can control.", .green),
                isLastPage: true
            )
        ],
        category: "Work & Career",
        isPremium: true
    ),
    
    // Career Growth Course (Premium)
    CourseContent(
        courseId: "career_growth",
        title: "Career Growth",
        icon: "chart.line.uptrend.xyaxis",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Planning Your Career Path",
                content: "Career growth is about intentionally developing your skills, knowledge, and experience to advance in your chosen field. It requires self-reflection, goal setting, and continuous learning.\n\nYour career path doesn't have to follow a straight line. Many successful careers involve twists, turns, and unexpected opportunities.",
                visualElement: .icon("chart.line.uptrend.xyaxis", .blue)
            ),
            CoursePage(
                title: "Building Your Skills",
                content: "Identify the skills that are most valuable in your field and focus on developing them. This might involve formal education, on-the-job learning, or self-directed study.\n\nDon't forget about soft skills like communication, leadership, and problem-solving. These are often just as important as technical skills for career advancement.",
                visualElement: .stepList([
                    "Identify valuable skills",
                    "Seek learning opportunities",
                    "Practice regularly",
                    "Get feedback",
                    "Stay current in your field"
                ])
            ),
            CoursePage(
                title: "Navigating Career Transitions",
                content: "Career growth often involves transitions - new roles, new companies, or even new industries. Approach these transitions with curiosity and openness to learning.\n\nRemember that career growth is a marathon, not a sprint. Focus on building a sustainable career that aligns with your values and interests.",
                visualElement: .tipBox("Career growth is about continuous learning and adaptation. Stay curious and open to new opportunities.", .green),
                isLastPage: true
            )
        ],
        category: "Work & Career",
        isPremium: true
    ),
    
    // Social Anxiety Course (Premium)
    CourseContent(
        courseId: "social_anxiety",
        title: "Social Anxiety",
        icon: "person.3.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Understanding Social Anxiety",
                content: "Social anxiety is the fear of being judged, embarrassed, or humiliated in social situations. It's more than just shyness - it's an intense fear that can interfere with daily life and relationships.\n\nSocial anxiety is common and treatable. Many people experience it to some degree, and there are effective strategies for managing it.",
                visualElement: .icon("person.3.fill", .purple),
                tips: [
                    "Social anxiety is common and treatable",
                    "It's more than just shyness",
                    "Small steps can lead to big improvements"
                ]
            ),
            CoursePage(
                title: "Recognizing Social Anxiety",
                content: "Common symptoms include intense fear of social situations, physical symptoms like sweating or rapid heartbeat, avoiding social situations, and excessive worry about what others think.\n\nUnderstanding your specific triggers and symptoms is the first step in managing social anxiety effectively.",
                visualElement: .stepList([
                    "Fear of judgment",
                    "Physical symptoms",
                    "Avoiding social situations",
                    "Excessive worry",
                    "Difficulty speaking"
                ])
            ),
            CoursePage(
                title: "Managing Social Anxiety",
                content: "Start with small, manageable social situations and gradually work up to more challenging ones. Practice relaxation techniques before social events. Focus on the present moment rather than worrying about what might happen.\n\nRemember that most people are focused on themselves, not on judging you. Challenge negative thoughts about how others perceive you.",
                visualElement: .comparison("Anxious: 'Everyone is judging me'", "Balanced: 'Most people are focused on themselves'")
            ),
            CoursePage(
                title: "Building Social Confidence",
                content: "Practice social skills in low-pressure situations. Join groups or activities that interest you, where you can meet people with similar interests. Remember that social skills improve with practice.\n\nBe patient with yourself. Overcoming social anxiety takes time and practice. Celebrate small victories and don't be discouraged by setbacks.",
                visualElement: .tipBox("Social confidence is built through practice. Start small and be patient with your progress.", .green),
                isLastPage: true
            )
        ],
        category: "Social Skills",
        isPremium: true
    ),
    
    // Making Friends Course (Premium)
    CourseContent(
        courseId: "making_friends",
        title: "Making Friends",
        icon: "person.badge.plus.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "The Art of Making Friends",
                content: "Making friends as an adult can feel challenging, but it's a skill that can be learned and practiced. Friendships provide support, connection, and joy, making them essential for our well-being.\n\nGood friendships are built on mutual interest, shared experiences, and genuine care for each other. They take time to develop and require ongoing effort to maintain.",
                visualElement: .icon("person.badge.plus.fill", .blue)
            ),
            CoursePage(
                title: "Finding Opportunities to Connect",
                content: "Look for opportunities to meet people with similar interests. Join clubs, take classes, volunteer, or participate in community events. Be open to meeting people in unexpected places.\n\nRemember that most people are also looking for connection. Don't be afraid to initiate conversations or suggest getting together.",
                visualElement: .stepList([
                    "Join clubs or groups",
                    "Take classes or workshops",
                    "Volunteer in your community",
                    "Attend local events",
                    "Be open to new experiences"
                ])
            ),
            CoursePage(
                title: "Building and Maintaining Friendships",
                content: "Show genuine interest in others by asking questions and listening actively. Be reliable and follow through on plans. Share your own experiences and be vulnerable when appropriate.\n\nRemember that friendships require effort from both people. Be patient and don't take it personally if some connections don't develop into close friendships.",
                visualElement: .tipBox("Friendships are built on genuine interest, reliability, and mutual care. Be patient with the process.", .green),
                isLastPage: true
            )
        ],
        category: "Social Skills",
        isPremium: true
    ),
    
    // Public Speaking Course (Premium)
    CourseContent(
        courseId: "public_speaking",
        title: "Public Speaking",
        icon: "megaphone.fill",
        duration: "5 min",
        pages: [
            CoursePage(
                title: "Overcoming Public Speaking Fear",
                content: "Fear of public speaking is one of the most common fears, affecting many people. However, public speaking is a skill that can be learned and improved with practice.\n\nThe key is to start small and gradually build your confidence. Remember that most people in your audience want you to succeed.",
                visualElement: .icon("megaphone.fill", .red),
                tips: [
                    "Public speaking is a learnable skill",
                    "Most people want you to succeed",
                    "Practice makes progress"
                ]
            ),
            CoursePage(
                title: "Preparing for Success",
                content: "Know your material well - this builds confidence. Practice your presentation multiple times, preferably in front of a mirror or with a friend. Prepare for potential questions or challenges.\n\nFocus on your message and your audience, not on yourself. Remember that you're sharing valuable information or insights with people who want to hear it.",
                visualElement: .stepList([
                    "Know your material thoroughly",
                    "Practice multiple times",
                    "Prepare for questions",
                    "Focus on your message",
                    "Visualize success"
                ])
            ),
            CoursePage(
                title: "Managing Nervousness",
                content: "Some nervousness is normal and can actually improve your performance. Practice deep breathing and relaxation techniques before speaking. Remember that your audience can't see your nervousness as much as you think they can.\n\nStart with smaller groups and gradually work up to larger audiences. Each successful experience builds your confidence for the next one.",
                visualElement: .comparison("Fearful: 'I'm going to mess up'", "Confident: 'I'm prepared and ready to share'")
            ),
            CoursePage(
                title: "Delivering with Impact",
                content: "Speak clearly and at a good pace. Make eye contact with your audience and use gestures naturally. Vary your voice tone and volume to keep people engaged.\n\nRemember that public speaking is about connecting with your audience and sharing your message effectively. Focus on the value you're providing rather than on your performance.",
                visualElement: .tipBox("Great public speaking is about connecting with your audience and sharing your message effectively.", .blue),
                isLastPage: true
            )
        ],
        category: "Social Skills",
        isPremium: true
    ),
    
    // Social Confidence Course (Premium)
    CourseContent(
        courseId: "social_confidence",
        title: "Social Confidence",
        icon: "person.fill.checkmark",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Building Social Confidence",
                content: "Social confidence is the ability to feel comfortable and authentic in social situations. It's not about being the most outgoing person in the room - it's about being comfortable with who you are and how you interact with others.\n\nSocial confidence is built through experience and practice. Every social interaction is an opportunity to develop this skill.",
                visualElement: .icon("person.fill.checkmark", .green)
            ),
            CoursePage(
                title: "Developing Authentic Confidence",
                content: "Focus on being genuine rather than trying to impress others. Share your interests and experiences authentically. Remember that you don't need to be perfect to be likable.\n\nPractice active listening and show genuine interest in others. This not only helps you connect with people but also takes the focus off your own nervousness.",
                visualElement: .stepList([
                    "Be genuine and authentic",
                    "Share your interests",
                    "Practice active listening",
                    "Show interest in others",
                    "Accept that you don't need to be perfect"
                ])
            ),
            CoursePage(
                title: "Maintaining Your Confidence",
                content: "Remember that everyone has moments of social awkwardness or uncertainty. Don't let one bad experience define your social confidence. Learn from each interaction and keep practicing.\n\nSurround yourself with supportive people who appreciate you for who you are. Their positive feedback can help reinforce your social confidence.",
                visualElement: .tipBox("Social confidence grows with practice. Every interaction is an opportunity to develop this skill.", .green),
                isLastPage: true
            )
        ],
        category: "Social Skills",
        isPremium: true
    ),
    
    // Group Dynamics Course (Premium)
    CourseContent(
        courseId: "group_dynamics",
        title: "Group Dynamics",
        icon: "person.2.circle.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Understanding Group Dynamics",
                content: "Group dynamics are the patterns of behavior and interaction that occur when people work or socialize together. Understanding these dynamics can help you navigate group situations more effectively.\n\nEvery group has its own culture, roles, and communication patterns. Learning to read and work with these dynamics can improve your group experiences.",
                visualElement: .icon("person.2.circle.fill", .cyan),
                tips: [
                    "Every group has its own dynamics",
                    "Understanding dynamics improves participation",
                    "You can influence group dynamics positively"
                ]
            ),
            CoursePage(
                title: "Navigating Group Roles",
                content: "Groups often have informal roles like leaders, mediators, supporters, and challengers. Understanding these roles can help you contribute effectively to the group.\n\nBe flexible about the role you play. Sometimes you might need to lead, other times to support. The key is to contribute in a way that helps the group achieve its goals.",
                visualElement: .stepList([
                    "Observe group roles",
                    "Be flexible in your role",
                    "Support group goals",
                    "Contribute constructively",
                    "Respect different perspectives"
                ])
            ),
            CoursePage(
                title: "Building Positive Group Dynamics",
                content: "Encourage open communication and respect for different viewpoints. Help create an environment where everyone feels heard and valued. Address conflicts constructively when they arise.\n\nRemember that you have the power to influence group dynamics positively through your own behavior and communication.",
                visualElement: .comparison("Negative: Dominating conversations", "Positive: Encouraging others to participate")
            ),
            CoursePage(
                title: "Thriving in Group Settings",
                content: "Focus on contributing value to the group while also learning from others. Be open to different perspectives and approaches. Remember that group success often depends on collaboration and mutual support.\n\nPractice active listening and show appreciation for others' contributions. This creates a positive environment where everyone can thrive.",
                visualElement: .tipBox("Positive group dynamics benefit everyone. Your contributions can make a difference.", .blue),
                isLastPage: true
            )
        ],
        category: "Social Skills",
        isPremium: true
    ),
    
    // Building Good Habits Course (Premium)
    CourseContent(
        courseId: "building_good_habits",
        title: "Building Good Habits",
        icon: "checkmark.circle.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "The Power of Habits",
                content: "Habits are automatic behaviors that shape your daily life. Good habits can improve your health, productivity, and well-being, while bad habits can hold you back. Understanding how habits work is the first step to building better ones.\n\nHabits are formed through repetition and reinforcement. The more you practice a behavior, the more automatic it becomes.",
                visualElement: .icon("checkmark.circle.fill", .green),
                tips: [
                    "Habits are formed through repetition",
                    "Start small and build gradually",
                    "Consistency is more important than perfection"
                ]
            ),
            CoursePage(
                title: "The Habit Loop",
                content: "Every habit has three parts: a cue (trigger), a routine (behavior), and a reward. Understanding this loop helps you build good habits and break bad ones.\n\nTo build a good habit, identify a clear cue, make the routine easy to do, and ensure there's a satisfying reward. To break a bad habit, disrupt the loop by changing the cue, routine, or reward.",
                visualElement: .stepList([
                    "Cue: What triggers the habit?",
                    "Routine: What is the behavior?",
                    "Reward: What is the benefit?",
                    "Identify your habit loops",
                    "Modify the loop intentionally"
                ])
            ),
            CoursePage(
                title: "Building New Habits",
                content: "Start with small, manageable changes. Make your new habit easy to do by reducing friction. Stack your new habit onto an existing one. For example, if you want to meditate, do it right after brushing your teeth.\n\nTrack your progress and celebrate small wins. Remember that building habits takes time - be patient and consistent.",
                visualElement: .comparison("Overwhelming: 'I'll exercise for an hour every day'", "Manageable: 'I'll do 10 push-ups every morning'")
            ),
            CoursePage(
                title: "Maintaining Your Habits",
                content: "Habits are most vulnerable when you're stressed, tired, or busy. Plan for these challenging times by having backup strategies. Don't let one missed day derail your progress.\n\nRemember that building good habits is a lifelong process. Focus on progress, not perfection, and be kind to yourself when you slip up.",
                visualElement: .tipBox("Habits are like compound interest - small daily actions add up to significant long-term results.", .blue),
                isLastPage: true
            )
        ],
        category: "Habits & Routines",
        isPremium: true
    ),
    
    // Breaking Bad Habits Course (Premium)
    CourseContent(
        courseId: "breaking_bad_habits",
        title: "Breaking Bad Habits",
        icon: "xmark.circle.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding Bad Habits",
                content: "Bad habits are behaviors that don't serve your long-term goals or well-being. They often provide short-term relief or pleasure but have negative long-term consequences.\n\nBreaking bad habits is challenging but possible. The key is to understand why the habit exists and develop strategies to replace it with healthier alternatives.",
                visualElement: .icon("xmark.circle.fill", .red)
            ),
            CoursePage(
                title: "Identifying Your Triggers",
                content: "Bad habits are often triggered by specific situations, emotions, or people. Understanding your triggers helps you prepare for and avoid them.\n\nKeep a habit journal to track when and why you engage in the habit. This information helps you develop targeted strategies for change.",
                visualElement: .stepList([
                    "Identify trigger situations",
                    "Notice emotional triggers",
                    "Track your habit patterns",
                    "Understand the reward",
                    "Plan alternative responses"
                ])
            ),
            CoursePage(
                title: "Replacing Bad Habits",
                content: "Instead of just trying to stop a bad habit, replace it with a healthier alternative that provides similar benefits. For example, if you stress-eat, try stress-walking instead.\n\nBe patient with yourself. Breaking habits takes time and you may slip up occasionally. Focus on progress over perfection.",
                visualElement: .tipBox("Replace bad habits with good ones rather than just trying to eliminate them.", .green),
                isLastPage: true
            )
        ],
        category: "Habits & Routines",
        isPremium: true
    ),
    
    // Habit Tracking Course (Premium)
    CourseContent(
        courseId: "habit_tracking",
        title: "Habit Tracking",
        icon: "chart.bar.fill",
        duration: "2 min",
        pages: [
            CoursePage(
                title: "Why Track Your Habits?",
                content: "Habit tracking provides visual feedback on your progress and helps you stay motivated. It makes your habits more visible and helps you identify patterns in your behavior.\n\nTracking can be as simple as marking a calendar or using a habit tracking app. The key is finding a method that works for you and that you'll actually use consistently.",
                visualElement: .icon("chart.bar.fill", .blue)
            ),
            CoursePage(
                title: "Effective Tracking Methods",
                content: "Choose a tracking method that's simple and sustainable. This might be a physical calendar, a digital app, or a simple checklist. Focus on tracking the habits that matter most to you.\n\nReview your tracking data regularly to identify patterns and adjust your strategies as needed.",
                visualElement: .tipBox("The best tracking method is the one you'll actually use consistently.", .green),
                isLastPage: true
            )
        ],
        category: "Habits & Routines",
        isPremium: true
    ),
    
    // Morning Routines Course (Premium)
    CourseContent(
        courseId: "morning_routines",
        title: "Morning Routines",
        icon: "sunrise.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "The Power of Morning Routines",
                content: "How you start your day sets the tone for everything that follows. A good morning routine can improve your mood, energy, and productivity throughout the day.\n\nMorning routines don't need to be elaborate or time-consuming. Simple, consistent actions can make a big difference in how you feel and perform.",
                visualElement: .icon("sunrise.fill", .orange)
            ),
            CoursePage(
                title: "Building Your Morning Routine",
                content: "Start with activities that energize and ground you. This might include exercise, meditation, reading, or simply enjoying a quiet cup of coffee. Avoid checking email or social media first thing.\n\nKeep your routine simple and realistic. It's better to have a short routine you can stick to than an elaborate one you'll abandon.",
                visualElement: .stepList([
                    "Start with energizing activities",
                    "Avoid screens first thing",
                    "Include movement or exercise",
                    "Practice mindfulness or meditation",
                    "Eat a nourishing breakfast"
                ])
            ),
            CoursePage(
                title: "Making It Stick",
                content: "Prepare for your morning routine the night before. Lay out your clothes, prepare your breakfast, or set up your meditation space. This reduces friction and makes it easier to follow through.\n\nBe flexible and adjust your routine as needed. What works for you may change over time, and that's okay.",
                visualElement: .tipBox("A good morning routine is one that you look forward to and can maintain consistently.", .blue),
                isLastPage: true
            )
        ],
        category: "Habits & Routines",
        isPremium: true
    ),
    
    // Consistency Course (Premium)
    CourseContent(
        courseId: "consistency",
        title: "Consistency",
        icon: "repeat.circle.fill",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "The Power of Consistency",
                content: "Consistency is the key to achieving long-term goals and building lasting change. Small actions repeated consistently over time create much better results than occasional bursts of intense effort.\n\nConsistency builds momentum and creates positive feedback loops. The more consistent you are, the easier it becomes to maintain your habits and achieve your goals.",
                visualElement: .icon("repeat.circle.fill", .purple),
                tips: [
                    "Consistency beats intensity",
                    "Small daily actions add up",
                    "Momentum builds over time"
                ]
            ),
            CoursePage(
                title: "Building Consistency",
                content: "Start with small, manageable commitments that you can realistically maintain. Focus on showing up every day, even if it's just for a few minutes. Consistency is more important than duration.\n\nCreate systems and routines that support your consistency. Remove obstacles and make it as easy as possible to follow through on your commitments.",
                visualElement: .stepList([
                    "Start with small commitments",
                    "Focus on daily consistency",
                    "Create supportive systems",
                    "Remove obstacles",
                    "Track your progress"
                ])
            ),
            CoursePage(
                title: "Maintaining Consistency",
                content: "Expect setbacks and plan for them. Don't let one missed day derail your progress. Instead, focus on getting back on track as quickly as possible.\n\nRemember that consistency is a skill that improves with practice. The more you practice being consistent, the easier it becomes.",
                visualElement: .comparison("Inconsistent: 'I'll start again next week'", "Consistent: 'I'll get back on track today'")
            ),
            CoursePage(
                title: "The Compound Effect",
                content: "Consistency creates a compound effect - small improvements build on each other over time, leading to significant results. Trust the process and focus on the long-term benefits of your consistent efforts.\n\nCelebrate your consistency, not just your results. The discipline and commitment you're building are valuable skills that will serve you in all areas of life.",
                visualElement: .tipBox("Consistency is the bridge between goals and accomplishments. Trust the process.", .green),
                isLastPage: true
            )
        ],
        category: "Habits & Routines",
        isPremium: true
    ),
    
    // Self-Care Basics Course (Premium)
    CourseContent(
        courseId: "self_care_basics",
        title: "Self-Care Basics",
        icon: "heart.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "What is Self-Care?",
                content: "Self-care is the practice of taking care of your physical, mental, and emotional well-being. It's not selfish or indulgent - it's essential for your health and ability to care for others.\n\nSelf-care includes activities that nourish your body, mind, and spirit. It's about creating a sustainable lifestyle that supports your overall well-being.",
                visualElement: .icon("heart.fill", .pink),
                tips: [
                    "Self-care is essential, not selfish",
                    "It includes physical, mental, and emotional care",
                    "Self-care looks different for everyone"
                ]
            ),
            CoursePage(
                title: "Types of Self-Care",
                content: "Physical self-care includes exercise, nutrition, sleep, and medical care. Mental self-care involves activities that challenge and stimulate your mind. Emotional self-care includes practices that help you process and express your feelings.\n\nSpiritual self-care might involve meditation, prayer, or connecting with nature. Social self-care includes maintaining healthy relationships and boundaries.",
                visualElement: .stepList([
                    "Physical: exercise, nutrition, sleep",
                    "Mental: learning, creativity, problem-solving",
                    "Emotional: expression, processing, validation",
                    "Spiritual: meditation, nature, reflection",
                    "Social: relationships, boundaries, connection"
                ])
            ),
            CoursePage(
                title: "Making Self-Care a Priority",
                content: "Schedule self-care activities just like you would any other important appointment. Start with small, manageable practices and gradually build your self-care routine.\n\nRemember that self-care is not a luxury - it's a necessity. Taking care of yourself enables you to be your best self and care for others effectively.",
                visualElement: .tipBox("Self-care is not a one-time event, but a daily practice of honoring your needs.", .green),
                isLastPage: true
            )
        ],
        category: "Self-Care",
        isPremium: true
    ),
    
    // Physical Wellness Course (Premium)
    CourseContent(
        courseId: "physical_wellness",
        title: "Physical Wellness",
        icon: "figure.walk",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "Understanding Physical Wellness",
                content: "Physical wellness is about taking care of your body through movement, nutrition, rest, and preventive care. It's the foundation for overall health and well-being.\n\nPhysical wellness is not about achieving a perfect body or following strict diets. It's about creating sustainable habits that support your health and energy levels.",
                visualElement: .icon("figure.walk", .green),
                tips: [
                    "Physical wellness supports overall health",
                    "It's about sustainable habits",
                    "Small changes make big differences"
                ]
            ),
            CoursePage(
                title: "Movement and Exercise",
                content: "Regular movement is essential for physical wellness. This doesn't mean you need to run marathons - walking, dancing, gardening, or playing with children all count as physical activity.\n\nFind activities you enjoy and can maintain consistently. The best exercise is the one you'll actually do regularly.",
                visualElement: .stepList([
                    "Find activities you enjoy",
                    "Start with small amounts",
                    "Build gradually",
                    "Be consistent",
                    "Listen to your body"
                ])
            ),
            CoursePage(
                title: "Nutrition and Hydration",
                content: "Eat a variety of whole foods that nourish your body. Stay hydrated by drinking water throughout the day. Pay attention to how different foods make you feel.\n\nRemember that nutrition is personal - what works for one person may not work for another. Focus on what makes you feel good and energized.",
                visualElement: .comparison("Restrictive: 'I can't eat that'", "Nourishing: 'This food makes me feel good'")
            ),
            CoursePage(
                title: "Rest and Recovery",
                content: "Rest is just as important as activity for physical wellness. Get adequate sleep, take breaks when needed, and listen to your body's signals for rest.\n\nRemember that physical wellness is a journey, not a destination. Focus on progress and sustainability rather than perfection.",
                visualElement: .tipBox("Physical wellness is about honoring your body's needs for movement, nourishment, and rest.", .blue),
                isLastPage: true
            )
        ],
        category: "Self-Care",
        isPremium: true
    ),
    
    // Mental Health Course (Premium)
    CourseContent(
        courseId: "mental_health",
        title: "Mental Health",
        icon: "brain.head.profile",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "Understanding Mental Health",
                content: "Mental health is just as important as physical health. It includes your emotional, psychological, and social well-being. Good mental health helps you cope with stress, relate to others, and make choices.\n\nMental health exists on a spectrum, and everyone experiences ups and downs. Taking care of your mental health is a sign of strength, not weakness.",
                visualElement: .icon("brain.head.profile", .blue)
            ),
            CoursePage(
                title: "Supporting Your Mental Health",
                content: "Practice stress management techniques, maintain healthy relationships, and engage in activities that bring you joy and meaning. Don't hesitate to seek professional help when needed.\n\nRemember that mental health is an ongoing process. Regular self-care and awareness help maintain good mental health.",
                visualElement: .stepList([
                    "Practice stress management",
                    "Maintain healthy relationships",
                    "Engage in meaningful activities",
                    "Seek help when needed",
                    "Practice self-compassion"
                ])
            ),
            CoursePage(
                title: "Breaking the Stigma",
                content: "Mental health challenges are common and treatable. Talking openly about mental health helps reduce stigma and encourages others to seek help when needed.\n\nRemember that seeking help for mental health is a sign of strength and self-awareness.",
                visualElement: .tipBox("Mental health is health. Taking care of it is essential for your overall well-being.", .green),
                isLastPage: true
            )
        ],
        category: "Self-Care",
        isPremium: true
    ),
    
    // Spiritual Growth Course (Premium)
    CourseContent(
        courseId: "spiritual_growth",
        title: "Spiritual Growth",
        icon: "sparkles",
        duration: "4 min",
        pages: [
            CoursePage(
                title: "What is Spiritual Growth?",
                content: "Spiritual growth is about developing a deeper understanding of yourself, your purpose, and your connection to something larger than yourself. It's not necessarily about religion - it can involve meditation, nature, art, or personal reflection.\n\nSpiritual growth helps you find meaning, purpose, and inner peace. It can provide comfort during difficult times and enhance your appreciation for life.",
                visualElement: .icon("sparkles", .purple),
                tips: [
                    "Spiritual growth is personal and individual",
                    "It's not necessarily religious",
                    "It helps find meaning and purpose"
                ]
            ),
            CoursePage(
                title: "Exploring Your Spirituality",
                content: "Spiritual growth can take many forms: meditation, prayer, spending time in nature, reading inspiring books, or engaging in creative activities. Explore different practices to find what resonates with you.\n\nRemember that spiritual growth is a personal journey. What works for one person may not work for another. Trust your intuition and follow what feels meaningful to you.",
                visualElement: .stepList([
                    "Explore different practices",
                    "Spend time in nature",
                    "Read inspiring materials",
                    "Practice meditation or prayer",
                    "Engage in creative activities"
                ])
            ),
            CoursePage(
                title: "Integrating Spirituality into Daily Life",
                content: "Look for ways to bring spiritual practices into your daily routine. This might be a morning meditation, gratitude practice, or simply taking moments to appreciate the beauty around you.\n\nRemember that spiritual growth is a lifelong journey. Be patient with yourself and trust the process.",
                visualElement: .tipBox("Spiritual growth is about finding your own path to meaning and connection.", .blue),
                isLastPage: true
            )
        ],
        category: "Self-Care",
        isPremium: true
    ),
    
    // Creative Expression Course (Premium)
    CourseContent(
        courseId: "creative_expression",
        title: "Creative Expression",
        icon: "paintbrush.fill",
        duration: "3 min",
        pages: [
            CoursePage(
                title: "The Power of Creative Expression",
                content: "Creative expression is a powerful way to process emotions, reduce stress, and connect with your authentic self. It doesn't require artistic talent - it's about expressing yourself in whatever way feels natural to you.\n\nCreative activities can include writing, drawing, music, dance, cooking, gardening, or any activity that allows you to express yourself and create something meaningful.",
                visualElement: .icon("paintbrush.fill", .orange)
            ),
            CoursePage(
                title: "Finding Your Creative Outlet",
                content: "Explore different forms of creative expression to find what resonates with you. Don't worry about being 'good' at it - focus on the process and how it makes you feel.\n\nRemember that creativity is a skill that can be developed with practice. Start with simple activities and gradually explore more complex forms of expression.",
                visualElement: .stepList([
                    "Explore different activities",
                    "Focus on the process, not the product",
                    "Practice regularly",
                    "Don't judge your creativity",
                    "Share your creations when comfortable"
                ])
            ),
            CoursePage(
                title: "Making Creativity a Habit",
                content: "Set aside regular time for creative activities, even if it's just a few minutes each day. Create a space that inspires you and remove obstacles that might prevent you from creating.\n\nRemember that creative expression is a form of self-care. It helps you process emotions, reduce stress, and connect with your authentic self.",
                visualElement: .tipBox("Creativity is not about talent - it's about courage to express yourself authentically.", .green),
                isLastPage: true
            )
        ],
        category: "Self-Care",
        isPremium: true
    )
]

// MARK: - Helper Functions

func getCourseContent(for courseId: String) -> CourseContent? {
    return courseContentData.first { $0.courseId == courseId }
}

func getAllCourses() -> [CourseContent] {
    return courseContentData
}

func getCoursesByCategory(_ category: String) -> [CourseContent] {
    return courseContentData.filter { $0.category == category }
}

// MARK: - Course Favorites Service

class CourseFavoritesService: ObservableObject {
    static let shared = CourseFavoritesService()
    
    @Published var favoriteCourseIds: Set<String> = []
    
    private let favoritesKey = "favoriteCourseIds"
    
    private init() {
        loadFavorites()
    }
    
    func toggleFavorite(courseId: String) {
        if favoriteCourseIds.contains(courseId) {
            favoriteCourseIds.remove(courseId)
        } else {
            favoriteCourseIds.insert(courseId)
        }
        saveFavorites()
    }
    
    func isFavorite(courseId: String) -> Bool {
        return favoriteCourseIds.contains(courseId)
    }
    
    func getFavoriteCourses() -> [CourseContent] {
        return courseContentData.filter { favoriteCourseIds.contains($0.courseId) }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteCourseIds = favorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteCourseIds) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
} 