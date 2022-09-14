//
//  forceQuitFromProfile.swift
//  Karmus
//
//  Created by VironIT on 9/5/22.
//

import UIKit
import KeychainSwift

func forceQuitFromProfile() {
    
    FireBaseDataBaseManager.removeSession()
    KeychainSwift.shared.delete(ConstantKeys.isProfileActive)
    KeychainSwift.shared.delete(ConstantKeys.currentProfile)
    KeychainSwift.shared.delete(ConstantKeys.currentProfileLogin)
    KeychainSwift.shared.delete(ConstantKeys.profileType)
    UserDefaults.standard.setValue(Date?(nil), forKey: ConstantKeys.lastLogInDate)
    
    let storyboard = UIStoryboard(name: StoryboardNames.main, bundle: nil)
    let mainVC = storyboard.instantiateInitialViewController()!
    SceneDelegate.keyWindow?.rootViewController = mainVC
    ((mainVC as? UINavigationController)?.viewControllers.first as? ViewController)?.wasForceExit = true
    SceneDelegate.keyWindow?.makeKeyAndVisible()
}
