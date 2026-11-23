import SwiftUI
import ActivityKit

@main
struct IslandMascotApp: App {
    @StateObject private var mascotManager = MascotManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mascotManager)
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .background:
                        // При сворачивании приложения обновляем или запускаем Live Activity в Dynamic Island
                        mascotManager.saveState()
                        if mascotManager.isLiveActivityEnabled {
                            LiveActivityManager.shared.startOrUpdateActivity(with: mascotManager.mascot)
                        }
                    case .active:
                        // При возвращении в приложение синхронизируем состояние по времени
                        mascotManager.updateStatsOverTime()
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
                }
        }
    }
}
