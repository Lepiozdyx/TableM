import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel: GameViewModel
    @ObservedObject private var playerProgress: PlayerProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    // UI State
    @State private var showingSettings = false
    @State private var showingVictory = false
    @State private var showingGameOver = false
    @State private var showingSecretStory = false
    
    init(level: GameLevel, playerProgress: PlayerProgressViewModel) {
        self.playerProgress = playerProgress
        self._gameViewModel = StateObject(wrappedValue: GameViewModel(level: level, playerProgress: playerProgress))
    }
    
    var body: some View {
        ZStack {
            // Background

            
            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar
                    .padding(.top, 10)
                
                // Question marks (current row at top)
                currentRowQuestionsView
                    .padding(.top, 20)
                
                // Game Content (History)
                gameContentView
                    .padding(.top, 20)
                
                Spacer()
                
                // Color Palette at bottom
                colorPaletteView
                    .padding(.bottom, 40)
            }
            
            // Professor Overlay
            if case .speaking(let message, let isOnboarding) = gameViewModel.professorState {
                ProfessorOverlayView(
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
            switch newState {
            case .won:
                showingVictory = true
            case .lost:
                showingGameOver = true
            case .playing:
                break
            }
        }
        .sheet(isPresented: $showingVictory) {
            VictoryView(
                level: gameViewModel.currentLevel,
                attempts: gameViewModel.attempts.count,
                coinsEarned: 100,
                hasNextLevel: gameViewModel.shouldShowNextLevelButton,
                hasSecretStory: gameViewModel.shouldShowSecretStoryButton,
                onNextLevel: {
                    if let nextLevel = gameViewModel.nextLevel() {
                        // Navigate to next level
                        showingVictory = false
                    }
                },
                onMenu: {
                    showingVictory = false
                    dismiss()
                },
                onSecretStory: {
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
                    showingGameOver = false
                    gameViewModel.restartLevel()
                },
                onMenu: {
                    showingGameOver = false
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showingSecretStory) {
            SecretStoryView(location: gameViewModel.currentLevel.location)
        }
        // .sheet(isPresented: $showingSettings) {
        //     SettingsView(playerProgress: playerProgress)
        // }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Settings Button
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
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
        .padding(.horizontal, 20)
    }
    
    // MARK: - Current Row Questions (Top)
    private var currentRowQuestionsView: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                Button(action: {
                    gameViewModel.selectPosition(index)
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                gameViewModel.currentRow.colors[index]?.color ??
                                Color.teal.opacity(0.7)
                            )
                            .frame(width: 50, height: 50)
                        
                        // Selection indicator
                        if gameViewModel.currentRow.selectedIndex == index {
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 56, height: 56)
                        }
                        
                        // Question mark for empty slots
                        if gameViewModel.currentRow.colors[index] == nil {
                            Text("?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(!gameViewModel.canInteract())
            }
            
            // Check button (appears when row is complete)
            if gameViewModel.canCheckRow() {
                Button(action: {
                    gameViewModel.checkCurrentRow()
                }) {
                    Text("Check")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameViewModel.canCheckRow())
        .padding(.horizontal, 20)
    }
    
    // MARK: - Game Content (Attempts History)
    private var gameContentView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameViewModel.attempts) { attempt in
                    AttemptRowView(attempt: attempt)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxHeight: 300)
    }
    
    // MARK: - Color Palette (8 colors in 2x4 grid)
    private var colorPaletteView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(GameColor.allCases, id: \.self) { color in
                Button(action: {
                    gameViewModel.selectColor(color)
                }) {
                    Circle()
                        .fill(color.color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .disabled(!gameViewModel.canInteract())
                .scaleEffect(gameViewModel.canInteract() ? 1.0 : 0.8)
                .animation(.easeInOut(duration: 0.2), value: gameViewModel.canInteract())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.black.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 20)
    }
}

// MARK: - Attempt Row View Component
struct AttemptRowView: View {
    let attempt: GameAttempt
    
    var body: some View {
        HStack(spacing: 0) {
            // Attempt number
            Text("\(attempt.attemptNumber)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30)
            
            Spacer()
            
            // Color circles
            HStack(spacing: 8) {
                ForEach(0..<attempt.colors.count, id: \.self) { index in
                    Circle()
                        .fill(attempt.colors[index].color)
                        .frame(width: 35, height: 35)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1.5)
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
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            return .clear
        }
    }
}

#Preview {
    GameView(
        level: GameLevel(id: 1, location: .france, isUnlocked: true),
        playerProgress: PlayerProgressViewModel()
    )
}
