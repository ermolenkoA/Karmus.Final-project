//
//  FillAdditionalProfileInfoVC.swift
//  Karmus
//
//  Created by VironIT on 9/1/22.
//

import UIKit
import FirebaseDatabase
import KeychainSwift

final class FillAdditionalProfileInfoVC: UIViewController {

    @IBOutlet private weak var mainView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var mainStackView: UIStackView!
    
    @IBOutlet private weak var preferencesLabel: UILabel!
    @IBOutlet private weak var preferencesCleanUpButton: UIButton!
    @IBOutlet private weak var preferencesTextView: UITextView!
    
    
    @IBOutlet private weak var educationLabel: UILabel!
    @IBOutlet private weak var educationCleanUpButton: UIButton!
    @IBOutlet private weak var educationTextView: UITextView!
    
    @IBOutlet private weak var workLabel: UILabel!
    @IBOutlet private weak var workCleanUpButton: UIButton!
    @IBOutlet private weak var workTextView: UITextView!
    
    @IBOutlet private weak var skillsLabel: UILabel!
    @IBOutlet private weak var skillsCleanUpButton: UIButton!
    @IBOutlet private weak var skillsTextView: UITextView!
    
    @IBOutlet private weak var submitButton: UIButton!
    
    private var preferencesTitles = [String]()
    
    private lazy var defaultSettings: [String] = { [
        preferencesTextView.fixedText ?? "",
        educationTextView.fixedText ?? "",
        workTextView.fixedText ?? "",
        skillsTextView.fixedText ?? ""
        ] }()
    
     
    private var login: String?
    private var isNewUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        standartSettings()
        preferencesTextView.delegate = self
        educationTextView.delegate = self
        workTextView.delegate = self
        skillsTextView.delegate = self
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                         name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardNotification(notification: Notification){
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyboard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let multiplier: CGFloat = skillsTextView.isFirstResponder ? 4
            : (workTextView.isFirstResponder ? 3 : (educationTextView.isFirstResponder ? 2 : 1))
        
        let textViewLowerBound = mainView.frame.minY
            + mainStackView.frame.minY - 5
            + mainStackView.frame.height/4*multiplier
        
        if keyboard.minY < textViewLowerBound - mainView.transform.ty{
            if keyboard.minY < textViewLowerBound + 10 {
                mainView.transform.ty -= abs(keyboard.minY - textViewLowerBound) + 10
            } else if (mainView.transform.ty != 0) && (keyboard.minY > textViewLowerBound + 10) {
                mainView.transform.ty += abs(keyboard.minY - textViewLowerBound) - 10
            }
        } else {
            mainView.transform.ty = 0
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let login = login else {
            return
        }
        
        if let profileTabBar = segue.destination as? ProfileTabBarController {
            (profileTabBar as SetLoginProtocol).setLogin(login: login)
            if let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile) {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
                Database.database().reference()
                    .child(FBDefaultKeys.profiles)
                    .child(profileID)
                    .child(FBProfileKeys.profileUpdateDate)
                    .setValue(formatter.string(from: Date()))
                UserDefaults.standard.setValue(Date(), forKey: ConstantKeys.lastLogInDate)

            }
        }
        
    }
    
    
    
    private func showPreferences(_ sender: UITextView){
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "ChoosePreferencesVC") else {
            print("\n<showPopOver> ERROR: UIViewController withIdentifier \"ChoosePreferencesVC\" isn't exist\n")
            return
        }
        
        popVC.modalPresentationStyle = .popover
        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = sender
        popOverVC?.permittedArrowDirections = .up
        popOverVC?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.maxY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: view.frame.width - 20, height: 200)
        (popVC as! GetPreferencesProtocol).getPreferences(preferencesTitles)
        (popVC as! SetSenderProtocol).setSender(self)
        present(popVC, animated: true)
    }
    
    
    private func standartSettings() {
        
        guard let login = login else {
            print("\n<FillAdditionalProfileInfoVC\\standartSettings> ERROR: login isn't exist\n")
            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
            return
        }
        
        preferencesTextView.backgroundColor = UIColor.tertiarySystemBackground.withAlphaComponent(0.3)
        educationTextView.backgroundColor = UIColor.tertiarySystemBackground.withAlphaComponent(0.3)
        workTextView.backgroundColor = UIColor.tertiarySystemBackground.withAlphaComponent(0.3)
        skillsTextView.backgroundColor = UIColor.tertiarySystemBackground.withAlphaComponent(0.3)
        
        preferencesTextView.layer.borderColor = CGColor(gray: 0, alpha: 1)
        preferencesTextView.layer.borderWidth = 1
        educationTextView.layer.borderColor = CGColor(gray: 0, alpha: 1)
        educationTextView.layer.borderWidth = 1
        workTextView.layer.borderColor = CGColor(gray: 0, alpha: 1)
        workTextView.layer.borderWidth = 1
        skillsTextView.layer.borderColor = CGColor(gray: 0, alpha: 1)
        skillsTextView.layer.borderWidth = 1
        
        
        preferencesTextView.startSettings()
        educationTextView.startSettings()
        workTextView.startSettings()
        skillsTextView.startSettings()
        
        FireBaseDataBaseManager.getProfileInfo(login) { [weak self] info in
            
            guard let info = info else {
                let _ = self?.defaultSettings
                return
            }
            
            if let preferences = info.preferences {
                self?.preferencesTitles = preferences
                self?.preferencesTextView.textColor = .label
                self?.preferencesTextView.text = preferences.reduce("") {
                    $0 == "" ? $0 + $1 : $0 + ", \($1)"
                }
                self?.preferencesCleanUpButton.isHidden = false
            }
            
            if let education = info.education {
                self?.educationTextView.text = education
                self?.educationTextView.textColor = .label
                self?.educationCleanUpButton.isHidden = false
            }
            
            if let work = info.work {
                self?.workTextView.text = work
                self?.workTextView.textColor = .label
                self?.workCleanUpButton.isHidden = false
            }
            
            if let skills = info.skills {
                self?.skillsTextView.text = skills
                self?.skillsTextView.textColor = .label
                self?.skillsCleanUpButton.isHidden = false
            }
            
            let _ = self?.defaultSettings
        }
        
    }
    
    private func setNewInfo(_ value: Any?, for key: String){
        guard let login = login else {
            print("\n<FillAdditionalProfileInfoVC\\setNewInfo> ERROR: login isn't exist\n")
            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
            return
        }
        Database.database().reference()
            .child(FBDefaultKeys.profilesInfo)
            .child(login)
            .child(key)
            .setValue(value)
    }
    
    private func removeOldInfo(for key: String){
        guard let login = login else {
            print("\n<FillAdditionalProfileInfoVC\\removeOldInfo> ERROR: login isn't exist\n")
            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
            return
        }
        
        Database.database().reference()
            .child(FBDefaultKeys.profilesInfo)
            .child(login)
            .child(key)
            .removeValue()
    }
    
    @IBAction func choosePreferenses(_ sender: UITapGestureRecognizer) {
        print("\nMYLOG: I'm here\n")
        showPreferences(preferencesTextView)
    }
    
    @IBAction private func cleanUpSelection(_ sender: UIButton) {
        switch sender {
        case preferencesCleanUpButton:
            preferencesTextView.startSettings()
        case educationCleanUpButton:
            educationTextView.startSettings()
        case workCleanUpButton:
            workTextView.startSettings()
        case skillsCleanUpButton:
            skillsTextView.startSettings()
        default:
            break
        }
        sender.isHidden = true
    }
    
    @IBAction func didTapSubmitButton(_ sender: UIButton) {
        
        let currentSettings = [
            preferencesTextView.fixedText ?? "",
            educationTextView.fixedText ?? "",
            workTextView.fixedText ?? "",
            skillsTextView.fixedText ?? ""
        ]

        print("\nMYLOG: currentSettings = \(currentSettings)\n\n \(defaultSettings)\n")

        if currentSettings != defaultSettings{
            
            if currentSettings[0] != defaultSettings[0] {
                if currentSettings[0] == "" {
                    removeOldInfo(for: FBProfileInfoKeys.preferences)
                } else {
                    setNewInfo(preferencesTitles, for: FBProfileInfoKeys.preferences)
                }
                
            }
            
            if currentSettings[1] != defaultSettings[1] {
                if currentSettings[1] == "" {
                    removeOldInfo(for: FBProfileInfoKeys.education)
                } else {
                    setNewInfo(currentSettings[1], for: FBProfileInfoKeys.education)
                }
                
            }
            
            if currentSettings[2] != defaultSettings[2] {
                if currentSettings[2] == "" {
                    removeOldInfo(for: FBProfileInfoKeys.work)
                } else {
                    setNewInfo(currentSettings[2], for: FBProfileInfoKeys.work)
                }
            }
            
            if currentSettings[3] != defaultSettings[3] {
                if currentSettings[3] == "" {
                    removeOldInfo(for: FBProfileInfoKeys.skills)
                } else {
                    setNewInfo(currentSettings[3], for: FBProfileInfoKeys.skills)
                }
            }

            let title = "Новые данные были сохранены"
            let alert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
            let okButton = !isNewUser ? UIAlertAction(title: "Продолжить", style: .default)
                 : UIAlertAction(title: "Продолжить", style: .default) { [weak self] _ in
                    self?.performSegue(withIdentifier: References.fromFillAdditionalInfotoAccountScreen,
                     sender: self)
                    
                 }

            alert.addAction(okButton)
            alert.view.tintColor = UIColor.black
            present(alert, animated: true)
        } else if isNewUser {
            performSegue(withIdentifier: References.fromFillAdditionalInfotoAccountScreen,
             sender: self)
        }
    }

    
}

extension FillAdditionalProfileInfoVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        submitButton.alpha = 0.5
        submitButton.isUserInteractionEnabled = false
        guard textView.textColor != .darkGray else {
            textView.text = nil
            textView.textColor = .label
            return
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 200
            && !(newText ~= "\n(.){0,10}\n")
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        submitButton.alpha = 1
        submitButton.isUserInteractionEnabled = true
        guard textView.hasText else {
            textView.startSettings()
            switch textView {
            case educationTextView:
                educationCleanUpButton.isHidden = true
            case workTextView:
                workCleanUpButton.isHidden = true
            case skillsTextView:
                skillsCleanUpButton.isHidden = true
            default:
                break
            }
            return
        }
        switch textView {
        case educationTextView:
            educationCleanUpButton.isHidden = false
        case workTextView:
            workCleanUpButton.isHidden = false
        case skillsTextView:
            skillsCleanUpButton.isHidden = false
        default:
            break
        }
    }
}

extension FillAdditionalProfileInfoVC: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}


extension FillAdditionalProfileInfoVC: GetPreferencesProtocol {
    func getPreferences(_ preferences: [String]) {
        preferencesTitles = preferences
        
        preferencesTextView.text = preferences.reduce("") {
            $0 == "" ? $0 + $1 : $0 + ", \($1)"
        }
        
        if preferences.isEmpty {
            preferencesTextView.startSettings()
        } else {
            preferencesTextView.textColor = .label
        }
    }
}

extension FillAdditionalProfileInfoVC: SetLoginProtocol {
    func setLogin(login: String) {
        self.login = login
    }
}


extension FillAdditionalProfileInfoVC: NewUserProtocol {
    func calledByNewUser() {
        isNewUser = true
    }
}

