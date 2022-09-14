import Firebase
import UIKit

class ActiveTasksViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var celldataLabel: String?
    var celldeclarationLabel: String?
    var celltaskImageView: UIImage?
    
    var refActiveTasks: DatabaseReference!
    var refGroupActiveTasks: DatabaseReference!
    var activeTasks = [ModelActiveTasks]()

    
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
            
            for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                let taskObject = tasks.value as? [String: AnyObject]
                let taskProfileName = taskObject?["name"]
                let taskPhoto = taskObject?["photo"]
                let taskLogin = taskObject?["login"]
                let taskName = taskObject?["taskName"]
                let taskType = taskObject?["taskType"]
                let taskId = tasks.key
                let taskAddress = taskObject?["address"]
                let taskDate = taskObject?["taskDate"]
                let taskImage = taskObject?["imageURL"]
                let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                
                let task = ModelActiveTasks(imageURL: taskImage as! String, id: taskId, latitudeCoordinate: taskLatitudeCoordinate as! Double, longitudeCoordinate: taskLongitudeCoordinate as! Double, date: taskDate as! String, declaration: taskName as! String, address: taskAddress as! String, type: taskType as! String, photo: taskPhoto as! String, profileName: taskProfileName as! String, login: taskLogin as! String)
                
                self.activeTasks.append(task)
            }
            self.tableView.reloadData()
        }
    })
    }
    
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
        
