//
//  DashboardRouter.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/18/24.
//

import Foundation
import UIKit

protocol DashboardRouterProtocol: AnyObject {
    static func createModule(navigationController: UINavigationController) -> UIViewController
}

class DashboardRouter: DashboardRouterProtocol {
    weak var navigationController: UINavigationController?
    
    static func createModule(navigationController: UINavigationController) -> UIViewController {
        let interactor: DashboardInteractorProtocol = DashboardInteractor()
        let router: DashboardRouter = DashboardRouter()
        router.navigationController = navigationController
        let eventHandler: DashboardEventHandlerProtocol = DashboardEventHandler(interactor: interactor, router: router)
        let viewController = DashboardViewController(eventHandler: eventHandler)
        eventHandler.viewController = viewController
        return viewController
    }
    
}
