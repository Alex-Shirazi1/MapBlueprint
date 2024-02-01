//
//  ConnectViewController.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation
import UIKit

protocol ConnectViewControllerProtocol: AnyObject {
    
}

class ConnectViewController: UIViewController, ConnectViewControllerProtocol {
    let eventHandler: ConnectEventHandlerProtocol
    
    
    
    init(eventHandler: ConnectEventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

