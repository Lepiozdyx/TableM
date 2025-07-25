//
//  GameOverView.swift
//  TableM
//
//  Created by Alex on 23.07.2025.
//

import SwiftUI

struct GameOverView: View {
    let level: GameLevel
    let secretCombination: [GameColor]
    let onTryAgain: () -> Void
    let onMenu: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                titleSection
                
                // Secret combination reveal
                secretSection
                
                // Message
                messageSection
                
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
            Text("Try Again!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("\(level.location.displayName)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Level \(level.id)")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Secret Section
    private var secretSection: some View {
        VStack(spacing: 15) {
            Text("The secret code was:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(0..<secretCombination.count, id: \.self) { index in
                    Circle()
                        .fill(secretCombination[index].color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - Message Section
    private var messageSection: some View {
        VStack(spacing: 10) {
            Text("Don't give up!")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Every attempt brings you closer to cracking the code. Use logic and deduction to succeed!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Buttons Section
    private var buttonsSection: some View {
        VStack(spacing: 15) {
            // Try Again button
            Button(action: onTryAgain) {
                Text("Try Again")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
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
}

#Preview {
    GameOverView(
        level: GameLevel(id: 2, location: .france, isUnlocked: true),
        secretCombination: [.red, .magenta, .green, .purple],
        onTryAgain: { print("Try Again") },
        onMenu: { print("Menu") }
    )
}
