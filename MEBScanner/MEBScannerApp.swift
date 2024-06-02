//
//  MEBScannerApp.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 13/01/2024.
//

import SwiftUI



@main
struct MEBScannerApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
