//
//  AppStateManager.swift
//  TableM
//
//  Created by Alex on 27.07.2025.
//

import SwiftUI

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var playerProgress: PlayerProgressViewModel
    @Published var isDataLoaded = false
    @Published var isInitialized = false
    
    private let dataManager = DataManager.shared
    
    private init() {
        // Initialize with empty progress initially
        self.playerProgress = PlayerProgressViewModel()
        
        // Start loading data
        loadInitialData()
    }
    
    // MARK: - Initialization
    private func loadInitialData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Load saved progress
            let savedProgress = self?.dataManager.loadPlayerProgress() ?? PlayerProgressViewModel()
            
            DispatchQueue.main.async {
                self?.playerProgress = savedProgress
                self?.isDataLoaded = true
                
                // Initialize audio system
                self?.initializeAudioSystem()
                
                self?.isInitialized = true
            }
        }
    }
    
    // MARK: - Audio System Integration
    private func initializeAudioSystem() {
        SettingsViewModel.shared.setPlayerProgress(playerProgress)
    }
    
    // MARK: - Data Management
    func saveProgress() {
        guard isDataLoaded else { return }
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            self.dataManager.savePlayerProgress(self.playerProgress)
        }
    }
    
    func forceReload() {
        let savedProgress = dataManager.loadPlayerProgress()
        self.playerProgress = savedProgress
        SettingsViewModel.shared.setPlayerProgress(playerProgress)
    }
    
    func resetProgress() {
        dataManager.resetPlayerProgress()
        let freshProgress = dataManager.loadPlayerProgress()
        self.playerProgress = freshProgress
        SettingsViewModel.shared.setPlayerProgress(playerProgress)
    }
    
    // MARK: - Game Actions
    func completeLevel(location: GameLocation, levelId: Int, attempts: Int) {
        playerProgress.completeLevel(location: location, levelId: levelId, attempts: attempts)
        saveProgress()
    }
    
    func recordGamePlayed() {
        playerProgress.recordGamePlayed()
        saveProgress()
    }
    
    func recordPersistentPlay() {
        playerProgress.recordPersistentPlay()
        saveProgress()
    }
    
    func purchaseShopItem(_ item: ShopItem) -> Bool {
        let success = playerProgress.purchaseItem(item)
        if success {
            saveProgress()
        }
        return success
    }
    
    func selectBackground(_ backgroundId: String) {
        playerProgress.selectBackground(backgroundId)
        saveProgress()
    }
    
    func selectSkin(_ skinId: String) {
        playerProgress.selectSkin(skinId)
        saveProgress()
    }
    
    func claimAchievement(_ type: AchievementType) -> Int {
        let reward = playerProgress.claimAchievement(type)
        if reward > 0 {
            saveProgress()
        }
        return reward
    }
    
    func claimDailyReward() -> Int {
        let reward = playerProgress.claimDailyReward()
        if reward > 0 {
            saveProgress()
        }
        return reward
    }
    
    func updateCurrentLocation(_ location: GameLocation) {
        playerProgress.currentLocation = location
        saveProgress()
    }
    
    // MARK: - Settings Management
    func updateMusicVolume(_ volume: Double) {
        playerProgress.musicVolume = volume
        playerProgress.isMusicEnabled = volume > 0
        SettingsViewModel.shared.updateMusicVolume(volume)
        saveProgress()
    }
    
    func updateSoundVolume(_ volume: Double) {
        playerProgress.soundVolume = volume
        playerProgress.isSoundEnabled = volume > 0
        SettingsViewModel.shared.updateSoundVolume(volume)
        saveProgress()
    }
    
    // MARK: - App Lifecycle
    func handleAppWillResignActive() {
        saveProgress()
        SettingsViewModel.shared.pauseAllAudio()
    }
    
    func handleAppDidBecomeActive() {
        // Reload data to catch any external changes
        if isDataLoaded {
            forceReload()
        }
        
        // Resume audio if needed
        if playerProgress.isMusicEnabled && playerProgress.musicVolume > 0 {
            SettingsViewModel.shared.resumeAllAudio()
        }
    }
    
    func handleAppWillTerminate() {
        saveProgress()
        SettingsViewModel.shared.stopAllAudio()
    }
    
    // MARK: - Validation
    func validateData() -> Bool {
        return dataManager.validateSavedData()
    }
    
    // MARK: - Debug Methods
    #if DEBUG
    func printCurrentState() {
        print("=== App State Debug ===")
        print("Data Loaded: \(isDataLoaded)")
        print("Initialized: \(isInitialized)")
        print("Coins: \(playerProgress.coins)")
        print("Current Location: \(playerProgress.currentLocation.displayName)")
        print("Total Games Played: \(playerProgress.totalGamesPlayed)")
        print("Total Levels Completed: \(playerProgress.totalLevelsCompleted)")
        print("Unlocked Locations: \(playerProgress.unlockedLocations.map { $0.displayName })")
        print("======================")
    }
    
    func exportData() -> String? {
        return dataManager.exportDataAsJSON()
    }
    #endif
}
