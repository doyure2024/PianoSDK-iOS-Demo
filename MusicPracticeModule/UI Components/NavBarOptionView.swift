//
//  NavBarOptionView.swift
//  MusicPractice
//
//  Created by kingcyk on 5/26/21.
//

import UIKit

/// Top navigation bar control delegate protocol
protocol NavBarOptionDelegate: AnyObject {
    func didTap(sender: NavBarOptionView)
}

/// Top navigation bar view
class NavBarOptionView: UIView {
    
    let sessionManager = SessionManager.shared
    var expandedBackgroundView: UIView!
    var expanded = false {
        didSet {
            if type != .metronome {
                guard let view = defaultBackgroundView else { return }
                view.backgroundColor = expanded ? #colorLiteral(red: 0.9450980392, green: 0.5450980392, blue: 0.6980392157, alpha: 1) : #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1)
            }
        }
    }
    var expandedInfoLabel: UILabel!
    var defaultBackgroundView: UIView!
    var defaultIconImageView: UIImageView!
    var titleLabel: UILabel!
    public var type: OptionType!
    public var isMetronomeOn = false { // only for jiepaiqi
        didSet {
            guard let view = defaultBackgroundView else { return }
            view.backgroundColor = isMetronomeOn ? #colorLiteral(red: 0.9450980392, green: 0.5450980392, blue: 0.6980392157, alpha: 1) : #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1)
            expandedBackgroundView.backgroundColor = isMetronomeOn ? #colorLiteral(red: 0.9450980392, green: 0.4901960784, blue: 0.662745098, alpha: 1) : #colorLiteral(red: 0.4475799781, green: 0.4349185927, blue: 0.6856368864, alpha: 1)
        }
    }
    public var isAccompanimentOn = false { // only for accompaniment
        didSet {
            guard let view = defaultBackgroundView else { return }
            view.backgroundColor = isAccompanimentOn ? #colorLiteral(red: 0.9450980392, green: 0.5450980392, blue: 0.6980392157, alpha: 1) : #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1)
            expandedBackgroundView.backgroundColor = isAccompanimentOn ? #colorLiteral(red: 0.9450980392, green: 0.4901960784, blue: 0.662745098, alpha: 1) : #colorLiteral(red: 0.4475799781, green: 0.4349185927, blue: 0.6856368864, alpha: 1)
            expandedInfoLabel.text = isAccompanimentOn ? "On" : "Off"
        }
    }
    
    weak var delegate: NavBarOptionDelegate?
    
    enum OptionType: String {
        case metronome
        case accompaniment
        case restartPracticeOrDemonstration
        case demonstration
        case settings
        case leftHand
        case rightHand
        case skipNote
        
        var title: String {
            switch self {
            case .metronome:
                return "节拍器"
            case .accompaniment:
                return "伴奏"
            case .restartPracticeOrDemonstration:
                return "重新开始"
            case .demonstration:
                return "演示"
            case .settings:
                return "设置"
            case .leftHand:
                return "左手"
            case .rightHand:
                return "右手"
            case .skipNote:
                return "跳过"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(type: OptionType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        expandedBackgroundView = UIView()
        if type == .metronome {
            expandedBackgroundView.backgroundColor = isMetronomeOn ? #colorLiteral(red: 0.9450980392, green: 0.4901960784, blue: 0.662745098, alpha: 1) : #colorLiteral(red: 0.4475799781, green: 0.4349185927, blue: 0.6856368864, alpha: 1)
        } else if type == .accompaniment {
            expandedBackgroundView.backgroundColor = isAccompanimentOn ? #colorLiteral(red: 0.9450980392, green: 0.4901960784, blue: 0.662745098, alpha: 1) : #colorLiteral(red: 0.4475799781, green: 0.4349185927, blue: 0.6856368864, alpha: 1)
        } else {
            expandedBackgroundView.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.4901960784, blue: 0.662745098, alpha: 1)
        }
        addSubview(expandedBackgroundView)
        expandedBackgroundView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(32)
        }
        expandedInfoLabel = UILabel()
        expandedInfoLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        expandedInfoLabel.textColor = .white
        if type == .metronome {
            expandedInfoLabel.text = "\(Int(metronomeSpeed))"
        } else if type == .accompaniment {
            expandedInfoLabel.text = sessionManager.isAccompanimentOn ? "On" : "Off"
        } else if type == .demonstration {
            expandedInfoLabel.text = "\(Int(sessionManager.demonstrationSpeed))"
        }
        expandedBackgroundView.addSubview(expandedInfoLabel)
        expandedInfoLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
        defaultBackgroundView = UIView()
        defaultBackgroundView.backgroundColor = #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1)
        addSubview(defaultBackgroundView)
        defaultBackgroundView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.size.equalTo(32)
        }
        defaultIconImageView = UIImageView()
        defaultIconImageView.image = UIImage(named: type.rawValue)
        defaultIconImageView.contentMode = .scaleAspectFit
        defaultIconImageView.tintColor = .white
        defaultBackgroundView.addSubview(defaultIconImageView)
        defaultIconImageView.snp.makeConstraints { (make) in
            make.size.equalTo(24)
            make.center.equalToSuperview()
        }
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1)
        titleLabel.text = type.title
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.centerX.equalToSuperview()
        }
        defaultBackgroundView.layer.cornerRadius = 16
        expandedBackgroundView.layer.cornerRadius = 16
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTap() {
        delegate?.didTap(sender: self)
    }
    
    @objc func turnMetronomeOn() {
        sessionManager.isMetronomeOn = true
        isMetronomeOn = true
        self.snp.updateConstraints { (make) in
            make.width.equalTo(64)
        }
        superview?.layoutIfNeeded()
    }
    
    @objc func turnMetronomeOff() {
        sessionManager.isMetronomeOn = false
        isMetronomeOn = false
        self.snp.updateConstraints { (make) in
            make.width.equalTo(64)
        }
        superview?.layoutIfNeeded()
    }
    
    @objc func turnAccompanimentOn() {
        sessionManager.isAccompanimentOn = true
        isAccompanimentOn = true
        self.snp.updateConstraints { (make) in
            make.width.equalTo(64)
        }
        superview?.layoutIfNeeded()
//        sessionManager.prepareAccompaniment(fromUrl: URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3")! , originalAccompanimentTempo: 62)
        sessionManager.prepareAccompaniment(fromLocalFile: "03-慢速伴奏-62", originalAccompanimentTempo: 62)
    }
    
    @objc func turnAccompanimentOff() {
        sessionManager.isAccompanimentOn = false
        isAccompanimentOn = false
        self.snp.updateConstraints { (make) in
            make.width.equalTo(64)
        }
        superview?.layoutIfNeeded()
    }
    
    @objc func selectDemoTempo(_ notification: Notification) {
        if let info = notification.userInfo {
            if let tempo = info["tempo"] as? Int {
                expandedInfoLabel.text = "\(tempo)"
                print("tempo", tempo)
            }
        }
        expanded = true
        self.snp.updateConstraints { (make) in
            make.width.equalTo(64)
        }
        superview?.layoutIfNeeded()
    }
    
    @objc func demoPerformanceOff() {
        expanded = false
        self.snp.updateConstraints { (make) in
            make.width.equalTo(32)
        }
        superview?.layoutIfNeeded()
    }
    
    @objc func updateSpeed(_ notification: Notification) {
        if let info = notification.userInfo {
            if let speed = info["speed"] as? Double {
                expandedInfoLabel.text = "\(Int(speed))"
            }
        }
    }
}
