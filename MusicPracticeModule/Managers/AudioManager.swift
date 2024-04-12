//
//  AudioManager.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/14/21.
//

import UIKit
import AudioKit

/// Audio Manager
class AudioManager: NSObject {
    static let shared = AudioManager()
    
    var mic: AKMicrophone!
    var sequencer: AKSequencer!
    var metronome: AKMetronome!
    var mixer: AKMixer!
    var micMixer: AKMixer!
    var piano: AKMIDISampler!
    var pianoTrack: AKSequencerTrack!
    var player: AKPlayer!
    var timePitch: AKTimePitch!
    var cachedAudioFileURL: URL!
    var originalAccompanimentTempo = 120.0
    var metronomeBooster: AKBooster!
    
    private let conversionQueue = DispatchQueue(label: "conversionQueue")
    
    /// Handling of underlying microphone buffer
    func startEngine() {
        if AKManager.engine.isRunning {
            return
        }
        
        AKSettings.sampleRate = 48000
        AKSettings.channelCount = 2
        AKSettings.defaultToSpeaker = true
        try! AKSettings.setSession(category: .playAndRecord)
        mic = AKMicrophone()
        sequencer = AKSequencer()
        metronome = AKMetronome()
        metronomeBooster = AKBooster(metronome)
        metronomeBooster.gain = 3.0
        player = AKPlayer()
        timePitch = AKTimePitch(player)
        piano = AKMIDISampler(midiOutputName: "piano")
        micMixer = AKMixer(mic)
        micMixer.volume = 0
        mixer = AKMixer(piano, metronomeBooster, micMixer, timePitch)
        AKManager.output = mixer
        pianoTrack = sequencer.addTrack(for: piano)
        pianoTrack >>> mixer
        
        do {

            try piano.loadSoundFont("piano", preset: 0, bank: 0)
            try AKManager.start()
            let inputFormat = mic.avAudioNode.outputFormat(forBus: 0)
            let recordingFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: true)!
            guard let formatConverter = AVAudioConverter(from: inputFormat, to: recordingFormat) else {
                return
            }
            mic.avAudioNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(6144), format: inputFormat) { [weak self] (buffer, time) in
                guard let strongSelf = self else { return }
                strongSelf.conversionQueue.async {
                    let pcmBuffer = AVAudioPCMBuffer(pcmFormat: recordingFormat, frameCapacity: AVAudioFrameCount(2048))

                    var error: NSError? = nil

                    let inputBlock: AVAudioConverterInputBlock = {inNumPackets, outStatus in
                        outStatus.pointee = AVAudioConverterInputStatus.haveData
                        return buffer
                    }

                    formatConverter.convert(to: pcmBuffer!, error: &error, withInputFrom: inputBlock)
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    else if let channelData = pcmBuffer!.floatChannelData {

                        let channelDataValue = channelData.pointee
                        let channelDataValueArray = stride(from: 0,
                                                           to: Int(pcmBuffer!.frameLength),
                                                           by: pcmBuffer!.stride).map{ channelDataValue[$0] }
                        SessionManager.shared.signal(didReceive: channelDataValueArray)
                    }

                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopEngine() {
        stopAccompaniment()
        AKManager.engine.stop()
    }
    

    /// Update the sequence of notes for sheet music playback
    func updateSequence(from score: Score, with bpm: Double = 90) {
        sequencer.stop()
        pianoTrack.stop()
        pianoTrack.clear()
        sequencer.tempo = bpm
        pianoTrack.tempo = bpm

        if score.notes.isEmpty {
            return
        }
        // let firstNoteTimeStamp = score.notes[0][0].currentTimeStamp!
        
        for noteArray in score.notes {
            for note in noteArray {
                pianoTrack.add(noteNumber: MIDINoteNumber(note.key + 21), position: AKDuration(seconds: (note.currentTimeStamp - score.startTimeStamp / bpm) / 1000.0, tempo: Double(bpm)).beats, duration: AKDuration(seconds: note.duration / 1000.0, tempo: Double(bpm)).beats)
            }
        }
        pianoTrack.length = (score.notes.last!.first!.currentTimeStamp)! / 1000.0 - score.notes.first!.first!.currentTimeStamp / 1000.0 + 1000.0
        sequencer.length = pianoTrack.length
    }

    /// Start playing the accompaniment
    func startAccompaniment(from startingTime: Double) {
        do {
            try player.load(url: cachedAudioFileURL)
        } catch {
            print(error.localizedDescription)
        }
        timePitch.rate = Double(metronomeSpeed) / originalAccompanimentTempo
        // try player.load(audioFile: AKAudioFile(readFileName: "03-慢速伴奏-62.mp3"))
        player.prepare()
        player.play(from: startingTime)
    }

    func prepareAccompaniment(fromUrl url: URL, originalAccompanimentTempo originalTempo: Double) {
        do {
            guard let data = NSData(contentsOf: url) else {
                AKLog("Remote failed to load.")
                return
            }
            cachedAudioFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("cachedAudioFile.mp3") as URL
            print("url:", cachedAudioFileURL)
            try data.write(to: cachedAudioFileURL)
            originalAccompanimentTempo = originalTempo
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func prepareAccompaniment(fromLocalFile fileName: String, ofType fileType: String, originalAccompanimentTempo originalTempo: Double) {
        do {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
                AKLog("Local file not found.")
                return
            }
            cachedAudioFileURL = url
            print("url:", cachedAudioFileURL)
            originalAccompanimentTempo = originalTempo
        } catch {
            print("prepareAccompaniment error", error.localizedDescription)
        }
    }

    func stopAccompaniment() {
        player.stop()
    }

    /// Start the demonstration
    func startDemonstration(bpm: Double) {
        sequencer.loopEnabled = false
        sequencer.tempo = bpm
        pianoTrack.tempo = bpm
        print("[Swift]", sequencer.length, pianoTrack.length)
        print("[Swift]", pianoTrack.tempo, sequencer.tempo)
        sequencer.playFromStart()
    }

    /// Stop the demonstration
    func stopDemonstration() {
        sequencer.stop()
        pianoTrack.stop()
        pianoTrack.stopPlayingNotes()
    }

    /// Start the metronome
    func startMetronome(bpm: Double = 90) {
        metronome.tempo = bpm
        metronome.start()
    }

    /// Stop the metronome
    func stopMetronome() {
        metronome.stop()
    }

    /// Restart the metronome
    func restartMetronome(bpm: Double = 90) {
        metronome.tempo = bpm
        metronome.restart()
    }
}
