//
//  ViewController.swift
//  RabbleWabble
//
//  Created by Peter on 2018/10/28.
//  Copyright © 2018 Peter. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {

    // MARK:- Instance Properties
    public var questionGroup = QuestionGroup.basicPhrases()
    public var questionIndex = 0

    public var correctCount = 0
    public var incorrectCount = 0

    public var questionView: QuestionView! {
        guard isViewLoaded else {
            return nil
        }
        return view as? QuestionView
    }

    // Mark:- View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        showQuestion()
    }

    private func showQuestion() {
        let question = questionGroup.questions[questionIndex]

        questionView.answerLabel.text = question.answer
        questionView.promptLabel.text = question.prompt
        questionView.hintLabel.text = question.hint

        questionView.answerLabel.isHidden = true
        questionView.hintLabel.isHidden = true
    }

    @IBAction func toggleAnswerLabels(_ sender: Any) {
        questionView.answerLabel.isHidden = !questionView.answerLabel.isHidden
        questionView.hintLabel.isHidden = !questionView.hintLabel.isHidden
    }

    @IBAction func handleCorrect(_ sender: Any) {
        correctCount += 1
        questionView.correctCountLabel.text = "\(correctCount)"
        showQuestion()
    }

    @IBAction func handleIncorrect(_ sender: Any) {
        incorrectCount += 1
        questionView.incorrectCountLabel.text = "\(incorrectCount)"
        showQuestion()
    }

    @IBAction func showNextQuestion() {
        questionIndex += 1
        guard questionIndex < questionGroup.questions.count else {
            // TODO:- Handle this...!
            return
        }
        showQuestion()
    }
}

