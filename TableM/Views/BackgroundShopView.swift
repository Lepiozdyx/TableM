//
//  BackgroundShopView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct BackgroundShopView: View {
    @ObservedObject private var appState = AppStateManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            BackgroundView(playerProgress: appState.playerProgress)
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(backgroundItems, id: \.id) { item in
                            BackgroundItemCard(
                                item: item,
                                isSelected: appState.playerProgress.selectedBackground == item.id,
                                canAfford: appState.playerProgress.coins >= item.price,
                                onAction: {
                                    handleItemAction(item)
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
    
    // MARK: - Helper Properties
    private var backgroundItems: [ShopItem] {
        return appState.playerProgress.shopItems.filter { $0.type == .background }
    }
    
    // MARK: - Helper Methods
    private func handleItemAction(_ item: ShopItem) {
        if item.isPurchased || item.isDefault {
            // Select the item
            selectItem(item)
            SettingsViewModel.shared.playButtonSound()
        } else if appState.playerProgress.coins >= item.price {
            // Purchase the item
            if purchaseItem(item) {
                // Automatically select the purchased item
                selectItem(item)
                SettingsViewModel.shared.playVictorySound()
            } else {
                SettingsViewModel.shared.playDefeatSound()
            }
        } else {
            // Cannot afford - play sound to indicate error
            SettingsViewModel.shared.playDefeatSound()
        }
    }
    
    private func selectItem(_ item: ShopItem) {
        appState.selectBackground(item.id)
    }
    
    private func purchaseItem(_ item: ShopItem) -> Bool {
        return appState.purchaseShopItem(item)
    }
}

// MARK: - Background Item Card Component
struct BackgroundItemCard: View {
    let item: ShopItem
    let isSelected: Bool
    let canAfford: Bool
    let onAction: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Item Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                if !item.isDefault && !item.isPurchased {
                    HStack(spacing: 6) {
                        Text("\(item.price)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                        
                        Image(.coin)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                    }
                }
                
                Spacer()
                
                // Action Button
                actionButton
            }
            
            Spacer()
            
            // Preview Image
            backgroundPreview
        }
        .padding()
        .frame(height: 140)
        .background(
            Image(.underlay2).resizable()
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // MARK: - Background Preview
    private var backgroundPreview: some View {
        Image(item.imageName)
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(width: 100, height: 100)
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: onAction) {
            Text(buttonText)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 80, height: 36)
                .background(
                    Image(buttonImageName).resizable()
                )
        }
        .disabled(!canInteract)
    }
    
    // MARK: - Button Properties
    private var buttonText: String {
        if isSelected {
            return "Selected"
        } else if item.isPurchased || item.isDefault {
            return "Select"
        } else if canAfford {
            return "Buy"
        } else {
            return "Unavailable"
        }
    }
    
    private var buttonImageName: ImageResource {
        if !canInteract {
            return .btn2
        } else if isSelected {
            return .btn2
        } else {
            return .btn3
        }
    }
    
    private var canInteract: Bool {
        return item.isPurchased || item.isDefault || canAfford
    }
}

#Preview {
    BackgroundShopView()
}
