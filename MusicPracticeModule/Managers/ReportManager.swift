//
//  ReportUtil.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/7/21.
//

import UIKit

/// Report Manager
class ReportManager: NSObject {
    static let shared = ReportManager()

    /// Getting the index of the error note
    func getWrongNodeIndices(noteCorrectWrongList: [Bool?]) -> [Int] {
        return noteCorrectWrongList.enumerated().filter { $0.element == false }.map { $0.offset }
    }

    /// Getting the range of confusion
    func getMessyRange(noteCorrectWrongList: [Bool?]) -> [[Int]] {
        let notePairList = noteCorrectWrongList.enumerated().filter { $0.element != nil }.map { ($0.offset, $0.element) }
        guard let firstIndex = notePairList.firstIndex(where: { $0.1 == false }) else { return [] }
        var index = firstIndex
        var correctNoteCount = 0
        var wrongNoteCount = 0
        var messyRangeList: [[Int]] = []
        var messyNoteList: [(Int, Bool)] = []
        while index < notePairList.count {
            let note = notePairList[index] as! (Int, Bool)
            if note.1 {
                correctNoteCount += 1
            } else {
                wrongNoteCount += 1
            }
            messyNoteList.append(note)
            index += 1
            if correctNoteCount + wrongNoteCount < 4 {
                continue
            }
            if wrongNoteCount < correctNoteCount {
                if correctNoteCount + wrongNoteCount == 4 {
                    messyNoteList.removeAll()
                    correctNoteCount = 0
                    wrongNoteCount = 0
                } else {
                    messyNoteList.removeLast()
                    messyRangeList.append([messyNoteList.first!.0, messyNoteList.last!.0])
                    messyNoteList.removeAll()
                    correctNoteCount = 0
                    wrongNoteCount = 0
                    if let nextIndex = notePairList.enumerated().first(where: { $0.element.1 == false && $0.offset > index }) {
                        index = nextIndex.offset
                    } else {
                        break
                    }
                }
            }
        }
        if !messyNoteList.isEmpty {
            messyRangeList.append([messyNoteList.first!.0, messyNoteList.last!.0])
        }
        return messyRangeList
    }

    /// Backup code for an alternative method to obtain the range of confusion, currently unused for debugging purposes:
    /*
    func getMessyRangeBackup(noteCorrectWrongList: [Bool?]) -> [[Int]] {
        var correctNoteCount = 0
        var wrongNoteCount = 0
        var invalidNoteCount = 0
        var startMessyIndex = -1
        var messyNoteList: [Int] = []
        var messyRangeList: [[Int]] = []
        var index = 0
        var nextWrongIndex = -1
        var remainCount = 0
        while index < noteCorrectWrongList.count {
            let noteResult = noteCorrectWrongList[index]
            if startMessyIndex == -1 && noteResult == false {
                startMessyIndex = index
            }
            if nextWrongIndex == -1 && index > startMessyIndex && noteResult == false {
                nextWrongIndex = index
            }
            if noteResult == nil {
                invalidNoteCount += 1
            } else if noteResult == false {
                wrongNoteCount += 1
            } else {
                correctNoteCount += 1
            }
            messyNoteList.append(index)
            index += 1
            if messyNoteList.count - invalidNoteCount >= 4 {
                if wrongNoteCount > correctNoteCount {
                    if messyNoteList.count - invalidNoteCount >= 4 {
                        if noteResult == nil {
                            remainCount += 1
                        } else if noteResult != false {
                            messyRangeList.append([startMessyIndex, index - 2])
                            correctNoteCount = 0
                            wrongNoteCount = 0
                            invalidNoteCount = 0
                            startMessyIndex = -1
                            nextWrongIndex = -1
                            messyNoteList.removeAll()
                        }
                    }
                } else {
                    correctNoteCount = 0
                    wrongNoteCount = 0
                    invalidNoteCount = 0
                    startMessyIndex = -1
                    if nextWrongIndex != -1 {
                        index = nextWrongIndex
                    }
                    nextWrongIndex = -1
                    messyNoteList.removeAll()
                }
            }
        }
        if messyNoteList.count - invalidNoteCount >= 4 {
            if wrongNoteCount > correctNoteCount {
                if noteCorrectWrongList[index - 1] == nil {
                    messyRangeList.append([startMessyIndex, index - 1 - remainCount])
                } else {
                    messyRangeList.append([startMessyIndex, index - 1])
                }
            }
        }
        return messyRangeList
    }
    */
}
