//
//  MainMenuView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject private var appState = AppStateManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var navigateToLevelSelection = false
    @State private var showingShop = false
    @State private var showingAchievements = false
    @State private var showingSettings = false
    @State private var showingDailyReward = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if appState.isDataLoaded {
                    // Background
                    BackgroundView(playerProgress: appState.playerProgress)
                    
                    VStack(spacing: 0) {
                        // Top section with coins and settings
                        topSection
                        
                        Spacer()
                        
                        // Main menu buttons
                        menuButtonsSection
                        
                        Spacer()
                        
                        // Daily reward indicator
                        if appState.playerProgress.dailyReward.canClaimToday {
                            dailyRewardButton
                        }
                    }
                } else {
                    // Loading screen
                    LoadingView()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLevelSelection) {
                LevelSelectionView()
            }
            .sheet(isPresented: $showingShop) {
                ShopView()
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingDailyReward) {
                DailyRewardView()
            }
            .onChange(of: scenePhase) { newPhase in
                handleScenePhaseChange(newPhase)
            }
            .onAppear {
                // FIXED: Force refresh data when view appears
                refreshDataIfNeeded()
            }
        }
    }
    
    // MARK: - Top Section
    private var topSection: some View {
        HStack {
            ScoreboardView(coins: appState.playerProgress.coins)
                .id("scoreboard-\(appState.playerProgress.coins)")
            
            Spacer()
            
            // Settings button
            Button(action: {
                SettingsViewModel.shared.playButtonSound()
                showingSettings = true
            }) {
                Image(.btn1)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(.gear)
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                    }
            }
        }
        .padding()
    }
    
    // MARK: - Menu Buttons Section
    private var menuButtonsSection: some View {
        VStack(spacing: 30) {
            // Play button (main action)
            Button(action: {
                SettingsViewModel.shared.playButtonSound()
                navigateToLevelSelection = true
            }) {
                Text("Play")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: 200, maxHeight: 80)
                    .background(
                        Image(.btn3)
                            .resizable()
                    )
            }
            
            // Shop button
            Button(action: {
                SettingsViewModel.shared.playButtonSound()
                showingShop = true
            }) {
                Text("Shop")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: 200, maxHeight: 80)
                    .background(
                        Image(.btn2)
                            .resizable()
                    )
            }
            
            // Achievements button
            Button(action: {
                SettingsViewModel.shared.playButtonSound()
                showingAchievements = true
            }) {
                Text("Achievements")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: 200, maxHeight: 80)
                    .background(
                        Image(.btn2)
                            .resizable()
                    )
            }
        }
    }
    
    // MARK: - Daily Reward Button
    private var dailyRewardButton: some View {
        Button(action: {
            SettingsViewModel.shared.playButtonSound()
            showingDailyReward = true
        }) {
            Image(systemName: "gift.fill")
                .font(.system(size: 32))
                .foregroundColor(.indigo)
                .frame(width: 50, height: 50)
                .background(
                    Image(.btn1)
                        .resizable()
                )
        }
        .padding()
    }
    
    // MARK: - Data Refresh Helper
    private func refreshDataIfNeeded() {
        // FIXED: Force reload data when returning to main menu
        if appState.isDataLoaded {
            appState.forceReload()
        }
    }
    
    // MARK: - App Lifecycle Management
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            appState.handleAppDidBecomeActive()
            // FIXED: Also refresh data when app becomes active
            refreshDataIfNeeded()
        case .background, .inactive:
            appState.handleAppWillResignActive()
        @unknown default:
            break
        }
    }
}

#Preview {
    MainMenuView()
}
