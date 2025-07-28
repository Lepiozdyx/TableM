//
//  SettingsViewModel.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import AVFoundation
import SwiftUI

class SettingsViewModel: NSObject, ObservableObject {

    static let shared = SettingsViewModel()
    
    // Audio Players
    private var musicPlayer: AVAudioPlayer?
    private var soundPlayer: AVAudioPlayer?
    
    // Audio State
    @Published var isMusicPlaying = false
    @Published var currentMusicVolume: Float = 1.0
    @Published var currentSoundVolume: Float = 1.0
    
    // Audio Session
    private var audioSession = AVAudioSession.sharedInstance()
    
    // Player Progress Reference
    var playerProgress: PlayerProgressViewModel?
    private var isInitialized = false
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Player Progress Integration
    func setPlayerProgress(_ progress: PlayerProgressViewModel) {
        self.playerProgress = progress
        
        if !isInitialized {
            currentMusicVolume = Float(progress.musicVolume)
            currentSoundVolume = Float(progress.soundVolume)
            
            setupAudio()
            applyCurrentSettings()
            isInitialized = true
        } else {
            updateVolumeSettings()
        }
    }
    
    private func updateVolumeSettings() {
        guard let progress = playerProgress else { return }
        
        currentMusicVolume = Float(progress.musicVolume)
        currentSoundVolume = Float(progress.soundVolume)
        
        musicPlayer?.volume = currentMusicVolume
        soundPlayer?.volume = currentSoundVolume
    }
    
    private func applyCurrentSettings() {
        guard let progress = playerProgress else { return }
        
        updateMusicVolume(progress.musicVolume)
        updateSoundVolume(progress.soundVolume)
        
        if progress.isMusicEnabled && progress.musicVolume > 0 {
            startBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Audio Setup
    func setupAudio() {
        setupBackgroundMusic()
        setupSoundEffects()
    }
    
    private func setupBackgroundMusic() {
        guard let musicURL = Bundle.main.url(forResource: "music", withExtension: "mp3") else {
            print("Could not find background_music.mp3 file")
            return
        }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
            musicPlayer?.delegate = self
            musicPlayer?.numberOfLoops = -1 // Infinite loop
            musicPlayer?.volume = currentMusicVolume
            musicPlayer?.prepareToPlay()
        } catch {
            print("Failed to setup background music: \(error.localizedDescription)")
        }
    }
    
    private func setupSoundEffects() {
        guard let soundURL = Bundle.main.url(forResource: "sound", withExtension: "mp3") else {
            print("Could not find button_click.mp3 file")
            return
        }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            soundPlayer?.volume = currentSoundVolume
            soundPlayer?.prepareToPlay()
        } catch {
            print("Failed to setup sound effects: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Background Music Control
    func startBackgroundMusic() {
        guard let musicPlayer = musicPlayer,
              let progress = playerProgress,
              progress.isMusicEnabled && progress.musicVolume > 0 else { return }
        
        if !musicPlayer.isPlaying {
            musicPlayer.play()
            isMusicPlaying = true
        }
    }
    
    func stopBackgroundMusic() {
        musicPlayer?.stop()
        isMusicPlaying = false
    }
    
    func pauseBackgroundMusic() {
        musicPlayer?.pause()
        isMusicPlaying = false
    }
    
    func resumeBackgroundMusic() {
        guard let musicPlayer = musicPlayer,
              let progress = playerProgress,
              progress.isMusicEnabled && progress.musicVolume > 0 else { return }
        
        if !musicPlayer.isPlaying {
            musicPlayer.play()
            isMusicPlaying = true
        }
    }
    
    func updateMusicVolume(_ volume: Double) {
        let floatVolume = Float(volume)
        currentMusicVolume = floatVolume
        musicPlayer?.volume = floatVolume
        
        guard let progress = playerProgress else { return }
        
        // Update player progress
        progress.musicVolume = volume
        progress.isMusicEnabled = volume > 0
        
        // Save changes
        DataManager.shared.savePlayerProgress(progress)
        
        // Control music playback
        if floatVolume == 0 || !progress.isMusicEnabled {
            stopBackgroundMusic()
        } else if floatVolume > 0 && progress.isMusicEnabled && !isMusicPlaying {
            startBackgroundMusic()
        }
    }
    
    // MARK: - Sound Effects Control
    func playButtonSound() {
        guard let soundPlayer = soundPlayer,
              let progress = playerProgress,
              progress.isSoundEnabled && progress.soundVolume > 0 else { return }
        
        soundPlayer.stop()
        soundPlayer.currentTime = 0
        soundPlayer.play()
    }
    
    func playVictorySound() {
        playButtonSound()
    }
    
    func playDefeatSound() {
        playButtonSound()
    }
    
    func updateSoundVolume(_ volume: Double) {
        let floatVolume = Float(volume)
        currentSoundVolume = floatVolume
        soundPlayer?.volume = floatVolume
        
        guard let progress = playerProgress else { return }
        
        // Update player progress
        progress.soundVolume = volume
        progress.isSoundEnabled = volume > 0
        
        // Save changes
        DataManager.shared.savePlayerProgress(progress)
    }
    
    // MARK: - Complete Audio Control
    func stopAllAudio() {
        stopBackgroundMusic()
        soundPlayer?.stop()
    }
    
    func pauseAllAudio() {
        pauseBackgroundMusic()
        soundPlayer?.stop()
    }
    
    func resumeAllAudio() {
        guard let progress = playerProgress else { return }
        
        if progress.isMusicEnabled && progress.musicVolume > 0 {
            resumeBackgroundMusic()
        }
    }
    
    func initializeWithDefaults() {
        guard let progress = playerProgress else { return }
        
        // Set up audio with current settings
        setupAudio()
        
        // Apply settings
        currentMusicVolume = Float(progress.musicVolume)
        currentSoundVolume = Float(progress.soundVolume)
        
        musicPlayer?.volume = currentMusicVolume
        soundPlayer?.volume = currentSoundVolume
        
        // Start music if enabled
        if progress.isMusicEnabled && progress.musicVolume > 0 {
            startBackgroundMusic()
        }
    }
    
    // MARK: - Utility Methods
    var isMusicAvailable: Bool {
        return musicPlayer != nil
    }
    
    var isSoundAvailable: Bool {
        return soundPlayer != nil
    }
    
    func refreshAudioPlayers() {
        stopAllAudio()
        setupAudio()
        applyCurrentSettings()
    }
    
    deinit {
        stopAllAudio()
    }
}

// MARK: - AVAudioPlayerDelegate
extension SettingsViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == musicPlayer {
            isMusicPlaying = false
            
            if flag && currentMusicVolume > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.startBackgroundMusic()
                }
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        
        if player == musicPlayer {
            isMusicPlaying = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.setupBackgroundMusic()
            }
        }
    }
}
