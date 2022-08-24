//
//  CreationTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import UIKit

class CreationTaskViewController: UIViewController {
    
    @IBOutlet weak var taskImage: UIImageView!
    
    @IBOutlet weak var dateField: UITextField!
    private let datePicker = UIDatePicker()
    
    private let imagePicker = UIImagePickerController()
    
    
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
    }
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
extension CreationTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            taskImage.image = pickedImage
        }
        dismiss(animated: true)
    }
    
}
