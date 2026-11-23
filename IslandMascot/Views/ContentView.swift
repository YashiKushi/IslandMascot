import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var manager: MascotManager
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.secondarySystemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Главная карточка маскота
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(manager.mascot.name)
                                        .font(.title2)
                                        .bold()
                                    Text("Занятие: \(manager.mascot.currentActivity.rawValue)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(manager.mascot.mood.rawValue)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                                    .foregroundColor(.accentColor)
                            }
                            
                            // Персонаж с облачком мыслей
                            MascotCharacterView(mascot: manager.mascot)
                                .padding(.vertical, 8)
                                .onTapGesture {
                                    manager.pet()
                                }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(UIColor.tertiarySystemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // Шкалы состояния
                        VStack(spacing: 14) {
                            StatBarView(title: "Сытость", value: manager.mascot.hunger, color: .orange, icon: "🍔")
                            StatBarView(title: "Энергия", value: manager.mascot.energy, color: .yellow, icon: "⚡️")
                            StatBarView(title: "Счастье", value: manager.mascot.happiness, color: .pink, icon: "💖")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(UIColor.tertiarySystemBackground))
                        )
                        .padding(.horizontal)
                        
                        // Кнопки ухода за питомцем
                        VStack(spacing: 12) {
                            Text("Взаимодействие")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ActionButton(title: "Покормить", icon: "🍣", color: .orange) {
                                    manager.feed()
                                }
                                ActionButton(title: "Поиграть", icon: "🎾", color: .green) {
                                    manager.play()
                                }
                            }
                            
                            HStack(spacing: 12) {
                                ActionButton(
                                    title: manager.mascot.currentActivity == .sleeping ? "Разбудить" : "Уложить спать",
                                    icon: manager.mascot.currentActivity == .sleeping ? "☀️" : "🌙",
                                    color: .indigo
                                ) {
                                    manager.toggleSleep()
                                }
                                
                                ActionButton(title: "Погладить", icon: "🥰", color: .pink) {
                                    manager.pet()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Блок-подсказка про виджеты
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                    .foregroundColor(.accentColor)
                                Text("Как поставить виджет на экран?")
                                    .font(.headline)
                            }
                            
                            Text("1. Зажми палец на любом свободном месте экрана iPhone.\n2. Нажми «+» в верхнем левом углу.\n3. Найди «Island Mascot» в списке виджетов.\n4. Выбери размер (маленький или средний) и нажми «Добавить виджет»!\n5. Питомец теперь живёт прямо на твоем рабочем столе!")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.tertiarySystemBackground))
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Мой Питомец")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ActionButton: View {
    var title: String
    var icon: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.title3)
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(14)
        }
    }
}
