//
//  ListView.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 24/01/2024.
//

import SwiftUI

struct MessageView: View {
    let message: String
    let sent: Bool
    var body: some View {
        Text(message).padding().frame(maxWidth:.infinity , alignment: .leading).background(Color.blue).contentShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
    }
}

#Preview {
    MessageView(message: "teszt", sent: false)
}
