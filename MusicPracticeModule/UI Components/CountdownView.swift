//
//  CountdownView.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/28/21.
//

import UIKit

/// Countdown view in fixed speed mode
class CountdownView: UIView {
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80, weight: .semibold)
        label.textColor = .white
        label.text = "4"
        return label
    }()
    
    var timerSecond = 4 {
        didSet {
            timeLabel.text = String(timerSecond)
        }
    }
    var timer: Timer!
    var completion: (() -> ())!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(completion: @escaping ()->()) {
        super.init(frame: .zero)
        setupView()
        self.completion = completion
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 0.7)
        layer.cornerRadius = 16
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func countdown(in bpm: Double) {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(bpm), repeats: true) { (timer) in
            self.timerSecond -= 1
            if self.timerSecond == 0 {
                timer.invalidate()
                self.completion()
                self.removeFromSuperview()
                NotificationCenter.default.post(name: .EMCountDownFinished, object: nil)
                
            } else {
                self.timeLabel.text = "\(self.timerSecond)"
            }
        }
    }


}
