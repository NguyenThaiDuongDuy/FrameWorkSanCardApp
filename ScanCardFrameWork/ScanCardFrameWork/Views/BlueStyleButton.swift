//
//  BlueStyleButton.swift
//  ScanCard
//
//  Created by admin on 20/04/2021.
//

import UIKit

class BlueStyleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initCommon()
    }

    func initCommon() {
        backgroundColor = UIColor(rgb: 0x22A7F0)
        tintColor = .white
        layer.cornerRadius = bounds.height / 2
    }
}
