//
//  CoreDataManager.swift
//  Karmus
//
//  Created by User on 8/21/22.
//

import UIKit
import CoreData

class CoreDataManager {
    public static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    public static let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
    public static let description = "<CoreDataManager>"
    
    static func saveProfile(profile: NSManagedObject) -> Bool{
        do {
            context.insert(profile)
            try context.save()
        } catch (let error) {
            print("\n \(self.description) ERROR: add item \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    static func isLoginExist(_ login: String) -> Bool? {
        
        guard login ~= "^[A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}$" && login.count >= 3 else{
            print("\n \(self.description) ERROR: login is incorrec\n)")
            return nil
        }
        
        guard let objects = try? context.fetch(Profile.fetchRequest()) else{
            print("\n \(self.description) ERROR: error while fetch request\n)")
            return nil
        }
        
        return (objects as? [Profile])?.contains(where:){$0.login == login}
        
    }
    
    static func isPhoneNumberExist(_ phoneNumber: String) -> Bool? {
        
        guard phoneNumber ~= "^(\\+375)(29|25|33|44)([\\d]{7})$" else{
            print("\n \(self.description) ERROR: email is incorrec\n)")
            return nil
        }
        
        guard let objects = try? context.fetch(Profile.fetchRequest()) else{
            print("\n \(self.description) ERROR: error while fetch request\n)")
            return nil
        }
        
        return (objects as? [Profile])?.contains(where:){$0.phoneNumber == phoneNumber}
        
    }
}
