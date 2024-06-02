//
//  TerminalMessage.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 18/02/2024.
//

import Foundation

struct TerminalMessage: Identifiable, Hashable {
    var message: String
    let id = UUID()
}
