import SwiftUI

struct GroundingExerciseView: View {
    let tool: CalmingTool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStep = 0
    @State private var responses: [String] = Array(repeating: "", count: 5)
    @State private var isCompleted = false
    
    private let steps = [
        (icon: "eye.fill", text: "Name 5 things you can see"),
        (icon: "hand.tap.fill", text: "Name 4 things you can touch"),
        (icon: "ear.fill", text: "Name 3 things you can hear"),
        (icon: "nose.fill", text: "Name 2 things you can smell"),
        (icon: "mouth.fill", text: "Name 1 thing you can taste")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            if isCompleted {
                completionView
            } else {
                exerciseView
            }
        }
        .padding()
        .background(themeManager.colors.surface)
        .cornerRadius(16)
    }
    
    private var exerciseView: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index <= currentStep ? tool.category.color : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Step content
            VStack(spacing: 16) {
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 40))
                    .foregroundColor(tool.category.color)
                
                Text(steps[currentStep].text)
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundColor(themeManager.colors.text)
                    .multilineTextAlignment(.center)
                
                TextField("Type your response...", text: $responses[currentStep])
                    .font(.custom("Poppins-Regular", size: 16))
                    .padding()
                    .background(themeManager.colors.background)
                    .cornerRadius(12)
            }
            
            // Navigation buttons
            HStack(spacing: 16) {
                if currentStep > 0 {
                    Button(action: { currentStep -= 1 }) {
                        Text("Previous")
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(themeManager.colors.text)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.colors.background)
                            .cornerRadius(12)
                    }
                }
                
                Button(action: {
                    if currentStep < 4 {
                        currentStep += 1
                    } else {
                        isCompleted = true
                    }
                }) {
                    Text(currentStep < 4 ? "Next" : "Complete")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(responses[currentStep].isEmpty ? Color.gray : tool.category.color)
                        .cornerRadius(12)
                }
                .disabled(responses[currentStep].isEmpty)
            }
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(tool.category.color)
            
            Text("Exercise Complete!")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(themeManager.colors.text)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(0..<5) { index in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(steps[index].text)
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(themeManager.colors.text)
                        
                        Text(responses[index])
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(themeManager.colors.text.opacity(0.7))
                    }
                }
            }
            .padding()
            .background(themeManager.colors.background)
            .cornerRadius(16)
            
            Button(action: resetExercise) {
                Text("Start Over")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tool.category.color)
                    .cornerRadius(12)
            }
        }
    }
    
    private func resetExercise() {
        currentStep = 0
        responses = Array(repeating: "", count: 5)
        isCompleted = false
    }
} 