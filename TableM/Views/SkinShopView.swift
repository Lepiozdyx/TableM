//
//  SkinShopView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct SkinShopView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(skinItems, id: \.id) { item in
                            SkinItemCard(
                                item: item,
                                isSelected: playerProgress.selectedSkin == item.id,
                                canAfford: playerProgress.coins >= item.price,
                                onAction: {
                                    handleItemAction(item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
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
    
    // MARK: - Helper Properties
    private var skinItems: [ShopItem] {
        return playerProgress.shopItems.filter { $0.type == .skin }
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
        playerProgress.selectedSkin = item.id
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

// MARK: - Skin Item Card Component
struct SkinItemCard: View {
    let item: ShopItem
    let isSelected: Bool
    let canAfford: Bool
    let onAction: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Professor Preview
            professorPreview
            
            // Item Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !item.isDefault && !item.isPurchased {
                    HStack(spacing: 6) {
                        Text("\(item.price)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Image(systemName: "dollarsign.circle")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Action Button
            actionButton
        }
        .padding(16)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.green : Color.white.opacity(0.3), lineWidth: isSelected ? 3 : 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // MARK: - Professor Preview
    private var professorPreview: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 80, height: 110)
            .overlay(
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: onAction) {
            Text(buttonText)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 80, height: 36)
                .background(buttonBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 18))
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
    
    private var buttonBackgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.8)
        } else if item.isPurchased || item.isDefault {
            return Color.green.opacity(0.8)
        } else if canAfford {
            return Color.green.opacity(0.8)
        } else {
            return Color.red.opacity(0.8)
        }
    }
    
    private var canInteract: Bool {
        return item.isPurchased || item.isDefault || canAfford
    }
}

#Preview {
    SkinShopView(playerProgress: PlayerProgressViewModel())
}
