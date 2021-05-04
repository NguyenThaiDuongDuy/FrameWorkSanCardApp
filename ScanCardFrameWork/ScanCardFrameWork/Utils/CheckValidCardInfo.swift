//
//  CheckValidCardInfo.swift
//  ScanCardFrameWork
//
//  Created by admin on 04/05/2021.
//

import Foundation

enum CheckValidCardInfo {
    
    static let maxCardNumber = 19
    static let minCardNumber = 16
    
    static func isValidCardNumber(cardNumber: String) -> Bool {
        let vowels: Set<Character> = [" "]
        var checkCardNumber = ""
        checkCardNumber = cardNumber
        checkCardNumber.removeAll(where: { vowels.contains($0) })

        if !checkCardNumber.isNumeric { return false }

        if checkCardNumber.count<minCardNumber || checkCardNumber.count>maxCardNumber {
            return false
        }
        return true
    }

    static func isValidCardHolder(cardHolder: String) -> Bool {
        if !cardHolder.isOnlyUpCaseAndWhiteSpaceCharacter { return false }
        let nameAfterCutWhiteSpacesAndNewlines = cardHolder.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
        return nameAfterCutWhiteSpacesAndNewlines.contains(" ")
    }

    static func isValidIssueDate(checkIssueDate: String) -> Bool {
        let dateStringAfterFilter = String(checkIssueDate.getDateString())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: dateStringAfterFilter)
        guard let checkInputDate = inputDate else {
            return false }
        return checkInputDate < Date()
    }

    static func isValidExpiryDate(checkExpiryDate: String) -> Bool {
        let dateStringAfterFilter = String(checkExpiryDate.getDateString())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: dateStringAfterFilter)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate > Date()
    }
    
    static func getInfoCardAuto(information: [String]?) -> Card {
        Logger.log(information as Any)
        var cardInfo = Card(cardHolder: "",
                            cardNumber: "",
                            issueDate: "",
                            expiryDate: "")
        guard let checkInformation = information else { return cardInfo }

        for index in stride(from: checkInformation.count - 1, to: 0, by: -1) {

            if self.isValidCardHolder(cardHolder: checkInformation[index]) &&
                (((cardInfo.cardHolder.isEmpty))) {
                cardInfo.cardHolder = checkInformation[index]
            }

            if self.isValidCardNumber(cardNumber: checkInformation[index])
                && ((cardInfo.cardNumber.isEmpty)) {
                cardInfo.cardNumber = checkInformation[index]
            }

            if self.isValidIssueDate(checkIssueDate: checkInformation[index])
                && ((cardInfo.issueDate!.isEmpty)) {
                cardInfo.issueDate = String(checkInformation[index].getDateString())
            }

            if self.isValidExpiryDate(checkExpiryDate: checkInformation[index])
                && ((cardInfo.expiryDate!.isEmpty)) {
                cardInfo.expiryDate = String(checkInformation[index].getDateString())
            }
        }
        return cardInfo
    }
    
    
}
