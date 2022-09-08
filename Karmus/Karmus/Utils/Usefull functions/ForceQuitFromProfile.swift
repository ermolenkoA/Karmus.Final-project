//
//  forceQuitFromProfile.swift
//  Karmus
//
//  Created by VironIT on 9/5/22.
//

import UIKit
import KeychainSwift

func forceQuitFromProfile() {
    KeychainSwift.shared.delete(ConstantKeys.currentProfile)
    KeychainSwift.shared.delete(ConstantKeys.currentProfileLogin)
    UserDefaults.standard.setValue(Date?(nil), forKey: ConstantKeys.lastLogInDate)
    
    let storyboard = UIStoryboard(name: StoryboardNames.main, bundle: nil)
    let mainVC = storyboard.instantiateInitialViewController()!
    SceneDelegate.keyWindow?.rootViewController = mainVC
    SceneDelegate.keyWindow?.makeKeyAndVisible()
    showAlert("В акаунте произошли серьезные изменения", "Вы были усиленно выгнаны", where: mainVC)
}
