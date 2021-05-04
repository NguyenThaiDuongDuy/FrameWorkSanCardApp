//
//  ViewController.swift
//  TestApp
//
//  Created by admin on 28/04/2021.
//

import UIKit
import ScanCardFrameWork

class ViewController: UIViewController {
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var issueDateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.receiveDataWithAutoMode), name: NSNotification.Name("autoInformationKey"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.receiveDataWithManualMode), name: NSNotification.Name("manualInformationKey"), object: nil)
    }
    
    @IBAction func tapButton(_ sender: Any) {
        let scanCardViewController = ScanCardViewController(scanMode: .auto)
        navigationController?.pushViewController(scanCardViewController, animated: true)
    }
    
    @IBAction func tapScanCardNumber(_ sender: Any) {
        let scanCardViewController = ScanCardViewController(scanMode: .cardNumber)
        navigationController?.pushViewController(scanCardViewController, animated: true)
    }
    
    @IBAction func tapScanIssueDate(_ sender: Any) {
        let scanCardViewController = ScanCardViewController(scanMode: .issueDate)
        navigationController?.pushViewController(scanCardViewController, animated: true)
    }
    
    
    @objc func receiveDataWithAutoMode(notification: NSNotification) {
        if let cardInfo = notification.userInfo?["infoCard"] as? Card {
            cardNumberTextField.text = cardInfo.cardNumber
            issueDateTextField.text = cardInfo.issueDate
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func receiveDataWithManualMode(notification: NSNotification) {
        guard let mode = notification.userInfo?["mode"] as? ScanMode, let cardInfo = notification.userInfo?["infoCard"] as? Card
        else { return }
        switch mode {
        case .cardNumber:
            cardNumberTextField.text = cardInfo.cardNumber
        case .issueDate:
            issueDateTextField.text = cardInfo.issueDate
        default:
            print(cardInfo)
        }
    }

}

