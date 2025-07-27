//
//  SettingsView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView(playerProgress: playerProgress)
                
                VStack {
                    topNavigationBar
                    
                    Spacer()
                    
                    // Audio Settings Section
                    audioSettingsSection
                    
                    Spacer()
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            setupAudioSettings()
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetGameProgress()
            }
        } message: {
            Text("This will permanently delete all your progress, coins, and achievements. This action cannot be undone.")
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            Spacer()
            
            // Home Button
            Button(action: { dismiss() }) {
                Image(.btn1)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(.home)
                            .resizable()
                            .padding(10)
                    }
            }
        }
        .padding()
    }
    
    // MARK: - Audio Settings Section
    private var audioSettingsSection: some View {
        VStack(spacing: 20) {
            sectionHeader("Settings")
                .padding(.top, 20)
                .padding(.bottom, 30)
            
            VStack(spacing: 25) {
                // Music Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Music")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Slider(
                        value: $playerProgress.musicVolume,
                        in: 0...1,
                        step: 0.1
                    ) {
                        Text("Music Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker")
                            .foregroundColor(.gray)
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3")
                            .foregroundColor(.gray)
                    }
                    .onChange(of: playerProgress.musicVolume) { newValue in
                        settingsViewModel.updateMusicVolume(newValue)
                        playerProgress.isMusicEnabled = newValue > 0
                    }
                }
                
                // Sound Effects Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sound")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Slider(
                        value: $playerProgress.soundVolume,
                        in: 0...1,
                        step: 0.1
                    ) {
                        Text("Sound Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker")
                            .foregroundColor(.gray)
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3")
                            .foregroundColor(.gray)
                    }
                    .onChange(of: playerProgress.soundVolume) { newValue in
                        settingsViewModel.updateSoundVolume(newValue)
                        playerProgress.isSoundEnabled = newValue > 0
                    }
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 100)
        .background(
            Image(.underlay1)
                .resizable()
        )
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(.gray)
    }
    
    // MARK: - Helper Methods
    private func setupAudioSettings() {
        settingsViewModel.setupAudio()
        settingsViewModel.updateMusicVolume(playerProgress.musicVolume)
        settingsViewModel.updateSoundVolume(playerProgress.soundVolume)
        
        if playerProgress.isMusicEnabled && playerProgress.musicVolume > 0 {
            settingsViewModel.startBackgroundMusic()
        }
    }
    
    private func saveSettings() {
        // Update enabled states based on volume
        playerProgress.isMusicEnabled = playerProgress.musicVolume > 0
        playerProgress.isSoundEnabled = playerProgress.soundVolume > 0
        
        // Save to persistent storage
        DataManager.shared.savePlayerProgress(playerProgress)
        
        // Apply audio settings
        settingsViewModel.applyAudioSettings(
            musicVolume: playerProgress.musicVolume,
            soundVolume: playerProgress.soundVolume,
            musicEnabled: playerProgress.isMusicEnabled,
            soundEnabled: playerProgress.isSoundEnabled
        )
    }
    
    private func resetGameProgress() {
        // Stop all audio
        settingsViewModel.stopAllAudio()
        
        // Reset progress
        DataManager.shared.resetPlayerProgress()
        
        // Load fresh progress
        let freshProgress = DataManager.shared.loadPlayerProgress()
        
        // Update current progress with fresh data
        playerProgress.coins = freshProgress.coins
        playerProgress.levels = freshProgress.levels
        playerProgress.achievements = freshProgress.achievements
        playerProgress.shopItems = freshProgress.shopItems
        playerProgress.dailyReward = freshProgress.dailyReward
        playerProgress.selectedBackground = freshProgress.selectedBackground
        playerProgress.selectedSkin = freshProgress.selectedSkin
        playerProgress.currentLocation = freshProgress.currentLocation
        playerProgress.unlockedLocations = freshProgress.unlockedLocations
        playerProgress.isMusicEnabled = freshProgress.isMusicEnabled
        playerProgress.isSoundEnabled = freshProgress.isSoundEnabled
        playerProgress.musicVolume = freshProgress.musicVolume
        playerProgress.soundVolume = freshProgress.soundVolume
        playerProgress.dailyTasks = freshProgress.dailyTasks
        playerProgress.totalGamesPlayed = freshProgress.totalGamesPlayed
        playerProgress.totalLevelsCompleted = freshProgress.totalLevelsCompleted
        playerProgress.perfectGames = freshProgress.perfectGames
        
        // Restart audio with fresh settings
        setupAudioSettings()
    }
}

#Preview {
    SettingsView(playerProgress: PlayerProgressViewModel())
}
