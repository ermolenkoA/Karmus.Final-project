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
    
    static func saveContext() -> Bool{
        do {
            try context.save()
        } catch (let error) {
            print("\n \(self.description) ERROR: add item \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    static func isLoginExist(_ login: String) -> Bool? {
        
        guard login ~= "^[A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}$" && login.count >= 3 else{
            print("\n \(self.description) ERROR: login is incorrect\n)")
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
            print("\n \(self.description) ERROR: email is incorrect\n)")
            return nil
        }
        
        guard let objects = try? context.fetch(Profile.fetchRequest()) else{
            print("\n \(self.description) ERROR: error while fetch request\n)")
            return nil
        }
        
        return (objects as? [Profile])?.contains(where:){$0.phoneNumber == phoneNumber}
        
    }
    
    static func tryToOpenProfile(login: String, password: Int64, newPassword: Int64? = nil, _ controller: UIViewController? = nil) -> Bool {
        
        
        
        guard let profiles = try? CoreDataManager.context.fetch(Profile.fetchRequest()) as? [Profile] else{
            print("\n <didTapBubmitButton> ERROR: error while fetch request\n)")
            if let controller = controller {
                showAlert("Произошла ошибка", "Обратитесь к разработчику приложения", where: controller)
            }
            return false
        }
        
        guard let profile = profiles.first(where: {$0.login == login || $0.phoneNumber == login}) else {
            if let controller = controller  {
                showAlert("Неверно введен логин или пароль", nil, where: controller)
            }
            return false
        }
        
        guard password == profile.password else{
            if let controller = controller  {
                showAlert("Неверно введен логин или пароль", nil, where: controller)
            }
            return false
        }
    
        if let newPassword = newPassword {
            profile.password = newPassword
            
            if CoreDataManager.saveContext() && controller != nil{
                showAlert("Пароль был успешно изменен!", nil, where: controller!)
            } else if controller != nil{
                showAlert("Ууупс, что-то пошло не так", "Обратитесь к разработчику приложения", where: controller!)
            }
            
        }
        
        return true
    }
    
}
