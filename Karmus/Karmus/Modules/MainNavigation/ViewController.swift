//
//  ViewController.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit
import FirebaseDatabase

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
  
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.dismiss(animated: true)
    }
    

    @IBAction private func didTapToIdentification(_ sender: UIButton) {
        performSegue(withIdentifier: References.fromMainToIdentificationScreen, sender: self)
    }
    
    @IBAction func didTapSingUpButton(_ sender: UIButton) {
        performSegue(withIdentifier: References.fromMainToRegistrationScreen, sender: self)
    }
    
//    @IBAction func didTapToAccountScreen(_ sender: UIButton) {
//        let storyboar = UIStoryboard(name: "AccountScreen", bundle: nil)
//        let toNext = storyboar.instantiateViewController(identifier: "AccountViewController")
//        self.present(toNext, animated: true)
//
//    }

}

