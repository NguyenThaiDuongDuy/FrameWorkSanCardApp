//
//  ScanTextCollectionView.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import UIKit

class ScanTextScrollView: UIScrollView {

    override func touchesShouldCancel(in view: UIView) -> Bool {

        if view.isKind(of: CardImageView.self) {
            return false
        }

        if view.isKind(of: UITextField.self) {
            return true
        }

        return super.touchesShouldCancel(in: view)
    }
}
