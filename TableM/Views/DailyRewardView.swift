//
//  DailyRewardView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct DailyRewardView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingClaimAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                BackgroundView(playerProgress: playerProgress)
                
                VStack(spacing: 0) {
                    // Top Navigation
                    topNavigationBar
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 30) {
                            // Daily Login Reward
                            DailyLoginCard(
                                dailyReward: playerProgress.dailyReward,
                                onClaim: {
                                    claimDailyLogin()
                                }
                            )
                            
                            // Daily Tasks
                            dailyTasksSection
                        }
                        .padding()
                    }
                }
                
                // Claim Animation Overlay
                if showingClaimAnimation {
                    claimAnimationOverlay
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Coins Display
            ScoreboardView(coins: playerProgress.coins)
            
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
    
    // MARK: - Daily Tasks Section
    private var dailyTasksSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader("Daily Tasks")
            
            ForEach(playerProgress.dailyTasks) { task in
                DailyTaskCard(
                    task: task,
                    playerProgress: playerProgress,
                    onClaim: {
                        claimDailyTask(task.type)
                    }
                )
            }
        }
        .padding()
        .background(
            Image(.underlay2)
                .resizable()
        )
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }
    
    // MARK: - Claim Animation Overlay
    private var claimAnimationOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(showingClaimAnimation ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.5).repeatCount(3), value: showingClaimAnimation)
                
                Text("Congratulations!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Reward Claimed!")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.gray)
                
                ScoreboardView(coins: 10)
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 80)
            .background(
                Image(.underlay1)
                    .resizable()
            )
        }
        .opacity(showingClaimAnimation ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: showingClaimAnimation)
    }
    
    // MARK: - Helper Methods
    private func claimDailyLogin() {
        let reward = playerProgress.claimDailyReward()
        if reward > 0 {
            showClaimAnimation()
            SettingsViewModel.shared.playVictorySound()
            DataManager.shared.savePlayerProgress(playerProgress)
        }
    }
    
    private func claimDailyTask(_ taskType: DailyTaskType) {
        if let index = playerProgress.dailyTasks.firstIndex(where: { $0.type == taskType && $0.isCompleted && !$0.isClaimed }) {
            playerProgress.dailyTasks[index].isClaimed = true
            playerProgress.coins += taskType.reward
            
            showClaimAnimation()
            SettingsViewModel.shared.playVictorySound()
            DataManager.shared.savePlayerProgress(playerProgress)
        }
    }
    
    private func showClaimAnimation() {
        showingClaimAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showingClaimAnimation = false
        }
    }
}

// MARK: - Daily Login Card Component
struct DailyLoginCard: View {
    let dailyReward: DailyReward
    let onClaim: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // Reward Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Login Bonus")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Come back daily to build your streak!")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.gray)
                
                ScoreboardView(coins: dailyReward.todayReward)
            }
            
            Spacer()
            
            // Claim Button
            Button(action: onClaim) {
                Text(dailyReward.canClaimToday ? "Claim" : "Claimed")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 40)
                    .background(
                        dailyReward.canClaimToday
                        ? Image(.btn3).resizable()
                        : Image(.btn2).resizable()
                    )
            }
            .disabled(!dailyReward.canClaimToday)
        }
        .padding()
        .background(
            Image(.underlay2)
                .resizable()
        )
    }
}

// MARK: - Daily Task Card Component
struct DailyTaskCard: View {
    let task: DailyTask
    let playerProgress: PlayerProgressViewModel
    let onClaim: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Task Info
            VStack(alignment: .leading, spacing: 8) {
                Text(task.type.description)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(progressText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.gray)
                
                if task.isCompleted && !task.isClaimed {
                    Text("+\(task.type.reward)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            
            Spacer()
            
            // Status/Claim Button
            taskActionView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Task Action View
    private var taskActionView: some View {
        Group {
            if task.isClaimed {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    
                    Text("Claimed")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            } else if task.isCompleted {
                Button(action: onClaim) {
                    Text("Claim")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 36)
                        .background(
                            Image(.btn3)
                                .resizable()
                        )
                }
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 20))
                        .foregroundColor(.indigo)
                    
                    Text("Pending")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.indigo)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    private var progressText: String {
        switch task.type {
        case .playGame:
            return playerProgress.totalGamesPlayed > 0 ? "Completed!" : "Start any level"
        case .completeLevel:
            return playerProgress.totalLevelsCompleted > 0 ? "Completed!" : "Win any level"
        }
    }
}

#Preview {
    DailyRewardView(playerProgress: PlayerProgressViewModel())
}
