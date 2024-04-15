//
//  JiepaiqiShezhiViewController.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/24/21.
//

import UIKit

/// Metronome Popover Settings Interface
class MetronomePopoverViewController: UIViewController {
    
    /// Unified Process Manager
    let sessionManager = SessionManager.shared
    
    lazy var speedLabel: UILabel = {
        let label = UILabel()
        label.text = "拍子"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .themeTint
        return label
    }()
    
    lazy var metronomeLabel: UILabel = {
        let label = UILabel()
        label.text = "节拍器"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .themeTint
        return label
    }()
    
    lazy var speedSlider: UISlider = {
        let slider = UISlider()
        slider.isContinuous = false
        slider.minimumValue = 40
        slider.maximumValue = 150
        slider.thumbTintColor = .themeTint
        slider.tintColor = .gray
        return slider
    }()
    
    lazy var metronomeSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = sessionManager.isMetronomeOn
        switcher.onTintColor = .secondaryTint
        return switcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        /// UI operations after the interface is loaded
        view.addSubview(speedLabel)
        speedLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(48)
        }
        view.addSubview(speedSlider)
        speedSlider.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(85)
            make.centerY.equalTo(speedLabel)
        }
        speedSlider.addTarget(self, action: #selector(didMoveSlider), for: .allTouchEvents)
        speedSlider.setValue(Float(metronomeSpeed), animated: true)
        view.addSubview(metronomeLabel)
        metronomeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
        view.addSubview(metronomeSwitch)
        metronomeSwitch.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(metronomeLabel)
        }
        metronomeSwitch.addTarget(self, action: #selector(didTapSwitch), for: .valueChanged)
        if sessionManager.isMetronomeOn {
            speedSlider.thumbTintColor = .secondaryTint
            speedLabel.textColor = .secondaryTint
            metronomeLabel.textColor = .secondaryTint
        } else {
            speedSlider.thumbTintColor = .themeTint
            speedLabel.textColor = .themeTint
            metronomeLabel.textColor = .themeTint
        }
    }
    
    @objc func didTapSwitch() {
        sessionManager.isMetronomeOn = metronomeSwitch.isOn
        if metronomeSwitch.isOn {
            NotificationCenter.default.post(name: .EMTurnMetronomeOn, object: nil)
            sessionManager.restartMetronome(bpm: metronomeSpeed)
            speedSlider.thumbTintColor = .secondaryTint
            speedLabel.textColor = .secondaryTint
            metronomeLabel.textColor = .secondaryTint
        } else {
            NotificationCenter.default.post(name: .EMTurnMetronomeOff, object: nil)
            sessionManager.stopMetronome()
            speedSlider.thumbTintColor = .themeTint
            speedLabel.textColor = .themeTint
            metronomeLabel.textColor = .themeTint
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sessionManager.stopMetronome()
        NotificationCenter.default.post(name: .EMMetronomePopoverViewDidDisappear, object: nil, userInfo: nil)
    }
    
    @objc func didMoveSlider() {
        let speed = Double(Int(speedSlider.value))
        metronomeSpeed = speed
        NotificationCenter.default.post(name: .EMUpdateSpeed, object: nil, userInfo: ["speed": speed])
        if metronomeSwitch.isOn {
            sessionManager.restartMetronome(bpm: metronomeSpeed)
        }
    }

}
