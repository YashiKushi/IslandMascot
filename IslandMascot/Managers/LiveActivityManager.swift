import Foundation
import ActivityKit

/// Менеджер для запуска, обновления и завершения Live Activity (Dynamic Island & Lock Screen)
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<MascotAttributes>?
    
    private init() {}
    
    /// Запустить или обновить Live Activity
    func startOrUpdateActivity(with mascot: Mascot) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not authorized.")
            return
        }
        
        let contentState = MascotAttributes.ContentState(
            mascotName: mascot.name,
            emoji: mascot.currentActivity.emoji,
            faceEmoji: mascot.mood.faceEmoji,
            statusText: mascot.currentActivity.rawValue,
            thought: mascot.thoughtBubble,
            hunger: mascot.hunger,
            energy: mascot.energy,
            happiness: mascot.happiness,
            updatedDate: Date()
        )
        
        let content = ActivityContent(
            state: contentState,
            staleDate: Calendar.current.date(byAdding: .hour, value: 4, to: Date())
        )
        
        // Проверяем, есть ли уже активная сессия Live Activity
        if let existingActivity = Activity<MascotAttributes>.activities.first {
            currentActivity = existingActivity
            Task {
                await existingActivity.update(content)
            }
        } else {
            // Создаем новую
            let attributes = MascotAttributes(petId: "mascot_bubu")
            do {
                let activity = try Activity.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
                self.currentActivity = activity
                print("Live Activity started successfully with ID: \(activity.id)")
            } catch {
                print("Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
    }
    
    /// Завершить активность (убрать из Dynamic Island)
    func endActivity() {
        for activity in Activity<MascotAttributes>.activities {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        currentActivity = nil
    }
}
