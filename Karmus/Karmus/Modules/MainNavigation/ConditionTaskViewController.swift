//
//  ConditionTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 2.09.22.
//

import Firebase
import Kingfisher
import UIKit
import CoreLocation

class ConditionTaskViewController: UIViewController {

    
    @IBOutlet weak var imageCondition: UIImageView!
    @IBOutlet weak var declarationCondition: UILabel!
    @IBOutlet weak var dateCondition: UILabel!
    @IBOutlet weak var typeCondition: UILabel!
    @IBOutlet weak var addressCondition: UILabel!
    
    
    var declarationFromTasks: ModelTasks!
    var declarationFromMap: ModelTasks!
    
    var latitudeCoordinateToMap: Double?
    var longitudeCoordinateToMap: Double?
    
    var referenceFromMapTask: DatabaseReference!
    var referenceDelTask: DatabaseReference!
    var referenceProcessingTask: DatabaseReference!
    var uniqueKeyFromMapAndTasks: String?
    var uniqueKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choiceOfData()

    }
    
    @IBAction func backToTasksScreen(_ sender: Any) {
        performSegue(withIdentifier: References.fromConditionTaskToTasksScreen, sender: self)
    
    }
    
    @IBAction func tapToProcessingTask(_ sender: Any) {
        let firstAlertController = UIAlertController(title: "Задание ушло на обработку", message: "Ожидайте уведомления", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ок", style: .default)
                { [weak self] _ in
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.referenceDelTask = Database.database().reference().child("Tasks")
                    self?.referenceDelTask.child(self!.uniqueKeyFromMapAndTasks!).setValue(nil)
                    self?.saveTask()
                    }
        
            firstAlertController.addAction(actionOk)
            present(firstAlertController, animated: true)

    }
    
    @IBAction func tapToMapScreen(_ sender: Any) {
        if let controller = navigationController?.viewControllers.first as? MapViewController {
            
            controller.taskLocation = CLLocationCoordinate2D(latitude: latitudeCoordinateToMap!, longitude: longitudeCoordinateToMap!)
            print("КООРДИНАТЫ \(controller.taskLocation)")
            NotificationCenter.default.post(Notification(name: Notification.Name("lol")))
            navigationController?.popToViewController(controller, animated: true)
        }
        
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == References.fromConditionTaskToMapScreen {
//            let controller = segue.destination as! MapViewController
//
//            controller.taskLocation = CLLocationCoordinate2D(latitude: latitudeCoordinateToMap!, longitude: longitudeCoordinateToMap!)
//        }
//    }
    /// weak self?
    
//    @IBAction func unwindToMap(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
//        performSegue(withIdentifier: "unwindToMap", sender: self)
//        // Use data from the view controller which initiated the unwind segue
//    }

    
    @IBAction func tapToDeleteTask(_ sender: Any) {
        
        referenceDelTask = Database.database().reference().child("Tasks")
        let firstAlertController = UIAlertController(title: "Удалить задание", message: "Вы уверены?", preferredStyle: .alert)
                let actionDelete = UIAlertAction(title: "Да", style: .cancel){[unowned self] _ in
                    self.referenceDelTask.child(uniqueKeyFromMapAndTasks!).setValue(nil)
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
    
    func choiceOfData(){
        if declarationFromTasks != nil {
            
            declarationCondition.text = declarationFromTasks.declaration
            dateCondition.text = declarationFromTasks.date
            latitudeCoordinateToMap = declarationFromTasks.latitudeCoordinate
            longitudeCoordinateToMap = declarationFromTasks.longitudeCoordinate
            addressCondition.text = declarationFromTasks.address
            typeCondition.text = declarationFromTasks.type
            let url = URL(string: declarationFromTasks!.imageURL)
            if let url = url as? URL {
                
                KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                    self.imageCondition.image = image
                    self.imageCondition.kf.indicatorType = .activity
                }
            }
        }else {
            print("перешло")
            referenceFromMapTask = Database.database().reference().child("Tasks")
            
            referenceFromMapTask.child(uniqueKeyFromMapAndTasks!).observeSingleEvent(of: .value){ snapshot in
                if snapshot.exists(){
                    
                    let taskObject = snapshot.value as! [String: AnyObject]
                    let taskName = taskObject["taskName"]
                    let taskType = taskObject["taskType"]
                    let taskId = snapshot.key
                    let taskDate = taskObject["taskDate"]
                    let taskAddress = taskObject["address"]
                    let taskImage = taskObject["imageURL"]
                    let taskLatitudeCoordinate = taskObject["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject["longitudeCoordinate"]
                    
                    let task = ModelTasks(imageURL: taskImage as? String ?? "", id: taskId, latitudeCoordinate: taskLatitudeCoordinate as! Double, longitudeCoordinate: taskLongitudeCoordinate as! Double, date: taskDate as! String, declaration: taskName as! String, address: taskAddress as! String, type: taskType as! String)
                    
                    self.declarationFromTasks = task
                    self.latitudeCoordinateToMap = self.declarationFromTasks.latitudeCoordinate
                    self.longitudeCoordinateToMap = self.declarationFromTasks.longitudeCoordinate
                    self.declarationCondition.text = self.declarationFromTasks.declaration
                    self.dateCondition.text = self.declarationFromTasks.date
                    self.addressCondition.text = self.declarationFromTasks.address
                    self.typeCondition.text = self.declarationFromTasks.type
                    
                    let url = URL(string: self.declarationFromTasks.imageURL)
                    if let url = url as? URL {
                        
                        KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                            self.imageCondition.image = image
                            self.imageCondition.kf.indicatorType = .activity
                        }
                    }
                }
            }
        }
    }
    
    func saveTask(){
        referenceProcessingTask = Database.database().reference().child("ProcessingTasks")
            let key = referenceProcessingTask.childByAutoId().key
        uniqueKey = key
//        print(resultAddress!)
//            let date = dateField.text!
//            let decloration = taskDeclorationField.text!
        let task = ["taskType": declarationFromTasks.type,
                    "address": declarationFromTasks.address,
                    "longitudeCoordinate": declarationFromTasks.longitudeCoordinate,
                    "latitudeCoordinate": declarationFromTasks.latitudeCoordinate,
                    "taskName": declarationFromTasks.declaration,
                    "taskDate": declarationFromTasks.date,
                    "imageURL": declarationFromTasks.imageURL
                    
            ] as! [String: AnyObject]
        self.referenceProcessingTask.child(key!).setValue(task)
        
        }
    
}
