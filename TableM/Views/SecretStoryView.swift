//
//  SecretStoryView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct SecretStoryView: View {
    let location: GameLocation
    @Environment(\.dismiss) private var dismiss
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            // Background
            
            VStack(spacing: 0) {
                // Top navigation
                topNavigationBar
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Title section
                        titleSection
                        
                        // Story content
                        storySection
                        
                        // Back button
                        backButton
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
            
            Text("Secret Revealed!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Congratulations on completing \(location.displayName)")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Story Section
    private var storySection: some View {
        VStack(spacing: 20) {
            // University info card
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "building.columns.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text(universityName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                Text(location.secretStory)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            .padding(25)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Achievement badge
            achievementBadge
        }
    }
    
    // MARK: - Achievement Badge
    private var achievementBadge: some View {
        HStack(spacing: 15) {
            Image(systemName: "star.fill")
                .font(.title2)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Location Master")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("You've unlocked all secrets of \(location.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.purple.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    // MARK: - Back Button
    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.left")
                    .font(.headline)
                Text("Back to Levels")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Helper Properties
    private var universityName: String {
        switch location {
        case .france:
            return "École Normale Supérieure"
        case .japan:
            return "Kyoto University"
        case .brazil:
            return "University of São Paulo"
        case .egypt:
            return "Al-Azhar University"
        case .usa:
            return "Stanford University"
        }
    }
}

#Preview {
    SecretStoryView(location: .france)
}

#Preview("Japan") {
    SecretStoryView(location: .japan)
}

#Preview("Egypt") {
    SecretStoryView(location: .egypt)
}
