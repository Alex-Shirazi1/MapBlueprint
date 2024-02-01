//
//  ConnectRouter.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation
import UIKit

protocol ConnectRouterProtocol: AnyObject {
    static func createModule(navigationController: UINavigationController) -> UIViewController
}

class ConnectRouter: ConnectRouterProtocol {
    weak var navigationController: UINavigationController?
    
    static func createModule(navigationController: UINavigationController) -> UIViewController {
        let interactor: ConnectInteractorProtocol = ConnectInteractor()
        let router: ConnectRouter = ConnectRouter()
        router.navigationController = navigationController
        let eventHandler: ConnectEventHandlerProtocol = ConnectEventHandler(interactor: interactor, router: router)
        let viewController = ConnectViewController(eventHandler: eventHandler)
        eventHandler.viewController = viewController
        return viewController
    }
}
    
