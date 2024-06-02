//
//  BatteryIndicator.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 05/04/2024.
//

import SwiftUI

struct BatteryIndicator: View {
    var soc: Double
    var operationMode: OperationMode
    var minTemp: Double
    var maxTemp: Double
    var inletTemp: Double
    var ptcPower: Double
    var circPump: Int
    var batteryImage: String {
        if soc > 90{
            "battery.100percent"
        } else if soc >= 75 {
            "battery.75percent"
        } else if soc >= 50 {
            "battery.75percent"
        } else if soc >= 25 {
            "battery.25percent"
        } else {
            "battery.0percent"
        }
    }
    var body: some View {
        HStack{
            VStack{
                // if the battery temp is bellow 20, charging speed is compromised
                HStack{
                    Text("inlet: ")
                    Spacer()
                    Text("\(String(format: "%.1f",inletTemp))°C")
                }.font(.system(size: 22))
                
                    
                HStack{
                    Text("PTC: ")
                    Spacer()
                    Text("\(String(format: "%.0f",ptcPower))kW")
                }.font(.system(size: 22))
                
                HStack{
                    Text("Circ: ")
                    Spacer()
                    Text("\(String(format: "%.0f",ptcPower))%")
                }.font(.system(size: 22))
            }
            VStack{
                if operationMode == .standBy || operationMode == .driving {
                        HStack{
                            Image(systemName: batteryImage).font(.system(size: 40)).foregroundColor(.primary)
                            Spacer()
                        }
                    }else{
                        HStack{
                            Image(systemName: "battery.100percent.bolt").font(.system(size: 40)).foregroundColor(.primary)
                            Spacer()
                            OperationModeView(mode: operationMode)
                        }
                    }

                HStack{
                    Text("max: ")
                    Spacer()
                    Text("\(String(format: "%.1f",maxTemp))°C")
                }.foregroundColor(maxTemp < 20 ? Color.blue : .primary)
                    .font(.system(size: 22))
                    
                HStack{
                    Text("min: ")
                    Spacer()
                    Text("\(String(format: "%.1f",minTemp))°C")
                }.foregroundColor(minTemp < 20 ? Color.blue : .primary)
                    .font(.system(size: 22))
            }
        }.padding()
    }
}

#Preview {
    BatteryIndicator(soc:60, operationMode: .driving , minTemp: 14.0, maxTemp: 21.0, inletTemp: 14, ptcPower: 5, circPump: 44)
}
