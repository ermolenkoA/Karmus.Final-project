//
//  TaskMapViewController.swift
//  Karmus
//
//  Created by VironIT on 31.08.22.
//
import Firebase
import MapKit
import UIKit
import KeychainSwift


final class TaskMapViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, MKMapViewDelegate{
    
    // MARK: - IBOutlet

    @IBOutlet private weak var mapContainer: UIView!
    @IBOutlet private weak var mapView: MKMapView!
    
    // MARK: - Private Properties

    private var searchController: UISearchController!  = .init(searchResultsController: ResultsMapViewController())
    private var longitudeCoordinate: Double?
    private var latitudeCoordinate: Double?
    private var resultAddress: String?
    private var resultDeleagte: GetAddress?
    private var profileLogin: String?
    private var profileId: String?
    private var photo: String?
    private var name: String?
    private var login: String?
    private var addCoordinate = false
    private var refActiveTasks: DatabaseReference!
    private var refGroupActiveTasks: DatabaseReference!
    private var refAccuintCreatedTasks: DatabaseReference!
    private var refTasksCoordinates: DatabaseReference!
   
    // MARK: - Public Properties

    var typeFromCreation: String?
    var dateFromCreation: String?
    var declorationFromCreation: String?
    var imageFromCreation = UIImage()
    var imageViewFromCreation = UIImageView()
    var switchFromCreation: Bool?
    var taskCoordinate: CLLocationCoordinate2D!
    var uniqueKey: String?
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mapView.delegate = self
        refGroupActiveTasks = Database.database().reference().child("GroupTasks")
        refActiveTasks = Database.database().reference().child("ActiveTasks")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView = nil
        searchController = nil
        refGroupActiveTasks = nil
        refTasksCoordinates = nil
    }
    
    // MARK: - Private Functions

    private func showAlert(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default))
        present(alert, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? ResultsMapViewController else {
            return
        }
        
        resultVC.delegate = self
        resultVC.addressDelegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    resultVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func checkCoordinate(reference: DatabaseReference){
        reference.observeSingleEvent(of: .value){ [unowned self] snapshot in
            
            if snapshot.exists() {
                for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                    let taskObject = tasks.value as? [String: AnyObject]
                    let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                    let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                    
                    if  taskLongitudeCoordinate as? Double == self.longitudeCoordinate &&
                            taskLatitudeCoordinate as? Double == self.latitudeCoordinate {
                        self.addCoordinate = true
                    }
                }
            }
        }
    }
    
    private func dataFromProfile(reference: DatabaseReference) {
        profileLogin = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
        profileId = KeychainSwift.shared.get(ConstantKeys.currentProfile)
        refAccuintCreatedTasks = Database.database().reference().child("Profiles").child(profileId!).child("CreatedTasks")
        FireBaseDataBaseManager.getProfileForTask(profileLogin!) { [weak self] profile in
            
            guard let profile = profile else { return }
            self?.login = profile.login
            self?.photo = profile.photo
            self?.name = profile.name
            self?.saveFIRData(reference: reference)
            self?.saveFIRData(reference: (self?.refAccuintCreatedTasks)!)
        }
    }
    
    
    
    private func saveTask(imageURL: URL, referenceTask: DatabaseReference) {
        let key = referenceTask.childByAutoId().key
        uniqueKey = key
        
        let task = ["login": login!,
                    "photo": photo!,
                    "name": name!,
                    "address": resultAddress!,
                    "longitudeCoordinate": longitudeCoordinate!,
                    "latitudeCoordinate": latitudeCoordinate!,
                    "taskName": declorationFromCreation!,
                    "taskDate": dateFromCreation!,
                    "imageURL": imageURL.absoluteString,
                    "taskType": typeFromCreation!
        ] as [String: AnyObject]
        
        referenceTask.child(key!).setValue(task)
    }
    
    private func saveFIRData(reference: DatabaseReference) {
        
        FireBaseDataBaseManager.uploadPhoto(imageFromCreation) { url in
            if url == nil {
                return
            } else {
                self.saveTask(imageURL: url!, referenceTask: reference)
            }
        }
    }
    
    private func binarySearch<T:Comparable>(inputArr:Array<T>, searchItem: T) -> Int? {
        var lowerIndex = 0
        var upperIndex = inputArr.count - 1
        
        while (true) {
            let currentIndex = (lowerIndex + upperIndex)/2
            
            if(inputArr[currentIndex] == searchItem) {
                return currentIndex
            } else if (lowerIndex > upperIndex) {
                return nil
            } else {
                
                if (inputArr[currentIndex] > searchItem) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - IBAction
    
    @IBAction func addTaskButton(_ sender: Any) {
        
        if addCoordinate == false {
            
            if longitudeCoordinate != nil && latitudeCoordinate != nil{
                
                if switchFromCreation == true {
                    dataFromProfile(reference: refGroupActiveTasks)
                    
                    if let controller = navigationController?.viewControllers.first as? MapViewController {
                        navigationController?.popToViewController(controller, animated: true)
                    }
                } else {
                    dataFromProfile(reference: refActiveTasks)
                    
                    if let controller = navigationController?.viewControllers.first as? MapViewController {
                        navigationController?.popToViewController(controller, animated: true)
                    }
                }
            } else {
                showAlert(title: "Ошибка", message: "Вы не указали адрес", action: "Ок")
            }
        } else {
            showAlert(title: "Ошибка", message: "такой адрес уже существует", action: "Эхх")
        }
    }
    
    // MARK: - IBAction

    @IBAction func searchWithAddress(_ sender: Any) {
        self.addCoordinate = false
        
        searchController.searchBar.backgroundColor = .secondarySystemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        (searchController.searchResultsController as? SetDelegate)?.setDelegate(sender: self)
        
        self.present(searchController, animated: true)
    }
}

// MARK: - ResultsMapViewControllerDelegate

extension TaskMapViewController: ResultsMapViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        checkCoordinate(reference: refActiveTasks)
        checkCoordinate(reference: refGroupActiveTasks)
        searchController.dismiss(animated: true)
        searchController.searchBar.resignFirstResponder()
        
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        taskCoordinate = coordinates
        longitudeCoordinate = coordinates.longitude
        latitudeCoordinate = coordinates.latitude
        
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
            center: coordinates,
            latitudinalMeters: 600,
            longitudinalMeters: 600
        ),
        animated: true)
    }
}

// MARK: - GetAddress

extension TaskMapViewController: GetAddress {
    func resultAddress(address: String) {
        self.resultAddress = address
    }
}


