//
//  HomeInteractor.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation

protocol HomeInteractorProtocol: AnyObject {
    
}

class HomeInteractor: HomeInteractorProtocol {
    
    let dataManager: HomeDataManagerProtocol
    
    init(dataManager: HomeDataManagerProtocol = HomeDataManager()) {
        self.dataManager = dataManager
    }
}
