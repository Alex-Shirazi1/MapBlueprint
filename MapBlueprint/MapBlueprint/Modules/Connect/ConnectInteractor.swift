//
//  ConnectInteractor.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation

protocol ConnectInteractorProtocol: AnyObject {
    
}

class ConnectInteractor: ConnectInteractorProtocol {
    
    let dataManager: ConnectDataManagerProtocol
    
    init(dataManager: ConnectDataManagerProtocol = ConnectDataManager()) {
        self.dataManager = dataManager
    }
}
