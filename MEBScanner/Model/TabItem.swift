//
//  TAbItem.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 17/03/2024.
//

import Foundation
import SwiftUI

struct TabItem: Identifiable{
    let id = UUID()
    var image: String
    var label: String
    var view: any View
    var tag: Int
}
