//
//  AppDelegate.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 5/31/21.
//

import UIKit
import AVFoundation
import Bugly

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.\
        
        let session = AVAudioSession.sharedInstance()
                
        do {
            try session.setCategory(.playAndRecord,
                                    options: [.defaultToSpeaker])
            try session.setPreferredSampleRate(48000)
            try session.setActive(true)
        } catch let err {
            print(err)
        }
    
        // Other AudioSession stuff here
        
        do {
            try session.setActive(true)
        } catch let err {
            print(err)
        }
        
        let buglyConfig = BuglyConfig();
        buglyConfig.debugMode = true;
        buglyConfig.unexpectedTerminatingDetectionEnable = true; // Abnormal exit event recording switch, off by default.
        buglyConfig.reportLogLevel = .warn; // Report level.
        buglyConfig.blockMonitorEnable = true; // Enable lag monitoring.
        buglyConfig.blockMonitorTimeout = 5; // Lag monitoring judgment interval, in seconds.
        
        Bugly.start(withAppId: "0104113891", config: buglyConfig)
        
//        print(Bugly.sdkVersion())
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .EMApplicationDidBecomeActive, object: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .EMApplicationDidBecomeActive, object: nil)
    }
    
}

