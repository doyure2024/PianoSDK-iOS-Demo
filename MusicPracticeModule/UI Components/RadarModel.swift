//
//  RadarModel.swift
//  MusicPracticeModule
//
//  Created by Race Li on 2021/7/20.
//

import UIKit

class RadarModel: NSObject {

    var title: String!
    var percent: CGFloat!
    
    init(title: String, percent: CGFloat) {
        super.init()
        self.title = title
        self.percent = percent
    }
}
