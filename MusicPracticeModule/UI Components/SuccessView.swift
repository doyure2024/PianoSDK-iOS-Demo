//
//  SuccessView.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import UIKit

protocol ResultViewDelegate: AnyObject {
    func didTapTryAgain()
    func didTapNext()
    func didTapShowReport()
    func didTapCancel()
}

/// Popup interface after current practice is completed
class SuccessView: UIView {
    
    var backgroundImageView: UIImageView!
    var tryAgainButton: UIButton!
    var nextButton: UIButton!
    var timerSecond = 5
    var timer: Timer?
    
    weak var delegate: ResultViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundImageView = UIImageView()
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.image = UIImage(named: "Success")
        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tryAgainButton = UIButton()
        tryAgainButton.setImage(UIImage(named: "TryAgain"), for: .normal)
        addSubview(tryAgainButton)
        tryAgainButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        tryAgainButton.addTarget(self, action: #selector(didTapTryAgain), for: .touchUpInside)
        nextButton = UIButton()
        nextButton.setTitle("下一步（\(timerSecond)s）", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        nextButton.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.5450980392, blue: 0.6980392157, alpha: 1)
        addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        nextButton.layer.cornerRadius = 18
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCancel))
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.addGestureRecognizer(tapRecognizer)
    }
    
    /// Automatic countdown for clicking
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.timerSecond -= 1
            if self.timerSecond == 0 {
                timer.invalidate()
                self.didTapNext()
            } else {
                self.nextButton.setTitle("下一步（\(self.timerSecond)s）", for: .normal)
            }
        }
    }
    
    @objc func didTapTryAgain() {
        delegate?.didTapTryAgain()
        didTapCancel()
    }

    @objc func didTapNext() {
        delegate?.didTapNext()
        didTapCancel()
    }
    
    @objc func didTapCancel() {
        timer?.invalidate()
        removeFromSuperview()
        delegate?.didTapCancel()
    }

}
