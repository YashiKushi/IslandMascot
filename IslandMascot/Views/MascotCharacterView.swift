import SwiftUI
import UIKit

struct MascotCharacterView: View {
    var mascot: Mascot
    var size: CGFloat = 140
    @State private var isBouncing = false
    @State private var isSleepingWiggle = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Облачко мыслей
            Text(mascot.thoughtBubble)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                )
                .overlay(
                    // Хвостик облачка
                    Triangle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(width: 12, height: 8)
                        .rotationEffect(.degrees(180))
                        .offset(y: 18),
                    alignment: .bottom
                )
                .padding(.bottom, 6)
                .transition(.scale.combined(with: .opacity))
                .id(mascot.thoughtBubble) // Анимация при смене фразы
            
            // Персонаж
            ZStack {
                // Мягкое свечение вокруг
                Circle()
                    .fill(moodGlowColor.opacity(0.2))
                    .frame(width: size + 30, height: size + 30)
                    .blur(radius: 12)
                
                // Тень питомца
                Ellipse()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: size * 0.7, height: 16)
                    .offset(y: size * 0.45)
                    .scaleEffect(isBouncing ? 0.85 : 1.0)
                
                // Сам маскот
                VStack(spacing: -10) {
                    Text(mascot.mood.faceEmoji)
                        .font(.system(size: size * 0.75))
                    
                    if mascot.currentActivity != .idle {
                        Text(mascot.currentActivity.emoji)
                            .font(.system(size: size * 0.35))
                            .offset(x: size * 0.25, y: -size * 0.15)
                    }
                }
                .offset(y: isBouncing ? -12 : 0)
                .rotationEffect(.degrees(isSleepingWiggle ? -3 : 3))
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: mascot.currentActivity == .sleeping ? 2.5 : 1.2)
                        .repeatForever(autoreverses: true)
                ) {
                    if mascot.currentActivity == .sleeping {
                        isSleepingWiggle = true
                    } else {
                        isBouncing = true
                    }
                }
            }
        }
    }
    
    private var moodGlowColor: Color {
        switch mascot.mood {
        case .ecstatic, .happy: return .pink
        case .hungry: return .orange
        case .tired: return .indigo
        case .sad: return .blue
        case .neutral: return .green
        }
    }
}

// Вспомогательный треугольник для облачка реплики
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
