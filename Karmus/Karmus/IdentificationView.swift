//
//  IdentificationView.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit

class IdentificationView: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupLabelTapRecognazer()
    
    }
    override func viewWillAppear(_ animated: Bool) {

        
    }

    
//    @IBOutlet private weak var registrationButton: UILabel!
    
//    private func setupLabelTapRecognazer(){
//        let tapRecognizer = UITapGestureRecognizer()
//        tapRecognizer.addTarget(self, action: #selector(didTapLabel))
//        tapRecognizer.numberOfTapsRequired = 1
//        registrationButton.addGestureRecognizer(tapRecognizer)
//    }
//
//
//
//    @objc private func didTapLabel() {
//        let regLab = UIStoryboard(name: "RegistrationScreen", bundle: nil)
//        let regLabView = regLab.instantiateViewController(withIdentifier: "RegistrationViewID")
//        self.present(regLabView, animated: true)
//    }
//
    @IBAction func didTapToRegistration(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toRegistrationSegue", sender: self)
        
    }
    
    
}
