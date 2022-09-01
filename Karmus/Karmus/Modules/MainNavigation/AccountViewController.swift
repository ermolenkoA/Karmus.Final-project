//
//  AccountViewController.swift
//  Karmus
//
//  Created by VironIT on 17.08.22.
//

import UIKit

class AccountViewController: UIViewController {

    
    @IBOutlet private weak var mainScrollView: UIScrollView!
    
    @IBOutlet private weak var loginLabel: UILabel!
    
    @IBOutlet private weak var numberOfAwards: UILabel!
    @IBOutlet private weak var profilePhotoImageView: UIImageView!
    @IBOutlet private weak var numberOfFriendsLabel: UILabel!
    
    @IBOutlet private weak var firstAndSecondNamesLabel: UILabel!
    
    @IBOutlet private weak var karmaBalanceLabel: UILabel!
    
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
    
    
    @IBOutlet private weak var profileFullnessProgressView: UIProgressView!
    @IBOutlet private weak var profileFullnessLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainScrollView.frame.size = mainScrollView.contentSize
        navigationController?.isNavigationBarHidden = true
        mainInfoView.backgroundColor =
            mainInfoView.backgroundColor?.withAlphaComponent(0.4)
        additionalInfoView.backgroundColor =
            additionalInfoView.backgroundColor?.withAlphaComponent(0.4)
        profilePhotoImageView.layer.cornerRadius =
            profilePhotoImageView.frame.width / 2
    }
    
    
    @IBAction func didTapQuitButton(_ sender: UIButton) {
        let title = "Вы уверены, что хотите выйти?"
        let alert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
        let quitButton = UIAlertAction(title: "Да", style: .destructive) { [unowned self] _ in
            self.performSegue(withIdentifier: References.fromAccountScreenToMainStoryboard, sender: self)
        }
        let backButton = UIAlertAction(title: "Вернуться", style: .default)
        alert.addAction(quitButton)
        alert.addAction(backButton)
        backButton.setValue(UIColor.black, forKey: "titleTextColor")
        present(alert, animated: true)
    }
    
}
