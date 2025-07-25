//
//  SettingsViewModel.swift
//  TableM
//
//  Created by Alex on 25.07.2025.
//

import AVFoundation
import SwiftUI

class SettingsViewModel: NSObject, ObservableObject {
    // Audio Players
    private var musicPlayer: AVAudioPlayer?
    private var soundPlayer: AVAudioPlayer?
    
    // Audio State
    @Published var isMusicPlaying = false
    @Published var currentMusicVolume: Float = 1.0
    @Published var currentSoundVolume: Float = 1.0
    
    // Audio Session
    private var audioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    func setupAudioSession() {
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
            print("Could not find music.mp3 file")
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
            print("Could not find sound.mp3 file")
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
        guard let musicPlayer = musicPlayer else {
            setupBackgroundMusic()
            return
        }
        
        if !musicPlayer.isPlaying && currentMusicVolume > 0 {
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
        guard let musicPlayer = musicPlayer else { return }
        
        if !musicPlayer.isPlaying && currentMusicVolume > 0 {
            musicPlayer.play()
            isMusicPlaying = true
        }
    }
    
    func updateMusicVolume(_ volume: Double) {
        let floatVolume = Float(volume)
        currentMusicVolume = floatVolume
        musicPlayer?.volume = floatVolume
        
        // Stop music if volume is 0, start if volume > 0
        if floatVolume == 0 {
            stopBackgroundMusic()
        } else if floatVolume > 0 && !isMusicPlaying {
            startBackgroundMusic()
        }
    }
    
    // MARK: - Sound Effects Control
    func playButtonSound() {
        guard let soundPlayer = soundPlayer, currentSoundVolume > 0 else { return }
        
        soundPlayer.stop()
        soundPlayer.currentTime = 0
        soundPlayer.play()
    }
    
    func playVictorySound() {
        // For now, use the same sound effect
        // In a real app, you might have different sound files
        playButtonSound()
    }
    
    func playDefeatSound() {
        // For now, use the same sound effect
        // In a real app, you might have different sound files
        playButtonSound()
    }
    
    func updateSoundVolume(_ volume: Double) {
        let floatVolume = Float(volume)
        currentSoundVolume = floatVolume
        soundPlayer?.volume = floatVolume
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
        if currentMusicVolume > 0 {
            resumeBackgroundMusic()
        }
    }
    
    func applyAudioSettings(musicVolume: Double, soundVolume: Double, musicEnabled: Bool, soundEnabled: Bool) {
        updateMusicVolume(musicEnabled ? musicVolume : 0.0)
        updateSoundVolume(soundEnabled ? soundVolume : 0.0)
        
        if musicEnabled && musicVolume > 0 {
            startBackgroundMusic()
        } else {
            stopBackgroundMusic()
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
    }
    
    // MARK: - App Lifecycle Methods
    func handleAppWillResignActive() {
        // Called when app is about to become inactive (like receiving a call)
        pauseAllAudio()
    }
    
    func handleAppDidEnterBackground() {
        // Called when app enters background
        stopAllAudio()
    }
    
    func handleAppWillEnterForeground() {
        // Called when app is about to enter foreground
        setupAudioSession()
        if currentMusicVolume > 0 {
            resumeBackgroundMusic()
        }
    }
    
    func handleAppDidBecomeActive() {
        // Called when app becomes active
        if currentMusicVolume > 0 && !isMusicPlaying {
            startBackgroundMusic()
        }
    }
    
    // MARK: - Audio Interruption Handling
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let interruptionType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else {
            return
        }
        
        switch interruptionType {
        case AVAudioSession.InterruptionType.began.rawValue:
            // Audio interruption began (like phone call)
            pauseAllAudio()
            
        case AVAudioSession.InterruptionType.ended.rawValue:
            // Audio interruption ended
            if let optionsValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Resume audio if appropriate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.resumeAllAudio()
                    }
                }
            }
            
        default:
            break
        }
    }
    
    deinit {
        stopAllAudio()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - AVAudioPlayerDelegate
extension SettingsViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == musicPlayer {
            isMusicPlaying = false
            
            // Restart music if it should be playing (for safety, though numberOfLoops = -1 should handle this)
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
            // Try to recreate the music player
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.setupBackgroundMusic()
            }
        }
    }
}

// MARK: - Singleton for Global Access
extension SettingsViewModel {
    static let shared = SettingsViewModel()
}
