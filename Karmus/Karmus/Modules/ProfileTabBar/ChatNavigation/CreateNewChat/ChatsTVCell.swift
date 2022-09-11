//
//  ChatsTableViewCell.swift
//  Karmus
//
//  Created by VironIT on 9/10/22.
//

import UIKit
import KeychainSwift
import FirebaseDatabase

protocol GetChatProtocol {
    func getChat(_ chat: Chat)
}

final class ChatsTVCell: UITableViewCell {

    // MARK: - IBOutlet
    
    
    @IBOutlet private weak var profileTypeImageView: UIImageView!
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

extension ChatsTVCell: GetChatProtocol {
    func getChat(_ chat: Chat) {
        
        guard let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) else {
            forceQuitFromProfile()
            return
        }
        
        profilePhotoImageView.image = chat.interlocutor.photo
        
        switch chat.interlocutor.profileType {
        
        case FBProfileTypes.sponsor:
            profileTypeImageView.image = UIImage(named: "iconSponsor")
        case FBProfileTypes.admin:
            profileTypeImageView.image = UIImage(named: "iconAdmin")
        default:
            break
        }
        
        switch chat.interlocutor.onlineStatus {
        
        case FBOnlineStatuses.offline:
            onlineStatusView.backgroundColor = .lightGray
        case FBOnlineStatuses.online:
            onlineStatusView.backgroundColor = .green
        case FBOnlineStatuses.blocked:
            onlineStatusView.backgroundColor = .red
        default:
            onlineStatusView.backgroundColor = .clear
            
        }
        
        firstAndSecondNamesLabel.text = chat.interlocutor.name
        
        let lastMessage = chat.messages.last!
        
        if lastMessage.sender != login{
            senderLabel.isHidden = true
        }
        
        lastMessageLabel.text = lastMessage.messageText
        timeFromMessageSentLabel.text = String.messageDate(lastMessage.sentDate)
        
        if lastMessage.isRead {
            unreadMessagesView.isHidden = true
        } else if !senderLabel.isHidden {
            unreadMessagesView.isHidden = false
            numberOfUnreadMessagesLabel.isHidden = true
            unreadMessagesView.layer.cornerRadius = 12
        } else {
            var numberOfUnreadMessage = UInt(0)
            for message in chat.messages.reversed() {
                guard !message.isRead else {
                    break
                }
                
                numberOfUnreadMessage += 1
            }
            
            unreadMessagesView.isHidden = false
            numberOfUnreadMessagesLabel.isHidden = false
            numberOfUnreadMessagesLabel.text = numberOfUnreadMessage < 100 ? String(numberOfUnreadMessage) : "99+"
        }
        
        
        
    }
    
}
