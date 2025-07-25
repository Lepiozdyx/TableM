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
            
            VStack(spacing: 30) {
                // Title
                titleSection
                
                // Results
                resultsSection
                
                // Coins earned
                coinsSection
                
                // Buttons
                buttonsSection
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
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
        VStack(spacing: 10) {
            Text("Victory!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("\(level.location.displayName)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Level \(level.id)")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Attempts:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(attempts)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Performance indicator
            HStack {
                Text("Performance:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(performanceText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(performanceColor)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Coins Section
    private var coinsSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text("+\(coinsEarned)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("coins earned")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    // MARK: - Buttons Section
    private var buttonsSection: some View {
        VStack(spacing: 15) {
            // Next Level or Secret Story button
            if hasNextLevel {
                Button(action: onNextLevel) {
                    Text("Next Level")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
            }
            
            // Secret Story button (for 5th level)
            if hasSecretStory {
                Button(action: onSecretStory) {
                    Text("View Secret Story")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
            }
            
            // Menu button
            Button(action: onMenu) {
                Text("Menu")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
        }
    }
    
    // MARK: - Performance Logic
    private var performanceText: String {
        switch attempts {
        case 1:
            return "Perfect!"
        case 2...3:
            return "Excellent"
        case 4...6:
            return "Good"
        case 7...8:
            return "Fair"
        default:
            return "Keep Trying!"
        }
    }
    
    private var performanceColor: Color {
        switch attempts {
        case 1:
            return .green
        case 2...3:
            return .blue
        case 4...6:
            return .orange
        case 7...8:
            return .yellow
        default:
            return .red
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
