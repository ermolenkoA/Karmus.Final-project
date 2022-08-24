//
//  RegistrationView.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit
import CoreData

final class RegistrationViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainScrollView: UIScrollView!
    
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var firstNameCheckButton: UIButton!
    
    @IBOutlet private weak var secondNameTextField: UITextField!
    @IBOutlet private weak var secondNameCheckButton: UIButton!
    
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var loginCheckButton: UIButton!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var passwordCheckButton: UIButton!
    
    @IBOutlet private weak var repeatPasswordTextField: UITextField!
    @IBOutlet private weak var repeatPasswordCheckButton: UIButton!
    
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var phoneNumberCheckButton: UIButton!
    
    @IBOutlet private weak var agreementSwitch: UISwitch!
    
    @IBOutlet private weak var registrationButton: UIButton!
    
    // MARK: - Private Properties
    
    private var correctTextFields = Set<RegistrationElements>()
    private let maxPhoneNumberLength = 13
    
    private var activeTextField: UITextField?
    
    private let greenColor = CGColor(red: 0, green: 255, blue: 0, alpha: 1)
    private let redColor = CGColor(red: 255, green: 0, blue: 0, alpha: 1)
    
    private var phoneNumberVerification: PhoneNumberVerification?
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registrationButton.alpha = 0.5
        registrationButton.layer.cornerRadius = 3
        
        firstNameTextField.delegate = self
        secondNameTextField.delegate = self
        loginTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        phoneNumberTextField.delegate = self
            
        passwordTextField.textContentType = .none
        repeatPasswordTextField.textContentType = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: Notification){
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyboard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if keyboard.minY != view.frame.maxY{
            mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboard.height, right: 0)
        } else {
            mainScrollView.contentInset = UIEdgeInsets.zero
        }
        
    }
    
    // MARK: - Change Correct TextFields
    
    private func changeCorrectTextFields(registrationElement: RegistrationElements, formFillResult: Result){
        
        if formFillResult == .correct {
            correctTextFields.insert(registrationElement)
        } else {
            correctTextFields.remove(registrationElement)
        }
        registrationButton.isUserInteractionEnabled = correctTextFields.count == 6 && agreementSwitch.isOn
        registrationButton.alpha = registrationButton.isUserInteractionEnabled ? 1 : 0.5
    }
    
    
    
    // MARK: - IBAction
    
    
    @IBAction func didTapCheckButton(_ sender: UIButton) {
        
        var textFieldByButton: UITextField? {
            switch sender {
            case firstNameCheckButton:
                return firstNameTextField
            case secondNameCheckButton:
                return secondNameTextField
            case loginCheckButton:
                return loginTextField
            case passwordCheckButton:
                return passwordTextField
            case repeatPasswordCheckButton:
                return repeatPasswordTextField
            case phoneNumberCheckButton:
                return phoneNumberTextField
            default:
                return nil
            }
        }
        
        guard textFieldByButton != nil else {
            print("\n<didTapCheckButton> ERROR: textFieldByButton isn't exist\n")
            return
        }
    
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") else {
            print("\n<didTapCheckButton> ERROR: ViewController withIdentifier \"popVC\" isn't exist\n")
            return
        }
        
        popVC.modalPresentationStyle = .popover
        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = sender
        popOverVC?.sourceRect = CGRect(x: sender.bounds.minX, y: sender.bounds.midY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: 270, height: 90)
        
        (popVC as! GetDescriptionProtocol).getDescription(getErrorText(textField: textFieldByButton!) ?? "Текст введен корректно")
    
        self.present(popVC, animated: true)
        
    }
    
    @IBAction private func changedAgreementSwitch(_ sender: UISwitch) {
        registrationButton.isEnabled = correctTextFields.count == 6 && agreementSwitch.isOn
        registrationButton.alpha = registrationButton.isEnabled ? 1 : 0.5
    }
    
    @IBAction private func didTapRegistrationButton(_ sender: UIButton) {
        
        let profile = ProfileItem()
        profile.firstName = firstNameTextField.text
        profile.secondName = secondNameTextField.text
        profile.login = loginTextField.text
        if let password = passwordTextField.text?.hashValue {
            profile.password = Int64(password)
        }
        profile.phoneNumber = phoneNumberTextField.text
        
        clearAllTextFields()
        correctTextFields.removeAll()
        
        phoneNumberVerification = PhoneNumberVerification()
        phoneNumberVerification?.startVerification(profile: profile, self)
    
        registrationButton.isUserInteractionEnabled = false
        registrationButton.alpha =  0.5
        
    }
    
    @IBAction private func touchBeganOutside(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

// MARK: - UIPopoverPresentationControllerDelegate

extension RegistrationViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

// MARK: - UITextFieldDelegate

extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField{
        case firstNameTextField:
            secondNameTextField.becomeFirstResponder()
        case secondNameTextField:
            loginTextField.becomeFirstResponder()
        case loginTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            repeatPasswordTextField.becomeFirstResponder()
        case repeatPasswordTextField:
            phoneNumberTextField.becomeFirstResponder()
        case phoneNumberTextField:
            textField.resignFirstResponder()
        default:
            return true
        }
        return true
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let registrationElement = findTextFieldByTag(textField) else {
            print("\n<textFieldDidBeginEditing> ERROR: textField doesn't apple to registration elements\n")
            return
        }
        
        textField.layer.borderColor = CGColor(gray: 255, alpha: 1)
        textField.layer.borderWidth = 0
        
        showOrHideButton(for: textField, action: .hide)
        changeCorrectTextFields(registrationElement: registrationElement, formFillResult: .incorrect)
        
        if registrationElement == .password {
            textFieldDidBeginEditing(repeatPasswordTextField)
        } else if registrationElement == .phoneNumber {
            guard let number = textField.text, !number.isEmpty else{
                textField.text = "+375"
                return
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.contains(" ") else {
            return false
        }
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case firstNameTextField:
            return newText.count < 20
        case secondNameTextField:
            return newText.count < 30
        case loginTextField:
            return newText.count < 24
        case passwordTextField:
            return newText.count < 64
        case repeatPasswordTextField:
            return newText.count < 64
        case phoneNumberTextField:
            return newText ~= "^\\+375([\\d]{0,9})$"
        default:
            return true
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let registrationElement = findTextFieldByTag(textField) else {
            print("\n<textFieldDidEndEditing> ERROR: textField doesn't apple to registration elements\n")
            return
        }
        
        
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        guard text != "+375" || registrationElement != .phoneNumber else {
            textField.text = nil
            return
        }
        
        
        textField.layer.borderColor = isTextInTextFieldCorrect(textField: textField) ? greenColor : redColor
        
        let result: Result = textField.layer.borderColor == greenColor ? .correct : .incorrect
        
        changeButtonIcon(for: textField, icon: result)
        changeCorrectTextFields(registrationElement: registrationElement, formFillResult: result)
        
        textField.layer.borderWidth = 1
        showOrHideButton(for: textField, action: .show)
    }
    
}

// MARK: - Tests and usefull functions for textFields

extension RegistrationViewController{
    
    private func findTextFieldByTag(_ textField: UITextField) -> RegistrationElements? {
        
        switch textField {
        case firstNameTextField:
            return .firstName
        case secondNameTextField:
            return .secondName
        case loginTextField:
            return .login
        case passwordTextField:
            return .password
        case repeatPasswordTextField:
            return .repeatPassword
        case phoneNumberTextField:
            return .phoneNumber
        default:
            return nil
        }
        
    }
    
    private func clearAllTextFields(){
        
        let textFields: [UITextField] = [firstNameTextField, secondNameTextField, loginTextField, passwordTextField, repeatPasswordTextField, phoneNumberTextField]
        for textField in textFields {

            textField.text = nil
            textField.layer.borderColor = CGColor(gray: 255, alpha: 1)
            textField.layer.borderWidth = 0
            
            showOrHideButton(for: textField, action: .hide)
        }
        agreementSwitch.isOn = false
        
    }
    
    private func changeButtonIcon(for textField: UITextField, icon: Result){
        let image = UIImage(named: icon == .correct ? "iconOK" : "iconError")
        
        var button: UIButton {
            switch textField {
            case firstNameTextField:
                return firstNameCheckButton
            case secondNameTextField:
                return secondNameCheckButton
            case loginTextField:
                return loginCheckButton
            case passwordTextField:
                return passwordCheckButton
            case repeatPasswordTextField:
                return repeatPasswordCheckButton
            case phoneNumberTextField:
                return phoneNumberCheckButton
            default:
                return UIButton()
            }
        }
        
        button.setBackgroundImage(image, for: .normal)
        button.isUserInteractionEnabled = icon == .incorrect
    }
    
    private func showOrHideButton(for textField: UITextField, action: ShowOrHide){
        switch textField {
        
        case firstNameTextField:
            firstNameCheckButton.isHidden = action == .hide
        case secondNameTextField:
            secondNameCheckButton.isHidden = action == .hide
        case loginTextField:
            loginCheckButton.isHidden = action == .hide
        case passwordTextField:
            passwordCheckButton.isHidden = action == .hide
        case repeatPasswordTextField:
            repeatPasswordCheckButton.isHidden = action == .hide
        case phoneNumberTextField:
            phoneNumberCheckButton.isHidden = action == .hide
        default:
            break
        }
        
    }
    
    private func isTextInTextFieldCorrect(textField: UITextField) -> Bool{
        
        let text = textField.text ?? ""

        switch textField {
        case firstNameTextField:
            return text ~= "^[A-za-zА-Яа-я]{2,}$"
        case secondNameTextField:
            return text ~= "^[A-za-zА-Яа-я]{2,}$"
        case loginTextField:
            return text ~= "^[A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}$" && text.count >= 3 && !CoreDataManager.isLoginExist(text)!
        case passwordTextField:
            return text ~= "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*]{8,}$"
        case repeatPasswordTextField:
            guard passwordTextField.layer.borderColor == greenColor else { return false }
            return text == passwordTextField.text
        case phoneNumberTextField:
            return text ~= "^(\\+375)(29|25|33|44)([\\d]{7})$" && !CoreDataManager.isPhoneNumberExist(text)!
        default:
            return 2 + 2 == 4
        }
        
    }
    
    private func getErrorText(textField: UITextField) -> String? {
        
        let text = textField.text ?? ""
        
        switch textField {
        case firstNameTextField:
            if text.count < 2 {
                return "Имя должно содержать от 2 до 20 символов"
            } else if !(text ~= "^[A-za-zА-Яа-я]{2,}$") {
                return "Имя может содержать только буквы русского и латинского алфавитов"
            }
        case secondNameTextField:
            if text.count < 2 {
                return "Фамилия должна содержать от 2 до 30 символов"
            } else if !(text ~= "^[A-za-zА-Яа-я]{2,}$") {
                return "Фамилия может содержать только буквы русского и латинского алфавитов"
            }
        case loginTextField:
            if text.count < 3 {
                return "Логин должен содержать от 3 до 25 символов"
            } else if !(text ~= "^[-_\\.A-Za-z\\d]+$") {
                return "Логин может содержать только латинские буквы, цифры, \"-\", \".\", \"_\""
            } else if !(text ~= "^[A-Za-z]+[-_\\.A-Za-z0-9]+$") {
                return "Логин должен начинаться с буквы"
            } else if !(text ~= "^[-_\\.A-Za-z0-9]+[A-Za-z0-9]+$") {
                return "Логин не может заканчиваться на (\"_\", \"-\", \".\")"
            } else if !(text ~= "^([-_\\.]?[A-Za-z0-9]+){0,2}$") {
                return "Логин не может содержать более двух знаков (\"_\", \"-\", \".\") и не под ряд"
            } else if CoreDataManager.isLoginExist(text)! {
                return "Логин уже используется"
            }
        case passwordTextField:
            if text.count < 8 {
                return "Пароль должен содержать от 8 до 64 символов"
            } else if !(text ~= "^[A-Za-z\\d!@#$%^&*]{8,}$") {
                return "Пароль может содержать только латинские буквы, цифры и символы: !@#$%^&*"
            } else if !(text ~= "^(?=.*[A-Z])[A-Za-z\\d!@#$%^&*]{8,}$") {
                return "Пароль должен содержать хотя бы одну прописную букву"
            } else if !(text ~= "^(?=.*[a-z])[A-Za-z\\d!@#$%^&*]{8,}$") {
                return "Пароль должен содержать хотя бы одну строчную букву"
            } else if !(text ~= "^(?=.*\\d)[A-Za-z\\d!@#$%^&*]{8,}$") {
                return "Пароль должен содержать хотя бы одну цифру"
            }
        case repeatPasswordTextField:
            if passwordTextField.layer.borderColor == redColor {
                return "Для начала введите валидный пароль строкой выше"
            } else if text != passwordTextField.text {
                return "Пароли не совпадают"
            }
        case phoneNumberTextField:
            if !(text ~= "^(\\+375)(29|25|33|44)([\\d]{7})$") {
                return "Номер телефона не существует (только номера РБ)"
            } else if CoreDataManager.isPhoneNumberExist(text)! {
                return "Пользователь с таким номером телефона уже зарегистрирован"
            }
        default:
            return nil
        }

        return nil
        
    }
}

