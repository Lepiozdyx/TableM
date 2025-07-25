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
                // Background
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Audio Settings Section
                        audioSettingsSection
                        
                        // Game Settings Section
                        gameSettingsSection
                        
                        // About Section
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
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
    
    // MARK: - Audio Settings Section
    private var audioSettingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Audio")
            
            VStack(spacing: 25) {
                // Music Settings
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "music.note")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        Text("Music")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(Int(playerProgress.musicVolume * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(minWidth: 40)
                    }
                    
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
                
                Divider()
                
                // Sound Effects Settings
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                            .font(.title2)
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        Text("Sounds")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(Int(playerProgress.soundVolume * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(minWidth: 40)
                    }
                    
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
        .padding(20)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    // MARK: - Game Settings Section
    private var gameSettingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Game")
            
            VStack(spacing: 15) {
                // Reset Progress Button
                SettingsRowView(
                    icon: "arrow.counterclockwise",
                    iconColor: .red,
                    title: "Reset Progress",
                    subtitle: "Clear all game data",
                    showChevron: false
                ) {
                    showingResetAlert = true
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("About")
            
            VStack(spacing: 15) {
                // App Version
                SettingsRowView(
                    icon: "info.circle",
                    iconColor: .blue,
                    title: "Version",
                    subtitle: "1.0.0",
                    showChevron: false
                )
                
                Divider()
                
                // Developer
                SettingsRowView(
                    icon: "person.circle",
                    iconColor: .purple,
                    title: "Developer",
                    subtitle: "Table M Games",
                    showChevron: false
                )
                
                Divider()
                
                // Game Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About Table M")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("A logic puzzle game where you crack secret color codes using deduction and systematic thinking. Travel the world and unlock the mysteries of each location!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
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

// MARK: - Settings Row Component
struct SettingsRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let showChevron: Bool
    let action: (() -> Void)?
    
    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String? = nil,
        showChevron: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .disabled(action == nil)
    }
}

#Preview {
    SettingsView(playerProgress: PlayerProgressViewModel())
}
