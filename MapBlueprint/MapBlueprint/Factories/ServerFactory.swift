//
//  ServerFactory.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 3/3/24.
//

import Foundation

protocol ServerFactoryType {
    func testRoute()
    func sendVehicleData(_ data: VehicleData)
    func fetchVehicleData(_ id: String, completion: @escaping (Result<VehicleData, Error>) -> Void)
}

class ServerFactory: ServerFactoryType {
    
    
    func testRoute() {
        print("Init Test")
        let testPost = VehicleData(_id: "bmwf23",fuelLevel: 60, maxFuelLevel: 69, coolantTemperature: 10, oilTemperature: 10, controlModuleVoltage: 10, engineRPM: 10, vehicleSpeed: 10, ambientTemperature: 10, temperatureUnits: "test", volumeUnits: "test")
        sendVehicleData(testPost)
    }
    
    func sendVehicleData(_ data: VehicleData) {
        guard let url = URL(string: "https://alex-shirazi.com/saveVehicleData") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending data: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Unexpected response from server")
                    return
                }
                
                if let mimeType = httpResponse.mimeType, mimeType == "application/json",
                   let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Received from server: \(json)")
                }
            }
            
            task.resume()
        } catch {
            print("Error encoding VehicleData: \(error.localizedDescription)")
        }
    }
    
    func fetchVehicleData(_ id: String, completion: @escaping (Result<VehicleData, Error>) -> Void) {
        guard let url = URL(string: "https://alex-shirazi.com/getVehicleData/\(id)") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }
            
            do {
                let vehicleData = try JSONDecoder().decode(VehicleData.self, from: data)
                completion(.success(vehicleData))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    
}
