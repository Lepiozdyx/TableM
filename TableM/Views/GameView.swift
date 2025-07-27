import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel: GameViewModel
    @ObservedObject private var appState = AppStateManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // UI State
    @State private var showingSettings = false
    @State private var showingVictory = false
    @State private var showingGameOver = false
    @State private var showingSecretStory = false
    
    init(level: GameLevel) {
        self._gameViewModel = StateObject(wrappedValue: GameViewModel(level: level))
    }
    
    var body: some View {
        ZStack {
            // Background
            Image(appState.playerProgress.currentLocation.backgroundImage)
                .resizable()
                .ignoresSafeArea()

            VStack {
                // Top Navigation Bar
                topNavigationBar
                
                // Question marks (current row at top)
                currentRowQuestionsView
                
                // Game Content (History)
                gameContentView
            }
            
            VStack {
                Spacer()
                
                // Color Palette at bottom
                colorPaletteView
                    .padding(.bottom)
            }
            
            // Professor Overlay
            if case .speaking(let message, let isOnboarding) = gameViewModel.professorState {
                ProfessorOverlayView(
                    playerProgress: appState.playerProgress,
                    message: message,
                    isOnboarding: isOnboarding,
                    onNext: gameViewModel.nextOnboardingMessage,
                    onSkip: gameViewModel.skipOnboarding,
                    onDismiss: gameViewModel.hideProfessor
                )
                .zIndex(1000)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: gameViewModel.gameState) { newState in
            handleGameStateChange(newState)
        }
        .sheet(isPresented: $showingVictory) {
            VictoryView(
                level: gameViewModel.currentLevel,
                attempts: gameViewModel.attempts.count,
                coinsEarned: 100,
                hasNextLevel: gameViewModel.shouldShowNextLevelButton,
                hasSecretStory: gameViewModel.shouldShowSecretStoryButton,
                onNextLevel: {
                    SettingsViewModel.shared.playButtonSound()
                    if let _ = gameViewModel.nextLevel() {
                        // Navigate to next level ?
                        showingVictory = false
                    }
                },
                onMenu: {
                    SettingsViewModel.shared.playButtonSound()
                    showingVictory = false
                    dismiss()
                },
                onSecretStory: {
                    SettingsViewModel.shared.playButtonSound()
                    showingVictory = false
                    showingSecretStory = true
                }
            )
        }
        .sheet(isPresented: $showingGameOver) {
            GameOverView(
                level: gameViewModel.currentLevel,
                secretCombination: gameViewModel.secretCombination,
                onTryAgain: {
                    SettingsViewModel.shared.playButtonSound()
                    showingGameOver = false
                    gameViewModel.restartLevel()
                },
                onMenu: {
                    SettingsViewModel.shared.playButtonSound()
                    showingGameOver = false
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showingSecretStory) {
            SecretStoryView(location: gameViewModel.currentLevel.location)
        }
         .sheet(isPresented: $showingSettings) {
             SettingsView()
         }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Settings Button
            Button(action: {
                SettingsViewModel.shared.playButtonSound()
                showingSettings = true
            }) {
                Image(.btn1)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(.gear)
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                    }
            }
            
            Spacer()
            
            // Back/Home Button
            Button(action: {
                SettingsViewModel.shared.playButtonSound()
                dismiss()
            }) {
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
    
    // MARK: - Current Row Questions (Top)
    private var currentRowQuestionsView: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Button(action: {
                    SettingsViewModel.shared.playButtonSound()
                    gameViewModel.selectPosition(index)
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                gameViewModel.currentRow.colors[index]?.color ??
                                Color.teal.opacity(0.9)
                            )
                            .frame(width: 50, height: 50)
                        
                        // Selection indicator
                        if gameViewModel.currentRow.selectedIndex == index {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 54, height: 54)
                        }
                        
                        // Question mark for empty slots
                        if gameViewModel.currentRow.colors[index] == nil {
                            Text("?")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .disabled(!gameViewModel.canInteract())
            }
            
            // Check button (appears when row is complete)
            if gameViewModel.canCheckRow() {
                Button(action: {
                    SettingsViewModel.shared.playButtonSound()
                    gameViewModel.checkCurrentRow()
                }) {
                    Text("Check")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 90)
                        .frame(height: 45)
                        .background(
                            Image(.btn2)
                                .resizable()
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameViewModel.canCheckRow())
        .padding(.horizontal)
    }
    
    // MARK: - Game Content (Attempts History)
    private var gameContentView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameViewModel.attempts) { attempt in
                    AttemptRowView(attempt: attempt)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Color Palette
    private var colorPaletteView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 4), spacing: 2) {
            ForEach(GameColor.allCases, id: \.self) { color in
                Button(action: {
                    SettingsViewModel.shared.playButtonSound()
                    gameViewModel.selectColor(color)
                }) {
                    Circle()
                        .fill(color.color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(color.color, lineWidth: 2.5)
                                .frame(width: 54, height: 54)
                        )
                        .padding(10)
                        .background(
                            Image(.btn1)
                                .resizable()
                        )
                }
                .disabled(!gameViewModel.canInteract())
                .scaleEffect(gameViewModel.canInteract() ? 1.0 : 0.8)
                .animation(.easeInOut(duration: 0.2), value: gameViewModel.canInteract())
            }
        }
        .frame(maxWidth: 300)
    }
    
    // MARK: - Game State Handling
    private func handleGameStateChange(_ newState: GameState) {
        switch newState {
        case .won:
            SettingsViewModel.shared.playVictorySound()
            showingVictory = true
        case .lost:
            SettingsViewModel.shared.playDefeatSound()
            showingGameOver = true
        case .playing:
            break
        }
    }
}

// MARK: - Attempt Row View Component
struct AttemptRowView: View {
    let attempt: GameAttempt
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Color circles
            HStack(spacing: 8) {
                ForEach(0..<attempt.colors.count, id: \.self) { index in
                    Circle()
                        .fill(attempt.colors[index].color)
                        .frame(width: 35, height: 35)
                        .overlay(
                            Circle()
                                .stroke(attempt.colors[index].color, lineWidth: 1.5)
                                .frame(width: 38, height: 38)
                        )
                }
            }
            
            Spacer()
            
            // Hints grid (2x2)
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    HintDotView(hint: attempt.hints[0])
                    HintDotView(hint: attempt.hints[1])
                }
                HStack(spacing: 2) {
                    HintDotView(hint: attempt.hints[2])
                    HintDotView(hint: attempt.hints[3])
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

// MARK: - Hint Dot Component
struct HintDotView: View {
    let hint: HintType
    
    var body: some View {
        Circle()
            .fill(hintColor)
            .frame(width: 10, height: 10)
    }
    
    private var hintColor: Color {
        switch hint {
        case .correctPosition:
            return .green
        case .correctColor:
            return .red
        case .wrong:
            return .gray
        }
    }
}

#Preview {
    GameView(
        level: GameLevel(id: 1, location: .france, isUnlocked: true)
    )
}
