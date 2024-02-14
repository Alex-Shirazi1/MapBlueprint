//
//  OBD2Router.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation
import UIKit

protocol OBD2RouterProtocol: AnyObject {
    static func createModule(navigationViewController: UINavigationController) -> UIViewController
}

class OBD2Router: OBD2RouterProtocol {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    static func createModule(navigationViewController navigationController: UINavigationController) -> UIViewController {
        let dataManager = OBD2DataManager(factory: OBD2AdapterFactory.shared)
        let interactor = OBD2Interactor(dataManager: dataManager)
        let router = OBD2Router(navigationController: navigationController) // Adjusted constructor
        let eventHandler = OBD2EventHandler(interactor: interactor, router: router)
        let viewController = OBD2ViewController(eventHandler: eventHandler)

        eventHandler.viewController = viewController
        interactor.eventHandler = eventHandler

        return viewController
    }
}
