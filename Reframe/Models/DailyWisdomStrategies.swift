import Foundation

public struct DailyBoostStrategy: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

public let dailyBoostStrategies: [DailyBoostStrategy] = [
    DailyBoostStrategy(title: "Ground Yourself", description: "To calm your mind, bring your focus back to the present. Notice the connection between your body and the ground beneath you."),
    DailyBoostStrategy(title: "Set Boundaries Today", description: "Protect your energy by saying no to what drains you. You deserve space for what matters."),
    DailyBoostStrategy(title: "Breathe Deeply", description: "Take a slow, deep breath. Let it out gently. Repeat three times to reset your mind and body."),
    DailyBoostStrategy(title: "Practice Gratitude", description: "List three things you're grateful for right now. Let that feeling fill your heart."),
    DailyBoostStrategy(title: "Move Your Body", description: "Stretch, walk, or dance for a minute. Movement helps release tension and boost your mood."),
    DailyBoostStrategy(title: "Embrace Imperfection", description: "You don't have to be perfect. Progress is more important than perfection."),
    DailyBoostStrategy(title: "Connect with Nature", description: "Step outside, feel the air, notice the sky. Nature grounds and refreshes your spirit."),
    DailyBoostStrategy(title: "Check In With Yourself", description: "Pause and ask: How am I feeling right now? Honor your emotions without judgment."),
    DailyBoostStrategy(title: "Visualize Success", description: "Picture yourself achieving a goal. Let that vision motivate your next step."),
    DailyBoostStrategy(title: "Let Go of What You Can't Control", description: "Focus on what's within your power. Release the rest with a gentle exhale."),
    DailyBoostStrategy(title: "Speak Kindly to Yourself", description: "Replace self-criticism with encouragement. You are worthy of compassion."),
    DailyBoostStrategy(title: "Take a Mindful Break", description: "Close your eyes for 30 seconds. Notice your breath. Return to your day with clarity."),
    DailyBoostStrategy(title: "Celebrate Small Wins", description: "Acknowledge even tiny steps forward. Every bit of progress counts."),
    DailyBoostStrategy(title: "Ask for Help", description: "You don't have to do it all alone. Reaching out is a sign of strength."),
    DailyBoostStrategy(title: "Declutter Your Space", description: "Tidy up one small area. A clear space can help clear your mind."),
    DailyBoostStrategy(title: "Practice Self-Compassion", description: "Treat yourself as you would a dear friend—gently and with understanding."),
    DailyBoostStrategy(title: "Hydrate Well", description: "Drink a glass of water. Refresh your body and mind."),
    DailyBoostStrategy(title: "Limit Screen Time", description: "Take a break from devices. Let your mind rest and reset."),
    DailyBoostStrategy(title: "Reflect on Your Values", description: "What matters most to you? Let your actions today align with your values."),
    DailyBoostStrategy(title: "Forgive Yourself", description: "Release guilt over past mistakes. Growth comes from learning, not perfection."),
    DailyBoostStrategy(title: "Laugh Today", description: "Find something that makes you smile or laugh. Joy is powerful medicine."),
    DailyBoostStrategy(title: "Listen to Your Body", description: "Rest if you're tired. Move if you're restless. Trust your body's signals."),
    DailyBoostStrategy(title: "Do One Thing at a Time", description: "Focus on a single task. Let go of multitasking for a moment of peace."),
    DailyBoostStrategy(title: "Practice Patience", description: "Growth takes time. Be gentle with yourself as you move forward."),
    DailyBoostStrategy(title: "Notice Beauty Around You", description: "Pause and appreciate something beautiful—big or small—right now."),
    DailyBoostStrategy(title: "Let Yourself Rest", description: "Rest is productive. Give yourself permission to recharge."),
    DailyBoostStrategy(title: "Express Yourself Creatively", description: "Draw, write, sing, or dance. Creativity is a form of self-care."),
    DailyBoostStrategy(title: "Reconnect with a Friend", description: "Send a message or call someone you care about. Connection heals."),
    DailyBoostStrategy(title: "Accept What Is", description: "Meet this moment as it is, without resistance. Acceptance brings peace."),
    DailyBoostStrategy(title: "Trust Your Journey", description: "You are exactly where you need to be. Trust the process of your growth.")
] 