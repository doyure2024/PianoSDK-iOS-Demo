//
//  SdkManager.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import Foundation
import AVFoundation

/// SDK Proxy Protocol
protocol LibDelegate: class {
    func targetMet()
    func keys(keys: [Int])
    func setStartDate(_ startDate: Date)
    func notMetForALongTime()
}

protocol CalibrateDelegate {
    func keysForCalibrate(keys: [Int])
}

/// SDK Manager
class SdkManager: NSObject {
    
    static let shared = SdkManager()
    weak var delegate: LibDelegate?
    var calibrateDelegate: CalibrateDelegate?
    
    var currentIndex: Int32 = 0
    var startDate: Date!
    var lastMetDate = Date()
    var currentDate: Date!
    var singleNoteRecognitionTime: Date!
    var started = false
    var shouldResume = false
    var shouldStopDueToDemonstration = false
    var currentMetronomeTempo = 90
    var isRunningModel = false

    var currentMode = 0 {
        didSet {
            startDate = Date()
        }
    }
    
    var lib = SdkLib()
    
    func loadModel(path: String) {
        lib.setThread(-1) // Int32(ProcessInfo.processInfo.processorCount)
        lib.loadModel(NSString(string: path).utf8String)
    }
    
    func loadClsModel(path: String) {
        lib.loadClsModel(NSString(string: path).utf8String)
    }
    
    func loadLicense(license: String) {
        lib.initialize()
        lib.loadLicense(license)
    }
    
    func setThread(thread: Int) {
        lib.setThread(Int32(thread))
    }
    
    func setLowThreshold(threshold: Float) {
        lib.setLowThreshold(threshold)
    }
    
    func setCheckPercent(percent: Float) {
        lib.setCheckPercent(percent)
    }
    
    func loadScore(document: String) {
        lib.loadScore(document)
    }
    
    func prepare() {
        lib.prepare()
    }
    
    func skipNext() -> Bool {
        if lib.skipNext() {
            lastMetDate = Date()
            return true
        }
        return false
    }
    
    func setMode(mode: Int) {
        currentMode = mode
        lib.setMode(Int32(mode))
    }
    
    func getScore() -> [Double] {
        print("score:", lib.getScore()!)
        var scoreArray: [Double] = lib.getScore()!.compactMap({ $0 as? Double })
        for i in 0..<scoreArray.count {
            if scoreArray[i].isNaN {
                scoreArray[i] = 0
            }
        }
        return scoreArray
    }
    
    func getReport() {
        print("report:", lib.getReport()!)
    }
    
    func createNewLib() {
        while isRunningModel {
            print("[WARN]", "CreateNewLib:", "Should create now, but previous running")
            Thread.sleep(forTimeInterval: 0.05)
        }
        lib = SdkLib()
    }

    func runModel(on buffer: [Float]) {
        currentDate = Date()
        if buffer.count != 2048 {
            print(buffer.count)
            isRunningModel = false
            return
        }
        isRunningModel = true
        let pointer = UnsafeMutablePointer<Float>.allocate(capacity: buffer.count)
        pointer.initialize(from: buffer, count: buffer.count)
        
        /// Usage of SDK modes: 0 - Recognition, 1 - Followed play, 2 - Free play.
        switch currentMode {
        case 0:
            let currentDate = Date()
            if lib.shouldGoNext(pointer, andLength: 2048) {
                if Date().timeIntervalSince(startDate) > 0 {
                    lastMetDate = currentDate
                    delegate?.targetMet()
                }
            }
            if currentDate.timeIntervalSince(lastMetDate) > 5 {
                delegate?.notMetForALongTime()
            }
            // print("Real-time rate", Date().timeIntervalSince(currentDate) / 0.112)
            
        case 1:
            let hostTime = Int32(Date().timeIntervalSince(startDate) * 1000)
            if let result = lib.keys(atHostTime: pointer, length: 2048, andHostTime: hostTime) as? [Int] {
                delegate?.keys(keys: result)
            }
        case 3:
            if let result = lib.compute(pointer, length: 2048) as? [Int] {
                /// Recognition of sound used for calibration
                calibrateDelegate?.keysForCalibrate(keys: result)
            }
        default:
            break
        }
        isRunningModel = false
    }
}
