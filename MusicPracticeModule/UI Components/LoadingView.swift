//
//  LoadingView.swift
//  MusicPractice
//
//  Created by kingcyk on 5/26/21.
//

import UIKit

/// Interface for loading process 加载过程页面
class LoadingView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var loadingImageView: UIImageView!
    var progressBgView: UIView!
    var progressView: UIView!
    var progress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        loadingImageView = UIImageView()
        loadingImageView.image = UIImage(named: "Loading")
        loadingImageView.contentMode = .scaleAspectFit
        addSubview(loadingImageView)
        loadingImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(213)
            make.height.equalTo(62)
        }
        progressBgView = UIView()
        progressBgView.backgroundColor = #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 0.1)
        addSubview(progressBgView)
        progressBgView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(8)
        }
        progressView = UIView()
        progressView.backgroundColor = #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.5254901961, alpha: 1)
        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(8)
            make.width.equalTo(0)
        }
        progressBgView.layer.cornerRadius = 4
        progressView.layer.cornerRadius = 4
    }
    
    func setProgress(_ progress: CGFloat) {
        self.progress = progress
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UIView.animate(withDuration: 0.5) {
            self.progressView.snp.updateConstraints { (make) in
                make.width.equalTo(self.progressBgView.bounds.width * self.progress)
            }
            self.layoutIfNeeded()
        }
    }
    
}
