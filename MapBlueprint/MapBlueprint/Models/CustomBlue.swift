//
//  CustomBlue.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/21/24.
//

import Foundation
import UIKit

class CustomBlue {
    
    let redPercentage: CGFloat = 2.76 / 100
    let greenPercentage: CGFloat = 33.17 / 100
    let bluePercentage: CGFloat = 64.07 / 100
    let customColor: UIColor

    init() {
        self.customColor = UIColor(red: redPercentage, green: greenPercentage, blue: bluePercentage, alpha: 1.0)
    }
    
    func color() -> UIColor {
        return customColor
    }
    
}
