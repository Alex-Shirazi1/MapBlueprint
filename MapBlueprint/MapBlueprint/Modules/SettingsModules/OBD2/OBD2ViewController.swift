//
//  OBD2ViewContoller.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

// OBD2ViewController.swift

import UIKit

protocol OBD2ViewControllerProtocol: AnyObject {
    func updateConnectionStatus(isConnected: Bool)
}

class OBD2ViewController: UIViewController, OBD2ViewControllerProtocol {
    var eventHandler: OBD2EventHandlerProtocol?
    private let connectButton = UIButton()
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
        statusLabel.text = "Activating"
        eventHandler?.handleTransporterAndConnect()
    }

    func setupUI() {
        
        connectButton.setTitle("Manual Connect", for: .normal)
        connectButton.backgroundColor = .blue
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectButton)
        
       
        statusLabel.text = "Not Connected"
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
       
        NSLayoutConstraint.activate([
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            connectButton.widthAnchor.constraint(equalToConstant: 200),
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            
            statusLabel.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
        ])
        
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
    }

    @objc func connectButtonPressed() {
        statusLabel.text = "User Activating"
        eventHandler?.handleTransporterAndConnect()
    }


    func updateConnectionStatus(isConnected: Bool) {
        DispatchQueue.main.async {
            self.connectButton.isHidden = isConnected
            self.statusLabel.text = isConnected ? "Connected" : "Not Connected"
        }
    }
}

