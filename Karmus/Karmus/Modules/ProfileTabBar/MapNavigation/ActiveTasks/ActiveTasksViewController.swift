import Firebase
import UIKit

class ActiveTasksViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private  weak var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private var celldataLabel: String?
    private var celldeclarationLabel: String?
    private var celltaskImageView: UIImage?
    private var refActiveTasks = Database.database().reference().child("ActiveTasks")
    private var refGroupActiveTasks = Database.database().reference().child("GroupTasks")
    private var activeTasks = [ModelActiveTasks]()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        uploadData(reference: refActiveTasks)
        uploadData(reference: refGroupActiveTasks)
    }
    
    // MARK: - Private Functions

    private func uploadData(reference: DatabaseReference) {
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

// MARK: - Table view data source

extension ActiveTasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as! ActiveTasksViewCell
        cell.activeModelTask = activeTasks[indexPath.row]
        celldataLabel = cell.dateLabel.text
        celldeclarationLabel = cell.declarationLabel.text
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: References.fromActiveTasksToDeclarationOfTasksScreen, sender: indexPath)
    }
}
        
