//
//  DashboardView.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/02/2024.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var manager: OBDManager
    @ObservedObject var viewModel = DashboardViewViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .center){
//                PRNDBStatus(status: viewModel.drivingMode).padding()
                Spacer()
                BatteryIndicator(
                    soc: viewModel.batterySoc,
                    operationMode: viewModel.operationMode,
                    minTemp: viewModel.battMinTemp,
                    maxTemp: viewModel.battMaxTemp,
                    inletTemp: viewModel.battInletTemp,
                    ptcPower: viewModel.battPTCHeaterPower,
                    circPump: viewModel.circPump
                )
            }
            HStack{
                CircleGaugeView(min:0, max: 100, currentValue: viewModel.batterySoc, label: "%")
                CircleGaugeView(min:-110, max: 110, currentValue: viewModel.power, label: "kW")
            }
            HStack{
                CircleGaugeView(min:0, max: 400, currentValue: viewModel.voltage, label: "V")
                CircleGaugeView(min:-400, max: 400, currentValue: viewModel.current, label: "A")
            }
            Spacer()
            
        }.onDisappear {
            viewModel.stopListening()
            UIApplication.shared.isIdleTimerDisabled = false
        }.onAppear(){
            viewModel.startListening()
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
}

#Preview {
    DashboardView()
}
