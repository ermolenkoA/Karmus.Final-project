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
    KeychainSwift.shared.set(false, forKey: ConstantKeys.isProfileActive)
    UserDefaults.standard.setValue(Date?(nil), forKey: ConstantKeys.lastLogInDate)
    
    let storyboard = UIStoryboard(name: StoryboardNames.main, bundle: nil)
    let mainVC = storyboard.instantiateInitialViewController()!
    SceneDelegate.keyWindow?.rootViewController = mainVC
    SceneDelegate.keyWindow?.makeKeyAndVisible()
    showAlert("В акаунте произошли серьезные изменения", "Вы были усиленно выгнаны", where: mainVC)
}
