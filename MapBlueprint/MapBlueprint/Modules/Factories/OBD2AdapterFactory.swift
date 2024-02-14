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
import WatchConnectivity

class OBD2AdapterFactory: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
             print("WCSession error: \(error.localizedDescription)")
             return
         }
         print("WCSession activated: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
    }
    
    
    static let shared = OBD2AdapterFactory()
    
    var transporter: LTBTLESerialTransporter?
    var obd2Adapter: LTOBD2Adapter?
    weak var eventHandler: OBD2EventHandlerProtocol?
    
    var outgoingBytesNotification = UILabel()
    var incomingBytesNotification = UILabel()
    
    private var fuelLevelUpdateTimer: Timer?
    
    override init() {
        super.init()
        setupWatchConnection()
    }
     func setupWatchConnection() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
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
         print("Starting fuel level tracking")
         fuelLevelUpdateTimer?.invalidate()
         fuelLevelUpdateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
             guard let self = self else {
                 return
             }
             let fuelLevel = self.updateFuelLevel()
             self.sendFuelDataToWatch(fuelLevel: fuelLevel)
         }
     }

        func stopFuelLevelPolling() {
            print("END FUEL TRACK")
            fuelLevelUpdateTimer?.invalidate()
        }

    func updateFuelLevel() -> Double {
         var fuelLevel: Double = 0.0
         let semaphore = DispatchSemaphore(value: 0)

         guard let fuelPIDInfo = OBD2MetaData.getPIDInfo(for: .Fuel_Tank_Level_Input) else {
             return 0.0
         }

         fetchDataFor(pidInfo: fuelPIDInfo, completion: { rawValue in
             if let rawValue = rawValue, let hexValue = UInt8(rawValue, radix: 16) {
                 let fuelLevelPercentage = Double(hexValue) / 255.0 * 100.0
                 print("Fuel Level: \(fuelLevelPercentage)%")

                 let totalGallons = 13.7 // Change later to include app configurable max
                 fuelLevel = totalGallons * (fuelLevelPercentage / 100.0)
             } else {
                 print("Invalid or nil raw value received for fuel level.")
             }
             semaphore.signal()
         })

         semaphore.wait()
         return fuelLevel
     }
    
    func sendFuelDataToWatch(fuelLevel: Double) {
        let message = ["fuelLevel": fuelLevel, "maxFuelLevel": 13.7] // Change later to include app configurable max

        do {
            try WCSession.default.updateApplicationContext(message)
        } catch {
            print("Error sending fuel data to watch: \(error.localizedDescription)")
        }
    }

    }
