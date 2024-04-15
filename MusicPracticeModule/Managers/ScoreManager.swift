//
//  ScoreManager.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/3/21.
//

import UIKit
import SwiftyJSON
import Pitchy

/// Score Manager乐谱处理器
class ScoreManager: NSObject {
    static let shared = ScoreManager()
    var score: Score?
    
    /// Loading sheet music for SDK 加载SDK的乐谱
    func getSdkScore(hand: Int) -> String? {
        if let score = score {
            var result = JSON()
            var notes: [JSON] = []
            let notesToLoop: [[ScoreNote]] = hand == 0 ? score.notes : score.notes.filter { $0.contains { $0.hand == hand } }
            for noteArray in notesToLoop {
                var tempArray: [JSON] = []
                let tempToLoop: [ScoreNote] = hand == 0 ? noteArray : noteArray.filter { $0.hand == hand }
                for note in tempToLoop {
                    var noteJson = JSON()
                    noteJson["key"].int = note.key
                    noteJson["index"].int = note.index
                    noteJson["time"].int = note.time
                    noteJson["duration"].int = note.duration
                    tempArray.append(noteJson)
                }
                notes.append(JSON(tempArray))
            }
            result["bpm"].double = score.bpm
            result["notes"] = JSON(notes)
            return result.rawString([.castNilToNSNull: true])!
        } else {
            return nil
        }
    }
    
    /// Handling of left and right hand in sheet music 乐谱中左右手的处理
    func getHandScore(hand: Int, bpm: Double = 90) -> Score? {
        if let score = score {
            let result = Score()
            result.bpm = bpm
            if hand == 0 {
                result.notes = score.notes
            } else {
                result.notes = score.notes.compactMap { $0.filter { $0.hand == hand }.selfOrNilIfEmpty }
            }
            result.startTimeStamp = score.startTimeStamp
            return result
        } else {
            return nil
        }
    }
    
    /// Load sheet
    func loadScore(from json: JSON, bpm: Double = 90) {
        var result = Score()
        result.bpm = bpm
        let allNotes = json["allNotes"].arrayValue
        var allNotesArray: [[ScoreNote]] = []
        var time = 0
        var index = 0
        var timeStampArray = [Int]()
        var isFirstNoteRest = true
        
        if allNotes.isEmpty {
            return
        }
        
        /// Parsing from JSON
        let startTimeStamp = Int((allNotes.first?.arrayValue.first!["ctsRealValue"].doubleValue)! * 4 * 60.0 * 1000)
        
        for noteJSON in allNotes {
            let noteSeq = noteJSON.arrayValue
            var noteArray: [ScoreNote] = []
            var timeSeq = Int.max
            
            for note in noteSeq {
                var scoreNote = ScoreNote()
                if note["frequency"].doubleValue == 0 {
                    if isFirstNoteRest {
                        scoreNote.key = -1
                        isFirstNoteRest = false
                    } else {
                        isFirstNoteRest = false
                        continue
                    }
                } else {
                    isFirstNoteRest = false
                    let notePitchy = try! Note(frequency: note["frequency"].doubleValue)
                    scoreNote.key = notePitchy.index + 48
                }
                
                let handId = note["id"].intValue
                let realLength = note["realValue"].doubleValue
                let ctsRealValue = note["ctsRealValue"].doubleValue
                let duration = Int(realLength * 4 * 60.0 * 1000 / Double(bpm))
                let currentTimeStamp = Int(ctsRealValue * 4 * 60.0 * 1000 / Double(bpm))
                
                timeStampArray.append(currentTimeStamp)
                
                scoreNote.hand = handId
                scoreNote.index = index
                scoreNote.time = time
                scoreNote.duration = duration
                scoreNote.currentTimeStamp = currentTimeStamp
                
                noteArray.append(scoreNote)
                index += 1
                timeSeq = min(timeSeq, duration)
            }
            // print("index, timeSeq:", index, timeSeq)

            if !noteArray.isEmpty {
                allNotesArray.append(noteArray)
            }
            if timeSeq != Int.max {
                time = time + timeSeq
            }
        }
        
        timeStampArray = [Int](Set(timeStampArray)).sorted()
        
        /*
        for i in 1..<timeStampArray.count {
            let timeInterval = timeStampArray[i] - timeStampArray[i - 1]
            for noteArray in allNotesArray {
                for note in noteArray {
                    if note.currentTimeStamp == timeStampArray[i - 1] {
                        note.duration = timeInterval
                        
                    }
                }
            }
        }
        */
        
        result.notes = allNotesArray
        result.startTimeStamp = startTimeStamp
        score = result
    }
}

/// Classes and enumerations related to format definitions
class Score: NSObject {
    var notes: [[ScoreNote]]!
    var bpm: Double!
    var startTimeStamp = 0
}

class ScoreNote: NSObject {
    var key: Int!
    var index: Int!
    var time: Int!
    var duration: Int!
    var hand: Int! // full 0, right 1, left 2
    var currentTimeStamp: Int!
}

enum ScoreType {
    case full, right, left
}

enum InstrumentType {
    case piano, guitar, violin
}
