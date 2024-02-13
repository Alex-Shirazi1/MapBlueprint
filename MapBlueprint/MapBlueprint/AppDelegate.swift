//
//  AppDelegate.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import UIKit
import CarPlay

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CPApplicationDelegate{
   
    var window: UIWindow?
    var carPlayWindow: CPWindow?
    
    func application(_ application: UIApplication, didConnectCarInterfaceController interfaceController: CPInterfaceController, to window: CPWindow) {
        self.carPlayWindow = window
              let carPlaySceneDelegate = CarPlaySceneDelegate(interfaceController: interfaceController, window: window)
              window.rootViewController = carPlaySceneDelegate.createCarPlayRootViewController()
          }
    
    func application(_ application: UIApplication, didDisconnectCarInterfaceController interfaceController: CPInterfaceController, from window: CPWindow) {
        self.carPlayWindow = nil
    }
    



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
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

