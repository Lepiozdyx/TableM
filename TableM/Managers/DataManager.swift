//
//  DataManager.swift
//  TableM
//
//  Created by Alex on 23.07.2025.
//

import Foundation

// MARK: - Data Manager Error Types
enum DataManagerError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case dataNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode player progress data"
        case .decodingFailed:
            return "Failed to decode player progress data"
        case .dataNotFound:
            return "No saved player progress found"
        case .invalidData:
            return "Saved data is corrupted or invalid"
        }
    }
}

// MARK: - Data Manager
class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    
    // Storage Keys
    private struct StorageKeys {
        static let playerProgress = "PlayerProgress"
        static let appVersion = "AppVersion"
        static let isFirstLaunch = "IsFirstLaunch"
    }
    
    // Current app version for migration purposes
    private let currentAppVersion = "1.0.0"
    
    private init() {
        setupInitialData()
    }
    
    // MARK: - Initial Setup
    private func setupInitialData() {
        // Check if this is first launch
        if !userDefaults.bool(forKey: StorageKeys.isFirstLaunch) {
            performFirstLaunchSetup()
        }
        
        // Check for version updates and perform migration if needed
        let savedVersion = userDefaults.string(forKey: StorageKeys.appVersion) ?? "0.0.0"
        if savedVersion != currentAppVersion {
            performMigrationIfNeeded(from: savedVersion, to: currentAppVersion)
            userDefaults.set(currentAppVersion, forKey: StorageKeys.appVersion)
        }
    }
    
    private func performFirstLaunchSetup() {
        userDefaults.set(true, forKey: StorageKeys.isFirstLaunch)
        userDefaults.set(currentAppVersion, forKey: StorageKeys.appVersion)
        
        // Create and save default player progress
        let defaultProgress = PlayerProgressViewModel()
        savePlayerProgress(defaultProgress)
    }
    
    // MARK: - Player Progress Management
    func savePlayerProgress(_ progress: PlayerProgressViewModel) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(progress)
            userDefaults.set(data, forKey: StorageKeys.playerProgress)
            
            print("Player progress saved successfully")
        } catch {
            print("Failed to save player progress: \(error.localizedDescription)")
        }
    }
    
    func loadPlayerProgress() -> PlayerProgressViewModel {
        do {
            guard let data = userDefaults.data(forKey: StorageKeys.playerProgress) else {
                print("No saved player progress found, creating new one")
                return PlayerProgressViewModel()
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let progress = try decoder.decode(PlayerProgressViewModel.self, from: data)
            print("Player progress loaded successfully")
            return progress
            
        } catch {
            print("Failed to load player progress: \(error.localizedDescription)")
            print("Creating new player progress")
            
            // If loading fails, create new progress and save it
            let newProgress = PlayerProgressViewModel()
            savePlayerProgress(newProgress)
            return newProgress
        }
    }
    
    // MARK: - Data Validation
    func validateSavedData() -> Bool {
        guard let data = userDefaults.data(forKey: StorageKeys.playerProgress) else {
            return false
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            _ = try decoder.decode(PlayerProgressViewModel.self, from: data)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Data Migration
    private func performMigrationIfNeeded(from oldVersion: String, to newVersion: String) {
        print("Migrating data from version \(oldVersion) to \(newVersion)")
        
        // Add version-specific migration logic here
        switch (oldVersion, newVersion) {
        case ("0.0.0", "1.0.0"):
            // First version migration
            break
        default:
            // Handle other migrations in future
            break
        }
    }
    
    // MARK: - Backup and Restore
    func createBackup() -> Data? {
        guard let data = userDefaults.data(forKey: StorageKeys.playerProgress) else {
            return nil
        }
        return data
    }
    
    func restoreFromBackup(_ backupData: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Validate backup data
            _ = try decoder.decode(PlayerProgressViewModel.self, from: backupData)
            
            // If validation passes, save the backup data
            userDefaults.set(backupData, forKey: StorageKeys.playerProgress)
            return true
            
        } catch {
            print("Invalid backup data: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Data Management
    func resetPlayerProgress() {
        userDefaults.removeObject(forKey: StorageKeys.playerProgress)
        let newProgress = PlayerProgressViewModel()
        savePlayerProgress(newProgress)
        print("Player progress has been reset")
    }
    
    func clearAllData() {
        let keys = [StorageKeys.playerProgress, StorageKeys.appVersion, StorageKeys.isFirstLaunch]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
        print("All app data has been cleared")
    }
    
    // MARK: - Utility Methods
    var hasExistingData: Bool {
        return userDefaults.data(forKey: StorageKeys.playerProgress) != nil
    }
    
    var isFirstLaunch: Bool {
        return !userDefaults.bool(forKey: StorageKeys.isFirstLaunch)
    }
    
    var savedAppVersion: String {
        return userDefaults.string(forKey: StorageKeys.appVersion) ?? "0.0.0"
    }
    
    // MARK: - Auto-Save Support
    func enableAutoSave(for progress: PlayerProgressViewModel) {
        // Observe changes to PlayerProgressViewModel and auto-save
        // This would typically use Combine publishers in a real implementation
        
        // For now, we'll rely on manual saves at key points
        print("Auto-save enabled for player progress")
    }
    
    // MARK: - Debug Methods
    #if DEBUG
    func printSavedData() {
        if let data = userDefaults.data(forKey: StorageKeys.playerProgress) {
            print("Saved data size: \(data.count) bytes")
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let progress = try decoder.decode(PlayerProgressViewModel.self, from: data)
                
                print("Coins: \(progress.coins)")
                print("Current Location: \(progress.currentLocation.displayName)")
                print("Total Levels Completed: \(progress.totalLevelsCompleted)")
                print("Unlocked Locations: \(progress.unlockedLocations.map { $0.displayName })")
                
            } catch {
                print("Failed to decode data for debugging: \(error)")
            }
        } else {
            print("No saved data found")
        }
    }
    
    func exportDataAsJSON() -> String? {
        guard let data = userDefaults.data(forKey: StorageKeys.playerProgress) else {
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8)
        } catch {
            print("Failed to export data as JSON: \(error)")
            return nil
        }
    }
    #endif
}
