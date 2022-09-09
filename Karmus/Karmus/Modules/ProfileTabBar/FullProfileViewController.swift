//
//  FullProfileViewController.swift
//  Karmus
//
//  Created by VironIT on 9/8/22.
//

import UIKit
import KeychainSwift

final class FullProfileViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainActivityIndicatorView: UIActivityIndicatorView!
    
    
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var onlineStatusLabel: UILabel!
    
    
    @IBOutlet private weak var mainScrollView: UIScrollView!
    @IBOutlet private weak var mainView: UIView!

    @IBOutlet private weak var numberOfRespectsView: UIView!
    @IBOutlet private weak var numberOfRespectsLabel: UILabel!
    
    @IBOutlet private weak var profilePhotoImageView: UIImageView!
    @IBOutlet private weak var profileTypeImageView: UIImageView!
    
    
    @IBOutlet private weak var numberOfFriendsView: UIView!
    @IBOutlet private weak var numberOfFriendsLabel: UILabel!
    
    @IBOutlet private weak var firstAndSecondNamesLabel: UILabel!

    @IBOutlet private weak var mainInfoView: UIView!
    @IBOutlet private weak var dateOfBirthLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    @IBOutlet private weak var additionalInfoView: UIView!
    @IBOutlet private weak var preferencesLabel: UILabel!
    @IBOutlet private weak var educationLabel: UILabel!
    @IBOutlet private weak var workLabel: UILabel!
    @IBOutlet private weak var skillsLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var login: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainScrollView.frame.size = mainScrollView.contentSize
        mainInfoView.backgroundColor =
            mainInfoView.backgroundColor?.withAlphaComponent(0.4)
        additionalInfoView.backgroundColor =
            additionalInfoView.backgroundColor?.withAlphaComponent(0.4)
        profilePhotoImageView.layer.cornerRadius =
            view.frame.width * 0.15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainActivityIndicatorView.backgroundColor = .clear
        mainActivityIndicatorView.startAnimating()
        mainScrollView.isUserInteractionEnabled = false
        standartSettings()
    }
    
    // MARK: - Private functions
    
        
    private func standartSettings() {
        
        guard let login = login else {
            print("\n<standartSettings> ERROR: login isn't exist \n")
            navigationController?.popViewController(animated: true)
            return
        }
        
        loginLabel.text = "@" + login
        
        FireBaseDataBaseManager.getProfileInfo(login) { [weak self] info in
            
            guard let info = info else {
                return
            }
            
            if let profileType = info.profileType {

                switch profileType {
                
                case FBProfileTypes.sponsor:
                    
                    self?.profileTypeImageView.image = UIImage(named: "iconSponsor")
                    self?.profileTypeImageView.isHidden = false
                    
                    self?.mainView.frame = self!.view.frame
                    self?.additionalInfoView.removeFromSuperview()
                    self?.mainInfoView.removeFromSuperview()
                    self?.numberOfFriendsView.removeFromSuperview()
                    self?.numberOfRespectsView.removeFromSuperview()
                    
                    if let sponsorName = info.sponsorName {
                        self?.firstAndSecondNamesLabel.text = sponsorName
                    } else {
                        self?.firstAndSecondNamesLabel.text = "UNKNOWED SPONSOR"
                    }
                    self?.mainScrollView.isUserInteractionEnabled = true
                    self?.mainActivityIndicatorView.stopAnimating()
                    return
                    
                case FBProfileTypes.admin:
                    
                    self?.profileTypeImageView.image = UIImage(named: "iconAdmin")
                    self?.profileTypeImageView.isHidden = false
                    
                default:
                    break
                }
                
            }
            
            if let firstName = info.firstName, let secondName = info.secondName {
                self?.firstAndSecondNamesLabel.text = firstName + " " + secondName
            }
            
            if let dateOfBirth = info.dateOfBirth {
                self?.dateOfBirthLabel.text = "Дата рождения: " + dateOfBirth
            }
            
            if let city = info.city {
                self?.cityLabel.text = "Город: " + city
            }
           
            if let phone = info.phone {
                self?.phoneNumberLabel.text = "Телефон: " +  phone
            }
            
            if let email = info.email {
                self?.emailLabel.text = "Эл. почта: " +  email
            }
            
            if let preferences = info.preferences {
                self?.preferencesLabel.text = preferences.reduce("") {
                    $0 == "" ? $0 + $1 : $0 + ", \($1)"
                }
            }
            
            if let education = info.education {
                self?.educationLabel.text = education.last == "\n" ? String(education.dropLast()) : education
            }
            
            if let work = info.work {
                self?.workLabel.text = work.last == "\n" ? String(work.dropLast()) : work
            }
            
            if let skills = info.skills {
                self?.skillsLabel.text = skills.last == "\n" ? String(skills.dropLast()) : skills
            }
            
            if let numberOfFriends = info.numberOfFriends {
                self?.numberOfFriendsLabel.text = String.makeStringFromNumber(numberOfFriends)
            }
            
            if let numberOfRespects = info.numberOfRespects {
                self?.numberOfRespectsLabel.text = String.makeStringFromNumber(numberOfRespects)
            }
            
            if let onlineStatus = info.onlineStatus {
                self?.onlineStatusLabel.text = onlineStatus
                
                self?.onlineStatusLabel.text = onlineStatus
                
                switch onlineStatus {
                
                case FBOnlineStatuses.offline:
                    self?.onlineStatusLabel.textColor = .lightGray
                case FBOnlineStatuses.online:
                    self?.onlineStatusLabel.textColor = .green
                case FBOnlineStatuses.blocked:
                    self?.onlineStatusLabel.textColor = .red
                default:
                    self?.onlineStatusLabel.textColor = .clear
                    
                }
                
            }
            self?.mainScrollView.isUserInteractionEnabled = true
            self?.mainActivityIndicatorView.stopAnimating()
        }
        
    }

}

extension FullProfileViewController: SetLoginProtocol {
    func setLogin(login: String) {
        self.login = login
    }
}
