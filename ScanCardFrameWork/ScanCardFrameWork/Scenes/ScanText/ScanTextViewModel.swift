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

class ScanTextViewModel {
    
    var cardInfo: Card = Card(cardHolder: "",
                              cardNumber: "",
                              issueDate: "",
                              expiryDate: "")
    var image: CIImage
    var scanMode: ScanMode
    
    weak var delegate: ScanTextViewModelDelegate?
    
    init(image: CIImage, mode: ScanMode) {
        self.image = image
        self.scanMode = mode
    }
    
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
                    
                case .auto:
                    return
                }
                
            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
            self.delegate?.didGetCardInfo()
        }
    }
}
