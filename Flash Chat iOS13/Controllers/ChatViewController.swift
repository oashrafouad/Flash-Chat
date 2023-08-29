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
    
    var messages: [Message] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        title = K.appName
        // Change title color to white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.hidesBackButton = true
        
        // Tells the table view to create new cells from the MessageCell nib
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
    }
    
    func loadMessages()
    {
        // Gets executed automatically whenever a new message (document) is added via the send button
        db.collection(K.FStore.collectionName).addSnapshotListener { querySnapshot, error in
            self.messages = []
            
            if error != nil
            {
                print("Error reading data from Firestore: \(error!)")
            }
            else
            {
                print("Reading data successful")
                if let snapshotDocuments = querySnapshot?.documents
                {
                    for document in snapshotDocuments
                    {
                        let documentData = document.data()
                        if let messageSender = documentData[K.FStore.senderField] as? String, let messageBody = documentData[K.FStore.bodyField] as? String
                        {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
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
                K.FStore.bodyField: messageBody
            ]) { (error) in
                if error != nil
                {
                    print("Error saving data to Firestore: \(error!)")
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
                    self.tableView.reloadData()
                }
            }
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAlertAction)
        alertController.addAction(cancelAlertAction)
        
        self.present(alertController, animated: true)
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
