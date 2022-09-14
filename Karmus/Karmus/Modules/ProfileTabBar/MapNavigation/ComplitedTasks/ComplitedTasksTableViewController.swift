//
//  ComplitedTasksTableViewController.swift
//  Karmus
//
//  Created by VironIT on 4.09.22.
//
import Firebase
import KeychainSwift
import UIKit

class ComplitedTasksTableViewController: UIViewController{
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
   
    // MARK: - Private Properties
    
    private var completeTasks = [ModelActiveTasks]()
    private var referenceTasks: DatabaseReference!
    private var profileLogin: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        downloadTask()
        
    }
    
    // MARK: - Private Properties
    
    private func downloadTask() {
        profileLogin = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
        referenceTasks = Database.database().reference().child("ProfilesInfo").child(profileLogin!).child("ProcessingTasks")
        referenceTasks.observe(DataEventType.value, with:{(snapshot) in
            if snapshot.childrenCount > 0 {
                self.completeTasks.removeAll()
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let taskObject = tasks.value as? [String: AnyObject]
                    let taskProfileName = taskObject?["name"]
                    let taskPhoto = taskObject?["photo"]
                    let taskLogin = taskObject?["login"]
                    let taskName = taskObject?["taskName"]
                    let taskType = taskObject?["taskType"]
                    let taskAddress = taskObject?["address"]
                    let taskId = tasks.key
                    let taskDate = taskObject?["taskDate"]
                    let taskImage = taskObject?["imageURL"]
                    let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                    
                    let task = ModelActiveTasks(imageURL: taskImage as! String,
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
                    
                    self.completeTasks.append(task)
                }
                self.tableView.reloadData()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == References.fromComplitedTasksToProcessingTaskScreen {
            let controller = segue.destination as! ProcessingTaskViewController
            let indexPath = sender as! IndexPath
            let task = completeTasks[indexPath.row]
            
            controller.declarationFromComplitedTasks = task
            controller.uniqueKeyFromComplitedTasks = task.id
            
        }
    }
}

// MARK: - Table view data source

extension ComplitedTasksTableViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return completeTasks.count
 }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as! ComplitedTasksTableViewCell
     cell.compliteModelTasks = completeTasks[indexPath.row]
     return cell
 }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     performSegue(withIdentifier: References.fromComplitedTasksToProcessingTaskScreen, sender: indexPath)
 }
}
