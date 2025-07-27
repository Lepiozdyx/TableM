//
//  ShopView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct ShopView: View {
    @ObservedObject private var appState = AppStateManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToBackgrounds = false
    @State private var navigateToSkins = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                BackgroundView(playerProgress: appState.playerProgress)
                
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
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToBackgrounds) {
                BackgroundShopView()
            }
            .navigationDestination(isPresented: $navigateToSkins) {
                SkinShopView()
            }
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
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
}

// MARK: - Category Selection Button Component
struct CategorySelectionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: 200, maxHeight: 80)
                .background(
                    Image(.btn2).resizable()
                )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

#Preview {
    ShopView()
}
