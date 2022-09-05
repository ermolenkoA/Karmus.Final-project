//
//  FillMainProfileInfoVC.swift
//  Karmus
//
//  Created by VironIT on 8/31/22.
//

import UIKit
import FirebaseDatabase
import KeychainSwift

final class FillMainProfileInfoVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainView: UIView!
    
    @IBOutlet private weak var dateOfBirthTextField: UITextField!
    @IBOutlet private weak var dateDeleteButton: UIButton!
    
    @IBOutlet private weak var titleCityLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var cityDeleteButton: UIButton!
    
    @IBOutlet private weak var titlePhoneLabel: UILabel!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var phoneDeleteButton: UIButton!
    
    
    @IBOutlet private weak var titleEmailLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var emailDeleteButton: UIButton!
    
    @IBOutlet private weak var sumbitButton: UIButton!
    
    // MARK: - Private Properties
    
    private let datePicker = UIDatePicker()
    private var searchController: UISearchController! = UISearchController(searchResultsController: SearchResultVC())
    
    private var lastDate: String?

    private var defaultSettings: [String]?
    private var isDatePickerActive = false
    private var login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
    private var isNewUser = false
        
    // MARK: - Life Cycle
    
    override func viewDidDisappear(_ animated: Bool) {
        searchController = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Вернуться"
        navigationItem.backBarButtonItem = backItem

        navigationController?.isNavigationBarHidden = false
        
        standartSettings()
        
        datePicker.minimumDate = Date.year1950()
        datePicker.maximumDate = Date()
        
        mainView.backgroundColor = mainView.backgroundColor?.withAlphaComponent(0.7)
        
        dateOfBirthStartSettings()
        cityStartSettings()
        phoneNumberTextField.delegate = self
        emailTextField.delegate = self
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                         name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dateOfBirthTextField.isEditing {
            getDateFromPicker()
        }
        view.endEditing(true)
    }
    
    func showNextScreenForNewUser() {
        
        let storyboard = UIStoryboard(name: StoryboardNames.fillAdditionalProfileInfo, bundle: nil)
        guard let fillInfoVC = storyboard.instantiateInitialViewController() else {
            showAlert("Невозможно перейти", "Повторите попытку позже", where: self)
            return
        }
        (fillInfoVC as? NewUserProtocol)?.calledByNewUser()
        navigationController?.pushViewController(fillInfoVC, animated: true)
        
    }
    
    private func standartSettings() {
        
        guard let login = login else {
            print("\n<FillMainProfileInfoVC\\standartSettings> ERROR: login isn't exist\n")
            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
            return
        }
        
        dateOfBirthTextField.attributedPlaceholder = NSAttributedString(string: "Не указана", attributes: [NSAttributedString.Key.foregroundColor : UIColor.systemBlue])
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "Не указан", attributes: [NSAttributedString.Key.foregroundColor : UIColor.systemBlue])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Не указана", attributes: [NSAttributedString.Key.foregroundColor : UIColor.systemBlue])
        
            FireBaseDataBaseManager.getProfileInfo(login) { [weak self] info in
                
                guard let info = info else {
                    self?.defaultSettings = [self!.dateOfBirthTextField.text ?? "",
                                             self!.cityLabel.text ?? "",
                                             self!.phoneNumberTextField.text ?? "",
                                             self!.emailTextField.text ?? ""]
                    return
                }
               
                if let dateOfBirth = info.dateOfBirth {
                    self?.dateOfBirthTextField.text = dateOfBirth
                    self?.dateDeleteButton.isHidden = false
                }
                
                if let city = info.city {
                    self?.cityLabel.text = city
                    self?.cityDeleteButton.isHidden = false
                }
                
                if let phone = info.phone {
                    self?.phoneNumberTextField.text = phone
                    self?.phoneDeleteButton.isHidden = false
                }
                
                if let email = info.email {
                    self?.emailTextField.text = email
                    self?.emailDeleteButton.isHidden = false
                }
                
                self?.defaultSettings = [self!.dateOfBirthTextField.text ?? "",
                                         self!.cityLabel.text ?? "",
                                         self!.phoneNumberTextField.text ?? "",
                                         self!.emailTextField.text ?? ""]
            }
        
    }
    
    
    private func setLastDate() {
        lastDate = dateOfBirthTextField.text
    }
    
    private func dateOfBirthStartSettings() {
        
        dateOfBirthTextField.delegate = self
        
        datePicker.preferredDatePickerStyle = .wheels
        dateOfBirthTextField.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let saveButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(saveAction))
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems([saveButton, flexSpace, closeButton], animated: true)
        dateOfBirthTextField.inputAccessoryView = toolbar
        
    }
    
    private func cityStartSettings() {
        
        let tapForCityLabel = UITapGestureRecognizer(
            target: self, action: #selector(didTapCityLabel(_:))
        )
        cityLabel.addGestureRecognizer(tapForCityLabel)
        
        (searchController.searchResultsController as? SetSenderProtocol)?.setSender(self)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Введите город"
        definesPresentationContext = true
        
    }
    
    private func getDateFromPicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        dateOfBirthTextField.text = formatter.string(from: datePicker.date)
    }
    
    private func setNewInfo(_ value: Any?, for key: String){
        guard let login = login else {
            print("\n<FillMainProfileInfoVC\\setNewInfo> ERROR: login isn't exist\n")
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
            print("\n<FillMainProfileInfoVC\\removeOldInfo> ERROR: login isn't exist\n")
            showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: self)
            return
        }
        
        Database.database().reference()
            .child(FBDefaultKeys.profilesInfo)
            .child(login)
            .child(key)
            .removeValue()
    }
    
    @objc private func saveAction(){
        if dateOfBirthTextField.isEditing {
            getDateFromPicker()
        }
        view.endEditing(true)
    }
    
    @objc private func closeAction(){
        dateOfBirthTextField.text = lastDate
        view.endEditing(true)
    }
    
    @objc private func didTapCityLabel(_ sender: UITapGestureRecognizer) {
        present(searchController, animated: true)
    }
    
    @objc private func keyboardNotification(notification: Notification){
        guard !isDatePickerActive else {
            mainView.transform.ty = 0
            cityDeleteButton.transform.ty = mainView.transform.ty
            return
        }
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyboard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
      
        
        let textField = phoneNumberTextField.isEditing ? phoneNumberTextField! : emailTextField!
        
        let textFieldLowerBound = textField.frame.maxY + mainView.frame.minY
        
        if keyboard.minY < textFieldLowerBound - mainView.transform.ty{
            if keyboard.minY < textFieldLowerBound + 10 {
                mainView.transform.ty -= abs(keyboard.minY - textFieldLowerBound) + 10
            } else if (mainView.transform.ty != 0) && (keyboard.minY > textField.frame.maxY + 10) {
                mainView.transform.ty += abs(keyboard.minY - textFieldLowerBound) - 10
            }
        } else {
            mainView.transform.ty = 0
        }
        
        cityDeleteButton.transform.ty = mainView.transform.ty
        
    }
    
    // MARK: - IBAction
    
    @IBAction private func cleanUpSelection(_ sender: UIButton) {
        switch sender {
        case dateDeleteButton:
            dateOfBirthTextField.text = nil
        case cityDeleteButton:
            cityLabel.text = "Выбрать"
            titleCityLabel.textColor = .label
        case phoneDeleteButton:
            phoneNumberTextField.text = nil
            titlePhoneLabel.textColor = .label
        case emailDeleteButton:
            emailTextField.text = nil
            titleEmailLabel.textColor = .label
        default:
            break
        }
        if titleEmailLabel.textColor != .red && titlePhoneLabel.textColor != .red {
            self.sumbitButton.alpha = 1
            self.sumbitButton.isUserInteractionEnabled = true
        }
        sender.isHidden = true
    }
    
    @IBAction private func didTapSubmitButton(_ sender: UIButton) {
        
        guard cityLabel.text != "Выбрать" else {
            titleCityLabel.textColor = .red
            return
        }
        
        guard let defaultSettings = self.defaultSettings else {
            print("\n<FillMainProfileInfoVC\\didTapSubmitButton> ERROR: defaultSettings isn't exist\n")
            return
        }
        
        let currentSettings = [
            dateOfBirthTextField.text ?? "",
            cityLabel.text ?? "",
            phoneNumberTextField.text ?? "",
            emailTextField.text ?? ""
        ]
        
        if currentSettings != defaultSettings {
            if currentSettings[0] != defaultSettings[0] {
                if currentSettings[0] == "" {
                    removeOldInfo(for: FBProfileInfoKeys.dateOfBirth)
                } else {
                    setNewInfo(currentSettings[0], for: FBProfileInfoKeys.dateOfBirth)
                }
                
            }
            
            if currentSettings[1] != defaultSettings[1] {
                if currentSettings[1] == "" {
                    removeOldInfo(for: FBProfileInfoKeys.city)
                } else {
                    setNewInfo(currentSettings[1], for: FBProfileInfoKeys.city)
                }
            }
            
            if currentSettings[2] != defaultSettings[2] {
                if currentSettings[2] == "" {
                    removeOldInfo(for: FBProfileInfoKeys.phone)
                } else {
                    setNewInfo(currentSettings[2], for: FBProfileInfoKeys.phone)
                }
            }
            
            if currentSettings[3] != defaultSettings[3] {
                if currentSettings[3] == "" {
                    removeOldInfo(for: FBProfileInfoKeys.email)
                } else {
                    setNewInfo(currentSettings[3], for: FBProfileInfoKeys.email)
                }
            }
            
            self.defaultSettings = currentSettings
            
            let title = "Новые данные были сохранены"
            let alert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
            let okButton = !isNewUser ? UIAlertAction(title: "Продолжить", style: .default)
                 : UIAlertAction(title: "Продолжить", style: .default) { [weak self] _ in
                    self?.showNextScreenForNewUser()
                    
                 }
            alert.addAction(okButton)
            alert.view.tintColor = UIColor.black
            present(alert, animated: true)
            
        } else if isNewUser {
            showNextScreenForNewUser()
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension FillMainProfileInfoVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        filterContentForSearchText(text)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let filteredCities = Belarus.shared.allCities.filter{
            $0.lowercased().starts(with: searchText.lowercased())
        }
        guard let resultVC = searchController.searchResultsController else  {
            return
        }
        (resultVC as? UpdateTableViewTitleProtocol)?.update(with: filteredCities)
    }
}

// MARK: - UITextFieldDelegate

extension FillMainProfileInfoVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.sumbitButton.isUserInteractionEnabled = false
        
        switch textField {
        case dateOfBirthTextField:
            isDatePickerActive = true
            setLastDate()
            dateOfBirthTextField.text = nil
        case phoneNumberTextField:
            textField.text = (textField.text ?? "").count == 0 ? "+375" : textField.text
            phoneDeleteButton.isHidden = true
            titlePhoneLabel.textColor = .label
        case emailTextField:
            emailDeleteButton.isHidden = true
            titleEmailLabel.textColor = .label
        default:
            break
        }
        self.sumbitButton.alpha = 0.5
        self.sumbitButton.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case dateOfBirthTextField:
            isDatePickerActive = false
            if let date = dateOfBirthTextField.text {
                dateDeleteButton.isHidden = date.isEmpty
            } else {
                dateDeleteButton.isHidden = true
            }
        case phoneNumberTextField:
            
            guard let phone = phoneNumberTextField.text, !phone.isEmpty else {
                break
            }
        
            guard phone != "+375" else {
                phoneNumberTextField.text = nil
                break
            }
            
            if phone ~= "^(\\+375)(29|25|33|44)([\\d]{7})$"{
                titlePhoneLabel.textColor = .label
            } else {
                titlePhoneLabel.textColor = .red
                phoneDeleteButton.isHidden = false
            }
            
            phoneDeleteButton.isHidden = false
        case emailTextField:
            guard let email = emailTextField.text, !email.isEmpty else {
                break
            }
            
            if email ~= "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"{
                titleEmailLabel.textColor = .label
            } else {
                titleEmailLabel.textColor = .red
                emailDeleteButton.isHidden = false
            }
            
            emailDeleteButton.isHidden = false
        default:
            break
        }
        if titleEmailLabel.textColor != .red && titlePhoneLabel.textColor != .red {
            self.sumbitButton.alpha = 1
            self.sumbitButton.isUserInteractionEnabled = true
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        switch textField {
        case phoneNumberTextField:
            switch newText.count {
            case 4:
                return newText == "+375"
            case 5:
                return newText ~= "^(\\+375)(2|3|4)$"
            case 6:
                return newText ~= "^(\\+375)(29|25|33|44)$"
            case 7...13:
                return newText ~= "^(\\+375)(29|25|33|44)[\\d]{1,7}$"
            default:
                return false
            }
        case emailTextField:
            return newText.count < 70
        default:
            return false
        }
    }
}

// MARK: - NewUserProtocol

extension FillMainProfileInfoVC: NewUserProtocol {
    
    func calledByNewUser() {
        isNewUser = true
    }
     
}

// MARK: - SetCityProtocol


extension FillMainProfileInfoVC: SetCityProtocol{
    func setCity(_ city: String) {
        cityLabel.text = city
        searchController.isActive = false
        cityDeleteButton.isHidden = false
        titleCityLabel.textColor = .label
    }
}


