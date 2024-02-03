//
//  OBD2ViewContoller.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation
import UIKit

protocol OBD2ViewControllerProtocol: AnyObject {
    func displayConnectionStatus(message: String)
}

class OBD2ViewController: UIViewController, OBD2ViewControllerProtocol {
    let eventHandler: OBD2EventHandlerProtocol
    private let connectButton = UIButton(type: .system)
    private let statusLabel = UILabel() // Declare a label to display the connection status

    init(eventHandler: OBD2EventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConnectButton()
        setupStatusLabel() // Setup the status label
    }

    private func setupStatusLabel() {
        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = .black
        statusLabel.textAlignment = .center
        statusLabel.text = "Not Connected" // Default text

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -20)
        ])
    }

    private func setupConnectButton() {
        connectButton.setTitle("Connect to OBD2", for: .normal)
        connectButton.addTarget(self, action: #selector(connectToOBD2Scanner), for: .touchUpInside)

        view.addSubview(connectButton)
        connectButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func connectToOBD2Scanner() {
        print("Attempting to connect to OBD2 scanner...")
        eventHandler.handleOBDConnection()
    }

    // Implement the displayConnectionStatus method to update the label text
    func displayConnectionStatus(message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = message
        }
    }
}
