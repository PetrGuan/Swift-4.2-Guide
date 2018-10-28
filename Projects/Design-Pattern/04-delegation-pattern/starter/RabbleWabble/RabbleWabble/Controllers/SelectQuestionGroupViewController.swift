//
//  SelectQuestionGroupViewController.swift
//  RabbleWabble
//
//  Created by Peter on 2018/10/28.
//  Copyright © 2018 Razeware, LLC. All rights reserved.
//

import UIKit

public class SelectQuestionGroupViewController: UIViewController {

    // MARK:- Outlets
    @IBOutlet internal var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }

    // MARK:- Properties
    public let questionGroups = QuestionGroup.allGroups()
    private var selectedQuestionGroup: QuestionGroup!

}

extension SelectQuestionGroupViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionGroups.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionGroupCell", for: indexPath) as! QuestionGroupCell
        let questionGroup = questionGroups[indexPath.row]
        cell.titleLabel.text = questionGroup.title
        return cell
    }

}
