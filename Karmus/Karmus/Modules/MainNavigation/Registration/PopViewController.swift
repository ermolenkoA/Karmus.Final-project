//
//  popViewController.swift
//  Karmus
//
//  Created by User on 8/21/22.
//

import UIKit

protocol GetDescriptionProtocol {
    func getDescription(_ text: String)
}

final class PopViewController: UIViewController {

    @IBOutlet private weak var errorDescriptionLabel: UILabel!
    
    private var descriptionText = "Unknowed error"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorDescriptionLabel.text = descriptionText
    }

}

extension PopViewController: GetDescriptionProtocol {
    func getDescription(_ text: String){
        self.descriptionText = text
    }
}


