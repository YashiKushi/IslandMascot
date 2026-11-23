import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var manager: MascotManager
    @State private var reactionEffect: String? = nil
    @State private var reactionScale: CGFloat = 1.0
    @State private var petSquish: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 22) {
                        // Карточка питомца
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(manager.mascot.name)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                    
                                    HStack(spacing: 5) {
                                        Image(systemName: manager.mascot.currentActivity.sfSymbol)
                                            .font(.caption2)
                                        Text(manager.mascot.currentActivity.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Label(manager.mascot.mood.rawValue, systemImage: manager.mascot.mood.sfSymbol)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(moodAccentColor.opacity(0.15)))
                                    .foregroundColor(moodAccentColor)
                            }
                            
                            // Векторный процедурный персонаж
                            ZStack {
                                MascotCharacterView(mascot: manager.mascot, size: 150)
                                    .scaleEffect(petSquish)
                                    .onTapGesture {
                                        triggerReaction(symbol: "heart.fill")
                                        manager.pet()
                                    }
                                
                                // Всплывающая иконка эмоции при взаимодействии
                                if let reaction = reactionEffect {
                                    Image(systemName: reaction)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(moodAccentColor)
                                        .scaleEffect(reactionScale)
                                        .offset(y: -75)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .frame(height: 190)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // Шкалы состояния
                        VStack(spacing: 16) {
                            StatBarView(title: "Энергия сытости", value: manager.mascot.hunger, color: .orange, sfSymbol: "fork.knife")
                            StatBarView(title: "Жизненная сила", value: manager.mascot.energy, color: .blue, sfSymbol: "bolt.fill")
                            StatBarView(title: "Уровень радости", value: manager.mascot.happiness, color: .pink, sfSymbol: "heart.fill")
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal)
                        
                        // Кнопки взаимодействия
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                EmoteActionButton(title: "Покормить", sfSymbol: "fork.knife", color: .orange) {
                                    triggerReaction(symbol: "sparkles")
                                    manager.feed()
                                }
                                EmoteActionButton(title: "Поиграть", sfSymbol: "gamecontroller.fill", color: .green) {
                                    triggerReaction(symbol: "figure.play")
                                    manager.play()
                                }
                            }
                            
                            HStack(spacing: 12) {
                                EmoteActionButton(
                                    title: manager.mascot.currentActivity == .sleeping ? "Разбудить" : "Уложить спать",
                                    sfSymbol: manager.mascot.currentActivity == .sleeping ? "sun.max.fill" : "moon.stars.fill",
                                    color: .indigo
                                ) {
                                    triggerReaction(symbol: manager.mascot.currentActivity == .sleeping ? "sun.max.fill" : "moon.fill")
                                    manager.toggleSleep()
                                }
                                
                                EmoteActionButton(title: "Погладить", sfSymbol: "hand.wave.fill", color: .pink) {
                                    triggerReaction(symbol: "heart.fill")
                                    manager.pet()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Инструкция по установке виджета
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.square.on.square")
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                                Text("Виджет на экране")
                                    .font(.system(.headline, design: .rounded))
                            }
                            
                            Text("1. Зажмите палец на пустом месте экрана iPhone.\n2. Нажмите «+» в верхнем углу.\n3. Выберите «Island Mascot» (маленький или средний).\n4. Нажмите «Добавить виджет». Питомец оживёт на рабочем столе!")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineSpacing(3)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 25)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Мой Питомец")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func triggerReaction(symbol: String) {
        reactionEffect = symbol
        reactionScale = 0.5
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
            reactionScale = 1.3
            petSquish = 1.12
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                petSquish = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.25)) {
                reactionEffect = nil
            }
        }
    }
    
    private var moodAccentColor: Color {
        switch manager.mascot.mood {
        case .ecstatic: return .orange
        case .happy: return .green
        case .neutral: return .blue
        case .tired: return .indigo
        case .hungry: return .orange
        case .sad: return .secondary
        }
    }
}

struct EmoteActionButton: View {
    var title: String
    var sfSymbol: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: sfSymbol)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
