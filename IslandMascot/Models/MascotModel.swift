import Foundation
import SwiftUI

/// Состояния и действия маскота
public enum MascotActivity: String, Codable, CaseIterable, Sendable {
    case idle = "Отдыхает"
    case playing = "Играет"
    case sleeping = "Спит"
    case eating = "Кушает"
    case exploring = "Исследует"
    case reading = "Читает"
    case dancing = "Танцует"
    
    public var sfSymbol: String {
        switch self {
        case .idle: return "sparkles"
        case .playing: return "figure.play"
        case .sleeping: return "moon.stars.fill"
        case .eating: return "fork.knife"
        case .exploring: return "binoculars.fill"
        case .reading: return "book.fill"
        case .dancing: return "music.note"
        }
    }
}

/// Настроение маскота
public enum MascotMood: String, Codable, Sendable {
    case ecstatic = "В восторге"
    case happy = "Счастлив"
    case neutral = "Спокоен"
    case tired = "Хочет спать"
    case hungry = "Голоден"
    case sad = "Грустит"
    
    public var sfSymbol: String {
        switch self {
        case .ecstatic: return "star.fill"
        case .happy: return "heart.fill"
        case .neutral: return "circle.fill"
        case .tired: return "zzz"
        case .hungry: return "flame.fill"
        case .sad: return "cloud.rain.fill"
        }
    }
}

/// Основная модель питомца
public struct Mascot: Codable, Equatable, Sendable {
    public var name: String = "Люми"
    public var hunger: Double = 85.0
    public var energy: Double = 90.0
    public var happiness: Double = 80.0
    public var lastUpdated: Date = Date()
    public var currentActivity: MascotActivity = .idle
    public var thoughtBubble: String = "Тепло и уютно..."
    
    public init(
        name: String = "Люми",
        hunger: Double = 85.0,
        energy: Double = 90.0,
        happiness: Double = 80.0,
        lastUpdated: Date = Date(),
        currentActivity: MascotActivity = .idle,
        thoughtBubble: String = "Тепло и уютно..."
    ) {
        self.name = name
        self.hunger = hunger
        self.energy = energy
        self.happiness = happiness
        self.lastUpdated = lastUpdated
        self.currentActivity = currentActivity
        self.thoughtBubble = thoughtBubble
    }
    
    public var mood: MascotMood {
        if hunger < 25 {
            return .hungry
        } else if energy < 25 {
            return .tired
        } else if happiness < 30 {
            return .sad
        } else if happiness > 85 && hunger > 70 && energy > 70 {
            return .ecstatic
        } else if happiness > 60 {
            return .happy
        } else {
            return .neutral
        }
    }
    
    public static func randomThought(for activity: MascotActivity, mood: MascotMood) -> String {
        switch (activity, mood) {
        case (.sleeping, _):
            return ["Сплю сладким сном...", "Тихо и спокойно вокруг", "Восстанавливаю силы"].randomElement()!
        case (.eating, _):
            return ["Очень вкусно!", "Заряжаюсь энергией", "Спасибо за заботу"].randomElement()!
        case (.playing, _):
            return ["Как же весело!", "Прыгаю от радости", "Обожаю двигаться"].randomElement()!
        case (_, .hungry):
            return ["Животик пустой...", "Пора бы перекусить", "Жду вкусняшку"].randomElement()!
        case (_, .tired):
            return ["Глазки слипаются", "Пора отдохнуть", "Тянет в сон"].randomElement()!
        case (_, .sad):
            return ["Немного грустно...", "Хочется внимания", "Побудь со мной"].randomElement()!
        default:
            return [
                "Ловлю лучи света",
                "Отличный день для открытий",
                "Наблюдаю за миром вокруг",
                "Чувствую гармонию и покой",
                "Интересно, что будет дальше?"
            ].randomElement()!
        }
    }
}
