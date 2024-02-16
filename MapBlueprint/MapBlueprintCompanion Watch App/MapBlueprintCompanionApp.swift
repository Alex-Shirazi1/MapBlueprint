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
        
        print("WCSession Received Context \(applicationContext)")
        
        DispatchQueue.main.async {
            let defaults = UserDefaults(suiteName: "group.shirazi")
            
            // Checks and save fuel level data
            if let fuelLevel = applicationContext["fuelLevel"] as? Double {
                print("WCSession FUEL \(fuelLevel)")
                defaults?.set(fuelLevel, forKey: "fuelLevel")
            }
            
            // Checks and save max fuel data
            if let maxFuelLevel = applicationContext["maxFuelLevel"] as? Double {
                defaults?.set(maxFuelLevel, forKey: "maxFuelLevel")
            }
            
            // Checks and save coolant temperature
            if let coolantTemperature = applicationContext["coolantTemperature"] as? Double {
                print("WCSession COOL \(coolantTemperature)")
                defaults?.set(coolantTemperature, forKey: "coolantTemperature")
            }
            
            // Checks and save oil temperature
            if let oilTemperature = applicationContext["oilTemperature"] as? Double {
                print("WCSession OIL \(oilTemperature)")
                defaults?.set(oilTemperature, forKey: "oilTemperature")
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }


}
