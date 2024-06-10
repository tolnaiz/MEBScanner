//
//  SettingsViewViewModel.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/02/2024.
//

import Foundation
import UIKit

class SettingsViewViewModel: ObservableObject {
    var ABRPAuthorizationKey = "646f636e-b7e7-440d-9b06-1117a239f45c"
    var abrpKey = UserDefaults.standard.string(forKey: "ABRPKey") ?? ""
    @Published var abrpConnected: Bool = false
    var ABRPtimer: Timer?
    
    var voltage: Double = 0
    var current: Double = 0
    var batterySoc: Double = 0
    var drivingMode: DrivingMode = .p
    var operationMode: OperationMode = .standBy
    var battMinTemp: Double = 20
    var battMaxTemp: Double = 25
    var battInletTemp: Double = 30
    var battPTCHeaterCurrent: Double = 4
    var circPump: Int = 4
    var power: Double {
        voltage * current / 1000
    }
    var displaySoc: Double {
        batterySoc * 2.5 * 0.505 - 9.0947
    }
    var battPTCHeaterPower: Double {
        voltage * battPTCHeaterCurrent / 1000
    }
    var subscriptions: Set<Subscription> = []
    var sharedSender: CommandSender?
    @Published var manager: ConnectionManager
    
    init(){
        manager = ConnectionManager.shared()
    }
    // 22F40D
    
    func ABRPConnect(){
        abrpConnected = true
        UserDefaults.standard.setValue(abrpKey, forKey: "ABRPKey")

        
        sharedSender = CommandSender.sharedSender;
        sharedSender?.start()
        setupSender()
        
        
        
        self.ABRPtimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.sendABRPData(payload: ABRPPayload(
                utc: Int(Date().timeIntervalSince1970),
                soc: self.displaySoc,
                power: self.power,
                speed: 0,
                lat: 0, lon: 0,
                is_charging: (self.operationMode == .ACCharging || self.operationMode == .DCCharging),
                is_dcfc: self.operationMode == .DCCharging,
                is_parked: self.drivingMode == .p,
                capacity: 45000,
                ext_temp: 14,
                batt_temp: 15,
                voltage: self.voltage,
                current: self.current
            ))
        })
        
    }
    
    func setupSender() {
        subscriptions.insert(Subscription(pidparam: .batteryVoltage, interval: .slow) { pidvalue in
            self.voltage = pidvalue.value
        })
        subscriptions.insert(Subscription(pidparam: .batteryCurrent, interval: .slow) { pidvalue in
            self.current = pidvalue.value
        })
        subscriptions.insert(Subscription(pidparam: .batterySoc, interval: .slow) { pidvalue in
            self.batterySoc = pidvalue.value
        })
        subscriptions.insert(Subscription(pidparam: .batterySoc, interval: .slow) { pidvalue in
            self.batterySoc = pidvalue.value
        })
        
        subscriptions.insert(Subscription(pidparam: .operationMode, interval: .slow) { pidvalue in
            self.operationMode = OperationMode(rawValue: Int(pidvalue.value))!
        })
        
        subscriptions.insert(Subscription(pidparam: .drivingMode, interval: .slow) { pidvalue in
            self.drivingMode = DrivingMode(rawValue: Int(pidvalue.value))!
        })
        
        // speed
        // lat
        // lon
        // soh
        // ext temp
        // odometer
        // est range
        // batt temp
        
        for item in subscriptions {
            sharedSender?.subscribePID(subscription: item)
        }
    }
    
    func ABRPDisconnect(){
        abrpConnected = false
        ABRPtimer?.invalidate();
        sharedSender?.stop()
        teardownSenders()
    }
    
    func teardownSenders() {
        for item in subscriptions {
            sharedSender?.unSubscribePID(subscription: item)
        }
        // speed
        // lat
        // lon
        // soh
        // ext temp
        // odometer
        // est range
        // batt temp
    }
    
    func sendABRPData(payload: ABRPPayload){
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.iternio.com"
        components.path = "/1/tlm/send"
        
        let jsonEncoder = JSONEncoder()
        let data = try! jsonEncoder.encode(payload)
        components.queryItems = [
            URLQueryItem(name: "token", value: abrpKey),
            URLQueryItem(name: "tlm", value: String(data: data, encoding: .utf8)!),
            URLQueryItem(name: "api_key", value: ABRPAuthorizationKey)
        ]
        var request = URLRequest(url: components.url!)
        print(request)
        request.httpMethod = "POST"
        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            let statusCode = (response as! HTTPURLResponse).statusCode
//
//            if statusCode == 200 {
//                print("SUCCESS")
//            } else {
//                print("FAILURE")
//            }
//        }
//        task.resume()
    }
    // ?token=<ABRP user token>&tlm={"utc":1553807658,"soc":80.4,"soh":97.7,"speed":0,"lat":29.564,"lon":-95.025,"elevation":50,"is_charging":0,"power":13.2,"ext_temp":25,"batt_temp":25,"car_model":"chevy:bolt:17:60:other","current":36.66,"voltage":360}
    // Int(Date().timeIntervalSince1970)
    


    
}
