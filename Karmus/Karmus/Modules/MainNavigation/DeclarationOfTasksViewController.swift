//
//  DeclarationOfTasksViewController.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//

import Firebase
import Kingfisher
import UIKit
import CoreLocation


class DeclarationOfTasksViewController: UIViewController {

    var declarationFromActiveTasks: ModelTasks!
    var declarationFromMap: ModelTasks!
    var uniqueKeyFromMap: String?
    var uniqueKeyFromActiveTasks: String?

    @IBOutlet weak var imageOfTask: UIImageView!
    @IBOutlet weak var declarationOfTask: UILabel!
    @IBOutlet weak var dateOfTask: UILabel!
    @IBOutlet weak var addressOfTask: UILabel!
    @IBOutlet weak var typeOfTask: UILabel!
    
    var referenceTasks: DatabaseReference!
    var referenceActiveTasks: DatabaseReference!
    var referenceGroupTasks: DatabaseReference!
  
    var latitudeCoordinateToMap: Double?
    var longitudeCoordinateToMap: Double?
    
    var addGroupTask = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        referenceTasks = Database.database().reference().child("Tasks")
        referenceActiveTasks = Database.database().reference().child("ActiveTasks")
        referenceGroupTasks = Database.database().reference().child("GroupTasks")
        choiceOfTaskFromMap()
        dataReceptionFromDeclaration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
            testGroup()
    }

    @IBAction func tapToAddTaskUser(_ sender: Any) {
        print("маркер")
        if self.addGroupTask == true{
            let alert = UIAlertController(title: "У вас уже есть это задание", message: "Одинаковые задания нельзя брать", preferredStyle: .alert)
            let alertOk = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(alertOk)
                present(alert, animated: true)
            print("задание уже есть")
        }else{
            showAlert(title: "Задание успешно добавлено!", message: "", reference: References.fromDeclarationToMapScreen)
                self.uploadData()
            print("задания нет")
        }
    }
    
    func showAlert(title: String, message: String, reference: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default){ [unowned self] _ in
                performSegue(withIdentifier: reference, sender: self)
                }
        alert.addAction(alertOk)
        present(alert, animated: true)
    }
    
    @IBAction func tapToMapScreen(_ sender: Any) {
    //    performSegue(withIdentifier: References.fromDeclarationToMapScreen, sender: self)
        self.dismiss(animated: true)
//        navigationController?.tabBarController?.selectedIndex = 0
//            navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    func testGroup(){
        referenceTasks.observe(DataEventType.value, with:{(snapshot) in
            let d = (snapshot.children.allObjects as! [DataSnapshot]).count
            print(d)
            if snapshot.childrenCount > 0 {
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let taskObject = tasks.value as? [String: AnyObject]
                    let taskName = taskObject?["taskName"]
                    let taskAddress = taskObject?["address"]
                    let taskDate = taskObject?["taskDate"]
                    print("\(taskName!) + \(taskAddress!) + \(taskDate!)")
                    
                    if  taskName as? String == self.declarationOfTask.text! &&
                            taskAddress as? String == self.declarationFromActiveTasks.address
                            && taskDate as? String == self.dateOfTask.text!
                    {
                    print("EEEEE")
                        self.addGroupTask = true
                        }
                    }
                }
            }
        )
    }
                             
    func uploadData(){
        
        let key = referenceTasks.childByAutoId().key
        let task = ["address": declarationFromActiveTasks.address,
                    "taskType": declarationFromActiveTasks.type,
                    "latitudeCoordinate": declarationFromActiveTasks.latitudeCoordinate,
                    "longitudeCoordinate": declarationFromActiveTasks.longitudeCoordinate,
                    "imageURL":  declarationFromActiveTasks.imageURL,
                    "taskName": declarationOfTask.text!,
                    "taskDate": dateOfTask.text!
                    ] as! [String: Any]
        self.referenceTasks.child(key!).setValue(task)

        if uniqueKeyFromActiveTasks != nil{
            self.referenceActiveTasks.child(uniqueKeyFromActiveTasks!).removeValue()
        } else {
            self.referenceActiveTasks.child(uniqueKeyFromMap!).removeValue()
        }
    }
    
    func saveTask(imageURL: URL, completion: @escaping ((_ url: URL?) -> ())) {
            let key = referenceTasks.childByAutoId().key
            let task = [
                        "taskName": declarationOfTask.text!,
                        "taskDate": dateOfTask.text!,
                        "imageURL": imageURL.absoluteString
                        ] as! [String: Any]
        self.referenceTasks.child(key!).setValue(task)
        }
    
    func choiceOfTaskFromMap(){
        var boolTask = false
        referenceGroupTasks.observe(DataEventType.value, with:{(snapshot) in
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    let taskId = tasks.key
                    if  taskId == self.uniqueKeyFromMap
                    {
                        self.choiceData(reference: self.referenceGroupTasks)
                        boolTask = true
                        print(boolTask)
                    }
                }
            }
        )
        
        if boolTask == false
        {
            self.choiceData(reference: self.referenceActiveTasks)
            print(boolTask)
        }
    }
    
    func dataReceptionFromDeclaration(){
   if  declarationFromActiveTasks != nil
        {
            print("из таблицы")
            declarationOfTask.text = declarationFromActiveTasks.declaration
            dateOfTask.text = declarationFromActiveTasks.date
            longitudeCoordinateToMap = declarationFromActiveTasks.longitudeCoordinate
            latitudeCoordinateToMap = declarationFromActiveTasks.latitudeCoordinate
            addressOfTask.text = declarationFromActiveTasks.address
            typeOfTask.text = declarationFromActiveTasks.type
            let url = URL(string: declarationFromActiveTasks!.imageURL)
                if let url = url as? URL {
                    KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                        self.imageOfTask.image = image
                        self.imageOfTask.kf.indicatorType = .activity
                }
            }
        }
    }
    
    func choiceData(reference: DatabaseReference){

        if uniqueKeyFromMap != nil {
        reference.child(uniqueKeyFromMap!).observeSingleEvent(of: .value){ snapshot in
                if snapshot.exists(){
                    
                    let taskObject = snapshot.value as! [String: AnyObject]
                    let taskAddress = taskObject["address"]
                    let taskType = taskObject["taskType"]
                    let taskName = taskObject["taskName"]
                    let taskId = snapshot.key
                    let taskDate = taskObject["taskDate"]
                    let taskImage = taskObject["imageURL"]
                    let taskLatitudeCoordinate = taskObject["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject["longitudeCoordinate"]
                    
                    let task = ModelTasks(imageURL: taskImage as? String ?? "", id: taskId, latitudeCoordinate: taskLatitudeCoordinate as! Double, longitudeCoordinate: taskLongitudeCoordinate as! Double, date: taskDate as! String, declaration: taskName as! String, address: taskAddress as! String, type: taskType as! String)
                    
                    self.declarationFromActiveTasks = task
                    self.typeOfTask.text = self.declarationFromActiveTasks.type
                    self.declarationOfTask.text = self.declarationFromActiveTasks.declaration
                    self.dateOfTask.text = self.declarationFromActiveTasks.date
                    self.addressOfTask.text = self.declarationFromActiveTasks.address
                    self.longitudeCoordinateToMap = self.declarationFromActiveTasks.longitudeCoordinate
                    self.latitudeCoordinateToMap = self.declarationFromActiveTasks.latitudeCoordinate
                    
                    let url = URL(string: self.declarationFromActiveTasks.imageURL)
                    if let url = url as? URL
                    {
                        KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                            self.imageOfTask.image = image
                            self.imageOfTask.kf.indicatorType = .activity
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == References.fromDeclarationToMapScreen {
            let controller = segue.destination as! MapViewController
            controller.taskLocation = CLLocationCoordinate2D(latitude: latitudeCoordinateToMap!, longitude: longitudeCoordinateToMap!)
        }
    }
}
                        
