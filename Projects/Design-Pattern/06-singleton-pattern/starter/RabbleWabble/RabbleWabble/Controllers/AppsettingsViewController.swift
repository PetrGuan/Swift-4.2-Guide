//
//  AppsettingsViewController.swift
//  RabbleWabble
//
//  Created by 管君 on 12/1/18.
//  Copyright © 2018 Razeware, LLC. All rights reserved.
//

import UIKit

public class AppsettingsViewController: UITableViewController {
  // MARK:- Properties
  public let appSettings = AppSettings.shared
  private let cellIdentifier = "basicCell"
  
  // MARK:- View Life Cycle
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
  }
  
}

// MARK:- UITableViewDataSource
extension AppsettingsViewController {
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return AppSettings.QuestionStrategyType.allCases.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let questionStrategyType = AppSettings.QuestionStrategyType.allCases[indexPath.row]
    cell.textLabel?.text = questionStrategyType.title()
    
    if appSettings.questionStrategyType == questionStrategyType {
      cell.accessoryType = .checkmark
    }
    else {
      cell.accessoryType = .none
    }
    return cell
  }
  
}

// MARK:- UITableViewDelegate
extension AppsettingsViewController {
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let questionStrategyType = AppSettings.QuestionStrategyType.allCases[indexPath.row]
    appSettings.questionStrategyType = questionStrategyType
    tableView.reloadData()
  }
}
