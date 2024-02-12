//
//  OBD2Router.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation
import UIKit

protocol OBD2RouterProtocol: AnyObject {
    static func createModule(navigationViewController: UINavigationController, settingsViewController: SettingsViewControllerProtocol) -> UIViewController
}

class OBD2Router: OBD2RouterProtocol {
    var navigationController: UINavigationController
    
    let settingsViewController: SettingsViewControllerProtocol
    
    init(navigationController: UINavigationController, settingsViewController: SettingsViewControllerProtocol) {
        self.navigationController = navigationController
        self.settingsViewController = settingsViewController
    }
    
    
    static func createModule(navigationViewController navigationViewController: UINavigationController, settingsViewController: SettingsViewControllerProtocol) -> UIViewController {
        
        let interactor: OBD2InteractorProtocol = OBD2Interactor(dataManager: OBD2DataManager())
        let router: OBD2Router = OBD2Router(navigationController: navigationViewController, settingsViewController: settingsViewController)
        let eventHandler: OBD2EventHandlerProtocol = OBD2EventHandler(interactor: interactor, router: router)
        let viewController = OBD2ViewController(eventHandler: eventHandler)
        eventHandler.viewController = viewController
        interactor.eventHandler = eventHandler
        eventHandler.viewController = viewController
        return viewController
    }
}
