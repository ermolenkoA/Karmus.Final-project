//
//  TasksTableViewController.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//
import Firebase
import UIKit


class TasksTableViewController: UIViewController{
    
    
    var allTasks = [ModelTasks]()
//    var tasksFromDeclaration: ActiveTasks!
    var tasksFromDeclaration = DeclarationOfTasksViewController()
    var refTasks: DatabaseReference!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        refTasks = Database.database().reference().child("Tasks")
        refTasks.observe(DataEventType.value, with:{(snapshot) in
            if snapshot.childrenCount > 0 {
                self.allTasks.removeAll()
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    let taskObject = tasks.value as? [String: AnyObject]
                    let taskName = taskObject?["taskName"]
                    let taskAddress = taskObject?["address"]
                    let taskType = taskObject?["taskType"]
                    let taskId = tasks.key
                    let taskDate = taskObject?["taskDate"]
                    let taskImage = taskObject?["imageURL"]
                    let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                    
                    let task = ModelTasks(imageURL: taskImage as! String, id: taskId, latitudeCoordinate: taskLatitudeCoordinate as! Double, longitudeCoordinate: taskLongitudeCoordinate as! Double, date: taskDate as! String, declaration: taskName as! String, address: taskAddress as! String, type: taskType as! String)
                    
                    self.allTasks.append(task)
                }
                self.tableView.reloadData()
            }
        })
        
            }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.isNavigationBarHidden = true
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == References.fromTasksToConditionTaskScreen {
            let controller = segue.destination as! ConditionTaskViewController
            let indexPath = sender as! IndexPath
            let task = allTasks[indexPath.row]
            controller.declarationFromTasks = task
            controller.uniqueKeyFromMapAndTasks = task.id
            
        }
    }
    func deleteTask(id: String){
        refTasks.child(id).setValue(nil)
    }
    
    @IBAction private func didTapToMapButton() {
        self.dismiss(animated: true)
        navigationController?.viewControllers.first as? MapViewController
    }
}

    // MARK: - Table view data source
extension TasksTableViewController: UITableViewDataSource, UITableViewDelegate{

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as! TasksTableViewCell
        cell.activeModelTask = allTasks[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let task = allTasks[indexPath.row]
        performSegue(withIdentifier: References.fromTasksToConditionTaskScreen, sender: indexPath)
//
    }
    }
 
