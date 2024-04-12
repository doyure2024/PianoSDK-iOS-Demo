//
//  UIColor+Extension.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/24/21.
//

import UIKit
import WebKit

extension UIColor {
    static let themeTint = UIColor(named: "ThemeTint")!
    static let secondaryTint = UIColor(named: "SecondaryTint")!
}

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
