//
//  OperationMode.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 23/03/2024.
//

import Foundation
import SwiftUI

struct OperationModeView: View {
    // Car operation mode, XX = 0 => standby, XX = 1 => driving, XX = 4 => AC charging, XX = 6 => DC charging
    @State var mode: OperationMode
    var body: some View {
        HStack{
            switch mode {
            case .standBy:
                Text("")
            case .driving:
                Text("")
            case .ACCharging:
                Text("AC")
            case .DCCharging:
                Text("DC")
            }
        }
    }
}

#Preview {
    OperationModeView(mode: .standBy)
}
