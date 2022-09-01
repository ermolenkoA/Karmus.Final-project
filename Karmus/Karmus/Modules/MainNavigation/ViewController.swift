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

    @IBAction private func didTapToIdentification(_ sender: UIButton) {
        performSegue(withIdentifier: References.fromMainToIdentificationScreen, sender: self)
    }
    
    @IBAction func didTapSingUpButton(_ sender: UIButton) {
        performSegue(withIdentifier: References.fromMainToRegistrationScreen, sender: self)
    }

}

