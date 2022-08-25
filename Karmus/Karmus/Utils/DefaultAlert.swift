//
//  DefaultAlert.swift
//  Karmus
//
//  Created by User on 8/25/22.
//

import UIKit

 public func showAlert(_ title: String?, _ message: String?, where controller: UIViewController) {
    
    let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    let okButton = UIAlertAction(title: "OK", style: .default)
    alert.addAction(okButton)
    alert.view.tintColor = UIColor.black
    controller.present(alert, animated: true)
    
}
