//
//  ChecklistItem.swift
//  CheckLists
//
//  Created by 管君 on 8/8/18.
//  Copyright © 2018 管君. All rights reserved.
//

import Foundation

class ChecklistItem {
    var text = ""
    var checked = false
    
    func toggleChecked() {
        checked = !checked
    }
}
