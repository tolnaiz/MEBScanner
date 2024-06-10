//
//  DasboardViewViewModel.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/02/2024.
//

import Foundation

class DashboardViewViewModel: ObservableObject {
    @Published var voltage: Double = 0
    @Published var current: Double = 0
    @Published var batterySoc: Double = 0
    @Published var drivingMode: DrivingMode = .n
    @Published var operationMode: OperationMode = .standBy
    @Published var battMinTemp: Double = 20
    @Published var battMaxTemp: Double = 25
    @Published var battInletTemp: Double = 22
    @Published var battPTCHeaterCurrent: Double = 0
    @Published var circPump: Int = 0
    @Published var rv: String = ""
    
    var power: Double {
        voltage * current / 1000
    }
    var displaySoc: Double {
        batterySoc * 1.2625 - 9.0947
    }
    var battPTCHeaterPower: Double {
        voltage * battPTCHeaterCurrent / 1000
    }
    @Published var manager: ConnectionManager
    
    init() {
        manager = ConnectionManager.shared()
    }
    
    var subscriptions: Set<Subscription> = []
    
    func startListening(){

        let sharedSender = CommandSender.sharedSender;
        if manager.connected{
            sharedSender.start()
            
            subscriptions.insert(Subscription(pidparam: .batteryVoltage, interval: .fast) { pidvalue in
                self.voltage = pidvalue.value
            })
            subscriptions.insert(Subscription(pidparam: .batteryCurrent, interval: .fast) { pidvalue in
                self.current = pidvalue.value
            })
            
            subscriptions.insert(Subscription(pidparam: .batterySoc, interval: .slow) { pidvalue in
                self.batterySoc = pidvalue.value
            })
            
            subscriptions.insert(Subscription(pidparam: .operationMode, interval: .slow) { pidvalue in
                self.operationMode = OperationMode(rawValue: Int(pidvalue.value))!
            })
            
            subscriptions.insert(Subscription(pidparam: .batteryMinTemp, interval: .slow) { pidvalue in
                self.battMinTemp = pidvalue.value
            })
            
            subscriptions.insert(Subscription(pidparam: .batteryMaxTemp, interval: .slow) { pidvalue in
                self.battMaxTemp = pidvalue.value
            })
            
            subscriptions.insert(Subscription(pidparam: .batteryInletTemp, interval: .slow) { pidvalue in
                self.battInletTemp = pidvalue.value
            })
            
            subscriptions.insert(Subscription(pidparam: .batteryPTCCurrent, interval: .slow) { pidvalue in
                self.battPTCHeaterCurrent = pidvalue.value
            })
            
            subscriptions.insert(Subscription(pidparam: .circulationPumpHVBattery, interval: .slow) { pidvalue in
                self.circPump = Int(pidvalue.value)
            })
            
            subscriptions.insert(Subscription(pidparam: .drivingMode, interval: .slow) { pidvalue in
                    self.drivingMode = DrivingMode(rawValue: Int(pidvalue.value))!
            })
            
            for item in subscriptions {
                sharedSender.subscribePID(subscription: item)
            }
        }
    }
    
    func stopListening(){
        let sharedSender = CommandSender.sharedSender;
        sharedSender.stop()
        for item in subscriptions {
            sharedSender.unSubscribePID(subscription: item)
        }
    }
}
