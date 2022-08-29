//
//  TasksTableViewController.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//
import Firebase
import UIKit


class TasksTableViewController: UITableViewController {
    
    
    var allTasks = [ActiveTasks]()
//    var tasksFromDeclaration: ActiveTasks!
    var tasksFromDeclaration = DeclarationOfTasksViewController()
    var refTasks: DatabaseReference!
    
    
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
                    let taskId = taskObject?["id"]
                    let taskDate = taskObject?["taskDate"]
                    
                    let task = ActiveTasks(data: taskDate as! String, declaration: taskName as! String, id: taskId as! String)
                    
                    self.allTasks.append(task)
                }
                self.tableView.reloadData()
            }
        })
        
            }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as! TasksTableViewCell
        
        let task = allTasks[indexPath.row]
       
        cell.dataLabel.text = task.data
 //       cell.taskImageView.image = task.image
        cell.declarationLabel.text = task.declaration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = allTasks[indexPath.row]
        let alertController = UIAlertController(title: "Удалить задание", message: "Вы уверены?", preferredStyle: .alert)
        let actionDelete = UIAlertAction(title: "Удалить", style: .cancel){[weak self] (_) in
            self!.deleteTask(id: task.id)
        }
        alertController.addAction(actionDelete)
        present(alertController, animated: true)
        
    }
    func deleteTask(id: String){
        refTasks.child(id).setValue(nil)
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
