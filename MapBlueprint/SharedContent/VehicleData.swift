//
//  VehicleData.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 3/3/24.
//

import Foundation

struct VehicleData: Codable {
    // Data
    var _id: String
    var fuelLevel: Double
    var maxFuelLevel: Double
    var coolantTemperature: Double
    var oilTemperature: Double
    var controlModuleVoltage: Double
    var engineRPM: Int
    var vehicleSpeed: Int
    
    // Units associated with data
    var temperatureUnits: String
    var volumeUnits: String
    
    private enum CodingKeys: String, CodingKey {
        case controlModuleVoltage, coolantTemperature, engineRPM, fuelLevel, maxFuelLevel, oilTemperature, temperatureUnits, vehicleSpeed, volumeUnits, _id
    }
}
