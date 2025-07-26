//
//  MainMenuView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var viewModel = PlayerProgressViewModel()
    
//    @Environment(\.scenePhase) private var phase
    
    @State private var navigateToLevelSelection = false
    @State private var showingShop = false
    @State private var showingAchievements = false
    @State private var showingSettings = false
    @State private var showingDailyReward = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                BackgroundView(playerProgress: viewModel)
                
                VStack(spacing: 0) {
                    // Top section with coins and settings
                    topSection
                    
                    Spacer()
                    
                    // Main menu buttons
                    menuButtonsSection
                    
                    Spacer()
                    
                    // Daily reward indicator
                    if viewModel.dailyReward.canClaimToday {
                        dailyRewardButton
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLevelSelection) {
                LevelSelectionView(playerProgress: viewModel)
            }
            .sheet(isPresented: $showingShop) {
                ShopView(playerProgress: viewModel)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(playerProgress: viewModel)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(playerProgress: viewModel)
            }
            .sheet(isPresented: $showingDailyReward) {
                DailyRewardView(playerProgress: viewModel)
            }
        }
    }
    
    // MARK: - Top Section
    private var topSection: some View {
        HStack {
            // Coins display
            ScoreboardView(coins: viewModel.coins)
            
            Spacer()
            
            // Settings button
            Button(action: { showingSettings = true }) {
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
            Button(action: { navigateToLevelSelection = true }) {
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
            Button(action: { showingShop = true }) {
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
            Button(action: { showingAchievements = true }) {
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
        Button(action: { showingDailyReward = true }) {
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
}

#Preview {
    MainMenuView()
}
