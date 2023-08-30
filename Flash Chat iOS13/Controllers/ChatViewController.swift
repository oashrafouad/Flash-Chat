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
    @IBOutlet weak var sendButton: UIButton!
    
    var messages: [Message] = []
    
    let db = Firestore.firestore()
    
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        messageTextfield.delegate = self
        
        messageTextfield.enablesReturnKeyAutomatically = true
        
        title = K.appName
        // Change title color to white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.hidesBackButton = true
        
        // Tells the table view to create new cells from the MessageCell nib
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
    }

    
    // Detach listener to prevent firestore from refreshing in background to save battery and data
    override func viewDidDisappear(_ animated: Bool) {
        listener?.remove()
    }
    
    func loadMessages()
    {
        // Gets executed automatically whenever a new message (document) is added via the send button
        listener = db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            self.messages = []
            if error != nil
            {
                print("Error reading data from Firestore: \(error!)")
            }
            else
            {
//                print("Reading data successful")
                if let snapshotDocuments = querySnapshot?.documents
                {
                    for document in snapshotDocuments
                    {
                        let documentData = document.data()
                        if let messageSender = documentData[K.FStore.senderField] as? String, let messageBody = documentData[K.FStore.bodyField] as? String
                        {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        // Check if the array is empty first to avoid index at -1 (when history is cleared)
                        if !self.messages.isEmpty
                        {
                            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageSender = Auth.auth().currentUser?.email, let messageBody = messageTextfield.text {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date()
            ]) { (error) in
                if error != nil
                {
                    print("Error saving data to Firestore: \(error!)")
                }
                else
                {
//                    print("Successfully saved data")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let logOutAlertAction = UIAlertAction(title: "Log out", style: .destructive)
        {_ in
            do {
                try Auth.auth().signOut()
                self.navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(logOutAlertAction)
        alertController.addAction(cancelAlertAction)
        
        present(alertController, animated: true)
    }
    
    // Delete all messages (documents) (only for testing)
    @IBAction func deleteAllMessagesPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Clear History", message: "Are you sure you want to clear messages history?", preferredStyle: .alert)
        
        let deleteAlertAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.db.collection(K.FStore.collectionName).getDocuments { querySnapshot, error in
                if error != nil
                {
                    print("Error deleting documents: \(error!)")
                }
                else
                {
                    for document in querySnapshot!.documents
                    {
                        document.reference.delete()
                    }
                    self.messages = []
//                    print("Successfully deleted data")
                    DispatchQueue.main.async {
                        // Wait before reloading for avoiding bug where a single message would remain after deleting, requiring reloading again
                        Thread.sleep(forTimeInterval: 0.1)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAlertAction)
        alertController.addAction(cancelAlertAction)
        
        self.present(alertController, animated: true)
    }
    
    
    @IBAction func reloadTableView(_ sender: UIBarButtonItem) {
        tableView.reloadData()
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
        
        if !messages.isEmpty
        {
            let message = messages[indexPath.row]
            
            // TODO: use newer method
            cell.messageLabel?.text = message.body
            
            if message.sender == Auth.auth().currentUser?.email
            {
                cell.meAvatarImageView.isHidden = true
                cell.youAvatarImageView.isHidden = false
                cell.messageView.backgroundColor = UIColor(named: K.BrandColors.purple)
                cell.messageLabel.textColor = UIColor(named: K.BrandColors.lightPurple)
                // add padding 10 to the right of the message
            }
            else
            {
                cell.youAvatarImageView.isHidden = true
                cell.meAvatarImageView.isHidden = false
                cell.messageView.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
                cell.messageLabel.textColor = UIColor(named: K.BrandColors.purple)
            }
        }
        return cell
    }
}

extension ChatViewController: UITextFieldDelegate
{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if messageTextfield.hasText
        {
            sendButton.isEnabled = true
        }
        else
        {
            sendButton.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // The IBAction can take any button as argument, so I just created one, sendButton can also be used
        sendPressed(UIButton.init())
        return true
    }
}
