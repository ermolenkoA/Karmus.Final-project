//
//  ModelTasks.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import Foundation
import UIKit

class Tasks: NSObject{
    var image: UIImage
    var data: String
    var declaration: String
    init(image: UIImage, data: String, declaration: String){
        self.data = data
        self.image = image
        self.declaration = declaration
    }
}

class ModelTasks {
    var tasks = [Tasks]()
    init(){
        setUp()
    }
    func setUp(){
        let taskNumber1 = Tasks(image: UIImage(named:"tmb_215871_399815")!, data: "Активно до 25 августа, 2022", declaration: "Убрать территорию в парке")
        let taskNumber2 = Tasks(image: UIImage(named:"a482c3b8a982a4dd34fb10df40806ae6")!, data: "Активно до 28 августа, 2022", declaration: "Посадить дерево у болота")
        tasks.append(taskNumber1)
        tasks.append(taskNumber2)

    }
}
