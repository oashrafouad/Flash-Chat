//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "⚡️FlashChat"
        
//        titleLabel.text = ""
//        let titleText = "⚡️FlashChat"
//        var number = 0.0
//
//        for letter in titleText
//        {
//            Timer.scheduledTimer(withTimeInterval: 0.1 + number, repeats: false)
//            { timer in
//                self.titleLabel.text?.append(letter)
//            }
//            number += 0.1
//
//        }
    }
}
