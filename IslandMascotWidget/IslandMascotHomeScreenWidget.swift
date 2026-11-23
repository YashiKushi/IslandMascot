import WidgetKit
import SwiftUI
import UIKit

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
        .configurationDisplayName("Люми Маскот")
        .description("Живой процедурный питомец прямо на твоем экране.")
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

// Маленький виджет (2x2)
public struct SmallMascotWidgetView: View {
    var mascot: Mascot
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(mascot.name)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: mascot.currentActivity.sfSymbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 0)
            
            // Векторный персонаж
            MascotCharacterView(mascot: mascot, size: 75, isInteractive: false)
            
            Spacer(minLength: 0)
            
            Text(mascot.thoughtBubble)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.primary.opacity(0.85))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                )
        }
    }
}

// Средний виджет (2x4)
public struct MediumMascotWidgetView: View {
    var mascot: Mascot
    
    public var body: some View {
        HStack(spacing: 14) {
            // Левая часть: персонаж
            VStack(spacing: 4) {
                MascotCharacterView(mascot: mascot, size: 85, isInteractive: false)
                
                HStack(spacing: 4) {
                    Image(systemName: mascot.currentActivity.sfSymbol)
                        .font(.system(size: 9))
                    Text(mascot.currentActivity.rawValue)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.secondary)
            }
            .frame(width: 90)
            
            Divider()
            
            // Правая часть: информация и индикаторы
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(mascot.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Spacer()
                    Label(mascot.mood.rawValue, systemImage: mascot.mood.sfSymbol)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                        .foregroundColor(.accentColor)
                }
                
                Text(mascot.thoughtBubble)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                    .lineLimit(2)
                
                Spacer()
                
                HStack(spacing: 10) {
                    MiniSymbolStatView(label: "Сытость", value: mascot.hunger, sfSymbol: "fork.knife", color: .orange)
                    MiniSymbolStatView(label: "Сила", value: mascot.energy, sfSymbol: "bolt.fill", color: .blue)
                    MiniSymbolStatView(label: "Радость", value: mascot.happiness, sfSymbol: "heart.fill", color: .pink)
                }
            }
        }
    }
}

public struct MiniSymbolStatView: View {
    var label: String
    var value: Double
    var sfSymbol: String
    var color: Color
    
    public var body: some View {
        VStack(spacing: 2) {
            Image(systemName: sfSymbol)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(color)
            Text("\(Int(value))%")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}
