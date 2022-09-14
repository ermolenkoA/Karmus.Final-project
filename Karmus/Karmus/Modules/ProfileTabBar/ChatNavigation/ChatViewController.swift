//
//  ChatViewController.swift
//  Karmus
//
//  Created by VironIT on 9/10/22.
//

import UIKit
import KeychainSwift

final class ChatViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var chatListIsEmptyLabel: UILabel!
    @IBOutlet private weak var chatsTableView: UITableView!
    
    // MARK: - Private Properties
    
    private var chats = [Chat]()
    
    // MARK: - Life Cycle
    
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
    
    // MARK: - Private functions
    
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
    
    // MARK: - IBAction
    
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

// MARK: - UITableViewDelegate

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = chats[indexPath.row]
        let conversationVC = ConversationViewController()
        (conversationVC as GetChatIDProtocol).getChatID(chat.chatID)
        (conversationVC as GetConversationInfoProtocol).getConversationInfo(interlocutor: chat.interlocutor)
        navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let chatID = chats[indexPath.row].chatID
        
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            chats.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            chatListIsEmptyLabel.isHidden = !chats.isEmpty
            tableView.endUpdates()
        }
        FireBaseDataBaseManager.deleteChat(chatID)
        
    }
    
}

// MARK: - UITableViewDataSource

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
