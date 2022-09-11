//
//  ChatsTableViewCell.swift
//  Karmus
//
//  Created by VironIT on 9/10/22.
//

import UIKit

final class ChatsTVCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var profilePhotoImageView: UIImageView!
    @IBOutlet private weak var onlineStatusView: UIView!
    
    @IBOutlet private weak var firstAndSecondNamesLabel: UILabel!
    
    @IBOutlet private weak var senderLabel: UILabel!
    @IBOutlet private weak var lastMessageLabel: UILabel!
    @IBOutlet private weak var timeFromMessageSentLabel: UILabel!
    
    @IBOutlet private weak var unreadMessagesView: UIView!
    @IBOutlet private weak var numberOfUnreadMessagesLabel: UILabel!
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
