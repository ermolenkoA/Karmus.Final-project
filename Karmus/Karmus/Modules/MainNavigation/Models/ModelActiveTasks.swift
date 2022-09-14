//
//  ModelActiveTasks.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//

import Foundation
import UIKit
import CoreLocation

class ModelTasks: NSObject {
    
    var imageURL: String
    var id: String
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    var date: String
    var declaration: String
    var address: String
    var type: String
    init(imageURL: String, id: String, latitudeCoordinate: Double, longitudeCoordinate: Double, date: String, declaration: String, address: String, type: String){
        self.address = address
        self.imageURL = imageURL
        self.id = id
        self.longitudeCoordinate = longitudeCoordinate
        self.latitudeCoordinate = latitudeCoordinate
        self.date = date
        self.declaration = declaration
        self.type = type
    }
    
}
class ModelActiveTasks: NSObject {
    var photo: String
    var profileName: String
    var login: String
    var imageURL: String
    var id: String
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    var date: String
    var declaration: String
    var address: String
    var type: String
    init(imageURL: String, id: String, latitudeCoordinate: Double, longitudeCoordinate: Double, date: String, declaration: String, address: String, type: String, photo: String, profileName: String, login: String) {
        self.address = address
        self.imageURL = imageURL
        self.id = id
        self.longitudeCoordinate = longitudeCoordinate
        self.latitudeCoordinate = latitudeCoordinate
        self.date = date
        self.declaration = declaration
        self.type = type
        self.photo = photo
        self.login = login
        self.profileName = profileName
    }
}

class ModelGroupTasks: NSObject {
    var imageURL: String
    var id: String
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    var date: String
    var declaration: String
    var address: String
    var type: String
    var group: String
    init(imageURL: String, id: String, latitudeCoordinate: Double, longitudeCoordinate: Double, date: String, declaration: String, address: String, type: String, group: String){
        self.address = address
        self.imageURL = imageURL
        self.id = id
        self.longitudeCoordinate = longitudeCoordinate
        self.latitudeCoordinate = latitudeCoordinate
        self.date = date
        self.declaration = declaration
        self.type = type
        self.group = group
    }
}

class ModelUserProfile: NSObject{
    var photo: String
    var profileName: String
    var login: String
    init(photo: String, profileName: String, login: String) {
        self.photo = photo
        self.profileName = profileName
        self.login = login
    }
}

