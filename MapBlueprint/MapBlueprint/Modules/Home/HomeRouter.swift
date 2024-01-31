//
//  HomeRouter.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation
import UIKit

protocol HomeRouterProtocol: AnyObject {
    static func createModule(navigationController: UINavigationController) -> UIViewController
}

class HomeRouter: HomeRouterProtocol {
    weak var navigationController: UINavigationController?
    
    static func createModule(navigationController: UINavigationController) -> UIViewController {
        let interactor: HomeInteractorProtocol = HomeInteractor()
        let router: HomeRouter = HomeRouter()
        router.navigationController = navigationController
        let eventHandler: HomeEventHandlerProtocol = HomeEventHandler(interactor: interactor, router: router)
        let viewController = HomeViewController(eventHandler: eventHandler)
        eventHandler.viewController = viewController
        return viewController
    }
    
}
