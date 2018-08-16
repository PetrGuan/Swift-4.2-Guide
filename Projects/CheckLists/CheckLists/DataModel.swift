//
//  DataModel.swift
//  CheckLists
//
//  Created by 管君 on 8/14/18.
//  Copyright © 2018 管君. All rights reserved.
//

import Foundation

class DataModel {
    var lists = [Checklist]()
    
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }
    
    init() {
        loadCheckLists()
        registerDefaults()
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("CheckLists.plist")
    }
    
    func saveCheckLists() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(),
                           options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array!")
        }
    }
    
    func loadCheckLists() {
        let decoder = PropertyListDecoder()
        do {
            let path = dataFilePath()
            if let data = try? Data(contentsOf: path) {
                lists = try decoder.decode([Checklist].self, from: data)
            }
        } catch {
            print("Error decoding item array!")
        }
    }
    
    func registerDefaults() {
        let dictionary = ["ChecklistIndex": -1]
        
        UserDefaults.standard.register(defaults: dictionary)
    }
}
