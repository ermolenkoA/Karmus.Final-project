//
//  DataBaseManagerForMap.swift
//  Karmus
//
//  Created by VironIT on 15.09.22.
//

import Foundation
import FirebaseDatabase
import KeychainSwift
import MapKit

enum TasksTypes {
    case activeTasks
    case userTasks
    case groupTasks
}

final class DataBaseManagerForMap {
    
    static func getTasks(tasksType: TasksTypes, _ conclusion: @escaping (Any?) -> Void) {
        
        var reference: DatabaseReference
        
        if tasksType == .userTasks {
            guard let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile) else {
                conclusion(nil)
                return
            }
            reference = Database.database().reference().child(FBDefaultKeys.profiles)
                .child(profileID).child(FBProfileKeys.tasks)
        } else {
            reference = tasksType == .activeTasks
            ? Database.database().reference().child(FBDefaultKeys.activeTasks)
            : Database.database().reference().child(FBDefaultKeys.groupTasks)
        }
        
        reference.observe(.value) { tasks in
            
            var resultTasks = [Any]()
            
            guard tasks.exists(), let tasks = tasks.children.allObjects as? [DataSnapshot] else {
                conclusion(resultTasks)
                return
            }
            
            for task in tasks {
                guard let task = parseTasks(task, tasksType) else {
                    continue
                }
                resultTasks.append(task)
            }
            
            reference.observe(.childRemoved) { tasks in
                var resultTasks = [Any]()
                
                guard tasks.exists(), let tasks = tasks.children.allObjects as? [DataSnapshot] else {
                    conclusion(resultTasks)
                    return
                }
                
                for task in tasks {
                    guard let task = parseTasks(task, tasksType) else {
                        continue
                    }
                    resultTasks.append(task)
                }
                conclusion(resultTasks)
            }


            conclusion(resultTasks)
        }
        
    }
    
    private static func parseTasks(_ task: DataSnapshot, _ tasksType: TasksTypes) -> Any? {
        guard let taskElements = task.value as? [String: AnyObject],
              let taskAddress = taskElements[FBTasks.address] as? String,
              let taskName = taskElements[FBTasks.taskName] as? String,
              let taskType = taskElements[FBTasks.taskType] as? String,
              let taskLatitudeCoordinate = taskElements[FBTasks.latitudeCoordinate] as? Double,
              let taskLongitudeCoordinate = taskElements[FBTasks.longitudeCoordinate] as? Double else {
            return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: taskLatitudeCoordinate, longitude: taskLongitudeCoordinate)
        
        switch tasksType {
        case .groupTasks:
            return ModelGroupTasksMap(coordinate: coordinate,
                                      name: taskName,
                                      id: task.key,
                                      address: taskAddress,
                                      type: taskType)
        case .activeTasks:
            return ModelActiveTasksMap(coordinate: coordinate,
                                    name: taskName,
                                    id: task.key,
                                    address: taskAddress,
                                    type: taskType)
        case .userTasks:
            return ModelTasksMap(coordinate: coordinate,
                                 name: taskName,
                                 id: task.key,
                                 address: taskAddress,
                                 type: taskType)
        }
    }
    
}
