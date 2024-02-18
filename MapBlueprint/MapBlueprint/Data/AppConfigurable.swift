//
//  AppConfigurable.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/17/24.
//

import Foundation

class AppConfigurable {
    static let shared = AppConfigurable()
    
    private let autoConnectKey = "AutoConnectToAdapter"
    
    var autoConnectToAdapter: Bool {
        get {
            return UserDefaults.standard.bool(forKey: autoConnectKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: autoConnectKey)
        }
    }
    
    init() {
        
    }
}
