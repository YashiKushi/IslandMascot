import Foundation
import Combine
import SwiftUI
import WidgetKit

/// Менеджер питомца, отвечающий за сохранение, деградацию параметров по времени и действия
class MascotManager: ObservableObject {
    static let shared = MascotManager()
    
    private let userDefaultsSuite = "group.com.islandmascot.app"
    private let mascotStorageKey = "saved_mascot_state"
    private let liveActivityKey = "is_live_activity_enabled"
    
    @Published var mascot: Mascot
    @Published var isLiveActivityEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isLiveActivityEnabled, forKey: liveActivityKey)
            if !isLiveActivityEnabled {
                LiveActivityManager.shared.endActivity()
            } else {
                LiveActivityManager.shared.startOrUpdateActivity(with: mascot)
            }
        }
    }
    
    private var timer: AnyCancellable?
    
    init() {
        self.isLiveActivityEnabled = UserDefaults.standard.object(forKey: liveActivityKey) as? Bool ?? true
        
        // Загрузка сохраненного состояния
        if let data = UserDefaults.standard.data(forKey: mascotStorageKey),
           let saved = try? JSONDecoder().decode(Mascot.self, data) {
            self.mascot = saved
        } else {
            self.mascot = Mascot()
        }
        
        updateStatsOverTime()
        startAutonomousLifeCycle()
    }
    
    /// Автономный жизненный цикл маскота (периодическое изменение активности)
    private func startAutonomousLifeCycle() {
        timer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.simulateAutonomousLife()
            }
    }
    
    /// Маскот живет сам по себе: выбирает случайные действия, если его не трогают
    func simulateAutonomousLife() {
        updateStatsOverTime()
        
        // Если маскот не спит, он может заняться чем-то своим
        if mascot.currentActivity != .sleeping {
            let possibleActivities: [MascotActivity] = [.idle, .exploring, .reading, .dancing, .playing]
            let newActivity = possibleActivities.randomElement() ?? .idle
            mascot.currentActivity = newActivity
            mascot.thoughtBubble = Mascot.randomThought(for: newActivity, mood: mascot.mood)
        } else {
            // Если спит и восстановил энергию > 90, просыпается сам
            if mascot.energy >= 90 {
                mascot.currentActivity = .idle
                mascot.thoughtBubble = "Ура, я выспался! Доброе утро! ☀️"
            } else {
                mascot.thoughtBubble = Mascot.randomThought(for: .sleeping, mood: mascot.mood)
            }
        }
        
        saveState()
        if isLiveActivityEnabled {
            LiveActivityManager.shared.startOrUpdateActivity(with: mascot)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Расчет изменения показателей на основе прошедшего времени (когда приложение было закрыто)
    func updateStatsOverTime() {
        let now = Date()
        let elapsedMinutes = now.timeIntervalSince(mascot.lastUpdated) / 60.0
        
        guard elapsedMinutes > 0.5 else { return }
        
        if mascot.currentActivity == .sleeping {
            // Во сне энергия восстанавливается (+0.5 в минуту), голод слегка падает (-0.1 в минуту)
            mascot.energy = min(100.0, mascot.energy + (elapsedMinutes * 0.5))
            mascot.hunger = max(0.0, mascot.hunger - (elapsedMinutes * 0.1))
        } else {
            // Во время бодрствования голод падает (-0.2 в минуту), энергия падает (-0.15 в минуту)
            mascot.hunger = max(0.0, mascot.hunger - (elapsedMinutes * 0.2))
            mascot.energy = max(0.0, mascot.energy - (elapsedMinutes * 0.15))
            
            // Если голоден или устал, счастье падает
            if mascot.hunger < 30 || mascot.energy < 30 {
                mascot.happiness = max(0.0, mascot.happiness - (elapsedMinutes * 0.2))
            }
        }
        
        mascot.lastUpdated = now
        saveState()
    }
    
    // MARK: - Действия пользователя
    
    func feed() {
        mascot.hunger = min(100.0, mascot.hunger + 30.0)
        mascot.happiness = min(100.0, mascot.happiness + 10.0)
        mascot.currentActivity = .eating
        mascot.thoughtBubble = Mascot.randomThought(for: .eating, mood: mascot.mood)
        syncState()
    }
    
    func play() {
        guard mascot.energy >= 15 else {
            mascot.thoughtBubble = "Я слишком устал, чтобы играть... Давай посплю 🥱"
            return
        }
        mascot.energy = max(0.0, mascot.energy - 15.0)
        mascot.happiness = min(100.0, mascot.happiness + 25.0)
        mascot.hunger = max(0.0, mascot.hunger - 10.0)
        mascot.currentActivity = .playing
        mascot.thoughtBubble = Mascot.randomThought(for: .playing, mood: mascot.mood)
        syncState()
    }
    
    func toggleSleep() {
        if mascot.currentActivity == .sleeping {
            mascot.currentActivity = .idle
            mascot.thoughtBubble = "Я проснулся и готов к новым приключениям! 🌟"
        } else {
            mascot.currentActivity = .sleeping
            mascot.thoughtBubble = Mascot.randomThought(for: .sleeping, mood: mascot.mood)
        }
        syncState()
    }
    
    func pet() {
        mascot.happiness = min(100.0, mascot.happiness + 15.0)
        mascot.thoughtBubble = "Муррр... Так приятно, когда ты меня гладишь! 🥰"
        syncState()
    }
    
    private func syncState() {
        mascot.lastUpdated = Date()
        saveState()
        if isLiveActivityEnabled {
            LiveActivityManager.shared.startOrUpdateActivity(with: mascot)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func saveState() {
        if let encoded = try? JSONEncoder().encode(mascot) {
            UserDefaults.standard.set(encoded, forKey: mascotStorageKey)
            // Также сохраняем в AppGroup для виджетов, если AppGroup настроен
            if let groupDefaults = UserDefaults(suiteName: userDefaultsSuite) {
                groupDefaults.set(encoded, forKey: mascotStorageKey)
            }
        }
    }
}

