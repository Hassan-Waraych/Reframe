import SwiftUI

struct BreathingExerciseView: View {
    let tool: CalmingTool
    let inhale: Int
    let hold: Int
    let exhale: Int
    let holdAfter: Int
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isActive = false
    
    private var totalDuration: Int {
        inhale + hold + exhale + holdAfter
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                Text(tool.title)
                    .font(.custom("Poppins-Bold", size: 28))
                    .foregroundColor(themeManager.colors.text)
                
                Text(tool.description)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(themeManager.colors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Breathing Circle
            ZStack {
                // Background Circle
                Circle()
                    .stroke(tool.category.color.opacity(0.2), lineWidth: 4)
                    .frame(width: 240, height: 240)
                
                // Progress Circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(tool.category.color, lineWidth: 4)
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                
                // Breathing Circle
                Circle()
                    .fill(tool.category.color.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .scaleEffect(breathingScale)
                
                // Phase Text
                VStack(spacing: 12) {
                    if !isActive {
                        Text("Tap to Start")
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundColor(tool.category.color)
                            .opacity(0.8)
                    } else {
                        Text(phaseText)
                            .font(.custom("Poppins-Bold", size: 28))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text("\(remainingTime)s")
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundColor(themeManager.colors.text.opacity(0.7))
                    }
                }
            }
            .onTapGesture {
                toggleBreathing()
            }
            .contentShape(Circle())
            
            // Pattern Info
            if isActive {
                HStack(spacing: 24) {
                    PatternInfoItem(title: "Inhale", value: "\(inhale)s", color: tool.category.color)
                    PatternInfoItem(title: "Hold", value: "\(hold)s", color: tool.category.color)
                    PatternInfoItem(title: "Exhale", value: "\(exhale)s", color: tool.category.color)
                    if holdAfter > 0 {
                        PatternInfoItem(title: "Hold", value: "\(holdAfter)s", color: tool.category.color)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .onDisappear {
            stopBreathing()
        }
    }
    
    private var breathingScale: CGFloat {
        switch currentPhase {
        case .inhale:
            return 1 + (progress * 0.25) // Scale from 1.0 to 1.25
        case .hold:
            return 1.25 // Keep at max size
        case .exhale:
            return 1.25 - (progress * 0.25) // Scale from 1.25 to 1.0
        case .holdAfter:
            return 1.0 // Keep at min size
        }
    }
    
    private var phaseText: String {
        switch currentPhase {
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        case .holdAfter: return "Hold"
        }
    }
    
    private var remainingTime: Int {
        switch currentPhase {
        case .inhale: return Int((1 - progress) * CGFloat(inhale))
        case .hold: return Int((1 - progress) * CGFloat(hold))
        case .exhale: return Int((1 - progress) * CGFloat(exhale))
        case .holdAfter: return Int((1 - progress) * CGFloat(holdAfter))
        }
    }
    
    private func toggleBreathing() {
        if isActive {
            stopBreathing()
        } else {
            startBreathing()
        }
    }
    
    private func startBreathing() {
        isActive = true
        progress = 0
        currentPhase = .inhale
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateBreathing()
        }
    }
    
    private func stopBreathing() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func updateBreathing() {
        let phaseDuration: CGFloat
        switch currentPhase {
        case .inhale: phaseDuration = CGFloat(inhale)
        case .hold: phaseDuration = CGFloat(hold)
        case .exhale: phaseDuration = CGFloat(exhale)
        case .holdAfter: phaseDuration = CGFloat(holdAfter)
        }
        
        progress += 0.016 / phaseDuration
        
        if progress >= 1 {
            progress = 0
            switch currentPhase {
            case .inhale: currentPhase = .hold
            case .hold: currentPhase = .exhale
            case .exhale: currentPhase = .holdAfter
            case .holdAfter: currentPhase = .inhale
            }
        }
    }
}

struct PatternInfoItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(color)
        }
    }
}

enum BreathingPhase {
    case inhale
    case hold
    case exhale
    case holdAfter
} 