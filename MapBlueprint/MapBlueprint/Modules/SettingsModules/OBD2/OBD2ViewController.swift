//
//  OBD2ViewContoller.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

// OBD2ViewController.swift

import UIKit

protocol OBD2ViewControllerProtocol: AnyObject {
    func updateConnectionStatus(status: String)
}

class OBD2ViewController: UIViewController, OBD2ViewControllerProtocol {
    var eventHandler: OBD2EventHandlerProtocol?
    private let connectButton = UIButton()
    private let disconnectButton = UIButton()
    private let statusLabel = UILabel()
    
    
    init(eventHandler: OBD2EventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    func updateConnectionStatus(status: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = status
            let isConnected = status == "OBD2AdapterStateConnected"
            self.connectButton.isHidden = isConnected
            self.disconnectButton.isHidden = !isConnected
        }
    }

    
    func setupUI() {
        
        
        connectButton.setTitle("Manual Connect", for: .normal)
        connectButton.backgroundColor = .blue
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectButton)
        
        disconnectButton.setTitle("Disconnect", for: .normal)
        disconnectButton.backgroundColor = .red
        disconnectButton.translatesAutoresizingMaskIntoConstraints = false
        disconnectButton.isHidden = true
        view.addSubview(disconnectButton)
        
        statusLabel.text = "Loading..."
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        
        NSLayoutConstraint.activate([
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            connectButton.widthAnchor.constraint(equalToConstant: 200),
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            
            disconnectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            disconnectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            disconnectButton.widthAnchor.constraint(equalToConstant: 200),
            disconnectButton.heightAnchor.constraint(equalToConstant: 50),
            statusLabel.topAnchor.constraint(equalTo: disconnectButton.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
        ])
        
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        disconnectButton.addTarget(self, action: #selector(disconnectButtonPressed), for: .touchUpInside)
        
    }
    
    @objc func connectButtonPressed() {
        statusLabel.text = "User Activating"
        eventHandler?.handleTransporterAndConnect()
    }
    @objc func disconnectButtonPressed() {
        eventHandler?.handleDisconnect()
        self.connectButton.isHidden = false
        self.disconnectButton.isHidden = true
    }
    
    

}

