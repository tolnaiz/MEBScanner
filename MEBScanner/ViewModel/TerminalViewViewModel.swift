//
//  TerminalViewViewModel.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/02/2024.
//

import Foundation

class TerminalViewViewModel: ObservableObject {
    @Published var manager : ConnectionManager
    @Published var text = ""
    @Published var messages : [TerminalMessage] = []
    
    init(){
        manager = ConnectionManager.shared()
    }
    
    func send(){
        self.messages.append(TerminalMessage(message: self.text))
        let text = self.text
        manager.request(message:text) { response in
            DispatchQueue.main.async{
                print("terminal message received: \(self.text) \(response)")
                self.messages.append(TerminalMessage(message: response))
            }
        }
        self.text = ""
    }
}
