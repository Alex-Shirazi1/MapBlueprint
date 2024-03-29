//
//  UnitsViewController.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/27/24.
//

import Foundation
import UIKit

class UnitsViewController: UIViewController {
    
    private let temperatureLabel = UILabel()
    private let volumeLabel = UILabel()
    private let speedLabel = UILabel()
    
    private let temperatureSegmentedControl = UISegmentedControl(items: [TemperatureUnitType.fahrenheit.rawValue, TemperatureUnitType.celsius.rawValue])
    private let volumeSegmentedControl = UISegmentedControl(items: [VolumeUnitType.gallons.rawValue, VolumeUnitType.liters.rawValue])
    private let speedSegmentedControl = UISegmentedControl(items: [SpeedUnitType.mph.rawValue, SpeedUnitType.kmh.rawValue])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        setup()
    }
    
    func setup() {
        view.backgroundColor = .systemBackground
        
        temperatureLabel.text = "Temperature"
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        volumeLabel.text = "Volume"
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        speedLabel.text = "Speed"
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        temperatureSegmentedControl.selectedSegmentIndex = SettingsMetaData.shared.temperatureUnits == .fahrenheit ? 0 : 1
        temperatureSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        temperatureSegmentedControl.addTarget(self, action: #selector(temperatureUnitChanged), for: .valueChanged)
        
        
        volumeSegmentedControl.selectedSegmentIndex = SettingsMetaData.shared.volumeUnits == .gallons ? 0 : 1
        volumeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        volumeSegmentedControl.addTarget(self, action: #selector(volumeUnitChanged), for: .valueChanged)
        
        speedSegmentedControl.selectedSegmentIndex = SettingsMetaData.shared.speedUnits == .mph ? 0 : 1
        speedSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        speedSegmentedControl.addTarget(self, action: #selector(speedUnitChanged), for: .valueChanged)
        
        view.addSubview(temperatureLabel)
        view.addSubview(volumeLabel)
        view.addSubview(speedLabel)
        view.addSubview(temperatureSegmentedControl)
        view.addSubview(volumeSegmentedControl)
        view.addSubview(speedSegmentedControl)
        
        NSLayoutConstraint.activate([
            temperatureLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            temperatureLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            temperatureLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            temperatureSegmentedControl.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            temperatureSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            temperatureSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            volumeLabel.topAnchor.constraint(equalTo: temperatureSegmentedControl.bottomAnchor, constant: 20),
            volumeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            volumeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            volumeSegmentedControl.topAnchor.constraint(equalTo: volumeLabel.bottomAnchor, constant: 8),
            volumeSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            volumeSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            
            speedLabel.topAnchor.constraint(equalTo: volumeSegmentedControl.bottomAnchor, constant: 20),
            speedLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            speedLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            speedSegmentedControl.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 8),
            speedSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            speedSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
            
            
            
            
        ])
    }
    
    @objc private func temperatureUnitChanged(_ sender: UISegmentedControl) {
        let selectedUnits = sender.selectedSegmentIndex == 0 ? TemperatureUnitType.fahrenheit : TemperatureUnitType.celsius
        SettingsMetaData.shared.temperatureUnits = selectedUnits
    }
    
    @objc private func volumeUnitChanged(_ sender: UISegmentedControl) {
        let selectedUnits = sender.selectedSegmentIndex == 0 ? VolumeUnitType.gallons : VolumeUnitType.liters
        SettingsMetaData.shared.volumeUnits = selectedUnits
        
        switch selectedUnits {
        case .gallons:
            SettingsMetaData.shared.fuelTankCapacity = SettingsMetaData.shared.fuelTankCapacity / 3.78541
        case .liters:
            SettingsMetaData.shared.fuelTankCapacity = SettingsMetaData.shared.fuelTankCapacity * 3.78541
        }
    }
    
    @objc private func speedUnitChanged(_ sender: UISegmentedControl) {
        let selectedUnits = sender.selectedSegmentIndex == 0 ? SpeedUnitType.mph : SpeedUnitType.kmh
        SettingsMetaData.shared.speedUnits = selectedUnits
    }
    
}
