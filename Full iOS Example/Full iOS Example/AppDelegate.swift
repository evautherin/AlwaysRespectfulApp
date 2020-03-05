//
//  AppDelegate.swift
//  Full iOS Example
//
//  Created by Etienne Vautherin on 27/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import UIKit
import AnyLogger


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AppLogger.startLogging()
        
        log.debug("launchOptions: \(launchOptions.debugDescription)")
        let locationLaunch = (launchOptions?[UIApplication.LaunchOptionsKey.location] as? NSNumber)?.boolValue ?? false
        AppModel.shared.sideEffects(locationLaunch)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        log.debug("applicationWillTerminate")
        AppLogger.flushLog()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

