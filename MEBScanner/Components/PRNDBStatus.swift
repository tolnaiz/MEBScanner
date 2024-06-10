//
//  PRNDStatus.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 23/03/2024.
//

import Foundation
import SwiftUI

struct PRNDBStatus: View {
    // Driving mode position (P-N-D-B), YY=08->P,YY=05->D,YY=12->B,YY=07->R,YY=06->N
    var status: DrivingMode
    var body: some View {
        HStack{
            Text("P").bold(status == .p).foregroundColor(status == .p ? .red: .primary)
            Text("R").bold(status == .r).foregroundColor(status == .r ? .red: .primary)
            Text("N").bold(status == .n).foregroundColor(status == .n ? .red: .primary)
            Text("D").bold(status == .d).foregroundColor(status == .d ? .red: .primary)
            Text("B").bold(status == .b).foregroundColor(status == .b ? .red: .primary)
        }
    }
}

#Preview {
    PRNDBStatus(status: .p)
}
