//
//  DeclarationOfTasksViewController.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//
import Firebase
import UIKit


class DeclarationOfTasksViewController: UIViewController {

    var declarationOfTasks: ActiveTasks!
 //var activeTasks = ModelActiveTasks()
    var taskForTasksVC: ActiveTasks!
    
    @IBOutlet weak var imageOfTask: UIImageView!
    @IBOutlet weak var declarationOfTask: UILabel!
    @IBOutlet weak var dateOfTask: UILabel!
    
    var refTasks: DatabaseReference!
    var refDelTasks: DatabaseReference!
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        declarationOfTask.text = declarationOfTasks.declaration
        dateOfTask.text = declarationOfTasks.data
 //       imageOfTask.image = declarationOfTasks.image
        
        refTasks = Database.database().reference().child("Tasks")
        refDelTasks = Database.database().reference().child("ActiveTasks")
    }

    @IBAction func tapToAddTaskUser(_ sender: Any) {
        performSegue(withIdentifier: References.fromDeclarationToTasksScreen, sender: self)
        let key = refTasks.childByAutoId().key
        let date = dateOfTask.text!
        let declaration = declarationOfTask.text!
        let task = ["id": key,
                    "taskName": declarationOfTask.text!,
                    "taskDate": dateOfTask.text!
        ]
        if (!date.isEmpty && !declaration.isEmpty) {
            
        refTasks.child(key!).setValue(task)
            
//            refDelTasks.child(task[declarationOfTask.text!]!!).setValue(nil)
    }
       
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == References.fromDeclarationToTasksScreen {
//            let controller = segue.destination as! TasksTableViewController
//        let kol =
//               ActiveTasks(image: declarationOfTasks.image, data: declarationOfTasks.data, declaration: declarationOfTasks.declaration)
//
//            controller.allTasks.append(kol)
//        }
//    }
}
}
