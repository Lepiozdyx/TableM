//
//  MainMenuView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var playerProgress = PlayerProgressViewModel()
    
    @State private var navigateToLevelSelection = false
    @State private var showingShop = false
    @State private var showingAchievements = false
    @State private var showingSettings = false
    @State private var showingDailyReward = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundView
                
                VStack(spacing: 0) {
                    // Top section with coins and settings
                    topSection
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Game title
                    titleSection
                    
                    // Progress indicator
                    progressSection
                        .padding(.top, 30)
                    
                    Spacer()
                    
                    // Main menu buttons
                    menuButtonsSection
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Daily reward indicator
                    if playerProgress.dailyReward.canClaimToday {
                        dailyRewardButton
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLevelSelection) {
                LevelSelectionView(playerProgress: playerProgress)
            }
            .sheet(isPresented: $showingShop) {
                ShopView(playerProgress: playerProgress)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(playerProgress: playerProgress)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(playerProgress: playerProgress)
            }
            .sheet(isPresented: $showingDailyReward) {
                DailyRewardView(playerProgress: playerProgress)
            }
        }
        .onAppear {
            loadPlayerProgress()
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Top Section
    private var topSection: some View {
        HStack {
            // Coins display
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("\(playerProgress.coins)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Spacer()
            
            // Settings button
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("Table M")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Global Tournament of Mind")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 15) {
            Text("Current Progress")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 20) {
                // Current location
                VStack(spacing: 5) {
                    Text(playerProgress.currentLocation.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Current Location")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Divider()
                    .frame(height: 30)
                    .background(Color.white.opacity(0.3))
                
                // Completed levels
                VStack(spacing: 5) {
                    Text("\(playerProgress.totalLevelsCompleted)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Levels Completed")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Divider()
                    .frame(height: 30)
                    .background(Color.white.opacity(0.3))
                
                // Unlocked locations
                VStack(spacing: 5) {
                    Text("\(playerProgress.unlockedLocations.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Locations")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Menu Buttons Section
    private var menuButtonsSection: some View {
        VStack(spacing: 20) {
            // Play button (main action)
            Button(action: { navigateToLevelSelection = true }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.title2)
                    Text("Play")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.green.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            
            // Secondary buttons row
            HStack(spacing: 15) {
                // Shop button
                Button(action: { showingShop = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "cart.fill")
                            .font(.title2)
                        Text("Shop")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                // Achievements button
                Button(action: { showingAchievements = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                        Text("Achievements")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.orange.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }
    
    // MARK: - Daily Reward Button
    private var dailyRewardButton: some View {
        Button(action: { showingDailyReward = true }) {
            HStack(spacing: 10) {
                Image(systemName: "gift.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                
                Text("Daily Reward Available!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.yellow.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    private func loadPlayerProgress() {
        // Load saved progress from DataManager
        let loadedProgress = DataManager.shared.loadPlayerProgress()
        
        // Update current progress with loaded data
        playerProgress.coins = loadedProgress.coins
        playerProgress.levels = loadedProgress.levels
        playerProgress.achievements = loadedProgress.achievements
        playerProgress.shopItems = loadedProgress.shopItems
        playerProgress.dailyReward = loadedProgress.dailyReward
        playerProgress.selectedBackground = loadedProgress.selectedBackground
        playerProgress.selectedSkin = loadedProgress.selectedSkin
        playerProgress.currentLocation = loadedProgress.currentLocation
        playerProgress.unlockedLocations = loadedProgress.unlockedLocations
        playerProgress.isMusicEnabled = loadedProgress.isMusicEnabled
        playerProgress.isSoundEnabled = loadedProgress.isSoundEnabled
        playerProgress.musicVolume = loadedProgress.musicVolume
        playerProgress.soundVolume = loadedProgress.soundVolume
        playerProgress.dailyTasks = loadedProgress.dailyTasks
        playerProgress.totalGamesPlayed = loadedProgress.totalGamesPlayed
        playerProgress.totalLevelsCompleted = loadedProgress.totalLevelsCompleted
        playerProgress.perfectGames = loadedProgress.perfectGames
    }
}

#Preview {
    MainMenuView()
}
