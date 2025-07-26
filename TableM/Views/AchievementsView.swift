//
//  AchievementsView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundView
                
                VStack(spacing: 0) {
                    // Top Navigation
                    topNavigationBar
                    
                    // Achievements List
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(playerProgress.achievements) { achievement in
                                AchievementCard(
                                    achievement: achievement,
                                    onClaim: {
                                        claimAchievement(achievement.type)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarHidden(true)
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
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Back/Home Button
            Button(action: { dismiss() }) {
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Title
            Text("Achievements")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            // Coins Display
            HStack(spacing: 8) {
                Text("\(playerProgress.coins)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Helper Methods
    private func claimAchievement(_ type: AchievementType) {
        let reward = playerProgress.claimAchievement(type)
        if reward > 0 {
            SettingsViewModel.shared.playVictorySound()
            DataManager.shared.savePlayerProgress(playerProgress)
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
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(achievement.type.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Reward info
                if achievement.isUnlocked && !achievement.isClaimed {
                    HStack(spacing: 6) {
                        Text("+\(achievement.type.reward)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Image(systemName: "dollarsign.circle")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
            
            // Action Button or Status
            actionSection
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
    
    // MARK: - Action Section
    private var actionSection: some View {
        Group {
            if achievement.isClaimed {
                // Already claimed
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("Claimed")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            } else if achievement.isUnlocked {
                // Ready to claim
                Button(action: onClaim) {
                    Text("Claim")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 70, height: 36)
                        .background(Color.green.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            } else {
                // Not unlocked yet
                VStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Locked")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Styling Properties
    private var backgroundColor: Color {
        if achievement.isClaimed {
            return Color.green.opacity(0.2)
        } else if achievement.isUnlocked {
            return Color.blue.opacity(0.2)
        } else {
            return Color.white.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if achievement.isClaimed {
            return Color.green.opacity(0.5)
        } else if achievement.isUnlocked {
            return Color.blue.opacity(0.5)
        } else {
            return Color.white.opacity(0.3)
        }
    }
    
    private var borderWidth: CGFloat {
        return achievement.isUnlocked && !achievement.isClaimed ? 2 : 1
    }
    
    private var iconBackgroundColor: Color {
        if achievement.isClaimed {
            return Color.green.opacity(0.8)
        } else if achievement.isUnlocked {
            return Color.blue.opacity(0.8)
        } else {
            return Color.gray.opacity(0.6)
        }
    }
}

#Preview {
    AchievementsView(playerProgress: PlayerProgressViewModel())
}
