//
//  SceneDelegate.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        
        let tabBarController = self.tabbar(controllers: [])
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window

        DispatchQueue.global(qos: .background).async {
            self.prepareViewControllers { controllers in
                DispatchQueue.main.async {
                    tabBarController.viewControllers = controllers
                }
            }
        }
    }
    
    private func prepareViewControllers(completion: @escaping ([UIViewController]) -> Void) {
        DispatchQueue.main.async {
            let controllers = self.createViewControllers()
            completion(controllers)
        }
    }
    
    private func createViewControllers() -> [UIViewController] {

        // Home Module Logic
        
        let homeNavigationController = UINavigationController()
        let homeViewController = HomeRouter.createModule(navigationController: homeNavigationController)
        homeNavigationController.viewControllers = [homeViewController]
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        
        
        // Dashboard Module Logic
        
        let dashboardNavigationController = UINavigationController()
        let dashboardViewController = DashboardRouter.createModule(navigationController: dashboardNavigationController)
        dashboardNavigationController.viewControllers = [dashboardViewController]
        dashboardNavigationController.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "gauge.with.dots.needle.67percent"), tag: 2)
        
        // Settings Module Logic
        
        let settingsNavigationController = UINavigationController()
        let settingsViewController = SettingsRouter.createModule(navigationController: settingsNavigationController)
        settingsNavigationController.viewControllers = [settingsViewController]
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)
        
        
        
        
        return [homeNavigationController, dashboardNavigationController, settingsNavigationController]
    }

    private func tabbar(controllers: [UIViewController]) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = controllers
        tabBarController.tabBar.isTranslucent = false

        // Set barTintColor based on the user interface style
            tabBarController.tabBar.barTintColor = UIColor { traitCollection -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .black
                    default:
                        return .white
                }
            }
      
        
        // Set divider (shadowImage) to the top of the tab bar
        tabBarController.tabBar.shadowImage = UIImage() // Clear image for the shadow
        tabBarController.tabBar.backgroundImage = UIImage() // Clear image for the background
   
            let dividerColor = UIColor { traitCollection -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .white // White divider for dark mode
                    default:
                        return .black // Black divider for light mode
                }
            }
            tabBarController.tabBar.standardAppearance.shadowColor = dividerColor

                tabBarController.tabBar.scrollEdgeAppearance = tabBarController.tabBar.standardAppearance
            
        return tabBarController
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
            if OBD2AdapterFactory.shared.getStatus() != .connected && AppConfigurable.shared.autoConnectToAdapter {
                OBD2AdapterFactory.shared.setupTransporterAndConnect()
            }
        }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
