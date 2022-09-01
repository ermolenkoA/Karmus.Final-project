//
//  ProfileTabBarController.swift
//  Karmus
//
//  Created by VironIT on 8/30/22.
//

import UIKit
import KeychainSwift

class ProfileTabBarController: UITabBarController {
    
    var login: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

extension ProfileTabBarController: SetLoginProtocol{
    func setLogin(login: String) {
        self.login = login
    }
}
