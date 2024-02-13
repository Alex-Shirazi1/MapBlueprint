//
//  CarPlaySceneDelegate.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/12/24.
//

import Foundation
import CarPlay

class CarPlaySceneDelegate {
    let interfaceController: CPInterfaceController
    let carWindow: CPWindow
    
    init(interfaceController: CPInterfaceController, window: CPWindow) {
        self.interfaceController = interfaceController
        self.carWindow = window
    }
    
    func createCarPlayRootViewController() -> UIViewController {
        let rootTemplate = CPListTemplate(title: "Main Menu", sections: [])
        self.interfaceController.setRootTemplate(rootTemplate, animated: true)
        
        let viewController = UIViewController()
        return viewController
    }
}

