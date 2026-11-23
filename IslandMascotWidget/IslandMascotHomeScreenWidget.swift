import WidgetKit
import SwiftUI

// Запись в таймлайне виджета
struct MascotTimelineEntry: TimelineEntry {
    let date: Date
    let mascot: Mascot
}

// Провайдер данных для виджета домашнего экрана
struct MascotTimelineProvider: TimelineProvider {
    typealias Entry = MascotTimelineEntry
    
    private let userDefaultsSuite = "group.com.islandmascot.app"
    private let mascotStorageKey = "saved_mascot_state"
    
    func placeholder(in context: Context) -> MascotTimelineEntry {
        MascotTimelineEntry(date: Date(), mascot: Mascot())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MascotTimelineEntry) -> Void) {
        let entry = MascotTimelineEntry(date: Date(), mascot: loadCurrentMascot())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MascotTimelineEntry>) -> Void) {
        let currentMascot = loadCurrentMascot()
        var entries: [MascotTimelineEntry] = []
        let currentDate = Date()
        
        // Генерируем точки во времени на ближайшие 2 часа каждые 20 минут,
        // чтобы маскот автономно менял свои занятия на экране!
        let activities: [MascotActivity] = [.idle, .exploring, .reading, .dancing, .playing]
        
        for minuteOffset in stride(from: 0, through: 120, by: 20) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            var simulatedMascot = currentMascot
            
            // Если маскот не спит, каждые 20 минут он может заняться чем-то новым
            if simulatedMascot.currentActivity != .sleeping && minuteOffset > 0 {
                let randomAct = activities.randomElement() ?? .idle
                simulatedMascot.currentActivity = randomAct
                simulatedMascot.thoughtBubble = Mascot.randomThought(for: randomAct, mood: simulatedMascot.mood)
                simulatedMascot.hunger = max(10, simulatedMascot.hunger - Double(minuteOffset / 4))
                simulatedMascot.energy = max(10, simulatedMascot.energy - Double(minuteOffset / 5))
            }
            
            entries.append(MascotTimelineEntry(date: entryDate, mascot: simulatedMascot))
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadCurrentMascot() -> Mascot {
        // Пробуем прочитать из AppGroup
        if let groupDefaults = UserDefaults(suiteName: userDefaultsSuite),
           let data = groupDefaults.data(forKey: mascotStorageKey),
           let mascot = try? JSONDecoder().decode(Mascot.self, data) {
            return mascot
        }
        // Либо стандартный UserDefaults
        if let data = UserDefaults.standard.data(forKey: mascotStorageKey),
           let mascot = try? JSONDecoder().decode(Mascot.self, data) {
            return mascot
        }
        return Mascot()
    }
}

// Виджет домашнего экрана
struct IslandMascotHomeScreenWidget: Widget {
    let kind: String = "IslandMascotHomeScreenWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MascotTimelineProvider()) { entry in
            MascotWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Мой Питомец")
        .description("Живой маскот прямо на твоем экране iPhone.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Представление виджета
struct MascotWidgetEntryView: View {
    var entry: MascotTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallMascotWidgetView(mascot: entry.mascot)
        case .systemMedium:
            MediumMascotWidgetView(mascot: entry.mascot)
        default:
            SmallMascotWidgetView(mascot: entry.mascot)
        }
    }
}

// Компактный виджет (квадрат 2x2)
struct SmallMascotWidgetView: View {
    var mascot: Mascot
    
    var body: some View {
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
        .padding(8)
    }
}

// Средний виджет (прямоугольник 2x4)
struct MediumMascotWidgetView: View {
    var mascot: Mascot
    
    var body: some View {
        HStack(spacing: 16) {
            // Левая часть: персонаж и облачко
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
            
            // Правая часть: шкалы и фраза
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
        .padding(10)
    }
}

struct MiniStatView: View {
    var label: String
    var value: Double
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(icon)
                .font(.caption2)
            Text("\(Int(value))%")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
        }
    }
}

