import Firebase
import UIKit

class ActiveTasksViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
   // let activeTasks = ModelActiveTasks()
    var celldataLabel: String?
    var celldeclarationLabel: String?
    var celltaskImageView: UIImage?
//    var tasksFromDeclaration: ActiveTasks!
    
    var refActiveTasks: DatabaseReference!
    var refGroupActiveTasks: DatabaseReference!
    var activeTasks = [ModelTasks]()
//    var activeGrouptasks = [ModelGroupTasks]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        refActiveTasks = Database.database().reference().child("ActiveTasks")
        refGroupActiveTasks = Database.database().reference().child("GroupTasks")
        uploadData(reference: refActiveTasks)
        uploadData(reference: refGroupActiveTasks)
    }
    
    func uploadData(reference: DatabaseReference){
        reference.observe(DataEventType.value, with:{(snapshot) in
        
        if snapshot.childrenCount > 0 {
            //self.activeTasks.removeAll()
            
            for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                let taskObject = tasks.value as? [String: AnyObject]
                let taskName = taskObject?["taskName"]
                let taskType = taskObject?["taskType"]
                let taskId = tasks.key
                let taskAddress = taskObject?["address"]
                let taskDate = taskObject?["taskDate"]
                let taskImage = taskObject?["imageURL"]
                let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                
                let task = ModelTasks(imageURL: taskImage as! String, id: taskId, latitudeCoordinate: taskLatitudeCoordinate as! Double, longitudeCoordinate: taskLongitudeCoordinate as! Double, date: taskDate as! String, declaration: taskName as! String, address: taskAddress as! String, type: taskType as! String)
                
                self.activeTasks.append(task)
            }
            self.tableView.reloadData()
        }
    })
    }
//    func getAllFIRData() {
//        refTasks.queryOrderedByKey()
//    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == References.fromActiveTasksToDeclarationOfTasksScreen {
            let controller = segue.destination as! DeclarationOfTasksViewController
            let indexPath = sender as! IndexPath
            let activeTask = activeTasks[indexPath.row]
            controller.declarationFromActiveTasks = activeTask
            controller.uniqueKeyFromActiveTasks = activeTask.id
            print(activeTask.id)
        }
    }
}

extension ActiveTasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return activeTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as! ActiveTasksViewCell
        
        cell.activeModelTask = activeTasks[indexPath.row]
        
        celldataLabel = cell.dateLabel.text
        celldeclarationLabel = cell.declarationLabel.text
//        celltaskImageView = cell.taskImageView.image
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: References.fromActiveTasksToDeclarationOfTasksScreen, sender: indexPath)
  
    }
}
        
