//
//  ConversationViewController.swift
//  Karmus
//
//  Created by VironIT on 9/11/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import KeychainSwift
import Kingfisher

final class ConversationViewController: MessagesViewController {

    // MARK: - Private Properties
    private var mainActivityIndicator: UIActivityIndicatorView!
    
    private var newNavBarView: UIView!
    private var profilePhotoImageView: UIImageView!
    private var onlineStatusView: UIView!
    private var profileNameLabel: UILabel!
    private var backgroundImageView: UIImageView!
    
    private var members = [Sender]()
    private var messages = [Message]()
    
    private var chatID: String?
    private var interlocutor: ProfileForChatModel?
    private var login: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let backItem = UIBarButtonItem()
        backItem.title = "Вернуться к чату"
        navigationItem.backBarButtonItem = backItem
        
        startSettings()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        mainActivityIndicator = UIActivityIndicatorView()
        mainActivityIndicator.frame = view.frame
        mainActivityIndicator.color = .label
        mainActivityIndicator.style = .large
        view.addSubview(mainActivityIndicator)
        
        navigationBarSettings()
        
        if let chatID = chatID {
            
            startSearching()
            FireBaseDataBaseManager.getChatMessages(chatID) { [weak self] messages in
                self?.messages = messages
                
                if !messages.isEmpty
                    && !messages.last!.isRead
                    && messages.last!.sender.senderId != self?.login {
                    
                    FireBaseDataBaseManager.readAllMessage(chatID)
                    
                }
                
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                self?.stopSearching()
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let chatID = chatID {
            FireBaseDataBaseManager.removeCurrentChatObserver(chatID)
        }
        newNavBarView = nil
        profilePhotoImageView = nil
        onlineStatusView = nil
        profileNameLabel = nil
        backgroundImageView = nil
        mainActivityIndicator = nil
        if let interlocutor = interlocutor {
            FireBaseDataBaseManager.removeObserverFromOnlineStatus(interlocutor.login)
        }
        
    }
    
     // MARK: - Private functions
    
    private func startSearching() {
        mainActivityIndicator.startAnimating()
        messagesCollectionView.isUserInteractionEnabled = false
    }
    
    private func stopSearching() {
        mainActivityIndicator.stopAnimating()
        messagesCollectionView.isUserInteractionEnabled = true
    }
    
    private func startSettings() {
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        messagesCollectionView.backgroundColor = .clear
        
        messageInputBar.backgroundView.backgroundColor = #colorLiteral(red: 0.01331504728, green: 0.4268253922, blue: 0.9692421556, alpha: 1)
        
        messageInputBar.inputTextView.backgroundColor = #colorLiteral(red: 0.2962377071, green: 0.5318125486, blue: 0.9692421556, alpha: 1)
        messageInputBar.inputTextView.layer.cornerRadius = 10
        
        messageInputBar.inputTextView.placeholder = "Сообщение..."
        messageInputBar.inputTextView.placeholderTextColor = .white
        
        messageInputBar.inputTextView.textColor = .white
        
        messageInputBar.sendButton.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.tintColor = .white
        
        messageInputBar.sendButton.transform = CGAffineTransform(scaleX: 0.8, y: 1)
        
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        backgroundImageView.image = UIImage(named: "pngChatBG")
        backgroundImageView.layer.masksToBounds = true
        backgroundImageView.contentMode = .scaleAspectFill

        view.backgroundColor = #colorLiteral(red: 0.3236172476, green: 0.7529074694, blue: 1, alpha: 1)
        view.insertSubview(backgroundImageView, at: 0)
        
    }
    
    private func navigationBarSettings() {
        
        guard let navController = navigationController, let interlocutor = interlocutor else {
            return
        }
        
        let navBarHeight = navController.navigationBar.frame.height
        let navBarWidth = navController.navigationBar.frame.width
        
        newNavBarView = .init(frame: CGRect(x: 0, y: 0, width: navBarWidth*0.7, height: navBarHeight))
        
        profilePhotoImageView = .init(frame: CGRect(x: 0, y: navBarHeight*0.1, width: navBarHeight*0.8, height: navBarHeight*0.8))
        profilePhotoImageView.image = interlocutor.photo
        profilePhotoImageView.contentMode = .scaleAspectFill
        profilePhotoImageView.backgroundColor = .white
        profilePhotoImageView.layer.masksToBounds = true
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.height/2
        
        onlineStatusView = .init(frame: CGRect(x: navBarHeight*0.5, y: navBarHeight*0.6, width: navBarHeight*0.3, height: navBarHeight*0.3))
        onlineStatusView.backgroundColor = .green
        onlineStatusView.layer.cornerRadius = navBarHeight*0.15
        
        onlineStatusView.isHidden = true
        
        FireBaseDataBaseManager.putObserverOnOnlineStatus(interlocutor.login) { [weak self] status in
            self?.onlineStatusView?.isHidden = status != FBOnlineStatuses.online
        }
        
        profileNameLabel = .init(frame: CGRect(x: 10+navBarHeight*0.8, y: navBarHeight*0.5-10, width: navBarWidth*0.7 - navBarHeight*1.3, height: 20))
        profileNameLabel.text = interlocutor.name
        profileNameLabel.font = UIFont.systemFont(ofSize: 18)
        profileNameLabel.textColor = .label
        
        newNavBarView.addSubview(profilePhotoImageView)
        newNavBarView.addSubview(onlineStatusView)
        newNavBarView.addSubview(profileNameLabel)
        
        newNavBarView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openShotProfileInfo(sender:)))
        newNavBarView.addGestureRecognizer(tap)
        
        navigationItem.titleView = newNavBarView
 
    }
    
    @objc private func openShotProfileInfo(sender: Any?) {
        
        guard let interlocutor = self.interlocutor else {
            return
        }
        
        if let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile) {
            startSearching()
            FireBaseDataBaseManager.getProfileInfo(interlocutor.login) { profile in
                guard let profile = profile else {
                    return
                }
                
                FireBaseDataBaseManager.getFriendStatus(profileID, friendLogin: interlocutor.login) { [weak self] friendType in
                    
                    let shortProfile = ShortProfileInfoModel(login: self!.interlocutor!.login,
                                                             firstName: self!.interlocutor!.name,
                                                             secondName: " ",
                                                             numberOfRespects: String.makeStringFromNumber(profile.numberOfRespects ?? 0),
                                                             numberOfFriends: String.makeStringFromNumber(profile.numberOfFriends ?? 0),
                                                             photo: profile.photo,
                                                             profileType: profile.profileType ?? "user")
                    self?.stopSearching()
                    self?.showShortProfileInfo(profile: shortProfile, friendStatus: friendType)
                    
                }
            }
            
            
        }
    }
    
    private func showShortProfileInfo(profile: ShortProfileInfoModel, friendStatus: FriendsTypes?) {
        
        let storyboard = UIStoryboard(name: StoryboardNames.cutProfileScreen, bundle: nil)
        
        guard let shortProfileInfoVC = storyboard.instantiateInitialViewController() else {
            return
        }
        
        shortProfileInfoVC.modalPresentationStyle = .popover
        let popOverVC = shortProfileInfoVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = view
        popOverVC?.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        shortProfileInfoVC.preferredContentSize = CGSize(width: view.frame.width, height: 240 + view.frame.width*0.3)
        popOverVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        (shortProfileInfoVC as? GetShortProfileInfoProtocol)?.getShortProfileInfo(profile: profile, friendStatus, conclusion: { [weak self] in
            
            shortProfileInfoVC.dismiss(animated: true) {
                
                let storyboard = UIStoryboard(name: StoryboardNames.fullProfileScreen, bundle: nil)
                
                guard let fullProfileInfoVC = storyboard.instantiateInitialViewController() else {
                    return
                }
                
                (fullProfileInfoVC as? SetLoginProtocol)?.setLogin(login: profile.login)
                self?.navigationController?.pushViewController(fullProfileInfoVC, animated: true)
            }
            
        })
        
        (shortProfileInfoVC as? SetSenderProtocol)?.setSender(self)
        
        self.present(shortProfileInfoVC, animated: true)
        
    }

}

// MARK: - InputBarAccessoryViewDelegate

extension ConversationViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let resultText = text.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
        
        guard !resultText.isEmpty, let interlocutor = interlocutor else {
            return
        }
        
        inputBar.inputTextView.text = nil
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        if let chatID = chatID {
            
            FireBaseDataBaseManager.sendMessage(chatID, message: Message(sender: members.first!,
                                                                         messageId: String(messages.count),
                                                                         sentDate: Date(),
                                                                         kind: .text(text),
                                                                         isRead: false)) { [weak self] success in
                if !success {
                    showAlert("Невозможно отправить сообщение",
                              "Повторите попытку через несколько минут",
                              where: self)
                }
            }
            
        } else {
            
            FireBaseDataBaseManager.createNewChat(interlocutorLogin: interlocutor.login,
                                                  message: Message.init(sender: members.first!,
                                                                        messageId: "0",
                                                                        sentDate: Date(),
                                                                        kind: .text(text),
                                                                        isRead: false) ) { [weak self] chatID in
                guard let chatID = chatID else {
                    showAlert("Невозможно создать чат",
                              "Обновите чат, возможно пользователь изменил свои данные",
                              where: self)
                    return
                }
                
                self?.chatID = chatID
                self?.startSearching()
                FireBaseDataBaseManager.getChatMessages(chatID) { [weak self] messages in
                    self?.messages = messages
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                    self?.stopSearching()
                }
                
            }
            
        }
        
    }
    
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ConversationViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

// MARK: - MessagesDataSource

extension ConversationViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        members.first { $0.senderId == login }!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
        
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return NSAttributedString(string: formatter.string(from: message.sentDate),
                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 13
    }
    
    func messageBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath,
                                     in messagesCollectionView: MessagesCollectionView) -> LabelAlignment? {
        
        message.sender.senderId == login ? LabelAlignment(textAlignment: .right,
                                                          textInsets: .init(top: 0, left: 0, bottom: 0, right: 10))
            : LabelAlignment(textAlignment: .left,
                             textInsets: .init(top: 0, left: 10, bottom: 0, right: 0))
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == login ? #colorLiteral(red: 0.06696602717, green: 0.3071031543, blue: 1, alpha: 0.904484161) : #colorLiteral(red: 0.7784107499, green: 0.7801650059, blue: 0.8069347155, alpha: 0.8453285531)
        
    }
}

// MARK: - GetConversationInfoProtocol

extension ConversationViewController: GetConversationInfoProtocol {
    func getConversationInfo(interlocutor: ProfileForChatModel) {
        
        guard let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) else {
            forceQuitFromProfile()
            return
        }
        self.login = login
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
