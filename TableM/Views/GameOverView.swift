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
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Game over!")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 5) {
                Text("\(level.location.displayName)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                
                Text("Level \(level.id)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Secret Section
    private var secretSection: some View {
        VStack(spacing: 15) {
            Text("The secret code was:")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(0..<secretCombination.count, id: \.self) { index in
                    Circle()
                        .fill(secretCombination[index].color)
                        .frame(width: 35, height: 35)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - Buttons Section
    private var buttonsSection: some View {
        VStack(spacing: 15) {
            // Try Again button
            Button(action: onTryAgain) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 150)
                    .frame(height: 50)
                    .background(
                        Image(.btn3)
                            .resizable()
                    )
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
    GameOverView(
        level: GameLevel(id: 1, location: .france, isUnlocked: true),
        secretCombination: [.red, .magenta, .green, .purple],
        onTryAgain: { print("Try Again") },
        onMenu: { print("Menu") }
    )
}
