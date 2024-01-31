//
//  SettingsViewController.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation
import UIKit

protocol SettingsViewControllerProtocol: AnyObject {
    
}

class SettingsViewController: UIViewController, SettingsViewControllerProtocol, UITableViewDelegate, UITableViewDataSource {
    let eventHandler: SettingsEventHandlerProtocol
    
    let tableViewCellFactory: TableViewCellFactoryType
    
    init(eventHandler: SettingsEventHandlerProtocol, tableViewCellFactory: TableViewCellFactoryType) {
        self.eventHandler = eventHandler
        self.tableViewCellFactory = tableViewCellFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let settingsOptions: [TableOption] = [
        TableOption(text: "About", image: "info.circle.fill"),
        TableOption(text: "Terms and Conditions", image: "newspaper.fill")
    ]
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let settingsLabel: UILabel = {
        let label = UILabel()
        label.text = "More Settings Coming Soon..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        view.addSubview(settingsLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            settingsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            settingsLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let roughCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let tableOption = settingsOptions[indexPath.row]
        
        let cell = tableViewCellFactory.styleCell(cell: roughCell, tableOption: tableOption)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            eventHandler.navigateToAbout()
        case 1:
            eventHandler.navigateToTerms()
        default:
            break
        }
    }
    
    
}

