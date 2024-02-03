//
//  OBD2Interactor.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation
import OBD2

protocol OBD2InteractorProtocol: AnyObject {
    func connectToOBD2Scanner(completion: @escaping (Bool, String?) -> Void)
}

class OBD2Interactor: OBD2InteractorProtocol {
    let dataManager: OBD2DataManagerProtocol
    let obd: OBD2
    
    init(dataManager: OBD2DataManagerProtocol = OBD2DataManager(), obd: OBD2 = OBD2()) {
        self.dataManager = dataManager
        self.obd = obd
    }
    
    func connectToOBD2Scanner(completion: @escaping (Bool, String?) -> Void) {
        obd.connect { [weak self] success, error in
            if success {
                completion(true, nil) // Connection successful, no error message needed
            } else if let error = error {
                completion(false, error.localizedDescription) // Connection failed, provide the error message
            } else {
                completion(false, "An unknown error occurred.") // Connection failed, unknown error
            }
        }
    }}
