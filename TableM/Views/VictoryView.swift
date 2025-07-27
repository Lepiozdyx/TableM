//
//  VictoryView.swift
//  TableM
//
//  Created by Alex on 23.07.2025.
//

import SwiftUI

struct VictoryView: View {
    let level: GameLevel
    let attempts: Int
    let coinsEarned: Int
    let hasNextLevel: Bool
    let hasSecretStory: Bool
    let onNextLevel: () -> Void
    let onMenu: () -> Void
    let onSecretStory: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                titleSection
                
                // Coins earned
                coinsSection
                
                // Buttons
                buttonsSection
            }
            .padding(30)
            .background(
                Image(.underlay1)
                    .resizable()
            )
            .padding(.horizontal, 40)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "face.smiling")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Congratulations!")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("You win!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Coins Section
    private var coinsSection: some View {
        ScoreboardView(coins: coinsEarned)
    }
    
    // MARK: - Buttons Section
    private var buttonsSection: some View {
        VStack(spacing: 15) {
            // Next Level or Secret Story button
            if hasNextLevel {
                Button(action: onNextLevel) {
                    Text("Next Level")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 150)
                        .frame(height: 50)
                        .background(
                            Image(.btn3)
                                .resizable()
                        )
                }
            }
            
            // Secret Story button (for 5th level)
            if hasSecretStory {
                Button(action: onSecretStory) {
                    Text("View Secret Story")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 150)
                        .frame(height: 50)
                        .background(
                            Image(.btn3)
                                .resizable()
                        )
                }
            }
            
            // Menu button
            Button(action: onMenu) {
                Text("Menu")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 150)
                    .frame(height: 50)
                    .background(
                        Image(.btn2)
                            .resizable()
                    )
            }
        }
    }
}

#Preview {
    VictoryView(
        level: GameLevel(id: 1, location: .france, isUnlocked: true, isCompleted: true),
        attempts: 3,
        coinsEarned: 100,
        hasNextLevel: true,
        hasSecretStory: false,
        onNextLevel: { print("Next Level") },
        onMenu: { print("Menu") },
        onSecretStory: { print("Secret Story") }
    )
}

#Preview("Level 5 Complete") {
    VictoryView(
        level: GameLevel(id: 5, location: .france, isUnlocked: true, isCompleted: true),
        attempts: 5,
        coinsEarned: 100,
        hasNextLevel: false,
        hasSecretStory: true,
        onNextLevel: { },
        onMenu: { print("Menu") },
        onSecretStory: { print("Secret Story") }
    )
}
