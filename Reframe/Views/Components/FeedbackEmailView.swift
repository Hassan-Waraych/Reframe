import SwiftUI
import MessageUI

struct FeedbackEmailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var showMailView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var currentSubject = ""
    @State private var currentMessageBody = ""
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    private var deviceInfo: String {
        let device = UIDevice.current
        return "\(device.model) - iOS \(device.systemVersion)"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 48))
                        .foregroundColor(themeManager.colors.primary)
                    
                    Text("Send Feedback")
                        .font(.custom("Quicksand-Bold", size: 28))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text("We'd love to hear from you! Share your thoughts, suggestions, or report any issues you've encountered.")
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(themeManager.colors.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Feedback Options
                VStack(spacing: 16) {
                    FeedbackOptionCard(
                        icon: "lightbulb.fill",
                        title: "Feature Request",
                        description: "Suggest new features or improvements",
                        color: themeManager.colors.primary
                    ) {
                        composeEmail(subject: "Feature Request - Reframe App", category: "Feature Request")
                    }
                    
                    FeedbackOptionCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Bug Report",
                        description: "Report issues or unexpected behavior",
                        color: themeManager.colors.error
                    ) {
                        composeEmail(subject: "Bug Report - Reframe App", category: "Bug Report")
                    }
                    
                    FeedbackOptionCard(
                        icon: "heart.fill",
                        title: "General Feedback",
                        description: "Share your thoughts and experiences",
                        color: themeManager.colors.secondary
                    ) {
                        composeEmail(subject: "Feedback - Reframe App", category: "General Feedback")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Footer Info
                VStack(spacing: 8) {
                    Text("App Version \(appVersion) (\(buildNumber))")
                        .font(.custom("Nunito-Regular", size: 14))
                        .foregroundColor(themeManager.colors.textLight)
                    
                    Text(deviceInfo)
                        .font(.custom("Nunito-Regular", size: 14))
                        .foregroundColor(themeManager.colors.textLight)
                }
                .padding(.bottom, 20)
            }
            .background(themeManager.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Nunito-Medium", size: 16))
                    .foregroundColor(themeManager.colors.primary)
                }
            }
        }
        .sheet(isPresented: $showMailView) {
            MailView(
                toRecipients: ["feedbackreframe@gmail.com"],
                subject: currentSubject,
                messageBody: currentMessageBody,
                isPresented: $showMailView,
                result: { result in
                    handleMailResult(result)
                }
            )
        }
        .alert("Email", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func composeEmail(subject: String, category: String) {
        currentSubject = subject
        currentMessageBody = """
        Hi Reframe Team,
        
        I'm reaching out regarding: \(category)
        
        [Please describe your feedback, suggestion, or issue here]
        
        ---
        App Version: \(appVersion) (\(buildNumber))
        Device: \(deviceInfo)
        Category: \(category)
        ---
        
        Thank you!
        """
        
        showMailView = true
    }
    
    private func handleMailResult(_ result: Result<MFMailComposeResult, Error>) {
        switch result {
        case .success(let mailResult):
            switch mailResult {
            case .sent:
                alertMessage = "Thank you for your feedback! We'll get back to you soon."
            case .saved:
                alertMessage = "Your feedback has been saved as a draft."
            case .cancelled:
                alertMessage = "Email cancelled."
            case .failed:
                alertMessage = "Failed to send email. Please try again."
            @unknown default:
                alertMessage = "Email action completed."
            }
        case .failure(let error):
            alertMessage = "Error: \(error.localizedDescription)"
        }
        showAlert = true
    }
}

struct FeedbackOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Quicksand-SemiBold", size: 18))
                        .foregroundColor(themeManager.colors.text)
                    
                    Text(description)
                        .font(.custom("Nunito-Regular", size: 14))
                        .foregroundColor(themeManager.colors.textLight)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.colors.textLight)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(20)
            .background(themeManager.colors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Mail View Wrapper
struct MailView: UIViewControllerRepresentable {
    let toRecipients: [String]
    let subject: String
    let messageBody: String
    @Binding var isPresented: Bool
    let result: (Result<MFMailComposeResult, Error>) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(toRecipients)
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isPresented = false
            
            if let error = error {
                parent.result(.failure(error))
            } else {
                parent.result(.success(result))
            }
        }
    }
}

#Preview {
    FeedbackEmailView()
        .environmentObject(ThemeManager())
} 