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

    @IBOutlet weak var cardView: CardImageView!
    @IBOutlet weak var cardHolderTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var issueDateTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cardHolderLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var issueDateLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var shadowOfInformationView: ShadowView!
    @IBOutlet weak var confirmButton: BlueStyleButton!
    @IBOutlet weak var informationView: UIStackView!
    @IBOutlet weak var scrollView: ScanTextScrollView!
    @IBOutlet weak var cardHolderStackView: UIStackView!
    @IBOutlet weak var cardNumberStackView: UIStackView!
    @IBOutlet weak var issueDateStackView: UIStackView!
    @IBOutlet weak var expiryDateStackView: UIStackView!
    
    
    init(cardImage: CIImage, mode: ScanMode) {
        viewModel = ScanTextViewModel(image: cardImage, mode: mode)
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCardView()
        setUpConfirmButton()
        setInformationToTextFiled()
        setUpTitleInfoView()
        setUpViewModel()
        setUpScanMode()
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
        setUpShadowView()
    }

    private func setUpCardView() {
        cardView.delegate = self
        cardView.isUserInteractionEnabled = true
        cardView.image = UIImage(ciImage: viewModel.image)
        cardView.contentMode = .scaleAspectFit
    }

    private func setUpShadowView() {
        shadowOfInformationView.cornerRadius = 15.0
    }

    private func setUpConfirmButton () {
        confirmButton.setTitle(Language.share.localized(string: "Confirm"), for: .normal)
    }
    
    private func setUpScanMode() {
        
        cardHolderStackView.isHidden = true
        cardNumberStackView.isHidden = true
        issueDateStackView.isHidden = true
        expiryDateStackView.isHidden = true
        
        cardView.setMode(scanMode: viewModel.scanMode)
        
        switch viewModel.scanMode {
        
        case .cardHolder:
            cardHolderStackView.isHidden = false
          
        case .cardNumber:
            cardNumberStackView.isHidden = false
            
        case .issueDate:
            issueDateStackView.isHidden = false
           
        case .expiryDate:
            expiryDateStackView.isHidden = false
            
        case .auto:
            return
        }
    }


    @IBAction func tapConfirmButton(_ sender: Any) {
        let infoCardDataDict = ["infoCard": self.viewModel.cardInfo, "mode": self.viewModel.scanMode] as [String : Any]
        NotificationCenter.default.post(name:  Notification.Name("manualInformationKey"), object: nil, userInfo: infoCardDataDict)
        navigationController?.popToRootViewController(animated: true)
    }
    

    private func setInformationToTextFiled() {
        cardHolderTextField.text = viewModel.cardInfo.cardHolder
        cardNumberTextField.text = viewModel.cardInfo.cardNumber
        issueDateTextField.text = viewModel.cardInfo.issueDate ?? ""
        expiryDateTextField.text = viewModel.cardInfo.expiryDate ?? ""
    }

    private func setUpTitleInfoView() {
        for stackView in informationView.subviews {
            for view in stackView.subviews {
                if view.isKind(of: UILabel.self) {
                    guard let label = view as? UILabel else { return }
                    label.text = Language.share.localized(string: ScanMode.allModeManual[label.tag].modeString)
                }
            }
        }
    }
}

extension ScanTextViewController: CardViewDelegate {
    func getTextFromImage(textImage: CGImage, mode: ScanMode) {
        viewModel.setTextInfoWithMode(textImage: textImage, mode: mode)
    }
}

extension ScanTextViewController: ScanTextViewModelDelegate {
    func didGetCardInfo() {
        setInformationToTextFiled()
    }
}
