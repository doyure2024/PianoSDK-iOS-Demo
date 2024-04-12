//
//  SessionManager.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/28/21.
//

import UIKit

/// Enum for demonstration hands (left, right, full)
enum HandsForDemonstration {
    case left, right, full
}

/// Session Manager
class SessionManager: NSObject {
    static let shared = SessionManager()
    
    let audioManager = AudioManager.shared
    let sdkManager = SdkManager.shared
    
    var defaultMetronomeOn = false
    var isFirstStart = true
    var isSdkReady = false
    var isStarted = false
    var isInDemonstration = false
    var isMetronomeOn = false
    var isAccompanimentOn = false
    var handsForDemoPerformance = HandsForDemonstration.full
    var isInDemonstrationMode = false
    var timer: Timer?

    var demonstrationSpeed = 90.0
    var demonstrationCount = -1
    
    /// Start the audio engine
    func startAudioEngine() {
        audioManager.startEngine()
    }
    
    func stopAudioEngine() {
        audioManager.stopEngine()
    }

    /// Called after receiving audio buffer
    func signal(didReceive buf: [Float]) {
        if isSdkReady && isStarted {
            sdkManager.runModel(on: buf)
        }
    }
    
    /// SDK instance creation
    func createSdk() {
        isSdkReady = false
        sdkManager.createNewLib()
        if let license = LicenseManager.shared.license {
            sdkManager.loadLicense(license: license)
            sdkManager.loadModel(path: Bundle.main.path(forResource: "piano", ofType: "tflite")!)
            sdkManager.loadClsModel(path: Bundle.main.path(forResource: "classifier", ofType: "tflite")!)
            sdkManager.prepare()
            isSdkReady = true
        } else {
            print("[ERROR]", "error loading license")
        }
    }
    
    /// Start the practice
    func start() {
        isStarted = true
    }
    
    func startAccompaniment(from startingTime: Double) {
        audioManager.startAccompaniment(from: startingTime)
    }
    
    func prepareAccompaniment(fromLocalFile fileName: String, originalAccompanimentTempo originalTempo: Double) {
        audioManager.prepareAccompaniment(fromLocalFile: fileName, ofType: "mp3", originalAccompanimentTempo: originalTempo)
    }
    
    func prepareAccompaniment(fromUrl url: URL, originalAccompanimentTempo originalTempo: Double) {
        audioManager.prepareAccompaniment(fromUrl: url, originalAccompanimentTempo: originalTempo)
    }
    
    func stopAccompaniment() {
        audioManager.stopAccompaniment()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(checkTimeInterval), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    @objc func checkTimeInterval() {
        NotificationCenter.default.post(name: .EMCheckTimeInterval, object: nil)
    }
    
    /// Stop the practice
    func stop() {
        isStarted = false
        audioManager.stopAccompaniment()
    }
    
    /// Start the demonstration
    func startDemonstration(bpm: Double) {
        demonstrationCount = -1
        isInDemonstration = true
        audioManager.startDemonstration(bpm: bpm)
    }
    
    /// Stop the demonstration
    func stopDemonstration() {
        isInDemonstration = false
        audioManager.stopDemonstration()
    }
    
    /// Start the metronome
    func startMetronome() {
        audioManager.startMetronome(bpm: metronomeSpeed)
    }
    
    /// Stop the metronome
    func stopMetronome() {
        audioManager.stopMetronome()
    }
    
    /// Restart the metronome
    func restartMetronome(bpm: Double) {
        audioManager.restartMetronome(bpm: bpm)
    }
    
    /// Update the sequence of notes for sheet music playback
    func updateSequence(from score: Score) {
        audioManager.updateSequence(from: score, with: metronomeSpeed)
    }
}
