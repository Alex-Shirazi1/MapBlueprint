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
    
    let serverFactory = ServerFactory()
    
    
    private var updateTimer: Timer?
    
    override init() {
        serverFactory.testRoute()
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
    
    func fetchDataFor(pidInfo: PIDInfo, completion: @escaping (String?, Any?) -> Void) {
        guard let obd2Adapter = self.obd2Adapter else {
            print("Adapter not initialized")
            completion(nil, nil)
            return
        }
        
        let commandString = "01 " + pidInfo.pid.replacingOccurrences(of: "0x", with: "")
        let command = LTOBD2Command(string: commandString)
        
        obd2Adapter.transmitCommand(command) { response in
            let rawValueString = response.formattedResponse
            
            if rawValueString != "NO DATA", !rawValueString.contains("?") {
                let processedValue = self.processResponse(for: pidInfo, rawValue: rawValueString)
                completion(rawValueString, processedValue)
            } else {
                print("Error retrieving data for PID: \(pidInfo.pid)")
                completion(nil, nil)
            }
        }
    }
    func fetchDataForAsync(pidInfo: PIDInfo) async -> (String?, Any?) {
        guard let obd2Adapter = self.obd2Adapter else {
            print("Adapter not initialized")
            return (nil, nil)
        }
        
        let commandString = "01 " + pidInfo.pid.replacingOccurrences(of: "0x", with: "")
        let command = LTOBD2Command(string: commandString)
        
        // Convert the callback-based OBD2 command transmission into an async operation
        return await withCheckedContinuation { continuation in
            obd2Adapter.transmitCommand(command) { response in
                let rawValueString = response.formattedResponse
                
                if rawValueString != "NO DATA", !rawValueString.contains("?") {
                    let processedValue = self.processResponse(for: pidInfo, rawValue: rawValueString)
                    continuation.resume(returning: (rawValueString, processedValue))
                } else {
                    print("Error retrieving data for PID: \(pidInfo.pid)")
                    continuation.resume(returning: (nil, nil))
                }
            }
        }
    }
    
    
    private func processResponse(for pidInfo: PIDInfo, rawValue: String) -> Any? {
        // Processing logic based on PID type
        switch pidInfo.obdPID{
            
        case .Fuel_Tank_Level_Input:
            if let hexValue = UInt8(rawValue, radix: 16) {
                let fuelLevelPercentage = Double(hexValue) / 255.0 * 100.0
                return fuelLevelPercentage
            }
            
        case .Engine_Oil_Temperature:
            return hexStringToDouble(hexString: rawValue)
            
        case .Engine_Coolant_Temperature:
            // Used to simplify Coolant Raw Data bc the response for Coolant from the adapter is stupid
            let refinedRawData = rawValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.first ?? ""
            return hexStringToDouble(hexString: refinedRawData)
        case .Control_Module_Voltage:
            let refinedRawData = rawValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.first ?? ""
            return hexStringToDouble(hexString: refinedRawData)
        case .Engine_RPM:
            return handleRPMValue(rawValue: rawValue)
        case .Vehicle_Speed:
            return handleVehicleSpeed(rawValue: rawValue)
            
            // TODO add others in terms of processing PIDS
        default:
            return nil
        }
        return nil
    }
    
    func getStatus() -> OBD2AdapterState {
        guard let stateString = obd2Adapter?.friendlyAdapterState else {
            return .unknown
        }
        return OBD2AdapterState(rawValue: stateString) ?? .unknown
    }
    
    
    @objc private func adapterDidConnect(notification: Notification) {
    }
    
    @objc private func adapterDidDisconnect(notification: Notification) {
    }
    
    @objc private func adapterDidUpdateState(_ notification: Notification) {
        let state = getStatus()
        DispatchQueue.main.async {
            self.eventHandler?.adapterDidConnect(status: state)
            self.startAllDataPolling()
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
        obd2Adapter?.disconnect()
        transporter?.disconnect()
    }
    func convertCelsiusToFahrenheit(celsius: Double) -> Double {
        
        return celsius * 9 / 5 + 32
    }
    func hexStringToDouble(hexString: String) -> Double? {
        let cleanHexString = hexString.filter { "0123456789ABCDEFabcdef".contains($0) }
        
        guard let decimalValue = UInt64(cleanHexString, radix: 16) else {
            return nil
        }
        return Double(decimalValue)
    }
    
    func processTemperature(temperature: Double) -> Double {
        let calculatedTemperature = temperature * 9 / 5 - 39.5
        
        switch SettingsMetaData.shared.temperatureUnits {
        case .fahrenheit:
            return calculatedTemperature
        case .celsius:
            return convertFahrenheitToCelsius(fahrenheit: calculatedTemperature)
        }
    }
}

extension OBD2AdapterFactory {
    // MARK: - Unified Data Fetching and Sending
    
    func startAllDataPolling(interval: TimeInterval = 1.0) {
        print("begin data tracking")
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                let vehicleData = await self.fetchData()
                self.serverFactory.sendVehicleData(vehicleData)
                self.sendDataToWatch(vehicleData)
            }
        }
    }
    
    func fetchData() async -> VehicleData {
        let fuelLevel = await updateFuelLevelAsync()
        let coolantTemperature = await updateCoolantTemperatureAsync()
        let oilTemperature = await updateOilTemperatureAsync()
        let controlModuleVoltage = await updateControlModuleVoltageAsync()
        let engineRPM = await updateEngineRPMAsync()
        let vehicleSpeed = await updateVehicleSpeedAsync()
        let temperatureUnits = handleTemperatureUnits()
        let volumeUnits = handleVolumeUnits()
        
        return VehicleData(
                    _id: "bmwf23",
                    fuelLevel: fuelLevel,
                    maxFuelLevel: SettingsMetaData.shared.fuelTankCapacity,
                    coolantTemperature: coolantTemperature,
                    oilTemperature: oilTemperature,
                    controlModuleVoltage: controlModuleVoltage,
                    engineRPM: engineRPM,
                    vehicleSpeed: vehicleSpeed,
                    temperatureUnits: temperatureUnits,
                    volumeUnits: volumeUnits
                )
    }
    
    func sendDataToWatch(_ vehicleData: VehicleData) {
        do {
            let data = try JSONEncoder().encode(vehicleData)
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                try WCSession.default.updateApplicationContext(jsonObject)
            }
            print("All data sent to watch successfully. observe: \(vehicleData)")
        } catch {
            print("Error sending all data to watch: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fuel Level
    
    func updateFuelLevelAsync() async -> Double {
        guard let fuelPIDInfo = OBD2MetaData.getPIDInfo(for: .Fuel_Tank_Level_Input) else {
            print("Invalid PIDInfo for fuel level.")
            return -1
        }
        
        let (_, processedValue) = await fetchDataForAsync(pidInfo: fuelPIDInfo)
        guard let fuelLevelPercentage = processedValue as? Double else {
            print("Invalid or nil raw value received for fuel level.")
            return -1
        }
        
        let fuelTankCapacity = SettingsMetaData.shared.fuelTankCapacity
        
        guard fuelTankCapacity != 0 else {
            // If fuel Tank Capacity is not set show percentage
            return fuelLevelPercentage
        }
        return fuelTankCapacity * (fuelLevelPercentage / 100.0)
    }
    
    // MARK: - Coolant Temperature
    
    func updateCoolantTemperatureAsync() async -> Double {
        guard let coolantPIDInfo = OBD2MetaData.getPIDInfo(for: .Engine_Coolant_Temperature) else {
            print("Invalid PIDInfo for Coolant Temperature.")
            return -1
        }
        
        let (_, processedValue) = await fetchDataForAsync(pidInfo: coolantPIDInfo)
        guard let coolantTemperature = processedValue as? Double else {
            print("Invalid or nil raw value received for coolant temperature.")
            return -1
        }
        return processTemperature(temperature: coolantTemperature)
    }
    
    // MARK: - Oil Temperature
    
    func updateOilTemperatureAsync() async -> Double {
        guard let oilPIDInfo = OBD2MetaData.getPIDInfo(for: .Engine_Oil_Temperature) else {
            print("Invalid PIDInfo for oil Temperature.")
            return -1
        }
        
        let (_, processedValue) = await fetchDataForAsync(pidInfo: oilPIDInfo)
        guard let oilTemperature = processedValue as? Double else {
            print("Invalid or nil raw value received for oil temperature.")
            return -1
        }
        
        return processTemperature(temperature: oilTemperature)
    }
    
    func updateControlModuleVoltageAsync() async -> Double {
        guard let controlModuleVoltagePIDInfo = OBD2MetaData.getPIDInfo(for: .Control_Module_Voltage) else {
            print("Invalid PIDInfo for control module voltage.")
            return -1
        }
        
        let (_, processedValue) = await fetchDataForAsync(pidInfo: controlModuleVoltagePIDInfo)
        guard let milliVolts = processedValue as? Double else {
            print("Invalid or nil raw value received for oil temperature.")
            return -1
        }
        
        return milliVolts/1000 // Converts to Volts
        
    }
    
    
    
    func updateEngineRPMAsync() async -> Int {
        // Fetch data for the engine RPM PID
        guard let rpmPIDInfo = OBD2MetaData.getPIDInfo(for: .Engine_RPM) else {
            print("Invalid PIDInfo for engine RPM.")
            return -1
        }
        let (_, processedValue) = await fetchDataForAsync(pidInfo: rpmPIDInfo)
        
        guard let rpm = processedValue as? Double else {
            return -1
        }
        return Int(rpm)
    }
    
    func handleRPMValue(rawValue: String?) -> Double {
        guard let rawValue = rawValue, rawValue != "No data" else {
            print("engine no data")
            return -1
        }
        
        if rawValue == "0000, 0000" {
            print("engine off")
            return 0
        }
        let hexValues = rawValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var totalRPM: Double = 0
        hexValues.forEach { hexValue in
            guard let res = UInt64(hexValue, radix: 16) else {
                return
            }
            totalRPM = totalRPM + Double(res)/4
        }
        let average = totalRPM/Double(hexValues.count)
        return average
    }
    func updateVehicleSpeedAsync() async -> Int {
        guard let speedPIDInfo = OBD2MetaData.getPIDInfo(for: .Vehicle_Speed) else {
            print("Invalid PIDInfo for car speed")
            return -1
        }
        
        let (_, processedValue) = await fetchDataForAsync(pidInfo: speedPIDInfo)
        
        guard let vehicleSpeed = processedValue as? Double else {
            return -1
        }
        return Int(vehicleSpeed)
    }
    func handleVehicleSpeed(rawValue: String?) -> Double {
        guard let rawValue = rawValue, rawValue != "No data" else {
            print("Not connected")
            return -1
        }
        
        let speedValues = rawValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        var totalSpeed: Double = 0
        speedValues.forEach { hexValue in
            guard let speed = UInt64(hexValue, radix: 16) else {
                return
            }
            totalSpeed = totalSpeed + Double(speed)
        }
        
        let averageSpeed = totalSpeed / Double(speedValues.count)
        
        // Convert To MPH if we want MPH as units
        if SettingsMetaData.shared.speedUnits == .mph {
            return convertKmhToMph(kmh: averageSpeed)
        } else {
            // Adapter Default is KMH
            return averageSpeed
        }
    }
    
    func handleTemperatureUnits() -> String {
        switch SettingsMetaData.shared.temperatureUnits {
        case .fahrenheit:
            return "°F"
        case .celsius:
            return "°C"
        }
    }
    
    func handleVolumeUnits() -> String {
        switch SettingsMetaData.shared.volumeUnits {
        case .gallons:
            return "G"
        case .liters:
            return "L"
        }
    }
    
    func celsiusToFahrenheit(celsius: Double) -> Double {
        return (celsius * 9/5) + 32
    }
    
    func convertFahrenheitToCelsius(fahrenheit: Double) -> Double {
        return (fahrenheit - 32) * 5/9
    }
    func convertKmhToMph(kmh: Double) -> Double {
        return kmh * 0.621371
    }
    
}

