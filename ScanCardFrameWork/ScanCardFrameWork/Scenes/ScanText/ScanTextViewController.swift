//
//  ScanTextViewController2.swift
//  ScanCard
//
//  Created by DuyNguyen on 27/04/2021.
//

import UIKit

class ScanTextViewController: UIViewController {
    
    private let cellID = "ScanModeCollectionViewCell"
    private var viewModel: ScanTextViewModel
    private var scanMode: ScanMode
    var info: String = ""
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cardView: CardImageView!
    @IBOutlet weak var confirmButton: BlueStyleButton!
    @IBOutlet weak var scrollView: ScanTextScrollView!
    
    
    init(cardImage: CIImage, mode: ScanMode) {
        self.scanMode = mode
        viewModel = ScanTextViewModel(image: cardImage)
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCardView()
        setUpConfirmButton()
        setUpViewModel()
    }
    
    private func setUpViewModel() {
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setUpCardView() {
        cardView.delegate = self
        cardView.isUserInteractionEnabled = true
        cardView.image = UIImage(ciImage: viewModel.image)
        cardView.contentMode = .scaleAspectFit
        cardView.setMode(scanMode: scanMode)
    }
    
    private func setUpConfirmButton () {
        confirmButton.setTitle(Language.share.localized(string: "Confirm"), for: .normal)
    }
    
    @IBAction func tapConfirmButton(_ sender: Any) {
        let infoCardDataDict = ["infoCard": info] as [String : String]
        NotificationCenter.default.post(name:  Notification.Name("infoFromScanTextViewController"), object: nil, userInfo: infoCardDataDict)
        navigationController?.popToRootViewController(animated: true)
    }
}

extension ScanTextViewController: CardViewDelegate {
    func getTextFromImage(textImage: CGImage, mode: ScanMode) {
        viewModel.setTextInfoWithMode(textImage: textImage)
    }
}

extension ScanTextViewController: ScanTextViewModelDelegate {
    func didGetCardInfo(info: String) {
        self.info = info
        infoLabel.text = ""
        infoLabel.text?.append("info : \(self.info)")
    }
}
