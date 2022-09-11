//
//  ChatViewController.swift
//  Karmus
//
//  Created by VironIT on 9/10/22.
//

import UIKit
import KeychainSwift

final class ChatViewController: UIViewController {

    
    @IBOutlet private weak var mainActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var chatListIsEmptyLabel: UILabel!
    
    @IBOutlet private weak var chatsTableView: UITableView!
    
    private var chats = [Chat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        chatsTableView.separatorStyle = .none
        
        FireBaseDataBaseManager.createChatsObserver { [weak self] in
            self?.getChats()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getChats()
    }
    
    private func startSearching() {
        mainActivityIndicatorView.startAnimating()
        chatListIsEmptyLabel.isHidden = true
        chatsTableView.isUserInteractionEnabled = false
    }
    
    private func stopSearching() {
        mainActivityIndicatorView.stopAnimating()
        chatsTableView.isUserInteractionEnabled = true
    }
    
    private func getChats() {
        
        startSearching()
        
        FireBaseDataBaseManager.getChatsIDs { chatsIDs in
            
        FireBaseDataBaseManager.getChatsInfo(chatsIDs) { [weak self] chats in
                self?.chats = chats
                self?.chatsTableView.reloadData()
                self?.chatListIsEmptyLabel.isHidden = !chats.isEmpty
                self?.stopSearching()
            }
            
        }
    }
    
    @IBAction func createNewChat(_ sender: Any) {
        let storyboard = UIStoryboard(name: StoryboardNames.createNewChat, bundle: nil)
        let createNewChatVC = storyboard.instantiateInitialViewController()!
        (createNewChatVC as? CreateNewChatConclusionProtocol)?.getConclusion{ [weak self] interlocutor, chatID in
            
            let conversationVC = ConversationViewController()
            
            if let chatID = chatID {
                (conversationVC as GetChatIDProtocol).getChatID(chatID)
            }
            
            (conversationVC as GetConversationInfoProtocol).getConversationInfo(interlocutor: interlocutor)
            createNewChatVC.navigationController?.popViewController(animated: true)
            self?.navigationController?.pushViewController(conversationVC, animated: true)
        
        }
        
        navigationController?.pushViewController(createNewChatVC, animated: true)
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = chats[indexPath.row]
        let conversationVC = ConversationViewController()
        (conversationVC as GetChatIDProtocol).getChatID(chat.chatID)
        (conversationVC as GetConversationInfoProtocol).getConversationInfo(interlocutor: chat.interlocutor)
        navigationController?.pushViewController(conversationVC, animated: true)
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatsCell", for: indexPath)
        
        (cell as? GetChatProtocol)?.getChat(chats[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.5
    }
    
    
}
