//
//  Profile+CoreDataClass.swift
//  Karmus
//
//  Created by User on 8/22/22.
//
//

import Foundation
import CoreData

public class ProfileItem{
    var dateOfBirth: Date?
    var firstName: String?
    var login: String?
    var password: Int64 = 0
    var phoneNumber: String?
    var photo: String?
    var secondName: String?
    
}

@objc(Profile)
public class Profile: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var firstName: String?
    @NSManaged public var login: String?
    @NSManaged public var password: Int64
    @NSManaged public var phoneNumber: String?
    @NSManaged public var photo: String?
    @NSManaged public var secondName: String?

}

extension Profile : Identifiable {

}
