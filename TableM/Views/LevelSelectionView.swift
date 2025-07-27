import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject private var appState = AppStateManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedLocation: GameLocation
    @State private var showingProfessorComment = false
    @State private var professorMessage = ""
    @State private var navigateToGame = false
    @State private var selectedLevel: GameLevel?
    
    init() {
        self._selectedLocation = State(initialValue: AppStateManager.shared.playerProgress.currentLocation)
    }
    
    var body: some View {
        ZStack {
            // Background
            BackgroundView(playerProgress: appState.playerProgress)
            
            VStack(spacing: 0) {
                // Top Navigation
                topNavigationBar
                
                Spacer()
                
                // Location Tile
                locationTileView
                
                Spacer()
                
                // Location Navigation
                locationNavigationView
                
                Spacer()
            }
            
            // Professor Comment Overlay
            if showingProfessorComment {
                ProfessorOverlayView(
                    playerProgress: appState.playerProgress,
                    message: professorMessage,
                    isOnboarding: false,
                    onNext: { },
                    onSkip: { },
                    onDismiss: {
                        showingProfessorComment = false
                    }
                )
                .zIndex(1000)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToGame) {
            if let level = selectedLevel {
                GameView(level: level)
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
    
    // MARK: - Location Tile View
    private var locationTileView: some View {
        VStack {
            // Location Title
            Text(selectedLocation.displayName)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            // Location Image
            locationImageView
            
            // Level Selection
            levelSelectionView
        }
        .padding()
        .background(
            Image(.underlay1)
                .resizable()
        )
    }
    
    // MARK: - Location Image View
    private var locationImageView: some View {
        Image(selectedLocation.backgroundImage)
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .frame(width: 200, height: 350)
    }
    
    // MARK: - Level Selection View
    private var levelSelectionView: some View {
        HStack(spacing: 15) {
            ForEach(1...5, id: \.self) { levelNumber in
                levelButton(for: levelNumber)
            }
        }
        .padding()
    }
    
    // MARK: - Level Button
    private func levelButton(for levelNumber: Int) -> some View {
        let level = appState.playerProgress.levelForLocationAndId(location: selectedLocation, levelId: levelNumber)
        let isUnlocked = level?.isUnlocked ?? false
        let isCompleted = level?.isCompleted ?? false
        
        return Button {
            // FIXED: Only allow playing unlocked levels, but button is always interactive for visual feedback
            if isUnlocked, let gameLevel = level {
                selectedLevel = gameLevel
                navigateToGame = true
            } else {
                // Visual feedback for locked levels
                SettingsViewModel.shared.playDefeatSound()
            }
        } label: {
            Image(buttonImageName(isUnlocked: isUnlocked, isCompleted: isCompleted))
                .resizable()
                .frame(width: 50, height: 50)
                .overlay {
                    if isUnlocked {
                        if isCompleted {
                            // Checkmark for completed levels
                            Image(systemName: "checkmark")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        } else {
                            // Level number for unlocked levels
                            Text("\(levelNumber)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    } else {
                        // Lock for locked levels
                        Image(.lock)
                            .resizable()
                            .scaledToFit()
                            .padding(14)
                    }
                }
        }
        .scaleEffect(isUnlocked ? 1.0 : 0.9)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
    
    // MARK: - Location Navigation View
    private var locationNavigationView: some View {
        HStack(spacing: 80) {
            // Previous Location Button - FIXED: Always enabled for browsing
            Button(action: previousLocation) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        !canGoToPreviousLocation
                        ? Image(.btn5).resizable()
                        : Image(.btn4).resizable()
                    )
            }
            .disabled(!canGoToPreviousLocation)
            .opacity(canGoToPreviousLocation ? 1.0 : 0.6)
            
            // Next Location Button - FIXED: Always enabled for browsing
            Button(action: nextLocation) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        !canGoToNextLocation
                        ? Image(.btn5).resizable()
                        : Image(.btn4).resizable()
                    )
            }
            .disabled(!canGoToNextLocation)
            .opacity(canGoToNextLocation ? 1.0 : 0.6)
        }
    }
    
    // MARK: - Helper Methods
    private func buttonImageName(isUnlocked: Bool, isCompleted: Bool) -> ImageResource {
        if !isUnlocked {
            return .btn5
        } else if isCompleted {
            return .btn4
        } else {
            return .btn4
        }
    }
    
    private var canGoToPreviousLocation: Bool {
        guard let currentIndex = GameLocation.allCases.firstIndex(of: selectedLocation) else { return false }
        return currentIndex > 0
    }
    
    private var canGoToNextLocation: Bool {
        guard let currentIndex = GameLocation.allCases.firstIndex(of: selectedLocation) else { return false }
        return currentIndex + 1 < GameLocation.allCases.count
    }
    
    // FIXED: Removed hasNextLocationUnlocked check - allow browsing all locations
    private func previousLocation() {
        guard let currentIndex = GameLocation.allCases.firstIndex(of: selectedLocation),
              currentIndex > 0 else { return }
        
        selectedLocation = GameLocation.allCases[currentIndex - 1]
        showLocationComment()
    }
    
    private func nextLocation() {
        guard let currentIndex = GameLocation.allCases.firstIndex(of: selectedLocation),
              currentIndex + 1 < GameLocation.allCases.count else { return }
        
        // FIXED: Allow browsing all locations, not just unlocked ones
        selectedLocation = GameLocation.allCases[currentIndex + 1]
        showLocationComment()
    }
    
    private func showLocationComment() {
        professorMessage = selectedLocation.professorComment
        showingProfessorComment = true
        
        // Update current location through AppStateManager only if it's unlocked
        if appState.playerProgress.unlockedLocations.contains(selectedLocation) {
            appState.updateCurrentLocation(selectedLocation)
        }
    }
}

#Preview {
    NavigationStack {
        LevelSelectionView()
    }
}
