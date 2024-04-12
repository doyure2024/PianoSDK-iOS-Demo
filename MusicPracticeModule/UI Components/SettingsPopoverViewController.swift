//
//  ShezhiShezhiViewController.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/25/21.
//

import UIKit

/// Keyboard display area
enum KeyboardShowingRange {
    case full, partial
}

/// Setting up the popover interface delegate protocol
protocol SettingsPopoverViewDelegate : class {
    func setKeyboardShowingRange(to range: KeyboardShowingRange)
    func alwaysShowInstrumentPanel(to alwaysOn: Bool)
}

/// Setting up a popover view controller
class SettingsPopoverViewController: UIViewController {
    
    weak var delegate: SettingsPopoverViewDelegate?
    
    /// UI controls
    lazy var fullLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Keyboard"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .themeTint
        return label
    }()
    
    lazy var fullSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = (keyboardShowingRange == .full) ? true : false
        switcher.onTintColor = .themeTint
        switcher.addTarget(self, action: #selector(fullSwitchValueDidChange(_:)), for: .valueChanged)
        return switcher
    }()

    lazy var alwayShowInstrumentPanelLabel: UILabel = {
        let label = UILabel()
        label.text = "Always Show Keyboard"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .themeTint
        return label
    }()
    
    lazy var alwayShowInstrumentPanelSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = showInstrumentPanel
        switcher.onTintColor = .themeTint
        switcher.addTarget(self, action: #selector(alwaysOnSwitchValueDidChange(_:)), for: .valueChanged)
        return switcher
    }()

    lazy var metronomeAlwaysOnLabel: UILabel = {
        let label = UILabel()
        label.text = "Default Metronome On"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .themeTint
        return label
    }()
    
    lazy var metronomeAlwaysOnSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = SessionManager.shared.defaultMetronomeOn
        switcher.onTintColor = .themeTint
        switcher.addTarget(self, action: #selector(metronomeAlwaysOnSwitchChange), for: .valueChanged)
        return switcher
    }()
    
    lazy var coinAnimationLabel: UILabel = {
        let label = UILabel()
        label.text = "Score Animation"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .themeTint
        return label
    }()
    
    lazy var coinAnimationSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = coinAnimationOn
        switcher.onTintColor = .themeTint
        switcher.addTarget(self, action: #selector(coinAnimationSwitchChange), for: .valueChanged)
        return switcher
    }()
    
    lazy var scrollHorizontallyLabel: UILabel = {
        let label = UILabel()
        label.text = "Horizontal Score"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .themeTint
        return label
    }()
        
    lazy var scrollHorizontallySwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = scrollHorizontally
        switcher.onTintColor = .themeTint
        switcher.addTarget(self, action: #selector(scrollHorizontallySwitchChange), for: .valueChanged)
        return switcher
    }()

    @objc func fullSwitchValueDidChange(_ sender: UISwitch) {
        keyboardShowingRange = sender.isOn ? .full : .partial
        print("keyboardShowingRange", keyboardShowingRange)
        delegate?.setKeyboardShowingRange(to: keyboardShowingRange)
    }

    @objc func alwaysOnSwitchValueDidChange(_ sender: UISwitch) {
        showInstrumentPanel = sender.isOn
        delegate?.alwaysShowInstrumentPanel(to: showInstrumentPanel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Layout of UI controls
        let fullStackView = UIStackView()
        fullStackView.axis = .horizontal
        fullStackView.distribution = .fill
        fullStackView.addArrangedSubview(fullLabel)
        fullStackView.addArrangedSubview(fullSwitch)
        let alwaysOnStackView = UIStackView()
        alwaysOnStackView.axis = .horizontal
        alwaysOnStackView.distribution = .fill
        alwaysOnStackView.addArrangedSubview(alwayShowInstrumentPanelLabel)
        alwaysOnStackView.addArrangedSubview(alwayShowInstrumentPanelSwitch)
        let jiepaiqiStackView = UIStackView()
        jiepaiqiStackView.axis = .horizontal
        jiepaiqiStackView.distribution = .fill
        jiepaiqiStackView.addArrangedSubview(metronomeAlwaysOnLabel)
        jiepaiqiStackView.addArrangedSubview(metronomeAlwaysOnSwitch)
        let coinAnimationView = UIStackView()
        coinAnimationView.axis = .horizontal
        coinAnimationView.distribution = .fill
        coinAnimationView.addArrangedSubview(coinAnimationLabel)
        coinAnimationView.addArrangedSubview(coinAnimationSwitch)
        let scrollHorizontallyView = UIStackView()
        scrollHorizontallyView.axis = .horizontal
        scrollHorizontallyView.distribution = .fill
        scrollHorizontallyView.addArrangedSubview(scrollHorizontallyLabel)
        scrollHorizontallyView.addArrangedSubview(scrollHorizontallySwitch)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(fullStackView)
        stackView.addArrangedSubview(alwaysOnStackView)
        stackView.addArrangedSubview(jiepaiqiStackView)
        stackView.addArrangedSubview(coinAnimationView)
        stackView.addArrangedSubview(scrollHorizontallyView)
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-24)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    @objc func metronomeAlwaysOnSwitchChange() {
        SessionManager.shared.defaultMetronomeOn = metronomeAlwaysOnSwitch.isOn
        NotificationCenter.default.post(name: .EMTurnMetronomeOn, object: nil)
    }
    
    @objc func coinAnimationSwitchChange() {
        coinAnimationOn = coinAnimationSwitch.isOn
    }
    
    @objc func scrollHorizontallySwitchChange() {
        scrollHorizontally = scrollHorizontallySwitch.isOn
        NotificationCenter.default.post(name: .EMScrollHorizontallySwitchChange, object: nil)
    }
    
}
