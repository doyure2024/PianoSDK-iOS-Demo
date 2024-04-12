//
//  PracticeRecord.swift
//  MusicPracticeModule
//
//  Created by Race Li on 2021/7/20.
//

import Foundation

struct PracticeRecord {
    var uuid: String!
    var mode: Int!
    var startDate: String!
    var endDate: String!
    var status: Bool! = false  // Indicates whether the score is completed or not
    var practiceTime = 0
    var score: PracticeScore!
}

struct PracticeScore {
    /// Speed score
    var speed = 0.0
    /// Intonation score
    var intonation = 0.0
    /// Completeness score
    var completeness = 0.0
    /// Rhythm score
    var rhythm = 0.0
    /// Smoothness score
    var smoothness = 0.0
    /// Total score
    var totalScore = 0.0
    
    func toString() -> String {
        return "PracticeScore(speed=\(speed), intonation=\(intonation), completeness=\(completeness), rhythm=\(rhythm), smoothness=\(smoothness), totalScore=\(totalScore))"
    }
}
