//
//  OBD2Interactor.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation

protocol OBD2InteractorProtocol: AnyObject {
    
}

class OBD2Interactor: OBD2InteractorProtocol {
    let dataManager: OBD2DataManagerProtocol
    
    init(dataManager: OBD2DataManagerProtocol = OBD2DataManager()) {
        self.dataManager = dataManager
    }
}
