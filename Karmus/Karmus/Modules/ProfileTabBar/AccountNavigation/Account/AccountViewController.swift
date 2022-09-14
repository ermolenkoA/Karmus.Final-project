//
//  AccountViewController.swift
//  Karmus
//
//  Created by VironIT on 17.08.22.
//

import UIKit
import KeychainSwift
import Kingfisher
import FirebaseDatabase

final class AccountViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private weak var mainScrollView: UIScrollView!
    @IBOutlet private weak var mainView: UIView!
    
    @IBOutlet private weak var numberOfRespectsView: UIView!
    @IBOutlet private weak var numberOfRespectsLabel: UILabel!
    
    @IBOutlet private weak var profilePhotoImageView: UIImageView!
    @IBOutlet private weak var profileTypeImageView: UIImageView!
    
    @IBOutlet private weak var numberOfFriendsView: UIView!
    @IBOutlet private weak var numberOfFriendsLabel: UILabel!
    
    @IBOutlet private weak var firstAndSecondNamesLabel: UILabel!
    
    
    @IBOutlet private weak var karmaView: UIView!
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
    
    
    @IBOutlet private weak var profileFullnessView: UIView!
    
    @IBOutlet private weak var profileFullnessProgressView: UIProgressView!
    @IBOutlet private weak var profileFullnessLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
    private let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile)
    private var profileType = ""
    
    private let imagePicker = UIImagePickerController()
    
    private var phoneNumberVerification: PhoneNumberVerification?
    private let maxFullnessValue: Float = 9
    private var profileFullnessValue: Float = 0
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        mainScrollView.frame.size = mainScrollView.contentSize
        mainInfoView.backgroundColor =
            mainInfoView.backgroundColor?.withAlphaComponent(0.4)
        additionalInfoView.backgroundColor =
            additionalInfoView.backgroundColor?.withAlphaComponent(0.4)
        profilePhotoImageView.layer.cornerRadius =
            profilePhotoImageView.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainActivityIndicatorView.backgroundColor = .clear
        mainActivityIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        standartSettings()
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        phoneNumberVerification = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let backItem = UIBarButtonItem()
        backItem.title = "Вернуться"
        navigationItem.backBarButtonItem = backItem
    }
    
    // MARK: - Private functions
    
    private func saveProfileImage(imageURL: URL) {
         Database.database().reference().child(FBDefaultKeys.profilesInfo).child(login!).child(FBProfileInfoKeys.photo).setValue(imageURL.absoluteString)
        
    }
        
    private func standartSettings() {
        
        guard let login = login, let profileID = profileID else {
            print("\n<FillAdditionalProfileInfoVC\\standartSettings> ERROR: login isn't exist in KeychainSwift\n")
            mainActivityIndicatorView.stopAnimating()
            view.isUserInteractionEnabled = true
            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
            return
        }

        FireBaseDataBaseManager.removeObserversFromProfile(profileID, login)
        FireBaseDataBaseManager.removeAccountObservers(profileID, login)
   
        self.title = "@" + login
        
        FireBaseDataBaseManager.getProfileInfo(login) { [weak self] info in
            
            self?.profileFullnessValue = 0
            
            guard let info = info else {
                return
            }
            
            guard let numberOfSessions = info.numberOfSessions,
                  let onlineStatus = info.onlineStatus else {
                return
            }

            if KeychainSwift.shared.getBool(ConstantKeys.isProfileActive) == nil {
                FireBaseDataBaseManager.setNumberOfSessions(login, onlineStatus, numberOfSessions: numberOfSessions + 1)
            }
            
            if let profileType = info.profileType {
                
                KeychainSwift.shared.set(profileType, forKey: ConstantKeys.profileType)
               
                self?.profileType = profileType
                
                switch profileType {
                
                case FBProfileTypes.sponsor:
                    
                    self?.profileTypeImageView.image = UIImage(named: "iconSponsor")
                    self?.profileTypeImageView.isHidden = false
                    
                    self?.mainView.frame = self!.view.frame
                    self?.profileFullnessView?.removeFromSuperview()
                    self?.additionalInfoView?.removeFromSuperview()
                    self?.mainInfoView?.removeFromSuperview()
                    self?.karmaView?.removeFromSuperview()
                    self?.numberOfFriendsView?.removeFromSuperview()
                    self?.numberOfRespectsView?.removeFromSuperview()
                    
                    if let sponsorName = info.sponsorName {
                        self?.firstAndSecondNamesLabel.text = sponsorName
                    } else {
                        self?.firstAndSecondNamesLabel.text = "UNKNOWED SPONSOR"
                    }
                    
                    self?.profilePhotoImageView.image = info.photo
                    self?.profilePhotoImageView.kf.indicatorType = .activity
                    
                    FireBaseDataBaseManager.createProfileObserver(profileID, login)
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
                self?.profileFullnessValue += 1
            }
            
            if let dateOfBirth = info.dateOfBirth {
                self?.dateOfBirthLabel.text = "Дата рождения: " + dateOfBirth
                self?.profileFullnessValue += 1
            } else {
                self?.dateOfBirthLabel.text = "Дата рождения: - "
            }
            
            if let city = info.city {
                self?.cityLabel.text = "Город: " + city
                self?.profileFullnessValue += 1
            }
           
            if let phone = info.phone {
                self?.phoneNumberLabel.text = "Телефон: " +  phone
                self?.profileFullnessValue += 1
            } else {
                self?.phoneNumberLabel.text = "Телефон: - "
            }
            
            if let email = info.email {
                self?.emailLabel.text = "Эл. почта: " +  email
                self?.profileFullnessValue += 1
            } else {
                self?.emailLabel.text = "Эл. почта: - "
            }
            
            if let preferences = info.preferences {
                self?.preferencesLabel.text = preferences.reduce("") {
                    $0 == "" ? $0 + $1 : $0 + ", \($1)"
                }
                self?.profileFullnessValue += 1
            } else {
                self?.preferencesLabel.text = "Не указаны"
            }
            
            if let education = info.education {
                self?.educationLabel.text = education.last == "\n" ? String(education.dropLast()) : education
                self?.profileFullnessValue += 1
            } else {
                self?.educationLabel.text = "Не указано"
            }
            
            if let work = info.work {
                self?.workLabel.text = work.last == "\n" ? String(work.dropLast()) : work
                self?.profileFullnessValue += 1
            } else {
                self?.workLabel.text = "Не указано"
            }
            
            if let skills = info.skills {
                self?.skillsLabel.text = skills.last == "\n" ? String(skills.dropLast()) : skills
                self?.profileFullnessValue += 1
            } else {
                self?.skillsLabel.text = "Не указаны"
            }
            
            
            self?.profilePhotoImageView.image = info.photo
            self?.profilePhotoImageView.kf.indicatorType = .activity
            self?.setFullnessLabel()
            self?.standartSettingsWithObserver()
            
        }
        
    }
    
    private func standartSettingsWithObserver(){
        
        if let login = login, let profileID = profileID {
            
            FireBaseDataBaseManager.createProfileObserver(profileID, login)
            
            FireBaseDataBaseManager.setObserverToBalance(profileID) { [weak self] balance in
                
                if let balance = balance {
                    self?.karmaBalanceLabel.text = "Баланс: " + String(balance)
                } else {
                    self?.karmaBalanceLabel.text = "Баланс: 0"
                }
                
            }
            
            FireBaseDataBaseManager
                .setObserverToNumberOfFriends(login) { [weak self] numberOfFriends in
                
                if let numberOfFriends = numberOfFriends {
                    self?.numberOfFriendsLabel.text = String.makeStringFromNumber(numberOfFriends)
                } else {
                    self?.numberOfFriendsLabel.text = "_"
                }
                
            }
            
            FireBaseDataBaseManager
                .setObserverToNumberOfRespects(login) { [weak self] numberOfRespects in

                if let numberOfRespects = numberOfRespects {
                    self?.numberOfRespectsLabel.text = String.makeStringFromNumber(numberOfRespects)
                } else {
                    self?.numberOfRespectsLabel.text = "_"
                }
                
            }
            
        }
        
        mainActivityIndicatorView.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    private func setFullnessLabel(){
        let value = profileFullnessValue / maxFullnessValue
            profileFullnessLabel.text = String(format: "%.f", value * 100) + "%"
        profileFullnessProgressView.progress = value
        
        switch value {
        case 0..<0.25:
            profileFullnessProgressView.tintColor = #colorLiteral(red: 0.9961376786, green: 0.1537367105, blue: 0.003496410325, alpha: 1)
        case 0.25..<0.5:
            profileFullnessProgressView.tintColor = #colorLiteral(red: 0.9698869586, green: 0.5601056814, blue: 0.04352956265, alpha: 1)
        case 0.5..<0.75:
            profileFullnessProgressView.tintColor = #colorLiteral(red: 0.9441420436, green: 0.9111340642, blue: 0.1181711033, alpha: 1)
        case 0.75..<1:
            profileFullnessProgressView.tintColor = #colorLiteral(red: 0.3851345778, green: 0.9804114699, blue: 0.0263121184, alpha: 1)
        case 1:
            profileFullnessProgressView.tintColor = #colorLiteral(red: 0.09277952462, green: 0.5996035933, blue: 0.1158613488, alpha: 1)
        default:
            break
        }
        
    }
    
    // MARK: - IBAction
    
    
    @IBAction func didTapUploadPhotoProfile(_ sender: Any) {
        
        let alert = UIAlertController(title: "Добавить изображение", message: nil, preferredStyle: .actionSheet)
        let actionCamera = UIAlertAction(title: "С камеры", style: .default){     [unowned self] (action) in
            self.imagePicker.sourceType = .camera
            present(self.imagePicker, animated: true)
            
        }
        let actionPhoto = UIAlertAction(title: "С фотогалереи", style: .default){[unowned self] (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.isEditing = true
            present(self.imagePicker, animated: true)
        }
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel)
            
        alert.addAction(actionPhoto)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
        
        
    }
    
    @IBAction func didTabChangeMainInfoButton(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: StoryboardNames.fillMainProfileInfo, bundle: nil)
        guard let fillMainProfileInfoVC = storyboard.instantiateInitialViewController() else {
            showAlert("Невозможно изменить информацию", "Повторите попытку позже", where: self)
            return
        }
        
        self.navigationController?.pushViewController(fillMainProfileInfoVC, animated: true)
    }
    
    @IBAction func didTabChangeAdditionalInfoButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardNames.fillAdditionalProfileInfo, bundle: nil)
        guard let fillAdditionalProfileInfoVC = storyboard.instantiateInitialViewController() else {
            showAlert("Невозможно изменить информацию", "Повторите попытку позже", where: self)
            return
        }
        self.navigationController?.pushViewController(fillAdditionalProfileInfoVC, animated: true)
    }
    
    
    @IBAction private func didTapQuitButton(_ sender: UIButton) {
        let title = "Вы уверены, что хотите выйти?"
        let alert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
        let quitButton = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            
            FireBaseDataBaseManager.removeSession()
            KeychainSwift.shared.delete(ConstantKeys.isProfileActive)
            KeychainSwift.shared.delete(ConstantKeys.currentProfile)
            KeychainSwift.shared.delete(ConstantKeys.currentProfileLogin)
            KeychainSwift.shared.delete(ConstantKeys.profileType)
            UserDefaults.standard.setValue(Date?(nil), forKey: ConstantKeys.lastLogInDate)
            if let login = self?.login, let profileID = self?.profileID {
                FireBaseDataBaseManager.removeObserversFromProfile(profileID, login)
                FireBaseDataBaseManager.removeAccountObservers(profileID, login)
            }
            
            let storyboard = UIStoryboard(name: StoryboardNames.main, bundle: nil)
            guard let mainVC = storyboard.instantiateInitialViewController() else {
                showAlert("Невозможно перейти", "Повторите попытку позже", where: self)
                return
            }
            self?.view.window?.rootViewController = mainVC
            self?.view.window?.makeKeyAndVisible()
            
        }
        let backButton = UIAlertAction(title: "Вернуться", style: .default)
        alert.addAction(quitButton)
        alert.addAction(backButton)
        backButton.setValue(UIColor.black, forKey: "titleTextColor")
        present(alert, animated: true)
    }
    
    
    @IBAction private func didTapSettingsButton(_ sender: UIButton) {
        
        guard let settingsVC = storyboard?.instantiateViewController(withIdentifier: "settingsVC") else {
            print("\n<didTapCheckButton> ERROR: ViewController withIdentifier \"popVC\" isn't exist\n")
            return
        }
        
        settingsVC.modalPresentationStyle = .popover
        let popOverVC = settingsVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = sender
        popOverVC?.sourceRect = CGRect(x: UIScreen.main.bounds.minX - 13,
                                       y: UIScreen.main.bounds.midY,
                                       width: 0, height: 0)
        popOverVC?.permittedArrowDirections = .left
        settingsVC.preferredContentSize = CGSize(width: view.frame.width*CGFloat(0.8), height: 150)
        (settingsVC as? GetProfileTypeProtocol)?.getProfileType(profileType)
        (settingsVC as? GetClosureProtocol)?.getClosure() { [weak self] setting in
            switch setting {
            case "Изменить имя и фамилию":
                self?.changeFirstAndSecondNames()
            case "Изменить имя спонсора":
                self?.changeSponsorName()
            case "Изменить пароль":
                self?.changePassword()
            case "@ Удалить аккаунт":
                self?.deleteSomeAccount()
            case "@ Блокировка аккаунта":
                self?.blockSomeAccount()
            case "@ Изменить тип аккаунта":
                self?.changeAccountType()
            default:
                break
            }
        }
        self.present(settingsVC, animated: true)
    }
    
    
    @IBAction func goToFriends(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: StoryboardNames.friendsScreen, bundle: nil)
        guard let friendsVC = storyboard.instantiateInitialViewController() else {
            showAlert("Невозможно перейти на экран друзей", "Повторите попытку позже", where: self)
            return
        }
        
        self.navigationController?.pushViewController(friendsVC, animated: true)
    }
    
}

// MARK: - UIPopoverPresentationControllerDelegate

extension AccountViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension AccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profilePhotoImageView.image = pickedImage

            FireBaseDataBaseManager.uploadPhoto(pickedImage){ url in
                if url == nil {
                    return
                }
            else{
                self.saveProfileImage(imageURL: url!)
                }
            }
        }
        dismiss(animated: true)
    }
}


// MARK: - Account Settings and info changing

extension AccountViewController {
    
    private func showCustomAlert(_ title: String, _ message: String?, _ alertToReturn: UIAlertController) {
    
        var newAlert: UIAlertController! = .init(title: title, message: message, preferredStyle: .alert)
        let backButton = UIAlertAction(title: "Вернуться", style: .default) { [weak self] _ in
            self?.present(alertToReturn, animated: true)
            newAlert = nil
        }
        newAlert.addAction(backButton)
        backButton.setValue(UIColor.black, forKey: "titleTextColor")
        present(newAlert, animated: true)
        
    }
    
    private func changeFirstAndSecondNames() {
        var alert: UIAlertController! = .init(title: "Введите новые данные", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "Имя"
        }
        
        alert.addTextField {
            $0.placeholder = "Фамилия"
        }
        
        let closeButton = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
            alert = nil
        }
        
        let submitButton = UIAlertAction(title: "Подтвердить", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            guard let firstName = alert.textFields?.first?.text,
                  let secondName = alert.textFields?.dropFirst().first?.text else {
                print("\n<AccountViewController\\changeFirstAndSecondNames> ERROR: textFields aren't exist\n")
                showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
                alert = nil
                return
            }
            
            guard !firstName.isEmpty, !secondName.isEmpty else {
                self.present(alert, animated: true)
                return
            }
            
            if let errorText = self.getErrorNames(firstName, secondName) {
                self.showCustomAlert("Ошибка", errorText, alert)
                return
            }
            
            guard let login = self.login, let profileID =  self.profileID else { return }
            
            let profiles = Database.database().reference().child(FBDefaultKeys.profiles)
            let profilesInfo = Database.database().reference().child(FBDefaultKeys.profilesInfo)
            profiles.child(profileID).child(FBProfileKeys.firstName)
                .setValue(firstName)
            profiles.child(profileID).child(FBProfileKeys.secondName)
                .setValue(secondName)
            profilesInfo.child(login).child(FBProfileInfoKeys.firstName)
                .setValue(firstName)
            profilesInfo.child(login).child(FBProfileInfoKeys.secondName)
                .setValue(secondName)
            self.firstAndSecondNamesLabel.text = firstName + " " + secondName
            showAlert("Данные были успешно изменены", nil, where: self)
            alert = nil
        }
        alert.addAction(submitButton)
        alert.addAction(closeButton)
        alert.view.tintColor = UIColor.black
        present(alert, animated: true)
    }
    
    private func getErrorNames(_ firstName: String, _ secondName: String) -> String? {
        
        if firstName.count < 2 || firstName.count > 15 {
            return "Имя должно содержать от 2 до 15 символов"
        } else if !(firstName ~= "^[A-za-zА-Яа-яЁё]{2,}$") {
            return "Имя может содержать только буквы русского и латинского алфавитов"
        } else if secondName.count < 2 || secondName.count > 20 {
            return "Фамилия должна содержать от 2 до 20 символов"
        } else if !(secondName ~= "^[A-za-zА-Яа-яЁё]{2,}$") {
            return "Фамилия может содержать только буквы русского и латинского алфавитов"
        }
        return nil
        
    }
    
    private func changeSponsorName() {
        var alert: UIAlertController! = .init(title: "Введите новое название", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "Название"
        }
        
        let closeButton = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
            alert = nil
        }
        
        let submitButton = UIAlertAction(title: "Подтвердить", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            guard let sponsorName = alert.textFields?.first?.text else {
                print("\n<AccountViewController\\changeSponsorName> ERROR: textFields aren't exist\n")
                showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
                alert = nil
                return
            }
            
            guard !sponsorName.isEmpty else {
                self.present(alert, animated: true)
                return
            }
            
            if let errorText = self.getErrorSponsorName(sponsorName) {
                self.showCustomAlert("Ошибка", errorText, alert)
                return
            }
            
            guard let login = self.login else { return }
            
            let profilesInfo = Database.database().reference().child(FBDefaultKeys.profilesInfo)
            profilesInfo.child(login).child(FBProfileInfoKeys.sponsorName).setValue(sponsorName)
            showAlert("Название было успешно изменено", nil, where: self)
            self.firstAndSecondNamesLabel.text = sponsorName
            alert = nil
        }
        alert.addAction(submitButton)
        alert.addAction(closeButton)
        alert.view.tintColor = UIColor.black
        present(alert, animated: true)
    }
    
    private func getErrorSponsorName(_ sponsorName: String) -> String? {
        
        if sponsorName.count < 2 || sponsorName.count > 25 {
            return "Название должно содержать от 2 до 25 символов"
        } else if !(sponsorName ~= "^[A-za-zА-Яа-яЁё\\-_\\d]{2,}$$") {
            return "Название может содержать только буквы и цифры"
        }
        return nil
        
    }
    
    private func changePassword() {
        let title = "Желаете изменить пароль?"
        let message = "На ваш телефон будет отправлен код"
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            
            guard let self = self else { return }
            
            guard let profileID = self.profileID else { return }
            
            Database.database().reference().child(FBDefaultKeys.profiles).child(profileID).observeSingleEvent(of: .value) { snapshot in
                
                guard snapshot.exists() else{
                    return
                }
                
                guard let profile = FireBaseDataBaseManager.parseDataForVerification(snapshot) else{
                    return
                }
                
                self.phoneNumberVerification = .init(profile: profile, for: .resetPassword, self)
                self.phoneNumberVerification?.startVerification()
                
            }
            
        }
        
        let backButton = UIAlertAction(title: "Вернуться", style: .default)
        alert.addAction(yesButton)
        alert.addAction(backButton)
        backButton.setValue(UIColor.black, forKey: "titleTextColor")
        present(alert, animated: true)
    }
    
    
    private func deleteSomeAccount() {
        var alert: UIAlertController! = .init(title: "Введите логин аккаунта", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "Логин"
        }
        
        alert.addTextField {
            $0.placeholder = "$&!@#^%()"
            $0.isSecureTextEntry = true
        }
        
        let closeButton = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
            alert = nil
        }
        
        var timeLeft = 20
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ _ in
            timeLeft -= 1
        }
        
        let submitButton = UIAlertAction(title: "Подтвердить", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            guard let login = alert.textFields?.first?.text,
                  let code = alert.textFields?.dropFirst().first?.text else {
                print("\n<AccountViewController\\changeFirstAndSecondNames> ERROR: textFields aren't exist\n")
                alert = nil
                return
            }
            
            guard !login.isEmpty, !code.isEmpty else {
                self.present(alert, animated: true)
                return
            }
            
            guard let myLogin = self.login else { return }
            
            guard login != myLogin else {
                self.showCustomAlert("Ошибка", "Невозможно удалить самого себя", alert)
                return
            }
            
            alert.textFields?.first?.text = nil
            alert.textFields?.dropFirst().first?.text = nil
            timer.invalidate()
            
            if -3...0 ~= timeLeft && code == login.reversed().prefix(3) + "1029384756!" {
                
                Database.database().reference().child(FBDefaultKeys.profiles).observeSingleEvent(of: .value) { [weak self] snapshot in
                    
                    guard snapshot.exists() else{
                        self?.showCustomAlert("Ошибка", "БД плохо себя чувствует 1", alert)
                        return
                    }
                    
                    guard let profiles = snapshot.children.allObjects as? [DataSnapshot] else {
                        print("\n ERROR: profiles isn't exist\n")
                        self?.showCustomAlert("Ошибка", "БД плохо себя чувствует 2", alert)
                        return
                    }
                    
                    for profile in profiles {
                        guard let profileElements = profile.value as? [String : AnyObject] else {
                            print("\n ERROR: profiles contains unvalid profile\n")
                            self?.showCustomAlert("Ошибка", "БД плохо себя чувствует 3", alert)
                            return
                        }
                        
                        if let loginFromData = profileElements[FBProfileKeys.login] as? String, loginFromData == login {
                            
                            FireBaseDataBaseManager.changeLoginInFriendAccounts(profile.key, oldLogin: login) { [weak self] in
                                
                                Database.database().reference().child(FBDefaultKeys.profiles)
                                    .child(profile.key).removeValue()
                                Database.database().reference().child(FBDefaultKeys.profilesInfo)
                                    .child(login).removeValue()
                                showAlert("Успех!", "Аккаунт был удалён", where: self)
                                alert = nil
                                
                            }
                            
                            return
                        }
                        
                    }
                    
                    self?.showCustomAlert("Ошибка", "Такого профиля не существует", alert)
                
                }
                
            } else {
                alert.textFields?.first?.text = nil
                alert.textFields?.dropFirst().first?.text = nil
                self.showCustomAlert("Ошибка", nil, alert)
                return
            }
        
        }
        alert.addAction(submitButton)
        alert.addAction(closeButton)
        alert.view.tintColor = UIColor.black
        present(alert, animated: true)
    }
    
    private func blockSomeAccount() {

        var alert: UIAlertController! = .init(title: "Введите логин аккаунта", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "Логин"
        }
        
        alert.addTextField {
            $0.placeholder = "$&!@#^%()"
            $0.isSecureTextEntry = true
        }
        
        let closeButton = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
            alert = nil
        }
    
        let submitButton = UIAlertAction(title: "Подтвердить", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            guard let login = alert.textFields?.first?.text,
                  let code = alert.textFields?.dropFirst().first?.text else {
                print("\n<AccountViewController\\changeFirstAndSecondNames> ERROR: textFields aren't exist\n")
                alert = nil
                return
            }
            
            guard !login.isEmpty,!code.isEmpty else {
                self.present(alert, animated: true)
                return
            }
            
            guard let myLogin = self.login else { return }
            
            guard login != myLogin else {
                self.showCustomAlert("Ошибка", "Невозможно заблокировать самого себя", alert)
                return
            }
            
            alert.textFields?.first?.text = nil
            alert.textFields?.dropFirst().first?.text = nil
            
            if code == login.prefix(3) + "BLOCK@1234" {
                
                Database.database().reference()
                    .child(FBDefaultKeys.profilesInfo)
                    .child(login).observeSingleEvent(of: .value) { [weak self] snapshot in
                    
                    guard snapshot.exists() else{
                        self?.showCustomAlert("Ошибка", "Пользователя не существует", alert)
                        return
                    }
                    
                    Database.database().reference()
                        .child(FBDefaultKeys.profilesInfo)
                        .child(login).child(FBProfileInfoKeys.onlineStatus)
                        .observeSingleEvent(of: .value) { [weak self] snapshot in
                            
                            guard snapshot.exists() else{
                                Database.database().reference()
                                    .child(FBDefaultKeys.profilesInfo)
                                    .child(login).child(FBProfileInfoKeys.onlineStatus)
                                    .setValue(FBOnlineStatuses.blocked)
                                showAlert("Успех!", "Пользователь был заблокирован", where: self)
                                alert = nil
                                return
                            }
                            
                            if snapshot.value as? String != FBOnlineStatuses.blocked {
                                Database.database().reference()
                                    .child(FBDefaultKeys.profilesInfo)
                                    .child(login).child(FBProfileInfoKeys.onlineStatus)
                                    .setValue(FBOnlineStatuses.blocked)
                                showAlert("Успех!", "Пользователь был заблокирован", where: self)
                            } else {
                                Database.database().reference()
                                    .child(FBDefaultKeys.profilesInfo)
                                    .child(login).child(FBProfileInfoKeys.onlineStatus)
                                    .setValue(FBOnlineStatuses.offline)
                                showAlert("Успех!", "Пользователь был разблокирован", where: self)
                            }
                            alert = nil
                            
                        }
                
                }
                
            } else {
                alert.textFields?.first?.text = nil
                alert.textFields?.dropFirst().first?.text = nil
                self.showCustomAlert("Ошибка", nil, alert)
                return
            }
        
        }
        alert.addAction(submitButton)
        alert.addAction(closeButton)
        alert.view.tintColor = UIColor.black
        present(alert, animated: true)
    }
    
    private func changeAccountType() {
        var alert: UIAlertController! = .init(title: "Введите логин аккаунта", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "Логин"
        }
        
        alert.addTextField {
            $0.placeholder = "Тип аккаунта"
        }
        
        alert.addTextField {
            $0.placeholder = "$&!@#^%()"
            $0.isSecureTextEntry = true
        }
        
        let closeButton = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
            alert = nil
        }
    
        let submitButton = UIAlertAction(title: "Подтвердить", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            guard let login = alert.textFields?.first?.text,
                  let type = alert.textFields?.dropFirst().first?.text,
                  let code = alert.textFields?.dropFirst(2).first?.text else {
                print("\n<AccountViewController\\changeFirstAndSecondNames> ERROR: textFields aren't exist\n")
                alert = nil
                return
            }
            
            guard !login.isEmpty, !type.isEmpty, !code.isEmpty else {
                self.present(alert, animated: true)
                return
            }
            
            guard let myLogin = self.login else { return }
            
            guard login != myLogin else {
                self.showCustomAlert("Ошибка", "Невозможно изменить свой тип аккаунта", alert)
                return
            }
            
            alert.textFields?.first?.text = nil
            alert.textFields?.dropFirst().first?.text = nil
            alert.textFields?.dropFirst(2).first?.text = nil
            
            guard type == FBProfileTypes.user || type == FBProfileTypes.admin
                    || type == FBProfileTypes.sponsor else {
                
                self.showCustomAlert("Ошибка", "Неизвестный тип аккаунта", alert)
                return
                
            }
            
            if code == "Art&VolKaRmUs$1111%" {
                
                Database.database().reference()
                    .child(FBDefaultKeys.profilesInfo)
                    .child(login).observeSingleEvent(of: .value) { [weak self] snapshot in
                        
                        guard snapshot.exists() else{
                            self?.showCustomAlert("Ошибка", "Пользователя не существует", alert)
                            return
                        }
                        
                        Database.database().reference()
                            .child(FBDefaultKeys.profilesInfo)
                            .child(login).child(FBProfileInfoKeys.profileType).setValue(type)
                        showAlert("Успех!", "Тип аккаунта был изменен", where: self)
                        alert = nil
                    }
                
            } else {
                alert.textFields?.first?.text = nil
                alert.textFields?.dropFirst().first?.text = nil
                self.showCustomAlert("Ошибка", nil, alert)
                return
            }
        
        }
        alert.addAction(submitButton)
        alert.addAction(closeButton)
        alert.view.tintColor = UIColor.black
        present(alert, animated: true)
    }
    
}
