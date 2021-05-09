//
//  ViewController.swift
//  TestApp
//
//  Created by admin on 28/04/2021.
//

import UIKit
import ScanCardFrameWork

class ViewController: UIViewController {
    
    var scanMode: ScanMode = .auto
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        infoLabel.text = "info"
    }
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDataWithAutoMode), name: NSNotification.Name("infoFromScanCardViewController"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDataWithManualMode), name: NSNotification.Name("infoFromScanTextViewController"), object: nil)
    }
    
    @IBAction func tapButton(_ sender: Any) {
        let scanCardViewController = ScanCardViewController(scanMode: scanMode)
        navigationController?.pushViewController(scanCardViewController, animated: true)
    }
    
    @objc func receiveDataWithAutoMode(notification: NSNotification) {
        infoLabel.text = "info"
        if let cardInfo = notification.userInfo?["infoCard"] as? [String] {
            cardInfo.forEach({ (string) in
                infoLabel.text?.append("\n\(string)")
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func receiveDataWithManualMode(notification: NSNotification) {
        guard let cardInfo = notification.userInfo?["infoCard"] as? String
        else { return }
        infoLabel.text = "info: "
        infoLabel.text?.append(cardInfo)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ScanMode.allMode.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ScanMode.allMode[indexPath.item].modeString
        cell.selectionStyle = .none
        if
            let selectedRows = tableView.indexPathsForSelectedRows,
            selectedRows.contains(indexPath)
        {
            cell.accessoryView = UIImageView(image: UIImage(named: "check_circle"))
            
        } else {
            cell.accessoryView = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryView = UIImageView(image: UIImage(named: "check_circle"))
        scanMode = ScanMode.allMode[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryView = .none
    }
}
