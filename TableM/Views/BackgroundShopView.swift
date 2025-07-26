//
//  BackgroundShopView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct BackgroundShopView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            BackgroundView(playerProgress: playerProgress)
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(backgroundItems, id: \.id) { item in
                            BackgroundItemCard(
                                item: item,
                                isSelected: playerProgress.selectedBackground == item.id,
                                canAfford: playerProgress.coins >= item.price,
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
    
    // MARK: - Helper Properties
    private var backgroundItems: [ShopItem] {
        return playerProgress.shopItems.filter { $0.type == .background }
    }
    
    // MARK: - Helper Methods
    private func handleItemAction(_ item: ShopItem) {
        if item.isPurchased || item.isDefault {
            // Select the item
            selectItem(item)
            SettingsViewModel.shared.playButtonSound()
            saveChanges()
        } else if playerProgress.coins >= item.price {
            // Purchase the item
            purchaseItem(item)
            SettingsViewModel.shared.playVictorySound()
            saveChanges()
        } else {
            // Cannot afford - play sound to indicate error
            SettingsViewModel.shared.playDefeatSound()
        }
    }
    
    private func selectItem(_ item: ShopItem) {
        playerProgress.selectedBackground = item.id
    }
    
    private func purchaseItem(_ item: ShopItem) {
        let success = playerProgress.purchaseItem(item)
        if success {
            // Automatically select the purchased item
            selectItem(item)
        }
    }
    
    private func saveChanges() {
        DataManager.shared.savePlayerProgress(playerProgress)
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
                .stroke(isSelected ? Color.green : Color.white.opacity(0.3), lineWidth: isSelected ? 3 : 1)
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
                    Image(.btn3).resizable()
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
    
    private var canInteract: Bool {
        return item.isPurchased || item.isDefault || canAfford
    }
}

#Preview {
    BackgroundShopView(playerProgress: PlayerProgressViewModel())
}
