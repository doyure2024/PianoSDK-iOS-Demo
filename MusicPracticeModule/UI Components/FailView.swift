//
//  FailView.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import UIKit

/// Popup interface after current practice fails
class FailView: UIView {
    
    var backgroundImageView: UIImageView!
    var tryAgainButton: UIButton!
    
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
        backgroundImageView.image = UIImage(named: "Fail")
        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tryAgainButton = UIButton()
        tryAgainButton.setImage(UIImage(named: "TryAgain"), for: .normal)
        addSubview(tryAgainButton)
        tryAgainButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        tryAgainButton.addTarget(self, action: #selector(didTapTryAgain), for: .touchUpInside)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCancel))
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.addGestureRecognizer(tapRecognizer)
    }

    @objc func didTapTryAgain() {
        delegate?.didTapTryAgain()
        didTapCancel()
    }

    @objc func didTapCancel() {
        removeFromSuperview()
        delegate?.didTapCancel()
    }

}
