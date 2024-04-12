//
//  Foundation+Extension.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import Foundation

extension Sequence where Self.Element: Equatable {
    @inline(__always)
    func doesNotContain(_ member: Element) -> Bool {
        return !contains(member)
    }
}

extension Collection {
    var selfOrNilIfEmpty: Self? {
        return isEmpty ? nil : self
    }
}

extension Notification.Name {
    static let EMReadyToStart = Notification.Name("EMReadyToStart")
    static let EMTurnMetronomeOn = Notification.Name("EMTurnMetronomeOn")
    static let EMTurnMetronomeOff = Notification.Name("EMTurnMetronomeOff")
    static let EMTurnAccompanimentOn = Notification.Name("EMTurnAccompanimentOn")
    static let EMTurnAccompanimentOff = Notification.Name("EMTurnAccompanimentOff")
    static let EMUpdateSpeed = Notification.Name("EMUpdateSpeed")
    static let EMSelectDemoTempo = Notification.Name("EMSelectDemoTempo")
    static let EMDemoPerformanceOff = Notification.Name("EMDemoPerformanceOff")
    static let EMBackFromReportAndGoNext = Notification.Name("EMBackFromReportAndGoNext")
    static let EMBackFromReportAndTryAgain = Notification.Name("EMBackFromReportAndTryAgain")
    static let EMCountDownFinished = Notification.Name("EMCountDownFinished")
    static let EMCheckTimeInterval = Notification.Name("EMCheckTimeInterval")
    static let EMScrollHorizontallySwitchChange = Notification.Name("EMScrollHorizontallySwitchChange")
    static let EMMetronomePopoverViewDidDisappear = Notification.Name("EMMetronomePopoverViewDidDisappear")

    static let EMApplicationDidBecomeActive = Notification.Name("EMApplicationDidBecomeActive")
    static let EMApplicationWillResignActive = Notification.Name("EMApplicationWillResignActive")

}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
