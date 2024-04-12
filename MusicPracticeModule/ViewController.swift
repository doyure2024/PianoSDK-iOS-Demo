//
//  ViewController.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 5/31/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import AVFoundation
import WebKit

class ViewController: UIViewController {
    
    let resourceManager = ResourceManager.shared
    let licenseManager = LicenseManager.shared
    var testInputMode = 0
    
    // Song list
    let items = ["Fur Elise", "Always With Me", "Summer", "Castle in the Sky"]
    let scoreUrls: [String: String] = [
        "Fur Elise": "https://small.kingcyk.com/Fur_Elise.xml",
        "Always With Me": "https://small.kingcyk.com/Always_With_Me.xml",
        "Summer": "https://small.kingcyk.com/Summer.xml",
        "Castle in the Sky": "https://small.kingcyk.com/天空之城简易版.xml"
    ]
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet private var textXml: UITextField?;
    @IBOutlet private var textStartBar: UITextField?;
    @IBOutlet private var textEndBar: UITextField?;
    @IBOutlet weak var textThreshold: UITextField!
    @IBOutlet weak var textCheckPercent: UITextField!
    @IBOutlet weak var scorePickerView: UIPickerView!
    
    @IBAction func didTapUserAgreement(_ sender: Any) {
        if let url = URL(string: "https://enjoymusic.ai/PianoRealTime/") {
            UIApplication.shared.open(url)
        }
    }

    @IBAction func didTapPrivacyPolicy(_ sender: Any) {
        if let url = URL(string: "https://enjoymusic.ai/PianoRealTime/") {
            UIApplication.shared.open(url)
        }
    }
    
    /// Test entrance
    @IBAction func didTapTest(_ sender: Any) {
        startTest()
    }
    
    @IBAction func didTapSettingsButton(_ sender: Any) {
        showSettingsPopup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
        scorePickerView.dataSource = self
        scorePickerView.delegate = self
        // Set the default text of textXml as the URL of the selected item in pickerView.
        let defaultItemSelected = items[scorePickerView.selectedRow(inComponent: 0)]
        textXml!.text = scoreUrls[defaultItemSelected]
        
        settingsButton.layer.cornerRadius = 20
        
        settingsButton.clipsToBounds = true
    }

    /// Start testing
    func startTest() {
        if !checkAudioAvailable() {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view.self, animated: true)
        hud.label.text = "Loading course list..."
        AF.request("https://small.kingcyk.com/demo.json").response { (response) in  // 192.168.50.161:5501/demo3.json
            if let data = response.data, let json = try? JSON(data: data) {
                self.resourceManager.loadResource(from: json)
                self.getLicense()
                self.setThresholds()
            }
        }
    }
    
    /// Get license
    func getLicense() {
        AF.request("https://license.enjoymusic.ai/vendor/hHw2GKaYZY1cJY3f").response { (response) in
            if let data = response.data, let license = String(data: data, encoding: .utf8) {
                self.licenseManager.setLicense(license)
                self.showPractice()
                self.setThresholds()
            }
        }
    }
    
    func showPractice() {
        SessionManager.shared.startAudioEngine()
        MBProgressHUD.hide(for: view.self, animated: true)
        performSegue(withIdentifier: "ShowPractice", sender: self)
    }
    
    func checkAudioAvailable() -> Bool {
        if AVAudioSession().isOtherAudioPlaying {
            let alert = UIAlertController(title: "Other applications are currently using the audio.", message: "Please close the relevant applications before starting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    @IBAction func didTapMode0(_ sender: UIButton) {
        testInputMode = 0
        startCustomizedTest()
    }
    
    @IBAction func didTapMode1(_ sender: UIButton) {
        testInputMode = 1
        startCustomizedTest()
    }
    
    @IBAction func didTapMode2(_ sender: UIButton) {
        testInputMode = 2
        startCustomizedTest()
    }
        
    func startCustomizedTest() {
        if !checkAudioAvailable() {
            return
        }
        let testInputUrl = textXml?.text ?? "";
        if (testInputUrl.count == 0) {
            let alert = UIAlertController(title: "Hint", message: "Please enter the configuration XML address.", preferredStyle: .alert);
            
            let okAction = UIAlertAction(
                    title: "Done",
                    style: .default,
                    handler: {
                    (action: UIAlertAction!) -> Void in
                      
                })
            alert.addAction(okAction)
            self.present(alert, animated: true) {
                
            }
            return;
        }
        
        var start = textStartBar?.text ?? "";
        start = start.count == 0 ? "1" : start;
        var end = textEndBar?.text ?? "";
        end = end.count == 0 ? "0" : end;
        
        let hud = MBProgressHUD.showAdded(to: view.self, animated: true)
        hud.label.text = "Loading course list..."
        
        let testString = """
        {
            "practiceList": [
                {
                    "type": "practice",
                    "sheetName": "测试曲谱",
                    "mode": \(testInputMode),
                    "sectionName": "A",
                    "startBar": \(start),
                    "endBar": \(end),
                    "hand": 0,
                    "practiceTime": 1,
                    "uuid": "7c9ffedc-c9ec-4a28-8145-0fe019ab6f4e",
                    "demoVideo": {
                        "url": "",
                        "uuid": "fbdc98ac-a5ad-4d78-96f4-f3c3654b78fa"
                    }
                }
            ],
            "sheetResource": [{
                    "sheetName": "测试曲谱",
                    "url": "\(testInputUrl)",
                    "uuid": "7c9ffedc-c9ec-4a28-8145-0fe019ab6f4e"
                }]
        }
        """
        let testJson = JSON.init(parseJSON: testString)
        self.resourceManager.loadResource(from: testJson)
        self.getLicense()
    }
    
    /// Set thresholds
    func setThresholds() {
        if let floatNumber = Float(textThreshold.text!) {
            modelThreshold = max(min(floatNumber, 1.0), 0.0)
        } else {
            modelThreshold = 0.45
        }
        if let floatNumber = Float(textCheckPercent.text!) {
            checkPercent = max(min(floatNumber, 1.0), 0.0)
        } else {
            checkPercent = 0.57
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func didTapRedirect(_ sender: UIButton) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("EnjoyMusic.log").path
        freopen(path, "w+", stdout)
    }
    
    @IBAction func didTapLog(_ sender: UIButton) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("EnjoyMusic.log")
        let objects = [url]
        let activityController = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender
        present(activityController, animated: true, completion: nil)
    }
    
    func showSettingsPopup() {
        let alert = UIAlertController(title: "Show More Options", message: "\n\n\n", preferredStyle: .alert) // Add new lines to increase alert height
        
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = UIColor.secondaryTint
        switchView.isOn = !textThreshold.isHidden
        switchView.addTarget(self, action: #selector(toggleDebugParameters(sender:)), for: .valueChanged)
        
        alert.view.addSubview(switchView)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            switchView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            switchView.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor, constant: -20) // Adjust this constant as needed
        ])
        
        let okAction = UIAlertAction(title: "Done", style: .default, handler: nil)
        alert.addAction(okAction)
        alert.view.tintColor = UIColor.themeTint
        
        self.present(alert, animated: true, completion: nil)
    }
    @objc func toggleDebugParameters(sender: UISwitch) {
        textThreshold.isHidden = !sender.isOn
        textCheckPercent.isHidden = !sender.isOn
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    // UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = items[row]
        
        // Set the URL of the selected song in the text field
        textXml!.text = scoreUrls[selectedItem]
        
        print("Selected Item: \(selectedItem)")
    }
}
