import SwiftUI
import UIKit

/// Процедурный векторный маскот Люми (без использования эмодзи)
public struct MascotCharacterView: View {
    public var mascot: Mascot
    public var size: CGFloat = 140
    public var isInteractive: Bool = true
    
    @State private var breathScale: CGFloat = 1.0
    @State private var floatOffset: CGFloat = 0.0
    @State private var squishX: CGFloat = 1.0
    @State private var squishY: CGFloat = 1.0
    @State private var eyeBlink: Bool = false
    
    public init(mascot: Mascot, size: CGFloat = 140, isInteractive: Bool = true) {
        self.mascot = mascot
        self.size = size
        self.isInteractive = isInteractive
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Облачко мыслей
            if !mascot.thoughtBubble.isEmpty {
                Text(mascot.thoughtBubble)
                    .font(.system(size: size * 0.11, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    )
                    .overlay(
                        VectorTail()
                            .fill(Color(UIColor.secondarySystemBackground))
                            .frame(width: 10, height: 6)
                            .rotationEffect(.degrees(180))
                            .offset(y: 14),
                        alignment: .bottom
                    )
                    .padding(.bottom, 4)
                    .id(mascot.thoughtBubble)
            }
            
            // Фигура существа
            ZStack {
                // Тень питомца
                Ellipse()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: size * 0.7 * squishX, height: size * 0.14)
                    .offset(y: size * 0.48)
                    .scaleEffect(breathScale)
                
                // Мягкое атмосферное свечение
                RoundedRectangle(cornerRadius: size * 0.38, style: .continuous)
                    .fill(primaryBodyColor.opacity(0.25))
                    .frame(width: size * 0.9, height: size * 0.85)
                    .blur(radius: 18)
                
                // Тело питомца (органическая сглаженная форма)
                RoundedRectangle(cornerRadius: size * 0.36, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [primaryBodyColor, secondaryBodyColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.88 * squishX, height: size * 0.84 * squishY)
                    .overlay(
                        // Верхний световой блик
                        RoundedRectangle(cornerRadius: size * 0.34, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.6), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: size * 0.02
                            )
                            .padding(size * 0.02)
                    )
                    .shadow(color: secondaryBodyColor.opacity(0.35), radius: 12, x: 0, y: 6)
                
                // Лицо (Глаза, Щечки, Ротик)
                VStack(spacing: size * 0.04) {
                    HStack(spacing: size * 0.24) {
                        EyeView(mood: mascot.mood, isBlinking: eyeBlink, size: size * 0.22)
                        EyeView(mood: mascot.mood, isBlinking: eyeBlink, size: size * 0.22)
                    }
                    
                    // Щечки и Ротик
                    ZStack {
                        // Румянец на щечках
                        HStack(spacing: size * 0.38) {
                            Circle()
                                .fill(blushColor.opacity(mascot.mood == .ecstatic || mascot.currentActivity == .sleeping ? 0.6 : 0.35))
                                .frame(width: size * 0.12, height: size * 0.07)
                            Circle()
                                .fill(blushColor.opacity(mascot.mood == .ecstatic || mascot.currentActivity == .sleeping ? 0.6 : 0.35))
                                .frame(width: size * 0.12, height: size * 0.07)
                        }
                        
                        // Ротик
                        MouthShape(mood: mascot.mood, activity: mascot.currentActivity)
                            .stroke(Color.primary.opacity(0.75), style: StrokeStyle(lineWidth: max(2, size * 0.025), lineCap: .round, lineJoin: .round))
                            .frame(width: size * 0.14, height: size * 0.08)
                    }
                }
                .offset(y: -size * 0.02)
            }
            .offset(y: floatOffset)
            .scaleEffect(y: breathScale, anchor: .bottom)
        }
        .onAppear {
            startLifeAnimation()
        }
    }
    
    private func startLifeAnimation() {
        // Дыхание и парение
        withAnimation(
            Animation.easeInOut(duration: mascot.currentActivity == .sleeping ? 2.4 : 1.5)
                .repeatForever(autoreverses: true)
        ) {
            breathScale = mascot.currentActivity == .sleeping ? 0.94 : 1.04
            floatOffset = mascot.currentActivity == .sleeping ? 4 : -6
        }
        
        // Морфология действий
        if mascot.currentActivity == .playing {
            withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                squishX = 1.08
                squishY = 0.92
            }
        }
    }
    
    // Цвета тела питомца в зависимости от настроения
    private var primaryBodyColor: Color {
        switch mascot.mood {
        case .ecstatic: return Color(red: 1.0, green: 0.62, blue: 0.42) // Персиково-золотой
        case .happy: return Color(red: 0.45, green: 0.85, blue: 0.72)    // Мятный
        case .neutral: return Color(red: 0.54, green: 0.68, blue: 0.98)  // Небесно-голубой
        case .tired: return Color(red: 0.72, green: 0.65, blue: 0.88)    // Лавандовый
        case .hungry: return Color(red: 0.98, green: 0.55, blue: 0.38)   // Теплый коралловый
        case .sad: return Color(red: 0.60, green: 0.70, blue: 0.80)      // Дымчато-синий
        }
    }
    
    private var secondaryBodyColor: Color {
        switch mascot.mood {
        case .ecstatic: return Color(red: 0.98, green: 0.40, blue: 0.55)
        case .happy: return Color(red: 0.28, green: 0.72, blue: 0.82)
        case .neutral: return Color(red: 0.40, green: 0.48, blue: 0.92)
        case .tired: return Color(red: 0.55, green: 0.45, blue: 0.80)
        case .hungry: return Color(red: 0.90, green: 0.35, blue: 0.30)
        case .sad: return Color(red: 0.48, green: 0.55, blue: 0.68)
        }
    }
    
    private var blushColor: Color {
        Color(red: 1.0, green: 0.35, blue: 0.45)
    }
}

// Векторные глаза существа
struct EyeView: View {
    var mood: MascotMood
    var isBlinking: Bool
    var size: CGFloat
    
    var body: some View {
        ZStack {
            if mood == .tired {
                // Закрытые сонные глазки (дуги вниз)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: size * 0.4))
                    p.addQuadCurve(to: CGPoint(x: size, y: size * 0.4), control: CGPoint(x: size * 0.5, y: size * 0.75))
                }
                .stroke(Color.primary.opacity(0.8), style: StrokeStyle(lineWidth: max(2, size * 0.14), lineCap: .round))
                .frame(width: size, height: size)
            } else if mood == .happy || mood == .ecstatic {
                // Радостные глазки-дуги (радостные арки вверх)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: size * 0.6))
                    p.addQuadCurve(to: CGPoint(x: size, y: size * 0.6), control: CGPoint(x: size * 0.5, y: size * 0.15))
                }
                .stroke(Color.primary.opacity(0.85), style: StrokeStyle(lineWidth: max(2, size * 0.16), lineCap: .round))
                .frame(width: size, height: size)
            } else {
                // Открытые круглые выразительные глаза
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.primary.opacity(0.85))
                        .frame(width: size, height: size)
                    
                    // Блик света в глазу
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.38, height: size * 0.38)
                        .offset(x: -size * 0.14, y: size * 0.14)
                }
            }
        }
        .frame(width: size, height: size)
    }
}


// Векторный ротик
struct MouthShape: Shape {
    var mood: MascotMood
    var activity: MascotActivity
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        if activity == .eating {
            // Жующий круглый ротик
            p.addEllipse(in: CGRect(x: rect.midX - 4, y: rect.midY - 3, width: 8, height: 6))
        } else if mood == .happy || mood == .ecstatic {
            // Широкая улыбка
            p.move(to: CGPoint(x: rect.minX, y: rect.minY + 2))
            p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 2), control: CGPoint(x: rect.midX, y: rect.maxY + 4))
        } else if mood == .sad || mood == .hungry {
            // Грустный ротик
            p.move(to: CGPoint(x: rect.minX, y: rect.maxY - 1))
            p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY - 1), control: CGPoint(x: rect.midX, y: rect.minY - 3))
        } else {
            // Спокойная легкая полуулыбка
            p.move(to: CGPoint(x: rect.minX + 2, y: rect.midY))
            p.addQuadCurve(to: CGPoint(x: rect.maxX - 2, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.midY + 3))
        }
        return p
    }
}

// Вспомогательный хвостик для облачка
struct VectorTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
