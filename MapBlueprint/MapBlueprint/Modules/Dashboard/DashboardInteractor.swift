//
//  DashboardInteractor.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/18/24.
//

import Foundation

protocol DashboardInteractorProtocol: AnyObject {
    
}

class DashboardInteractor: DashboardInteractorProtocol {
    
    let dataManager: DashboardDataManagerProtocol
    
    init(dataManager: DashboardDataManagerProtocol = DashboardDataManager()) {
        self.dataManager = dataManager
    }
}
