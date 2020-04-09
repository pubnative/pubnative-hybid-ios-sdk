//
//  AppDelegate.swift
//  HyBidDemo
//
//  Created by Fares Ben Hamouda on 09.04.20.
//  Copyright © 2020 Fares Ben Hamouda. All rights reserved.
//

import UIKit
import HyBid

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        HyBid.initWithAppToken(AdSdkDemoSettings.appToken, withPartnerKeyword: AdSdkDemoSettings.partnerKeyword) { (success) in
            
            guard success else {return}
            HyBidLogger.setLogLevel(HyBidLogLevelDebug)
            print("HyBid initialisation completed")
        }
        
        let targetingModel = HyBidTargetingModel()
        targetingModel.age = 29
        targetingModel.gender = "m"
        HyBid.setTargeting(targetingModel)
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

