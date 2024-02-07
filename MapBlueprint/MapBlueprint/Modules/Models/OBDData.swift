//
//  OBDData.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/7/24.
//

import Foundation


class OBDData {
    static let pidInfo: [OBDPID: PIDInfo] = [
        .Engine_Coolant_Temperature: PIDInfo(pid: "0x05", description: "Engine coolant temperature", units: "°C"),
        .Engine_Oil_Temperature: PIDInfo(pid: "0x5C", description: "Engine oil temperature", units: "°C"),
        .Vehicle_Speed: PIDInfo(pid: "0x0D", description: "Vehicle speed", units: "km/h"),
        .Engine_RPM: PIDInfo(pid: "0x0C", description: "Engine RPM", units: "rpm"),
        .Fuel_Tank_Level_Input: PIDInfo(pid: "0x2F", description: "Fuel Tank Level Input", units: "%")
        // Add additional PIDs as needed
    ]
    
    static func getPIDInfo(for pid: OBDPID) -> PIDInfo? {
        return pidInfo[pid]
    }
}


