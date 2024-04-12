//
//  ShifanShezhiViewController.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/24/21.
//

import UIKit

/// Demo popover view controller
class DemonstrationPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var demonstrationTempoSelectionViewController = DemonstrationTempoSelectionViewController()
    
    lazy var tableView: UITableView = {
        let tbView = UITableView()
        tbView.dataSource = self
        tbView.delegate = self
        tbView.isScrollEnabled = false
        tbView.separatorStyle = .none
        return tbView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(72)
        }
    }
}

/// Implementation of delegate methods for list view in demo popover view
extension DemonstrationPopoverViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let resource = ResourceManager.shared.resource {
            let practice =  resource.practiceList[ResourceManager.shared.currentPracticeListIndex]
            if practice.type == "practice" {
                if practice.demoVideo != nil {
                    return 2
                }
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.tintColor = .themeTint
        cell.textLabel?.textColor = .themeTint
        cell.textLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Score Playing"
        } else {
            cell.textLabel?.text = "Demo Video"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            // Show detail setting
            self.navigationController?.preferredContentSize = CGSize(width: 240, height: 31)
            self.navigationController?.pushViewController(demonstrationTempoSelectionViewController, animated: true)
            }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
}
