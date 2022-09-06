//
//  ProcessingTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 4.09.22.
//
import Firebase
import Kingfisher
import UIKit

class ProcessingTaskViewController: UIViewController {

    
    @IBOutlet weak var imageTaskView: UIImageView!
    
    @IBOutlet weak var dateTaskLabel: UILabel!
    
    @IBOutlet weak var declarationTaskLabel: UILabel!
    @IBOutlet weak var typeTaskLabel: UILabel!
    @IBOutlet weak var addressTaskLabel: UILabel!
    
    var referenceComplitedTasks: DatabaseReference!
    var referenceTasks: DatabaseReference!
    var declarationFromComplitedTasks: ModelTasks!
    var uniqueKeyFromComplitedTasks: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adoptionOfData()

      
    }

    @IBAction func didTapToCompliteTask(_ sender: Any) {
        referenceTasks = Database.database().reference().child("ProcessingTasks")
        referenceComplitedTasks = Database.database().reference().child("ComplitedTasks")
        let key = referenceComplitedTasks.childByAutoId().key
        let task = ["address": declarationFromComplitedTasks.address,
                    "imageURL":  declarationFromComplitedTasks.imageURL,
                    "taskName": declarationTaskLabel.text!,
                    "taskDate": dateTaskLabel.text!
        ] as! [String: Any]
            self.referenceComplitedTasks.child(key!).setValue(task)
            self.referenceTasks.child(uniqueKeyFromComplitedTasks!).removeValue()
        }
    
    func adoptionOfData(){
        declarationTaskLabel.text = declarationFromComplitedTasks.declaration
        dateTaskLabel.text = declarationFromComplitedTasks.date
        addressTaskLabel.text = declarationFromComplitedTasks.address
        typeTaskLabel.text = declarationFromComplitedTasks.type
        let url = URL(string: declarationFromComplitedTasks!.imageURL)
        if let url = url as? URL {
            
            KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                self.imageTaskView.image = image
                self.imageTaskView.kf.indicatorType = .activity
            }
        }
        
    }
    
}
