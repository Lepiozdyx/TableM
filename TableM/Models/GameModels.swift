//
//  GameColor.swift
//  TableM
//
//  Created by Alex on 23.07.2025.
//


import Foundation
import SwiftUI

// MARK: - Game Colors
enum GameColor: String, CaseIterable, Codable {
    case purple = "purple"
    case red = "red"
    case brown = "brown"
    case green = "green"
    case pink = "pink"
    case black = "black"
    case gray = "gray"
    case magenta = "magenta"
    
    var color: Color {
        switch self {
        case .purple: return .purple
        case .red: return .red
        case .brown: return .brown
        case .green: return .green
        case .pink: return .pink
        case .black: return .black
        case .gray: return .gray
        case .magenta: return .init(red: 1.0, green: 0.0, blue: 1.0)
        }
    }
    
    var displayName: String {
        return rawValue.capitalized
    }
}

// MARK: - Game Locations
enum GameLocation: String, CaseIterable, Codable {
    case france = "france"
    case japan = "japan"
    case brazil = "brazil"
    case egypt = "egypt"
    case usa = "usa"
    
    var displayName: String {
        switch self {
        case .france: return "Versailles Code"
        case .japan: return "Kyoto Mystery"
        case .brazil: return "Amazon Code"
        case .egypt: return "Pyramid Code"
        case .usa: return "Silicon Code"
        }
    }
    
    var backgroundImage: String {
        return "background_\(rawValue)"
    }
    
    var professorComment: String {
        switch self {
        case .france: return "France invented fashion, but logic has a place here too!"
        case .japan: return "In the land of precision and detail, every code tells a story."
        case .brazil: return "The Amazon holds many secrets - can you unlock this one?"
        case .egypt: return "Ancient pyramids, eternal mysteries. Let's decode the past!"
        case .usa: return "Silicon Valley - where logic meets innovation!"
        }
    }
    
    var secretStory: String {
        switch self {
        case .france: return "The prestigious École Normale Supérieure in Paris has been training brilliant minds since 1794. Its alumni include mathematicians, philosophers, and Nobel Prize winners who shaped modern thought."
        case .japan: return "Kyoto University, founded in 1897, stands as Japan's second-oldest university. Known for producing Nobel laureates and fostering innovative research in science and technology."
        case .brazil: return "The University of São Paulo, Brazil's largest and most prestigious institution, leads Latin American research and has contributed groundbreaking discoveries to global science."
        case .egypt: return "Al-Azhar University in Cairo, founded in 970 AD, is one of the world's oldest continuously operating universities, bridging ancient wisdom with modern knowledge."
        case .usa: return "Stanford University, located in the heart of Silicon Valley, has been the birthplace of countless technological innovations that transformed our digital world."
        }
    }
}

// MARK: - Hint Types
enum HintType: Codable {
    case correctPosition // Green dot
    case correctColor    // Red dot
    case wrong          // No dot
}

// MARK: - Game Attempt
struct GameAttempt: Codable, Identifiable {
    var id = UUID()
    let colors: [GameColor]
    let hints: [HintType]
    let attemptNumber: Int
    
    init(colors: [GameColor], hints: [HintType], attemptNumber: Int) {
        self.colors = colors
        self.hints = hints
        self.attemptNumber = attemptNumber
    }
}

// MARK: - Game State
enum GameState: Codable {
    case playing
    case won
    case lost
}

// MARK: - Current Row State
struct CurrentRow: Codable {
    var colors: [GameColor?]
    var selectedIndex: Int
    
    init() {
        self.colors = [nil, nil, nil, nil]
        self.selectedIndex = 0
    }
    
    var isComplete: Bool {
        return colors.allSatisfy { $0 != nil }
    }
    
    mutating func addColor(_ color: GameColor) {
        guard selectedIndex < colors.count else { return }
        colors[selectedIndex] = color
        if selectedIndex < colors.count - 1 {
            selectedIndex += 1
        }
    }
    
    mutating func selectIndex(_ index: Int) {
        guard index >= 0 && index < colors.count else { return }
        selectedIndex = index
    }
    
    mutating func reset() {
        colors = [nil, nil, nil, nil]
        selectedIndex = 0
    }
}

// MARK: - Level Model
struct GameLevel: Codable, Identifiable {
    let id: Int
    let location: GameLocation
    var isUnlocked: Bool
    var isCompleted: Bool
    var bestScore: Int? // Number of attempts to complete
    
    init(id: Int, location: GameLocation, isUnlocked: Bool = false, isCompleted: Bool = false, bestScore: Int? = nil) {
        self.id = id
        self.location = location
        self.isUnlocked = isUnlocked
        self.isCompleted = isCompleted
        self.bestScore = bestScore
    }
}

// MARK: - Achievement Model
enum AchievementType: String, CaseIterable, Codable {
    case firstGuess = "firstGuess"
    case codeBreaker = "codeBreaker"
    case persistence = "persistence"
    case worldTraveler = "worldTraveler"
    case perfection = "perfection"
    
    var title: String {
        switch self {
        case .firstGuess: return "First Guess"
        case .codeBreaker: return "Code Breaker"
        case .persistence: return "Persistence"
        case .worldTraveler: return "World Traveler"
        case .perfection: return "Perfection"
        }
    }
    
    var description: String {
        switch self {
        case .firstGuess: return "Make your first attempt"
        case .codeBreaker: return "Win a level"
        case .persistence: return "Make 10 attempts in a level"
        case .worldTraveler: return "Unlock a new location"
        case .perfection: return "Guess the code on first try"
        }
    }
    
    var reward: Int {
        return 10 // All achievements give 10 coins
    }
    
    var iconName: String {
        switch self {
        case .firstGuess: return "hand.point.up.left"
        case .codeBreaker: return "lock.open"
        case .persistence: return "repeat"
        case .worldTraveler: return "globe"
        case .perfection: return "star"
        }
    }
}

struct Achievement: Codable, Identifiable {
    var id = UUID()
    let type: AchievementType
    var isUnlocked: Bool
    var isClaimed: Bool
    
    init(type: AchievementType, isUnlocked: Bool = false, isClaimed: Bool = false) {
        self.type = type
        self.isUnlocked = isUnlocked
        self.isClaimed = isClaimed
    }
}

// MARK: - Shop Items
enum ShopItemType: String, CaseIterable, Codable {
    case background = "background"
    case skin = "skin"
    
    var displayName: String {
        return rawValue.capitalized
    }
}

struct ShopItem: Codable, Identifiable {
    let id: String
    let type: ShopItemType
    let name: String
    let price: Int
    let imageName: String
    var isPurchased: Bool
    let isDefault: Bool
    
    init(id: String, type: ShopItemType, name: String, price: Int, imageName: String, isPurchased: Bool = false, isDefault: Bool = false) {
        self.id = id
        self.type = type
        self.name = name
        self.price = price
        self.imageName = imageName
        self.isPurchased = isPurchased
        self.isDefault = isDefault
    }
}

// MARK: - Daily Reward
struct DailyReward: Codable {
    var lastClaimDate: Date?
    var consecutiveDays: Int
    var maxConsecutiveDays: Int
    
    init() {
        self.lastClaimDate = nil
        self.consecutiveDays = 0
        self.maxConsecutiveDays = 7
    }
    
    var canClaimToday: Bool {
        guard let lastClaim = lastClaimDate else { return true }
        return !Calendar.current.isDate(lastClaim, inSameDayAs: Date())
    }
    
    var todayReward: Int {
        return 10
    }
    
    mutating func claimReward() -> Int {
        let today = Date()
        
        if let lastClaim = lastClaimDate {
            let daysDifference = Calendar.current.dateComponents([.day], from: lastClaim, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                consecutiveDays = min(consecutiveDays + 1, maxConsecutiveDays)
            } else if daysDifference > 1 {
                // Streak broken
                consecutiveDays = 1
            }
        } else {
            // First claim
            consecutiveDays = 1
        }
        
        lastClaimDate = today
        return todayReward
    }
}

// MARK: - Daily Task Model
enum DailyTaskType: String, CaseIterable, Codable {
    case playGame = "playGame"
    case completeLevel = "completeLevel"
    
    var description: String {
        switch self {
        case .playGame: return "Play 1 game"
        case .completeLevel: return "Complete 1 level"
        }
    }
    
    var reward: Int {
        return 10
    }
}

struct DailyTask: Codable, Identifiable {
    var id = UUID()
    let type: DailyTaskType
    var isCompleted: Bool
    var isClaimed: Bool
    
    init(type: DailyTaskType, isCompleted: Bool = false, isClaimed: Bool = false) {
        self.type = type
        self.isCompleted = isCompleted
        self.isClaimed = isClaimed
    }
}
