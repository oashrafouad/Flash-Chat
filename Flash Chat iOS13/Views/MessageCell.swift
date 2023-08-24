//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by Omar Ashraf on 25/08/2023.
//  Copyright © 2023 Angela Yu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageView.layer.cornerRadius = 13
//        messageView.layer.cornerRadius = messageView.frame.size.height / 5
//        print(messageView.frame.size.height)
        
        // Increase line spacing of messageLabel
        // Create a paragraph style with increased line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5

        // Create an attributed string with the increased line spacing
        let attributedString = NSAttributedString(string: "Placeholder text", attributes: [.paragraphStyle: paragraphStyle])

        // Apply the attributed (styled) string to messageLabel
        messageLabel.attributedText = attributedString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
