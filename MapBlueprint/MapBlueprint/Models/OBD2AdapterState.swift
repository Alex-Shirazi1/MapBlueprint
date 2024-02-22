//
//  OBD2AdapterState.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/22/24.
//

import Foundation

enum OBD2AdapterState: String {
    case unknown = "OBD2AdapterStateUnknown"
    case notFound = "OBD2AdapterStateNotFound"
    case error = "OBD2AdapterStateError"
    case discovering = "OBD2AdapterStateDiscovering"
    case present = "OBD2AdapterStatePresent"
    case initializing = "OBD2AdapterStateInitializing"
    case ready = "OBD2AdapterStateReady"
    case ignitionOff = "OBD2AdapterStateIgnitionOff"
    case connected = "OBD2AdapterStateConnected"
    case unsupportedProtocol = "OBD2AdapterStateUnsupportedProtocol"
    case gone = "OBD2AdapterStateGone"
    
    var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .notFound:
            return "Not Found"
        case .error:
            return "Error"
        case .discovering:
            return "Discovering"
        case .present:
            return "present"
        case .initializing:
            return "Initializing"
        case .ready:
            return "Ready"
        case .ignitionOff:
            return "Ignition Off"
        case .connected:
            return "Connected"
        case .unsupportedProtocol:
            return "Unsupported Protocol"
        case .gone:
            return "Gone"
        default:
            return self.rawValue
        }
    }
}
