//
//  ResultView.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import UIKit

/// Result page after practice
class ResultView: UIView {

    var backgroundImageView: UIImageView!
    var tryAgainButton: UIButton!
    var reportButton: UIButton!
    var scores = [String : Double]()
    
    weak var delegate: ResultViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(withScores scores: [String : Double]) {
        /// Background image view for result popup
        backgroundImageView = UIImageView()
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.backgroundColor = .white
        backgroundImageView.image = UIImage(named: "ResultBackground")
        addSubview(backgroundImageView)
        backgroundImageView.layer.cornerRadius = 12
        backgroundImageView.clipsToBounds = true
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        /// Total score label
        let totalScorelabel = UILabel()
        totalScorelabel.text = String((100 * scores["Total Score"]!).rounded(toPlaces: 1))
        totalScorelabel.tintColor = .themeTint
        totalScorelabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        backgroundImageView.addSubview(totalScorelabel)
        totalScorelabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        /// Radar score chart
        let radarView = RadarView(frame: CGRect(x: (UIScreen.main.bounds.width - 350) / 2, y: 50, width: 216, height: 155))
        backgroundImageView.addSubview(radarView)
        radarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(53)
            make.bottom.equalToSuperview().offset(-68)
        }
        radarView.layer.cornerRadius = 12
        radarView.clipsToBounds = true
        radarView.backgroundColor = #colorLiteral(red: 0.9831872582, green: 0.9796274304, blue: 0.9867207408, alpha: 1)
        radarView.setTextColor(color: .themeTint)
        radarView.setDrawAreaColor(color: #colorLiteral(red: 0.9566624761, green: 0.5859056115, blue: 0.7361943722, alpha: 0.7696570592))
        radarView.setLineWidth(width: 0.5)
        radarView.setLineColor(color: #colorLiteral(red: 0.8606613278, green: 0.8480045199, blue: 0.9073385596, alpha: 1))
        radarView.setDotRadius(radius: 0)
        radarView.setDrawAreaColor(color: #colorLiteral(red: 0.9566624761, green: 0.5859056115, blue: 0.7361943722, alpha: 0.7696570592))
        radarView.setDotColor(color: UIColor.init(red: 121 / 255, green: 212 / 255, blue: 253 / 255, alpha: 1))
        radarView.setData(data: [RadarModel(title: "Stability", percent: CGFloat(scores["Stability"]!)), RadarModel(title: "Notes", percent: CGFloat(scores["Notes"]!)), RadarModel(title: "Speed", percent: CGFloat(scores["Speed"]!)), RadarModel(title: "Rhythm", percent: CGFloat(scores["Rhythm"]!)), RadarModel(title: "Completeness", percent: CGFloat(scores["Completeness"]!))])
        
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
        reportButton = UIButton()
        reportButton.setImage(UIImage(named: "Report"), for: .normal)
        addSubview(reportButton)
        reportButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        reportButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
    }
    
    @objc func didTapTryAgain() {
        delegate?.didTapTryAgain()
        didTapCancel()
    }

    @objc func didTapReport() {
        delegate?.didTapShowReport()
    }
    
    @objc func didTapCancel() {
        removeFromSuperview()
        delegate?.didTapCancel()
    }
}
