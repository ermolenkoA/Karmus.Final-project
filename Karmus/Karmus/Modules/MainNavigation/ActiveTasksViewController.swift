
import UIKit

class ActiveTasksViewController: UITableViewController {

    let activeTasks = ModelActiveTasks()
    var celldataLabel: String?
    var celldeclarationLabel: String?
    var celltaskImageView: UIImage?
//    var tasksFromDeclaration: ActiveTasks!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return activeTasks.tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as! ActiveTasksViewCell
        let task = activeTasks.tasks[indexPath.row]
        cell.taskImageView.image = task.image
        cell.dateLabel.text = task.data
        cell.declarationLabel.text = task.declaration
        celldataLabel = cell.dateLabel.text
        celldeclarationLabel = cell.declarationLabel.text
        celltaskImageView = cell.taskImageView.image
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
            let task = activeTasks.tasks[indexPath.row]
            controller.declarationOfTasks = task
        }
    }
}

