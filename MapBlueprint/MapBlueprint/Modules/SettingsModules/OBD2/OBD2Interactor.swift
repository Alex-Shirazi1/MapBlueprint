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
    var eventHandler: OBD2EventHandlerProtocol? { get set }
    func setupTransporterAndConnect()
    func disconnectAdapter()
}

class OBD2Interactor: OBD2InteractorProtocol {
    let dataManager: OBD2DataManagerProtocol
    var transporter: LTBTLESerialTransporter?
    var obd2Adapter: LTOBD2Adapter?
    weak var eventHandler: OBD2EventHandlerProtocol?
    
    var outgoingBytesNotification = UILabel()
    var incomingBytesNotification = UILabel()
    
    init(dataManager: OBD2DataManagerProtocol = OBD2DataManager()) {
        self.dataManager = dataManager
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

    @objc private func adapterDidConnect(notification: Notification) {

    }

    @objc private func adapterDidUpdateState(_ notification: Notification) {
        guard let adapterState = obd2Adapter?.friendlyAdapterState else { return
        }
        DispatchQueue.main.async {
            self.eventHandler?.adapterDidConnect(status: adapterState)
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
}
