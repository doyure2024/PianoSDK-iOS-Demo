//
//  CountdownView.swift
//  MusicPracticeModule
// 倒计时视图
//  Created by kingcyk on 6/28/21.
//

import UIKit

/// Countdown view in fixed speed mode 节奏模式下的倒计时视图
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
        /// 定义一个定时器对象，并设置执行的时间间隔为1s，定时执行的任务代码位于尾部的闭包之中。
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(bpm), repeats: true) { (timer) in
            self.timerSecond -= 1
            if self.timerSecond == 0 {
                timer.invalidate() // 停止并删除这个计时器
                self.completion() // 完成计时器
                self.removeFromSuperview() // 删除计时器view
                NotificationCenter.default.post(name: .EMCountDownFinished, object: nil)
                
            } else {
                self.timeLabel.text = "\(self.timerSecond)"
            }
        }
    }


}
