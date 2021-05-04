//
//  ViewController.swift
//  TestApp
//
//  Created by admin on 28/04/2021.
//

import UIKit
import ScanCardFrameWork

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func tapButton(_ sender: Any) {
        let scanCardViewController = ScanCardViewController()
        navigationController?.pushViewController(scanCardViewController, animated: true)
    }
    
}

