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
    func getStatus() -> String
    func disconnectAdapter()
}

class OBD2Interactor: OBD2InteractorProtocol {
    
    static let shared = OBD2Interactor()
    
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
        dataManager.connect()
        }
    
    func getStatus() -> String {
        dataManager.getStatus()
    }
    
    func disconnectAdapter() {
        dataManager.disconnect()
    }
}

