//
//  DashboardEventHandler.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/18/24.
//

import Foundation

protocol DashboardEventHandlerProtocol: AnyObject {
    var viewController: DashboardViewControllerProtocol? { get set }
}

class DashboardEventHandler: DashboardEventHandlerProtocol {
    weak var viewController: DashboardViewControllerProtocol?
    let interactor: DashboardInteractorProtocol
    let router: DashboardRouterProtocol
    
    init(interactor: DashboardInteractorProtocol, router: DashboardRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
}
