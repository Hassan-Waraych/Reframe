import SwiftUI

struct QuickCalmScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTool: CalmingTool?
    
    private let tools: [CalmingTool] = [
        CalmingTool(
            id: "breath_1",
            title: "Box Breathing",
            description: "A simple breathing technique to help you relax and focus",
            category: .breathing,
            icon: "lungs.fill",
            type: .breathing(inhale: 4, hold: 4, exhale: 4, holdAfter: 4)
        ),
        CalmingTool(
            id: "breath_2",
            title: "Calming Breath",
            description: "4-7-8 breathing pattern for deep relaxation",
            category: .breathing,
            icon: "wind",
            type: .breathing(inhale: 4, hold: 7, exhale: 8, holdAfter: 0)
        ),
        CalmingTool(
            id: "breath_3",
            title: "Deep Breathing",
            description: "5-2-7 pattern for stress relief",
            category: .breathing,
            icon: "leaf.fill",
            type: .breathing(inhale: 5, hold: 2, exhale: 7, holdAfter: 0)
        ),
        CalmingTool(
            id: "ground_1",
            title: "5-4-3-2-1 Grounding",
            description: "Use your senses to stay present and calm",
            category: .grounding,
            icon: "hand.raised.fill",
            type: .grounding
        ),
        CalmingTool(
            id: "mind_1",
            title: "Guided Meditation",
            description: "Find peace through guided meditation",
            category: .mindfulness,
            icon: "brain.head.profile",
            type: .meditation
        ),
        CalmingTool(
            id: "mind_2",
            title: "Gratitude Practice",
            description: "Cultivate positivity through gratitude",
            category: .mindfulness,
            icon: "heart.fill",
            type: .gratitude
        ),
        CalmingTool(
            id: "move_1",
            title: "Quick Stretch",
            description: "Release tension with simple stretches",
            category: .movement,
            icon: "figure.walk",
            type: .stretch
        ),
        CalmingTool(
            id: "move_2",
            title: "Yoga Flow",
            description: "Find balance through gentle yoga",
            category: .movement,
            icon: "figure.mind.and.body",
            type: .yoga
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Quick Calm")
                            .font(.custom("Poppins-Bold", size: 28))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text("Tools to help you find peace in the moment")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Tools Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(tools) { tool in
                            ToolCard(tool: tool)
                                .onTapGesture {
                                    selectedTool = tool
                                }
                        }
                    }
                }
                .padding()
            }
            .background(themeManager.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeManager.colors.text.opacity(0.7))
                    }
                }
            }
            .sheet(item: $selectedTool) { tool in
                ToolDetailView(tool: tool)
            }
        }
    }
}

struct ToolCard: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: tool.icon)
                .font(.system(size: 32))
                .foregroundColor(tool.category.color)
            
            Text(tool.title)
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(themeManager.colors.text)
                .multilineTextAlignment(.center)
            
            Text(tool.description)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(themeManager.colors.surface)
        .cornerRadius(16)
    }
}

struct ToolDetailView: View {
    let tool: CalmingTool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: tool.icon)
                        .font(.system(size: 40))
                        .foregroundColor(tool.category.color)
                    
                    Text(tool.title)
                        .font(.custom("Poppins-Bold", size: 24))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(tool.description)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(themeManager.colors.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.colors.surface)
                .cornerRadius(16)
                
                // Tool Content
                Group {
                    switch tool.type {
                    case .breathing(let inhale, let hold, let exhale, let holdAfter):
                        BreathingExerciseView(
                            tool: tool,
                            inhale: inhale,
                            hold: hold,
                            exhale: exhale,
                            holdAfter: holdAfter
                        )
                    case .grounding:
                        GroundingExerciseView(tool: tool)
                    case .meditation:
                        MeditationView(tool: tool)
                    case .gratitude:
                        GratitudeView(tool: tool)
                    case .stretch:
                        StretchView(tool: tool)
                    case .yoga:
                        YogaView(tool: tool)
                    case .bodyScan:
                        BodyScanView(tool: tool)
                    }
                }
            }
            .padding()
        }
        .background(themeManager.colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.colors.text.opacity(0.7))
                }
            }
        }
    }
} 