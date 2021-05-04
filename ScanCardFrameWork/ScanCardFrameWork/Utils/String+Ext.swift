//
//  String+Ext.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import Foundation
extension String {

    var isNumeric: Bool {
        !(isEmpty) && allSatisfy { $0.isNumber }
    }

    var isOnlyUpCaseAndWhiteSpaceCharacter: Bool {
        let characterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ ")
        if rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        } else {
            return true
        }
    }

    func getDateString() -> Substring {
        guard let range = self.range(of: "/") else { return "" }
        let indexOfCharacter = range.lowerBound
        let start = index(indexOfCharacter, offsetBy: -2, limitedBy: startIndex)
        let endOfString = index(startIndex, offsetBy: count - 1)
        let end = index(indexOfCharacter, offsetBy: +2, limitedBy: endOfString)
        if let start = start, let end = end {
            return self[start...end]
        }
        return ""
    }
}
