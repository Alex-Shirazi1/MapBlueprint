//
//  OBD2AdapterFactory.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/13/24.
//

import Foundation
import UIKit
import CoreBluetooth
import LTSupportAutomotive
import WidgetKit

class OBD2AdapterFactory {
    
    static let shared = OBD2AdapterFactory()
    
    var transporter: LTBTLESerialTransporter?
    var obd2Adapter: LTOBD2Adapter?
    weak var eventHandler: OBD2EventHandlerProtocol?
    
    var outgoingBytesNotification = UILabel()
    var incomingBytesNotification = UILabel()
    
    private var fuelLevelUpdateTimer: Timer?
    
    
    func setupTransporterAndConnect() {
        transporter = LTBTLESerialTransporter(identifier: nil, serviceUUIDs: OBD2MetaData.UUIDs)
        transporter?.connect { [weak self] (inputStream, outputStream) in
            guard let self = self, let inputStream = inputStream, let outputStream = outputStream else {
                print("Could not connect to OBD2 adapter")
                return
            }
            self.obd2Adapter = LTOBD2AdapterELM327(inputStream: inputStream, outputStream: outputStream)
            NotificationCenter.default.addObserver(self, selector: #selector(self.adapterDidConnect), name: NSNotification.Name("LTOBD2AdapterDidConnect"), object: self.obd2Adapter)
            self.obd2Adapter?.connect()
            configureNotifications()
        }
    }
    
    func fetchDataFor(pidInfo: PIDInfo, completion: @escaping (String?) -> Void) {
        guard let obd2Adapter = self.obd2Adapter else {
            print("Adapter not initialized")
            completion(nil)
            return
        }

        let commandString = "01 " + pidInfo.pid.replacingOccurrences(of: "0x", with: "")
        let command = LTOBD2Command(string: commandString)

        obd2Adapter.transmitCommand(command) { response in
            let rawValueString = response.formattedResponse
            
            
            if rawValueString != "NO DATA", !rawValueString.contains("?") {
                completion(rawValueString)
            } else {
                print("Error retrieving data for PID: \(pidInfo.pid)")
                completion(nil)
            }
        }
    }


    
    func getStatus() -> String {
         if let adapterState = obd2Adapter?.friendlyAdapterState {
             return adapterState
         } else {
             return "Unknown State"
         }
     }
    
    @objc private func adapterDidConnect(notification: Notification) {
    }   
    
    @objc private func adapterDidDisconnect(notification: Notification) {
    }
    
    @objc private func adapterDidUpdateState(_ notification: Notification) {
        let state = getStatus()
        DispatchQueue.main.async {
            self.eventHandler?.adapterDidConnect(status: state)
            self.startFuelLevelPolling()
        }
    }
    
    
    @objc private func transporterDidUpdateSignalStrength(_ notification: Notification) {
        if let signalStrength = transporter?.signalStrength {
            print("Device Signal Strength \(signalStrength)")
        }
    }
    @objc private func adapterDidSendBytes(_ notification: Notification) {
        print("Adapter did send bytes.")
        DispatchQueue.main.async {
            self.outgoingBytesNotification.alpha = 1.0
            UIView.animate(withDuration: 0.15) {
                self.outgoingBytesNotification.alpha = 0.3
            }
        }
    }
    
    @objc private func adapterDidReceiveBytes(_ notification: Notification) {
        print("Adapter did receive bytes.")
        DispatchQueue.main.async {
            self.incomingBytesNotification.alpha = 1.0
            UIView.animate(withDuration: 0.15) {
                self.incomingBytesNotification.alpha = 0.3
            }
        }
    }
    
    private func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adapterDidUpdateState(_:)), name: NSNotification.Name(LTOBD2AdapterDidUpdateState), object: obd2Adapter)
        NotificationCenter.default.addObserver(self, selector: #selector(transporterDidUpdateSignalStrength(_:)), name: NSNotification.Name(LTBTLESerialTransporterDidUpdateSignalStrength), object: transporter)
        NotificationCenter.default.addObserver(self, selector: #selector(adapterDidSendBytes(_:)), name: NSNotification.Name(LTOBD2AdapterDidSend), object: obd2Adapter)
        NotificationCenter.default.addObserver(self, selector: #selector(adapterDidReceiveBytes(_:)), name: NSNotification.Name(LTOBD2AdapterDidReceive), object: obd2Adapter)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func disconnectAdapter() {
        self.stopFuelLevelPolling()
        obd2Adapter?.disconnect()
        transporter?.disconnect()
    }
}


extension OBD2AdapterFactory {
     

        func startFuelLevelPolling(interval: TimeInterval = 5.0) {
            print("LOLZZ BEGIN FUEL TRACK")
            fuelLevelUpdateTimer?.invalidate()
            fuelLevelUpdateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.updateFuelLevelForComplication()
            }
        }

        func stopFuelLevelPolling() {
            print("LOLZZ END FUEL TRACK")
            fuelLevelUpdateTimer?.invalidate()
        }

        private func updateFuelLevelForComplication() {
                guard let fuelPIDInfo = OBD2MetaData.getPIDInfo(for: .Fuel_Tank_Level_Input) else {
                    return
                }

            fetchDataFor(pidInfo: fuelPIDInfo, completion: { [weak self] rawValue in
                if let rawValue = rawValue, let hexValue = UInt8(rawValue, radix: 16) {
                    let fuelLevelPercentage = Double(hexValue) / 255.0 * 100.0
                    print("Fuel Level: \(fuelLevelPercentage)%")

                    let totalGallons = 13.0 // TODO - Make settings configurable such we can define the tank size
                    let gallonsLeft = totalGallons * (fuelLevelPercentage / 100.0)

                  
                    let defaults = UserDefaults(suiteName: "group.shirazi")
                    defaults?.set(gallonsLeft, forKey: "fuelLevelGallons")

                    WidgetCenter.shared.reloadAllTimelines()
                } else {
                    print("Invalid or nil raw value received for fuel level.")
                }
            })
        }

    }
