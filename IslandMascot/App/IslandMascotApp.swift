import SwiftUI
import UIKit
import ActivityKit

@main
struct IslandMascotApp: App {
    @StateObject private var mascotManager = MascotManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mascotManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    mascotManager.saveState()
                    if mascotManager.isLiveActivityEnabled {
                        LiveActivityManager.shared.startOrUpdateActivity(with: mascotManager.mascot)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    mascotManager.updateStatsOverTime()
                }
        }
    }
}
