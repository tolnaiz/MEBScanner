//
//  TerminalViewViewModel.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/02/2024.
//

import Foundation

class TerminalViewViewModel: ObservableObject {
    @Published var manager : OBDManager
    @Published var text = ""
    @Published var messages : [TerminalMessage] = []
    
    init(){
        manager = OBDManager.shared()
    }
    
    func send(){
        self.messages.append(TerminalMessage(message: self.text))
        let text = self.text
        DispatchQueue.main.async {
            let message = self.manager.request(message:text)
            print("terminal message received: \(self.text) \(message)")
            self.messages.append(TerminalMessage(message: message))
        }
        self.text = ""
    }
}
