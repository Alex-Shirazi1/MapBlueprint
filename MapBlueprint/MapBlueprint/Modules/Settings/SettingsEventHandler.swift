//
//  SettingsEventHandler.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation

protocol SettingsEventHandlerProtocol: AnyObject {
    var viewController: SettingsViewControllerProtocol? { get set }
    
    func navigateToAbout()
    
    func navigateToTerms()
    
    func navigateToOBD2()
    
    func navigateToFuelTank()
    
    func navigateToUnits()
}

class SettingsEventHandler: SettingsEventHandlerProtocol {
    weak var viewController: SettingsViewControllerProtocol?
    let interactor: SettingsInteractorProtocol
    let router: SettingsRouterProtocol
    
    init(interactor: SettingsInteractorProtocol, router: SettingsRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToAbout() {
        router.navigateToAbout()
    }
    func navigateToTerms() {
        router.navigateToTerms()
    }
    
    func navigateToOBD2() {
        router.navigateToOBD2()
    }
    func navigateToFuelTank() {
        router.navigateToFuelTank()
    }
    func navigateToUnits() {
        router.navigateToUnits()
    }
}
