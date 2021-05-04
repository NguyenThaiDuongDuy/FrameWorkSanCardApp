//
//  ViewController.swift
//  AppTest
//
//  Created by admin on 28/04/2021.
//

import UIKit
import ScanCardFrameWork

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func tapButton(_ sender: Any) {
        let vc = ScanCardViewController(modeScan: .all)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

