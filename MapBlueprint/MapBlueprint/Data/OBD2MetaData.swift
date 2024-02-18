//
//  OBD2MetaData.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/7/24.
//

import Foundation
import LTSupportAutomotive

struct OBD2MetaData {
    static let UUIDs = [
        CBUUID(string: "18F0")
    ]
    
    static let commandSupport = "ELM237"
    
    static let pidInfo: [OBDPID: PIDInfo] = [
        .Engine_Coolant_Temperature: PIDInfo(obdPID: .Engine_Coolant_Temperature, pid: "0x05", description: "Engine coolant temperature", units: "°C"),
        .Engine_Oil_Temperature: PIDInfo(obdPID: .Engine_Oil_Temperature, pid: "0x5C", description: "Engine oil temperature", units: "°C"),
        .Vehicle_Speed: PIDInfo(obdPID: .Vehicle_Speed, pid: "0x0D", description: "Vehicle speed", units: "km/h"),
        .Engine_RPM: PIDInfo(obdPID: .Engine_RPM, pid: "0x0C", description: "Engine RPM", units: "rpm"),
        .Fuel_Tank_Level_Input: PIDInfo(obdPID: .Fuel_Tank_Level_Input, pid: "0x2F", description: "Fuel Tank Level Input", units: "%")
        // Add additional PIDs as needed
    ]
    
    static func getPIDInfo(for pid: OBDPID) -> PIDInfo? {
        return pidInfo[pid]
    }
}
