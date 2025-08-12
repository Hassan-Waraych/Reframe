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