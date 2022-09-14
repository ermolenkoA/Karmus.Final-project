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
    func getShortProfileInfo(profile: ShortProfileInfoModel,
    _ friendStatus: FriendsTypes?,
    conclusion: (() -> ())?)
}

final class CutProfileViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var buttonActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var numberOfRestectsLabel: UILabel!
    
    @IBOutlet private weak var profileTypeImageView: UIImageView!
    @IBOutlet private weak var profilePhotoImageView: UIImageView!
    
    @IBOutlet private weak var numberOfFriendsLabel: UILabel!
    
    @IBOutlet private weak var firstAndSecondNameLabel: UILabel!
    
    @IBOutlet private weak var fullInfoButton: UIButton!
    @IBOutlet private weak var friendActionButton: UIButton!
    
    // MARK: - Private Properties
    
    private var conclusion: (() -> Void)?
    private var friendProfile: ShortProfileInfoModel?
    private var friendStatus: FriendsTypes?
    private let myProfileID = KeychainSwift.shared.get(ConstantKeys.currentProfile)
    private let myLogin = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePhotoImageView.layer.cornerRadius = (view.frame.width - 40) * 0.15
        setStartSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        conclusion = nil
    }
    
    private func setStartSettings() {
        guard let profile = friendProfile else {
            return
        }
        
        loginLabel.text = "@" + profile.login
        numberOfRestectsLabel.text = profile.numberOfRespects
        numberOfFriendsLabel.text = profile.numberOfFriends
        profilePhotoImageView.image = profile.photo
        firstAndSecondNameLabel.text = profile.firstName + " " + profile.secondName
        
        switch profile.profileType {
        case FBProfileTypes.sponsor:
            profileTypeImageView.image = UIImage(named: "iconSponsor")
            fullInfoButton.isUserInteractionEnabled = false
            fullInfoButton.alpha = 0.6
            profileTypeImageView.isHidden = false
        case FBProfileTypes.admin:
            profileTypeImageView.image = UIImage(named: "iconAdmin")
            profileTypeImageView.isHidden = false
        default:
            break
        }
        
        settingsForFriendActionButton()
    }
    
    private func settingsForFriendActionButton() {
        switch friendStatus {
        case .followers:
            friendActionButton.setTitle("Принять запрос", for: .normal)
            friendActionButton.backgroundColor = #colorLiteral(red: 0, green: 0.1107608194, blue: 1, alpha: 1)
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
    
    // MARK: - IBAction
    
    @IBAction func didTapFriendActionButton(_ sender: UIButton) {
        
        guard let myProfileID = myProfileID,
              let myLogin = myLogin,
              let friendProfile = friendProfile else { return }
        
        friendActionButton.isUserInteractionEnabled = false
        buttonActivityIndicator.startAnimating()

        FireBaseDataBaseManager.changeFriendsLists(profileID: myProfileID, myLogin: myLogin,
                                                   friendLogin: friendProfile.login,
                                                   currentFriendType: friendStatus) { [weak self] resultStatus in
            self?.friendStatus = resultStatus
            self?.settingsForFriendActionButton()
            self?.buttonActivityIndicator.stopAnimating()
            self?.friendActionButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func didTapFullInfoButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardNames.fullProfileScreen, bundle: nil)

        guard let fullProfileInfoVC = storyboard.instantiateInitialViewController(),
              let friendProfile = friendProfile else {
            return
        }

        (fullProfileInfoVC as? SetLoginProtocol)?.setLogin(login: friendProfile.login)
        conclusion?()
    }
    
}

extension CutProfileViewController: GetShortProfileInfoProtocol {
    func getShortProfileInfo(profile: ShortProfileInfoModel,  _ friendStatus: FriendsTypes? = nil,
                             conclusion: (() -> Void)?) {
        self.friendProfile = profile
        self.friendStatus = friendStatus
        self.conclusion = conclusion
    }
}
