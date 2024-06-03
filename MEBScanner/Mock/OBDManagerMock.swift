//
//  ManagerMock.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 16/03/2024.
//

import Foundation

class OBDManagerMock: OBDManager{
    var testValues = [
        "22028C": ["62 02 8C 84"],
        "22F40D": ["62 F4 0D 00"],
        "227448": ["62 74 48 01"],
        "22743B": ["62 74 3В 00"],
        "22210E": ["62210E0008"],
        "221E3B": ["621E3B058E", "621E3B051E"],
        "221E3D": ["008621E3D000249A03EAAAAAAAAAA"],
        "222A0B": ["621E3D0060"],
        "221620": ["62162020"],
        "22189D": ["62189D04C034C0"],
        "221E0F": ["621f0e0134YYZZ"],
        "221E0E": ["621f0e0133YYZZ"],
        "ATRV": ["14.2V"]
    ]
    private static var sharedManager: any ObservableObject = {
            let manager = OBDManagerMock()
            return manager
    }()
    
    class func shared() -> any ObservableObject {
        return sharedManager
    }
    
    override func request(message: String, action: ((String) -> Void)? = nil) {
        debugPrint("Mock received: \(message)")
        var response = "???"
        if testValues.keys.contains(message){
            response = testValues[message]?.randomElement() ?? "???"
        }
        if action != nil {
            action!(response)
        }
    }
    
    override func connect(){
        self.connected = true
    }
    
    override func disconnect(){
        self.connected = false
    }
    
}
