//
//  GameViewModel.swift
//  TableM
//
//  Created by Alex on 23.07.2025.
//

import SwiftUI

// MARK: - Professor State
enum ProfessorState: Equatable {
    case hidden
    case speaking(message: String, isOnboarding: Bool = false)
}

// MARK: - Game View Model
class GameViewModel: ObservableObject {
    // Game State
    @Published var secretCombination: [GameColor] = []
    @Published var currentRow: CurrentRow = CurrentRow()
    @Published var attempts: [GameAttempt] = []
    @Published var gameState: GameState = .playing
    @Published var currentLevel: GameLevel
    @Published var professorState: ProfessorState = .hidden
    
    // Onboarding
    @Published var isFirstLevel: Bool = false
    @Published var onboardingMessages: [String] = []
    @Published var currentOnboardingIndex: Int = 0
    
    // References
    private let appState = AppStateManager.shared
    
    // Constants
    private let maxAttempts = 10
    private let availableColors = GameColor.allCases
    
    init(level: GameLevel) {
        self.currentLevel = level
        self.isFirstLevel = (level.location == .france && level.id == 1 && appState.playerProgress.totalGamesPlayed == 0)
        
        setupGame()
    }
    
    // MARK: - Game Setup
    private func setupGame() {
        generateSecretCombination()
        resetCurrentRow()
        attempts.removeAll()
        gameState = .playing
        
        appState.recordGamePlayed()
        
        // Show onboarding for first level
        if isFirstLevel {
            setupOnboarding()
        }
    }
    
    private func generateSecretCombination() {
        secretCombination = []
        for _ in 0..<4 {
            let randomColor = availableColors.randomElement()!
            secretCombination.append(randomColor)
        }
    }
    
    private func resetCurrentRow() {
        currentRow = CurrentRow()
    }
    
    private func setupOnboarding() {
        onboardingMessages = [
            "Ah, the code... Is hidden, but not forever! Time to turn on the deduction.",
            "Each colour is like a variable, and you are an equation looking for the truth.",
            "Your goal is to crack the secret code - a combination of 4 colors from the palette below.",
            "Select colors by tapping them. Each color will fill the highlighted position in your guess.",
            "After completing your row, press 'Check' to see the hints:",
            "🟢 Green dot = Right color in the right position",
            "🔴 Red dot = Right color but wrong position",
            "Empty space = Color not in the secret code",
            "You have 10 attempts to crack the code. Use logic and deduction to succeed!",
            "Ready to begin your first challenge? Good luck!"
        ]
        currentOnboardingIndex = 0
        professorState = .speaking(message: onboardingMessages[0], isOnboarding: true)
    }
    
    // MARK: - Game Actions
    func selectColor(_ color: GameColor) {
        guard gameState == .playing && professorState == .hidden else { return }
        currentRow.addColor(color)
    }
    
    func selectPosition(_ index: Int) {
        guard gameState == .playing && professorState == .hidden else { return }
        currentRow.selectIndex(index)
    }
    
    func checkCurrentRow() {
        guard gameState == .playing && currentRow.isComplete && professorState == .hidden else { return }
        
        let colors = currentRow.colors.compactMap { $0 }
        let hints = generateHints(for: colors)
        let attemptNumber = attempts.count + 1
        
        let attempt = GameAttempt(colors: colors, hints: hints, attemptNumber: attemptNumber)
        attempts.append(attempt)
        
        // Check for win condition
        if hints.allSatisfy({ $0 == .correctPosition }) {
            gameState = .won
            handleVictory(attempts: attemptNumber)
        } else if attempts.count >= maxAttempts {
            gameState = .lost
            handleDefeat()
        } else {
            // Continue playing
            resetCurrentRow()
            
            // Check for persistence achievement
            if attempts.count == maxAttempts {
                appState.recordPersistentPlay()
            }
        }
    }
    
    private func generateHints(for colors: [GameColor]) -> [HintType] {
        var hints: [HintType] = []
        var secretCopy = secretCombination
        var guessCopy = colors
        
        // First pass: find exact matches (correct position)
        for i in 0..<4 {
            if guessCopy[i] == secretCopy[i] {
                hints.append(.correctPosition)
                secretCopy[i] = GameColor.purple // Mark as used with dummy value
                guessCopy[i] = GameColor.red     // Mark as used with dummy value
            } else {
                hints.append(.wrong) // Placeholder, will be updated in second pass
            }
        }
        
        // Second pass: find color matches in wrong positions
        for i in 0..<4 {
            if hints[i] == .wrong { // Only check positions that weren't exact matches
                if let foundIndex = secretCopy.firstIndex(of: guessCopy[i]) {
                    hints[i] = .correctColor
                    secretCopy[foundIndex] = GameColor.purple // Mark as used
                }
            }
        }
        
        return hints
    }
    
    // MARK: - Game End Handling
    private func handleVictory(attempts: Int) {
        appState.completeLevel(
            location: currentLevel.location,
            levelId: currentLevel.id,
            attempts: attempts
        )
        
        // Update the current level reference to reflect completion
        if let updatedLevel = appState.playerProgress.levelForLocationAndId(location: currentLevel.location, levelId: currentLevel.id) {
            currentLevel = updatedLevel
        }
        
        showProfessorMessage(getProfessorVictoryMessage())
    }
    
    private func handleDefeat() {
        showProfessorMessage(getProfessorDefeatMessage())
    }
    
    // MARK: - Professor Messages
    func showProfessorMessage(_ message: String) {
        professorState = .speaking(message: message)
        
        // Auto-hide after 3 seconds (unless it's onboarding)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if case .speaking(_, let isOnboarding) = self.professorState, !isOnboarding {
                self.professorState = .hidden
            }
        }
    }
    
    func hideProfessor() {
        professorState = .hidden
    }
    
    // MARK: - Onboarding Navigation
    func nextOnboardingMessage() {
        guard case .speaking(_, true) = professorState else { return }
        
        currentOnboardingIndex += 1
        
        if currentOnboardingIndex < onboardingMessages.count {
            professorState = .speaking(message: onboardingMessages[currentOnboardingIndex], isOnboarding: true)
        } else {
            professorState = .hidden
        }
    }
    
    func skipOnboarding() {
        professorState = .hidden
    }
    
    // MARK: - Game Control
    func restartLevel() {
        setupGame()
    }
    
    func nextLevel() -> GameLevel? {
        let currentLocation = currentLevel.location
        let currentId = currentLevel.id
        
        if currentId < 5 {
            // Next level in same location
            return appState.playerProgress.levelForLocationAndId(location: currentLocation, levelId: currentId + 1)
        } else {
            // First level of next location
            if let currentLocationIndex = GameLocation.allCases.firstIndex(of: currentLocation),
               currentLocationIndex + 1 < GameLocation.allCases.count {
                let nextLocation = GameLocation.allCases[currentLocationIndex + 1]
                return appState.playerProgress.levelForLocationAndId(location: nextLocation, levelId: 1)
            }
        }
        
        return nil
    }
    
    // MARK: - Professor Messages
    private func getProfessorVictoryMessage() -> String {
        let messages = [
            "Excellent deduction! Your logical thinking is impressive.",
            "Brilliant work! You've cracked the code with skill and precision.",
            "Outstanding! Your analytical abilities are truly remarkable.",
            "Magnificent! Logic and patience have led you to victory.",
            "Superb reasoning! You've demonstrated the power of systematic thinking."
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    private func getProfessorDefeatMessage() -> String {
        let messages = [
            "Don't worry! Even the greatest minds need multiple attempts. Try again!",
            "Close, but not quite there! Logic puzzles require patience and practice.",
            "Every failed attempt teaches us something valuable. Keep experimenting!",
            "The code remains hidden, but your determination will crack it eventually!",
            "Remember: systematic elimination is key. You'll get it next time!"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Helper Methods
    func canCheckRow() -> Bool {
        return gameState == .playing && currentRow.isComplete && professorState == .hidden
    }
    
    func canInteract() -> Bool {
        return gameState == .playing && professorState == .hidden
    }
    
    var isGameComplete: Bool {
        return gameState == .won || gameState == .lost
    }
    
    var shouldShowNextLevelButton: Bool {
        return gameState == .won && nextLevel() != nil
    }
    
    var shouldShowSecretStoryButton: Bool {
        return gameState == .won && currentLevel.id == 5
    }
    
    // MARK: - Debug Methods (for development)
    #if DEBUG
    func revealSecret() {
        print("Secret combination: \(secretCombination.map { $0.rawValue })")
    }
    
    func autoWin() {
        currentRow.colors = secretCombination.map { $0 }
        currentRow.selectedIndex = 3
        checkCurrentRow()
    }
    #endif
}
