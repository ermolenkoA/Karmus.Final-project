//
//  PhoneNumberVerification.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import UIKit
import FirebaseDatabase

final class PhoneNumberVerification {
    
    // MARK: - Private Properties
    
    private weak var controller: UIViewController!
    private var verificationModel: VerificationModel
    private var name: String
    private var phone: String
    private var password: Int64?
    private var message: (messageBody: String, code: String)?
    private var profile: ProfileVerificationModel
    private var isBalanceEnough: Bool?
    private var alert: UIAlertController!
    private var newAlert: UIAlertController!
    
    // MARK: - Initializers
    
    init (profile: ProfileVerificationModel, for verificationModel: VerificationModel, _ controller: UIViewController) {
        self.verificationModel = verificationModel
        self.controller = controller
        self.profile = profile
        name = profile.firstName
        phone = profile.phoneNumber
    }
    
    // MARK: - Start verification
    
    func startVerification() {

        guard Reachability.isConnectedToNetwork() else {
            showAlert("Отсутствует доступ к интернету"
                      , "Проверьте подключение и повторите попытку", where: self.controller)
            return
        }
        
        if let timeLeft = AntiSpam.verificationBanTime {
            showAlert("Превышено количество попыток", "Повторите попытку через \(timeLeft)", where: self.controller)
            return
        }
        
        if verificationModel == .resetPassword {
            self.password = profile.password
            FireBaseDataBaseManager.openProfile(login: phone, password: password!) {  [weak self] result, _ in
                
                guard let self = self else{
                    print("\n<PhoneNumberVerification\\startVerification> ERROR: PhoneNumberVerification is deallocated\n")
                    return
                }
                
                guard result != .error else{
                    showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self.controller)
                    return
                }
                if result == .success {
                    self.checkBalanceAndSendCode()
                } else {
                    showAlert("Ошибка", "Профиль не существует", where: self.controller)
                }
            }
 
        } else {
            checkBalanceAndSendCode()
        }
        
        
        
    }
    
    // MARK: - Craete message
    
    private func isMessageCreated() -> Bool{
        
        switch verificationModel {
        case .registration:
            message = Code.shared.RegistrationMessageWithCode(name: name)
        case .resetPassword:
            message = Code.shared.PasswordResetMessageWithCode(name: name)
        }
        return true
        
    }
    
    // MARK: - Check balance
    
    private func checkBalanceAndSendCode() {
        
        guard isMessageCreated() else { return }
        
        guard let message = self.message else {
            print("\n<PhoneNumberVerification\\checkBalanceAndSendCode> ERROR: message wasn't created\n")
            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: controller)
            return
        }
        
        guard Reachability.isConnectedToNetwork() else {
            showAlert("Отсутствует доступ к интернету"
                      , "Проверьте подключение и повторите попытку", where: controller)
            return
        }
            
        SMSManager.isBalanceEnough{ [weak self] (error, isBalanceEnough) in
            
            guard let isBalanceEnough = isBalanceEnough else {
                DispatchQueue.main.async {
                    showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self?.controller)
                }
                return
            }
            
            guard isBalanceEnough else {
                print("\n<PhoneNumberVerification\\checkBalanceAndSendCode> ERROR: low balance\n")
                DispatchQueue.main.async {
                    showAlert("Невозможно отправить код", "Повторите попытку позже", where: self?.controller)
                }
                return
            }
            
        }
        
        sendCode(message)
    }
    
    // MARK: - Send code
    
    private func sendCode(_ message: (messageBody: String, code: String)) {
        
        guard Reachability.isConnectedToNetwork() else {
            showAlert("Отсутствует доступ к интернету"
                      , "Проверьте подключение и повторите попытку", where: controller)
            return
        }
        
        print("\nCODE: \(message.code)\n")
        
        DispatchQueue.main.async {
            self.showEnterVerificationCodeAlert(validCode: message.code)
        }
        
//        SMSManager.sendSMS(phone: phone, message: message.messageBody + message.code){ [weak self] (result) in
//            DispatchQueue.main.async {
//                if result == .error  {
//                       showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self?.controller)
//                }
//
//                self?.showEnterVerificationCodeAlert(validCode: message.code)
//            }
//        }
        
    }
    
    // MARK: - Show "Enter verification code" alert
    
    private func showEnterVerificationCodeAlert(validCode: String) {
        
            AntiSpam.saveNewVerificationAttemp()

            let phoneNumber = phone.dropLast(7) + "*****" + phone.dropFirst(11)
            
            alert = .init(title: "Введите код из SMS:" , message: "отправлен на \(phoneNumber) ", preferredStyle: .alert)
            alert.addTextField() {
                $0.placeholder = "Код"
            }
        
            let closeButton = self.createCloseButton(alert)
        
            let confirmButton = UIAlertAction(title: "Подтвердить", style: .default) { [weak self] _ in
                
                guard let self = self else { return }
                guard Reachability.isConnectedToNetwork() else {
                    self.showCustomAlert("Отсутствует доступ к интернету", "Проверьте подключение и повторите попытку", self.alert)
                    return
                }
                
                guard var code = self.alert.textFields?.first?.text else{
                    self.controller.present(self.alert, animated: true)
                    return
                }
                
                self.alert.textFields?.first?.text = nil
        
                code.removeExtraSpaces()
                code = code.uppercased()
                
                guard !code.isEmpty else{
                    self.controller.present(self.alert, animated: true)
                    return
                }
                
                guard code == validCode else{
                    
                    if let timeLeft = AntiSpam.verificationBanTime {
                        showAlert("Превышено количество попыток", "Повторите попытку через \(timeLeft)", where: self.controller)
                        self.alert = nil
                        return
                    } else {
                        AntiSpam.saveNewCodeComparisonAttemp()
                    }
                    
                    self.newAlert = .init(title: "Код не совпадает!", message: "Повторите попытку", preferredStyle: .alert)
                    
                    let closeButton = self.createCloseButton(self.newAlert)
                    let okButton = UIAlertAction(title: "Ещё раз", style: .default){ [unowned self] _ in
                        self.controller.present(self.alert, animated: true)
                        self.newAlert = nil
                    }
                    
                    self.newAlert.addAction(closeButton)
                    self.newAlert.addAction(okButton)
                    self.newAlert.view.tintColor = UIColor.black
                    self.controller.present(self.newAlert, animated: true)
                
                    return
                }
                
                self.newAlert = nil
                self.alert = nil
                
                switch self.verificationModel {
                
                case .registration:
                    
                    AntiSpam.resetUserVerificationAttemps()
                    
                    Database.database().reference()
                        .child(FBDefaultKeys.profiles)
                        .childByAutoId().setValue([
                            FBProfileKeys.firstName : self.profile.firstName,
                            FBProfileKeys.secondName : self.profile.secondName,
                            FBProfileKeys.login : self.profile.login,
                            FBProfileKeys.password : self.profile.password,
                            FBProfileKeys.phoneNumber : self.profile.phoneNumber,
                            FBProfileKeys.balance : 0
                        ])
                    
                    Database.database().reference()
                        .child(FBDefaultKeys.profilesInfo)
                        .child(self.profile.login).setValue([
                            FBProfileInfoKeys.onlineStatus : FBOnlineStatuses.offline,
                            FBProfileInfoKeys.firstName : self.profile.firstName,
                            FBProfileInfoKeys.secondName : self.profile.secondName,
                            FBProfileInfoKeys.photo : "jpgDefault",
                            FBProfileTypes.user: FBProfileTypes.user
                        ])
                    
                    showAlert("Вы были успешно зарегистрированы!", nil , where: self.controller)
                    
                    DispatchQueue.main.async {
                        (self.controller as? RegistrationViewController)?.clearAllTextFields()
                    }
                    
                case .resetPassword:
                    self.resetPassword()
                }
                
                
                
            }
            
            alert.addAction(confirmButton)
            
            if AntiSpam.verificationBanTime == nil {
 
                guard Reachability.isConnectedToNetwork() else {
                    showCustomAlert("Отсутствует доступ к интернету", "Проверьте подключение и повторите попытку", alert)
                    return
                }
                
                let sendNewCodeButton = UIAlertAction(title: "Отправить новый код", style: .default) { [unowned self] _ in
                    
                    if let timeLeft = AntiSpam.sendingCodeBanTime {
                        showCustomAlert("Повторная отправка кода разрешена через \(timeLeft)", nil, alert)
                        return
                    }
                    
                    self.startVerification()
                }
                
                alert.addAction(sendNewCodeButton)
                
            }
            
            alert.addAction(closeButton)
            alert.view.tintColor = UIColor.black
            self.controller.present(alert, animated: true)
        
    }
    
    // MARK: - Creation close button
    
    private func createCloseButton( _ alertToReturn: UIAlertController!) -> UIAlertAction {
     
        UIAlertAction(title: "Закрыть", style: .destructive) { [unowned self] _ in
        
            let message = "Вы уверены, что хотите покинуть эту страницу?"
            var newAlert: UIAlertController! = .init(title: "Внимание", message: message, preferredStyle: .alert)
            
            let closeButton = UIAlertAction(title: "05", style: .default) { [unowned self] _ in
                self.alert = nil
                self.newAlert = nil
                newAlert = nil
                controller = nil
            }
            closeButton.isEnabled = false
            
            let backButton = UIAlertAction(title: "Вернуться", style: .default) { [unowned self] _ in
                self.controller.present(alertToReturn, animated: true)
                newAlert = nil
            }
            
            newAlert.addAction(closeButton)
            newAlert.addAction(backButton)
            backButton.setValue(UIColor.black, forKey: "titleTextColor")
            closeButton.setValue(UIColor.gray, forKey: "titleTextColor")
            controller.present(newAlert, animated: true){
                
                var timeLeft = UInt(5)
                let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ timer in
                    
                    timeLeft -= 1
                    guard timeLeft != 0 else {
                        closeButton.setValue(UIColor.red, forKey: "titleTextColor")
                        closeButton.setValue("Да", forKey: "title")
                        closeButton.isEnabled = true
                        timer.invalidate()
                        return
                    }
                    closeButton.setValue("0\(timeLeft)", forKey: "title")
                    
                }
                
            }
        }
    }
    
    // MARK: - Show custom alert
    
    private func showCustomAlert(_ title: String, _ message: String?, _ alertToReturn: UIAlertController) {
    
        var newAlert: UIAlertController! = .init(title: title, message: message, preferredStyle: .alert)
        let backButton = UIAlertAction(title: "Вернуться", style: .default) { [weak self] _ in
            self?.controller.present(alertToReturn, animated: true)
            newAlert = nil
        }
        newAlert.addAction(backButton)
        backButton.setValue(UIColor.black, forKey: "titleTextColor")
        controller.present(newAlert, animated: true)
        
    }
    
    // MARK: - Functions for password reset

    private func resetPassword() {
        
        alert = .init(title: "Сброс пароля", message: "Введите новый пароль:", preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "Пароль"
            $0.isSecureTextEntry = true
        }
        
        alert.addTextField {
            $0.placeholder = "Повторите пароль"
            $0.isSecureTextEntry = true
        }
        
        let submitButton = UIAlertAction(title: "Потвердить", style: .default) { [unowned self] _ in
            
            guard Reachability.isConnectedToNetwork() else {
                showCustomAlert("Отсутствует доступ к интернету", "Проверьте подключение и повторите попытку", alert)
                return
            }
            
            guard let password = alert.textFields?.first?.text, let repeatPassword = alert.textFields?.dropFirst().first?.text else {
                print("\n<PhoneNumberVerification\\resetPassword> ERROR: textFields aren't exist\n")
                showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self.controller)
                controller = nil
                alert = nil
                return
            }
            
            guard !password.isEmpty, !repeatPassword.isEmpty else {
                self.controller.present(alert, animated: true)
                return
            }
            
            if let errorText = getErrorIfTheTestsFail(password, repeatPassword) {
                showCustomAlert("Ошибка", errorText, alert)
                return
            }
            
            
            
            FireBaseDataBaseManager.openProfile(login: phone, password: self.password!,
                                                newPassword: Int64(password.hash)) { [unowned self] result, profileID in
                
                guard result != .error && result != .failure else{
                    showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self.controller)
                    alert = nil
                    controller = nil
                    return
                }
                
                if controller is AccountViewController {
                    
                    guard let profileID = profileID else { return }
    
                    FireBaseDataBaseManager.removeObserversFromProfile(profileID, self.profile.login)
                    FireBaseDataBaseManager.setProfileUpdateDate(profileID)
                    UserDefaults.standard.setValue(Date(), forKey: ConstantKeys.lastLogInDate)
                    FireBaseDataBaseManager.createProfileObserver(profileID, self.profile.login)
                }
                
                showAlert("Пароль был успешно изменен!", nil , where: self.controller)
                AntiSpam.resetUserVerificationAttemps()
                controller = nil
                alert = nil
                    
            }
            
        }
        
        let closeButton = createCloseButton(alert)
        alert.addAction(closeButton)
        alert.addAction(submitButton)
        alert.view.tintColor = UIColor.black
        self.controller.present(alert, animated: true)
        
    }
    
    private func getErrorIfTheTestsFail(_ password: String, _ repeatPassword: String) -> String? {
        
        if password.count < 8 || password.count > 64 {
            return  "Пароль должен содержать от 8 до 64 символов"
        } else if !(password ~= "^[A-Za-z\\d!@#$%^&*]{8,}$") {
            return "Пароль может содержать только латинские буквы, цифры и символы: !@#$%^&*"
        } else if !(password ~= "^(?=.*[A-Z])[A-Za-z\\d!@#$%^&*]{8,64}$") {
            return "Пароль должен содержать хотя бы одну прописную букву"
        } else if !(password ~= "^(?=.*[a-z])[A-Za-z\\d!@#$%^&*]{8,64}$") {
            return "Пароль должен содержать хотя бы одну строчную букву"
        } else if !(password ~= "^(?=.*\\d)[A-Za-z\\d!@#$%^&*]{8,64}$") {
            return "Пароль должен содержать хотя бы одну цифру"
        } else if self.password == Int64(password.hash) {
            return "Пароль не может быть идентичен старому"
        } else if repeatPassword != password {
            return "Пароли не совпадают"
        }
        return nil
        
    }
    
}
