//
//  TerminalView.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 24/01/2024.
//

import UIKit
import SwiftUI
import ExternalAccessory
import Combine

struct TerminalView: View {
    @EnvironmentObject var manager: OBDManager
    @StateObject var viewModel = TerminalViewViewModel()
    
    var body: some View {
        VStack{
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 3 ) {
                        ForEach(viewModel.messages, id: \.id) { message in
                            MessageView(message: message.message, sent: false).id(message)
                        }
                    }.onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    .onReceive(Just(viewModel.messages)) { _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last, anchor: .bottom)
                        }
                        
                    }.onAppear {
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last, anchor: .bottom)
                        }
                    }
                }
            }
        
            HStack{
                TextField("Enter a command", text: $viewModel.text, axis: .vertical)
                    .padding().textFieldStyle(.roundedBorder)
                Button ("Send",action: {
                    viewModel.send()
                }).buttonStyle(.bordered).disabled(!manager.connected)
            }.padding(10)
        }.onDisappear {
            
        }.onAppear(){
            
        }
    }
    

}

#Preview {
    TerminalView().environmentObject(OBDManager.shared())
}
