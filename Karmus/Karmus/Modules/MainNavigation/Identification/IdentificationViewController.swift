//
//  IdentificationView.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit
import FirebaseDatabase
import KeychainSwift

final class IdentificationViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var forgotPasswordLabel: UILabel!
    
    @IBOutlet private weak var submitButton: UIButton!
    
    // MARK: - Private Properties
    
    private var correctTextFields = Set<RegistrationElements>()
    private var phoneNumberVerification: PhoneNumberVerification?
    private var isTextFieldsFill: Bool {
        passwordTextField.hasText && loginTextField.hasText
    }
    private var isNetworkConected: Bool {
        guard Reachability.isConnectedToNetwork() else {
            showAlert("Отсутствует доступ к интернету", "Проверьте подключение и повторите попытку", where: self)
            return false
        }
        return true
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Вернуться"
        navigationItem.backBarButtonItem = backItem
        
        submitButton.alpha = 0.5
        submitButton.layer.cornerRadius = 3
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        phoneNumberVerification = nil
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Private functions
   
   @objc private func keyboardNotification(notification: Notification) {
       guard let userInfo = notification.userInfo else { return }
       
       guard let keyboard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
               .cgRectValue else { return }
       
       let textField = loginTextField.isEditing ? loginTextField! : passwordTextField!
       
       if keyboard.minY < textField.frame.maxY - textField.transform.ty {
           if keyboard.minY < textField.frame.maxY + 10 {
               textField.transform.ty -= abs(keyboard.minY - textField.frame.maxY) + 10
           } else if (textField.transform.ty != 0) && (keyboard.minY > textField.frame.maxY + 10) {
               textField.transform.ty += abs(keyboard.minY - textField.frame.maxY) - 10
           }
       } else {
           textField.transform.ty = 0
       }
       
       titleLabel.transform.ty = textField.transform.ty
       if passwordTextField.isEditing {
           loginTextField.transform.ty = textField.transform.ty
       } else {
           passwordTextField.transform.ty = 0
       }
   }
    
    // MARK: - IBAction
    
    @IBAction private func didTapForgotPasswordLabel(_ sender: UITapGestureRecognizer) {
        guard isNetworkConected else { return }
        
        if let timeLeft = AntiSpam.verificationBanTime {
            showAlert("Превышено количество попыток", "Повторите попытку через \(timeLeft)", where: self)
            return
        }
        
        let title = "Восстановление пароля"
        let message = "Введите номер телефона на который зарегестрирован аккаунт"
        var alert: UIAlertController! = .init(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() {
            $0.placeholder = "Номер телефона"
        }
        
        let okButton = UIAlertAction(title: "Потвердить", style: .default){ [unowned self] _ in
            guard self.isNetworkConected else { return }
            guard let phone = alert.textFields?.first?.text, !phone.isEmpty else{
                self.present(alert, animated: true)
                return
            }
            guard phone ~= "^(\\+375)(29|25|33|44)([\\d]{7})$" else {
                let title = "Некорректно введён номер"
                let message = "Повторите попытку"
                var newAlert: UIAlertController! = .init(title: title, message: message , preferredStyle: .alert)
                let closeButton  = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
                    alert = nil
                    newAlert = nil
                }
                let retryButton = UIAlertAction(title: "Ещё раз", style: .default) { [unowned self] _ in
                    self.present(alert, animated: true)
                }
                newAlert.addAction(retryButton)
                newAlert.addAction(closeButton)
                newAlert.view.tintColor = UIColor.black
                self.present(newAlert, animated: true)
                return
            }
            
            Database.database().reference().child(FBDefaultKeys.profiles).observeSingleEvent(of: .value) { [weak self] snapshot in
                
                guard let self = self else{ return }
                guard snapshot.exists() else {
                    print("\n<IdentificationViewController\\didTapForgotPasswordLabel> ERROR: snapshot isn't exist\n")
                    showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
                    return
                }
                guard let profiles = snapshot.children.allObjects as? [DataSnapshot] else {
                    print("\n<IdentificationViewController\\didTapForgotPasswordLabel> ERROR: profiles isn't exist\n")
                    showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
                    return
                }
            
                for profile in profiles {
                    guard let profileElements = profile.value as? [String : AnyObject] else {
                        print("\n<IdentificationViewController\\didTapForgotPasswordLabel> ERROR: profiles contains unvalid profile\n")
                        showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
                        return
                    }
                    
                    if profileElements[FBProfileKeys.phoneNumber] as? String == phone {
                        guard let profile = FireBaseDataBaseManager.parseDataForVerification(profile) else {
                            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
                            return
                        }
                        self.phoneNumberVerification = PhoneNumberVerification(profile: profile,
                                                                        for: .resetPassword, self)
                        self.phoneNumberVerification?.startVerification()
                        alert = nil
                        return
                    }
                }
                
                let title = "Пользователь с такми номером не найден"
                var newAlert: UIAlertController! = .init(title: title, message: nil, preferredStyle: .alert)
                let closeButton = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
                    newAlert = nil
                    alert = nil
                }
                let retryButton = UIAlertAction(title: "Ещё раз", style: .default) { [unowned self] _ in
                    self.present(alert, animated: true)
                    newAlert = nil
                }
                newAlert.addAction(retryButton)
                newAlert.addAction(closeButton)
                newAlert.view.tintColor = UIColor.black
                self.present(newAlert, animated: true)
            }
        
        }
        
        let closeButton = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
            alert = nil
        }
        alert.addAction(closeButton)
        alert.addAction(okButton)
        alert.view.tintColor = UIColor.black
        self.present(alert, animated: true)
    }
    
    @IBAction private func didTapSubmitButton(_ sender: UIButton) {
        guard isNetworkConected else { return }
        
        if let timeLeft = AntiSpam.logInBanTime {
            showAlert("Превышено количество попыток", "Повторите попытку через \(timeLeft)", where: self)
            return
        }
        
        AntiSpam.saveNewLoginAttemp()
        let login = loginTextField.text!
        
        if !(login ~= "^([A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}){3,}$"){
            if !(login ~= "^(\\+375)(29|25|33|44)([\\d]{7})$") {
                showAlert("Неверно введен логин или пароль", nil, where: self)
                return
            }
        }
        
        let password = passwordTextField.text!
        passwordTextField.text = nil
        
        guard password ~= "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*]{8,}$" else {
            showAlert("Неверно введен логин или пароль", nil, where: self)
            return
        }
        
        FireBaseDataBaseManager.openProfile(login: login, password: Int64(password.hash)) { [weak self] result, profileID in
            guard let self = self else { return }
            
            guard result != .error else{
                showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
                return
            }
            
            if result == .failure {
                showAlert("Неверно введен логин или пароль", nil, where: self)
            } else {
                self.loginTextField.text = nil
                AntiSpam.resetUserLogInAttemps()
                KeychainSwift.shared.set(profileID!, forKey: ConstantKeys.currentProfile)
                KeychainSwift.shared.set(login, forKey: ConstantKeys.currentProfileLogin)
                FireBaseDataBaseManager.getProfileUpdateDate(profileID!){ [weak self] date in
                    if date == nil {
                        let storyboard = UIStoryboard(name: StoryboardNames.newUserScreen, bundle: nil)
                        guard let greetingVC = storyboard.instantiateInitialViewController() else {
                            showAlert("Невозможно перейти", "Повторите попытку позже", where: self)
                            return
                        }
                        self?.navigationController?.pushViewController(greetingVC, animated: true)
                    } else {
                        UserDefaults.standard.setValue(Date(), forKey: ConstantKeys.lastLogInDate)
                        
                        let storyboard = UIStoryboard(name: StoryboardNames.accountScreen, bundle: nil)
                        guard let profileTabBarC = storyboard.instantiateInitialViewController() else {
                            showAlert("Невозможно перейти", "Повторите попытку позже", where: self)
                            return
                        }
                        
                        self?.view.window?.rootViewController = profileTabBarC
                        self?.view.window?.makeKeyAndVisible()
                    }
                }
            }
        }
        
    }
    
}

extension IdentificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.contains(" ") else {
            return false
        }
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case loginTextField:
            return newText.count < 25
        case passwordTextField:
            return newText.count < 64
        default:
            return true
        }
    }
}

// MARK: - UISearchTextFieldDelegate

extension IdentificationViewController: UISearchTextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = CGColor(gray: 255, alpha: 1)
        textField.layer.borderWidth = 0
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        submitButton.alpha = isTextFieldsFill ? 1 : 0.5
        submitButton.isUserInteractionEnabled = isTextFieldsFill
    }
}
