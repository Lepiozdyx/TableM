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
            Image(.bgDefault)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                // Top navigation
                topNavigationBar
                
                ScrollView {
                    VStack {
                        // Title section
                        titleSection
                        
                        // Story content
                        storySection
                    }
                    .padding()
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
    
    // MARK: - Title Section
    private var titleSection: some View {
        Text("Congratulations on completing \(location.displayName)")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Story Section
    private var storySection: some View {
        // University info card
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(universityName)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            
            Text(location.secretStory)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .padding(30)
        .background(
            Image(.underlay2)
                .resizable()
        )
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
