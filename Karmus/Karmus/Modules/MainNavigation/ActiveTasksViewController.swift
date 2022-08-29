import Firebase
import UIKit

class ActiveTasksViewController: UITableViewController {

   // let activeTasks = ModelActiveTasks()
    var celldataLabel: String?
    var celldeclarationLabel: String?
    var celltaskImageView: UIImage?
//    var tasksFromDeclaration: ActiveTasks!
    
    var refTasks: DatabaseReference!
    var activeTasks = [ActiveTasks]()
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
                    let taskId = taskObject?["id"]
                    let taskDate = taskObject?["taskDate"]
                    
                    let task = ActiveTasks(data: taskDate as! String, declaration: taskName as! String, id: taskId as! String)
                    
                    self.activeTasks.append(task)
                }
                self.tableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return activeTasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as! ActiveTasksViewCell
        let task = activeTasks[indexPath.row]
//        cell.taskImageView.image =
        cell.dateLabel.text = task.data
        cell.declarationLabel.text = task.declaration
        celldataLabel = cell.dateLabel.text
        celldeclarationLabel = cell.declarationLabel.text
//        celltaskImageView = cell.taskImageView.image
        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let task = activeTasks.tasks[indexPath.row]
        performSegue(withIdentifier: References.fromActiveTasksToDeclarationOfTasksScreen, sender: indexPath)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == References.fromActiveTasksToDeclarationOfTasksScreen {
            let controller = segue.destination as! DeclarationOfTasksViewController
            let indexPath = sender as! IndexPath
            let task = activeTasks[indexPath.row]
            controller.declarationOfTasks = task
        }
    }
}
        
