//
//  CircleGauge.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/03/2024.
//

import Foundation
import SwiftUI

struct CircleGaugeView: View {
    let min: Double
    let max: Double
    var currentValue = 0.0
    var label: String
    
    var body: some View {
        Gauge(value: currentValue, in: min...max) {
            Image(systemName: "gauge.medium")
                .font(.system(size: 16.0))
        } currentValueLabel: {
            Text(String(format: "%.2f", currentValue))
        }
        .gaugeStyle(CircleGaugeStyle(label: label, range: min...max)).padding()
    }
}

#Preview {
    VStack{
        CircleGaugeView(min:-400, max: 400, currentValue: -400, label: "V")
        CircleGaugeView(min:-400, max: 400, currentValue: 400, label: "V")
        CircleGaugeView(min:0, max: 400, currentValue: 400, label: "V")
        
    }
}
