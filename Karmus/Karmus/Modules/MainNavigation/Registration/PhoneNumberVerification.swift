//
//  PhoneNumberVerification.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import UIKit

class PhoneNumberVerification {
    
    private weak var controller: UIViewController?
    private var time = UInt(60)
    private var timer = Timer()
    private var name = "Пользователь"
    private var phone = ""
    private var message: (messageBody: String, code: String)?
    private var profile: ProfileItem?
    private var isBalanceEnough: Bool?
    
    func startVerification(profile: ProfileItem, _ controller: UIViewController) {
        self.controller = controller
        self.profile = profile
        guard let name = profile.firstName, let phone = profile.phoneNumber else{
            return
        }
        self.name = name
        self.phone = phone
        verification()
    }
    
    func startVerification(name: String, phone: String, _ controller: UIViewController) {
        self.controller = controller
        self.name = name
        self.phone = phone
        verification()
    }
    
    private func verification() {
        
        if let date = UserDefaults.standard.object(forKey: ConstantKeys.verificationBlockingTime) as? Date {
            if showTimeBeforeUnlockVerification(date){
                return
            } else {
                let newDate: Date? = nil
                UserDefaults.standard.setValue(newDate, forKey: ConstantKeys.verificationBlockingTime)
                UserDefaults.standard.setValue(UInt(0), forKey: ConstantKeys.verificationAttemps)
                UserDefaults.standard.setValue(UInt(0), forKey: ConstantKeys.verificationSendCodeAttemps)
            }
        }
        
        message = Code.shared.messageWithCode(name: name)
        checkBalanceAndSendCode(message!)
    }
    
    private func checkBalanceAndSendCode(_ message: (messageBody: String, code: String)) {
        SMSManager.isBalanceEnough{ [weak self] (error, isBalanceEnough) in
            
            guard let self = self else{
                print("\n<PhoneNumberVerification\\checkBalanceAndSendCode> ERROR: PhoneNumberVerification class isn't exist\n")
                return
            }
            
            guard let isBalanceEnough = isBalanceEnough else {
                DispatchQueue.main.async {
                    let alert = UIAlertController.init(title: "Произошла ошибка", message: "Обратитесь к разработчику приложения", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okButton)
                    alert.view.tintColor = UIColor.black
                    self.controller?.present(alert, animated: true)
                }
                return
            }
            
            guard isBalanceEnough else {
                DispatchQueue.main.async {
                    let alert = UIAlertController.init(title: "Невозможно отправить код", message: "Баланса недостаточно", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okButton)
                    alert.view.tintColor = UIColor.black
                    self.controller?.present(alert, animated: true)
                }
                return
            }
            
            self.sendCode(message)
            
        }
    }
    
    private func sendCode(_ message: (messageBody: String, code: String)) {
        print("\nCODE: \(message.code)\n")
        
        SMSManager.sendSMS(phone: phone, message: message.messageBody + message.code){ [weak self] (result) in
            guard let self = self else {
                print("\n<PhoneNumberVerification\\sendCode> ERROR: PhoneNumberVerification class isn't exist\n")
                return
            }
            
            if result == .error  {
                DispatchQueue.main.async {
                    let alert = UIAlertController.init(title: "Произошла ошибка", message: "Обратитесь к разработчику приложения", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okButton)
                    alert.view.tintColor = UIColor.black
                    self.controller?.present(alert, animated: true)
                }
            }
            
            self.showEnterVerificationCode(validCode: message.code)
        }
        
        
    }
    
    @objc func tick(timer: Timer) {
        guard self.time != 0 else {
            timer.invalidate()
            return
        }
        self.time -= 1
    }
    
    private func showTimeBeforeUnlockVerification(_ unlockDate: Date) -> Bool {
        
        guard unlockDate.isGreaterThanDate(dateToCompare: Date()) else {
            return false
        }
        
        var timeLeft: String {
            let timeDifference = Calendar.current.dateComponents([.hour,.minute,.second], from: Date(), to: unlockDate)
            return String(format: "%02d:%02d:%02d", timeDifference.hour!, timeDifference.minute!, timeDifference.second!)
        }
        
        let alert = UIAlertController.init(title: "Превышено количество попыток", message: "Повторите попытку через \(timeLeft)", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        alert.view.tintColor = UIColor.black
        controller?.present(alert, animated: true)
        
        return true
    }
    
    private func showEnterVerificationCode(validCode: String) {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.tick(timer:)), userInfo: nil, repeats: true)
            self.time = 60
            let alert = UIAlertController.init(title: "Введите код из SMS:", message: nil, preferredStyle: .alert)
        
            alert.addTextField() {
                $0.placeholder = "Код"
            }
        
            let closeButton = UIAlertAction(title: "Закрыть", style: .cancel){ _ in
                if let attemps = UserDefaults.standard.object(forKey: ConstantKeys.verificationAttemps) as? UInt{
                    UserDefaults.standard.setValue(attemps + 1, forKey: ConstantKeys.verificationAttemps)
                    UserDefaults.standard.setValue(UInt(0), forKey: ConstantKeys.verificationSendCodeAttemps)
                } else {
                    UserDefaults.standard.setValue(UInt(1), forKey: ConstantKeys.verificationAttemps)
                    UserDefaults.standard.setValue(UInt(0), forKey: ConstantKeys.verificationSendCodeAttemps)
                }
            }
            
            let sendNewCodeButton = UIAlertAction(title: "Отправить новый код", style: .default) { [weak self] _ in
                
                guard self?.time == 0 else {
                    let newAlert = UIAlertController.init(title: "Повторная отправка кода разрешена через \(self?.time ?? 0) секунд", message: nil, preferredStyle: .alert)
                    
                    let closeButton = UIAlertAction(title: "Вернуться", style: .cancel){ [weak self] _ in
                        self?.controller?.present(alert, animated: true)
                    }
                    
                    newAlert.addAction(closeButton)
                    newAlert.view.tintColor = UIColor.black
                    self?.controller?.present(newAlert, animated: true)
                    return
                    
                }
                
                if let attemps = UserDefaults.standard.object(forKey: ConstantKeys.verificationAttemps) as? UInt{
                    
                    UserDefaults.standard.setValue(attemps + 1, forKey: ConstantKeys.verificationAttemps)
                    UserDefaults.standard.setValue(UInt(0), forKey: ConstantKeys.verificationSendCodeAttemps)
                    if attemps + 1 >= ConstantValues.maxVerificationAttemps{
                        let unlockDate = Date().addMinutes(minutesToAdd: ConstantValues.defaultTimeBan)
                        UserDefaults.standard.setValue(unlockDate, forKey: ConstantKeys.verificationBlockingTime)
                        _ = self?.showTimeBeforeUnlockVerification(unlockDate)
                        return
                    }

                } else {
                    UserDefaults.standard.setValue(UInt(1), forKey: ConstantKeys.verificationAttemps)
                    UserDefaults.standard.setValue(UInt(0), forKey: ConstantKeys.verificationSendCodeAttemps)
                }
                
                guard let self = self else{
                    print("\n<PhoneNumberVerification\\showEnterVerificationCode\\sendNewCodeButton> ERROR: button is out of PhoneNumberVerification class\n")
                    return
                }
                
                self.message = Code.shared.messageWithCode(name: self.name)
                
                self.checkBalanceAndSendCode(self.message!)
            }
            
            let confirmButton = UIAlertAction(title: "Подтвердить", style: .default) { [weak self] _ in
                
                guard var code = alert.textFields?.first?.text, !code.isEmpty else{
                    self?.controller?.present(alert, animated: true)
                    return
                }
                
                repeat {
                    
                    guard code.starts(with: " ") else {
                        break
                    }
                    code.removeFirst()
                    
                } while !code.isEmpty
                
                guard !code.isEmpty else{
                    self?.controller?.present(alert, animated: true)
                    return
                }
                
                repeat {
                    
                    guard code[code.index(before: code.endIndex)] == " " else {
                        break
                    }
                    code.removeLast()
                    
                } while !code.isEmpty
                
                guard !code.isEmpty else{
                    self?.controller?.present(alert, animated: true)
                    return
                }
                
                guard code == validCode else{
                    
                    if let attemps = UserDefaults.standard.object(forKey: ConstantKeys.verificationSendCodeAttemps) as? UInt{
                        
                        UserDefaults.standard.setValue(attemps + 1, forKey: ConstantKeys.verificationSendCodeAttemps)
                        if attemps + 1 >= ConstantValues.maxVerificationSendCodeAttemps{
                            let unlockDate = Date().addMinutes(minutesToAdd: ConstantValues.defaultTimeBan)
                            UserDefaults.standard.setValue(unlockDate, forKey: ConstantKeys.verificationBlockingTime)
                            _ = self?.showTimeBeforeUnlockVerification(unlockDate)
                            return
                        }
                    
                    } else {
                        UserDefaults.standard.setValue(UInt(1), forKey: ConstantKeys.verificationSendCodeAttemps)
                    }
                    
                    let newAlert = UIAlertController.init(title: "Код не совпадает!", message: "Повторите попытку", preferredStyle: .alert)
                    
                    let closeButton = UIAlertAction(title: "Закрыть", style: .cancel)
                    let okButton = UIAlertAction(title: "Ещё раз", style: .default){ _ in
                        self?.controller?.present(alert, animated: true)
                    }
                    
                    newAlert.addAction(closeButton)
                    newAlert.addAction(okButton)
                    newAlert.view.tintColor = UIColor.black
                    self?.controller?.present(newAlert, animated: true)
                
                    return
                }
                
                let newDate: Date? = nil
                UserDefaults.standard.setValue(newDate, forKey: ConstantKeys.verificationBlockingTime)
                UserDefaults.standard.setValue(UInt(0), forKey: ConstantKeys.verificationAttemps)
                UserDefaults.standard.setValue(UInt(0), forKey: ConstantKeys.verificationSendCodeAttemps)
                
                if let profile = self?.profile {
//                    let newProfile = Profile(context: CoreDataManager.context)
//                    newProfile.firstName = profile.firstName
//                    newProfile.secondName = profile.secondName
//                    newProfile.login = profile.login
//                    newProfile.password = profile.password
//                    newProfile.phoneNumber = profile.phoneNumber
                    
                    var newAlert: UIAlertController
//                        if CoreDataManager.saveProfile(profile: newProfile) {
                    if true {
                        newAlert = UIAlertController.init(title: "Вы были успешно зарегистрированы!", message: nil, preferredStyle: .alert)
                    } else {
                        newAlert = UIAlertController.init(title: "Ууупс, что-то пошло не так", message: "Обратитесь к разработчику приложения", preferredStyle: .alert)
                    }
                    let closeButton = UIAlertAction(title: "Close", style: .cancel)
                    newAlert.addAction(closeButton)
                    newAlert.view.tintColor = UIColor.black
                    self?.controller?.present(newAlert, animated: true)
                }
                
            }
            alert.addAction(closeButton)
            alert.addAction(confirmButton)
            alert.addAction(sendNewCodeButton)
            alert.view.tintColor = UIColor.black
            self.controller?.present(alert, animated: true)
        }
    }
    
}

