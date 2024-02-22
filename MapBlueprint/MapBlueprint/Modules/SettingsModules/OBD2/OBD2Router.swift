//
//  OBD2Router.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation
import UIKit

protocol OBD2RouterProtocol: AnyObject {
    static func createModule(navigationController: UINavigationController) -> UIViewController
}

class OBD2Router: OBD2RouterProtocol {
    weak var navigationController: UINavigationController?
    
    static func createModule(navigationController: UINavigationController) -> UIViewController {
        let interactor: OBD2InteractorProtocol = OBD2Interactor()
        let router: OBD2Router = OBD2Router()
        router.navigationController = navigationController
        let eventHandler: OBD2EventHandlerProtocol = OBD2EventHandler(interactor: interactor, router: router)
        let viewController = OBD2ViewController(eventHandler: eventHandler)
        eventHandler.viewController = viewController
        return viewController
    }
    
}
