//
//  AccompanimentPopoverViewController.swift
//  MusicPracticeModule
//
//  Created by Race Li on 2021/12/31.
//

import UIKit

class AccompanimentPopoverViewController: UIViewController {
    
    /// Unified Process Manager
    let sessionManager = SessionManager.shared
        
    lazy var accompanimentLabel: UILabel = {
        let label = UILabel()
        label.text = "Accompaniment"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .themeTint
        return label
    }()
        
    lazy var accompanimentSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .secondaryTint
        return switcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        /// UI operations after the interface is loaded
        view.addSubview(accompanimentLabel)
        accompanimentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(48)
        }
        view.addSubview(accompanimentSwitch)
        accompanimentSwitch.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(accompanimentLabel)
        }
        accompanimentSwitch.addTarget(self, action: #selector(didTapSwitch), for: .valueChanged)
        if sessionManager.isAccompanimentOn {
            accompanimentLabel.textColor = .secondaryTint
        } else {
            accompanimentLabel.textColor = .themeTint
        }
    }
    
    @objc func didTapSwitch() {
        sessionManager.isAccompanimentOn = accompanimentSwitch.isOn
        if accompanimentSwitch.isOn {
            NotificationCenter.default.post(name: .EMTurnAccompanimentOn, object: nil)
            accompanimentLabel.textColor = .secondaryTint
        } else {
            NotificationCenter.default.post(name: .EMTurnAccompanimentOff, object: nil)
            accompanimentLabel.textColor = .themeTint
        }
    }
        
}
