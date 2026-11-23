import Foundation
import SwiftUI

/// Состояния и действия маскота
enum MascotActivity: String, Codable, CaseIterable {
    case idle = "Отдыхает"
    case playing = "Играет"
    case sleeping = "Спит"
    case eating = "Кушает"
    case exploring = "Исследует мир"
    case reading = "Читает книжку"
    case dancing = "Танцует"
    
    var emoji: String {
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
enum MascotMood: String, Codable {
    case ecstatic = "В восторге!"
    case happy = "Счастлив"
    case neutral = "Спокоен"
    case tired = "Хочет спать"
    case hungry = "Голоден"
    case sad = "Скучает"
    
    var faceEmoji: String {
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
struct Mascot: Codable, Equatable {
    var name: String = "Бубу"
    var hunger: Double = 85.0     // 0 = голодный, 100 = сытый
    var energy: Double = 90.0     // 0 = без сил, 100 = бодр
    var happiness: Double = 80.0  // 0 = грустный, 100 = радостный
    var lastUpdated: Date = Date()
    var currentActivity: MascotActivity = .idle
    var thoughtBubble: String = "Мурр, как хорошо жить!"
    
    var mood: MascotMood {
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
    
    /// Генерация случайных мыслей в зависимости от состояния
    static func randomThought(for activity: MascotActivity, mood: MascotMood) -> String {
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

