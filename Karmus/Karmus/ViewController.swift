//
//  ViewController.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func didTapToIdentification(_ sender: UIButton) {
        performSegue(withIdentifier: "toIdentificationSegue", sender: self)
    }
}

