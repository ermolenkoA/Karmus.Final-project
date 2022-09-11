//
//  ConversationViewController.swift
//  Karmus
//
//  Created by VironIT on 9/11/22.
//

import UIKit
import MessageKit
import KeychainSwift

protocol GetConversationInfoProtocol {
    func getConversationInfo(interlocutor: ProfileForChatModel)
}

protocol GetChatIDProtocol {
    func getChatID(_ chatID: String)
}

final class ConversationViewController: MessagesViewController {

    // MARK: - Private Properties
    
    private var members = [Sender]()
    private var messages = [Message]()
    
    private var chatID: String?
    private var interlocutor: ProfileForChatModel?
    private var login: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.dataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        if let chatID = chatID {
            FireBaseDataBaseManager.getChatMessages(chatID) { [weak self] messages in
                self?.messages = messages
                self?.messagesCollectionView.reloadData()
            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let chatID = chatID {
            FireBaseDataBaseManager.removeCurrentChatObserver(chatID)
        }
    }

}

// MARK: - MessagesDataSource

extension ConversationViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        members.first { $0.senderId == login }!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {
    
}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {
    
}

// MARK: - GetConversationInfoProtocol

extension ConversationViewController: GetConversationInfoProtocol {
    func getConversationInfo(interlocutor: ProfileForChatModel) {
        
        guard let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) else {
            forceQuitFromProfile()
            return
        }
    
        members = [Sender(senderId: login, displayName: ""), Sender(senderId: interlocutor.login, displayName: "")]
        self.interlocutor = interlocutor
        
    }
}

// MARK: - GetChatIDProtocol

extension ConversationViewController: GetChatIDProtocol {
    func getChatID(_ chatID: String) {
        self.chatID = chatID
    }
}
