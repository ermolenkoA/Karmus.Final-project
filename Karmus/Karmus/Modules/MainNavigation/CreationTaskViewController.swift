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

class CreationTaskViewController: UIViewController {
    
    @IBOutlet weak var taskImage: UIImageView!
    
    @IBOutlet weak var dateField: UITextField!
    private let datePicker = UIDatePicker()
    
    private let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var switchTask: UISwitch!
    private var imagePickerForUpload = UIImage()
    
    // ТЕСТОВАЯ ЗАГРУЗКА
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    
    @IBOutlet weak var typeOfTask: UILabel!
    @IBOutlet weak var taskDeclorationField: UITextField!
    
    
    var refTasks: DatabaseReference!
    var refActiveTasks: DatabaseReference!
    private let database = Database.database().reference()
    var uniqueKey: String?
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
        refActiveTasks = Database.database().reference().child("Tasks")
    }
    
    
    @IBAction func didTapToMapScreen(_ sender: Any) {
        if (!dateField.text!.isEmpty && !taskDeclorationField.text!.isEmpty) {
            performSegue(withIdentifier: References.fromCreationToTaskMapScreen, sender: self)
        }else {
            showAlert()
        }
    }
    
    @IBAction func taskForGroup(_ sender: UISwitch) {
        if sender.isOn {
            view.backgroundColor = .blue
        }else {
            view.backgroundColor = .red
        }
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
    
//    func upload(currentUserId: String, photo: UIImage, completion: @escaping (Document?) -> Void) {
//        let reference = Storage.storage().reference().child("pictures")
//
//        guard let imageData = picture.image?.jpegData(compressionQuality: 0.4) else { return }
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        reference.putData(imageData, metadata: metadata) { (metadata, error) in
//            guard let metadata = metadata else {
// // ошибка
//                completion(nil)
//                return
//            }
//            reference.downloadURL{ (url,  error) in
//                guard let url = url else {
//                    completion(nil)
//                    return
//                }
//                completion(nil)
//            }
//        }
//
//    }
//    open func uploadData(_ image: UIImage, completion: @escaping (URL? , Error?) -> Void) {
//        guard let uid = refTasks?.child("ActiveTasks").url else { return }
//        let reference = Storage.storage().reference().child("user/\(uid)")
//           let metadata = StorageMetadata()
//           metadata.contentType = "image/jpg" // in my example this was "PDF"
//
//           // we create an upload task using our reference and upload the
//           // data using the metadata object
//           reference.putData(image.jpegData(compressionQuality: 0.8)!, metadata: metadata) { metadata, error in
//
//               // first we check if the error is nil
//               if let error = error {
//
//                   completion(nil, error)
//                   return
//               }
//
//               // then we check if the metadata and path exists
//               // if the error was nil, we expect the metadata and path to exist
//               // therefore if not, we return an error
//               guard let metadata = metadata, let path = metadata.path else {
//                   completion(nil, NSError(domain: "core", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected error. Path is nil."]))
//                   return
//               }
//
//               // now we get the download url using the path
//               // and the basic reference object (without child paths)
//              // self.getDownloadURL(from: path, completion: completion)
//           }
//
//           // further we are able to use the uploadTask for example to
//           // to get the progress
//       }

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
                    "taskName": taskDeclorationField.text!,
                    "taskDate": dateField.text,
                    "imageURL": imageURL.absoluteString
            ] as! [String: Any]
        self.refTasks.child(key!).setValue(task)
        }
        
    func saveFIRData(){
        self.uploadPhoto(imagePickerForUpload){ url in
            if url == nil {
                print("error1")
                return
            }else{
            print("не понял")
            self.saveTask(imageURL: url!){ success in
                if success != nil {
                    print("Eeee")
                }else {
                    print("error")
                    
                    }
                }
            }
        }
    }
/*
        let key = refTasks.childByAutoId().key
        let date = dateField.text!
        let decloration = taskDeclorationField.text!
        let task = [
                    "taskName": taskDeclorationField.text!,
                    "taskDate": dateField.text!
                    
        ]
        if (!date.isEmpty && !decloration.isEmpty) {
        refTasks.child(key!).setValue(task)
        self.uploadData(imagePickerForUpload, completion: { url, error in
                if error == nil && url != nil {
                    print("Image upload")
                }
            })
        }else{
            showAlert()
        }
    }
 */
//        reference.putData(image.jpegData(compressionQuality: 0.8)!, metadata: meta, completion: { (metaData, error) in
//               if error == nil, metaData != nil {
//                   if let url = reference.downloadURL(completion: {(url, error) in
//
//                   })
                   // handle the error
                 //  return}else{
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
//}
// https://overcoder.net/q/513237/загрузить-и-получить-фото-с-firebase
//                let downloadURL = imageMeta?.downloadURL()
//                let imagePath = imageMeta?.path
//
//                let timeStamp = imageMeta?.timeCreated
//                let size = imageMeta?.size
//
//                completion(nil)
//        })

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
        if segue.identifier == References.fromCreationToTaskMapScreen {
            let controller = segue.destination as! TaskMapViewController
                    controller.dateFromCreation = dateField.text
                    controller.declorationFromCreation = taskDeclorationField.text
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
extension CreationTaskViewController: UISearchBarDelegate{
    
}
