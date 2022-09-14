//
//  ModelTasks.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import Foundation
import MapKit
import UIKit

class ModelTasksMap: NSObject, MKAnnotation{
    var name: String?
    var coordinate: CLLocationCoordinate2D
    var id: String?
    var address: String?
    var type: String?
    var title: String?{
        return type
    }

    var subtitle: String?{
        return address
    }

    init(coordinate: CLLocationCoordinate2D, name: String, id: String, address: String, type: String){
        self.coordinate = coordinate
        self.name = name
        self.id = id
        self.address = address
        self.type = type
    }
}

class ModelActiveTasksMap: NSObject, MKAnnotation{
    var name: String?
    var coordinate: CLLocationCoordinate2D
    var id: String?
    var address: String?
    var type: String?
    var title: String?{
        return type
    }

    var subtitle: String?{
        return address
    }

    init(coordinate: CLLocationCoordinate2D, name: String, id: String, address: String, type: String){
        self.coordinate = coordinate
        self.name = name
        self.id = id
        self.address = address
        self.type = type
    }
}

class ModelGroupTasksMap:  NSObject, MKAnnotation{
    var name: String?
    var coordinate: CLLocationCoordinate2D
    var id: String?
    var address: String?
    var type: String?
    var title: String?{
        return type
    }

    var subtitle: String?{
        return address
    }

    init(coordinate: CLLocationCoordinate2D, name: String, id: String, address: String, type: String){
        self.coordinate = coordinate
        self.name = name
        self.id = id
        self.address = address
        self.type = type
    }
    
}
