//
//  DialogView.swift
//  ScanCard
//
//  Created by admin on 06/04/2021.
//

import Foundation
import UIKit

class DialogView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var viewModel: DialogViewModel?

    init(viewModel: DialogViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height))
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = frame
        setInformationDialog()
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        removeFromSuperview()
    }

    @IBAction func tapOkButton(_ sender: Any) {
        removeFromSuperview()
    }

    func setInformationDialog() {
        title.text = Language.share.localized(string: viewModel?.title ?? "")
        message.text = Language.share.localized(string: viewModel?.message ?? "")
        cancelButton.setTitle(Language.share.localized(string: viewModel?.cancelButtonTitle ?? ""), for: .normal)
        okButton.setTitle(Language.share.localized(string: viewModel?.okButtonTitle ?? ""), for: .normal)
    }
}
