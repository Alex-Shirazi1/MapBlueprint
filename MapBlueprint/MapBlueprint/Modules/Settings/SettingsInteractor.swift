//
//  SettingsInteractor.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation

protocol SettingsInteractorProtocol: AnyObject {
    
}

class SettingsInteractor: SettingsInteractorProtocol {
    let dataManager: SettingsDataManagerProtocol
    
    init(dataManager: SettingsDataManagerProtocol = SettingsDataManager()) {
        self.dataManager = dataManager
    }
}
