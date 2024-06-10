//
//  DashboardView.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/02/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: ConnectionManager
    @StateObject var viewModel = SettingsViewViewModel()
    
    @State private var showingAlert = false
    
    var body: some View {
        VStack(alignment: .leading){
            Text("ABRP connection").font(.largeTitle)
            TextField("ABRP key", text: $viewModel.abrpKey).textFieldStyle(.roundedBorder)
            HStack{
                Spacer()
                Button("Connect",action: {
                    viewModel.ABRPConnect()
                }).buttonStyle(.bordered).disabled(viewModel.abrpConnected)
                Spacer()
                Button("Disconnect",action: {
                    viewModel.ABRPDisconnect()
                }).buttonStyle(.bordered).disabled(!viewModel.abrpConnected)
                Spacer()
            }
            Text("OBD connection").font(.largeTitle)
            VStack{
                Toggle(isOn: $manager.testMode, label: {
                    Text("Test Mode")
                }).padding([.top, .bottom]).disabled(manager.connected)
                HStack{
                    Spacer()
                    Button("Connect",action: {
                        showingAlert = !manager.connect()
                    }).alert("Error connecting to OBD device", isPresented: $showingAlert) {
                       Button("OK", role: .cancel) { }
                    }.buttonStyle(.bordered).disabled(manager.connected)
                    Spacer()
                    Button("Disconnect",action: {
                        manager.disconnect()
                    }).buttonStyle(.bordered).disabled(!manager.connected)
                    Spacer()
                    
                }
            }
            Spacer()
            Text("Available devices:")
            ScrollView {
                LazyVStack{
                    ForEach(manager.connectedDevices, id: \.self){ device in
                        Text("\(device.manufacturer) \(device.modelNumber), \(device.serialNumber)")
                    }
                }.frame(maxHeight: 200).background()
            }
        }.padding()
        
    }
}

#Preview {
    SettingsView().environmentObject(ConnectionManager.shared())
}
