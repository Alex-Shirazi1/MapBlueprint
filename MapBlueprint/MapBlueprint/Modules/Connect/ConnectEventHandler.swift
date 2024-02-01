//
//  ConnectEventHandler.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation

protocol ConnectEventHandlerProtocol: AnyObject {
    var viewController: ConnectViewControllerProtocol? { get set }
}

class ConnectEventHandler: ConnectEventHandlerProtocol {
    weak var viewController: ConnectViewControllerProtocol?
    let interactor: ConnectInteractorProtocol
    let router: ConnectRouterProtocol
    
    init(interactor: ConnectInteractorProtocol, router: ConnectRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
}
