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
    @State var status: Int
    var body: some View {
        HStack{
            Text("P").bold(status == 8).foregroundColor(status == 8 ? .red: .primary)
            Text("R").bold(status == 7).foregroundColor(status == 7 ? .red: .primary)
            Text("N").bold(status == 6).foregroundColor(status == 6 ? .red: .primary)
            Text("D").bold(status == 5).foregroundColor(status == 5 ? .red: .primary)
            Text("B").bold(status == 12).foregroundColor(status == 12 ? .red: .primary)
        }
    }
}

#Preview {
    PRNDBStatus(status: 8)
}
