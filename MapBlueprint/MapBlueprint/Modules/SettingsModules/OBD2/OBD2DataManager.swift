//
//  OBD2DataManager.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation

protocol OBD2DataManagerProtocol: AnyObject {
    func connect()
    func getStatus() -> OBD2AdapterState
    func disconnect()
}

class OBD2DataManager: OBD2DataManagerProtocol {
    
    private let factory: OBD2AdapterFactory
    
    init(factory: OBD2AdapterFactory = .shared) {
        self.factory = factory
    }
    
    func connect() {
        factory.setupTransporterAndConnect()
    }
    func getStatus() -> OBD2AdapterState {
        factory.getStatus()
    }
    
    func disconnect() {
        factory.disconnectAdapter()
    }
}


