//
//  MapBlueprintCompanionApp.swift
//  MapBlueprintCompanion Watch App
//
//  Created by Alex Shirazi on 2/12/24.
//

import SwiftUI
import WatchConnectivity
import WidgetKit

@main
struct MapBlueprintCompanion_Watch_AppApp: App {
    @StateObject private var connectivityManager = ConnectivityProvider()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityManager)
        }
    }
}

class ConnectivityProvider: NSObject, ObservableObject, WCSessionDelegate {
    @Published var fuelLevel: Double = 2
    @Published var maxFuelLevel: Double = 13 // default test values

    override init() {
        super.init()
        // Link to Phone
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession error: \(error.localizedDescription)")
            return
        }
        print("WCSession activated: \(activationState.rawValue)")
        print("WCSession \(session.isCompanionAppInstalled)")
        print("WCSession \(session.applicationContext)")
       

    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("WCSession Recieved Context")
        print("WCSession\(session.applicationContext)")
        if let fuelLevel = applicationContext["fuelLevel"] as? Double {
            print("WCSession \(fuelLevel)")
            DispatchQueue.main.async {
                let defaults = UserDefaults(suiteName: "group.shirazi")
                defaults?.set(fuelLevel, forKey: "fuelLevel")
                
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

}
