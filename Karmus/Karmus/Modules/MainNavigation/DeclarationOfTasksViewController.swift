//
//  DeclarationOfTasksViewController.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//

import Firebase
import Kingfisher
import UIKit


class DeclarationOfTasksViewController: UIViewController {

    var declarationFromActiveTasks: ModelTasks!
    var declarationFromMap: ModelTasks!
    var uniqueKeyFromMap: String?
//    var declarationTextFromActiveTasks: String?
//    var taskForTasksVC: ActiveTasks!
    
    @IBOutlet weak var imageOfTask: UIImageView!
    @IBOutlet weak var declarationOfTask: UILabel!
    @IBOutlet weak var dateOfTask: UILabel!
    
    var referenceTasks: DatabaseReference!
    var referenceDelTasks: DatabaseReference!
    var referenceFromMapTask: DatabaseReference!
    private let database = Database.database().reference()
    var uniqueKeyFromActiveTasks: String?
    
    var activeTasks = [ModelTasks]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choiceOfData()
 //       imageOfTask.image = declarationOfTasks.image
        
        referenceTasks = Database.database().reference().child("Tasks")
        referenceDelTasks = Database.database().reference().child("ActiveTasks")
    }

    @IBAction func tapToAddTaskUser(_ sender: Any) {
        performSegue(withIdentifier: References.fromDeclarationToTasksScreen, sender: self)
        let key = referenceTasks.childByAutoId().key
        let task = ["latitudeCoordinate": declarationFromActiveTasks.latitudeCoordinate,
                    "longitudeCoordinate": declarationFromActiveTasks.longitudeCoordinate,
                    "imageURL":  declarationFromActiveTasks.imageURL,
                    "taskName": declarationOfTask.text!,
                    "taskDate": dateOfTask.text!
        ] as! [String: Any]
            self.referenceTasks.child(key!).setValue(task)
        self.referenceDelTasks.child(uniqueKeyFromActiveTasks!).removeValue()
        }
    
    func saveTask(imageURL: URL, completion: @escaping ((_ url: URL?) -> ())) {
            let key = referenceTasks.childByAutoId().key
//            let date = dateField.text!
//            let decloration = taskDeclorationField.text!
            let task = [
                        "taskName": declarationOfTask.text!,
                        "taskDate": dateOfTask.text!,
                        "imageURL": imageURL.absoluteString
            ] as! [String: Any]
        self.referenceTasks.child(key!).setValue(task)
        }
    
    func choiceOfData(){
        if declarationFromActiveTasks != nil {
            
            declarationOfTask.text = declarationFromActiveTasks.declaration
            dateOfTask.text = declarationFromActiveTasks.date
            
            let url = URL(string: declarationFromActiveTasks!.imageURL)
            if let url = url as? URL {
                
                KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                    self.imageOfTask.image = image
                    self.imageOfTask.kf.indicatorType = .activity
                }
            }
        }else {
            referenceFromMapTask = Database.database().reference().child("ActiveTasks")
            
            referenceFromMapTask.child(uniqueKeyFromMap!).observeSingleEvent(of: .value){ snapshot in
                if snapshot.exists(){
                    
                    let taskObject = snapshot.value as! [String: AnyObject]
                    let taskName = taskObject["taskName"]
                    let taskId = snapshot.key
                    let taskDate = taskObject["taskDate"]
                    let taskImage = taskObject["imageURL"]
                    let taskLatitudeCoordinate = taskObject["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject["longitudeCoordinate"]
                    
                    let task = ModelTasks(imageURL: taskImage as? String ?? "", id: taskId, latitudeCoordinate: taskLatitudeCoordinate as! Double, longitudeCoordinate: taskLongitudeCoordinate as! Double, date: taskDate as! String, declaration: taskName as! String)
                    
                    self.declarationFromMap = task
                    self.declarationOfTask.text = self.declarationFromMap.declaration
                    self.dateOfTask.text = self.declarationFromMap.date
                    
                    let url = URL(string: self.declarationFromMap.imageURL)
                    if let url = url as? URL {
                        
                        KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                            self.imageOfTask.image = image
                            self.imageOfTask.kf.indicatorType = .activity
                        }
                    }
                }
            }
        }
    }
}
                        
