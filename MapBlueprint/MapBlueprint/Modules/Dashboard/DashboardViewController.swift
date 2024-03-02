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
    var updateTimer: Timer?
    var scrollView = UIScrollView()
    var verticalStackView = UIStackView()
    let dialsPerRow = 2
    var maxFuelCapactity = SettingsMetaData.shared.fuelTankCapacity
    
    // Dials Init Lazy Loading
    lazy var coolantTempDial: DialView = {
        let dial = DialView(value: 0, minValue: 0, maxValue: 250, title: "Coolant", icon: UIImage(systemName: "snowflake") ?? UIImage())
        return dial
    }()
    
    lazy var oilTempDial: DialView = {
        let dial = DialView(value: 0,  minValue: 0, maxValue: 250, title: "Oil Temp", icon: UIImage(systemName: "oilcan.fill") ?? UIImage())
        return dial
    }()
    
    lazy var fuelLevelDial: DialView = {
        let dial = DialView(value: 0,  minValue: 0, maxValue: getMaxFuelTankCapacity(), title: "Fuel Level", icon: UIImage(systemName: "fuelpump.fill") ?? UIImage())
        return dial
    }()
    
    lazy var controlModuleVoltageDial: DialView = {
        let dial = DialView(value: 0,  minValue: 0, maxValue: 16, title: "Voltage", icon: UIImage(systemName: "minus.plus.batteryblock.fill") ?? UIImage())
        return dial
    }()
    
    lazy var rpmDial: DialView = {
        let dial = DialView(value: 0, minValue: 0, maxValue: 7000, title: "RPM", icon: UIImage(systemName: "engine.combustion.fill") ?? UIImage())
        return dial
    }()
    
    lazy var speedDial: DialView = {
        let dial = DialView(value: 0, minValue: 0, maxValue: 100, title: getSpeedUnits(), icon: UIImage(systemName: "car.2.fill") ?? UIImage())
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
        
        setupScrollView()
        setupDials(dials: [coolantTempDial, oilTempDial, fuelLevelDial, controlModuleVoltageDial, rpmDial, speedDial]) // Will be custom later when i add edit view/ selection view
        
        fetchDataAndUpdateUI()
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        scrollView.addSubview(verticalStackView)
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 50
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            verticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 50),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
    }
    
    func setupDials(dials: [DialView]) {
        // Iterate through the dials and add them to rows
        for (index, dial) in dials.enumerated() {
            let rowIndex = index / dialsPerRow
            if rowIndex >= verticalStackView.arrangedSubviews.count {
                // Create a new row if needed
                let rowStackView = createRowStackView()
                verticalStackView.addArrangedSubview(rowStackView)
            }
            if let rowStackView = verticalStackView.arrangedSubviews[rowIndex] as? UIStackView {
                // Add the dial to the appropriate row
                rowStackView.addArrangedSubview(dial)
            }
        }
    }
    
    func createRowStackView() -> UIStackView {
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.distribution = .fillEqually
        rowStackView.spacing = 10
        return rowStackView
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
                if let coolantTemp = data["coolantTemperature"] as? Double, let units = data["temperatureUnits"] as? String {
                    let refinedCoolantTemp = self.formatTemperature(coolantTemp)
                    if refinedCoolantTemp == -1 {
                        self.coolantTempDial.valueLabel.text = "--"
                    } else {
                        self.coolantTempDial.valueLabel.text = String(format: "%.2f \(units)", refinedCoolantTemp)
                        self.coolantTempDial.currentValue = refinedCoolantTemp
                    }
                }
                if let oilTemp = data["oilTemperature"] as? Double, let units = data["temperatureUnits"] as? String {
                    let refinedOilTemp = self.formatTemperature(oilTemp)
                    if refinedOilTemp == -1 {
                        self.oilTempDial.valueLabel.text = "--"
                    } else {
                        self.oilTempDial.valueLabel.text = String(format: "%.2f \(units)", refinedOilTemp)
                        self.oilTempDial.currentValue = refinedOilTemp
                    }
                }
                if let fuelLevel = data["fuelLevel"] as? Double, let maxFuelLevel = data["maxFuelLevel"] as? Double, let units = data["volumeUnits"] as? String {
                    if fuelLevel == -1 {
                        self.fuelLevelDial.valueLabel.text = "--"
                    } else {
                        if maxFuelLevel == 0 {
                            // If the max capacity is zero, display as a percentage
                            self.fuelLevelDial.valueLabel.text = String(format: "%.2f%%", fuelLevel)
                            self.maxFuelCapactity = 100
                        } else {
                            self.fuelLevelDial.valueLabel.text = String(format: "%.2f \(units)", fuelLevel)
                            self.maxFuelCapactity = maxFuelLevel
                        }
                        self.fuelLevelDial.maxValue = self.maxFuelCapactity
                        self.fuelLevelDial.currentValue = fuelLevel
                        self.checkFuelLevel(fuelLevel: fuelLevel)
                    }
                }
                if let voltage = data["controlModuleVoltage"] as? Double {
                    if voltage == -1 {
                        self.controlModuleVoltageDial.valueLabel.text = "--"
                    } else {
                        self.controlModuleVoltageDial.valueLabel.text = "\(voltage) V"
                        self.controlModuleVoltageDial.currentValue = voltage
                    }
                }
                if let rpm = data["engineRPM"] as? Double {
                    if rpm == -1 {
                        self.rpmDial.valueLabel.text = "--"
                    } else if rpm == 0 {
                        self.rpmDial.valueLabel.text = "Off"
                    }
                    else {
                        self.rpmDial.valueLabel.text = "\(Int(rpm))"
                        self.rpmDial.currentValue = rpm
                    }
                }
                if let speed = data["vehicleSpeed"] as? Double {
                    
                    self.speedDial.titleLabel.text = self.getSpeedUnits()
                    if speed == -1 {
                        self.speedDial.valueLabel.text = "--"
                    }
                    else {
                        self.speedDial.valueLabel.text = "\(Int(speed))"
                        self.speedDial.currentValue = speed
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
    // If we are low fuel, show user with updated Image, restore image if tank exceed low value
    private func checkFuelLevel(fuelLevel: Double) {
        if fuelLevel < 2.5 {
            let fuelImageLow = UIImage(systemName: "fuelpump.exclamationmark.fill") ?? UIImage()
            fuelLevelDial.alterImage(image: fuelImageLow)
        } else {
            let fuelImageGood = UIImage(systemName: "fuelpump.fill") ?? UIImage()
            fuelLevelDial.alterImage(image: fuelImageGood)
        }
    }
    private func getMaxFuelTankCapacity() -> Double {
        
        guard  self.maxFuelCapactity != 0 else {
            // Percentage is always out of 100, default to percentage if maxFuelLevel is undefined
            return 100
        }
        return self.maxFuelCapactity
        
    }
    private func getSpeedUnits() -> String {
        if SettingsMetaData.shared.speedUnits == .mph {
            return "MPH"
        } else {
            return "KMH"
        }
    }
}
