//
//  PlayerProgressViewModel.swift
//  TableM
//
//  Created by Alex on 23.07.2025.
//

import Foundation

// MARK: - Player Progress ViewModel
class PlayerProgressViewModel: ObservableObject, Codable {
    @Published var coins: Int
    @Published var levels: [GameLevel]
    @Published var achievements: [Achievement]
    @Published var shopItems: [ShopItem]
    @Published var dailyReward: DailyReward
    @Published var selectedBackground: String
    @Published var selectedSkin: String
    @Published var currentLocation: GameLocation
    @Published var unlockedLocations: Set<GameLocation>
    
    // Settings
    @Published var isMusicEnabled: Bool
    @Published var isSoundEnabled: Bool
    @Published var musicVolume: Double
    @Published var soundVolume: Double
    
    // Daily Tasks
    @Published var dailyTasks: [DailyTask]
    
    // Statistics
    @Published var totalGamesPlayed: Int
    @Published var totalLevelsCompleted: Int
    @Published var perfectGames: Int // Games won on first try
    
    init() {
        self.coins = 0
        self.currentLocation = .france
        self.unlockedLocations = [.france]
        self.selectedBackground = "default"
        self.selectedSkin = "default"
        
        // Audio settings
        self.isMusicEnabled = true
        self.isSoundEnabled = true
        self.musicVolume = 0.7
        self.soundVolume = 0.8
        
        // Statistics
        self.totalGamesPlayed = 0
        self.totalLevelsCompleted = 0
        self.perfectGames = 0
        
        // Initialize levels
        self.levels = PlayerProgressViewModel.createInitialLevels()
        
        // Initialize achievements
        self.achievements = AchievementType.allCases.map { Achievement(type: $0) }
        
        // Initialize shop items
        self.shopItems = PlayerProgressViewModel.createShopItems()
        
        // Initialize daily reward
        self.dailyReward = DailyReward()
        
        // Initialize daily tasks
        self.dailyTasks = PlayerProgressViewModel.createDailyTasks()
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case coins, levels, achievements, shopItems, dailyReward
        case selectedBackground, selectedSkin, currentLocation, unlockedLocations
        case isMusicEnabled, isSoundEnabled, musicVolume, soundVolume
        case dailyTasks, totalGamesPlayed, totalLevelsCompleted, perfectGames
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        coins = try container.decode(Int.self, forKey: .coins)
        levels = try container.decode([GameLevel].self, forKey: .levels)
        achievements = try container.decode([Achievement].self, forKey: .achievements)
        shopItems = try container.decode([ShopItem].self, forKey: .shopItems)
        dailyReward = try container.decode(DailyReward.self, forKey: .dailyReward)
        selectedBackground = try container.decode(String.self, forKey: .selectedBackground)
        selectedSkin = try container.decode(String.self, forKey: .selectedSkin)
        currentLocation = try container.decode(GameLocation.self, forKey: .currentLocation)
        unlockedLocations = try container.decode(Set<GameLocation>.self, forKey: .unlockedLocations)
        
        isMusicEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMusicEnabled) ?? true
        isSoundEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSoundEnabled) ?? true
        musicVolume = try container.decodeIfPresent(Double.self, forKey: .musicVolume) ?? 0.7
        soundVolume = try container.decodeIfPresent(Double.self, forKey: .soundVolume) ?? 0.8
        
        dailyTasks = try container.decodeIfPresent([DailyTask].self, forKey: .dailyTasks) ?? PlayerProgressViewModel.createDailyTasks()
        totalGamesPlayed = try container.decodeIfPresent(Int.self, forKey: .totalGamesPlayed) ?? 0
        totalLevelsCompleted = try container.decodeIfPresent(Int.self, forKey: .totalLevelsCompleted) ?? 0
        perfectGames = try container.decodeIfPresent(Int.self, forKey: .perfectGames) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(coins, forKey: .coins)
        try container.encode(levels, forKey: .levels)
        try container.encode(achievements, forKey: .achievements)
        try container.encode(shopItems, forKey: .shopItems)
        try container.encode(dailyReward, forKey: .dailyReward)
        try container.encode(selectedBackground, forKey: .selectedBackground)
        try container.encode(selectedSkin, forKey: .selectedSkin)
        try container.encode(currentLocation, forKey: .currentLocation)
        try container.encode(unlockedLocations, forKey: .unlockedLocations)
        
        try container.encode(isMusicEnabled, forKey: .isMusicEnabled)
        try container.encode(isSoundEnabled, forKey: .isSoundEnabled)
        try container.encode(musicVolume, forKey: .musicVolume)
        try container.encode(soundVolume, forKey: .soundVolume)
        
        try container.encode(dailyTasks, forKey: .dailyTasks)
        try container.encode(totalGamesPlayed, forKey: .totalGamesPlayed)
        try container.encode(totalLevelsCompleted, forKey: .totalLevelsCompleted)
        try container.encode(perfectGames, forKey: .perfectGames)
    }
    
    // MARK: - Level Management
    func levelForLocationAndId(location: GameLocation, levelId: Int) -> GameLevel? {
        return levels.first { $0.location == location && $0.id == levelId }
    }
    
    func levelsForLocation(_ location: GameLocation) -> [GameLevel] {
        return levels.filter { $0.location == location }.sorted { $0.id < $1.id }
    }
    
    func unlockLevel(location: GameLocation, levelId: Int) {
        if let index = levels.firstIndex(where: { $0.location == location && $0.id == levelId }) {
            levels[index].isUnlocked = true
        }
    }
    
    func completeLevel(location: GameLocation, levelId: Int, attempts: Int) {
        if let index = levels.firstIndex(where: { $0.location == location && $0.id == levelId }) {
            let wasCompleted = levels[index].isCompleted
            levels[index].isCompleted = true
            
            // Update best score if this is better
            if levels[index].bestScore == nil || attempts < levels[index].bestScore! {
                levels[index].bestScore = attempts
            }
            
            // Award coins for completion
            if !wasCompleted {
                coins += 100
                totalLevelsCompleted += 1
                
                // Check for perfect game
                if attempts == 1 {
                    perfectGames += 1
                    unlockAchievement(.perfection)
                }
                
                // Unlock next level or location
                unlockNextContent(location: location, levelId: levelId)
                
                // Check achievements
                checkAchievements()
            }
        }
    }
    
    private func unlockNextContent(location: GameLocation, levelId: Int) {
        if levelId < 5 {
            // Unlock next level in same location
            unlockLevel(location: location, levelId: levelId + 1)
        } else {
            // Completed all levels in location, unlock next location
            if let currentIndex = GameLocation.allCases.firstIndex(of: location),
               currentIndex + 1 < GameLocation.allCases.count {
                let nextLocation = GameLocation.allCases[currentIndex + 1]
                unlockedLocations.insert(nextLocation)
                unlockLevel(location: nextLocation, levelId: 1)
                unlockAchievement(.worldTraveler)
            }
        }
    }
    
    // MARK: - Achievement Management
    func unlockAchievement(_ type: AchievementType) {
        if let index = achievements.firstIndex(where: { $0.type == type && !$0.isUnlocked }) {
            achievements[index].isUnlocked = true
        }
    }
    
    func claimAchievement(_ type: AchievementType) -> Int {
        if let index = achievements.firstIndex(where: { $0.type == type && $0.isUnlocked && !$0.isClaimed }) {
            achievements[index].isClaimed = true
            let reward = type.reward
            coins += reward
            return reward
        }
        return 0
    }
    
    private func checkAchievements() {
        // Code Breaker - Win a level
        if totalLevelsCompleted > 0 {
            unlockAchievement(.codeBreaker)
        }
        
        // World Traveler - checked in unlockNextContent
        // Perfection - checked in completeLevel
    }
    
    // MARK: - Shop Management
    func purchaseItem(_ item: ShopItem) -> Bool {
        guard coins >= item.price, !item.isPurchased else { return false }
        
        if let index = shopItems.firstIndex(where: { $0.id == item.id }) {
            shopItems[index].isPurchased = true
            coins -= item.price
            return true
        }
        return false
    }
    
    func selectBackground(_ backgroundId: String) {
        if let _ = shopItems.first(where: { $0.id == backgroundId && $0.type == .background && ($0.isPurchased || $0.isDefault) }) {
            selectedBackground = backgroundId
        }
    }
    
    func selectSkin(_ skinId: String) {
        if let _ = shopItems.first(where: { $0.id == skinId && $0.type == .skin && ($0.isPurchased || $0.isDefault) }) {
            selectedSkin = skinId
        }
    }
    
    // MARK: - Helper Methods for UI
    func getSelectedBackgroundImageName() -> String {
        return shopItems.first(where: { $0.id == selectedBackground && $0.type == .background })?.imageName ?? "bg_default"
    }
    
    func getSelectedSkinImageName() -> String {
        return shopItems.first(where: { $0.id == selectedSkin && $0.type == .skin })?.imageName ?? "skin_default"
    }
    
    // MARK: - Daily Rewards
    func claimDailyReward() -> Int {
        guard dailyReward.canClaimToday else { return 0 }
        let reward = dailyReward.claimReward()
        coins += reward
        return reward
    }
    
    // MARK: - Game Statistics
    func recordGamePlayed() {
        totalGamesPlayed += 1
        unlockAchievement(.firstGuess)
    }
    
    func recordPersistentPlay() {
        unlockAchievement(.persistence)
    }
    
    // MARK: - Static Factory Methods
    private static func createInitialLevels() -> [GameLevel] {
        var levels: [GameLevel] = []
        
        for location in GameLocation.allCases {
            for levelId in 1...5 {
                let isUnlocked = (location == .france && levelId == 1)
                levels.append(GameLevel(id: levelId, location: location, isUnlocked: isUnlocked))
            }
        }
        
        return levels
    }
    
    private static func createShopItems() -> [ShopItem] {
        var items: [ShopItem] = []
        
        // Backgrounds
        items.append(ShopItem(id: "default", type: .background, name: "Classic", price: 0, imageName: "bg_default", isPurchased: true, isDefault: true))
        items.append(ShopItem(id: "lab", type: .background, name: "Lab", price: 200, imageName: "bg_lab"))
        items.append(ShopItem(id: "garden", type: .background, name: "Garden", price: 200, imageName: "bg_garden"))
        items.append(ShopItem(id: "neon", type: .background, name: "Neon", price: 300, imageName: "bg_neon"))
        
        // Skins
        items.append(ShopItem(id: "default", type: .skin, name: "Classic", price: 0, imageName: "skin_default", isPurchased: true, isDefault: true))
        items.append(ShopItem(id: "arctic", type: .skin, name: "Arctic", price: 150, imageName: "skin_arctic"))
        items.append(ShopItem(id: "zen", type: .skin, name: "Zen", price: 250, imageName: "skin_zen"))
        items.append(ShopItem(id: "cyber", type: .skin, name: "Cyber", price: 400, imageName: "skin_cyber"))
        
        return items
    }
    
    private static func createDailyTasks() -> [DailyTask] {
        return [
            DailyTask(type: .playGame, isCompleted: false),
            DailyTask(type: .completeLevel, isCompleted: false)
        ]
    }
}
