//
//  OBD2Interactor.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation
import UIKit
import CoreBluetooth
import LTSupportAutomotive

protocol OBD2InteractorProtocol: AnyObject {
    func setupTransporterAndConnect()
}

class OBD2Interactor: OBD2InteractorProtocol {
    var transporter: LTBTLESerialTransporter?
    var obd2Adapter: LTOBD2Adapter?
    
    weak var eventHandler: OBD2EventHandlerProtocol?

    func setupTransporterAndConnect() {
        transporter = LTBTLESerialTransporter(identifier: nil, serviceUUIDs: OBD2MetaData.UUIDs)
        transporter?.connect { [weak self] (inputStream, outputStream) in
            guard let self = self, let inputStream = inputStream, let outputStream = outputStream else {
                print("Could not connect to OBD2 adapter")
                return
            }
            
            self.obd2Adapter = LTOBD2AdapterELM327(inputStream: inputStream, outputStream: outputStream)
            self.obd2Adapter?.connect()
            self.adapterDidConnect()
        }
    }

    @objc private func adapterDidConnect() {
        if let stateRawValue = obd2Adapter?.adapterState.rawValue {
            print("Adapter state raw value: \(stateRawValue)")
            if stateRawValue == 8 {
                eventHandler?.adapterDidConnect()
            } else {
                print("Adapter is not in the 'Connected' state. Current state: \(stateRawValue)")
            }
        } else {
            print("Could not retrieve adapter state.")
        }
    }

}
