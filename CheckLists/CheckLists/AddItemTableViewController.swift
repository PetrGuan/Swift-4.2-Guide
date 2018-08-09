//
//  AddItemTableViewController.swift
//  CheckLists
//
//  Created by 管君 on 8/9/18.
//  Copyright © 2018 管君. All rights reserved.
//

import UIKit

class AddItemTableViewController: UITableViewController {

    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done() {
        print("This content is : \(textField.text)")
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
