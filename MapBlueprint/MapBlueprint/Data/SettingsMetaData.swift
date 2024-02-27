//
//  SettingsMetaData.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/13/24.
//

import Foundation

class SettingsMetaData {
    static let shared = SettingsMetaData()
    
    private let fuelTankLevelKey = "fuelTankLevelKey"
    
    var fuelTankCapacity: Double {
        get {
            return UserDefaults.standard.double(forKey: fuelTankLevelKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: fuelTankLevelKey)
        }
    }
    
    init() {
        
    }
}
