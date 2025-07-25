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
                backgroundView
                
                VStack(spacing: 0) {
                    // Top Navigation
                    topNavigationBar
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 30) {
                            // Daily Login Reward
                            dailyLoginSection
                            
                            // Daily Tasks
                            dailyTasksSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
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
            Text("Daily Rewards")
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
    
    // MARK: - Daily Login Section
    private var dailyLoginSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Daily Login Bonus")
            
            DailyLoginCard(
                dailyReward: playerProgress.dailyReward,
                onClaim: {
                    claimDailyLogin()
                }
            )
        }
    }
    
    // MARK: - Daily Tasks Section
    private var dailyTasksSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Daily Tasks")
            
            VStack(spacing: 15) {
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
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    // MARK: - Claim Animation Overlay
    private var claimAnimationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(showingClaimAnimation ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.5).repeatCount(3), value: showingClaimAnimation)
                
                Text("Reward Claimed!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .opacity(showingClaimAnimation ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: showingClaimAnimation)
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
            // Calendar Icon
            VStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                
                Text("Day \(dailyReward.consecutiveDays + 1)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Reward Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Login Bonus")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Come back daily to build your streak!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 6) {
                    Text("+\(dailyReward.todayReward)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Image(systemName: "dollarsign.circle")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            // Claim Button
            Button(action: onClaim) {
                Text(dailyReward.canClaimToday ? "Claim" : "Claimed")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 40)
                    .background(dailyReward.canClaimToday ? Color.green.opacity(0.8) : Color.gray.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .disabled(!dailyReward.canClaimToday)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(dailyReward.canClaimToday ? Color.yellow.opacity(0.5) : Color.white.opacity(0.3), lineWidth: dailyReward.canClaimToday ? 2 : 1)
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
            // Task Icon
            taskIcon
            
            // Task Info
            VStack(alignment: .leading, spacing: 8) {
                Text(task.type.description)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(progressText)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                if task.isCompleted && !task.isClaimed {
                    HStack(spacing: 6) {
                        Text("+\(task.type.reward)")
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
            
            // Status/Claim Button
            taskActionView
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
    }
    
    // MARK: - Task Icon
    private var taskIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 50, height: 50)
            
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Task Action View
    private var taskActionView: some View {
        Group {
            if task.isClaimed {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("Claimed")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            } else if task.isCompleted {
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
                VStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("Pending")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
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
    
    private var iconName: String {
        switch task.type {
        case .playGame:
            return "play.circle"
        case .completeLevel:
            return "star.circle"
        }
    }
    
    private var backgroundColor: Color {
        if task.isClaimed {
            return Color.green.opacity(0.2)
        } else if task.isCompleted {
            return Color.blue.opacity(0.2)
        } else {
            return Color.white.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if task.isClaimed {
            return Color.green.opacity(0.5)
        } else if task.isCompleted {
            return Color.blue.opacity(0.5)
        } else {
            return Color.white.opacity(0.3)
        }
    }
    
    private var borderWidth: CGFloat {
        return task.isCompleted && !task.isClaimed ? 2 : 1
    }
    
    private var iconBackgroundColor: Color {
        if task.isClaimed {
            return Color.green.opacity(0.8)
        } else if task.isCompleted {
            return Color.blue.opacity(0.8)
        } else {
            return Color.orange.opacity(0.8)
        }
    }
}

#Preview {
    DailyRewardView(playerProgress: PlayerProgressViewModel())
}
