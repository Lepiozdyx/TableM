//
//  SettingsView.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var appState = AppStateManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView(playerProgress: appState.playerProgress)
                
                VStack {
                    topNavigationBar
                    
                    Spacer()
                    
                    // Audio Settings Section
                    audioSettingsSection
                        .padding()
                    
                    Spacer()
                    
                    // Reset Progress Button
                    resetProgressButton
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetGameProgress()
            }
        } message: {
            Text("This will permanently delete all your progress, coins, and achievements. This action cannot be undone.")
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            Spacer()
            
            // Home Button
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
    
    // MARK: - Audio Settings Section
    private var audioSettingsSection: some View {
        VStack(spacing: 40) {
            sectionHeader("Settings")
            
            VStack(spacing: 25) {
                // Music Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Music")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Slider(
                        value: Binding(
                            get: { appState.playerProgress.musicVolume },
                            set: { appState.updateMusicVolume($0) }
                        ),
                        in: 0...1,
                        step: 0.1
                    ) {
                        Text("Music Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker")
                            .foregroundColor(.gray)
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3")
                            .foregroundColor(.gray)
                    }
                }
                
                // Sound Effects Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sound")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Slider(
                        value: Binding(
                            get: { appState.playerProgress.soundVolume },
                            set: { appState.updateSoundVolume($0) }
                        ),
                        in: 0...1,
                        step: 0.1
                    ) {
                        Text("Sound Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker")
                            .foregroundColor(.gray)
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 80)
        .background(
            Image(.underlay1)
                .resizable()
        )
    }
    
    // MARK: - Reset Progress Button
    private var resetProgressButton: some View {
        Button(action: {
            showingResetAlert = true
        }) {
            Text("Reset Progress")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
                .frame(width: 150, height: 50)
                .background(
                    Image(.btn2)
                        .resizable()
                )
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(.gray)
    }
    
    // MARK: - Helper Methods
    private func resetGameProgress() {
        appState.resetProgress()
        SettingsViewModel.shared.playButtonSound()
    }
}

#Preview {
    SettingsView()
}
