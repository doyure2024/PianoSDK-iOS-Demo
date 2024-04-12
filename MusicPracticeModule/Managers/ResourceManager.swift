//
//  ResourceManager.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import Foundation
import SwiftyJSON

/// Resource Manager
class ResourceManager: NSObject {
    static let shared = ResourceManager()
    
    var resource: Resource?
    
    /// Process control related to the current practice list
    var currentPracticeListIndex = 0
    var currentPracticeTime = 0
    
    /// Load resource
    func loadResource(from json: JSON) {
        currentPracticeListIndex = 0
        currentPracticeTime = 0
        resource = Resource(fromJson: json)
    }
    
    /// Go to the next practice
    func goNext() {
        if let resource = resource {
            if currentPracticeTime < resource.practiceList[currentPracticeListIndex].practiceTime {
                currentPracticeTime += 1
            }
            if currentPracticeTime >= resource.practiceList[currentPracticeListIndex].practiceTime {
                currentPracticeTime = 0
                currentPracticeListIndex = min(currentPracticeListIndex + 1, resource.practiceList.count - 1)
            }
        }
    }
}
