//
//  ConditionTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 2.09.22.
//

import Firebase
import KeychainSwift
import Kingfisher
import UIKit
import CoreLocation

class ConditionTaskViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageCondition: UIImageView!
    @IBOutlet private weak var declarationCondition: UITextView!
    @IBOutlet private weak var dateCondition: UILabel!
    @IBOutlet private weak var typeCondition: UILabel!
    @IBOutlet private weak var addressCondition: UILabel!
    @IBOutlet private weak var profilePhoto: UIImageView!
    @IBOutlet private weak var profileLogin: UILabel!
    @IBOutlet private weak var profileName: UILabel!
    
    // MARK: - Private Properties
    
    private var referenceFromMapTask: DatabaseReference!
    private var referenceDelTask: DatabaseReference!
    private var referenceProcessingTask: DatabaseReference!
    private var referenceActiveTask: DatabaseReference!
    private var referenceProfileInfo: DatabaseReference!
    private var profileId: String?
    private var profileUserLogin: String?
    
    // MARK: - Public Properties
    
    var uniqueKey: String?
    var uniqueKeyFromMapAndTasks: String?
    var declarationFromTasks: ModelActiveTasks!
    var profileInfo: ModelUserProfile!
    var loginForProcessing: String?
    var latitudeCoordinateToMap: Double?
    var longitudeCoordinateToMap: Double?
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        choiceOfData()
        processProfile()
        getProfileInfo()
    }
    
    // MARK: - Private functions

    private func processProfile() {
        referenceProcessingTask = Database.database().reference().child("ProfilesInfo")
        referenceProcessingTask.observe(DataEventType.value, with:{ [weak self](snapshot) in
            if snapshot.childrenCount > 0 {
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    if tasks.key == self?.profileLogin.text {
                        self?.referenceProcessingTask = Database.database().reference().child("ProfilesInfo").child(tasks.key)
                    }
                }
            }
        }
        )
    }
    
    private func getProfileInfo() {
        profileUserLogin = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
        referenceProfileInfo = Database.database().reference().child("ProfilesInfo").child(profileUserLogin!)
        FireBaseDataBaseManager.getProfileForTask(profileUserLogin!) { [weak self] profile in
            
            guard let profile = profile else {
                return
            }
            let task = ModelUserProfile(photo: profile.photo,
                                        profileName: profile.name,
                                        login: profile.login)
            self?.profileInfo = task
            }
        }
    
    private func choiceOfData() {
        if declarationFromTasks != nil {
            
            declarationCondition.text = declarationFromTasks.declaration
            dateCondition.text = declarationFromTasks.date
            latitudeCoordinateToMap = declarationFromTasks.latitudeCoordinate
            longitudeCoordinateToMap = declarationFromTasks.longitudeCoordinate
            addressCondition.text = "Адресс: \(declarationFromTasks.address)"
            typeCondition.text = "Тип задания: \(declarationFromTasks.type)"
            profileName.text = declarationFromTasks.profileName
            profileLogin.text = declarationFromTasks.login
            
            let profileUrl = URL(string: declarationFromTasks!.photo)
            let url = URL(string: declarationFromTasks!.imageURL)
            if let url = url {
                
                KingfisherManager.shared.retrieveImage(with: url as Resource,
                                                       options: nil,
                                                       progressBlock: nil)
                { (image, error, cache, imageURL) in
                    self.imageCondition.image = image
                    self.imageCondition.kf.indicatorType = .activity
                }
            }
            
            if let profileUrl = profileUrl {
                KingfisherManager.shared.retrieveImage(with: profileUrl as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                    self.profilePhoto.image = image
                    self.profilePhoto.kf.indicatorType = .activity
                }
            }
            
        } else {
            
            print("перешло")
            profileId = KeychainSwift.shared.get(ConstantKeys.currentProfile)
            referenceFromMapTask =  Database.database().reference().child(FBDefaultKeys.profiles).child(profileId!).child("Tasks")
            print("КЛЮЧ \(uniqueKeyFromMapAndTasks!)")
            referenceFromMapTask.child(uniqueKeyFromMapAndTasks!).observeSingleEvent(of: .value){ snapshot in
                if snapshot.exists(){
                    
                    let taskObject = snapshot.value as! [String: AnyObject]
                    let taskProfileName = taskObject["name"]
                    let taskPhoto = taskObject["photo"]
                    let taskLogin = taskObject["login"]
                    let taskName = taskObject["taskName"]
                    let taskType = taskObject["taskType"]
                    let taskId = snapshot.key
                    let taskDate = taskObject["taskDate"]
                    let taskAddress = taskObject["address"]
                    let taskImage = taskObject["imageURL"]
                    let taskLatitudeCoordinate = taskObject["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject["longitudeCoordinate"]
                    
                    let task = ModelActiveTasks(imageURL: taskImage as? String ?? "", id: taskId, latitudeCoordinate: taskLatitudeCoordinate as! Double, longitudeCoordinate: taskLongitudeCoordinate as! Double, date: taskDate as! String, declaration: taskName as! String, address: taskAddress as! String, type: taskType as! String,  photo: taskPhoto as! String, profileName: taskProfileName as! String, login: taskLogin as! String)
                    
                    self.declarationFromTasks = task
                    self.latitudeCoordinateToMap = self.declarationFromTasks.latitudeCoordinate
                    self.longitudeCoordinateToMap = self.declarationFromTasks.longitudeCoordinate
                    self.declarationCondition.text = self.declarationFromTasks.declaration
                    self.dateCondition.text = self.declarationFromTasks.date
                    self.addressCondition.text = self.declarationFromTasks.address
                    self.typeCondition.text = self.declarationFromTasks.type
                    self.profileName.text = self.declarationFromTasks.profileName
                    self.profileLogin.text = self.declarationFromTasks.login
                    
                    let profileUrl = URL(string: self.declarationFromTasks.photo)
                    let url = URL(string: self.declarationFromTasks.imageURL)
                    if let url = url {
                        
                        KingfisherManager.shared.retrieveImage(with: url as Resource,
                                                               options: nil,
                                                               progressBlock: nil){ (image, error, cache, imageURL) in
                            self.imageCondition.image = image
                            self.imageCondition.kf.indicatorType = .activity
                        }
                    }
                    if let profileUrl = profileUrl {
                        
                        KingfisherManager.shared.retrieveImage(with: profileUrl as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                            self.profilePhoto.image = image
                            self.profilePhoto.kf.indicatorType = .activity
                        }
                    }
                }
            }
        }
    }
    
    private func saveTask(reference: DatabaseReference, photo: String, login: String, name: String){
        
        let key = reference.childByAutoId().key
        uniqueKey = key
        let task = [
                    "name": name,
                    "login": login,
                    "photo": photo,
                    "taskType": declarationFromTasks.type,
                    "address": declarationFromTasks.address,
                    "longitudeCoordinate": declarationFromTasks.longitudeCoordinate,
                    "latitudeCoordinate": declarationFromTasks.latitudeCoordinate,
                    "taskName": declarationFromTasks.declaration,
                    "taskDate": declarationFromTasks.date,
                    "imageURL": declarationFromTasks.imageURL
            ] as! [String: AnyObject]
        reference.child(key!).setValue(task)
        }
    
    
    @IBAction func tapToProcessingTask(_ sender: Any) {
        profileId = KeychainSwift.shared.get(ConstantKeys.currentProfile)
        referenceDelTask = Database.database().reference().child("Profiles").child(profileId!).child("Tasks")
        let firstAlertController = UIAlertController(title: "Задание ушло на обработку", message: "Ожидайте уведомления", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ок", style: .default)
                { [weak self] _ in
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.referenceDelTask.child(self!.uniqueKeyFromMapAndTasks!).setValue(nil)
                    self?.saveTask(reference: (self?.referenceProcessingTask.child("ProcessingTasks"))!, photo: (self?.profileInfo.photo)!, login: (self?.profileInfo.login)!, name: (self?.profileInfo.profileName)!)
                    }
        
            firstAlertController.addAction(actionOk)
            present(firstAlertController, animated: true)

    }

    // MARK: - IBAction
    
    @IBAction func tapToMapScreen(_ sender: Any) {
        if let controller = navigationController?.viewControllers.first as? MapViewController {
            
            controller.taskLocation = CLLocationCoordinate2D(latitude: latitudeCoordinateToMap!, longitude: longitudeCoordinateToMap!)
            print("КООРДИНАТЫ \(controller.taskLocation)")
            NotificationCenter.default.post(Notification(name: Notification.Name("lol")))
            navigationController?.popToViewController(controller, animated: true)
        }
        
    }
    
    @IBAction func tapToDeleteTask(_ sender: Any) {
        profileId = KeychainSwift.shared.get(ConstantKeys.currentProfile)
        referenceDelTask = Database.database().reference().child("Profiles").child(profileId!).child("Tasks")
        referenceActiveTask = Database.database().reference().child("ActiveTasks")
        let firstAlertController = UIAlertController(title: "Удалить задание", message: "Вы уверены?", preferredStyle: .alert)
                let actionDelete = UIAlertAction(title: "Да", style: .cancel){[unowned self] _ in
                    self.referenceDelTask.child(uniqueKeyFromMapAndTasks!).setValue(nil)
                    self.saveTask(reference:referenceActiveTask,
                                  photo: declarationFromTasks.photo,
                                  login: declarationFromTasks.login,
                                  name: declarationFromTasks.profileName)
                    
                    let secondAlertController = UIAlertController(title: "Задание удалено", message: nil, preferredStyle: .alert)
                    let actionOk = UIAlertAction(title: "Ок", style: .default)
                    { [weak self] _ in
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                    secondAlertController.addAction(actionOk)
                    present(secondAlertController, animated: true)
                
                }
        firstAlertController.addAction(actionDelete)
                present(firstAlertController, animated: true)
    }
    
    
}
