//
//  CreationTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import Firebase
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
    
    @objc
    private func tappedToPop() {
        
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
    
    private func uploadPhoto(_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())) {
        let storageRef = Storage.storage().reference().child("imageTasks").child("my photo")
        let imageData = taskImage.image?.jpegData(compressionQuality: 0.8)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) {(metaData, error) in
            guard metaData != nil else { print("error in save image")
                completion(nil)
                return
            }
            storageRef.downloadURL(completion: {(url, error) in
                completion(url)
            })
        }
    }
    
    private func saveTask(imageURL: URL, completion: @escaping ((_ url: URL?) -> ())) {
        let key = refTasks.childByAutoId().key
        uniqueKey = key
        let task = ["taskType": typeOfTask.text!,
                    "taskName": taskDeclaration.text!,
                    "taskDate": dateField.text,
                    "imageURL": imageURL.absoluteString
        ] as! [String: Any]
        self.refTasks.child(key!).setValue(task)
    }
    
    private func saveFIRData() {
        self.uploadPhoto(imagePickerForUpload){ url in
            if url == nil {
                return
            }else{
                self.saveTask(imageURL: url!){ success in
                    if success != nil {
                    }else {
                    }
                }
            }
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
    
    // MARK: - IBAction
    
    @IBAction func didTapToMapScreen(_ sender: Any) {
        
        if (!dateField.text!.isEmpty && !taskDeclaration.text!.isEmpty) {
            if datePicker.date.isGreaterThanDate(dateToCompare: Date().addHours(hoursToAdd: 6)){
                performSegue(withIdentifier: References.fromCreationToTaskMapScreen, sender: self)
            }else {
                showAlert("Дата заполненна не корректно", "Задание должно оставаться активным не менее 6 часов ", where: self)
            }
        }else{
            showAlert("Ошибка", "Поля не все заполненны", where: self)
        }
        
    }
    
    @IBAction func tapToAddImage(_ sender: Any) {
        let alert = UIAlertController(title: "Добавить изображение", message: nil, preferredStyle: .alert)
        let actionCamera = UIAlertAction(title: "С камеры", style: .default){ [unowned self] (action) in
            self.imagePicker.sourceType = .camera
            present(self.imagePicker, animated: true)
        }
        let actionPhoto = UIAlertAction(title: "С фотогалереи", style: .default){[unowned self] (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.isEditing = true
            present(self.imagePicker, animated: true)
        }
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel)
        
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
