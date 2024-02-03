//
//  OBD2ViewContoller.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/3/24.
//

import Foundation
import UIKit

protocol OBD2ViewControllerProtocol: AnyObject {
    
}

class OBD2ViewController: UIViewController, OBD2ViewControllerProtocol {
    let eventHandler: OBD2EventHandlerProtocol
    
    
    
    init(eventHandler: OBD2EventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
