//
//  CreationTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import Firebase
import KeychainSwift
import UIKit

class CreationTaskViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlet

    @IBOutlet private  weak var taskImage: UIImageView!
    @IBOutlet private weak var dateField: UITextField!
    @IBOutlet private weak var typeOfTask: UITextField!
    @IBOutlet private weak var switchTask: UISwitch!
    @IBOutlet private weak var taskDeclaration: UITextView!
    
    // MARK: - Private Properties

    private let datePicker = UIDatePicker()
    private let imagePicker = UIImagePickerController()
    private var imagePickerForUpload = UIImage()
    private var respect: UInt8?
    private var refTasks = Database.database().reference().child("ActiveTasks")
    private var refActiveTasks = Database.database().reference().child("Tasks")
    private let database = Database.database().reference()
    
    // MARK: - Public Properties
    
    var uniqueKey: String?
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        tabBarController?.tabBar.isHidden = true
        imagePicker.delegate = self
        setDatePicker()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                                                       name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Private Functions

    private func setDatePicker(){
        datePicker.preferredDatePickerStyle = .wheels
        dateField.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: true)
        dateField.inputAccessoryView = toolbar

    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedToPop))
        tapGesture.numberOfTapsRequired = 1
        typeOfTask.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardNotification(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyboard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
            .cgRectValue else { return }
        view.transform.ty = 0
        if keyboard.minY < taskDeclaration.frame.maxY
            && taskDeclaration.isFirstResponder {
            if keyboard.minY < taskDeclaration.frame.maxY + 10 {
                view.transform.ty -= abs(keyboard.minY - taskDeclaration.frame.maxY) + 10
            } else if (view.transform.ty != 0) && (keyboard.minY > taskDeclaration.frame.maxY + 10) {
                view.transform.ty += abs(keyboard.minY - taskDeclaration.frame.maxY) - 10
            }
        }
        else {
            view.transform.ty = 0
        }
    }
    
    @objc
    private func tappedToPop() {
        
        view.endEditing(true)
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") else { return }
        popVC.modalPresentationStyle = .popover
        
        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.typeOfTask
        popOverVC?.sourceRect = CGRect(x: self.typeOfTask.bounds.midX, y: self.typeOfTask.bounds.midY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: 160, height: 160)
        FireBaseDataBaseManager.getTopics { [weak self] topics in
            if let topics = topics {
                (popVC as? PopTypeOfTaskTableViewController)?.typeArray = topics
            }
            
            (popVC as? GetHandlerProtocol)?.getHandler{ [weak self] topic in
                self?.typeOfTask.text = topic
                popVC.dismiss(animated: true)
            }
            self?.present(popVC, animated: true)
        }
        
    }
    
    private func getDownloadURL(from path: String, completion: @escaping (URL?, Error?) -> Void) {
        Storage.storage().reference().child(path).downloadURL(completion: completion)
    }
    
    @objc private func doneAction(){
        getDateFromPicker()
        view.endEditing(true)
    }
    
    private func getDateFromPicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateField.text = formatter.string(from: datePicker.date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == References.fromCreationToTaskMapScreen {
            let controller = segue.destination as! TaskMapViewController
            controller.dateFromCreation = dateField.text
            controller.declorationFromCreation = taskDeclaration.text
            controller.typeFromCreation = typeOfTask.text
            controller.imageFromCreation = imagePickerForUpload
            controller.imageViewFromCreation = taskImage
            
            if switchTask.isOn {
                controller.switchFromCreation = true
            } else {
                controller.switchFromCreation = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - IBAction
    
    @IBAction func didTapToMapScreen(_ sender: Any) {
        
        if (!dateField.text!.isEmpty && !taskDeclaration.text!.isEmpty) {
            if datePicker.date.isGreaterThanDate(dateToCompare: Date().addHours(hoursToAdd: 6)){
                performSegue(withIdentifier: References.fromCreationToTaskMapScreen, sender: self)
            }else {
                showAlert("???????? ???????????????????? ???? ??????????????????", "?????????????? ???????????? ???????????????????? ???????????????? ???? ?????????? 6 ?????????? ", where: self)
            }
        }else{
            showAlert("????????????", "???????? ???? ?????? ????????????????????", where: self)
        }
        
    }
    
    @IBAction func tapToAddImage(_ sender: Any) {
        let alert = UIAlertController(title: "???????????????? ??????????????????????", message: nil, preferredStyle: .alert)
        let actionCamera = UIAlertAction(title: "?? ????????????", style: .default){ [unowned self] (action) in
            self.imagePicker.sourceType = .camera
            present(self.imagePicker, animated: true)
        }
        let actionPhoto = UIAlertAction(title: "?? ??????????????????????", style: .default){[unowned self] (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.isEditing = true
            present(self.imagePicker, animated: true)
        }
        let actionCancel = UIAlertAction(title: "????????????", style: .cancel)
        
        alert.addAction(actionPhoto)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CreationTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            taskImage.image = pickedImage
            imagePickerForUpload = pickedImage
        }
        dismiss(animated: true)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension CreationTaskViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


