//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text
        {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if error != nil
                {
                    print(error!)
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = error!.localizedDescription
                    
                }
                else
                {
                    // Go to ChatViewController
                    self.performSegue(withIdentifier: "LoginToChat", sender: self)
                }
            }
            
        }
        
    }
    
}
