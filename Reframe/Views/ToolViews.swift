import SwiftUI

struct MeditationView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isPlaying = false
    @State private var timeRemaining = 120 // 2 minutes in seconds
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 32) {
            // Timer and Controls
            VStack(spacing: 24) {
                Text(timeString(from: timeRemaining))
                    .font(.custom("Poppins-Bold", size: 54))
                    .foregroundColor(themeManager.colors.text)
                
                HStack(spacing: 24) {
                    Button(action: {
                        if isPlaying {
                            stopTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(tool.category.color)
                                .frame(width: 96, height: 96)
                                .shadow(color: tool.category.color.opacity(0.25), radius: 16, x: 0, y: 8)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: resetTimer) {
                        ZStack {
                            Circle()
                                .fill(themeManager.colors.surface)
                                .frame(width: 56, height: 56)
                                .shadow(color: themeManager.colors.text.opacity(0.08), radius: 8, x: 0, y: 4)
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(tool.category.color)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(themeManager.colors.surface)
            .cornerRadius(24)
            
            // Simple Instructions
            VStack(spacing: 12) {
                Text("Find Your Center")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundColor(tool.category.color)
                
                Text("Close your eyes and focus on your breath")
                    .font(.custom("Poppins-Regular", size: 17))
                    .foregroundColor(themeManager.colors.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(themeManager.colors.surface.opacity(0.7))
                    .cornerRadius(12)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(themeManager.colors.surface)
            .cornerRadius(16)
        }
        .padding()
        .onDisappear {
            stopTimer()
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func startTimer() {
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        timeRemaining = 120
    }
}

struct GratitudeView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var gratitudeItems: [String] = ["", "", ""]
    @State private var isSubmitted = false
    
    private let prompts = [
        "What made you smile today?",
        "What are you looking forward to?",
        "What's something you're proud of?"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            if isSubmitted {
                completionView
            } else {
                inputView
            }
        }
        .padding()
    }
    
    private var inputView: some View {
        VStack(spacing: 24) {          
            // Input Fields
            VStack(spacing: 20) {
                ForEach(0..<3) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(prompts[index])
                            .font(.custom("Poppins-Medium", size: 16))
                            .foregroundColor(themeManager.colors.text)
                        
                        TextField("Enter your response", text: $gratitudeItems[index])
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text)
                            .padding()
                            .background(themeManager.colors.background)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(themeManager.colors.text.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding()
            .background(themeManager.colors.surface)
            .cornerRadius(16)
            
            // Submit Button
            Button(action: {
                if !gratitudeItems.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                    isSubmitted = true
                }
            }) {
                Text("Submit")
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        gratitudeItems.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ?
                            Color.gray : tool.category.color
                    )
                    .cornerRadius(12)
            }
            .disabled(gratitudeItems.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }))
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(tool.category.color)
            
            Text("Thank You!")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(themeManager.colors.text)
            
            Text("Your gratitude entries have been saved")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(0..<3) { index in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prompts[index])
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text(gratitudeItems[index])
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text.opacity(0.7))
                    }
                }
            }
            .padding()
            .background(themeManager.colors.surface)
            .cornerRadius(16)
            
            Button(action: {
                isSubmitted = false
                gratitudeItems = ["", "", ""]
            }) {
                Text("Start New Entry")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tool.category.color)
                    .cornerRadius(12)
            }
        }
    }
}

struct StretchView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStretch = 0
    @State private var isAnimating = false
    
    let stretches = [
        StretchInfo(
            name: "Neck Rolls",
            description: "Gently roll your neck in a circular motion",
            instructions: [
                "Start with your head in a neutral position",
                "Slowly roll your head to the right",
                "Continue the circle, bringing your head back",
                "Complete 5 rolls in each direction"
            ],
            duration: 30,
            icon: "figure.stand"
        ),
        StretchInfo(
            name: "Shoulder Shrugs",
            description: "Release tension in your shoulders",
            instructions: [
                "Keep your arms relaxed at your sides",
                "Lift your shoulders up towards your ears",
                "Hold for 2-3 seconds",
                "Release and relax",
                "Repeat 8-10 times"
            ],
            duration: 45,
            icon: "figure.arms.open"
        ),
        StretchInfo(
            name: "Wrist Stretches",
            description: "Stretch and flex your wrists",
            instructions: [
                "Extend your arms in front of you",
                "Point your fingers up, palm facing away",
                "Gently pull back on your fingers",
                "Hold for 15-20 seconds",
                "Repeat with fingers pointing down"
            ],
            duration: 40,
            icon: "hand.raised.fill"
        ),
        StretchInfo(
            name: "Ankle Circles",
            description: "Improve ankle mobility",
            instructions: [
                "Sit with your legs extended",
                "Lift one foot off the ground",
                "Rotate your ankle in circles",
                "Complete 10 circles in each direction",
                "Repeat with the other foot"
            ],
            duration: 60,
            icon: "figure.walk"
        ),
        StretchInfo(
            name: "Hip Circles",
            description: "Loosen up your hips",
            instructions: [
                "Stand with feet shoulder-width apart",
                "Place hands on hips",
                "Make circles with your hips",
                "Keep your upper body stable",
                "Complete 8-10 circles each way"
            ],
            duration: 45,
            icon: "figure.mind.and.body"
        )
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: stretches[currentStretch].icon)
                    .font(.system(size: 48))
                    .foregroundColor(tool.category.color)
                    .offset(y: isAnimating ? -10 : 10)
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(stretches[currentStretch].name)
                    .font(.custom("Poppins-Bold", size: 24))
                    .foregroundColor(themeManager.colors.text)
                
                Text(stretches[currentStretch].description)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(themeManager.colors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                Text("How to Perform")
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundColor(themeManager.colors.text)
                
                ForEach(stretches[currentStretch].instructions, id: \.self) { instruction in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(tool.category.color)
                            .padding(.top, 8)
                        
                        Text(instruction)
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text)
                    }
                }
            }
            .padding()
            .background(themeManager.colors.surface)
            .cornerRadius(16)
            
            // Timer
            Text("\(stretches[currentStretch].duration) seconds")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(tool.category.color)
            
            // Navigation
            HStack(spacing: 20) {
                Button(action: {
                    if currentStretch > 0 {
                        currentStretch -= 1
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(currentStretch > 0 ? tool.category.color : .gray)
                }
                .disabled(currentStretch == 0)
                
                Button(action: {
                    if currentStretch < stretches.count - 1 {
                        currentStretch += 1
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(currentStretch < stretches.count - 1 ? tool.category.color : .gray)
                }
                .disabled(currentStretch == stretches.count - 1)
            }
        }
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
}

struct YogaView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentPose = 0
    @State private var isAnimating = false
    
    let poses = [
        YogaPose(
            name: "Seated Mountain",
            description: "Find your center and ground yourself",
            instructions: [
                "Sit cross-legged on the floor or in a chair",
                "Lengthen your spine, crown reaching up",
                "Place hands on knees, palms up or down",
                "Close your eyes and breathe deeply",
                "Hold for 1-2 minutes"
            ],
            duration: 60,
            icon: "figure.mind.and.body"
        ),
        YogaPose(
            name: "Cat-Cow",
            description: "Gentle spinal movement",
            instructions: [
                "Come to hands and knees",
                "Inhale: arch back, lift head (Cow)",
                "Exhale: round spine, tuck chin (Cat)",
                "Move with your breath",
                "Repeat 8-10 times"
            ],
            duration: 90,
            icon: "arrow.up.arrow.down.circle"
        ),
        YogaPose(
            name: "Seated Twist",
            description: "Release tension in your spine",
            instructions: [
                "Sit with legs extended",
                "Bend right knee, foot outside left thigh",
                "Twist torso to the right",
                "Place left hand on right knee",
                "Hold for 30 seconds each side"
            ],
            duration: 60,
            icon: "arrow.triangle.2.circlepath"
        ),
        YogaPose(
            name: "Forward Fold",
            description: "Calm the mind and stretch the back",
            instructions: [
                "Stand with feet hip-width apart",
                "Hinge at hips, fold forward",
                "Let head and arms hang heavy",
                "Bend knees slightly if needed",
                "Hold for 1 minute"
            ],
            duration: 60,
            icon: "figure.cooldown"
        ),
        YogaPose(
            name: "Seated Pigeon",
            description: "Open the hips and release tension",
            instructions: [
                "Sit with legs extended",
                "Bend right knee, ankle over left thigh",
                "Keep spine long, fold forward",
                "Hold for 1-2 minutes each side",
                "Breathe deeply"
            ],
            duration: 120,
            icon: "figure.seated.side"
        )
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: poses[currentPose].icon)
                    .font(.system(size: 48))
                    .foregroundColor(tool.category.color)
                    .offset(y: isAnimating ? -10 : 10)
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(poses[currentPose].name)
                    .font(.custom("Poppins-Bold", size: 24))
                    .foregroundColor(themeManager.colors.text)
                
                Text(poses[currentPose].description)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(themeManager.colors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                Text("How to Perform")
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundColor(themeManager.colors.text)
                
                ForEach(poses[currentPose].instructions, id: \.self) { instruction in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(tool.category.color)
                            .padding(.top, 8)
                        
                        Text(instruction)
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text)
                    }
                }
            }
            .padding()
            .background(themeManager.colors.surface)
            .cornerRadius(16)
            
            // Timer
            Text("\(poses[currentPose].duration) seconds")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(tool.category.color)
            
            // Navigation
            HStack(spacing: 20) {
                Button(action: {
                    if currentPose > 0 {
                        currentPose -= 1
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(currentPose > 0 ? tool.category.color : .gray)
                }
                .disabled(currentPose == 0)
                
                Button(action: {
                    if currentPose < poses.count - 1 {
                        currentPose += 1
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(currentPose < poses.count - 1 ? tool.category.color : .gray)
                }
                .disabled(currentPose == poses.count - 1)
            }
        }
        .padding()
        .onAppear {
            isAnimating = true
        }
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

// Supporting Types
struct StretchInfo {
    let name: String
    let description: String
    let instructions: [String]
    let duration: Int
    let icon: String
}

struct YogaPose {
    let name: String
    let description: String
    let instructions: [String]
    let duration: Int
    let icon: String
} 