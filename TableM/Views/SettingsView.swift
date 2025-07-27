//
//  SettingsView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
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
            // Just sync the reference, don't reinitialize
            SettingsViewModel.shared.playerProgress = playerProgress
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
                        SettingsViewModel.shared.updateMusicVolume(newValue)
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
                        SettingsViewModel.shared.updateSoundVolume(newValue)
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
    private func resetGameProgress() {
        // Stop all audio
        SettingsViewModel.shared.stopAllAudio()
        
        // Reset progress in DataManager
        DataManager.shared.resetPlayerProgress()
        
        // Reload fresh progress
        let freshProgress = DataManager.shared.loadPlayerProgress()
        
        // Update all properties of current playerProgress with fresh data
        updatePlayerProgress(with: freshProgress)
        
        // Re-setup SettingsViewModel with fresh progress
        SettingsViewModel.shared.setPlayerProgress(playerProgress)
    }
    
    private func updatePlayerProgress(with freshProgress: PlayerProgressViewModel) {
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
    }
}

#Preview {
    SettingsView(playerProgress: PlayerProgressViewModel())
}
