import SwiftUI

/// A view component that displays a confetti animation
struct IOSConfettiView: View {
    let trigger: Bool
    let colors: [Color]
    let count: Int
    @State private var confettiIDs: [UUID] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiIDs, id: \.self) { id in
                IOSConfettiParticle(color: colors.randomElement() ?? .red)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { newValue in
            if newValue {
                confettiIDs = (0..<count).map { _ in UUID() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    confettiIDs = []
                }
            }
        }
    }
}

/// A single confetti particle that animates across the screen
struct IOSConfettiParticle: View {
    let color: Color
    @State private var x: CGFloat = .zero
    @State private var y: CGFloat = -200
    @State private var angle: Double = .zero
    @State private var size: CGSize = .zero
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .cornerRadius(3)
            .rotationEffect(.degrees(angle))
            .position(x: x, y: y)
            .onAppear {
                let screenWidth = UIScreen.main.bounds.width
                x = CGFloat.random(in: -10...screenWidth)
                size = CGSize(width: CGFloat.random(in: 8...14), height: CGFloat.random(in: 16...22))
                angle = Double.random(in: 0...360)
                let fallDuration = Double.random(in: 1.3...1.8)
                let delay = Double.random(in: 0...0.25)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.linear(duration: fallDuration)) {
                        y = UIScreen.main.bounds.height + 80
                        angle += Double.random(in: 90...360)
                    }
                }
            }
    }
}

#Preview {
    IOSConfettiView(
        trigger: true,
        colors: [.red, .blue, .green, .yellow, .purple],
        count: 50
    )
} 