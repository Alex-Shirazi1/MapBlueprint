//
//  OBD2AdapterFactory.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/13/24.
//

import Foundation

class OBD2AdapterFactory {
    static let shared = OBD2AdapterFactory()
    private var interactor: OBD2Interactor?

    private init() {}

    func setupAndConnect() {
        let dataManager = OBD2DataManager()
        interactor = OBD2Interactor(dataManager: dataManager)
        interactor?.setupTransporterAndConnect()
    }

    func disconnect() {
        interactor?.disconnectAdapter()
    }
}
