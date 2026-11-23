import SwiftUI

@main
struct IslandMascotApp: App {
    @StateObject private var mascotManager = MascotManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mascotManager)
        }
    }
}
