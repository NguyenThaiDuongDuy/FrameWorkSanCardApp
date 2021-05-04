//
//  OptionCollectionCell.swift
//  ChosseCollection
//
//  Created by admin on 13/04/2021.
//

import UIKit

class ScanModeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var modeNameLabel: UILabel!
    @IBOutlet weak var modeView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCell()
    }

    private func setUpCell() {
        modeView.clipsToBounds = true
        modeView.layer.cornerRadius = 15.0
        modeView.backgroundColor = UIColor(rgb: 0x22A7F0).withAlphaComponent(0.5)
        modeNameLabel.textColor = .white
    }

    override var isSelected: Bool {
        didSet {
            modeView.backgroundColor = isSelected ? UIColor(rgb: 0x22A7F0):
                UIColor(rgb: 0x22A7F0).withAlphaComponent(0.5)
        }
    }
}
