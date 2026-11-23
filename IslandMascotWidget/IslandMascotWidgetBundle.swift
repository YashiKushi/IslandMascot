import WidgetKit
import SwiftUI

@main
struct IslandMascotWidgetBundle: WidgetBundle {
    var body: some Widget {
        IslandMascotHomeScreenWidget()
        IslandMascotDynamicIslandWidget()
    }
}
