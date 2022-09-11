//
//  ChatViewController.swift
//  Karmus
//
//  Created by VironIT on 9/10/22.
//

import UIKit

final class ChatViewController: UIViewController {

    @IBOutlet private weak var chatsTableView: UITableView!
    
    private var chats = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        
        chatsTableView.separatorStyle = .none
    }
    
    @IBAction func createNewChat(_ sender: Any) {
        let storyboard = UIStoryboard(name: StoryboardNames.createNewChat, bundle: nil)
        let createNewChatVC = storyboard.instantiateInitialViewController()!
        self.navigationController?.pushViewController(createNewChatVC, animated: true)
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatsCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.5
    }
    
    
}
