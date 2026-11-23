import Foundation
import SwiftUI

/// Состояния и действия маскота
public enum MascotActivity: String, Codable, CaseIterable {
    case idle = "Отдыхает"
    case playing = "Играет"
    case sleeping = "Спит"
    case eating = "Кушает"
    case exploring = "Исследует мир"
    case reading = "Читает книжку"
    case dancing = "Танцует"
    
    public var emoji: String {
        switch self {
        case .idle: return "🐱"
        case .playing: return "🧶"
        case .sleeping: return "💤"
        case .eating: return "🍣"
        case .exploring: return "🎒"
        case .reading: return "📖"
        case .dancing: return "🎶"
        }
    }
}

/// Настроение маскота
public enum MascotMood: String, Codable {
    case ecstatic = "В восторге!"
    case happy = "Счастлив"
    case neutral = "Спокоен"
    case tired = "Хочет спать"
    case hungry = "Голоден"
    case sad = "Скучает"
    
    public var faceEmoji: String {
        switch self {
        case .ecstatic: return "😻"
        case .happy: return "😺"
        case .neutral: return "😸"
        case .tired: return "🥱"
        case .hungry: return "🤤"
        case .sad: return "😿"
        }
    }
}

/// Основная модель питомца
public struct Mascot: Codable, Equatable {
    public var name: String = "Бубу"
    public var hunger: Double = 85.0
    public var energy: Double = 90.0
    public var happiness: Double = 80.0
    public var lastUpdated: Date = Date()
    public var currentActivity: MascotActivity = .idle
    public var thoughtBubble: String = "Мурр, как хорошо жить!"
    
    public init(
        name: String = "Бубу",
        hunger: Double = 85.0,
        energy: Double = 90.0,
        happiness: Double = 80.0,
        lastUpdated: Date = Date(),
        currentActivity: MascotActivity = .idle,
        thoughtBubble: String = "Мурр, как хорошо жить!"
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
            return ["Сплю сладким сном... zZz", "Снятся рыбки и молочко", "Тихо-тихо... мурр"].randomElement()!
        case (.eating, _):
            return ["Ням-ням, вкуснотища!", "Обожаю перекусы!", "Спасибо за угощение!"].randomElement()!
        case (.playing, _):
            return ["Ловлю бантик!", "Ура, ты со мной играешь!", "Прыг-скок!"].randomElement()!
        case (_, .hungry):
            return ["Животик урчит... Покорми меня!", "Хочу вкусняшку!", "Где моя рыбка? 🐟"].randomElement()!
        case (_, .tired):
            return ["Зевок... Глазки слипаются", "Пора в кроватку", "Отдохну немножко"].randomElement()!
        case (_, .sad):
            return ["Мне одиноко...", "Погладь меня за ушком", "Скучаю по тебе"].randomElement()!
        default:
            return [
                "Ловлю солнечных зайчиков ☀️",
                "Жизнь на острове прекрасна!",
                "Я тут, наблюдаю за тобой!",
                "Мурлыкаю от счастья 💕",
                "Интересно, что мы будем делать дальше?",
                "Надеюсь, у тебя отличный день!"
            ].randomElement()!
        }
    }
}
