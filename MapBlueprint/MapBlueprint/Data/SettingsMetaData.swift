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
    var temperatureUnits: TemperatureUnitType {
        get {
            let unitString = UserDefaults.standard.string(forKey: "temperatureUnitKey") ?? TemperatureUnitType.fahrenheit.rawValue
            return TemperatureUnitType(rawValue: unitString) ?? .fahrenheit
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "temperatureUnitKey")
        }
    }

    var volumeUnits: VolumeUnitType {
        get {
            let unitString = UserDefaults.standard.string(forKey: "volumeUnitKey") ?? VolumeUnitType.gallons.rawValue
            return VolumeUnitType(rawValue: unitString) ?? .gallons
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "volumeUnitKey")
        }
    }

    init() {
        
    }
}

