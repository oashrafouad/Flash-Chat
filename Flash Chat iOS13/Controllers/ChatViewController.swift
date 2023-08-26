//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages = [
        Message(sender: "1@2.com", body: "Hey!"),
        Message(sender: "omar@gmail.com", body: "Hello!"),
        Message(sender: "1@2.com", body: "How are you?"),
        // generate another message with long sample message text
        Message(sender: "omar@gmail.com", body: "Hey there! Just wanted to check in and see how you're doing. I hope everything is going well for you. Remember that you're awesome and capable of achieving great things. If you ever need someone to talk to, I'm here for you. Stay positive and keep pushing forward! Wishing you a fantastic day ahead. Take care and talk to you soon!")
    ]
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        title = K.appName
        // Change title color to white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.hidesBackButton = true
        
        // Tells the table view to create new cells from the MessageCell nib
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageSender = Auth.auth().currentUser?.email, let messageBody = messageTextfield.text {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody
            ]) { (error) in
                if error != nil
                {
                    print(error!)
                }
                else
                {
                    print("Successfully saved data")
                    self.messageTextfield.text = ""
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

//MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the MessageCell nib
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        // TODO: use newer method
        cell.messageLabel?.text = messages[indexPath.row].body
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Dismiss keyboard when pressing on any tableview cell
        messageTextfield.endEditing(true)

    }
}
