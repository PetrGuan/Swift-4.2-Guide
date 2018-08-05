//
//  ViewController.swift
//  BullsEye
//
//  Created by 管君 on 8/4/18.
//  Copyright © 2018 管君. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var currentSliderValue = 50
    var targetValue = 0
    var totalScore = 0
    var round = 0
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        currentSliderValue = lroundf(sender.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize slider
        let thumbImageNormal = #imageLiteral(resourceName: "SliderThumb-Normal")
        slider.setThumbImage(thumbImageNormal, for: .normal)
        
        let thumbImageHighlighted = #imageLiteral(resourceName: "SliderThumb-Highlighted")
        slider.setThumbImage(thumbImageHighlighted, for: .highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        let trackLeftImage = #imageLiteral(resourceName: "SliderTrackLeft")
        let trackLeftResizable =
            trackLeftImage.resizableImage(withCapInsets: insets)
        slider.setMinimumTrackImage(trackLeftResizable, for: .normal)
        
        let trackRightImage = #imageLiteral(resourceName: "SliderTrackRight")
        let trackRightResizable =
            trackRightImage.resizableImage(withCapInsets: insets)
        slider.setMaximumTrackImage(trackRightResizable, for: .normal)
        
        startNewRound()
    }

    @IBAction func startOver(_ sender: UIButton) {
        startNewGame()
    }
    
    @IBAction func showAlert() {
        let difference = abs(currentSliderValue - targetValue)
        var points = 100 - difference
        
        let alertTitle: String
        if difference == 0 {
            alertTitle = "Perfect!"
            points += 100 // 100 bonus
        } else if difference < 5 {
            alertTitle = "You almost had it!"
            if difference == 1 {
                points += 50
            }
        } else if difference < 10 {
            alertTitle = "Pretty good!"
        } else {
            alertTitle = "Not even close..."
        }
        totalScore += points
        
        let message = "You scored \(points)"
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            self.startNewRound()
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        targetLabel.text = String(targetValue)
        scoreLabel.text = String(totalScore)
        roundLabel.text = String(round)
    }
    
    func startNewRound() {
        currentSliderValue = 50
        targetValue = Int.random(in: 1...100)
        slider.value = Float(currentSliderValue)
        round += 1
        updateLabels()
    }
    
    func startNewGame() {
        totalScore = 0
        round = 0
        startNewRound()
    }
}

