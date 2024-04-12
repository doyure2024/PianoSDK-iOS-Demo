//
//  LicenseManager.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import UIKit

class LicenseManager: NSObject {
    static let shared = LicenseManager()
    
    var license: String?
    
    func setLicense(_ lic: String) {
        license = lic
    }

}
