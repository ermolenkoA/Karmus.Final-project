//
//  ModelTasks.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import Foundation
import UIKit

//class Tasks: NSObject{
//    var image: UIImage
//    var data: String
//    var declaration: String
//    init(image: UIImage, data: String, declaration: String){
//        self.data = data
//        self.image = image
//        self.declaration = declaration
//    }
//}

class ModelTasks {
    var addTap = DeclarationOfTasksViewController()
    var tasks = [ActiveTasks]()
    var tasksFromActive = ModelActiveTasks()
    init(){
        setUp()
    }
    func setUp(){
//        let task1 = tasksFromActive.tasks
//if addTap.tapToAddTaskUser(<#T##sender: Any##Any#>)
        for myTask in tasksFromActive.tasks {
        tasks.append(myTask)
        }
//        let taskNumber1 = ActiveTasks(image: UIImage(named:"tmb_215871_399815")!, data: "Активно до 25 августа, 2022", declaration: "Убрать территорию в парке")
//        let taskNumber2 = ActiveTasks(image: UIImage(named:"a482c3b8a982a4dd34fb10df40806ae6")!, data: "Активно до 28 августа, 2022", declaration: "Посадить дерево у болота")
//        tasks.append(taskNumber1)
//        tasks.append(taskNumber2)
//
    }
}
