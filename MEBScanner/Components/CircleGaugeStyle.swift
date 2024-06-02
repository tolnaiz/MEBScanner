//
//  CircleGaugeStyle.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/03/2024.
//

import Foundation
import SwiftUI

struct CircleGaugeStyle: GaugeStyle {
    var label: String = "Km/h"
    var range: ClosedRange<Double>
    
    init(label: String, range: ClosedRange<Double>){
        self.label = label
        self.range = range
    }
    
    private var gradient = LinearGradient(gradient: Gradient(colors: [ Color(red: 32/255, green: 137/255, blue: 21/255), Color(red: 235/255, green: 18/255, blue: 18/255) ]), startPoint: .trailing, endPoint: .leading)
    private var green = Color(red: 170/255, green: 30/255, blue: 17/255)
 
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .foregroundColor(Color(.systemGray6))

            if range.lowerBound < 0 {
                if configuration.value < 0.5 {
                    Circle()
                        .trim(from: (configuration.value) * 0.75, to: 0.375)
                        .stroke(green, lineWidth: 10)
                        .rotationEffect(.degrees(135))
                } else {
                    Circle()
                        .trim(from: 0.375, to: 0.75 * configuration.value)
                        .stroke(green, lineWidth: 10)
                        .rotationEffect(.degrees(135))
                }
                
            }else{
                Circle()
                    .trim(from: 0, to: 0.75 * configuration.value)
                    .stroke(green, lineWidth: 10)
                    .rotationEffect(.degrees(135))
            }
 
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 10, lineCap: .butt, lineJoin: .round, dash: [1, 34], dashPhase: 0.0))
                .rotationEffect(.degrees(135))
 
            VStack {
//                Text("\(configuration.value)")
                configuration.currentValueLabel
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                Text(label)
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
            }
 
        }
//        .frame(width: 300, height: 300)
 
    }
 
}
