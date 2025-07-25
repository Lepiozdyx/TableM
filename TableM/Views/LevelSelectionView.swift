import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject private var playerProgress: PlayerProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedLocation: GameLocation
    @State private var showingProfessorComment = false
    @State private var professorMessage = ""
    @State private var navigateToGame = false
    @State private var selectedLevel: GameLevel?
    
    init(playerProgress: PlayerProgressViewModel) {
        self.playerProgress = playerProgress
        self._selectedLocation = State(initialValue: playerProgress.currentLocation)
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                // Top Navigation
                topNavigationBar
                
                Spacer()
                
                // Location Title
                Text(selectedLocation.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Location Image
                locationImageView
                
                // Level Selection
                levelSelectionView
                
                // Location Navigation
                locationNavigationView
                
                Spacer()
            }
            
            // Professor Comment Overlay
            if showingProfessorComment {
                ProfessorOverlayView(
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
                GameView(level: level, playerProgress: playerProgress)
            }
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            Spacer()
            
            // Home Button
            Button(action: { dismiss() }) {
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
    }
    
    // MARK: - Location Image View
    private var locationImageView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.5))
            .frame(width: 300, height: 200)
            .overlay(
                Image(selectedLocation.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 2)
            )
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
        let level = playerProgress.levelForLocationAndId(location: selectedLocation, levelId: levelNumber)
        let isUnlocked = level?.isUnlocked ?? false
        let isCompleted = level?.isCompleted ?? false
        
        return Button {
            if isUnlocked, let gameLevel = level {
                selectedLevel = gameLevel
                navigateToGame = true
            }
        } label: {
            ZStack {
                Circle()
                    .fill(buttonBackgroundColor(isUnlocked: isUnlocked, isCompleted: isCompleted))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                if isUnlocked {
                    if isCompleted {
                        // Checkmark for completed levels
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        // Level number for unlocked levels
                        Text("\(levelNumber)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                } else {
                    // Lock for locked levels
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(!isUnlocked)
        .scaleEffect(isUnlocked ? 1.0 : 0.8)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
    
    // MARK: - Location Navigation View
    private var locationNavigationView: some View {
        HStack(spacing: 80) {
            // Previous Location Button
            Button(action: previousLocation) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .disabled(!canGoToPreviousLocation)
            .opacity(canGoToPreviousLocation ? 1.0 : 0.3)
            
            // Next Location Button
            Button(action: nextLocation) {
                Image(systemName: "chevron.right")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .disabled(!canGoToNextLocation || !hasNextLocationUnlocked)
            .opacity((canGoToNextLocation && hasNextLocationUnlocked) ? 1.0 : 0.3)
        }
    }
    
    // MARK: - Helper Methods
    private func buttonBackgroundColor(isUnlocked: Bool, isCompleted: Bool) -> Color {
        if !isUnlocked {
            return Color.gray.opacity(0.6)
        } else if isCompleted {
            return Color.green.opacity(0.8)
        } else {
            return Color.blue.opacity(0.8)
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
    
    private var hasNextLocationUnlocked: Bool {
        guard let currentIndex = GameLocation.allCases.firstIndex(of: selectedLocation),
              currentIndex + 1 < GameLocation.allCases.count else { return false }
        let nextLocation = GameLocation.allCases[currentIndex + 1]
        return playerProgress.unlockedLocations.contains(nextLocation)
    }
    
    private func previousLocation() {
        guard let currentIndex = GameLocation.allCases.firstIndex(of: selectedLocation),
              currentIndex > 0 else { return }
        
        selectedLocation = GameLocation.allCases[currentIndex - 1]
        showLocationComment()
    }
    
    private func nextLocation() {
        guard let currentIndex = GameLocation.allCases.firstIndex(of: selectedLocation),
              currentIndex + 1 < GameLocation.allCases.count else { return }
        
        let nextLocation = GameLocation.allCases[currentIndex + 1]
        
        // Only switch if the location is unlocked
        if playerProgress.unlockedLocations.contains(nextLocation) {
            selectedLocation = nextLocation
            showLocationComment()
        }
    }
    
    private func showLocationComment() {
        professorMessage = selectedLocation.professorComment
        showingProfessorComment = true
        
        // Update current location in player progress
        playerProgress.currentLocation = selectedLocation
        DataManager.shared.savePlayerProgress(playerProgress)
    }
}

#Preview {
    NavigationStack {
        LevelSelectionView(playerProgress: PlayerProgressViewModel())
    }
}
