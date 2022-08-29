//
//  CreationTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage
import Firebase
import UIKit

class CreationTaskViewController: UIViewController {
    
    @IBOutlet weak var taskImage: UIImageView!
    
    @IBOutlet weak var dateField: UITextField!
    private let datePicker = UIDatePicker()
    
    private let imagePicker = UIImagePickerController()
    
    private var imagePickerForUpload = UIImage()
    
    // ТЕСТОВАЯ ЗАГРУЗКА
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var taskDeclorationField: UITextField!
    
    
    var refTasks: DatabaseReference!
    private let database = Database.database().reference()
    ////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
      //  refTasks.observe(DataEventType.value, with: <#T##(DataSnapshot) -> Void#>)
    }
    
    //ТЕСТОВАЯ ЗАГРУЗКА firebase
    
//    @IBAction func action(_ sender: Any) {
//        APIManager.shared.getPost(collection: "tasks", docName: "descriptionTask", completion: { doc in
//            guard doc != nil else { return }
//            self.label1.text = doc?.field1
//            self.label2.text = doc?.field2
//        })
//        APIManager.shared.getImage(picName: "16d3ac4608a0534abe596e52fe1e6f68", completion: { pic in
//            self.picture.image = pic
//        })
//    }
    
    func upload(currentUserId: String, photo: UIImage, completion: @escaping (Document?) -> Void) {
        let reference = Storage.storage().reference().child("pictures")
        
        guard let imageData = picture.image?.jpegData(compressionQuality: 0.4) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        reference.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
 // ошибка
                completion(nil)
                return
            }
            reference.downloadURL{ (url,  error) in
                guard let url = url else {
                    completion(nil)
                    return
                }
                completion(nil)
            }
        }
        
    }
    
    func uploadPhoto(_ image: UIImage, completion: @escaping () -> Void) {
    
        let reference = Storage.storage().reference().child("pictures").child(".jpeg")

        let meta = StorageMetadata()
        meta.contentType = "image/jpg"
        reference.putData(image.jpegData(compressionQuality: 0.8)!, metadata: meta, completion: { (imageMeta, error) in
               if error != nil {
                   // handle the error
                   return
                   //        let data = Data()
                   //        let uploadTask = reference.putData(data, metadata: nil) { (metadata, error) in
                   //          guard let metadata = metadata else {
                   //            // Uh-oh, an error occurred!
                   //            return
                   //          }
                   //          // Metadata contains file metadata such as size, content-type.
                   //          let size = metadata.size
                   //          // You can also access to download URL after upload.
                   //            reference.downloadURL { (url, error) in
                   //            guard let downloadURL = url else {
                   //              // Uh-oh, an error occurred!
                   //              return
                   //            }
                   //          }
                   //        }
}
// https://overcoder.net/q/513237/загрузить-и-получить-фото-с-firebase
//                let downloadURL = imageMeta?.downloadURL()
//                let imagePath = imageMeta?.path
//
//                let timeStamp = imageMeta?.timeCreated
//                let size = imageMeta?.size

                completion()
        })
}
    
    @IBAction func addTask(_ sender: Any) {
        let key = refTasks.childByAutoId().key
        let date = dateField.text!
        let decloration = taskDeclorationField.text!
        let task = ["id": key,
                    "taskName": taskDeclorationField.text!,
                    "taskDate": dateField.text!
        ]
        if (!date.isEmpty && !decloration.isEmpty) {
        refTasks.child(key!).setValue(task)
        }else{
            showAlert()
        }
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
    
    func showAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Поля не все заполнены", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
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
            present(self.imagePicker, animated: true)
        }
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel)
            
        alert.addAction(actionPhoto)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
    }
}

////
extension CreationTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            taskImage.image = pickedImage
            imagePickerForUpload = pickedImage
//            uploadPhoto(pickedImage, completion: {print("збс фотка")})
            
        }
        dismiss(animated: true)
    }
    
}

//extension CreationTaskViewController: UITextFieldDelegate{
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        let date = dateField.text!
//        let decloration = taskDeclorationField.text!
//        if (!date.isEmpty && !decloration.isEmpty) {
//            Firestore.firestore().collection(String).document(String){ (result, error) in
//                if error == nil {
//                    if let result = result {
//                        print("хорошо")
//                    }
//                }
//            }
//
//        }else{
//            showAlert()
//        }
//        return true
//    }
//}
