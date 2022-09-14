//
//  CreationTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

//import FirebaseCore
//import FirebaseFirestore
//import FirebaseDatabase
//import FirebaseStorage
import Firebase
import UIKit

class CreationTaskViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var typeOfTask: UITextField!
    @IBOutlet weak var switchTask: UISwitch!
    
    private let datePicker = UIDatePicker()
    private let imagePicker = UIImagePickerController()
    private var imagePickerForUpload = UIImage()
    private var respect: UInt8?
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    
//@IBOutlet weak var typeOfTask: UILabel!
    @IBOutlet weak var taskDeclaration: UITextView!
    
    
    var refTasks: DatabaseReference!
    var refActiveTasks: DatabaseReference!
    private let database = Database.database().reference()
    var uniqueKey: String?
    ////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        tabBarController?.tabBar.isHidden = true
        imagePicker.delegate = self
        datePicker.preferredDatePickerStyle = .wheels
        dateField.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
        dateField.inputAccessoryView = toolbar
//        taskDeclorationField.delegate = self
//        dateField.delegate = self
        refTasks = Database.database().reference().child("ActiveTasks")
        refActiveTasks = Database.database().reference().child("Tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
       
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
    
    

    func uploadPhoto(_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())) {
//        let key = refTasks.childByAutoId().key
        let storageRef = Storage.storage().reference().child("imageTasks").child("my photo")
        let imageData = taskImage.image?.jpegData(compressionQuality: 0.8)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) {(metaData, error) in
            guard metaData != nil else { print("error in save image")
                completion(nil)
                return
            }
                print("success")
                storageRef.downloadURL(completion: {(url, error) in
                    completion(url)
                })
            }
    }
   
    func saveTask(imageURL: URL, completion: @escaping ((_ url: URL?) -> ())) {
            let key = refTasks.childByAutoId().key
            uniqueKey = key
//            let date = dateField.text!
//            let decloration = taskDeclorationField.text!
        let task = ["taskType": typeOfTask.text!,
                    "taskName": taskDeclaration.text!,
                    "taskDate": dateField.text,
                    "imageURL": imageURL.absoluteString
            ] as! [String: Any]
        self.refTasks.child(key!).setValue(task)
        }
        
    func saveFIRData(){
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

    
    @IBAction func addTask(_ sender: Any) {

//        let date = dateField.text!
//        let decloration = taskDeclorationField.text!
//        let object: [String: String] = [
//            "Описание": taskDeclorationField.text!,
//            "Дата": dateField.text!
//        ]
//
//        if (!date.isEmpty && !decloration.isEmpty) {
//            database.child("Задание_\(Int.random(in: 0...100))").setValue(object)
//            print("хорошо")
//            uploadPhoto(imagePickerForUpload, completion: {print("збс фотка")})
//
//        }else{
//            showAlert()
//        }
        
    }
//
//    func showAlert() {
//        let alert = UIAlertController(title: "Ошибка", message: "Поля не все заполнены", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ок", style: .default))
//        present(alert, animated: true)
//    }
    
    ////
    
    @objc func doneAction(){
        getDateFromPicker()
        view.endEditing(true)
    }
    
    func getDateFromPicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateField.text = formatter.string(from: datePicker.date)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "toPopoverTypeOfTask" {
//            print("Яс сосу хуй")
//            let vc = segue.destination as! PopTypeOfTaskViewController
//            vc.preferredContentSize = CGSize(width: 300,
//                                             height: 300)
//            let controller = vc.popoverPresentationController
//            controller?.delegate = self
//            controller?.sourceView = self.view
//            controller?.permittedArrowDirections = UIPopoverArrowDirection.up
//
//            let myTextField = (sender as! UITextField)
//
//            controller?.sourceRect = CGRect(x: myTextField.frame.origin.x,
//                                            y: myTextField.frame.origin.y + myTextField.bounds.height,
//                                            width: 0,
//                                            height: 0)
//
//
//        }
        
        if segue.identifier == References.fromCreationToTaskMapScreen {
            let controller = segue.destination as! TaskMapViewController
                    controller.dateFromCreation = dateField.text
                    controller.declorationFromCreation = taskDeclaration.text
                    controller.typeFromCreation = typeOfTask.text
                    controller.imageFromCreation = imagePickerForUpload
                    controller.imageViewFromCreation = taskImage
            
            if switchTask.isOn{
                controller.switchFromCreation = true
            }else{
                controller.switchFromCreation = false
            }
        }
    }
}
    
extension CreationTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            taskImage.image = pickedImage
            imagePickerForUpload = pickedImage
        }
        dismiss(animated: true)
    }
    
}

extension CreationTaskViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

//extension CreationTaskViewController: GetTopicProtocol {
//    func getTopic(_ topic: String) {
//        typeOfTask.text = topic
//    }
//
//
//}

//extension CreationTaskViewController: GetTopicProtocol {
//    var getTopic: String = ""
//}
