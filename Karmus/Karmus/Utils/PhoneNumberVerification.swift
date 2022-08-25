//
//  PhoneNumberVerification.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import UIKit

final class PhoneNumberVerification {
    
    // MARK: - Private Properties
    
    private var controller: UIViewController
    private var verificationModel: VerificationModel
    private var name: String
    private var phone: String
    private var password: Int64?
    private var message: (messageBody: String, code: String)?
    private var profile: ProfileItem
    private var isBalanceEnough: Bool?
    
    // MARK: - Initializers
    
    init? (profile: ProfileItem, for verificationModel: VerificationModel, _ controller: UIViewController) {
        self.verificationModel = verificationModel
        self.controller = controller
        self.profile = profile
        guard let name = profile.firstName, let phone = profile.phoneNumber else{
            return nil
        }
        if verificationModel == .resetPassword {
            guard CoreDataManager.tryToOpenProfile(login: phone, password: profile.password) else{
                return nil
            }
            self.password = profile.password
        }
        self.name = name
        self.phone = phone
    }
    
    // MARK: - Start verification
    
    func startVerification() {
        
        if let timeLeft = AntiSpam.verificationBanTime {
            showAlert("Превышено количество попыток", "Повторите попытку через \(timeLeft)", where: self.controller)
            return
        }
        
        checkBalanceAndSendCode()
        
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
        
        guard isMessageCreated() else{ return }
        
        guard let message = self.message else {
            print("\n<PhoneNumberVerification\\checkBalanceAndSendCode> ERROR: message wasn't created\n")
            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self.controller)
            return
        }
        
            
        SMSManager.isBalanceEnough{ [weak self] (error, isBalanceEnough) in
            
            guard let self = self else{
                print("\n<PhoneNumberVerification\\checkBalanceAndSendCode> ERROR: PhoneNumberVerification class isn't exist\n")
                return
            }
            
            guard let isBalanceEnough = isBalanceEnough else {
                DispatchQueue.main.async {
                    showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self.controller)
                }
                return
            }
            
            guard isBalanceEnough else {
                print("\n<PhoneNumberVerification\\checkBalanceAndSendCode> ERROR: low balance\n")
                DispatchQueue.main.async {
                    showAlert("Невозможно отправить код", "Повторите попытку позже", where: self.controller)
                }
                return
            }
            
            self.sendCode(message)
            
        }
    }
    
    // MARK: - Send code
    
    private func sendCode(_ message: (messageBody: String, code: String)) {
        print("\nCODE: \(message.code)\n")
        
//        SMSManager.sendSMS(phone: phone, message: message.messageBody + message.code){ [weak self] (result) in
//            guard let self = self else {
//                print("\n<PhoneNumberVerification\\sendCode> ERROR: PhoneNumberVerification class isn't exist\n")
//                return
//            }
//
//            if result == .error  {
//                DispatchQueue.main.async {
//                    self.showAlert("Произошла ошибка", "Обратитесь к разработчику приложения")
//                }
//            }
//
//            self.showEnterVerificationCode(validCode: message.code)
//        }
        
        self.showEnterVerificationCodeAlert(validCode: message.code)
        
    }
    
    // MARK: - Show "Enter verification code" alert
    
    private func showEnterVerificationCodeAlert(validCode: String) {
        DispatchQueue.main.async {
            AntiSpam.saveNewVerificationAttemp()
            
            let phoneNumber = self.phone.dropLast(7) + "*****" + self.phone.dropFirst(11)
            
            let alert = UIAlertController.init(title: "Введите код из SMS:" , message: "отправлен на \(phoneNumber) ", preferredStyle: .alert)
            alert.addTextField() {
                $0.placeholder = "Код"
            }
        
            let closeButton = self.createCloseButton(alert)
        
            let confirmButton = UIAlertAction(title: "Подтвердить", style: .default) { [unowned self] _ in
                
                guard var code = alert.textFields?.first?.text else{
                    self.controller.present(alert, animated: true)
                    return
                }
                
                alert.textFields?.first?.text = nil
        
                code.removeExtraSpaces()
                code = code.uppercased()
                
                guard !code.isEmpty else{
                    self.controller.present(alert, animated: true)
                    return
                }
                
                guard code == validCode else{
                    
                    if let timeLeft = AntiSpam.verificationBanTime {
                        showAlert("Превышено количество попыток", "Повторите попытку через \(timeLeft)", where: self.controller)
                        return
                    } else {
                        AntiSpam.saveNewCodeComparisonAttemp()
                    }
                    
                    let newAlert = UIAlertController.init(title: "Код не совпадает!", message: "Повторите попытку", preferredStyle: .alert)
                    
                    let closeButton = createCloseButton(newAlert)
                    let okButton = UIAlertAction(title: "Ещё раз", style: .default){ _ in
                        self.controller.present(alert, animated: true)
                    }
                    
                    newAlert.addAction(closeButton)
                    newAlert.addAction(okButton)
                    newAlert.view.tintColor = UIColor.black
                    self.controller.present(newAlert, animated: true)
                
                    return
                }
                
                switch verificationModel {
                
                case .registration:
                    
                    let newProfile = Profile(context: CoreDataManager.context)
                    newProfile.firstName = profile.firstName
                    newProfile.secondName = profile.secondName
                    newProfile.login = profile.login
                    newProfile.password = profile.password
                    newProfile.phoneNumber = profile.phoneNumber
                    
                    if CoreDataManager.saveProfile(profile: newProfile) {
                        showAlert("Вы были успешно зарегистрированы!", nil, where: self.controller)
                    } else {
                        showAlert("Ууупс, что-то пошло не так", "Обратитесь к разработчику приложения", where: self.controller)
                    }
                    AntiSpam.resetUserVerificationAttemps()
                    
                case .resetPassword:
                    resetPassword()
                }
              
                
            }
            
            alert.addAction(confirmButton)
            
            if AntiSpam.verificationBanTime == nil {
                
                let sendNewCodeButton = UIAlertAction(title: "Отправить новый код", style: .default) { [unowned self] _ in
                    
                    if let timeLeft = AntiSpam.sendingCodeBanTime {
                        let title = "Повторная отправка кода разрешена через \(timeLeft)"
                        let newAlert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
                        
                        let closeButton = UIAlertAction(title: "Вернуться", style: .cancel){ [unowned self] _ in
                            self.controller.present(alert, animated: true)
                        }
                        
                        newAlert.addAction(closeButton)
                        newAlert.view.tintColor = UIColor.black
                        self.controller.present(newAlert, animated: true)
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
        
    }
    
    // MARK: - Creation close button
    
    private func createCloseButton(_ alertToReturn: UIAlertController) -> UIAlertAction {
     
        UIAlertAction(title: "Закрыть", style: .destructive) { [unowned self] _ in
        
            let message = "Вы уверены, что хотите покинуть эту страницу?"
            let newAlert = UIAlertController.init(title: "Внимание", message: message, preferredStyle: .alert)
            let closeButton = UIAlertAction(title: "05", style: .default)
            closeButton.isEnabled = false
            let backButton = UIAlertAction(title: "Вернуться", style: .default) { [unowned self] _ in
                self.controller.present(alertToReturn, animated: true)
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
    
    // MARK: - Functions for password reset

    private func resetPassword() {
        
        let alert = UIAlertController(title: "Сброс пароля", message: "Введите новый пароль:", preferredStyle: .alert)
        
        alert.addTextField{
            $0.placeholder = "Пароль"
            $0.isSecureTextEntry = true
        }
        alert.addTextField{
            $0.placeholder = "Повторите пароль"
            $0.isSecureTextEntry = true
        }
        
        let submitButton = UIAlertAction(title: "Потвердить", style: .default) { [unowned self] _ in
            guard let password = alert.textFields?.first?.text, let repeatPassword = alert.textFields?.dropFirst().first?.text else {
                print("\n<PhoneNumberVerification\\resetPassword> ERROR: textFields aren't exist\n")
                showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self.controller)
                return
            }
            
            guard !password.isEmpty, !repeatPassword.isEmpty else {
                self.controller.present(alert, animated: true)
                return
            }
            
            if let errorText = getErrorIfTheTestsFail(password, repeatPassword) {
                let newAlert = UIAlertController.init(title: "Ошибка", message: errorText, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default){ [unowned self] _ in
                    self.controller.present(alert, animated: true)
                }
                newAlert.addAction(okButton)
                newAlert.view.tintColor = UIColor.black
                controller.present(newAlert, animated: true)
                return
            }
            
            _ = CoreDataManager
                .tryToOpenProfile(login: phone, password: self.password!, newPassword: Int64(password.hash), self.controller)
            AntiSpam.resetUserLogInAttemps()
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
