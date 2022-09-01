//
//  SceneDelegate.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit
import KeychainSwift
import FirebaseDatabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let mainScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: mainScene)
        
        if let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile) {
            
            if let lastLogInDate = UserDefaults.standard.value(forKey: ConstantKeys.lastLogInDate) as? Date {
                
                FireBaseDataBaseManager.getProfileUpdateDate(profileID){ [weak self] profileUpdateDate in
                    
                    guard let date = profileUpdateDate, date < lastLogInDate else{
                        KeychainSwift.shared.delete(ConstantKeys.currentProfile)
                        UserDefaults.standard.setValue(Date?(nil), forKey: ConstantKeys.lastLogInDate)
                        self?.showMainVC()
                        return
                    }
                    
                    self?.showAccountVC()
                    
                }
                
            } else {
                KeychainSwift.shared.delete(ConstantKeys.currentProfile)
                showMainVC()
            }
            
        } else {
            showMainVC()
        }
        
    }
    
    private func showMainVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window?.rootViewController = storyboard.instantiateInitialViewController()
        window?.makeKeyAndVisible()
    }
    
    private func showAccountVC() {
        let storyboard = UIStoryboard(name: "AccountScreen", bundle: nil)
        window?.rootViewController = storyboard.instantiateInitialViewController()
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

