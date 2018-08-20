//
//  ChecklistItem.swift
//  CheckLists
//
//  Created by 管君 on 8/8/18.
//  Copyright © 2018 管君. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, Codable {
    var text = ""
    var checked = false
    
    init(text: String = "", checked: Bool = false) {
        self.text = text
        self.checked = checked
    }
    
    func toggleChecked() {
        checked = !checked
    }
}
