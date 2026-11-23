import WidgetKit
import SwiftUI

public struct MascotTimelineEntry: TimelineEntry {
    public let date: Date
    public let mascot: Mascot
    
    public init(date: Date, mascot: Mascot) {
        self.date = date
        self.mascot = mascot
    }
}

public struct MascotTimelineProvider: TimelineProvider {
    public typealias Entry = MascotTimelineEntry
    
    private let userDefaultsSuite = "group.com.islandmascot.app"
    private let mascotStorageKey = "saved_mascot_state"
    
    public init() {}
    
    public func placeholder(in context: Context) -> MascotTimelineEntry {
        MascotTimelineEntry(date: Date(), mascot: Mascot())
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (MascotTimelineEntry) -> Void) {
        let entry = MascotTimelineEntry(date: Date(), mascot: loadCurrentMascot())
        completion(entry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<MascotTimelineEntry>) -> Void) {
        let currentMascot = loadCurrentMascot()
        var entries: [MascotTimelineEntry] = []
        let currentDate = Date()
        let activities: [MascotActivity] = [.idle, .exploring, .reading, .dancing, .playing]
        
        for minuteOffset in stride(from: 0, through: 120, by: 20) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            var simulatedMascot = currentMascot
            
            if simulatedMascot.currentActivity != .sleeping && minuteOffset > 0 {
                let randomAct = activities.randomElement() ?? .idle
                simulatedMascot.currentActivity = randomAct
                simulatedMascot.thoughtBubble = Mascot.randomThought(for: randomAct, mood: simulatedMascot.mood)
                simulatedMascot.hunger = max(10, simulatedMascot.hunger - Double(minuteOffset / 4))
                simulatedMascot.energy = max(10, simulatedMascot.energy - Double(minuteOffset / 5))
            }
            
            entries.append(MascotTimelineEntry(date: entryDate, mascot: simulatedMascot))
        }
        
        completion(Timeline(entries: entries, policy: .atEnd))
    }
    
    private func loadCurrentMascot() -> Mascot {
        if let groupDefaults = UserDefaults(suiteName: userDefaultsSuite),
           let data = groupDefaults.data(forKey: mascotStorageKey),
           let mascot = try? JSONDecoder().decode(Mascot.self, from: data) {
            return mascot
        }
        if let data = UserDefaults.standard.data(forKey: mascotStorageKey),
           let mascot = try? JSONDecoder().decode(Mascot.self, from: data) {
            return mascot
        }
        return Mascot()
    }
}

public struct IslandMascotHomeScreenWidget: Widget {
    public let kind: String = "IslandMascotHomeScreenWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MascotTimelineProvider()) { entry in
            MascotWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Мой Питомец")
        .description("Живой маскот прямо на твоем экране iPhone.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

public struct MascotWidgetEntryView: View {
    var entry: MascotTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    public var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallMascotWidgetView(mascot: entry.mascot)
            case .systemMedium:
                MediumMascotWidgetView(mascot: entry.mascot)
            default:
                SmallMascotWidgetView(mascot: entry.mascot)
            }
        }
        .padding(8)
    }
}

public struct SmallMascotWidgetView: View {
    var mascot: Mascot
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(mascot.name)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Text(mascot.currentActivity.emoji)
                    .font(.caption2)
            }
            
            Spacer()
            
            Text(mascot.mood.faceEmoji)
                .font(.system(size: 48))
            
            Spacer()
            
            Text(mascot.thoughtBubble)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(0.06))
                )
        }
    }
}

public struct MediumMascotWidgetView: View {
    var mascot: Mascot
    
    public var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 6) {
                Text(mascot.mood.faceEmoji)
                    .font(.system(size: 54))
                
                Text(mascot.currentActivity.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .frame(width: 90)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(mascot.name)
                        .font(.headline)
                        .bold()
                    Spacer()
                    Text(mascot.mood.rawValue)
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                }
                
                Text("\"\(mascot.thoughtBubble)\"")
                    .font(.system(size: 11, design: .rounded))
                    .italic()
                    .lineLimit(2)
                    .foregroundColor(.primary.opacity(0.8))
                
                Spacer()
                
                HStack(spacing: 12) {
                    MiniStatView(label: "Сытость", value: mascot.hunger, icon: "🍔", color: .orange)
                    MiniStatView(label: "Энергия", value: mascot.energy, icon: "⚡️", color: .yellow)
                    MiniStatView(label: "Счастье", value: mascot.happiness, icon: "💖", color: .pink)
                }
            }
        }
    }
}

public struct MiniStatView: View {
    var label: String
    var value: Double
    var icon: String
    var color: Color
    
    public var body: some View {
        VStack(spacing: 2) {
            Text(icon)
                .font(.caption2)
            Text("\(Int(value))%")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
        }
    }
}
