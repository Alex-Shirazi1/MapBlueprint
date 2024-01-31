//
//  HomeViewController.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation
import UIKit

protocol HomeViewControllerProtocol: AnyObject {
    
}

class HomeViewController: UIViewController, HomeViewControllerProtocol {
    let eventHandler: HomeEventHandlerProtocol
    
    
    
    init(eventHandler: HomeEventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
