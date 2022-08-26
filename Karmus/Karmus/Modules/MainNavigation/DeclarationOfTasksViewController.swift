//
//  DeclarationOfTasksViewController.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//

import UIKit


class DeclarationOfTasksViewController: UIViewController {

    var declarationOfTasks: ActiveTasks!
    var activeTasks = ModelActiveTasks()
    
    @IBOutlet weak var imageOfTask: UIImageView!
    @IBOutlet weak var declarationOfTask: UILabel!
    @IBOutlet weak var dateOfTask: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        declarationOfTask.text = declarationOfTasks.declaration
        dateOfTask.text = declarationOfTasks.data
        imageOfTask.image = declarationOfTasks.image
    }

    @IBAction func tapToAddTaskUser(_ sender: Any) {
        performSegue(withIdentifier: References.fromDeclarationToTasksScreen, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == References.fromDeclarationToTasksScreen {
            let controller = segue.destination as! TasksTableViewController
            var tasker: ActiveTasks!
            
            controller.tasksFromDeclaration = tasker
        }
    }
}
