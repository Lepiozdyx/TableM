//
//  AchievementsView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject private var appState = AppStateManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                BackgroundView(playerProgress: appState.playerProgress)
                
                VStack(spacing: 0) {
                    // Top Navigation
                    topNavigationBar
                    
                    // Achievements List
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(appState.playerProgress.achievements) { achievement in
                                AchievementCard(
                                    achievement: achievement,
                                    onClaim: {
                                        claimAchievement(achievement.type)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Coins Display
            ScoreboardView(coins: appState.playerProgress.coins)
            
            Spacer()
            
            // Back/Home Button
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
    
    // MARK: - Helper Methods
    private func claimAchievement(_ type: AchievementType) {
        let reward = appState.claimAchievement(type)
        if reward > 0 {
            SettingsViewModel.shared.playVictorySound()
        } else {
            SettingsViewModel.shared.playDefeatSound()
        }
    }
}

// MARK: - Achievement Card Component
struct AchievementCard: View {
    let achievement: Achievement
    let onClaim: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Achievement Info
            VStack(alignment: .leading, spacing: 8) {
                Text(achievement.type.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(achievement.type.description)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Reward info
                if achievement.isUnlocked && !achievement.isClaimed {
                    Text("+\(achievement.type.reward)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Action Button or Status
            actionSection
        }
        .padding(.horizontal)
        .padding(.vertical, 25)
        .background(
            Image(.underlay2)
                .resizable()
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
    
    // MARK: - Action Section
    private var actionSection: some View {
        Group {
            if achievement.isClaimed {
                // Already claimed
                Text("Claimed")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 36)
                    .background(
                        Image(.btn2)
                            .resizable()
                    )
            } else if achievement.isUnlocked {
                // Ready to claim
                Button(action: onClaim) {
                    Text("Get")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 70, height: 36)
                        .background(
                            Image(.btn3)
                                .resizable()
                        )
                }
            } else {
                // Not unlocked yet
                VStack(spacing: 4) {
                    Image(.lock)
                        .resizable()
                        .frame(width: 20, height: 25)
                    
                    Text("Locked")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    AchievementsView()
}
