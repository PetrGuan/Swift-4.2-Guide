//
//  AddItemTableViewController.swift
//  CheckLists
//
//  Created by 管君 on 8/9/18.
//  Copyright © 2018 管君. All rights reserved.
//

import UIKit

protocol AddItemTableViewControllerDelegate: class {
    func addItemViewControllerDidCancel(_ controller: AddItemTableViewController)
    
    func addItemViewController(_ controller: AddItemTableViewController,
                               didFinishAdding item: ChecklistItem)
}

class AddItemTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: AddItemTableViewControllerDelegate?
    
    @IBAction func cancel() {
        delegate?.addItemViewControllerDidCancel(self)
        
    }
    
    @IBAction func done() {
        let item = ChecklistItem()
        item.text = textField.text!
        item.checked = false
        delegate?.addItemViewController(self, didFinishAdding: item)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        if newText.isEmpty {
            doneBarButton.isEnabled = false
        }
        else {
            doneBarButton.isEnabled = true
        }
        return true
    }
}
