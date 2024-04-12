//
//  ReportViewController.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/21/21.
//

import UIKit
import WebKit
import SwiftyJSON

/// Report Page View Controller
class ReportViewController: UIViewController {
    
    var urlToLoad: String?
    var startBar: Int?
    var endBar: Int?
    var sheetName: String?
    var currentMode: Int?
    var hand: Int?
    var reportJSON: JSON!
    var noteCount = 0
    
    lazy var backgroudImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CommonBg")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "ThemeTint")
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.backgroundColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 18
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var loadingView: LoadingView = {
        let view = LoadingView()
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Back"), for: .normal)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next Score", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.layer.cornerRadius = 18
        button.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.5450980392, blue: 0.6980392157, alpha: 1)
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        return button
    }()
    
    lazy var infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "NoteInfo")
        return imageView
    }()
    
    lazy var tryAgainButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "TryAgain"), for: .normal)
        button.addTarget(self, action: #selector(didTapTryAgain), for: .touchUpInside)
        return button
    }()

    let messageName = "ScoreNative"
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(self, name: messageName)
        config.userContentController = controller
        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = self
        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBasicUI()

        // Do any additional setup after loading the view.
    }
    
    func setupBasicUI() {
        view.addSubview(backgroudImageView)
        backgroudImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(360)
            make.height.equalTo(120)
        }
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(36)
        }
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right).offset(12)
            make.height.equalTo(36)
            make.width.equalTo(36)
            make.centerY.equalTo(backButton)
        }
        view.addSubview(infoImageView)
        infoImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(backButton)
            make.right.equalToSuperview().offset(-40)
        }
        view.addSubview(webView)
        webView.isHidden = true
        webView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        webView.load(URLRequest(url: URL(string: "https://small.kingcyk.com/music_index_old.html")!))
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        view.addSubview(tryAgainButton)
        tryAgainButton.snp.makeConstraints { (make) in
            make.right.equalTo(nextButton.snp.left).offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadingView.setProgress(0.28)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadingView.setProgress(1.0)
        }
    }

    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapNext() {
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .EMBackFromReportAndGoNext, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: .EMBackFromReportAndTryAgain, object: nil, userInfo: nil)
    }
    
    @objc func didTapTryAgain() {
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .EMBackFromReportAndTryAgain, object: nil, userInfo: nil)
    }

    func updateUI() {
        if let url = urlToLoad, let start = startBar, let end = endBar {
            webView.evaluateJavaScript("loadUrl(\"\(url)\", \(start), \(end))") { (result, error) in
            }
        }
        if let text = sheetName {
            let nsText = text as NSString
            let size = nsText.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)])
            nameLabel.snp.updateConstraints { (make) in
                make.width.equalTo(size.width + 36)
            }
            nameLabel.text = sheetName
//            view.layoutIfNeeded()
        }
    }
    
    func parseResource() {
        print("[INFO]", sheetName, currentMode, urlToLoad, startBar, endBar)
        updateUI()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ReportViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        parseResource()
    }
}

extension ReportViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == messageName {
            print("WebKit message")
            DispatchQueue.main.async {
                self.webView.isHidden = false
            }
            if let json = self.reportJSON {
                self.webView.evaluateJavaScript("drawReportInfo(\(json.rawString([.castNilToNSNull: true])!), \(self.noteCount), \(self.hand!))") { (result, error) in
                }
            }
//            self.webView.evaluateJavaScript("getLeftRightHandNoteList(\(hand ?? 0))") { (result, error) in
//                self.webView.evaluateJavaScript("drawLeftRightHandMusicScore(\(self.hand ?? 0))")
//                if let json = try? JSON(result) {
//                    self.scoreManager.loadScore(from: json, bpm: self.bpm)
//                    if let score = self.scoreManager.getHandScore(hand: self.hand ?? 0) {
//                        DispatchQueue.main.async {
//                            self.webView.isHidden = false
//                        }
//                        self.noteCount = self.scoreManager.score!.notes.count
//                        self.currentCount = 0
//                        self.currentWrongCount = 0
//                        let sdkMode = (self.currentMode ?? 0) > 0 ? 1 : 0
//                        self.sdkManager.setMode(mode: sdkMode)
//                        self.sdkManager.loadScore(document: self.scoreManager.getSdkScore(hand: self.hand ?? 0)!)
//                        self.sdkManager.prepare()
//                        self.sdkManager.start()
//                        if sdkMode == 1 {
//                            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
//                        }
//                        self.sdkManager.updateSequence(from: score)
//                    }
//                }
//            }
        }
    }
}
