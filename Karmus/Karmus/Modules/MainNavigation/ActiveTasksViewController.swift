import Firebase
import UIKit

class ActiveTasksViewController: UITableViewController {

   // let activeTasks = ModelActiveTasks()
    var celldataLabel: String?
    var celldeclarationLabel: String?
    var celltaskImageView: UIImage?
//    var tasksFromDeclaration: ActiveTasks!
    
    var refTasks: DatabaseReference!
    var activeTasks = [ModelTasks]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        refTasks = Database.database().reference().child("ActiveTasks")
        refTasks.observe(DataEventType.value, with:{(snapshot) in
            
            if snapshot.childrenCount > 0 {
                self.activeTasks.removeAll()
                
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    let taskObject = tasks.value as? [String: AnyObject]
                    let taskName = taskObject?["taskName"]
                    let taskId = tasks.key
                    let taskDate = taskObject?["taskDate"]
                    let taskImage = taskObject?["imageURL"]
                    let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]

//                    let task = ActiveTasks(date: taskDate as! String, declaration: taskName as! String, id: taskId, imageURL: taskImage as! String)
                    let task = ModelTasks(imageURL: taskImage as! String, id: taskId, latitudeCoordinate: taskLatitudeCoordinate as! Double, longitudeCoordinate: taskLongitudeCoordinate as! Double, date: taskDate as! String, declaration: taskName as! String)
                    
                    self.activeTasks.append(task)
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func getAllFIRData() {
        refTasks.queryOrderedByKey()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return activeTasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as! ActiveTasksViewCell
        cell.activeModelTask = activeTasks[indexPath.row]
        
        celldataLabel = cell.dateLabel.text
        celldeclarationLabel = cell.declarationLabel.text
//        celltaskImageView = cell.taskImageView.image
        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: References.fromActiveTasksToDeclarationOfTasksScreen, sender: indexPath)
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == References.fromActiveTasksToDeclarationOfTasksScreen {
            let controller = segue.destination as! DeclarationOfTasksViewController
            let indexPath = sender as! IndexPath
            let task = activeTasks[indexPath.row]
            controller.declarationFromActiveTasks = task
            controller.uniqueKeyFromActiveTasks = task.id
        }
    }
}
        
