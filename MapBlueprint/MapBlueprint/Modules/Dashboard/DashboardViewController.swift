//
//  DashboardViewController.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/18/24.
//

import Foundation
import UIKit

protocol DashboardViewControllerProtocol: AnyObject {
    
}

class DashboardViewController: UIViewController, DashboardViewControllerProtocol {
    let eventHandler: DashboardEventHandlerProtocol
    var stackView =  UIStackView()
    var updateTimer: Timer?
    
    // Dials Init Lazy Loading
    lazy var coolantTempDial: DialView = {
        let dial = DialView(value: 0, title: "Coolant Temp", icon: UIImage(systemName: "snowflake") ?? UIImage())
        return dial
    }()
    
    lazy var oilTempDial: DialView = {
        let dial = DialView(value: 0, title: "Oil Temp", icon: UIImage(systemName: "oilcan.fill") ?? UIImage())
        return dial
    }()
    
    lazy var fuelLevelDial: DialView = {
        let dial = DialView(value: 0, title: "Fuel Level", icon: UIImage(systemName: "fuelpump.fill") ?? UIImage())
        return dial
    }()
    
    lazy var controlModuleVoltageDial: DialView = {
        let dial = DialView(value: 0, title: "Control Module Voltage", icon: UIImage(systemName: "minus.plus.batteryblock.fill") ?? UIImage())
        return dial
    }()
    
    init(eventHandler: DashboardEventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupDials()
        fetchDataAndUpdateUI()
    }
    
    func setupDials() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        stackView.addArrangedSubview(coolantTempDial)
        stackView.addArrangedSubview(oilTempDial)
        stackView.addArrangedSubview(fuelLevelDial)
        stackView.addArrangedSubview(controlModuleVoltageDial)
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdatingData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopUpdatingData()
    }

    private func startUpdatingData() {
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fetchDataAndUpdateUI), userInfo: nil, repeats: true)
    }

    private func stopUpdatingData() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    @objc func fetchDataAndUpdateUI() {
        Task {
            let data = await fetchData()
            
            DispatchQueue.main.async {
                if let coolantTemp = data["coolantTemperature"] as? Double {
                    let refinedCoolantTemp = self.formatTemperature(coolantTemp)
                    if refinedCoolantTemp == -1 {
                        self.coolantTempDial.valueLabel.text = "--"
                    } else {
                        self.coolantTempDial.valueLabel.text = String(format: "%.2f°F", refinedCoolantTemp)
                    }
                }
                if let oilTemp = data["oilTemperature"] as? Double {
                    let refinedOilTemp = self.formatTemperature(oilTemp)
                    if refinedOilTemp == -1 {
                        self.oilTempDial.valueLabel.text = "--"
                    } else {
                        self.oilTempDial.valueLabel.text = String(format: "%.2f°F", refinedOilTemp)
                    }
                }
                if let fuelLevel = data["fuelLevel"] as? Double {
                    if fuelLevel == -1 {
                        self.fuelLevelDial.valueLabel.text = "--"
                    } else {
                        self.checkFuelLevel(fuelLevel: fuelLevel)
                        self.fuelLevelDial.valueLabel.text = String(format: "%.2f G", fuelLevel)
                    }
                }
                if let voltage = data["controlModuleVoltage"] as? Double {
                    if voltage == -1 {
                        self.controlModuleVoltageDial.valueLabel.text = "--"
                    } else {
                        self.controlModuleVoltageDial.valueLabel.text = "\(voltage)V"
                    }
                }
            }
        }
    }

    private func fetchData() async -> [String: Any] {
        return await OBD2AdapterFactory.shared.fetchData()
    }
    
    // Removes Extranenous Values to temp
    private func formatTemperature(_ temperature: Double) -> Double {
        if temperature > 500 {
            return -1
        } else {
            return temperature
        }
    }
    // If we are low fuel, show user with updated Image
    private func checkFuelLevel(fuelLevel: Double) {
        if fuelLevel < 2.5 {
            let fuelImage = UIImage(systemName: "fuelpump.exclamationmark.fill") ?? UIImage()
            fuelLevelDial.alterImage(image: fuelImage)
        }
    }
}
