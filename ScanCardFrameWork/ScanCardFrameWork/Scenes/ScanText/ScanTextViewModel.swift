//
//  ScanTextViewModel.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import UIKit

protocol ScanTextViewModelDelegate: AnyObject {
    func didGetCardInfo(info: String)
}

class ScanTextViewModel {
    var image: CIImage
    weak var delegate: ScanTextViewModelDelegate?
    
    init(image: CIImage) {
        self.image = image
    }
    
    func setTextInfoWithMode(textImage: CGImage) {
        ImageDetector.detectText(cgImage: textImage) { (resultOfDetectText) in
            switch resultOfDetectText {
            case .success(let strings):
                self.delegate?.didGetCardInfo(info: strings.first ?? "")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
