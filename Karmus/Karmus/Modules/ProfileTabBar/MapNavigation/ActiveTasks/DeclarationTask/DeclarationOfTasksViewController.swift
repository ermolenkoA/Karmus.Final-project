//
//  DeclarationOfTasksViewController.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//

import Firebase
import KeychainSwift
import Kingfisher
import UIKit
import CoreLocation

class DeclarationOfTasksViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var profileLogin: UILabel!
    @IBOutlet private weak var profileName: UILabel!
    @IBOutlet private weak var profilePhoto: UIImageView!
    @IBOutlet private weak var imageOfTask: UIImageView!
    @IBOutlet private weak var declarationOfTask: UITextView!
    @IBOutlet private weak var dateOfTask: UILabel!
    @IBOutlet private weak var addressOfTask: UILabel!
    @IBOutlet private weak var typeOfTask: UILabel!
    
    // MARK: - Private Properties
    
    private var referenceTasks: DatabaseReference!
    private var referenceActiveTasks = Database.database().reference().child("ActiveTasks")
    private var referenceGroupTasks = Database.database().reference().child("GroupTasks")
    private var profileId = KeychainSwift.shared.get(ConstantKeys.currentProfile)
    private var profileUserLogin: String?
    private var addGroupTask = false
    private var addCreateTask = false
    
    // MARK: - Public Properties

    var declarationFromActiveTasks: ModelActiveTasks!
    var declarationFromMap: ModelTasks!
    var uniqueKeyFromMap: String?
    var uniqueKeyFromActiveTasks: String?
    var latitudeCoordinateToMap: Double?
    var longitudeCoordinateToMap: Double?
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        choiceOfTaskFromMap()
        dataReceptionFromDeclaration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        testGroup()
        checkUserTask()
    }
    

    // MARK: - Private Functions

    private func checkUserTask(){
        referenceTasks = Database.database().reference().child(FBDefaultKeys.profiles).child(profileId!).child("CreatedTasks")
        referenceTasks.observe(.value, with:{ [weak self](snapshot) in
            
            if snapshot.exists() {
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    let taskObject = tasks.value as? [String: AnyObject]
                    let taskLogin = taskObject?["login"]
                    
                    if taskLogin as? String == self?.declarationFromActiveTasks.login {
                        self?.addCreateTask = true
                    }
                }
                
            }
        }
        )
    }

    private func testGroup() {
        referenceTasks = Database.database().reference().child("Profiles").child(profileId!).child("Tasks")
        referenceTasks.observe(DataEventType.value, with:{ (snapshot) in
            if snapshot.childrenCount > 0 {
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let taskObject = tasks.value as? [String: AnyObject]
                    let taskName = taskObject?["taskName"]
                    let taskAddress = taskObject?["address"]
                    let taskDate = taskObject?["taskDate"]
                    
                    if  taskName as? String == self.declarationOfTask.text! &&
                            taskAddress as? String == self.declarationFromActiveTasks.address
                            && taskDate as? String == self.dateOfTask.text! {
                        self.addGroupTask = true
                    }
                }
            }
        }
        )
    }
    
    private func uploadData(reference: DatabaseReference){
        let key = reference.childByAutoId().key
        let task = ["name": declarationFromActiveTasks.profileName,
                    "login": declarationFromActiveTasks.login,
                    "photo": declarationFromActiveTasks.photo,
                    "address": declarationFromActiveTasks.address,
                    "taskType": declarationFromActiveTasks.type,
                    "latitudeCoordinate": declarationFromActiveTasks.latitudeCoordinate,
                    "longitudeCoordinate": declarationFromActiveTasks.longitudeCoordinate,
                    "imageURL":  declarationFromActiveTasks.imageURL,
                    "taskName": declarationOfTask.text!,
                    "taskDate": dateOfTask.text!
        ] as! [String: Any]
        reference.child(key!).setValue(task)
        
        if uniqueKeyFromActiveTasks != nil {
            self.referenceActiveTasks.child(uniqueKeyFromActiveTasks!).removeValue()
        } else {
            self.referenceActiveTasks.child(uniqueKeyFromMap!).removeValue()
        }
    }
    
    private func choiceOfTaskFromMap() {
        var boolTask = false
        referenceGroupTasks.observe(DataEventType.value, with:{ (snapshot) in
            for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                let taskId = tasks.key
                
                if  taskId == self.uniqueKeyFromMap {
                    self.choiceData(reference: self.referenceGroupTasks)
                    boolTask = true
                    print(boolTask)
                }
            }
        }
        )
        
        if boolTask == false {
            self.choiceData(reference: self.referenceActiveTasks)
            print(boolTask)
        }
    }
    
    private func dataReceptionFromDeclaration(){
        
        if  declarationFromActiveTasks != nil {
            profileName.text = declarationFromActiveTasks.profileName
            profileLogin.text = declarationFromActiveTasks.login
            declarationOfTask.text = declarationFromActiveTasks.declaration
            dateOfTask.text = (declarationFromActiveTasks.date)
            longitudeCoordinateToMap = declarationFromActiveTasks.longitudeCoordinate
            latitudeCoordinateToMap = declarationFromActiveTasks.latitudeCoordinate
            addressOfTask.text = "Адресс: \(declarationFromActiveTasks.address)"
            typeOfTask.text = "Тип задания: \(declarationFromActiveTasks.type)"
            let url = URL(string: declarationFromActiveTasks!.imageURL)
            let urlProfile = URL(string: declarationFromActiveTasks!.photo)
            
            if let url = url {
                KingfisherManager.shared.retrieveImage(with: url as Resource,
                                                       options: nil,
                                                       progressBlock: nil) { (image, error, cache, imageURL) in
                    self.imageOfTask.image = image
                    self.imageOfTask.kf.indicatorType = .activity
                }
            }
            
            if let urlProfile = urlProfile {
                KingfisherManager.shared.retrieveImage(with: urlProfile as Resource,
                                                       options: nil,
                                                       progressBlock: nil) { (image, error, cache, imageURL) in
                    self.profilePhoto.image = image
                    self.profilePhoto.kf.indicatorType = .activity
                }
            }
        }
        
    }
    
    private func choiceData(reference: DatabaseReference){
        
        if uniqueKeyFromMap != nil {
            reference.child(uniqueKeyFromMap!).observeSingleEvent(of: .value) { [unowned self] snapshot in
                
                if snapshot.exists() {
                    
                    let taskObject = snapshot.value as! [String: AnyObject]
                    let taskProfileName = taskObject["name"]
                    let taskPhoto = taskObject["photo"]
                    let taskLogin = taskObject["login"]
                    let taskAddress = taskObject["address"]
                    let taskType = taskObject["taskType"]
                    let taskName = taskObject["taskName"]
                    let taskId = snapshot.key
                    let taskDate = taskObject["taskDate"]
                    let taskImage = taskObject["imageURL"]
                    let taskLatitudeCoordinate = taskObject["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject["longitudeCoordinate"]
                    
                    let task = ModelActiveTasks(imageURL: taskImage as? String ?? "",
                                                id: taskId,
                                                latitudeCoordinate: taskLatitudeCoordinate as! Double,
                                                longitudeCoordinate: taskLongitudeCoordinate as! Double,
                                                date: taskDate as! String,
                                                declaration: taskName as! String,
                                                address: taskAddress as! String,
                                                type: taskType as! String,
                                                photo: taskPhoto as! String,
                                                profileName: taskProfileName as! String,
                                                login: taskLogin as! String)
                    
                    self.declarationFromActiveTasks = task
                    self.profileLogin.text = self.declarationFromActiveTasks.login
                    self.profileName.text = self.declarationFromActiveTasks.profileName
                    self.typeOfTask.text = "Тип задания: \(self.declarationFromActiveTasks.type)"
                    self.declarationOfTask.text = self.declarationFromActiveTasks.declaration
                    self.dateOfTask.text = self.declarationFromActiveTasks.date
                    self.addressOfTask.text = "Адресс: \(self.declarationFromActiveTasks.address)"
                    self.longitudeCoordinateToMap = self.declarationFromActiveTasks.longitudeCoordinate
                    self.latitudeCoordinateToMap = self.declarationFromActiveTasks.latitudeCoordinate
                    let urlProfile = URL(string: self.declarationFromActiveTasks!.photo)
                    let url = URL(string: self.declarationFromActiveTasks!.imageURL)
                    
                    if let url = url {
                        KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                            self.imageOfTask.image = image
                            self.imageOfTask.kf.indicatorType = .activity
                        }
                    }
                    if let urlProfile = urlProfile {
                        KingfisherManager.shared.retrieveImage(with: urlProfile as Resource,
                                                               options: nil,
                                                               progressBlock: nil) { (image, error, cache, imageURL) in
                            self.profilePhoto.image = image
                            self.profilePhoto.kf.indicatorType = .activity
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func tapToAddTaskUser(_ sender: Any) {
        referenceTasks = Database.database().reference().child("Profiles").child(profileId!).child("Tasks")
        
        if self.addCreateTask == false {
            
            if self.addGroupTask == true {
                
                let alert = UIAlertController(title: "У вас уже есть это задание", message: "Одинаковые задания нельзя брать", preferredStyle: .alert)
                let alertOk = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(alertOk)
                present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Задание успешно добавлено!", message: "", preferredStyle: .alert)
                let alertOk = UIAlertAction(title: "Отлично!", style: .default) { [unowned self] _ in
                    
                    if let controller = self.navigationController?.viewControllers.first as? MapViewController {
                        
                        controller.taskLocation = CLLocationCoordinate2D(latitude: self.latitudeCoordinateToMap!, longitude: self.longitudeCoordinateToMap!)
                        NotificationCenter.default.post(Notification(name: Notification.Name("lol")))
                        navigationController?.popToViewController(controller, animated: true)
                    }
                    
                }
                alert.addAction(alertOk)
                present(alert, animated: true)
                
                self.uploadData(reference: referenceTasks)
            }
        }else{
        showAlert("Так не честно!", "Свои задания нельзя брать!", where: self)
        }
    }
    
    @IBAction func tapToMapScreen(_ sender: Any) {
        if let controller = navigationController?.viewControllers.first as? MapViewController {
            
            controller.taskLocation = CLLocationCoordinate2D(latitude: latitudeCoordinateToMap!, longitude: longitudeCoordinateToMap!)
            NotificationCenter.default.post(Notification(name: Notification.Name("lol")))
            navigationController?.popToViewController(controller, animated: true)
        }
    }
}


