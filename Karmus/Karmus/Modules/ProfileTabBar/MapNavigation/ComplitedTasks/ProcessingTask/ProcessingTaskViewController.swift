//
//  ProcessingTaskViewController.swift
//  Karmus
//
//  Created by VironIT on 4.09.22.
//
import Firebase
import Kingfisher
import KeychainSwift
import UIKit

class ProcessingTaskViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageTaskView: UIImageView!
    @IBOutlet private weak var dateTaskLabel: UILabel!
    @IBOutlet private weak var declarationTaskLabel: UITextView!
    @IBOutlet private weak var typeTaskLabel: UILabel!
    @IBOutlet private weak var addressTaskLabel: UILabel!
    @IBOutlet private weak var profilePhoto: UIImageView!
    @IBOutlet private weak var profileLogin: UILabel!
    @IBOutlet private weak var profileName: UILabel!
    
    // MARK: - Private Properties
    
    private var referenceComplitedTasks: DatabaseReference!
    private var referenceTasks: DatabaseReference!
    private var referenceProfile: DatabaseReference!
    private var profileId: String?
    private var userProfileLogin: String?
    
    // MARK: - Public Properties
    
    var declarationFromComplitedTasks: ModelActiveTasks!
    var uniqueKeyFromComplitedTasks: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adoptionOfData()
    }
    
    // MARK: - Private functions
    
    private func adoptionOfData() {
        declarationTaskLabel.text = declarationFromComplitedTasks.declaration
        dateTaskLabel.text = declarationFromComplitedTasks.date
        addressTaskLabel.text = declarationFromComplitedTasks.address
        typeTaskLabel.text = declarationFromComplitedTasks.type
        profileLogin.text = declarationFromComplitedTasks.login
        profileName.text = declarationFromComplitedTasks.profileName
        
        let profileUrl = URL(string: declarationFromComplitedTasks!.photo)
        let url = URL(string: declarationFromComplitedTasks!.imageURL)
        if let url = url {
            
            KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                self.imageTaskView.image = image
                self.imageTaskView.kf.indicatorType = .activity
            }
        }
        
        if let profileUrl = profileUrl {
            
            KingfisherManager.shared.retrieveImage(with: profileUrl as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                self.profilePhoto.image = image
                self.profilePhoto.kf.indicatorType = .activity
            }
        }
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Успех!", message: "", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Oк", style: .default){[weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(actionOk)
        present(alertController, animated: true)
    }
    
    private func addRespect(_ value: Int) {
        
        Database.database().reference().child(FBDefaultKeys.profilesInfo).child(profileLogin.text!).child(FBProfileInfoKeys.numberOfRespects).observeSingleEvent(of: .value, with: { [weak self] respects in
            Database.database().reference().child(FBDefaultKeys.profilesInfo).child((self?.profileLogin.text!)!).child(FBProfileInfoKeys.numberOfRespects).setValue((respects.value as! Int) + value)
        })
        
    }
    
    private func changeBalance(_ value: Int) {
        profileId = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
        
        referenceProfile = Database.database().reference().child(FBDefaultKeys.profiles)
        referenceProfile.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if snapshot.exists(){
                for profile in snapshot.children.allObjects as! [DataSnapshot] {
                    let taskObject = profile.value as? [String: AnyObject]
                    let taskLogin = taskObject?["login"]
                    print("Я  ищу   \(taskLogin)")
                    if taskLogin as? String == self?.profileLogin.text {
                        let balance = taskObject![FBProfileKeys.balance] as! Int
                        self?.referenceProfile.child(profile.key).child(FBProfileKeys.balance).setValue( balance + value)
                        break
                    }
                }
                
            }
        }
        )
    }
    
    // MARK: - IBAction
    
    @IBAction func didTapToNotCompliteTask(_ sender: Any) {
        addRespect(-1)
        profileId = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
        
        referenceComplitedTasks = Database.database().reference().child("ProfilesInfo").child(profileId!).child("ProcessingTasks")
        referenceTasks = Database.database().reference().child("ActiveTasks")
        self.referenceComplitedTasks.child(uniqueKeyFromComplitedTasks!).removeValue()
        showAlert()
    }
    
    @IBAction func didTapToCompliteTask(_ sender: Any) {
        addRespect(1)
        changeBalance(5)
        showAlert()
        profileId = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
        
        referenceTasks = Database.database().reference().child("ProfilesInfo").child(profileId!).child("ProcessingTasks")
        referenceComplitedTasks = Database.database().reference().child("ComplitedTasks")
        let key = referenceComplitedTasks.childByAutoId().key
        let task = ["address": declarationFromComplitedTasks.address,
                    "imageURL": declarationFromComplitedTasks.imageURL,
                    "taskName": declarationTaskLabel.text!,
                    "taskDate": dateTaskLabel.text!
        ] as! [String: Any]
        
        self.referenceComplitedTasks.child(key!).setValue(task)
        self.referenceTasks.child(uniqueKeyFromComplitedTasks!).removeValue()
    }
}


