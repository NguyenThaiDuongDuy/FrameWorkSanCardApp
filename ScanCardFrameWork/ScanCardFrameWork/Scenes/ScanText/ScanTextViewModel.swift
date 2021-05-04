//
//  ScanTextViewModel.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import UIKit

protocol ScanTextViewModelDelegate: AnyObject {
    func didGetCardInfo()
}

//enum ScanMode {
//    case cardHolder
//    case cardNumBer
//    case issueDate
//    case expiryDate
//
//    static let modes = [cardHolder, cardNumBer, issueDate, expiryDate]
//
//    var modeString: String {
//        switch self {
//        case .cardHolder:
//            return "Card Holder"
//
//        case .cardNumBer:
//            return "Card Number"
//
//        case .issueDate:
//            return "Issue Date"
//
//        case .expiryDate:
//            return "Expiry Date"
//        }
//    }
//}

enum ResultCheckInfo: String {
    case success
    case invalidCardHolder
    case invalidCardNumber
    case invalidIssueDate
    case invalidExpiryDate
}

class ScanTextViewModel {

    var cardInfo: Card = Card(cardHolder: "",
                              cardNumber: "",
                              issueDate: "",
                              expiryDate: "")
    var image: CIImage
    let mode: ScanMode
    private let maxCardNumber = 19
    private let minCardNumber = 16
    weak var delegate: ScanTextViewModelDelegate?

    init(image: CIImage, mode: ScanMode) {
        self.image = image
        self.mode = mode
    }

    func checkValidInfo(cardInfo: Card) -> ResultCheckInfo {
        
        switch self.mode {
        case .all:
            // Check valid Name
            if !isValidCardHolder(cardHolder: cardInfo.cardHolder) {
                return ResultCheckInfo.invalidCardHolder
            }

            // Check valid bank number
            if !isValidCardNumber(cardNumber: cardInfo.cardNumber) {
                return ResultCheckInfo.invalidCardNumber
            }

            // check valid created date
            if !isValidIssueDate(checkIssueDate: cardInfo.issueDate ?? "") {
                return ResultCheckInfo.invalidIssueDate
            }

            // check valid validate date
            if !isValidExpiryDate(checkExpiryDate: cardInfo.expiryDate ?? "") {
                return ResultCheckInfo.invalidExpiryDate
            }
            
            self.cardInfo = cardInfo
            return ResultCheckInfo.success
        case .cardHolder:
            if !isValidCardHolder(cardHolder: cardInfo.cardHolder) {
                return ResultCheckInfo.invalidCardHolder
            }
            self.cardInfo.cardHolder = cardInfo.cardHolder
            return ResultCheckInfo.success
            
        case .cardNumber:
            if !isValidCardNumber(cardNumber: cardInfo.cardNumber) {
                return ResultCheckInfo.invalidCardNumber
            }
            self.cardInfo.cardNumber = cardInfo.cardNumber
            return ResultCheckInfo.success
            
        case .issueDate:
            if !isValidIssueDate(checkIssueDate: cardInfo.issueDate ?? "") {
                return ResultCheckInfo.invalidIssueDate
            }
            self.cardInfo.issueDate = cardInfo.issueDate
            return ResultCheckInfo.success
            
        case .expiryDate:
            if !isValidExpiryDate(checkExpiryDate: cardInfo.expiryDate ?? "") {
                return ResultCheckInfo.invalidExpiryDate
            }
            self.cardInfo.expiryDate = cardInfo.expiryDate
            return ResultCheckInfo.success
        default:
            print("abc")
            return ResultCheckInfo.success
        }
    }

    private func isValidCardNumber(cardNumber: String) -> Bool {
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

    private func isValidCardHolder(cardHolder: String) -> Bool {
        if !cardHolder.isOnlyUpCaseAndWhiteSpaceCharacter { return false }
        let nameAfterCutWhiteSpacesAndNewlines = cardHolder.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
        return nameAfterCutWhiteSpacesAndNewlines.contains(" ")
    }

    private func isValidIssueDate(checkIssueDate: String) -> Bool {
        let dateStringAfterFilter = String(checkIssueDate.getDateString())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: dateStringAfterFilter)
        guard let checkInputDate = inputDate else {
            return false }
        return checkInputDate < Date()
    }

    private func isValidExpiryDate(checkExpiryDate: String) -> Bool {
        let dateStringAfterFilter = String(checkExpiryDate.getDateString())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: dateStringAfterFilter)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate > Date()
    }

    private func getInfoCardAuto(information: [String]?) -> Card {
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

//    func parseCardInfo() {
//        let context = CIContext()
//        guard let cgImage = context.createCGImage(image, from: image.extent) else {
//            Logger.log("Can't created cgImage from image")
//            return }
//
//        ImageDetector.detectText(cgImage: cgImage) { (resultOfDetectText) in
//            switch resultOfDetectText {
//            case .success(let strings):
//                self.cardInfo = self.getInfoCardAuto(information: strings)
//                self.delegate?.didGetCardInfo()
//
//            case .failure(let error):
//                Logger.log(error.localizedDescription)
//            }
//        }
//    }

    func setTextInfoWithMode(textImage: CGImage, mode: ScanMode) {
        ImageDetector.detectText(cgImage: textImage) { (resultOfDetectText) in
            switch resultOfDetectText {
            case .success(let strings):
                switch mode {
                case .cardHolder:
                    self.cardInfo.cardHolder = strings.first ?? ""

                case .cardNumber:
                    self.cardInfo.cardNumber = strings.first ?? ""

                case .issueDate:
                    self.cardInfo.issueDate = strings.first

                case .expiryDate:
                    self.cardInfo.expiryDate = strings.first
                case .auto, .all:
                    return
                }

            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
        }
        self.delegate?.didGetCardInfo()
    }
}
