import SwiftUI
import UIKit

struct CelebrationView: View {
    @Binding var isPresented: Bool
    let habitName: String
    let streak: Int
    let onComplete: () -> Void

    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Celebration Card
            VStack(spacing: 24) {
                // Animated Checkmark
                ZStack {
                    Circle()
                        .fill(Color(hex: "34C759").opacity(0.2))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(Color(hex: "34C759"))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)

                VStack(spacing: 8) {
                    Text("Completed!")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text(habitName)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    if streak > 0 {
                        HStack(spacing: 4) {
                            Text(streak >= 7 ? "🔥🔥" : "🔥")
                            Text("\(streak) day streak!")
                                .font(.subheadline.bold())
                            Text(streak >= 7 ? "🔥🔥" : "🔥")
                        }
                        .foregroundColor(.orange)
                    }
                }

                Button("Continue") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color(hex: "34C759"))
                .cornerRadius(25)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "1E1E1E"))
                    .shadow(color: .black.opacity(0.3), radius: 20)
            )

            // Confetti Overlay
            ForEach(confettiPieces) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onAppear {
            triggerHaptic()
            generateConfetti()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private func generateConfetti() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink, .purple]
        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                color: colors.randomElement()!,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -100...0),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.0)
            )
            confettiPieces.append(piece)

            withAnimation(.easeOut(duration: Double.random(in: 2...4))) {
                if let index = confettiPieces.firstIndex(where: { $0.id == i }) {
                    confettiPieces[index].y = UIScreen.main.bounds.height + 100
                    confettiPieces[index].rotation += Double.random(in: 360...720)
                }
            }
        }
    }

    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func dismiss() {
        withAnimation {
            isPresented = false
        }
        onComplete()
    }
}

struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var scale: CGFloat
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10 * piece.scale, height: 10 * piece.scale)
            .rotationEffect(.degrees(piece.rotation))
            .position(x: piece.x, y: piece.y)
    }
}

struct StreakFireView: View {
    let streak: Int
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if streak >= 7 {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                        .shadow(color: .orange, radius: 10)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                } else {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                }
            }

            Text("\(streak)")
                .font(.caption.bold())
                .foregroundColor(.orange)
        }
        .onAppear {
            if streak >= 7 {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    CelebrationView(
        isPresented: .constant(true),
        habitName: "Morning Run",
        streak: 7,
        onComplete: {}
    )
}