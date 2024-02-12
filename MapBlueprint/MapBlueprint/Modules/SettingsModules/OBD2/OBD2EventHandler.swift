//
//  OBD2EventHandler.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation

protocol OBD2EventHandlerProtocol: AnyObject {
    var viewController: OBD2ViewControllerProtocol? { get set }
    func handleTransporterAndConnect()
    func adapterDidConnect(status: String)
}

import Foundation

class OBD2EventHandler: OBD2EventHandlerProtocol {
    weak var viewController: OBD2ViewControllerProtocol?
    let interactor: OBD2InteractorProtocol
    let router: OBD2RouterProtocol

    init(interactor: OBD2InteractorProtocol, router: OBD2RouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func handleTransporterAndConnect() {
        interactor.setupTransporterAndConnect()
    }

    func adapterDidConnect(status: String) {
        viewController?.updateConnectionStatus(status: status)
    }
}
