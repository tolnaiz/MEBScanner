//
//  Extensions.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 17/03/2024.
//

import Foundation
import SwiftUI

//extension Color {
//    static let background = Color("Background")
//    static let icon = Color("Icon")
//    static let text = Color("Text")
//    static let systemBackground = Color(uiColor: .systemBackground)
//}

extension Array where Element: AnyObject {
    mutating func removeFirst(object: AnyObject) {
        guard let index = firstIndex(where: {$0 === object}) else { return }
        remove(at: index)
    }
}

extension String {
    subscript(_ index: Int) -> Character? {
        guard index >= 0, index < self.count else {
            return nil
        }

        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
    func index(from: Int) -> Index {
        if self.count <= from{
            return self.index(startIndex, offsetBy: self.count)
        }else {
            return self.index(startIndex, offsetBy: from)
        }
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
