//
//  ShopView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct ShopView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToBackgrounds = false
    @State private var navigateToSkins = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundView
                
                VStack(spacing: 0) {
                    // Top Navigation with Coins
                    topNavigationBar
                    
                    Spacer()
                    
                    // Category Selection
                    VStack(spacing: 30) {
                        // Background Category Button
                        CategorySelectionButton(
                            title: "Background",
                            icon: "photo.fill",
                            color: .purple
                        ) {
                            navigateToBackgrounds = true
                            SettingsViewModel.shared.playButtonSound()
                        }
                        
                        // Skin Category Button
                        CategorySelectionButton(
                            title: "Skin",
                            icon: "person.fill",
                            color: .blue
                        ) {
                            navigateToSkins = true
                            SettingsViewModel.shared.playButtonSound()
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToBackgrounds) {
                BackgroundShopView(playerProgress: playerProgress)
            }
            .navigationDestination(isPresented: $navigateToSkins) {
                SkinShopView(playerProgress: playerProgress)
            }
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
            // Home Button
            Button(action: { dismiss() }) {
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            
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
}

// MARK: - Category Selection Button Component
struct CategorySelectionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

#Preview {
    ShopView(playerProgress: PlayerProgressViewModel())
}
