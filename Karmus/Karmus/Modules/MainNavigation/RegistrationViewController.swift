//
//  RegistrationView.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit

enum RegistrationElements: Int{
    case firstName = 1
    case secondName = 2
    case login = 3
    case password = 4
    case repeatPassword = 5
    case email = 6
}

fileprivate enum ShowOrHide{
    case show, hide
}

fileprivate enum ButtonIcon{
    case correct, incorrect
}

final class RegistrationViewController: UIViewController {

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
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var emailCheckButton: UIButton!
    
    @IBOutlet private weak var agreementSwitch: UISwitch!
    
    @IBOutlet private weak var registrationButton: UIButton!
    
    private var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registrationButton.layer.cornerRadius = 3
        
        firstNameTextField.delegate = self
        secondNameTextField.delegate = self
        loginTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        emailTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
        if keyboard.minY != view.frame.maxY{
            mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboard.height + 5, right: 0)
        } else {
            mainScrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
    @IBAction private func didTapRegistrationButton(_ sender: UIButton) {
        
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func changeButtonIcon(for textField: RegistrationElements, icon: ButtonIcon){
        let image = UIImage(named: icon == .correct ? "iconOK" : "iconError")
        switch textField {
        case .firstName:
            firstNameCheckButton.setBackgroundImage(image, for: .normal)
        case .secondName:
            secondNameCheckButton.setBackgroundImage(image, for: .normal)
        case .login:
            loginCheckButton.setBackgroundImage(image, for: .normal)
        case .password:
            passwordCheckButton.setBackgroundImage(image, for: .normal)
        case .repeatPassword:
            repeatPasswordCheckButton.setBackgroundImage(image, for: .normal)
        case .email:
            emailCheckButton.setBackgroundImage(image, for: .normal)
        }
    }
    
    private func showOrHideButton(for textField: RegistrationElements, action: ShowOrHide){
        switch textField {
        case .firstName:
            firstNameCheckButton.isHidden = action == .hide ? true : false
        case .secondName:
            secondNameCheckButton.isHidden = action == .hide ? true : false
        case .login:
            loginCheckButton.isHidden = action == .hide ? true : false
        case .password:
            passwordCheckButton.isHidden = action == .hide ? true : false
        case .repeatPassword:
            repeatPasswordCheckButton.isHidden = action == .hide ? true : false
        case .email:
            emailCheckButton.isHidden = action == .hide ? true : false
        }
    }
    
    private func isTextCorrect(_ text: String, for textField: RegistrationElements) -> Bool{
        switch textField {
        case .login:
            return text ~= "^[A-Za-z]+([-_]?[A-Za-z0-9]+){0,2}$" && text.count >= 3 ? true : false
        case .password:
            return text ~= "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*]{8,}$" ? true : false
        case .repeatPassword:
            return text.count >= 8 && text == self.password ? true : false
        case .email:
            return text ~= "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" ? true : false
        default:
            return text ~= "[A-za-zА-Яа-я]{2,}" ? true : false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textFieldByTag = RegistrationElements(rawValue: textField.tag)  else {
            print("\nSomething went wrong: textField isn't exist\n")
            return
        }
        textField.layer.borderColor = CGColor(gray: 255, alpha: 1)
        textField.layer.borderWidth = 0
        showOrHideButton(for: textFieldByTag, action: .hide)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let textFieldByTag = RegistrationElements(rawValue: textField.tag) else {
            print("\nSomething went wrong: textField isn't exist\n")
            return
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textFieldByTag = RegistrationElements(rawValue: textField.tag)  else {
            print("\nSomething went wrong: textField isn't exist\n")
            return
        }
        
        if isTextCorrect(textField.text ?? "", for: textFieldByTag){
            textField.layer.borderColor = CGColor(red: 0, green: 255, blue: 0, alpha: 1)
            changeButtonIcon(for: textFieldByTag, icon: .correct)
        } else {
            textField.layer.borderColor = CGColor(red: 255, green: 0, blue: 0, alpha: 1)
            changeButtonIcon(for: textFieldByTag, icon: .incorrect)
        }
        textField.layer.borderWidth = 1
        showOrHideButton(for: textFieldByTag, action: .show)
    }
    
    
}

extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}


