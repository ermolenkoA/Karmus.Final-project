//
//  CreateCouponViewController.swift
//  Karmus
//
//  Created by VironIT on 9/12/22.
//

import UIKit
import FirebaseDatabase
import KeychainSwift

final class CreateCouponViewController: UIViewController {

    // MARK: - IBOutlet

    @IBOutlet private weak var mainActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    @IBOutlet private weak var priceDecreaseButton: UIButton!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var priceIncreaseButton: UIButton!
    
    @IBOutlet private weak var amountDecreaseButton: UIButton!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountIncreaseButton: UIButton!
    
    @IBOutlet private weak var generateCouponsButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        titleTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)

        titleTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
     // MARK: - Private functions
    
    private func startSending() {
        view.isUserInteractionEnabled = false
        mainActivityIndicatorView.startAnimating()
    }
    
    private func stopSending() {
        view.isUserInteractionEnabled = true
        mainActivityIndicatorView.stopAnimating()
    }
    
    // MARK: - IBAction
    
    @IBAction private func didTapPriceDecreaseButton(_ sender: UIButton) {
        
        let currentValue = Int(priceLabel.text!)!
        priceLabel.text = String(currentValue - 10)
        
        if currentValue - 10 == 20 {
            priceDecreaseButton.tintColor  = .lightGray
            priceDecreaseButton.isUserInteractionEnabled = false
        }
        
        if currentValue == 1000 {
            priceIncreaseButton.tintColor  = .label
            priceIncreaseButton.isUserInteractionEnabled = true
        }
        
        
    }
    
    @IBAction private func didTapPriceIncreaseButton(_ sender: UIButton) {
        
        let currentValue = Int(priceLabel.text!)!
        priceLabel.text = String(currentValue + 10)
        
        if currentValue + 10 == 1000 {
            priceIncreaseButton.tintColor  = .lightGray
            priceIncreaseButton.isUserInteractionEnabled = false
        }
        
        if currentValue == 20 {
            priceDecreaseButton.tintColor  = .label
            priceDecreaseButton.isUserInteractionEnabled = true
        }
        
    }
    
    @IBAction private func didTapAmountDecreaseButton(_ sender: UIButton) {
        
        let currentValue = Int(amountLabel.text!)!
        amountLabel.text = String(currentValue - 5)
        
        if currentValue - 5 == 5 {
            amountDecreaseButton.tintColor  = .lightGray
            amountDecreaseButton.isUserInteractionEnabled = false
        }
        
        if currentValue == 100 {
            amountIncreaseButton.tintColor  = .label
            amountIncreaseButton.isUserInteractionEnabled = true
        }
        
    }
    
    @IBAction private func didTapAmountIncreaseButton(_ sender: UIButton) {
        
        let currentValue = Int(amountLabel.text!)!
        amountLabel.text = String(currentValue + 5)
        
        if currentValue + 5 == 100 {
            amountIncreaseButton.tintColor  = .lightGray
            amountIncreaseButton.isUserInteractionEnabled = false
        }
        
        if currentValue == 5 {
            amountDecreaseButton.tintColor  = .label
            amountDecreaseButton.isUserInteractionEnabled = true
        }
        
    }
    
    
    @IBAction func didTapGenerateCouponsButton(_ sender: UIButton) {
        
        guard 5...20 ~= titleTextField.text!.count else {
            showAlert("Некорректно задано название", "Повторите попытку", where: self)
            return
        }
        
        guard !descriptionTextView.text.isEmpty else {
            showAlert("Введите краткое описание!", nil, where: self)
            return
        }
        
        guard let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile),
              let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) else {
            forceQuitFromProfile()
            return
        }
        
        startSending()

        Database.database().reference()
            .child(FBDefaultKeys.profiles)
            .child(profileID)
            .child(FBProfileKeys.phoneNumber)
        .observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let self = self else { return }
            
            guard snapshot.exists(), let phone = snapshot.value as? String else {
                self.stopSending()
                showAlert("Ошибка", "Номер телефона не обнаружен!", where: self)
                return
            }
            
            let message = Code.shared.couponsGenerate(numberOfCoupons: UInt(self.amountLabel.text!)!)
            
            SMSManager.sendSMS(phone: phone, message: message.messageBody) { [weak self] result in
                
                guard let self = self else { return }
                
                guard result != .error else {
                    self.stopSending()
                    showAlert("Ошибка", "Сообщение не было отправлено", where: self)
                    return
                }
                
                DispatchQueue.main.async {
                    
                    FireBaseDataBaseManager.createNewCoupon(
                        CouponModel(name: self.titleTextField.text!,
                                    description: self.descriptionTextView.text,
                                    codes: message.codes,
                                    sponsorLogin: login,
                                    price: UInt(self.priceLabel.text!)!)
                    )
                    
                    
                    
                    self.titleTextField.text = nil
                    self.descriptionTextView.text = nil
                    
                    self.priceLabel.text = "150"
                    self.priceDecreaseButton.tintColor = .label
                    self.priceDecreaseButton.isUserInteractionEnabled = true
                    self.priceIncreaseButton.tintColor = .label
                    self.priceDecreaseButton.isUserInteractionEnabled = true
                    
                    
                    
                    self.amountLabel.text = "20"
                    self.amountDecreaseButton.tintColor = .label
                    self.amountDecreaseButton.isUserInteractionEnabled = true
                    self.amountIncreaseButton.tintColor = .label
                    self.amountIncreaseButton.isUserInteractionEnabled = true
                    
                    self.stopSending()
                    
                    showAlert("Успех!", "Коды для купонов отправлены на ваш контактный телефон", where: self)
                    
                }
                
            }
        }
        
    }
    
}

// MARK: - UITextFieldDelegate

extension CreateCouponViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 20
    }
}

// MARK: - UITextViewDelegate

extension CreateCouponViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 150
    }
}
