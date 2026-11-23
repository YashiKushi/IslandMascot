import ActivityKit
import Foundation

/// Атрибуты для ActivityKit (Live Activities & Dynamic Island)
public struct MascotAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var mascotName: String
        public var emoji: String
        public var faceEmoji: String
        public var statusText: String
        public var thought: String
        public var hunger: Double
        public var energy: Double
        public var happiness: Double
        public var updatedDate: Date
        
        public init(
            mascotName: String,
            emoji: String,
            faceEmoji: String,
            statusText: String,
            thought: String,
            hunger: Double,
            energy: Double,
            happiness: Double,
            updatedDate: Date = Date()
        ) {
            self.mascotName = mascotName
            self.emoji = emoji
            self.faceEmoji = faceEmoji
            self.statusText = statusText
            self.thought = thought
            self.hunger = hunger
            self.energy = energy
            self.happiness = happiness
            self.updatedDate = updatedDate
        }
    }

    public var petId: String
    
    public init(petId: String = "primary_pet") {
        self.petId = petId
    }
}
