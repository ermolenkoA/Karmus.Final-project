//
//  IdentificationView.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit

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
    
    
    @objc func keyboardNotification(notification: Notification){
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyboard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
      
        
        let textField = loginTextField.isEditing ? loginTextField! : passwordTextField!
        
        if keyboard.minY < textField.frame.maxY - textField.transform.ty{
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() {
            $0.placeholder = "Номер телефона"
        }
        
        let okButton = UIAlertAction(title: "Потвердить", style: .default){ [unowned self] _ in
            guard let phone = alert.textFields?.first?.text, !phone.isEmpty else{
                self.present(alert, animated: true)
                return
            }
            
            guard phone ~= "^(\\+375)(29|25|33|44)([\\d]{7})$" else {
                let title = "Некорректно введён номер"
                let message = "Повторите попытку"
                let newAlert = UIAlertController.init(title: title, message: message , preferredStyle: .alert)
                let closeButton = UIAlertAction(title: "Закрыть", style: .cancel)
                let retryButton = UIAlertAction(title: "Ещё раз", style: .default) { [unowned self] _ in
                    self.present(alert, animated: true)
                }
                newAlert.addAction(retryButton)
                newAlert.addAction(closeButton)
                newAlert.view.tintColor = UIColor.black
                self.present(newAlert, animated: true)
                return
            }
            
            guard let result = CoreDataManager.isPhoneNumberExist(phone), result else{
                let title = "Пользователь с такми номером не найден"
                let newAlert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
                let closeButton = UIAlertAction(title: "Закрыть", style: .cancel)
                let retryButton = UIAlertAction(title: "Ещё раз", style: .default) { [unowned self] _ in
                    self.present(alert, animated: true)
                }
                newAlert.addAction(retryButton)
                newAlert.addAction(closeButton)
                newAlert.view.tintColor = UIColor.black
                self.present(newAlert, animated: true)
                return
            }
            
            guard let profiles = try? CoreDataManager.context.fetch(Profile.fetchRequest()) as? [Profile] else{
                print("\n \(self.description) ERROR: error while fetch request\n)")
                showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
                return
            }
            let profile = ProfileItem(profile: profiles.first(where: {$0.phoneNumber == phone})!)
            
            phoneNumberVerification = PhoneNumberVerification(profile: profile, for: .resetPassword, self)
            phoneNumberVerification?.startVerification()
        }
        let closeButton = UIAlertAction(title: "Закрыть", style: .cancel)
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
        let password = passwordTextField.text!
        
        if !(login ~= "^([A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}){3,}$"){
            if !(login ~= "^(\\+375)(29|25|33|44)([\\d]{7})$") {
                passwordTextField.text = nil
                showAlert("Неверно введен логин или пароль", nil, where: self)
                return
            }
        }
        
        guard password ~= "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*]{8,}$" else {
            passwordTextField.text = nil
            showAlert("Неверно введен логин или пароль", nil, where: self)
            return
        }
        
        guard CoreDataManager.tryToOpenProfile(login: login, password: Int64(password.hash), self) else {
            passwordTextField.text = nil
            return
        }
        
        performSegue(withIdentifier: References.fromIdentificationScreenToAccountScreen, sender: self)
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
