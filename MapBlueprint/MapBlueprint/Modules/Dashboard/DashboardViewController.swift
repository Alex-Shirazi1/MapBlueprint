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
    
    
    
    init(eventHandler: DashboardEventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
