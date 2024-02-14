//
//  SettingsRouter.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation
import UIKit

protocol SettingsRouterProtocol: AnyObject {
    static func createModule(navigationController: UINavigationController) -> UIViewController
    
    func navigateToAbout()
    
    func navigateToTerms()
    
    func navigateToOBD2()

}

class SettingsRouter: SettingsRouterProtocol {
    weak var navigationController: UINavigationController?
    
    static func createModule(navigationController: UINavigationController) -> UIViewController {
        let interactor: SettingsInteractorProtocol = SettingsInteractor()
        let router: SettingsRouter = SettingsRouter()
        router.navigationController = navigationController
        let eventHandler: SettingsEventHandlerProtocol = SettingsEventHandler(interactor: interactor, router: router)
        let viewController = SettingsViewController(eventHandler: eventHandler, tableViewCellFactory: TableViewCellFactory())
        eventHandler.viewController = viewController
        return viewController
    }
    func navigateToAbout() {
        let aboutViewController = AboutViewController()
        navigationController?.pushViewController(aboutViewController, animated: true)
    }
    func navigateToTerms() {
        let termsViewController = TermsViewController()
        navigationController?.pushViewController(termsViewController, animated: true)
    }
    
    func navigateToOBD2() {
        
        guard let navigationController else {
            return
        }
        
        let OBD2ViewController = OBD2Router.createModule(navigationViewController: navigationController)
        navigationController.pushViewController(OBD2ViewController, animated: false)
    }
}
