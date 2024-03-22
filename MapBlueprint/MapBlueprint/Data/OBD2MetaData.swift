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
        .Engine_Coolant_Temperature: PIDInfo(obdPID: .Engine_Coolant_Temperature, pid: "0x05", description: "Engine coolant temperature", units: "°F"),
        .Engine_Oil_Temperature: PIDInfo(obdPID: .Engine_Oil_Temperature, pid: "0x5C", description: "Engine oil temperature", units: "°F"),
        .Vehicle_Speed: PIDInfo(obdPID: .Vehicle_Speed, pid: "0x0D", description: "Vehicle speed", units: "km/h"),
        .Engine_RPM: PIDInfo(obdPID: .Engine_RPM, pid: "0x0C", description: "Engine RPM", units: "rpm"),
        .Fuel_Tank_Level_Input: PIDInfo(obdPID: .Fuel_Tank_Level_Input, pid: "0x2F", description: "Fuel Tank Level Input", units: "%"),
        .Control_Module_Voltage: PIDInfo(obdPID: .Control_Module_Voltage, pid: "0x42", description: "Control Module Voltage", units: "V"),
        .Ambient_Temperature: PIDInfo(obdPID: .Ambient_Temperature, pid: "0x46", description: "Ambient Air Temperature", units: "°F")

        // Add additional PIDs as needed
    ]
    
    static func getPIDInfo(for pid: OBDPID) -> PIDInfo? {
        return pidInfo[pid]
    }
}
/*
 
 All Compatible ELM 327 PID Codes
 0x01
 0x03
 0x04
 0x05
 0x06
 0x07
 0x0B
 0x0C
 0x0D
 0x0E
 0x0F
 0x10
 0x11
 0x13
 0x15
 0x1C
 0x1F
 0x20
 0x21
 0x23
 0x2E
 0x2F
 0x30
 0x31
 0x33
 0x34
 0x3C
 0x40
 0x41
 0x42
 0x43
 0x44
 0x45
 0x46
 0x47
 0x49
 0x4A
 0x4C
 0x51
 0x56
 0x5C

 */
