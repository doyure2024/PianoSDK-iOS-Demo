//
//  PracticeViewController.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 5/31/21.
//

import UIKit
import SnapKit
import WebKit
import Pitchy
import SwiftyJSON
import MBProgressHUD

class PracticeViewController: UIViewController {
    
    /// Instance encapsulating core SDK functionalities.
    let sdkManager = SdkManager.shared
    
    /// Resource Manager.
    let resourceManager = ResourceManager.shared
    
    /// Score Manager.
    let scoreManager = ScoreManager.shared
    
    /// Process Manager.
    let sessionManager = SessionManager.shared
    
    /// Timeline-related.
    var startDate = Date()
    var accumulatedTime = 0
    var accumulatedKeys = [Int]()
    var calledTimes = 0
    var applicationActiveDate = Date() {
        didSet {
            if isStarted {
                applicationInactiveInterval += applicationActiveDate.timeIntervalSince(applicationInactiveDate)
            } else {
                applicationInactiveInterval = 0
            }
        }
    }
    var applicationInactiveDate = Date()
    var applicationInactiveInterval: TimeInterval = 0
    
    /// Practice Records.
    var practiceRecord = PracticeRecord()
    
    /// UI Interface Elements.
    lazy var backgroudImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Mode\(currentMode ?? 0)Bg")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
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
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Close"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Back"), for: .normal)
        return button
    }()
    
    lazy var leftHandButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "LeftHand"), for: .normal)
        return button
    }()
    
    lazy var rightHandButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "RightHand"), for: .normal)
        return button
    }()
    
    lazy var keyboardView: KeyboardView = {
        let view = KeyboardView(frame: .zero)
        view.firstOctave = 0
        view.octaveCount = 7
        view.isUserInteractionEnabled = false
        if !showInstrumentPanel {
            view.isHidden = true
        }
        return view
    }()
    
    lazy var rightStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 24
        return stack
    }()
    
    lazy var leftStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 24
        stack.isHidden = true
        return stack
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondaryTint
        button.setTitle("Start", for: .normal)
        button.layer.cornerRadius = 24
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    lazy var skipNoteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondaryTint
        button.setTitle("Skip", for: .normal)
        button.layer.cornerRadius = 24
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.isHidden = true
        return button
    }()

    
    let messageName = "ScoreNative"
    var controller = WKUserContentController()
    lazy var webView: FullScreenWKWebView = {
        let config = WKWebViewConfiguration()
        controller.add(self, name: messageName)
        config.userContentController = controller
        /// Automatically scales according to the screen size of the device model.
        var pageZoomScale = 1.0
        if self.view.frame.width <= 926 { // iPhone 12 Pro Max screen width in dot.
            pageZoomScale = 0.75
        } else {
            pageZoomScale = 1.0
        }
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=\(pageZoomScale), maximum-scale=\(pageZoomScale), user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(script)
        let view = FullScreenWKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = self
        return view
    }()
    
    lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.alpha = 0.5
        return view
    }()
    
    var countdownView: CountdownView!

    
    /// Score-related.
    var urlToLoad: String?
    var startBar: Int?
    var endBar: Int?
    var sheetName: String?
    var currentMode: Int? {
        didSet {
            backgroudImageView.image = UIImage(named: "Mode\(currentMode ?? 0)Bg")
        }
    }
    var hand: Int?
    var noteCount = 0
    var tempCount = 0
    var currentCount = 0 {
        didSet {
            print("currentCount:", currentCount)
            if scoreManager.score == nil { return }
            if currentMode != 0 && currentCount >= 0 && currentCount < scoreManager.score!.notes.count - 1 && sessionManager.isMetronomeOn && !numeratorList.isEmpty {
                let min = scoreManager.score!.notes[currentCount + 1].map { $0.currentTimeStamp }.min()! - scoreManager.score!.notes[currentCount].map { $0.currentTimeStamp }.min()!
                Timer.scheduledTimer(withTimeInterval: Double(min) / 2 / 1000, repeats: false) { _ in
                    if self.numeratorList.isEmpty { return }
                    if self.numeratorList[self.currentCount] != self.numeratorList[self.currentCount + 1] {
                        self.tempCount = self.currentCount
                        Timer.scheduledTimer(withTimeInterval: Double(min) / 2 / 1000, repeats: false) { _ in
                            self.sessionManager.audioManager.metronome.stop()
                            self.sessionManager.audioManager.metronome.tempo =
                                Double(metronomeSpeed) * Double(self.numeratorList[self.tempCount + 1].1) / 4
                            self.sessionManager.audioManager.metronome.subdivision = self.numeratorList[self.tempCount + 1].0
                            self.sessionManager.audioManager.metronome.start()
                        }
                    }
                }
            }
            DispatchQueue.main.async { [self] in
                for note in 24..<112 {
                    self.keyboardView.programmaticNoteOff(note)
                    self.keyboardView.programmaticOnHands.removeAll()
                }
                if self.scoreManager != nil {
                    if currentCount < self.scoreManager.score!.notes.count &&
                        isStarted &&
                        currentCount >= 0
                        && currentMode != 0 {
                        for note in self.scoreManager.score!.notes[self.currentCount] {
                            self.keyboardView.programmaticOnHands.append(note.hand)
                            self.keyboardView.programmaticNoteOn(note.key + 21)
                            if currentMode != 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(note.duration) / 1000.0 * 0.75) {
                                    self.keyboardView.programmaticNoteOff(note.key + 21)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    var currentWrongCount = 0 {
        didSet {
            if currentWrongCount >= 5 && currentMode != 2 {
                self.sessionManager.stop()
                self.sessionManager.stopTimer()
                DispatchQueue.main.async {
                    self.view.bringSubviewToFront(self.blackView)
                    self.blackView.isHidden = false
                    let failView = FailView(frame: .zero)
                    failView.delegate = self
                    self.view.addSubview(failView)
                    failView.snp.makeConstraints { (make) in
                        make.center.equalToSuperview()
                        make.width.equalTo(248)
                        make.height.equalTo(254)
                    }
                    self.sessionManager.stopMetronome()
                }
            }
        }
    }
    var bpm = 90
    var numeratorList = [(Int, Int)]()
    
    /// Recognition-related in Note Practicing Mode.
    var alreadyMetTarget = false
    var isResultCorrect = false
    var noteCorrectWrongList: [Bool?]? = []
    
    /// Recognition-related in Tempo Following Mode.
    var previouResults = Set<Int>()
    var needToColorPreviousNote = false

    /// Keyboard blinking effect.
    var flickKeyboardTimer = Timer()
    
    /// Practice process control-related.
    var isTryAgain = false
    var isStarted = false
    var isCountingDown = false
    var isCheckingTimeInterval = false
    var shouldResponceToTap = true
    var resultView: ResultView?
    
    /// Called after the current view controller has finished loading.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(backFromReportAndGoNext), name: .EMBackFromReportAndGoNext, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(backFromReportAndTryAgain), name: .EMBackFromReportAndTryAgain, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateApplicationActiveDate), name: .EMApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(backFromReportAndGoNext), name: .EMApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(countDownFinished), name: .EMCountDownFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTimeInterval), name: .EMCheckTimeInterval, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollHorizontallySwitchChange), name: .EMScrollHorizontallySwitchChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(metronomePopoverViewDidDisappear), name: .EMMetronomePopoverViewDidDisappear, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .EMBackFromReportAndGoNext, object: nil)
        NotificationCenter.default.removeObserver(self, name: .EMBackFromReportAndTryAgain, object: nil)
        NotificationCenter.default.removeObserver(self, name: .EMApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .EMApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .EMCountDownFinished, object: nil)
        NotificationCenter.default.removeObserver(self, name: .EMCheckTimeInterval, object: nil)
        NotificationCenter.default.removeObserver(self, name: .EMScrollHorizontallySwitchChange, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()
        sdkManager.delegate = self
        sessionManager.isFirstStart = true
        resourceManager.currentPracticeTime = 0
        resourceManager.currentPracticeListIndex = 0
    }
    
    /// Drawing basic interface components and constraints.
    func setupBasicUI() {
        view.addSubview(blackView)
        blackView.isHidden = true
        blackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        view.addSubview(backgroudImageView)
        backgroudImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(77)
        }
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(360)
            make.height.equalTo(120)
        }
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(24)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(36)
        }
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(24)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(36)
        }
        view.addSubview(leftHandButton)
        view.addSubview(rightHandButton)
        
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right).offset(12)
            make.height.equalTo(36)
            make.width.equalTo(36)
            make.centerY.equalTo(backButton)
        }
        view.addSubview(rightStackView)
        rightStackView.snp.makeConstraints { (make) in
            make.right.equalTo(view).offset(-32)
            make.top.equalTo(backButton)
        }
        view.addSubview(leftStackView)
        leftStackView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(84)
            make.top.equalTo(backButton)
        }
        view.addSubview(webView)
        webView.isHidden = true
        webView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.left.right.equalTo(view)
            make.bottom.equalToSuperview().offset(0)
        }
        view.addSubview(keyboardView)
        keyboardView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        webView.load(URLRequest(url: URL(string: "https://small.kingcyk.com/music_index.html")!))
        view.addSubview(startButton)
        startButton.isEnabled = false
        startButton.snp.makeConstraints { (make) in
            make.width.equalTo(96)
            make.height.equalTo(48)
            make.right.equalTo(view).offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        view.addSubview(skipNoteButton)
        skipNoteButton.snp.makeConstraints { (make) in
            make.width.equalTo(96)
            make.height.equalTo(48)
            make.right.equalTo(view).offset(-144)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        skipNoteButton.addTarget(self, action: #selector(didTapSkipNote), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(readyToStart), name: .EMReadyToStart, object: nil)
    }
    
    /// Called after the current view controller is displayed.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadingView.setProgress(0.28)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadingView.setProgress(1.0)
        }
    }
    
    /// Click on the top left [Back] button.
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.navigationController == nil {
            isStarted = false
            sessionManager.stopMetronome()
            sessionManager.stopTimer()
            sessionManager.stop()
            resourceManager.currentPracticeListIndex = 0
            resourceManager.currentPracticeTime = 0
            noteCorrectWrongList = nil
            numeratorList.removeAll()
            if isCountingDown {
                self.isCountingDown = false
                self.view.sendSubviewToBack(countdownView)
                countdownView.timer.invalidate()
            }
            startButton.setTitle("Start", for: .normal)
            isStarted = false
            currentCount = 0
            accumulatedTime = 0
            startButton.alpha = 0.5
            startButton.isEnabled = false
            sdkManager.delegate = nil
            controller.removeScriptMessageHandler(forName: messageName)
            webView.removeFromSuperview()
        }
    }
    
    /// Click on the bottom right [Start] button.
    @objc func didTapStartButton() {
        if numeratorList.isEmpty {
            print("Numerator empty!")
            return
        }
        skipNoteButton.isHidden = true
        accumulatedTime = 0
        if !isStarted && !isCountingDown {
            /// Determine whether it is the first time to start the whole process.
            if sessionManager.isFirstStart {
                sessionManager.isFirstStart = false
            }
            startDate = Date()
            sdkManager.lastMetDate = startDate
                        
            /// Adjustment of keyboard display.
            DispatchQueue.main.async { [self] in
                for note in 24..<112 {
                    self.keyboardView.programmaticNoteOff(note)
                    self.keyboardView.programmaticOnHands.removeAll()
                }
            }
            
            startButton.setTitle("Stop", for: .normal)
//            sdkManager.setMode(mode: (currentMode == 1 ? 1 : 0))
            /// Judging the current mode.
            if currentMode != 0 {
                /// Full song or evaluation scoring mode.
                /// Countdown function of walking the spectrum at a fixed speed.
                countdownView = CountdownView {
                    if self.isCountingDown {
                        self.noteCorrectWrongList?.removeAll()
                        self.currentCount = 0
                        self.isStarted = true
                        self.isCountingDown = false
                        self.sessionManager.start()
                        if !self.sessionManager.isMetronomeOn {
                            self.sessionManager.stopMetronome()
                        }
                    }
                }
                countdownView.timerSecond = numeratorList[0].0 > 2 ? numeratorList[0].0 : numeratorList[0].0 * 2
                sessionManager.audioManager.metronome.subdivision = numeratorList[0].0
                webView.isUserInteractionEnabled = false
                self.view.addSubview(countdownView)
                countdownView.snp.makeConstraints { (make) in
                    make.size.equalTo(150)
                    make.center.equalToSuperview()
                }
                self.view.bringSubviewToFront(countdownView)
                countdownView.countdown(in: Double(metronomeSpeed) * Double(numeratorList[0].1) / 4)
                isCountingDown = true
                sessionManager.restartMetronome(bpm: Double(metronomeSpeed) * Double(numeratorList[0].1) / 4)
                
                if sessionManager.isAccompanimentOn {
                    sessionManager.startAccompaniment(from: 9.0 - Double(countdownView.timerSecond))
                }
                
                /// Create a new practice record.
                createNewPracticeRecord()
            } else {
                /// Start recognizing in sentence recognition mode.
                self.isStarted = true
                self.sessionManager.start()
                
                /// Create a new practice record.
                createNewPracticeRecord()
            }
        } else if isCountingDown {
            self.isCountingDown = false
            sessionManager.stopTimer()
            self.view.sendSubviewToBack(countdownView)
            countdownView.timer.invalidate()
            currentCount = 0
            noteCorrectWrongList?.removeAll()
            accumulatedTime = 0
            startButton.setTitle("Start", for: .normal)
            isStarted = false
            startButton.alpha = 0.5
            startButton.isEnabled = false
            tryAgain()
        } else {
            if !showInstrumentPanel {
                keyboardView.isHidden = true
            }
            sessionManager.stopTimer()
            flickKeyboardTimer.invalidate()
            currentCount = 0
            noteCorrectWrongList?.removeAll()
            accumulatedTime = 0
            startButton.setTitle("Start", for: .normal)
            isStarted = false
            startButton.alpha = 0.5
            startButton.isEnabled = false
            tryAgain()
        }
    }
    
    @objc func countDownFinished() {
        print("countDownFinished")
        startDate = Date()
        webView.isUserInteractionEnabled = true
        sessionManager.startTimer()
    }
    
    @objc func checkTimeInterval() {
        if scoreManager.score!.notes.count == currentCount || noteCorrectWrongList == nil || isCheckingTimeInterval {
            return
        }
        isCheckingTimeInterval = true
        var min = 1000
        if currentCount < scoreManager.score!.notes.count - 1 {
            min = scoreManager.score!.notes[currentCount + 1].map { $0.currentTimeStamp }.min()! - scoreManager.score!.notes[currentCount].map { $0.currentTimeStamp }.min()!
        }
        let currentDate = Date()
        if Int(currentDate.timeIntervalSince(startDate) * 1000.0) - accumulatedTime >= min {
            noteCorrectWrongList?.append(false)
            
            if (noteCorrectWrongList?.filter({ $0 == true }).count)! * 2 > noteCorrectWrongList!.count && min < 128 {
                isResultCorrect = true
            }
            
            /// Move cursor.
            if isResultCorrect {
                isResultCorrect = false
                previouResults = Set<Int>()
                // currentWrongCount = 0
                self.moveToNext(1)
            } else {
                // Only works for Tempo Following Mode.
                if currentMode == 1 {
                    currentWrongCount += 1
                }
                self.moveToNext(0)
            }
                        
            /// Control the accumulated time to maintain the synchronization of the recognition timeline.
            accumulatedTime += min
        }
        isCheckingTimeInterval = false
    }
    
    /// Prepare before starting when in practice mode.
    @objc func readyToStart() {
        startButton.alpha = 1
        startButton.isEnabled = true
        if !sessionManager.isFirstStart && !isTryAgain {
            didTapStartButton()
        }
    }
    
    /// When in demonstration mode, click the [Close] button in the upper left corner.
    @objc func closeButtonTapped() {
        self.webView.evaluateJavaScript("stopPlay()") { [weak self] (result, error) in
            if let strongSelft = self {
                strongSelft.sessionManager.isInDemonstrationMode = false
                strongSelft.sessionManager.stopDemonstration()
                let hud = MBProgressHUD.showAdded(to: strongSelft.view, animated: true)
                hud.label.text = "Demo Ended"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    hud.hide(animated: true)
                }
                strongSelft.tryAgain()
            }
        }
    }
    
    /// Update UI. 修改ui
    func updateUI(withUIUpdated needUIUpdation: Bool = true) {
        if let url = urlToLoad, let start = startBar, let end = endBar {
            /// Load sheet.
            webView.evaluateJavaScript("loadUrl(\"\(url)\", \(start), \(end), \(scrollHorizontally))") { (result, error) in
            }
        }
        if !needUIUpdation {
            return
        }
        startButton.setTitle("Start", for: .normal)
        isStarted = false
        startButton.alpha = 0.5
        startButton.isEnabled = false
        if let text = sheetName {
            let nsText = text as NSString
            let size = nsText.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)])
            nameLabel.snp.updateConstraints { (make) in
                make.width.equalTo(size.width + 36)
            }
            nameLabel.text = sheetName
        }
        
        /// Update right stack view UI
        for view in rightStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        var rightNavBarOptions: [NavBarOptionView.OptionType] = []
        if currentMode != 0 && !sessionManager.isInDemonstrationMode {
            rightNavBarOptions += [.metronome, .accompaniment]
        }
        rightNavBarOptions += [.restartPracticeOrDemonstration, .demonstration, .settings]
        let rightNavBarOptionViews: [UIView] = rightNavBarOptions.map { (type) -> UIView in
            let optionView = NavBarOptionView(type: type)
            optionView.delegate = self
            if type == .metronome {
                NotificationCenter.default.addObserver(optionView, selector: #selector(NavBarOptionView.turnMetronomeOn), name: .EMTurnMetronomeOn, object: nil)
                NotificationCenter.default.addObserver(optionView, selector: #selector(NavBarOptionView.turnMetronomeOff), name: .EMTurnMetronomeOff, object: nil)
                NotificationCenter.default.addObserver(optionView, selector: #selector(NavBarOptionView.updateSpeed(_:)), name: .EMUpdateSpeed, object: nil)
            }
            
            if type == .accompaniment {
                NotificationCenter.default.addObserver(optionView, selector: #selector(NavBarOptionView.turnAccompanimentOn), name: .EMTurnAccompanimentOn, object: nil)
                NotificationCenter.default.addObserver(optionView, selector: #selector(NavBarOptionView.turnAccompanimentOff), name: .EMTurnAccompanimentOff, object: nil)
            }
            
            if type == .demonstration {
                NotificationCenter.default.addObserver(optionView, selector: #selector(NavBarOptionView.selectDemoTempo(_:)), name: .EMSelectDemoTempo, object: nil)
                NotificationCenter.default.addObserver(optionView, selector: #selector(NavBarOptionView.demoPerformanceOff), name: .EMDemoPerformanceOff, object: nil)
            }
            
            if type == .metronome {
                optionView.expanded = true
                optionView.snp.makeConstraints { (make) in
                    make.width.equalTo(64)
                    make.height.equalTo(50)
                }
                if sessionManager.isMetronomeOn {
                    optionView.isMetronomeOn = true
                } else {
                    optionView.isMetronomeOn = false
                }
            } else if type == .accompaniment {
                optionView.expanded = true
                optionView.snp.makeConstraints { (make) in
                    make.width.equalTo(64)
                    make.height.equalTo(50)
                }
                if sessionManager.isAccompanimentOn {
                    optionView.isAccompanimentOn = true
                } else {
                    optionView.isAccompanimentOn = false
                }
            } else if type == .demonstration && sessionManager.isInDemonstrationMode {
                optionView.expanded = true
                optionView.snp.makeConstraints { (make) in
                    make.width.equalTo(64)
                    make.height.equalTo(50)
                }
            } else {
                optionView.snp.makeConstraints { (make) in
                    make.width.equalTo(32)
                    make.height.equalTo(50)
                }
            }
            return optionView
        }
        for view in rightNavBarOptionViews {
            rightStackView.addArrangedSubview(view)
        }
        
        /// Update left stack view UI
        for view in leftStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        let leftNavBarOptions: [NavBarOptionView.OptionType] = [.leftHand, .rightHand]
        let leftNavBarOptionViews: [UIView] = leftNavBarOptions.map { (type) -> UIView in
            let optionView = NavBarOptionView(type: type)
            optionView.delegate = self
            optionView.snp.makeConstraints { (make) in
                make.width.equalTo(32)
                make.height.equalTo(50)
            }
            if sessionManager.handsForDemoPerformance == .right {
                switch optionView.type {
                case .leftHand:
                    optionView.defaultBackgroundView.backgroundColor = .themeTint
                case .rightHand:
                    optionView.defaultBackgroundView.backgroundColor = .secondaryTint
                default:
                    break
                }
            } else if sessionManager.handsForDemoPerformance == .left {
                switch optionView.type {
                case .leftHand:
                    optionView.defaultBackgroundView.backgroundColor = .secondaryTint
                case .rightHand:
                    optionView.defaultBackgroundView.backgroundColor = .themeTint
                default:
                    break
                }
            } else if sessionManager.handsForDemoPerformance == .full {
                switch optionView.type {
                case .leftHand:
                    optionView.defaultBackgroundView.backgroundColor = .themeTint
                case .rightHand:
                    optionView.defaultBackgroundView.backgroundColor = .themeTint
                default:
                    break
                }
            }
            return optionView
        }
        for view in leftNavBarOptionViews {
            leftStackView.addArrangedSubview(view)
        }
        
        /// Control the display and hiding of the top widgets according to the current state.
        if sessionManager.isInDemonstrationMode == true {
            closeButton.isHidden = false
            leftStackView.isHidden = false
            backButton.isHidden = true
            nameLabel.isHidden = true
        } else {
            closeButton.isHidden = true
            leftStackView.isHidden = true
            backButton.isHidden = false
            nameLabel.isHidden = false
        }
    }
    
    /// Parse resources.分析资源
    func parseResource(withUIUpdated needUIUpdation: Bool = true) {
        if sessionManager.defaultMetronomeOn {
            sessionManager.isMetronomeOn = true
        }
        let currentIndex = resourceManager.currentPracticeListIndex
        if let resource = resourceManager.resource {
            let currentPracticeList = resource.practiceList[currentIndex]
            if currentPracticeList.type == "practice" {
                let uuid = currentPracticeList.uuid
                if let sheet = resource.sheetResource.filter({ $0.uuid == uuid }).first {
                    urlToLoad = sheet.url
                    startBar = currentPracticeList.startBar
                    endBar = currentPracticeList.endBar
                    hand = currentPracticeList.hand
                    let handString = hand == 0 ? "双手" : (hand == 1 ? "Right Hand" : "Left Hand")
                    let mode = currentPracticeList.mode
                    currentMode = mode
                    let modeString = mode == 0 ? "曲谱练习" : (mode == 1 ? "挑战" : "测评")
                    sheetName = currentPracticeList.sheetName + currentPracticeList.sectionName + "（" + handString + modeString + "）No. \(resourceManager.currentPracticeTime + 1)"
                    print("[INFO]", sheetName, currentMode, urlToLoad, startBar, endBar)
                    if needUIUpdation {
                        sessionManager.createSdk()
                    }
                    noteCorrectWrongList?.removeAll()
                    updateUI(withUIUpdated: needUIUpdation)
                } else {
                    print("[ERROR]", "failed to get musicxml")
                }
            } else {
                // MARK: ## Video Logic
                // TODO: Video practiceList
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.goNext()
                }
            }
        }
    }
    
    /// Enter the next practice.
    func goNext() {
        resourceManager.goNext()
        parseResource()
    }
    
    /// After clicking [Next Practice] on the test report page, return to the current page for execution.
    @objc func backFromReportAndGoNext() {
        if self.resourceManager.currentPracticeTime >= self.resourceManager.resource!.practiceList[self.resourceManager.currentPracticeListIndex].practiceTime - 1 &&
            self.resourceManager.currentPracticeListIndex >= self.resourceManager.resource!.practiceList.count - 1 {
            DispatchQueue.main.async { [self] in
                self.view.bringSubviewToFront(self.blackView)
                self.blackView.isHidden = false
                let successView = SuccessView(frame: .zero)
                successView.delegate = self
                self.view.addSubview(successView)
                successView.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.width.equalTo(248)
                    make.height.equalTo(285)
                }
                successView.tryAgainButton.setImage(UIImage(named: "TryAgain-Wide"), for: .normal)
                successView.tryAgainButton.snp.removeConstraints()
                successView.nextButton.isHidden = true
                successView.tryAgainButton.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
                    make.bottom.equalToSuperview().offset(-16)
                    make.height.equalTo(36)
                }
            }
        } else {
            goNext()
        }
    }
    
    @objc func updateApplicationActiveDate() {
        applicationActiveDate = Date()
    }
    
    @objc func updateApplicationInactiveDate() {
        applicationInactiveDate = Date()
    }
    
    /// Remove the result pop-up window.
    @objc func backFromReportAndTryAgain() {
        didTapCancel()
        resultView?.removeFromSuperview()
        self.sessionManager.stopDemonstration()
        self.tryAgain()
    }
    
    /// Operations at the resource level to restart.
    func tryAgain(withUIUpdated needUIUpdation: Bool = true) {
        if sessionManager.isInDemonstrationMode {
            sessionManager.stopDemonstration()
            parseResource(withUIUpdated: needUIUpdation)
        } else {
            isTryAgain = true
            noteCorrectWrongList?.removeAll()
            sessionManager.stop()
            sessionManager.stopMetronome()
            sessionManager.stopTimer()
            parseResource(withUIUpdated: needUIUpdation)
        }
        /// Update the timestamp.
        sdkManager.lastMetDate = Date()
    }
    
    /// Click the [Skip this sound] button.
    @objc func didTapSkipNote() {
        if !isStarted {
            let hud = MBProgressHUD.showAdded(to: view.self, animated: true)
            hud.label.text = "请先按开始"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                hud.hide(animated: true)
            }
            return
        }
        self.sdkManager.skipNext()
        targetMet()
    }
    
    /// Click the [Restart] button.
    func didTapRestart() {
        /// Determine whether it is in practice or demonstration mode.
        if !sessionManager.isInDemonstrationMode {
            /// If in practice mode, then a pop-up will prompt whether a restart is needed.
            let alert = UIAlertController(title: "你现在正在练习", message: "是否要重新启动?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Restart", style: UIAlertAction.Style.default, handler: {_ in
                self.sessionManager.stopTimer()
                self.webView.evaluateJavaScript("stopPlay()") { (result, error) in
                }
                self.sessionManager.isInDemonstrationMode = false
                self.sessionManager.stopDemonstration()
                self.tryAgain()
                
                // TODO: Return practice record
                /// Complete the practice record and return.
                self.endPracticeRecord(withStatus: false)
                self.postPracticeRecordToServer()

            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            /// If in demonstration mode, then restart the demonstration.
            self.webView.evaluateJavaScript("stopPlay()") { [weak self] (result, error) in
                if let strongSelf = self {
                    strongSelf.sessionManager.stopDemonstration()
                    strongSelf.sessionManager.startDemonstration(bpm: strongSelf.sessionManager.demonstrationSpeed)
                    strongSelf.tryAgain()
                    strongSelf.sessionManager.demonstrationCount = -2
                }
            }
        }
    }
    
    /// Click the [Demonstration] button.
    func didTapDemonstration(sender: NavBarOptionView) {
        if !sessionManager.isInDemonstrationMode {
            self.tryAgain(withUIUpdated: false)
        }
        let vc = DemonstrationPopoverViewController()
        vc.demonstrationTempoSelectionViewController.delegate = self
        vc.demonstrationTempoSelectionViewController.isOn = sessionManager.isInDemonstrationMode
        vc.demonstrationTempoSelectionViewController.currentTempo = Int(sessionManager.demonstrationSpeed)
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden = true
        navigationController.preferredContentSize = CGSize(width: 176, height: 70)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController!.delegate = self
        navigationController.popoverPresentationController!.sourceView = sender
        self.present(navigationController, animated: true, completion: nil)
    }
    
    /// Click the [Metronome] button.
    func didTapMetronome(sender: NavBarOptionView) {
        let vc = MetronomePopoverViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden = true
        navigationController.preferredContentSize = CGSize(width: 176, height: 70)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController!.delegate = self
        navigationController.popoverPresentationController!.sourceView = sender
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func didTapAccompaniment(sender: NavBarOptionView) {
        let vc = AccompanimentPopoverViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden = true
        navigationController.preferredContentSize = CGSize(width: 176, height: 40)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController!.delegate = self
        navigationController.popoverPresentationController!.sourceView = sender
        self.present(navigationController, animated: true, completion: nil)
    }
    
    /// Click the [Settings] button.
    func didTapSettings(sender: NavBarOptionView) {
        let vc = SettingsPopoverViewController()
        vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden = true
        navigationController.preferredContentSize = CGSize(width: 176, height: 168)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController!.delegate = self
        navigationController.popoverPresentationController!.sourceView = sender
        self.present(navigationController, animated: true, completion: nil)
    }
    
    /// Click the [Left Hand] button.
    func didTapLeftHand() {
        if sessionManager.isInDemonstration {
            if sessionManager.handsForDemoPerformance != .left {
                sessionManager.handsForDemoPerformance = .left
            } else {
                sessionManager.handsForDemoPerformance = .full
            }
            self.sessionManager.stopDemonstration()
            self.webView.evaluateJavaScript("stopPlay()") { [weak self] (result, error) in
                if let strongSelf = self {
                    strongSelf.sessionManager.isInDemonstrationMode = true
                    strongSelf.tryAgain()
                    strongSelf.sessionManager.demonstrationCount = -2
                    strongSelf.sessionManager.isInDemonstration = true
                }
            }
        }
    }
    
    /// Click the [Right Hand] button.
    func didTapRightHand() {
        if sessionManager.isInDemonstration {
            if sessionManager.handsForDemoPerformance != .right {
                sessionManager.handsForDemoPerformance = .right
            } else {
                sessionManager.handsForDemoPerformance = .full
            }
            self.sessionManager.stopDemonstration()
            self.webView.evaluateJavaScript("stopPlay()") { [weak self] (result, error) in
                if let strongSelf = self {
                    strongSelf.sessionManager.isInDemonstrationMode = true
                    strongSelf.tryAgain()
                    strongSelf.sessionManager.demonstrationCount = -2
                    strongSelf.sessionManager.isInDemonstration = true
                }
            }
        }
    }
    
    /// Load sheet.
    func loadScore() {
        self.webView.evaluateJavaScript("getLeftRightHandNoteList(\(hand ?? 0))") { [weak self] (result, error) in
            if let strongSelf = self {
                strongSelf.webView.evaluateJavaScript("drawLeftRightHandMusicScore(\(strongSelf.hand ?? 0))")
                if let json = try? JSON(result) {
                    strongSelf.scoreManager.loadScore(from: json, bpm: metronomeSpeed)
                    if let score = strongSelf.scoreManager.getHandScore(hand: strongSelf.hand ?? 0) {
                        strongSelf.noteCount = strongSelf.scoreManager.score!.notes.count
                        
                        /// 检查是否曲谱为空
                        if strongSelf.hand != 0 {
                            var isEmpty = true
                            for i in 0..<strongSelf.scoreManager.score!.notes.count {
                                if strongSelf.scoreManager.score!.notes[i].map({ $0.hand }).contains(strongSelf.hand ?? 0) {
                                    isEmpty = false
                                }
                            }
                            if isEmpty {
                                let hud = MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
                                hud.label.text = "乐谱格式不正确，请选择其他乐谱。"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    hud.hide(animated: true)
                                    strongSelf.navigationController?.popViewController(animated: true)
                                }
                                return
                            }
                        }
                        
                        strongSelf.currentCount = 0
                        strongSelf.currentWrongCount = 0
                        let sdkMode = (strongSelf.currentMode ?? 0) > 0 ? 1 : 0
                        print("sdkMode:", sdkMode)
                        strongSelf.sdkManager.setMode(mode: sdkMode)
                        strongSelf.sdkManager.setLowThreshold(threshold: modelThreshold)
                        strongSelf.sdkManager.setCheckPercent(percent: checkPercent)
                        print("modelThreshold:", modelThreshold, "checkPercent:", checkPercent)
                        strongSelf.sdkManager.loadScore(document: strongSelf.scoreManager.getSdkScore(hand: strongSelf.hand ?? 0)!)
                        if let score = strongSelf.scoreManager.getHandScore(hand: strongSelf.hand ?? 0) {
                            strongSelf.sessionManager.updateSequence(from: score)
                        }
                        strongSelf.webView.evaluateJavaScript("resetCursor()") { (result, error) in
                            strongSelf.webView.evaluateJavaScript("getScoreRhythms()") { (result, error) in
                                if let json = try? JSON(result) {
                                    let allNumeratorAndDenominators = json["scoreRhythms"].arrayValue
                                    for numeratorAndDenominator in allNumeratorAndDenominators {
                                        let numerator =  numeratorAndDenominator["numerator"].intValue
                                        let denominator =  numeratorAndDenominator["denominator"].intValue

                                        strongSelf.numeratorList.append((numerator, denominator))
                                    }
                                    if strongSelf.hand != 0 && strongSelf.currentMode == 0 {
                                        var finished = true
                                        var endloop = false
                                        while !endloop {
                                            if finished {
                                                if !strongSelf.scoreManager.score!.notes[strongSelf.currentCount].map { $0.hand }.contains(strongSelf.hand) {
                                                    finished = false
                                                    strongSelf.webView.evaluateJavaScript("moveCursorToNext(-1, false)") { result, error in
                                                        strongSelf.currentCount += 1
                                                        finished = true
                                                    }
                                                } else {
                                                    endloop = true
                                                }
                                            }
                                        }
                                        DispatchQueue.main.async {
                                            if strongSelf.numeratorList.isNotEmpty {
                                                NotificationCenter.default.post(name: .EMReadyToStart, object: nil)
                                                strongSelf.webView.isHidden = false
                                            } else {
                                                print("Numerator empty!")
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            if strongSelf.numeratorList.isNotEmpty {
                                                NotificationCenter.default.post(name: .EMReadyToStart, object: nil)
                                                strongSelf.webView.isHidden = false
                                            } else {
                                                print("Numerator empty!")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Keyboard-related communication during the demonstration process.
    func updateKeyboardHighlightInDemonstration() {
        DispatchQueue.main.async { [self] in
            for note in 24..<112 {
                self.keyboardView.programmaticNoteOff(note)
                self.keyboardView.programmaticOnHands.removeAll()
            }
            if sessionManager.demonstrationCount < self.scoreManager.score!.notes.count && sessionManager.demonstrationCount >= 0 {
                for note in self.scoreManager.score!.notes[self.sessionManager.demonstrationCount] {
                    self.keyboardView.programmaticOnHands.append(note.hand)
                    self.keyboardView.programmaticNoteOn(note.key + 21)
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(note.duration) / 1000.0 * 0.75) {
                        self.keyboardView.programmaticNoteOff(note.key + 21)
                    }
                }
            }
        }
    }
        
    /// Create a new practice record.创建新的练习记录
    func createNewPracticeRecord() {
        practiceRecord = PracticeRecord()
        practiceRecord.uuid = resourceManager.resource?.practiceList[resourceManager.currentPracticeListIndex].uuid
        practiceRecord.mode = resourceManager.resource?.practiceList[resourceManager.currentPracticeListIndex].mode
        
        practiceRecord.practiceTime = resourceManager.currentPracticeTime
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY-MM-dd HH:mm:ss"
        practiceRecord.startDate = dateFormatter.string(from: startDate)
    }
    
    /// Acquisition and recording of all information of the current practice record.
    func endPracticeRecord(withStatus status: Bool) {
        practiceRecord.status = status
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY-MM-dd HH:mm:ss"
        practiceRecord.endDate = dateFormatter.string(from: Date())
        
        // score
        if status == false || practiceRecord.mode != 2 {
            practiceRecord.score = PracticeScore()
        } else {
            let scoreArray = sdkManager.getScore()
            practiceRecord.score = PracticeScore(speed: scoreArray[0], intonation: scoreArray[1], completeness: scoreArray[2], rhythm: scoreArray[3], smoothness: scoreArray[4], totalScore: scoreArray[5])
        }
    }
    
    @objc func scrollHorizontallySwitchChange() {
        self.webView.evaluateJavaScript("setHorizontalMusicScore(\(scrollHorizontally))") { [weak self] (result, error) in
            if let strongSelf = self {
                strongSelf.sessionManager.isInDemonstrationMode = false
                strongSelf.sessionManager.stopDemonstration()
                strongSelf.tryAgain(withUIUpdated: false)
            }
        }
    }
    
    @objc func metronomePopoverViewDidDisappear() {
        startButton.alpha = 0.5
        startButton.isEnabled = false
        tryAgain(withUIUpdated: false)
    }
    
    func getScore() -> [Double] {
        
        let currentDate = Date()
        var scoreArray = [Double]()
        
        // ["Total Score": allScores[5], "Stability": allScores[4], "Pitch": allScores[1], "Speed": allScores[0], "Rhythm": allScores[3], "Integrity": allScores[2]]

        // Pitch Score: Number of correct notes / Length of the target note sequence * 100%
        let intonationScore = Double((noteCorrectWrongList!.filter({ $0 == true }).count)) / Double((scoreManager.score?.notes.count)!)
        
        // Speed Score: Actual duration / Required duration of the played part * 100%
        let scoreDuration = Double((scoreManager.score?.notes.last?.first?.currentTimeStamp)! - (scoreManager.score?.notes.first?.first?.currentTimeStamp)!)
        let cursorDuration = currentDate.timeIntervalSince(startDate) * 1000.0
        let speedScore = min(1.0, scoreDuration / cursorDuration * intonationScore * 1.1)
        
        // Integrity Score: (Number of correct notes - Number of skips * 10) / Length of the target note sequence * 100%
        var integrityScore: Double {
            var wrongAccumulated = 0
            var skips = 0
            for i in 0..<noteCorrectWrongList!.count {
                if noteCorrectWrongList![i] == false {
                    wrongAccumulated += 1
                } else {
                    wrongAccumulated = 0
                }
                if wrongAccumulated >= 3 {
                    skips += 1
                    wrongAccumulated = 0
                }
            }
            return min(max((Double((noteCorrectWrongList!.filter({ $0 == true }).count) - skips * 10) / Double((scoreManager.score?.notes.count)!)) * intonationScore, 0.0), 1.0)
        }
        
        // Rhythm Score: (Number of correct notes - Number of mistakes) / Length of the target note sequence * 150% * Pitch Score
        let rhythmScore = max(min(1, (Double((noteCorrectWrongList!.filter({ $0 == true }).count)) - Double((noteCorrectWrongList!.filter({ $0 == false }).count)))  / Double((scoreManager.score?.notes.count)!) * intonationScore * 1.5), 0)
        
        scoreArray.append(speedScore)
        scoreArray.append(intonationScore)
        scoreArray.append(integrityScore)
        scoreArray.append(rhythmScore)

        // Stability Score: Average of the above 4 scores
        let smoothnessScore = intonationScore * 0.2 + speedScore * 0.4 + rhythmScore * 0.4
        scoreArray.append(smoothnessScore)
        
        // Overall Score: Average of the above 5 scores
        let overallScore = (speedScore + intonationScore + integrityScore + rhythmScore + smoothnessScore) / 5
        scoreArray.append(overallScore)

        return scoreArray
    }
    
    /// Return the practice results to the server in JSON format.
    func postPracticeRecordToServer() {
        let practiceRecordJson = JSON(practiceRecord)
        
        // TODO: Send back the practice results to the server.
        print("practiceRecordJson:", practiceRecordJson)
    }
    
    ///Page navigation redirection.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "ShowReport":
            if let vc = segue.destination as? ReportViewController {
                vc.sheetName = sheetName
                vc.urlToLoad = urlToLoad
                vc.startBar = startBar
                vc.endBar = endBar
                vc.hand = hand
                vc.currentMode = currentMode
                vc.noteCount = noteCount
                
                print("noteCorrectWrongList:", noteCorrectWrongList)
                
                let wrongNodeIndices = ReportManager.shared.getWrongNodeIndices(noteCorrectWrongList: noteCorrectWrongList!)
                let messyRange = ReportManager.shared.getMessyRange(noteCorrectWrongList: noteCorrectWrongList!)
                var json = JSON()
                json["messyRange"] = JSON(messyRange.map { JSON($0) })
                json["wrongNodeIndices"] = JSON(wrongNodeIndices)
                vc.reportJSON = json
            }
        default:
            break
        }
    }
}

/// Delegate method for webpage navigation
extension PracticeViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        parseResource()
        let javascriptStyle = "var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'; var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);"
        webView.evaluateJavaScript(javascriptStyle, completionHandler: nil)
    }
}

/// Delegate method for webpage displaying the music score
extension PracticeViewController: WKScriptMessageHandler {
    /// Called each time the music score is loaded or refreshed
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("didReceive message at date:", Date(), "Message Name", message.name)
        if message.name == messageName {
            print("WebKit message")
            if let dict = message.body as? [String: Any] {
                if let status = dict["status"] as? String {
                    switch status {
                    
                    /// Communication related to demonstration
                    case "shifan":
                        self.webView.evaluateJavaScript("stopPlay()") { [weak self] (result, error) in
                            if let strongSelf = self {
                                strongSelf.sessionManager.isInDemonstrationMode = false
                                strongSelf.sessionManager.stopDemonstration()
                                let hud = MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
                                hud.label.text = "Demo Ended"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    hud.hide(animated: true)
                                }
                                strongSelf.tryAgain()
                            }
                        }
                        return
                        
                    /// Communication related to keyboard
                    case "keyboard":
                        updateKeyboardHighlightInDemonstration()
                        sessionManager.demonstrationCount += 1
                        return
                    default:
                        break
                    }
                }
            }
            
            /// Determine whether it is currently in demonstration mode
            if sessionManager.isInDemonstrationMode {
                var hand = 0
                switch sessionManager.handsForDemoPerformance {
                case .full:
                    hand = 0
                case .left:
                    hand = 2
                case .right:
                    hand = 1
                }
                if let score = self.scoreManager.getHandScore(hand: hand) {
                    self.sessionManager.updateSequence(from: score)
                }
                self.webView.evaluateJavaScript("drawLeftRightHandMusicScore(\(hand))")
                self.webView.evaluateJavaScript("playAtSpeed(\(self.sessionManager.demonstrationSpeed))") { (result, error) in
                }
                sessionManager.startDemonstration(bpm: self.sessionManager.demonstrationSpeed)
                return
            }
            
            /// Loading of music score
            loadScore()
        }
    }
}

/// Delegate methods for the core recognition module
extension PracticeViewController: LibDelegate {
    /// No correct note has been recognized for a long time in the phrase recognition scoring
    func notMetForALongTime() {
        DispatchQueue.main.async { [self] in
            skipNoteButton.isHidden = false
            /// If the keyboard showing mode is hidden
            if !showInstrumentPanel {
                keyboardView.isHidden = false
            }
            if !flickKeyboardTimer.isValid {
                flickKeyboardTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(flickKeyboard), userInfo: nil, repeats: true)
            }
        }
    }
    
    /// Keyboard flickering in phrase recognition mode
    @objc func flickKeyboard() {
        for note in 24..<112 {
            self.keyboardView.programmaticNoteOff(note)
            self.keyboardView.programmaticOnHands.removeAll()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.isStarted && self.currentCount <= self.scoreManager.score!.notes.count - 1 {
                for note in self.scoreManager.score!.notes[self.currentCount] {
                    // Display the corresponding keyboard location based on the corresponding hand
                    if note.hand == 0 || note.hand == self.hand {
                        self.keyboardView.programmaticNoteOn(note.key + 21)
                        self.keyboardView.programmaticOnHands.append(note.hand)
                    }
                }
            }
        }
    }
    
    /// Record the start timestamp
    func setStartDate(_ startDate: Date) {
        self.startDate = startDate
    }
    
    /// Move to the recognition of the next group of sounds when the current sound recognition is correct.
    func moveToNext(_ type: Int) {
        if currentMode != 0 && noteCorrectWrongList != nil {
            if !noteCorrectWrongList!.isEmpty {
                noteCorrectWrongList?.removeLast()
            }
        }
        let hand = self.hand ?? 0
        if hand == 0 {
            currentCount += 1
            if !self.sdkManager.isRunningModel || currentMode == 0 || type == 1 {
                noteCorrectWrongList?.append(type == 1)
                isResultCorrect = false
                DispatchQueue.main.async {
                    if self.currentMode == 2 {
                        /// Evaluation scoring mode, no note color animation
                        self.webView.evaluateJavaScript("moveCursorToNext(-1, \(coinAnimationOn))") { result, error in
                        }
                    } else {
                        /// Phrase recognition and whole song challenge mode, note color animation is present
                        self.webView.evaluateJavaScript("moveCursorToNext(\(type), \(coinAnimationOn))") { result, error in
                        }
                    }
                }
            } else {
                self.needToColorPreviousNote = true
                DispatchQueue.main.async {
                    self.webView.evaluateJavaScript("moveCursorToNext(-1, \(coinAnimationOn))") { result, error in
                    }
                }
            }
        } else {
            currentCount += 1
            if !self.sdkManager.isRunningModel || currentMode == 0 || type == 1 {
                noteCorrectWrongList?.append(type == 1)
                isResultCorrect = false
                DispatchQueue.main.async {
                    if (self.currentCount < self.noteCount && !self.scoreManager.score!.notes[self.currentCount - 1].contains { $0.hand == self.hand }) {
                        self.noteCorrectWrongList?.removeLast()
                        self.webView.evaluateJavaScript("moveCursorToNext(1, \(coinAnimationOn))") { result, error in
                        }
                    } else {
                        if self.currentMode == 2 {
                            /// Evaluation scoring mode, no note color animation
                            self.webView.evaluateJavaScript("moveCursorToNext(-1, \(coinAnimationOn))") { result, error in
                            }
                        } else {
                            /// Phrase recognition and whole song challenge mode, note color animation is present
                            self.webView.evaluateJavaScript("moveCursorToNext(\(type), \(coinAnimationOn))") { result, error in
                            }
                        }
                    }
                }
            } else  {
                self.needToColorPreviousNote = true
                DispatchQueue.main.async {
                    self.webView.evaluateJavaScript("moveCursorToNext(-1, \(coinAnimationOn))") { result, error in
                    }
                }
            }
        }
    }
    
    func updatePreviousNoteColor(_ result: Bool) {
        let hand = self.hand ?? 0
        noteCorrectWrongList?.append(result)
        accumulatedKeys.removeAll()
        if currentMode != 2 || (self.currentCount < self.noteCount && !self.scoreManager.score!.notes[self.currentCount].contains {$0.hand == self.hand}) {
            DispatchQueue.main.async {
                if self.currentMode == 1 {
                    self.webView.evaluateJavaScript("updateLastNoteColor(\(result), \(hand))") { result, error in
                    }
                }
            }
        }
    }
    
    /// In phrase recognition mode, called after recognition is correct.
    func targetMet() {
        DispatchQueue.main.async { [self] in
            skipNoteButton.isHidden = true
            /// if keyboardShowingMode is hidden
            if !showInstrumentPanel {
                self.keyboardView.isHidden = true
                
            }
            
            flickKeyboardTimer.invalidate()
            
            /// Clear the currently highlighted notes on the keyboard
            for note in 24..<112 {
                self.keyboardView.programmaticNoteOff(note)
                self.keyboardView.programmaticOnHands.removeAll()
            }
            
            /// Update the next set of highlighted notes on the keyboard
            /*
            for note in self.scoreManager.score!.notes[self.currentCount] {
                self.keyboardView.programmaticNoteOn(note.key + 21)
                self.keyboardView.programmaticOnHands.append(note.hand)
//                DispatchQueue.main.asyncAfter(deadline: .now() + Double(note.duration) / 1000.0 * 0.75) {
//                    self.keyboardView.programmaticNoteOff(note.key + 21)
//                }
            }
            */
            
            /// If all notes have been played, consider the practice completed
            // 如果所有音符都已演奏完毕，则认为练习已完成
            if self.currentCount >= self.noteCount {
                self.sessionManager.stop()
                self.view.bringSubviewToFront(self.blackView)
                self.blackView.isHidden = false
                let successView = SuccessView(frame: .zero)
                successView.delegate = self
                successView.backgroundImageView.image = UIImage(named: "FinishedAll")
                self.view.addSubview(successView)
                successView.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.width.equalTo(248)
                    make.height.equalTo(285)
                }
                
                if resourceManager.currentPracticeTime >= resourceManager.resource!.practiceList[resourceManager.currentPracticeListIndex].practiceTime - 1 &&
                    resourceManager.currentPracticeListIndex >= resourceManager.resource!.practiceList.count - 1 {
                    successView.backgroundImageView.image = UIImage(named: "FinishedAll")
                    successView.tryAgainButton.setImage(UIImage(named: "TryAgain-Wide"), for: .normal)
                    successView.tryAgainButton.snp.removeConstraints()
                    successView.nextButton.isHidden = true
                    successView.tryAgainButton.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().offset(16)
                        make.right.equalToSuperview().offset(-16)
                        make.bottom.equalToSuperview().offset(-16)
                        make.height.equalTo(36)
                    }
                } else {
                    successView.startTimer()
                }
                isTryAgain = false
                
                /// Complete practice recording and return
                endPracticeRecord(withStatus: true)
                postPracticeRecordToServer()
                
                return
            }
            
            if self.hand != 0 {
                self.moveToNext(1)
                print("noteCount:", self.noteCount, "currentCount:", self.currentCount)
                while true {
                    if self.currentCount < self.noteCount {
                        if !self.scoreManager.score!.notes[self.currentCount].map({ $0.hand }).contains(self.hand) {
                            DispatchQueue.main.async {
                                self.webView.evaluateJavaScript("moveCursorToNext(-1, false)") { result, error in
                                }
                            }
                            self.currentCount += 1
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
            } else {
                self.moveToNext(1)
            }
        }
    }
    
    /// In whole song challenge or evaluation scoring mode, repeatedly call the following method for note recognition
    // 在整首歌挑战或评估评分模式下，重复调用以下方法进行音符识别
    func keys(keys: [Int]) {
        if !(currentMode == 1 || currentMode == 2) {
            return
        }
        if self.currentCount >= self.noteCount {
            /// If all notes have been played, consider the practice completed
            // 如果所有音符都已演奏完毕，则认为练习已完成
            
            sessionManager.stopTimer()
            currentCount = 0
            accumulatedTime = 0
            
            self.sessionManager.stop()
            self.sessionManager.stopMetronome()
            if self.currentMode != 2 {
                DispatchQueue.main.async {
                    self.view.bringSubviewToFront(self.blackView)
                    self.blackView.isHidden = false
                    let successView = SuccessView(frame: .zero)
                    successView.delegate = self
                    self.view.addSubview(successView)
                    successView.snp.makeConstraints { (make) in
                        make.center.equalToSuperview()
                        make.width.equalTo(248)
                        make.height.equalTo(285)
                    }
                    if self.resourceManager.currentPracticeTime >= self.resourceManager.resource!.practiceList[self.resourceManager.currentPracticeListIndex].practiceTime - 1 &&
                        self.resourceManager.currentPracticeListIndex >= self.resourceManager.resource!.practiceList.count - 1 {
                        successView.tryAgainButton.setImage(UIImage(named: "TryAgain-Wide"), for: .normal)
                        successView.tryAgainButton.snp.removeConstraints()
                        successView.nextButton.isHidden = true
                        successView.tryAgainButton.snp.makeConstraints { (make) in
                            make.left.equalToSuperview().offset(16)
                            make.right.equalToSuperview().offset(-16)
                            make.bottom.equalToSuperview().offset(-16)
                            make.height.equalTo(36)
                        }
                    } else {
                        successView.startTimer()
                    }
                    self.sessionManager.stopMetronome()
                    self.isTryAgain = false
                }
            } else {
                DispatchQueue.main.async {
                    self.view.bringSubviewToFront(self.blackView)
                    self.blackView.isHidden = false
                    self.resultView = ResultView(frame: .zero)
                    let allScores = self.getScore()
                    print("allScores:", allScores)
                    self.resultView?.setupView(withScores: ["Total Score": allScores[5], "Stability": allScores[4], "Notes": allScores[1], "Speed": allScores[0], "Rhythm": allScores[3], "Completeness": allScores[2]])
                    self.resultView!.delegate = self
                    self.view.addSubview(self.resultView!)
                    self.resultView!.snp.makeConstraints { (make) in
                        make.center.equalToSuperview()
                        make.width.equalTo(248)
                        make.height.equalTo(285)
                    }
                }
            }
            
            /// Complete practice recording and return
            // 完成练习记录并返回
            endPracticeRecord(withStatus: true)
            postPracticeRecordToServer()
            return
        }
            
        /// The following code is for recognizing notes that have not yet been completed.
        /// 128 ms interval per call
        /// 以下代码用于识别尚未完成的注释。每次呼叫间隔128毫秒
        calledTimes += 1
        accumulatedKeys += keys
        
        if self.currentCount < self.noteCount {
            
            var minInterval = 1000
            if currentCount < scoreManager.score!.notes.count - 1 {
                minInterval = scoreManager.score!.notes[currentCount + 1].map { $0.currentTimeStamp }.min()! - scoreManager.score!.notes[currentCount].map { $0.currentTimeStamp }.min()!
            }
            var target = [Int]()
            var previousTarget = [Int]()
            var previous2Target = [Int]()
            var nextTarget = [Int]()
            if self.hand == 0 {
                target = scoreManager.score!.notes[currentCount].map { $0.key! }
                nextTarget = scoreManager.score!.notes[min(currentCount, self.noteCount - 1)].map { $0.key! }
                previousTarget = scoreManager.score!.notes[max(currentCount - 1, 0)].map { $0.key! }
                previous2Target = scoreManager.score!.notes[max(currentCount - 2, 0)].map { $0.key! }
            } else {
                target = scoreManager.score!.notes[currentCount].map { $0.hand == self.hand ? $0.key! : -1 }
                nextTarget = scoreManager.score!.notes[min(currentCount, self.noteCount - 1)].map { $0.hand == self.hand ? $0.key! : -1 }
                previousTarget = scoreManager.score!.notes[max(currentCount - 1, 0)].map { $0.hand == self.hand ? $0.key! : -1 }
                previous2Target = scoreManager.score!.notes[max(currentCount - 2, 0)].map { $0.hand == self.hand ? $0.key! : -1 }
            }
            // 着色上一个音符
            if needToColorPreviousNote {
                needToColorPreviousNote = false
                var result = false
                if minInterval < 800 {
                    result = checkResult(accumulatedKeys, target: previousTarget) || checkResult(accumulatedKeys, target: previous2Target) || checkResult(accumulatedKeys, target: target)
                } else {
                    result = checkResult(accumulatedKeys, target: previousTarget) || checkResult(accumulatedKeys, target: target)
                }
                if result {
                    // currentWrongCount = 0
                }
                self.updatePreviousNoteColor(result)
                isResultCorrect = false
            } else {
                if minInterval < 800 {
                    if checkResult(accumulatedKeys, target: target) || checkResult(accumulatedKeys, target: previousTarget) || checkResult(accumulatedKeys, target: nextTarget) {
                        isResultCorrect = true
                        accumulatedKeys.removeAll()
                    }
                } else {
                    if checkResult(accumulatedKeys, target: target) || checkResult(accumulatedKeys, target: nextTarget) {
                        isResultCorrect = true
                        accumulatedKeys.removeAll()
                    }
                }
            }
        }
    }
    
    /// Processing of model output results and accumulation of notes within the same time period
    /// 处理输出模式结果和同一时间段内的累积音符
    func checkResult(_ result: [Int], target: [Int]) -> Bool {
        
        var resultSet = Set(result)
        var targetSet = Set(target)
        targetSet.remove(-1)
        var result = false
        
        let unionizedResultSet = resultSet.union(previouResults)
        if targetSet.isSubset(of: unionizedResultSet) {
            result = true
        }
        if targetSet.count > 3 {
            var count = 0
            for key in targetSet {
                if unionizedResultSet.contains(key) {
                    count += 1
                }
            }
            if count > Int(0.57 * Double(targetSet.count)) {
                result = true
            }
        }
        print("resultSet:", [Int](resultSet).sorted(), "targetSet:", [Int](targetSet).sorted(), "result:", result)
        return result
    }
    
}

/// Delegate methods for popup window after individual practice ends
// 练习结束后弹出窗口
extension PracticeViewController: ResultViewDelegate {
    /// Tap [Try Again]
    func didTapTryAgain() {
        print("try again")
        tryAgain()
    }
    
    /// Tap [Next Practice]
    func didTapNext() {
        print("next")
        goNext()
    }
    
    /// Tap [Evaluation Report]
    func didTapShowReport() {
        print("show report")
        sessionManager.stop()
        performSegue(withIdentifier: "ShowReport", sender: self)
    }
    
    /// Tap [Close] in the upper right corner
    func didTapCancel() {
        blackView.isHidden = true
    }
}

/// Delegate methods for popup window of [Settings] button in the upper right corner
extension PracticeViewController: SettingsPopoverViewDelegate {
    
    /// Always show instrument panel
    func alwaysShowInstrumentPanel(to alwaysOn: Bool) {
        self.keyboardView.isHidden = !alwaysOn
        showInstrumentPanel = alwaysOn
    }
    
    /// Full keyboard
    func setKeyboardShowingRange(to range: KeyboardShowingRange) {
        if range == .partial {
            self.keyboardView.firstOctave = 1
            self.keyboardView.octaveCount = 5
        } else {
            self.keyboardView.firstOctave = 0
            self.keyboardView.octaveCount = 7
        }
        keyboardView.setNeedsDisplay()
    }
}

/// Delegate methods for individual components in the upper right corner
extension PracticeViewController: NavBarOptionDelegate {
    /// Called when any component in the upper right corner is tapped
    func didTap(sender: NavBarOptionView) {
        /// Filter response between multiple frequent taps
        if shouldResponceToTap {
            shouldResponceToTap = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.shouldResponceToTap = true
            }
        } else {
            return
        }
        
        /// If the practice is in progress, it needs to be paused before making changes to the settings 如果练习正在进行中，则在更改设置之前需要暂停
        if isStarted && sender.type != .restartPracticeOrDemonstration {
            let hud = MBProgressHUD.showAdded(to: view.self, animated: true)
            hud.label.text = "练习已经开始，请停止后继续练习。"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                hud.hide(animated: true)
            }
            return
        }
        
        switch sender.type {
            
        /// Tap [Skip Note] button
        case .skipNote:
            didTapSkipNote()
            
        /// Tap [Restart] button
        case .restartPracticeOrDemonstration:
            didTapRestart()
            
        /// Tap [Demonstration] button
        case .demonstration:
            didTapDemonstration(sender: sender)
            
        /// Tap [Metronome] button
        case .metronome:
            didTapMetronome(sender: sender)
            
        /// Tap [Accompaniment] button
        case .accompaniment:
            didTapAccompaniment(sender: sender)
            
        /// Tap [Settings] button
        case .settings:
            didTapSettings(sender: sender)
            
        /// Tap [Left Hand] button
        case .leftHand:
            didTapLeftHand()
            
        /// Tap [Right Hand] button
        case .rightHand:
            didTapRightHand()
            
        default:
            print(sender.type.title)
        }
    }
}

/// Delegate methods for demonstration tempo selection page演示节奏选择页面的代表方法
extension PracticeViewController: DemonstrationTempoSelectionViewDelegate {
    /// Select tempo
    func demoTempoSelected(to tempo: Double) {
        /// If in demonstration mode, need to pause the web score playback first如果处于演示模式，则需要先暂停网络乐谱播放
        self.webView.evaluateJavaScript("stopPlay()") { [weak self] (result, error) in
            if let strongSelf = self {
                print("stopped playing")
                strongSelf.sessionManager.isInDemonstrationMode = true
                strongSelf.sessionManager.demonstrationSpeed = tempo
                strongSelf.tryAgain()
            }
        }
    }
    
    /// Turn off demonstration关闭演示
    func offSelected() {
        self.webView.evaluateJavaScript("stopPlay()") { [weak self] (result, error) in
            if let strongSelf = self {
                strongSelf.sessionManager.isInDemonstrationMode = false
                strongSelf.sessionManager.stopDemonstration()
                let hud = MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
                hud.label.text = "Demo Ended"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    hud.hide(animated: true)
                }
                strongSelf.tryAgain()
            }
        }
    }
}

/// Popover page delegate弹出页面代理
extension PracticeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
