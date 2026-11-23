import Foundation
import SwiftUI
import WidgetKit

/// Менеджер питомца, отвечающий за сохранение, показатели и действия
public class MascotManager: ObservableObject {
    public static let shared = MascotManager()
    
    private let userDefaultsSuite = "group.com.islandmascot.app"
    private let mascotStorageKey = "saved_mascot_state"
    
    @Published public var mascot: Mascot
    
    public init() {
        if let groupDefaults = UserDefaults(suiteName: userDefaultsSuite),
           let data = groupDefaults.data(forKey: mascotStorageKey),
           let saved = try? JSONDecoder().decode(Mascot.self, data) {
            self.mascot = saved
        } else if let data = UserDefaults.standard.data(forKey: mascotStorageKey),
                  let saved = try? JSONDecoder().decode(Mascot.self, data) {
            self.mascot = saved
        } else {
            self.mascot = Mascot()
        }
        
        updateStatsOverTime()
    }
    
    public func updateStatsOverTime() {
        let now = Date()
        let elapsedMinutes = now.timeIntervalSince(mascot.lastUpdated) / 60.0
        
        guard elapsedMinutes > 0.5 else { return }
        
        if mascot.currentActivity == .sleeping {
            mascot.energy = min(100.0, mascot.energy + (elapsedMinutes * 0.5))
            mascot.hunger = max(0.0, mascot.hunger - (elapsedMinutes * 0.1))
        } else {
            mascot.hunger = max(0.0, mascot.hunger - (elapsedMinutes * 0.2))
            mascot.energy = max(0.0, mascot.energy - (elapsedMinutes * 0.15))
            
            if mascot.hunger < 30 || mascot.energy < 30 {
                mascot.happiness = max(0.0, mascot.happiness - (elapsedMinutes * 0.2))
            }
        }
        
        mascot.lastUpdated = now
        saveState()
    }
    
    public func feed() {
        mascot.hunger = min(100.0, mascot.hunger + 30.0)
        mascot.happiness = min(100.0, mascot.happiness + 10.0)
        mascot.currentActivity = .eating
        mascot.thoughtBubble = Mascot.randomThought(for: .eating, mood: mascot.mood)
        syncState()
    }
    
    public func play() {
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
    
    public func toggleSleep() {
        if mascot.currentActivity == .sleeping {
            mascot.currentActivity = .idle
            mascot.thoughtBubble = "Я проснулся и готов к новым приключениям! 🌟"
        } else {
            mascot.currentActivity = .sleeping
            mascot.thoughtBubble = Mascot.randomThought(for: .sleeping, mood: mascot.mood)
        }
        syncState()
    }
    
    public func pet() {
        mascot.happiness = min(100.0, mascot.happiness + 15.0)
        mascot.thoughtBubble = "Муррр... Так приятно, когда ты меня гладишь! 🥰"
        syncState()
    }
    
    private func syncState() {
        mascot.lastUpdated = Date()
        saveState()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    public func saveState() {
        if let encoded = try? JSONEncoder().encode(mascot) {
            UserDefaults.standard.set(encoded, forKey: mascotStorageKey)
            if let groupDefaults = UserDefaults(suiteName: userDefaultsSuite) {
                groupDefaults.set(encoded, forKey: mascotStorageKey)
            }
        }
    }
}
