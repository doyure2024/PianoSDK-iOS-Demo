//
//  ShifanTempoSelectionViewController.swift
//  MusicPracticeModule
//
//  Created by Race Li on 2021/6/28.
//

import UIKit

/// Demo popover view delegate protocol
protocol DemonstrationTempoSelectionViewDelegate : class {
    func demoTempoSelected(to tempo: Double)
    func offSelected()
}

/// Demo popover view controller
class DemonstrationTempoSelectionViewController: UIViewController {
    
    weak var delegate: DemonstrationTempoSelectionViewDelegate?
    var isOn = false {
        didSet {
            if !isOn {
                tempoSegemtedControl.selectedSegmentIndex = 0
            }
        }
    }
    var currentTempo = 120 {
        didSet {
            if isOn {
                tempoSegemtedControl.selectedSegmentIndex = tempoOptions.firstIndex(of: Int(currentTempo))! + 1
            }
        }
    }
    
    let tempoOptions = [60, 90, 120, 150]
    
    /// Segmented control for selecting speed
    lazy var tempoSegemtedControl: UISegmentedControl = {
        let items = ["Off", "60", "90", "120", "150"]
        let segemtedControl = UISegmentedControl(items: items)
        segemtedControl.selectedSegmentIndex = 0
        
        if #available(iOS 13, *) {
            segemtedControl.backgroundColor = .secondaryTint
        } else {
            segemtedControl.tintColor = .secondaryTint
        }
        
        segemtedControl.addTarget(self, action: #selector(tempoSegemtedControlSelected(_:)), for: .valueChanged)
        return segemtedControl
    }()
    
    @objc func tempoSegemtedControlSelected(_ sender: UISegmentedControl) {
        self.dismiss(animated: true, completion: nil)
        let currentSelectedSegmentIndex = sender.selectedSegmentIndex
        if currentSelectedSegmentIndex == 0 {
            NotificationCenter.default.post(name: .EMDemoPerformanceOff, object: nil, userInfo: nil)
            delegate?.offSelected()
        } else {
            NotificationCenter.default.post(name: .EMSelectDemoTempo, object: nil, userInfo: ["tempo": tempoOptions[currentSelectedSegmentIndex - 1]])
            delegate?.demoTempoSelected(to: Double(tempoOptions[currentSelectedSegmentIndex - 1]))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tempoSegemtedControl)
        tempoSegemtedControl.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
    }
}
