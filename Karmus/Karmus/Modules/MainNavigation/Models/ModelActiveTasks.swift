//
//  ModelActiveTasks.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//

import Foundation
import UIKit
import CoreLocation

//class ActiveTasks: NSObject{
//    var imageURL: String
//    var id: String
//    var date: String
//    var declaration: String
//
////    var coordinate: String
//    init(date: String, declaration: String, id: String, imageURL: String){
//        self.date = date
//        self.declaration = declaration
//        self.id = id
//        self.imageURL = imageURL
//    }
//}

class ModelTasks: NSObject {
    var imageURL: String
    var id: String
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    var date: String
    var declaration: String
//    var coordinate: String
    init(imageURL: String, id: String, latitudeCoordinate: Double, longitudeCoordinate: Double, date: String, declaration: String){
        self.imageURL = imageURL
        self.id = id
        self.longitudeCoordinate = longitudeCoordinate
        self.latitudeCoordinate = latitudeCoordinate
        self.date = date
        self.declaration = declaration
    }
    
}



//class ModelActiveTasks {
//    var tasks = [ActiveTasks]()
//    init(){
//        setUp()
//    }
//    func setUp(){
//        
//        let taskNumber1 = ActiveTasks(image: UIImage(named:"tmb_215871_399815")!, data: "Активно до 25 августа, 2022", declaration: "Убрать территорию в парке")
//        let taskNumber2 = ActiveTasks(image: UIImage(named:"a482c3b8a982a4dd34fb10df40806ae6")!, data: "Активно до 28 августа, 2022", declaration: "Посадить дерево у болота")
//        tasks.append(taskNumber1)
//        tasks.append(taskNumber2)
//
//    }
//}
