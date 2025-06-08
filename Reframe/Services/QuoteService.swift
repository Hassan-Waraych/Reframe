import Foundation
import SwiftUI

class QuoteService: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var currentQuote: Quote?
    @Published var isAnimating = false
    
    private var quoteTimer: Timer?
    private let quoteDisplayDuration: TimeInterval = 10 // 10 seconds
    
    init() {
        loadQuotes()
        startQuoteRotation()
    }
    
    private func loadQuotes() {
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let quoteData = try decoder.decode(QuoteData.self, from: data)
                self.quotes = quoteData.quotes
                self.currentQuote = quotes.randomElement()
                self.isAnimating = true
            } catch {
                print("Error loading quotes: \(error)")
            }
        }
    }
    
    private func startQuoteRotation() {
        // Stop any existing timer
        quoteTimer?.invalidate()
        
        // Create a new timer that fires every 10 seconds
        quoteTimer = Timer.scheduledTimer(withTimeInterval: quoteDisplayDuration, repeats: true) { [weak self] _ in
            self?.rotateQuote()
        }
    }
    
    private func rotateQuote() {
        // Get a random quote that's different from the current one
        var newQuote: Quote?
        repeat {
            newQuote = quotes.randomElement()
        } while newQuote?.id == currentQuote?.id && quotes.count > 1
        
        // Animate the transition
        withAnimation(.easeOut(duration: 0.5)) {
            isAnimating = false
        }
        
        // After the fade out, update the quote and fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.currentQuote = newQuote
            withAnimation(.easeIn(duration: 0.5)) {
                self?.isAnimating = true
            }
        }
    }
    
    deinit {
        quoteTimer?.invalidate()
    }
} 