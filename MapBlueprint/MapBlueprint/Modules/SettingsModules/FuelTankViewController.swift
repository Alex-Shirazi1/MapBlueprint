//
//  FuelTankViewController.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/27/24.
//

import Foundation
import UIKit

class FuelTankViewController: UIViewController {
    
    private let fuelTanklabel = UILabel()
    private let textField = UITextField()
    private let saveButton = UIButton()
    private let fyiLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        
        view.backgroundColor = .systemBackground
        
        fuelTanklabel.text = "Fuel Tank Capacity"
        fuelTanklabel.translatesAutoresizingMaskIntoConstraints = false
        
        if SettingsMetaData.shared.fuelTankCapacity != 0.0 {
            textField.placeholder = "\(SettingsMetaData.shared.fuelTankCapacity)"
        } else {
            textField.placeholder = "Enter fuel tank capacity"
        }
        
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .blue
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveFuelLevel), for: .touchUpInside)
        
        fyiLabel.text = "Note: \n If no fuel tank capacity is defined,\n or if the fuel tank capacity is set to 0, \n fuel data will be displayed as a percentage"
        fyiLabel.numberOfLines = 0
        fyiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(fuelTanklabel)
        view.addSubview(textField)
        view.addSubview(saveButton)
        view.addSubview(fyiLabel)
        
        NSLayoutConstraint.activate([
            fuelTanklabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            fuelTanklabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: fuelTanklabel.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            fyiLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            fyiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func saveFuelLevel() {
        guard let fuelTankCapacityText = textField.text, let fuelTankCapacity = Double(fuelTankCapacityText)  else {
            print("Invalid input. Please enter a valid number.")
            return
        }
        SettingsMetaData.shared.fuelTankCapacity = fuelTankCapacity
        print("Fuel tank level saved: \(fuelTankCapacity)")
        view.endEditing(true)
    }
}

