import SwiftUI

struct MeditationView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isPlaying = false
    @State private var timeRemaining = 120 // 2 minutes in seconds
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(tool.category.color)
            
            Text("Guided Meditation")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(themeManager.colors.text)
            
            Text("Find a comfortable position and focus on your breath")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Timer display
            Text(timeString(from: timeRemaining))
                .font(.custom("Poppins-Bold", size: 48))
                .foregroundColor(themeManager.colors.text)
            
            // Play/Pause button
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(tool.category.color)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct GratitudeView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var gratitudeItems: [String] = ["", "", ""]
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundColor(tool.category.color)
            
            Text("Gratitude Practice")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(themeManager.colors.text)
            
            Text("Write down three things you're grateful for")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(0..<3) { index in
                    TextField("Gratitude item \(index + 1)", text: $gratitudeItems[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.custom("Poppins-Regular", size: 16))
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StretchView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStretch = 0
    
    let stretches = [
        "Neck Rolls",
        "Shoulder Shrugs",
        "Wrist Stretches",
        "Ankle Circles",
        "Hip Circles"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.walk")
                .font(.system(size: 48))
                .foregroundColor(tool.category.color)
            
            Text("Quick Stretches")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(themeManager.colors.text)
            
            Text("Gentle stretches to release tension")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(stretches[currentStretch])
                .font(.custom("Poppins-Bold", size: 32))
                .foregroundColor(themeManager.colors.text)
            
            HStack(spacing: 20) {
                Button(action: {
                    if currentStretch > 0 {
                        currentStretch -= 1
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(tool.category.color)
                }
                
                Button(action: {
                    if currentStretch < stretches.count - 1 {
                        currentStretch += 1
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(tool.category.color)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct YogaView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentPose = 0
    
    let poses = [
        "Seated Mountain",
        "Cat-Cow",
        "Seated Twist",
        "Forward Fold",
        "Seated Pigeon"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 48))
                .foregroundColor(tool.category.color)
            
            Text("Desk Yoga")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(themeManager.colors.text)
            
            Text("Gentle yoga poses you can do at your desk")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(poses[currentPose])
                .font(.custom("Poppins-Bold", size: 32))
                .foregroundColor(themeManager.colors.text)
            
            HStack(spacing: 20) {
                Button(action: {
                    if currentPose > 0 {
                        currentPose -= 1
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(tool.category.color)
                }
                
                Button(action: {
                    if currentPose < poses.count - 1 {
                        currentPose += 1
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(tool.category.color)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BodyScanView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStep = 0
    
    let bodyParts = [
        "Head and Face",
        "Neck and Shoulders",
        "Arms and Hands",
        "Chest and Back",
        "Hips and Pelvis",
        "Legs and Feet"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.stand")
                .font(.system(size: 48))
                .foregroundColor(tool.category.color)
            
            Text("Body Scan")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(themeManager.colors.text)
            
            Text("Progressive relaxation through body awareness")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(bodyParts[currentStep])
                .font(.custom("Poppins-Bold", size: 32))
                .foregroundColor(themeManager.colors.text)
            
            Text("Notice any tension and consciously release it")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button(action: {
                    if currentStep > 0 {
                        currentStep -= 1
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(tool.category.color)
                }
                
                Button(action: {
                    if currentStep < bodyParts.count - 1 {
                        currentStep += 1
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(tool.category.color)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 