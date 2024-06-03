//
//  PID.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/03/2024.
//

import Foundation

struct PID: Hashable {
    static func == (lhs: PID, rhs: PID) -> Bool {
        lhs.command == rhs.command
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(command)
    }
    var command: String
    var header: String = "FC007B"
    var startByte: Int = 6
    var endByte: Int = 8
    var parse: (UInt32) -> Double = { (intValue) -> Double in
        Double(intValue)
    }
    func isA(p: PIDParameter) -> Bool{
        return p == PIDParameter(rawValue: command)
    }
    
    static let parameters: [PIDParameter: PID] = [
        .speedKmph: PID(command: "22F40D"),
        .operationMode: PID(command: "227448"),
        .rv: PID(command: "ATRV"),
        .circulationPumpHVBattery: PID(command: "22743B"),
        .drivingMode: PID(command: "22210E", endByte: 10),

        .batterySoc: PID(command: "22028C") { intValue in
            (Double(intValue))/2.55
        },
        .batteryVoltage: PID(command: "221E3B", endByte: 10) { intValue in
            (Double(intValue))/4
        },
        .batteryCurrent: PID(command: "221E3D", startByte: 9, endByte: 17) { intValue in
            ((Double(intValue)) - 150000)/100
        },
        .batteryMinTemp: PID(command: "221E0F", endByte: 10) { intValue in
            Double(intValue)/64
        },
        .batteryMaxTemp: PID(command: "221E0E", endByte: 10) { intValue in
            Double(intValue)/64
        },
        .batteryInletTemp: PID(command: "22189D", startByte:10, endByte: 14) { intValue in
            Double(intValue)/64
        },
        .batteryPTCCurrent: PID(command: "221620") { intValue in
            Double(intValue)/4
        },
        
        .auxillaryPower: PID(command: "220364", header: "FC0076")
    ]
    
    static func parse(response: String, command: String) throws -> PIDValue {
        if response.contains("NO DATA") || response.contains("?") || response.contains("???") || response.contains("CAN ERROR"){
            throw PIDError.InvalidResponse(response: response, command: command, pid: PIDParameter.init(rawValue: command))
        }
        let responseWithutSpaces = response.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\r", with: "")
        print("PARSER DEBUG RAW: \(command): \(responseWithutSpaces)")
        print(PIDParameter.init(rawValue: command).debugDescription)
        

        let pid = self.parameters[PIDParameter.init(rawValue: command)!]
        if pid != nil {
            let hexValue = responseWithutSpaces.substring(with: pid!.startByte..<pid!.endByte)
            let intValue = UInt32(hexValue, radix: 16) ?? 0
            return PIDValue(value: pid!.parse(intValue), pid: pid!, rawValue: responseWithutSpaces)
        } else {
            return PIDValue(value: 0.0, rawValue: responseWithutSpaces)
        }
    }
}

enum OperationMode: Int{
    case standBy = 0
    case driving = 1
    case ACCharging = 4
    case DCCharging = 6
}

enum DrivingMode: Int{
    case p = 8
    case d = 5
    case b = 12
    case r = 7
    case n = 6
}

enum PIDError: Error {
    case InvalidResponse(response: String, command: String, pid: PIDParameter?)
}


enum PIDParameter: String, CaseIterable {
    case batterySoc = "22028C"
    case speedKmph = "22F40D"
    case operationMode = "227448"
    case batteryVoltage = "221E3B"
    case batteryCurrent = "221E3D"
    case batteryMinTemp = "221E0F"
    case batteryMaxTemp = "221E0E"
    case batteryInletTemp = "22189D"
    case batteryPTCCurrent = "221620"
    case circulationPumpHVBattery = "22743B"
    case drivingMode = "22210E"
    case rv = "ATRV"
    case auxillaryPower = "220364"
}

//    DC-DC current (HV->12V) 0x17fc00b9 03 22 46 5b 55 55 55 55
//    DC-DC voltage (HV->12V) 0x17fc00b9 03 22 46 5d 55 55 55 55

//    HV Battery cell voltage - cell 1

//    HV Battery temp point 1

//    Dynamic limit for charging
//    Dynamic limit for discharge
    
//    Outdoor temperature
//    CO2 content interior
//    Inside temperature
//    Recirculation of air
    
//    12V battery voltage
//    12V Battery temp
//    12V Battery SoC
//    12V Battery current
    
//    HV Battery energy content
//    HV Battery max energy content
    
//    HV Battery serial
//    HV battery total charge
//    HV battery total discharge

