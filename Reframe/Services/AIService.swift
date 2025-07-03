import Foundation
import OpenAI
import Network

// Add response types
struct ModelsResponse: Codable {
    let data: [Model]
}

struct Model: Codable {
    let id: String
    let object: String
    let created: Int
    let owned_by: String
}

struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finish_reason: String?
}

struct Message: Codable {
    let role: String
    let content: String
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

enum ThoughtClassification {
    case negative
    case positive
    case nonsense
}

enum AIServiceError: Error {
    case invalidResponse
    case classificationFailed
    case reframeFailed
    case networkError(Error)
    case invalidAPIKey
    case rateLimitExceeded
    case timeout
    case invalidRequest
    case paymentRequired
    case noInternetConnection
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from AI service"
        case .classificationFailed:
            return "Failed to classify the thought"
        case .reframeFailed:
            return "Failed to generate a reframe"
        case .networkError(let error):
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return "No internet connection. Please check your network and try again."
                case .networkConnectionLost:
                    return "Network connection was lost. Please try again."
                case .timedOut:
                    return "Request timed out. Please try again."
                default:
                    return "Network error: \(error.localizedDescription)"
                }
            }
            return "Network error: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Invalid API key configuration"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again in a few moments."
        case .timeout:
            return "Request timed out. Please try again."
        case .invalidRequest:
            return "Invalid request to AI service"
        case .paymentRequired:
            return "API key requires payment setup. Please check your OpenAI account."
        case .noInternetConnection:
            return "No internet connection available. Please check your network settings."
        }
    }
}

class AIService {
    static let shared = AIService()
    private var openAI: OpenAI?
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0
    private let timeout: TimeInterval = 30.0
    private let monitor = NWPathMonitor()
    private var isConnected = false
    private let session: URLSession
    
    private init() {
        // Configure URLSession with basic settings
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        config.waitsForConnectivity = true
        config.httpShouldUsePipelining = false
        config.httpMaximumConnectionsPerHost = 1
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        // Disable modern protocols
        config.connectionProxyDictionary = [
            kCFProxyHostNameKey: "api.openai.com",
            kCFProxyPortNumberKey: 443,
            kCFProxyTypeKey: kCFProxyTypeHTTPS
        ]
        
        // Create custom session with basic delegate
        let delegate = BasicURLSessionDelegate()
        session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        
        setupNetworkMonitoring()
        // Initialize OpenAI with the API key
        openAI = OpenAI(apiToken: Config.openAIApiKey)
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: DispatchQueue.global())
    }
    
    private func makeRequest<T: Codable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.networkError(NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
        }
        
        // Response received
        
        if httpResponse.statusCode == 401 {
            throw AIServiceError.invalidAPIKey
        } else if httpResponse.statusCode == 402 {
            throw AIServiceError.paymentRequired
        } else if httpResponse.statusCode != 200 {
            throw AIServiceError.networkError(NSError(domain: "AIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error: \(httpResponse.statusCode)"]))
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func checkConnectivity() async throws {
        guard isConnected else {
            throw AIServiceError.noInternetConnection
        }
        
        // Test connection to OpenAI API
        let testURL = URL(string: "https://api.openai.com/v1/models")!
        var request = URLRequest(url: testURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Config.openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let response: ModelsResponse = try await makeRequest(request)
        // Successfully connected to OpenAI API
    }
    
    private func performWithRetry<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                // Check connectivity before each attempt
                try await checkConnectivity()
                
                return try await withTimeout(seconds: timeout, operation: operation)
            } catch let error as URLError {
                lastError = error
                
                // Handle specific network errors
                switch error.code {
                case .networkConnectionLost, .notConnectedToInternet, .timedOut:
                    if attempt < maxRetries {
                        // Exponential backoff with jitter
                        let baseDelay = retryDelay * pow(2.0, Double(attempt - 1))
                        let jitter = Double.random(in: 0...0.3) * baseDelay
                        let delay = baseDelay + jitter
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                default:
                    throw AIServiceError.networkError(error)
                }
            } catch {
                throw error
            }
        }
        
        if let lastError = lastError {
            throw AIServiceError.networkError(lastError)
        } else {
            throw AIServiceError.networkError(NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
        }
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                let result: T = try await operation()
                return result
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw AIServiceError.timeout
            }
            
            guard let result = try await group.next() else {
                throw AIServiceError.timeout
            }
            group.cancelAll()
            return result
        }
    }
    
    // MARK: - Classification
    
    func classifyThought(_ thought: String) async throws -> ThoughtClassification {
        guard let openAI = openAI else {
            throw AIServiceError.invalidAPIKey
        }
        let prompt = """
        Classify the following thought into one of these categories:
        - negative: A negative or challenging thought that needs reframing
        - positive: A positive or neutral thought that doesn't need reframing
        - nonsense: Not a real thought or unclear meaning
        
        Thought: "\(thought)"
        
        Respond with ONLY one word: negative, positive, or nonsense
        """
        
        return try await performWithRetry { [self] in
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.openAIApiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "system", "content": "You are a thought classification system. Respond with ONLY one word."],
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": 10,
                "temperature": 0.1
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let response: ChatCompletionResponse = try await self.makeRequest(request)
            
            guard let classification = response.choices.first?.message.content.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                throw AIServiceError.classificationFailed
            }
            switch classification {
            case "negative":
                return .negative
            case "positive":
                return .positive
            case "nonsense":
                return .nonsense
            default:
                throw AIServiceError.classificationFailed
            }
        }
    }
    
    // MARK: - Reframe Generation
    
    func generateReframe(for thought: String) async throws -> String {
        guard let openAI = openAI else {
            throw AIServiceError.invalidAPIKey
        }
        
        let prompt = """
        Reframe the following negative thought into a more positive and constructive perspective. 
        The reframe should be:
        1. Empathetic and understanding
        2. Realistic and practical
        3. Focused on growth and possibility
        4. Written in first person
        5. No more than 2 sentences
        
        Original thought: "\(thought)"
        
        Provide ONLY the reframed thought, no additional text.
        """
        
        return try await performWithRetry { [self] in
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.openAIApiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "system", "content": "You are a compassionate thought reframing assistant. Provide ONLY the reframed thought."],
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": 100,
                "temperature": 0.7
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let response: ChatCompletionResponse = try await self.makeRequest(request)
            
            guard let reframe = response.choices.first?.message.content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                throw AIServiceError.reframeFailed
            }
            
            return reframe
        }
    }
    
    // MARK: - Affirmation Generation
    
    func generateAffirmation(for thought: String) async throws -> String {
        guard let openAI = openAI else {
            throw AIServiceError.invalidAPIKey
        }
        
        let prompt = """
        Create a warm, personalized response to this positive thought.
        The response should be:
        1. Start with a warm exclamation (e.g., "That's wonderful!", "How amazing!", "I'm so happy to hear that!")
        2. Follow with a personalized, contextual response that:
           - Relates directly to what they shared
           - Acknowledges their achievement or positive feeling
           - Offers encouragement or insight about their specific situation
        3. Keep it to 2-3 sentences maximum
        4. Be warm and supportive, like a caring friend
        
        Thought: "\(thought)"
        
        Example responses:
        - "That's wonderful! Your dedication to studying really paid off - this is proof that your hard work makes a difference!"
        - "How amazing! You're building such a strong foundation for your future, one step at a time."
        - "I'm so happy to hear that! Your positive attitude is creating these great moments in your life."
        
        Provide ONLY the response, no additional text.
        """
        
        return try await performWithRetry { [self] in
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.openAIApiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "system", "content": "You are a warm and supportive friend who celebrates achievements and positive moments with personalized, contextual responses."],
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": 100,
                "temperature": 0.8
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let response: ChatCompletionResponse = try await self.makeRequest(request)
            
            guard let affirmation = response.choices.first?.message.content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                throw AIServiceError.reframeFailed
            }
            
            return affirmation
        }
    }
    
    // MARK: - Coach Response Generation
    
    enum CoachInputType: String {
        case venting = "Venting / Emotional Expression"
        case advice = "Seeking Advice"
        case question = "General Question"
        case unclear = "Unclear / Nonsense"
    }
    
    func classifyCoachInput(_ input: String) async throws -> CoachInputType {
        guard let openAI = openAI else {
            throw AIServiceError.invalidAPIKey
        }
        
        let prompt = """
        Classify the following user input into one of these categories:
        - Venting / Emotional Expression: User is expressing emotions, sharing feelings, or describing a situation they're struggling with
        - Seeking Advice: User is asking for guidance, help with a situation, or looking for specific solutions
        - General Question: User is asking a straightforward question about mental health, coping strategies, or personal growth
        - Unclear / Nonsense: Input is unclear, doesn't make sense, or lacks context
        
        User input: "\(input)"
        
        Respond with ONLY one of these exact phrases:
        - "Venting / Emotional Expression"
        - "Seeking Advice"
        - "General Question"
        - "Unclear / Nonsense"
        """
        
        // Classification prompt prepared
        
        return try await performWithRetry { [self] in
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.openAIApiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "system", "content": "You are a classification system. Respond with ONLY one of the specified phrases."],
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": 20,
                "temperature": 0.1
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let response: ChatCompletionResponse = try await self.makeRequest(request)
            
            guard let classification = response.choices.first?.message.content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                throw AIServiceError.classificationFailed
            }
            
            // Remove any extra quotes or whitespace
            let cleanClassification = classification.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch cleanClassification {
            case "Venting / Emotional Expression":
                return .venting
            case "Seeking Advice":
                return .advice
            case "General Question":
                return .question
            case "Unclear / Nonsense":
                return .unclear
            default:
                throw AIServiceError.classificationFailed
            }
        }
    }
    
    func generateCoachResponse(content: String, coach: Coach) async throws -> String {
        guard let openAI = openAI else {
            throw AIServiceError.invalidAPIKey
        }
        
        // First classify the input
        let inputType = try await classifyCoachInput(content)
        
        // If the input is unclear, return a fallback message
        if inputType == .unclear {
            return """
            I notice your message might be a bit unclear. Could you help me understand what you're going through? Feel free to share more details about your situation, and I'll be here to support you.
            """
        }
        
        let prompt = """
        You are \(coach.name) \(coach.emoji), an AI mental health coach. Your tone is \(coach.toneSummary). Your specialties include: \(coach.specialties.joined(separator: ", ")). Speak like a real, thoughtful human.

        User's message: "\(content)"

        Classify this as: \(inputType.rawValue)

        CRITICAL INSTRUCTIONS:
        1. DO NOT use any headers, titles, or section markers in your response
        2. DO NOT use phrases like "Energizing, challenge-based validation:" or "Tactical advice, micro-goals, motivational reframes:"
        3. DO NOT use numbers, bullet points, or any form of formatting
        4. DO NOT include any extra text or labels
        5. Respond with ONLY your natural, flowing conversation

        Structure your response in this format, but make it flow naturally like a real conversation:

        1. Start with an intro that captures your tone and style of: "\(coach.introStyle)"
        - DO NOT repeat or copy the intro style directly
        - Instead, create a natural opening that acknowledges the user's specific situation
        - For example, if the intro style is "Mindful acknowledgment of your feelings, gentle invitation to explore" and the user says "I'm feeling overwhelmed with work", you might start with:
          "I hear how work is really taking a toll on you right now. It's completely understandable to feel this way when things pile up."
        - Make it specific to their situation
        - Keep it natural and conversational that flows with the rest of the response
        
        2. Then provide 2-3 sentences of empathy and validation based on the input type:
        - For venting: Acknowledge their feelings and show understanding
        - For advice: Recognize their situation and validate their concerns
        - For questions: Show appreciation for their curiosity
        
        3. Share 2-3 sentences of insight or perspective, incorporating your coaching philosophy: "\(coach.quote)"
        
        4. Include a technique that follows this style: "\(coach.techniqueStyle)"
        - Vary the specific technique while staying within your coaching style
        - Make it relevant to their situation
        - Keep it simple and actionable
        
        5. Suggest a specific, actionable micro-step they can take right now. Make it concrete and doable, like:
        - "Try writing down three things you'd tell a friend in your situation"
        - "Take 2 minutes to write what boundaries you wish you had"
        - "List one small way you could practice self-care today"
        
        6. End with a closing that follows this style: "\(coach.closingStyle)"
        - Use this as a guide for your tone, not as a template to copy
        - Make it feel personal and specific to their situation
        - Keep it encouraging and supportive

        Your response should be a single, flowing conversation that naturally incorporates all these elements. Make it feel like a real person speaking, not a structured document. Keep your response warm and personal. Don't sound like ChatGPT. Focus on being specific to their situation while maintaining your unique coaching style. Vary your language and examples to avoid sounding repetitive or formulaic.

        REMEMBER: Respond with ONLY your natural, flowing conversation. No headers, titles, or extra text.
        """
        
        // Response generation prompt prepared
        
        return try await performWithRetry { [self] in
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.openAIApiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "system", "content": "You are a compassionate mental health coach who provides personalized, supportive responses. Never use headers, titles, or section markers in your responses."],
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": 400,
                "temperature": 0.8
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let response: ChatCompletionResponse = try await self.makeRequest(request)
            
            guard let coachResponse = response.choices.first?.message.content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                throw AIServiceError.reframeFailed
            }
            
            return coachResponse
        }
    }
}

// Basic URLSession delegate to handle connection issues
private class BasicURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Accept all certificates for testing
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
} 