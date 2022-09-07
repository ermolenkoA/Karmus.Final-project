//
//  CutProfileViewController.swift
//  Karmus
//
//  Created by VironIT on 9/7/22.
//

import UIKit
import KeychainSwift
import FirebaseDatabase

protocol GetShortProfileInfoProtocol {
    func getShortProfileInfo(profile: ShortProfileInfoModel, _ friendStatus: FriendsTypes?)
}

final class CutProfileViewController: UIViewController {
    
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var friendActionButton: UIButton!
    
    @IBOutlet private weak var numberOfRestectsLabel: UILabel!
    @IBOutlet private weak var profilePhotoImageView: UIImageView!
    @IBOutlet private weak var numberOfFriendsLabel: UILabel!
    
    @IBOutlet private weak var firstAndSecondNameLabel: UILabel!
    
    private var profile: ShortProfileInfoModel?
    private var friendStatus: FriendsTypes?
    
    private let addToFriendAction = UIAction.init { [weak self] _ in
        guard let profileID = KeychainSwift.shared
                .get(ConstantKeys.currentProfile) else { return }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStartSettings()
    }
    
    private func setStartSettings() {
        guard let profile = profile else {
            return
        }
        
        loginLabel.text = "@" + profile.login
        numberOfRestectsLabel.text =
            String.makeStringFromNumber(profile.numberOfRespects)
        numberOfFriendsLabel.text = String.makeStringFromNumber(profile.numberOfFriends)
        profilePhotoImageView.image = profile.photo
        firstAndSecondNameLabel.text = profile.firstName + " " + profile.secondName
    }
    
    private func settingsForFriendActionButton() {
        switch friendStatus {
        
        case .followers:
            friendActionButton.setTitle("Принять запрос", for: .normal)
            friendActionButton.backgroundColor = #colorLiteral(red: 0, green: 0.1107608194, blue: 1, alpha: 1)
            friendActionButton.addAction(<#T##action: UIAction##UIAction#>, for: .touchUpInside)
        case .friends:
            friendActionButton.setTitle("Удалить из друзей", for: .normal)
            friendActionButton.backgroundColor = #colorLiteral(red: 1, green: 0.589956837, blue: 0.5594668988, alpha: 1)
        case .requests:
            friendActionButton.setTitle("Отменить запрос", for: .normal)
            friendActionButton.backgroundColor = #colorLiteral(red: 0.3708083834, green: 0.5851160905, blue: 0.8618912101, alpha: 1)
        default:
            friendActionButton.setTitle("Добавить в друзья", for: .normal)
            friendActionButton.backgroundColor = .systemBlue
        }
    }

}

extension CutProfileViewController: GetShortProfileInfoProtocol {
    func getShortProfileInfo(profile: ShortProfileInfoModel, _ friendStatus: FriendsTypes? = nil) {
        self.profile = profile
        self.friendStatus = friendStatus
    }
}
